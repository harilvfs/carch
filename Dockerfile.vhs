FROM ghcr.io/charmbracelet/vhs

# Install required dependencies
RUN apt-get update && apt-get install -y fzf figlet
