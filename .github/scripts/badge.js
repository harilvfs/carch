const { Octokit } = require('@octokit/rest');
const color = require('color');
const svgBuilder = require('svg-builder');
const fs = require('fs');
const path = require('path');

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const [owner, repo] = process.env.REPO_NAME.split('/');

async function run() {
  try {
    const { data } = await octokit.actions.listWorkflowRunsForRepo({
      owner,
      repo,
      per_page: 100,
    });

    const workflowMap = new Map();
    data.workflow_runs.forEach(run => {
      const existingRun = workflowMap.get(run.workflow_id);
      if (!existingRun || new Date(run.created_at) > new Date(existingRun.created_at)) {
        workflowMap.set(run.workflow_id, run);
      }
    });

    const latestRuns = Array.from(workflowMap.values());
    const totalWorkflows = latestRuns.length;
    const successfulWorkflows = latestRuns.filter(run => run.conclusion === 'success').length;
    const failedWorkflows = latestRuns.filter(run => run.conclusion === 'failure').length;
    const otherWorkflows = totalWorkflows - successfulWorkflows - failedWorkflows;
    
    const successRate = totalWorkflows > 0 ? (successfulWorkflows / totalWorkflows) * 100 : 0;
    
    generateBeautifulBadge(totalWorkflows, successfulWorkflows, failedWorkflows, otherWorkflows, successRate);
    
    console.log('Badge generation complete!');
  } catch (error) {
    console.error('Error generating badge:', error);
    process.exit(1);
  }
}

function generateBeautifulBadge(total, success, failed, other, successRate) {
  const width = 280;
  const height = 140;
  const svg = svgBuilder.newInstance()
    .width(width)
    .height(height);
  
  const gradientId = 'statusGradient';
  svg.element('defs')
    .element('linearGradient')
    .id(gradientId)
    .attr('x1', '0%')
    .attr('y1', '0%')
    .attr('x2', '100%')
    .attr('y2', '100%')
    .element('stop')
    .attr('offset', '0%')
    .attr('stop-color', '#2D3748')
    .attr('stop-opacity', 1)
    .end()
    .element('stop')
    .attr('offset', '100%')
    .attr('stop-color', '#1A202C')
    .attr('stop-opacity', 1)
    .end()
    .end();
  
  svg.element('rect')
    .attr('x', 0)
    .attr('y', 0)
    .attr('width', width)
    .attr('height', height)
    .attr('rx', 10)
    .attr('ry', 10)
    .attr('fill', `url(#${gradientId})`);
  
  svg.element('rect')
    .attr('x', 5)
    .attr('y', 5)
    .attr('width', width - 10)
    .attr('height', 25)
    .attr('rx', 8)
    .attr('ry', 8)
    .attr('fill', 'rgba(255, 255, 255, 0.1)');
  
  svg.element('text')
    .attr('x', width / 2)
    .attr('y', 25)
    .attr('text-anchor', 'middle')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 16)
    .attr('font-weight', 'bold')
    .attr('fill', 'white')
    .text('Workflow Status');
  
  const statusColor = successRate >= 90 ? '#38A169' :
                     successRate >= 75 ? '#ECC94B' :
                     '#E53E3E';
  
  const radius = 40;
  const centerX = width / 2;
  const centerY = 70;
  
  svg.element('circle')
    .attr('cx', centerX)
    .attr('cy', centerY)
    .attr('r', radius)
    .attr('fill', 'none')
    .attr('stroke', statusColor)
    .attr('stroke-width', 4)
    .attr('stroke-opacity', 0.8);
  
  svg.element('text')
    .attr('x', centerX)
    .attr('y', centerY)
    .attr('text-anchor', 'middle')
    .attr('dominant-baseline', 'middle')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 22)
    .attr('font-weight', 'bold')
    .attr('fill', statusColor)
    .text(`${Math.round(successRate)}%`);
  
  const detailsY = 115;
  const detailsSpacing = 85;
  
  svg.element('text')
    .attr('x', centerX - detailsSpacing)
    .attr('y', detailsY)
    .attr('text-anchor', 'middle')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 14)
    .attr('fill', '#38A169')
    .text(`✓ ${success}`);
  
  svg.element('text')
    .attr('x', centerX)
    .attr('y', detailsY)
    .attr('text-anchor', 'middle')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 14)
    .attr('fill', 'white')
    .text(`Total: ${total}`);
  
  svg.element('text')
    .attr('x', centerX + detailsSpacing)
    .attr('y', detailsY)
    .attr('text-anchor', 'middle')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 14)
    .attr('fill', '#E53E3E')
    .text(`✗ ${failed}`);
  
  const timestamp = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
  svg.element('text')
    .attr('x', width - 10)
    .attr('y', height - 10)
    .attr('text-anchor', 'end')
    .attr('font-family', 'Arial, sans-serif')
    .attr('font-size', 8)
    .attr('fill', 'rgba(255, 255, 255, 0.6)')
    .text(`Updated: ${timestamp}`);
  
  const svgContent = svg.render();
  
  if (!fs.existsSync('./badges')) {
    fs.mkdirSync('./badges', { recursive: true });
  }
  
  fs.writeFileSync('./badges/workflow-status.svg', svgContent);
  
  const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Workflow Status Badge</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
      background-color: #f7fafc;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      padding: 20px;
    }
    .container {
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      border-radius: 15px;
      overflow: hidden;
      background-color: white;
      padding: 30px;
      max-width: 600px;
      width: 100%;
    }
    h1 {
      color: #2d3748;
      margin-top: 0;
      text-align: center;
    }
    .badge-container {
      display: flex;
      justify-content: center;
      margin: 20px 0;
    }
    .info {
      margin-top: 20px;
      background-color: #f0f4f8;
      padding: 15px;
      border-radius: 8px;
      font-size: 0.9rem;
    }
    code {
      background-color: #edf2f7;
      padding: 2px 5px;
      border-radius: 4px;
      font-family: monospace;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>GitHub Workflow Status</h1>
    <div class="badge-container">
      <img src="workflow-status.svg" alt="Workflow Status Badge">
    </div>
    <div class="info">
      <code>![Workflow Status](https://${owner}.github.io/${repo}/badges/workflow-status.svg)</code>
      <p>Status: ${successRate >= 90 ? '✅ Healthy' : successRate >= 75 ? '⚠️ Warning' : '❌ Critical'}</p>
      <p>Total workflows: ${total} | Success: ${success} | Failed: ${failed} | Other: ${other}</p>
      <p>Success rate: ${Math.round(successRate)}%</p>
      <p><small>Last updated: ${timestamp}</small></p>
    </div>
  </div>
</body>
</html>
  `;
  
  fs.writeFileSync('./badges/index.html', htmlContent);
}

run();
