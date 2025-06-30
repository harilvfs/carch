package main

import (
	"fmt"
)

func printUpdateSuccess() {
	fmt.Println()
	_, _ = green.Println("Carch updated successfully!")
	fmt.Println()
}

func Update() error {
	_, _ = blue.Println("Updating Carch...")
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

	printUpdateSuccess()
	return nil
}
