use std::process::Command;

pub fn run() {
    // Run the command to manually trigger a rebuild
    let output = Command::new("sudo nixos-rebuild switch") // TODO: FUTURE: Make this read the flake from setup.toml
        .args(&["--flake", "/etc/nixos#makerlab3040"])
        .output()
        .expect("Failed to execute command");

    // Print the output of the command
    println!("{}", String::from_utf8_lossy(&output.stdout.as_slice()));
}