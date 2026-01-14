package main

import (
	"io"
	"log"
	"math/rand"
	"net"
	"net/http"
	"os"
	"os/exec"
	"strings"
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

func replaceHostname(hostname string) {
	if err := os.Remove("/etc/hostname"); err != nil && !os.IsNotExist(err) {
		log.Fatalf("failed to remove /etc/hostname: %v", err)
	}
	f, err := os.OpenFile("/etc/hostname", os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		log.Fatalf("failed to create /etc/hostname: %v", err)
	}
	defer f.Close()

	if _, err := f.WriteString(hostname + "\n"); err != nil {
		log.Fatalf("failed to write hostname: %v", err)
	}
}

func main() {
	log.SetOutput(os.Stdout)
	rand.Seed(time.Now().UnixNano())

	baseURL := getPollBaseURL()

	waitForNetwork()
	log.Println("Client started")

	for {
		waitForNetwork()

		sysConf, err := readSystemConf()
		if err != nil {
			log.Fatalf("Error reading system configuration: %v", err)
		}

		replaceHostname(sysConf.Hostname)

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
		run("nixos-rebuild", "switch", "--flake", "/etc/nixos#"+sysConf.Config)

		log.Println("Updated successfully")

		time.Sleep(1.5 * time.Minute)
	}
}
