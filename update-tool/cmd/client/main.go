package main

import (
	"io"
	"log"
	"math/rand"
	"net"
	"net/http"
	"time"
)

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

func main() {
	waitForNetwork()
	log.Println("Client started")

	for {
		waitForNetwork()

		cmd := exec.Command("git", "-C", "/etc/nixos", "rev-parse", "--abbrev-ref", "HEAD")
	
		output, err := cmd.Output()
		if err != nil {
			fmt.Println("Error executing command:", err)
			return
		}

		if output != "master" {
			continue
		}

		res, err := http.Get("http://127.0.0.1:8080/poll")
		if err != nil {
			log.Printf("Error fetching poll endpoint: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		body, err := io.ReadAll(res.Body)
		res.Body.Close()
		if err != nil {
			log.Printf("Error reading response body: %v", err)
			time.Sleep(10 * time.Second)
			continue
		}

		commit := string(body)
		cmd := exec.Command("git", "-C", "/etc/nixos", "rev-parse", "HEAD")
	
		output, err := cmd.Output()
		if err != nil {
			fmt.Println("Error executing command:", err)
			return
		}

		if output == commit {
			log.Printf("Up to date")
			continue
		}
		
		cmd := exec.Command("git", "-C", "/etc/nixos", "pull")
	
		output, err := cmd.Output()
		if err != nil {
			fmt.Println("Error executing command:", err)
			return
		}

		cmd := exec.Command("nixos-rebuild", "switch", "--flake", "/etc/nixos#makerlab")
	
		output, err := cmd.Output()
		if err != nil {
			fmt.Println("Error executing command:", err)
			return
		}

		fmt.Println("Updated successfully")

		time.Sleep(time.Duration(rand.Intn(1)+1) * time.Minute)
	}
}
