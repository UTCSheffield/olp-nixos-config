package main

import (
	"encoding/json"
	"log"
	"io"
	"net/http"
	"fmt"
	"os"
	"strings"
)

const commitFile = "latest_commit.txt"

func readCommitHash() (string, error) {
	data, err := os.ReadFile(commitFile)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	return string(data), nil
}

func writeCommitHash(hash string) error {
	if hash == "" {
		return fmt.Errorf("commit hash is empty")
	}
	return os.WriteFile(commitFile, []byte(hash), 0644)
}

type Config struct {
	ListenPort string
	Owner      string
	Repo       string
	Branch     string
}

func ReadConfig(path string) (Config, error) {
	cfg := Config{
		ListenPort: "8080",
		Owner:      "UTCSheffield",
		Repo:       "olp-nixos-config",
		Branch:     "master",
	}

	data, err := os.ReadFile(path)
	if err != nil {
		return cfg, err
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
		val := strings.Trim(strings.TrimSpace(v), `"`) // remove quotes

		switch key {
		case "listen_port":
			cfg.ListenPort = val
		case "owner":
			cfg.Owner = val
		case "repo":
			cfg.Repo = val
		case "branch":
			cfg.Branch = val
		}
	}

	return cfg, nil
}

type GitHubCommit struct {
	SHA string `json:"sha"`
}

func fetchCommitHash(owner, repo, branch string) (string, error) {
	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/commits/%s", owner, repo, branch)

	res, err := http.Get(url)
	if err != nil {
		return "", err
	}
	defer res.Body.Close()

	if res.StatusCode != 200 {
		return "", fmt.Errorf("GitHub API returned status %d", res.StatusCode)
	}

	body, err := io.ReadAll(res.Body)
	if err != nil {
		return "", err
	}

	var commit GitHubCommit
	if err := json.Unmarshal(body, &commit); err != nil {
		return "", err
	}

	return commit.SHA, nil
}

func pollHandler(w http.ResponseWriter, r *http.Request) {
	hash, err := readCommitHash()
	if err != nil {
		http.Error(w, "Failed to read commit hash", http.StatusInternalServerError)
		return
	}

	if hash == "" {
		hash, err = fetchCommitHash("UTCSheffield", "olp-nixos-config", "master")
		if err != nil {
			http.Error(w, "Failed to fetch commit hash", http.StatusInternalServerError)
			return
		}
		writeCommitHash(hash)
	}

	fmt.Fprint(w, hash)
}

type Payload struct {
	Before  string `json:"before"`
	After   string `json:"after"`
	Ref string `json:"ref"`
}

func webhookHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var payload Payload
	if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	if payload.Ref != "refs/heads/master" {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Ignored non-master branch"))
		return
	}

	writeCommitHash(payload.After)

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func main() {
	log.SetOutput(os.Stdout)
	hash, err := fetchCommitHash("UTCSheffield", "olp-nixos-config", "master")
	if err != nil {
		log.SetOutput(os.Stderr)
		log.Println("Failed to fetch commit hash")
		return
	}
	writeCommitHash(hash)

	cfg, err := ReadConfig("/etc/update-tool.conf")

	http.HandleFunc("/poll", pollHandler)
	http.HandleFunc("/webhook", webhookHandler)
	fmt.Println("HTTP server started")
	err = http.ListenAndServe(":" + cfg.ListenPort, nil)
	if err != nil {
		log.SetOutput(os.Stderr)
		log.Println("Error starting server:", err)
		return
	}
}
