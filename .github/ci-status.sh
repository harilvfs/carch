#!/bin/bash

GITHUB_REPO="${GITHUB_REPOSITORY:-$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OUTPUT_FORMAT="${OUTPUT_FORMAT:-text}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Warning: GITHUB_TOKEN not set. Using unauthenticated API requests (rate limited)."
    AUTH_HEADER=""
else
    AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
fi

echo "Checking CI status for repository: $GITHUB_REPO"
echo "Fetching workflow runs..."

WORKFLOW_RUNS=$(curl -s -H "$AUTH_HEADER" \
    "https://api.github.com/repos/$GITHUB_REPO/actions/runs?per_page=30")

if echo "$WORKFLOW_RUNS" | grep -q "API rate limit exceeded"; then
    echo -e "${RED}Error: GitHub API rate limit exceeded. Please provide a GITHUB_TOKEN.${NC}"
    exit 1
elif echo "$WORKFLOW_RUNS" | grep -q "Not Found"; then
    echo -e "${RED}Error: Repository not found or you don't have access to it.${NC}"
    exit 1
fi

TOTAL_COUNT=$(echo "$WORKFLOW_RUNS" | jq '.total_count')
WORKFLOWS=$(echo "$WORKFLOW_RUNS" | jq '.workflow_runs[] | {id: .id, name: .name, status: .status, conclusion: .conclusion, branch: .head_branch, commit: .head_commit.message, url: .html_url, created_at: .created_at}')

case "$OUTPUT_FORMAT" in
    json)
        echo "$WORKFLOWS" | jq -s '.'
        ;;
    markdown)
        echo "# CI Workflow Status"
        echo
        echo "Repository: \`$GITHUB_REPO\`"
        echo "Last Updated: $(date)"
        echo
        echo "| Workflow | Status | Branch | Commit | Time |"
        echo "|----------|--------|--------|--------|------|"
        echo "$WORKFLOWS" | jq -r '.[] | "| [\(.name)](\(.url)) | \(.status) \(.conclusion // "") | \(.branch) | \(.commit // "" | .[0:50] + if (.[0:50] | length) == 50 then "..." else "" end) | \(.created_at) |"'
        ;;
    *)
        echo -e "\n===== CI Workflow Status ====="
        echo -e "Repository: $GITHUB_REPO"
        echo -e "Total workflows: $TOTAL_COUNT\n"
        
        echo "$WORKFLOWS" | jq -c '.[]' | while read -r workflow; do
            NAME=$(echo "$workflow" | jq -r '.name')
            STATUS=$(echo "$workflow" | jq -r '.status')
            CONCLUSION=$(echo "$workflow" | jq -r '.conclusion // "pending"')
            BRANCH=$(echo "$workflow" | jq -r '.branch')
            URL=$(echo "$workflow" | jq -r '.url')
            
            if [ "$STATUS" = "completed" ] && [ "$CONCLUSION" = "success" ]; then
                STATUS_DISPLAY="${GREEN}✓ Passed${NC}"
            elif [ "$STATUS" = "completed" ] && [ "$CONCLUSION" = "failure" ]; then
                STATUS_DISPLAY="${RED}✗ Failed${NC}"
            elif [ "$STATUS" = "in_progress" ]; then
                STATUS_DISPLAY="${YELLOW}⟳ Running${NC}"
            else
                STATUS_DISPLAY="${YELLOW}? $STATUS ($CONCLUSION)${NC}"
            fi
            
            echo -e "$NAME [$BRANCH]: $STATUS_DISPLAY"
            echo -e "  $URL"
        done
        ;;
esac

SUCCESS_COUNT=$(echo "$WORKFLOWS" | jq -r '. | select(.status == "completed" and .conclusion == "success") | .id' | wc -l)
FAILED_COUNT=$(echo "$WORKFLOWS" | jq -r '. | select(.status == "completed" and .conclusion == "failure") | .id' | wc -l)
RUNNING_COUNT=$(echo "$WORKFLOWS" | jq -r '. | select(.status == "in_progress") | .id' | wc -l)

echo -e "\nSummary:"
echo -e "${GREEN}Passing:${NC} $SUCCESS_COUNT"
echo -e "${RED}Failing:${NC} $FAILED_COUNT"
echo -e "${YELLOW}Running:${NC} $RUNNING_COUNT"

if [ $FAILED_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi
