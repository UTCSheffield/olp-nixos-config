package main

import (
	"io"
	"log"
	"math/rand"
	"net"
	"net/http"
	"time"
	"os"
	"os/exec"
	"strings"
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
		log.SetOutput(os.Stderr)
		log.Println("Could not read config, using default")
		return "http://127.0.0.1:8080"
	}

	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		if strings.HasPrefix(line, "base_url") {
			parts := strings.SplitN(line, "=", 2)
			if len(parts) != 2 {
				continue
			}
			val := strings.TrimSpace(parts[1])
			val = strings.Trim(val, `"`) // remove quotes
			return val
		}
	}

	return "http://127.0.0.1:8080"
}

func main() {
	log.SetOutput(os.Stdout)
	baseURL := getPollBaseURL()

	sysConf, err := readSystemConf()
	if err != nil {
		log.SetOutput(os.Stderr)
		log.Println("Error reading system configuration:", err)
		return
	}

	waitForNetwork()
	log.Println("Client started")

	for {
		waitForNetwork()

		sysConf, err = readSystemConf()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error reading system configuration:", err)
			return
		}

		cmd := exec.Command("hostnamectl", "set-hostname", sysConf.Hostname)
		
		output, err := cmd.Output()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error executing command:", err)
			return
		}

		cmd = exec.Command("git", "-C", "/etc/nixos", "rev-parse", "--abbrev-ref", "HEAD")

		output, err = cmd.Output()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error executing command:", err)
			return
		}

		branch := strings.TrimSpace(string(output))
		if branch != "master" {
			continue
		}

		res, err := http.Get(baseURL + "/poll")
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Printf("Error fetching poll endpoint: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		body, err := io.ReadAll(res.Body)
		res.Body.Close()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Printf("Error reading response body: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		commit := string(body)
		cmd = exec.Command("git", "-C", "/etc/nixos", "rev-parse", "HEAD")
	
		output, err = cmd.Output()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error executing command:", err)
			return
		}

		currentCommit := strings.TrimSpace(string(output))
		commit = strings.TrimSpace(commit)
		if currentCommit == commit {
			log.Println("Up to date")
			continue
		}
		
		cmd = exec.Command("git", "-C", "/etc/nixos", "pull")
	
		output, err = cmd.Output()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error executing command:", err)
			return
		}

		cmd = exec.Command("nixos-rebuild", "switch", "--flake", "/etc/nixos#" + sysConf.Config)
	
		output, err = cmd.Output()
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println("Error executing command:", err)
			return
		}

		log.Println("Updated successfully")

		time.Sleep(time.Duration(rand.Intn(1)+1) * time.Minute)
	}
}
