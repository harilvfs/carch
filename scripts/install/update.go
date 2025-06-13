package main

import (
	"fmt"

	"github.com/fatih/color"
)

func printUpdateSuccess() {
	fmt.Println()
	green.Println("🚀 Carch updated successfully!")
	fmt.Println()
	fmt.Printf("You can now run the updated carch from your terminal by typing: %s\n", color.New(color.Bold).Sprint("carch"))
	fmt.Println()
	fmt.Printf("If you need help, run: %s\n", color.New(color.Bold).Sprint("carch --help"))
	fmt.Println()
	fmt.Printf("For more information, visit: %s\n", color.New(color.Bold).Sprint("https://carch.chalisehari.com.np"))
	fmt.Println()
}

func Update() error {
	blue.Println("🔄 Updating Carch...")
	fmt.Println()

	config := NewInstallConfig()

	if err := detectPlatform(); err != nil {
		return err
	}

	if err := checkDependencies(); err != nil {
		return err
	}

	if err := checkPrerelease(config); err != nil {
		return err
	}

	if err := installBinary(config); err != nil {
		return err
	}

	if err := installCompletions(config); err != nil {
		yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installIcons(config); err != nil {
		yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installManPage(config); err != nil {
		yellow.Printf("⚠ Warning: %v\n", err)
	}

	if err := installDesktopFile(config); err != nil {
		yellow.Printf("⚠ Warning: %v\n", err)
	}

	printUpdateSuccess()
	return nil
}
