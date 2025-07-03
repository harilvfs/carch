package main

import (
	"fmt"
	"github.com/fatih/color"
	"os"
	"strings"
)

const (
	version = "1.0.0"
)

var (
	rosewater = color.New(color.FgHiWhite, color.Bold)
	blue      = color.New(color.FgBlue, color.Bold)
	green     = color.New(color.FgGreen, color.Bold)
	yellow    = color.New(color.FgYellow, color.Bold)
	red       = color.New(color.FgRed, color.Bold)
)

func printUsage() {
	fmt.Println("Usage: carch-installer [COMMAND]")
	fmt.Println()
	fmt.Println("Commands:")
	fmt.Println("  install     Install Carch (default)")
	fmt.Println("  update      Update an existing Carch installation")
	fmt.Println("  uninstall   Uninstall Carch completely")
	fmt.Println("  help        Show this help message")
	fmt.Println()
	fmt.Printf("Version: %s\n", version)
}

func checkRoot() {
	if os.Geteuid() == 0 {
		_, _ = yellow.Println("⚠ Running as root is not recommended for this installer.")
		_, _ = blue.Println("It's safer to run without sudo and let the script prompt for sudo when necessary.")
		_, _ = blue.Println("Press Enter to continue, or Ctrl+C to abort and re-run without sudo.")
		_, _ = fmt.Scanln(new(string))
		fmt.Println()
	}
}

func main() {
	var command string
	if len(os.Args) < 2 {
		command = "install"
	} else {
		command = strings.ToLower(os.Args[1])
	}

	switch command {
	case "install", "":
		checkRoot()
		if err := Install(); err != nil {
			_, _ = red.Printf("Installation failed: %v\n", err)
			os.Exit(1)
		}
	case "update":
		checkRoot()
		if err := Update(); err != nil {
			_, _ = red.Printf("Update failed: %v\n", err)
			os.Exit(1)
		}
	case "uninstall":
		checkRoot()
		if err := Uninstall(); err != nil {
			_, _ = red.Printf("Uninstallation failed: %v\n", err)
			os.Exit(1)
		}
	case "help", "--help", "-h":
		printUsage()
	default:
		_, _ = red.Printf("Unknown command: %s. Use 'help' to see available commands.\n", command)
		os.Exit(1)
	}
}
