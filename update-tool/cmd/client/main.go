package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"syscall"
	"time"
)

type Config struct {
	Hostname string
	Config   string
}

func readSystemConf() (Config, error) {
	var c Config
	data, err := os.ReadFile("/etc/nixos/system.conf")
	if err != nil {
		return c, err
	}

	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		k, v, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}

		key := strings.TrimSpace(k)
		val := strings.Trim(strings.TrimSpace(v), `"`)

		switch key {
		case "hostname":
			c.Hostname = val
		case "config":
			c.Config = val
		}
	}

	return c, nil
}

func checkNetwork() bool {
	timeout := 2 * time.Second
	_, err := net.DialTimeout("tcp", "github.com:443", timeout)
	return err == nil
}

func waitForNetwork() {
	for {
		if checkNetwork() {
			return
		}
		log.Println("Network down, retrying in 5s...")
		time.Sleep(5 * time.Second)
	}
}

func getPollBaseURL() string {
	data, err := os.ReadFile("/etc/update-tool.conf")
	if err != nil {
		log.Println("Could not read config, using default")
		return "http://127.0.0.1:8080"
	}

	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		if strings.HasPrefix(line, "base_url") {
			_, v, ok := strings.Cut(line, "=")
			if !ok {
				continue
			}
			return strings.Trim(strings.TrimSpace(v), `"`)
		}
	}

	return "http://127.0.0.1:8080"
}

func run(name string, args ...string) string {
	cmd := exec.Command(name, args...)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Fatalf(
			"command failed: %s %s\nexit error: %v\noutput:\n%s",
			name,
			strings.Join(args, " "),
			err,
			output,
		)
	}
	return strings.TrimSpace(string(output))
}

func replaceHostname(hostname string) error {
	if hostname == "" {
		return fmt.Errorf("hostname is empty in /etc/nixos/system.conf")
	}
	current, err := os.Hostname()
	if err != nil {
		return fmt.Errorf("read current hostname: %w", err)
	}
	if current != hostname {
		if err := syscall.Sethostname([]byte(hostname)); err != nil {
			return fmt.Errorf("set hostname: %w", err)
		}
	}

	data, err := os.ReadFile("/etc/hostname")
	if err == nil && string(data) == hostname+"\n" {
		return nil
	}
	// NixOS may manage this file as a symlink into the read-only Nix store.
	if err := os.Remove("/etc/hostname"); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("remove /etc/hostname: %w", err)
	}
	if err := os.WriteFile("/etc/hostname", []byte(hostname+"\n"), 0644); err != nil {
		return fmt.Errorf("write /etc/hostname: %w", err)
	}
	return nil
}

func syncHostname() {
	sysConf, err := readSystemConf()
	if err != nil {
		log.Printf("Hostname sync: %v", err)
		return
	}
	if err := replaceHostname(sysConf.Hostname); err != nil {
		log.Printf("Hostname sync: %v", err)
	}
}

func main() {
	oneshot := flag.Bool("oneshot", false, "run once then exit")
	flag.Parse()

	log.SetOutput(os.Stdout)
	rand.Seed(time.Now().UnixNano())

	baseURL := getPollBaseURL()

	syncHostname()
	go func() {
		ticker := time.NewTicker(time.Minute)
		defer ticker.Stop()
		for range ticker.C {
			syncHostname()
		}
	}()

	waitForNetwork()
	log.Println("Client started")

	for {
		waitForNetwork()

		sysConf, err := readSystemConf()
		if err != nil {
			log.Fatalf("Error reading system configuration: %v", err)
		}

		branch := run("git", "-C", "/etc/nixos", "rev-parse", "--abbrev-ref", "HEAD")
		if branch != "master" {
			log.Println("Not on master branch, skipping")
			time.Sleep(1 * time.Minute)
			continue
		}

		res, err := http.Get(baseURL + "/poll")
		if err != nil {
			log.Printf("Poll request failed: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		body, err := io.ReadAll(res.Body)
		res.Body.Close()
		if err != nil {
			log.Printf("Failed reading poll response: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		remoteCommit := strings.TrimSpace(string(body))
		currentCommit := run("git", "-C", "/etc/nixos", "rev-parse", "HEAD")

		if currentCommit == remoteCommit {
			log.Println("Up to date")
			time.Sleep(1 * time.Minute)
			continue
		}

		run("git", "-C", "/etc/nixos", "pull")
		run("/run/current-system/sw/bin/nixos-rebuild", "switch", "--flake", "/etc/nixos#"+sysConf.Config)

		log.Println("Updated successfully")

		if *oneshot {
			return
		}

		time.Sleep(90 * time.Second)
	}
}
