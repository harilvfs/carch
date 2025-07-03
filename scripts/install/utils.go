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

type progressWriter struct {
	Writer     io.Writer
	Total      int64
	Downloaded int64
	Spinner    *spinner.Spinner
}

func (pw *progressWriter) Write(p []byte) (n int, err error) {
	n, err = pw.Writer.Write(p)
	pw.Downloaded += int64(n)
	if pw.Total > 0 {
		progress := float64(pw.Downloaded) / float64(pw.Total) * 100
		pw.Spinner.Suffix = fmt.Sprintf(" Downloading... %.2f%%", progress)
	} else {
		pw.Spinner.Suffix = fmt.Sprintf(" Downloading... %d KB", pw.Downloaded/1024)
	}
	return
}

func downloadFile(url string, s *spinner.Spinner) (string, error) {
	tmpFile, err := os.CreateTemp("", "carch-download-*")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %v", err)
	}
	defer func() {
		_ = tmpFile.Close()
	}()

	resp, err := http.Get(url)
	if err != nil {
		_ = os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to download file: %v", err)
	}
	defer func() {
		_ = resp.Body.Close()
	}()

	if resp.StatusCode != http.StatusOK {
		_ = os.Remove(tmpFile.Name())
		return "", fmt.Errorf("download failed with status: %s", resp.Status)
	}

	contentLength := resp.ContentLength
	writer := &progressWriter{Writer: tmpFile, Total: contentLength, Spinner: s}

	_, err = io.Copy(writer, resp.Body)
	if err != nil {
		_ = os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to save file: %v", err)
	}

	return tmpFile.Name(), nil
}

func confirm(prompt string, defaultValue bool) bool {
	_, _ = blue.Print(":: ")
	_, _ = rosewater.Printf("%s ", prompt)

	var response string
	_, _ = fmt.Scanln(&response)
	response = strings.ToLower(strings.TrimSpace(response))

	if response == "y" || response == "yes" {
		return true
	}
	if response == "n" || response == "no" {
		return false
	}
	return defaultValue
}

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
