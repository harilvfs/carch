package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"github.com/briandowns/spinner"
	"github.com/fatih/color"
)

type Release struct {
	TagName    string `json:"tag_name"`
	Name       string `json:"name"`
	Prerelease bool   `json:"prerelease"`
}

type InstallConfig struct {
	RepoOwner     string
	RepoName      string
	BinaryName    string
	InstallDir    string
	ManDir        string
	IconDir       string
	DesktopFile   string
	BashCompDir   string
	ZshCompDir    string
	FishCompDir   string
	ConfigDir     string
	Version       string
	UsePrerelease bool
	Architecture  string
}

func NewInstallConfig() *InstallConfig {
	homeDir, _ := os.UserHomeDir()
	return &InstallConfig{
		RepoOwner:     "harilvfs",
		RepoName:      "carch",
		BinaryName:    "carch",
		InstallDir:    "/usr/local/bin",
		ManDir:        "/usr/local/share/man/man1",
		IconDir:       "/usr/share/icons/hicolor",
		DesktopFile:   "/usr/share/applications/carch.desktop",
		BashCompDir:   "/usr/share/bash-completion/completions",
		ZshCompDir:    "/usr/share/zsh/site-functions",
		FishCompDir:   "/usr/share/fish/vendor_completions.d",
		ConfigDir:     filepath.Join(homeDir, ".config", "carch"),
		Version:       "latest",
		UsePrerelease: false,
		Architecture:  getArchitecture(),
	}
}

func getArchitecture() string {
	arch := runtime.GOARCH
	switch arch {
	case "amd64":
		return "x86_64"
	case "arm64":
		return "aarch64"
	default:
		return arch
	}
}

func (c *InstallConfig) getGitHubAPIURL() string {
	return fmt.Sprintf("https://api.github.com/repos/%s/%s/releases", c.RepoOwner, c.RepoName)
}

func (c *InstallConfig) getDownloadURL() string {
	if c.Version == "latest" {
		if c.UsePrerelease {
			return fmt.Sprintf("https://github.com/%s/%s/releases/tag/%s/download", c.RepoOwner, c.RepoName, c.Version)
		}
		return fmt.Sprintf("https://github.com/%s/%s/releases/latest/download", c.RepoOwner, c.RepoName)
	}
	return fmt.Sprintf("https://github.com/%s/%s/releases/download/%s", c.RepoOwner, c.RepoName, c.Version)
}

func (c *InstallConfig) getBinaryFileName() string {
	if c.Architecture == "x86_64" {
		return c.BinaryName
	}
	return fmt.Sprintf("%s-%s", c.BinaryName, c.Architecture)
}

func detectPlatform() error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Detecting platform..."
	s.Start()
	defer s.Stop()

	if runtime.GOOS != "linux" {
		return fmt.Errorf("carch only supports Linux platforms. Detected: %s", runtime.GOOS)
	}

	arch := getArchitecture()
	if arch != "x86_64" && arch != "aarch64" {
		return fmt.Errorf("unsupported architecture: %s", arch)
	}

	time.Sleep(500 * time.Millisecond)
	s.Stop()
	_, _ = green.Printf("✓ Platform: Linux, Architecture: %s\n", arch)
	return nil
}

func checkDependencies() error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Checking dependencies..."
	s.Start()
	defer s.Stop()

	deps := []string{"curl", "tar", "fzf", "git", "wget", "man"}
	var missing []string

	for _, dep := range deps {
		if !commandExists(dep) {
			missing = append(missing, dep)
		}
	}

	if len(missing) > 0 {
		s.Stop()
		if confirm(fmt.Sprintf("Missing dependencies: %s. Do you want to install them? [Y/n]:", strings.Join(missing, ", ")), true) {
			_, _ = blue.Printf("→ Installing missing dependencies: %s\n", strings.Join(missing, ", "))
			if err := installDependencies(missing); err != nil {
				return fmt.Errorf("failed to install dependencies: %v", err)
			}
		} else {
			return fmt.Errorf("missing dependencies. Please install them manually: %s", strings.Join(missing, ", "))
		}
	}

	time.Sleep(300 * time.Millisecond)
	s.Stop()
	_, _ = green.Println("✓ All dependencies satisfied")
	return nil
}

