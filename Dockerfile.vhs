FROM archlinux:latest AS arch_deps

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm figlet fzf

FROM ghcr.io/charmbracelet/vhs

# Copy binaries from Arch Linux
COPY --from=arch_deps /usr/bin/figlet /usr/bin/figlet
COPY --from=arch_deps /usr/bin/fzf /usr/bin/fzf

# Copy any necessary libraries or additional files
COPY --from=arch_deps /usr/share/figlet /usr/share/figlet

# Verify executables work
RUN figlet "test" && which fzf
