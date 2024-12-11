// Rust bindings for the Git CLI
use std::process::Command;


pub fn git_get_latest_hash(directory: &str) -> String {
    let cmd = Command::new("git")
        .args(&["rev-parse", "HEAD"])
        .current_dir(directory) // Directory: /etc/nixos
        .output()
        .expect("Failed to execute command");
    let output = String::from_utf8_lossy(cmd.stdout.as_slice()).into_owned();
    return output;
}

pub fn git_pull(directory: &str) -> bool {
    let old_hash = git_get_latest_hash(directory);
    let cmd = Command::new("git")
        .args(&["pull"])
        .current_dir(directory)
        .output()
        .expect("Failed to execute command");
    // Check if hash is correct and work from there
    let new_hash = git_get_latest_hash(directory);
    if new_hash !== old_hash { // If the hashes are the same, the pull did nothing
        return true;
    } else {
        return false;
    }
}
