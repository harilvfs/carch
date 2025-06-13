package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/briandowns/spinner"
)

func fileExists(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}

func dirExists(path string) bool {
	info, err := os.Stat(path)
	return !os.IsNotExist(err) && info.IsDir()
}

func createDir(path string) error {
	return runCommand("sudo", "mkdir", "-p", path)
}

func makeExecutable(path string) error {
	return os.Chmod(path, 0755)
}

func sudoMoveFile(src, dest string) error {
	return runCommand("sudo", "mv", src, dest)
}

func commandExists(command string) bool {
	_, err := exec.LookPath(command)
	return err == nil
}

func runCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	return cmd.Run()
}

func runCommandWithOutput(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	output, err := cmd.Output()
	return strings.TrimSpace(string(output)), err
}

func downloadFile(url string) (string, error) {
	tmpFile, err := os.CreateTemp("", "carch-download-*")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %v", err)
	}
	defer tmpFile.Close()

	resp, err := http.Get(url)
	if err != nil {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to download file: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("download failed with status: %s", resp.Status)
	}

	_, err = io.Copy(tmpFile, resp.Body)
	if err != nil {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to save file: %v", err)
	}

	return tmpFile.Name(), nil
}

// Dependency management
func installDependencies(deps []string) error {
	s := spinner.New(spinner.CharSets[14], 100*time.Millisecond)
	s.Suffix = fmt.Sprintf(" Installing dependencies: %s", strings.Join(deps, ", "))
	s.Start()
	defer s.Stop()

	var err error
	if commandExists("pacman") {
		args := append([]string{"-Sy", "--noconfirm"}, deps...)
		err = runCommand("sudo", append([]string{"pacman"}, args...)...)
	} else if commandExists("dnf") {
		args := append([]string{"install", "-y"}, deps...)
		err = runCommand("sudo", append([]string{"dnf"}, args...)...)
	} else if commandExists("yum") {
		args := append([]string{"install", "-y"}, deps...)
		err = runCommand("sudo", append([]string{"yum"}, args...)...)
	} else {
		s.Stop()
		return fmt.Errorf("unsupported package manager. Please install the following dependencies manually: %s", strings.Join(deps, ", "))
	}

	time.Sleep(500 * time.Millisecond)
	return err
}
