package main

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/briandowns/spinner"
)

func uninstallBinary(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing carch binary..."
	s.Start()

	binaryPath := filepath.Join(config.InstallDir, config.BinaryName)
	if fileExists(binaryPath) {
		if err := runCommand("sudo", "rm", "-f", binaryPath); err != nil {
			s.Stop()
			return fmt.Errorf("failed to remove binary: %v", err)
		}
		s.Stop()
		_, _ = green.Println("✓ Binary removed")
	} else {
		s.Stop()
		_, _ = yellow.Println("⚠ Binary not found")
	}
	return nil
}

func uninstallCompletions(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing shell completions..."
	s.Start()

	completions := map[string]string{
		config.BashCompDir: "carch",
		config.ZshCompDir:  "_carch",
		config.FishCompDir: "carch.fish",
	}

	removed := 0
	for dir, filename := range completions {
		filePath := filepath.Join(dir, filename)
		if fileExists(filePath) {
			_ = runCommand("sudo", "rm", "-f", filePath)
			removed++
		}
	}

	s.Stop()
	if removed > 0 {
		_, _ = green.Printf("✓ %d shell completions removed\n", removed)
	} else {
		_, _ = yellow.Println("⚠ No shell completions found")
	}
	return nil
}

func uninstallIcons(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing icons..."
	s.Start()

	sizes := []string{"16", "24", "32", "48", "64", "128", "256"}
	removed := 0

	for _, size := range sizes {
		iconPath := filepath.Join(config.IconDir, fmt.Sprintf("%sx%s", size, size), "apps", "carch.png")
		if fileExists(iconPath) {
			_ = runCommand("sudo", "rm", "-f", iconPath)
			removed++
		}
	}

	if commandExists("gtk-update-icon-cache") {
		_ = runCommand("sudo", "gtk-update-icon-cache", "-f", "-t", config.IconDir)
	}

	s.Stop()
	if removed > 0 {
		_, _ = green.Printf("✓ %d icons removed\n", removed)
	} else {
		_, _ = yellow.Println("⚠ No icons found")
	}
	return nil
}

func uninstallManPage(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing man page..."
	s.Start()

	manPath := filepath.Join(config.ManDir, "carch.1")
	if fileExists(manPath) {
		if err := runCommand("sudo", "rm", "-f", manPath); err != nil {
			s.Stop()
			return fmt.Errorf("failed to remove man page: %v", err)
		}

		if commandExists("mandb") {
			_ = runCommand("sudo", "mandb", "-q")
		}

		s.Stop()
		_, _ = green.Println("✓ Man page removed")
	} else {
		s.Stop()
		_, _ = yellow.Println("⚠ Man page not found")
	}
	return nil
}

func uninstallDesktopFile(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing desktop file..."
	s.Start()

	if fileExists(config.DesktopFile) {
		if err := runCommand("sudo", "rm", "-f", config.DesktopFile); err != nil {
			s.Stop()
			return fmt.Errorf("failed to remove desktop file: %v", err)
		}

		if commandExists("update-desktop-database") {
			_ = runCommand("sudo", "update-desktop-database")
		}

		s.Stop()
		_, _ = green.Println("✓ Desktop file removed")
	} else {
		s.Stop()
		_, _ = yellow.Println("⚠ Desktop file not found")
	}
	return nil
}

func uninstallConfig(config *InstallConfig) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = " Removing configuration directory..."
	s.Start()

	if dirExists(config.ConfigDir) {
		if err := os.RemoveAll(config.ConfigDir); err != nil {
			s.Stop()
			return fmt.Errorf("failed to remove config directory: %v", err)
		}
		s.Stop()
		_, _ = green.Println("✓ Configuration directory removed")
	} else {
		s.Stop()
		_, _ = yellow.Println("⚠ Configuration directory not found")
	}
	return nil
}

func printUninstallSuccess() {
	fmt.Println()
	_, _ = green.Println("👋 Carch uninstalled successfully!")
	fmt.Println()
	fmt.Println("All Carch components have been removed from your system.")
	fmt.Println()
	fmt.Println("Thank you for using Carch!")
	fmt.Println()
}

func Uninstall() error {
	_, _ = blue.Println("Uninstalling Carch...")
	fmt.Println()

	config := NewInstallConfig()

	if err := uninstallBinary(config); err != nil {
		return err
	}

	if err := uninstallCompletions(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := uninstallIcons(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := uninstallManPage(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := uninstallDesktopFile(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := uninstallConfig(config); err != nil {
		_, _ = yellow.Printf("⚠ Warning: %v\n", err)
	}

	printUninstallSuccess()
	return nil
}
