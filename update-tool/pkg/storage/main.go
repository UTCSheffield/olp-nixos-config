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

type Config struct {
    Hostname string
    Config   string
}

func ReadSysConf(path string) (Config, error) {
    var c Config
    data, err := os.ReadFile(path)
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
        val := strings.Trim(strings.TrimSpace(v), `"`) // remove quotes

        switch key {
        case "hostname":
            c.Hostname = val
        case "config":
            c.Config = val
        }
    }

    return c, nil
}