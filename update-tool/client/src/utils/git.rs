// Rust bindings for the Git CLI
use std::process::Command;


pub fn git_get_latest_hash(directory: &str) -> String {
    let cmd = Command::new("git")
        .args(&["rev-parse", "HEAD"])
        .current_dir(directory)
        .output()
        .expect("Failed to execute command");
    let output = String::from_utf8_lossy(cmd.stdout.as_slice()).into_owned();
    return output;
}

pub fn git_pull(directory: &str) -> String {
    let cmd = Command::new("git")
        .args(&["pull"])
        .current_dir(directory)
        .output()
        .expect("Failed to execute command");
    let output = String::from_utf8_lossy(cmd.stdout.as_slice()).into_owned();
    return output;
}