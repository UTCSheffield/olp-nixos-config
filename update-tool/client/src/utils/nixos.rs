use std::process::Command;

pub fn rebuild_system(directory: &str) -> String {
    println!("Current Path {}", directory);
    let cmd = Command::new("nixos-rebuild")
    .args(&["switch", "--flake", ".#makerlab-3040"])
    .current_dir(directory) // Directory: /etc/nixos
    .output()
    .expect("Failed to execute command");
    let output = String::from_utf8_lossy(cmd.stdout.as_slice()).into_owned();
    return output;
}