func checkPrerelease(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Checking for pre-releases..."
	s.Start()

	resp, err := http.Get(config.getGitHubAPIURL())
	if err != nil {
		s.Stop()
		_, _ = yellow.Println("⚠ Could not check for pre-releases, using latest stable")
		return nil
	}
	defer func() {
		_ = resp.Body.Close()
	}()

	var releases []Release
	if err := json.NewDecoder(resp.Body).Decode(&releases); err != nil {
		s.Stop()
		_, _ = yellow.Println("⚠ Could not parse release information, using latest stable")
		return nil
	}

	s.Stop()

	for _, release := range releases {
		if release.Prerelease {
			_, _ = yellow.Printf("🚀 Pre-release available: %s (%s)\n", release.Name, release.TagName)
			_, _ = blue.Print(":: ")
			_, _ = rosewater.Print("Do you want to install this pre-release? [y/N]: ")

			var response string
			_, _ = fmt.Scanln(&response)
			response = strings.ToLower(strings.TrimSpace(response))

			if response == "y" || response == "yes" {
				config.UsePrerelease = true
				config.Version = release.TagName
				_, _ = blue.Printf("→ Will install pre-release version: %s\n", release.TagName)
				return nil
			}
			break
		}
	}

	_, _ = blue.Println("→ Using latest stable release")
	return nil
}

func installBinary(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Downloading carch binary..."
	s.Start()

	binaryURL := fmt.Sprintf("%s/%s", config.getDownloadURL(), config.getBinaryFileName())

	tmpFile, err := downloadFile(binaryURL, s)
	if err != nil {
		s.Stop()
		return fmt.Errorf("failed to download binary: %v", err)
	}
	defer func() {
		_ = os.Remove(tmpFile)
	}()

	s.Stop()
	s.Suffix = " Installing binary..."
	s.Start()

	if err := makeExecutable(tmpFile); err != nil {
		s.Stop()
		return fmt.Errorf("failed to make binary executable: %v", err)
	}

	if err := createDir(config.InstallDir); err != nil {
		s.Stop()
		return fmt.Errorf("failed to create install directory: %v", err)
	}

	destPath := filepath.Join(config.InstallDir, config.BinaryName)
	if err := sudoMoveFile(tmpFile, destPath); err != nil {
		s.Stop()
		return fmt.Errorf("failed to install binary: %v", err)
	}

	s.Stop()
	_, _ = green.Printf("✓ Binary installed to %s\n", destPath)
	return nil
}

func installCompletions(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Installing shell completions..."
	s.Start()

	completions := map[string]string{
		config.BashCompDir: fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/completions/bash/carch", config.RepoOwner, config.RepoName),
		config.ZshCompDir:  fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/completions/zsh/_carch", config.RepoOwner, config.RepoName),
		config.FishCompDir: fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/completions/fish/carch.fish", config.RepoOwner, config.RepoName),
	}

	filenames := map[string]string{
		config.BashCompDir: "carch",
		config.ZshCompDir:  "_carch",
		config.FishCompDir: "carch.fish",
	}

	for dir, url := range completions {
		if err := createDir(dir); err != nil {
			continue
		}

		tmpFile, err := downloadFile(url, s)
		if err != nil {
			continue
		}

		_ = sudoMoveFile(tmpFile, filepath.Join(dir, filenames[dir]))
		_ = os.Remove(tmpFile)
	}

	s.Stop()
	_, _ = green.Println("✓ Shell completions installed")
	return nil
}

func installIcons(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Installing icons..."
	s.Start()

	sizes := []string{"16", "24", "32", "48", "64", "128", "256"}

	for _, size := range sizes {
		iconDir := filepath.Join(config.IconDir, fmt.Sprintf("%sx%s", size, size), "apps")
		if err := createDir(iconDir); err != nil {
			continue
		}

		iconURL := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/assets/icons/carch_logo_%s.png",
			config.RepoOwner, config.RepoName, size)

		tmpFile, err := downloadFile(iconURL, s)
		if err != nil {
			continue
		}

		_ = sudoMoveFile(tmpFile, filepath.Join(iconDir, "carch.png"))
		_ = os.Remove(tmpFile)
	}

	if commandExists("gtk-update-icon-cache") {
		_ = runCommand("sudo", "gtk-update-icon-cache", "-f", "-t", config.IconDir)
	}

	s.Stop()
	_, _ = green.Println("✓ Icons installed")
	return nil
}

