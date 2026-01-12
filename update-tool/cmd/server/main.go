package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"update-tool/pkg/storage"
)

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
	hash, err := storage.ReadCommitHash()
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
		storage.WriteCommitHash(hash)
	}

	fmt.Fprint(w, hash)
}

type Payload struct {
	Before  string `json:"before"`
	After   string `json:"after"`
	BaseRef string `json:"base_ref"`
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

	if payload.BaseRef != "refs/heads/master" {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Ignored non-master branch"))
		return
	}

	storage.WriteCommitHash(payload.After)

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func main() {
	http.HandleFunc("/poll", pollHandler)
	http.HandleFunc("/webhook", webhookHandler)
	fmt.Println("HTTP server started on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
	}
}
