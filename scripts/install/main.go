package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/fatih/color"
)

const (
	version = "1.0.0"
	banner  = `
  _____             __
 / ___/__ _________/ /
/ /__/ _ ` + "`" + `/ __/ __/ _ \
\___/\_,_/_/  \__/_//_/

https://github.com/harilvfs/carch
`
)

var (
	flamingo  = color.New(color.FgHiMagenta, color.Bold)
	rosewater = color.New(color.FgHiWhite, color.Bold)
	blue      = color.New(color.FgBlue, color.Bold)
	green     = color.New(color.FgGreen, color.Bold)
	yellow    = color.New(color.FgYellow, color.Bold)
	red       = color.New(color.FgRed, color.Bold)
)

func printBanner() {
	_, _ = flamingo.Print(banner)
	fmt.Println()
}

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

func confirmAction(message string) bool {
	for {
		_, _ = blue.Print(":: ")
		_, _ = rosewater.Printf("%s [y/N]: ", message)

		var response string
		_, _ = fmt.Scanln(&response)
		response = strings.ToLower(strings.TrimSpace(response))

		switch response {
		case "y", "yes":
			fmt.Println()
			return true
		case "n", "no", "":
			return false
		default:
			_, _ = red.Println("Invalid input. Please answer y or n.")
		}
	}
}

func checkRoot() {
	if os.Geteuid() == 0 {
		_, _ = yellow.Println("⚠ This script is running as root. Consider running without sudo and let the script call sudo when needed.")
		fmt.Println()
	}
}

func clearScreen() {
	cmd := exec.Command("clear")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	_ = cmd.Run()
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
		clearScreen()
		checkRoot()
		printBanner()
		if confirmAction("Do you want to continue with the installation?") {
			if err := Install(); err != nil {
				_, _ = red.Printf("Installation failed: %v\n", err)
				os.Exit(1)
			}
		}
	case "update":
		checkRoot()
		if confirmAction("Do you want to continue with the carch update?") {
			if err := Update(); err != nil {
				_, _ = red.Printf("Update failed: %v\n", err)
				os.Exit(1)
			}
		}
	case "uninstall":
		checkRoot()
		if confirmAction("Do you want to continue with the carch uninstallation?") {
			if err := Uninstall(); err != nil {
				_, _ = red.Printf("Uninstallation failed: %v\n", err)
				os.Exit(1)
			}
		}
	case "help", "--help", "-h":
		printUsage()
	default:
		_, _ = red.Printf("Unknown command: %s. Use 'help' to see available commands.\n", command)
		os.Exit(1)
	}
}