func installManPage(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Installing man page..."
	s.Start()

	if err := createDir(config.ManDir); err != nil {
		s.Stop()
		return fmt.Errorf("failed to create man directory: %v", err)
	}

	manURL := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/man/carch.1", config.RepoOwner, config.RepoName)
	tmpFile, err := downloadFile(manURL, s)
	if err != nil {
		s.Stop()
		return fmt.Errorf("failed to download man page: %v", err)
	}
	defer func() {
		_ = os.Remove(tmpFile)
	}()

	destPath := filepath.Join(config.ManDir, "carch.1")
	if err := sudoMoveFile(tmpFile, destPath); err != nil {
		s.Stop()
		return fmt.Errorf("failed to install man page: %v", err)
	}

	if commandExists("mandb") {
		_ = runCommand("sudo", "mandb", "-q")
	}

	s.Stop()
	_, _ = green.Println("✓ Man page installed")
	return nil
}

func installDesktopFile(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Installing desktop file..."
	s.Start()

	desktopURL := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/carch.desktop", config.RepoOwner, config.RepoName)
	tmpFile, err := downloadFile(desktopURL, s)
	if err != nil {
		s.Stop()
		return fmt.Errorf("failed to download desktop file: %v", err)
	}
	defer func() {
		_ = os.Remove(tmpFile)
	}()

	content, err := os.ReadFile(tmpFile)
	if err != nil {
		s.Stop()
		return fmt.Errorf("failed to read desktop file: %v", err)
	}

	execPath := filepath.Join(config.InstallDir, config.BinaryName)
	updatedContent := strings.ReplaceAll(string(content), "Exec=carch", fmt.Sprintf("Exec=%s", execPath))

	if err := os.WriteFile(tmpFile, []byte(updatedContent), 0644); err != nil {
		s.Stop()
		return fmt.Errorf("failed to update desktop file: %v", err)
	}

	if err := sudoMoveFile(tmpFile, config.DesktopFile); err != nil {
		s.Stop()
		return fmt.Errorf("failed to install desktop file: %v", err)
	}

	if commandExists("update-desktop-database") {
		_ = runCommand("sudo", "update-desktop-database")
	}

	s.Stop()
	_, _ = green.Println("✓ Desktop file installed")
	return nil
}

func printInstallSuccess() {
	fmt.Println()
	_, _ = green.Println("Carch installed successfully!")
	fmt.Println()
	fmt.Printf("You can now run carch from your terminal by typing: %s\n", color.New(color.Bold).Sprint("carch"))
	fmt.Println()
	fmt.Printf("If you need help, run: %s\n", color.New(color.Bold).Sprint("carch --help"))
	fmt.Println()
	fmt.Printf("For more information, visit: %s\n", color.New(color.Bold).Sprint("https://carch.chalisehari.com.np"))
	fmt.Println()
}

func Install() error {
	config := NewInstallConfig()

	if err := detectPlatform(); err != nil {
		_, _ = red.Printf("✖ Platform detection failed: %v\n", err)
		_, _ = blue.Println("Please ensure you are running this installer on a supported Linux distribution (x86_64 or aarch64).")
		return err
	}

	if err := checkDependencies(); err != nil {
		_, _ = red.Printf("✖ Dependency check failed: %v\n", err)
		_, _ = blue.Println("Please ensure all required dependencies are installed or allow the installer to install them.")
		return err
	}

	if err := checkPrerelease(config); err != nil {
		_, _ = red.Printf("✖ Pre-release check failed: %v\n", err)
		_, _ = blue.Println("This might be a network issue or a problem with the GitHub API. The installation will proceed with the latest stable release.")
		return err
	}

	if err := installBinary(config); err != nil {
		return err
	}

	if err := installCompletions(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installIcons(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installManPage(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installDesktopFile(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	printInstallSuccess()
	return nil
}
