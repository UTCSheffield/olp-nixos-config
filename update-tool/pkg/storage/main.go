package storage

import (
	"fmt"
	"os"
)

const commitFile = "latest_commit.txt"

func ReadCommitHash() (string, error) {
	data, err := os.ReadFile(commitFile)
	if err != nil {
		if os.IsNotExist(err) {
			return "", nil
		}
		return "", err
	}
	return string(data), nil
}

func WriteCommitHash(hash string) error {
	if hash == "" {
		return fmt.Errorf("commit hash is empty")
	}
	return os.WriteFile(commitFile, []byte(hash), 0644)
}
