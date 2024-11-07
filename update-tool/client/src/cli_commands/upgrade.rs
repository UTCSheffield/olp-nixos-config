pub fn run(package: &String) {
    // Run the command to manually trigger a rebuild
    let output = Command::new("sudo nixos-rebuild switch --flake /etc/nixos#makerlab3040") // TODO: FUTURE: Make this read the flake from setup.toml
        .args(&["-iA", package.as_str()])
        .output()
        .expect("Failed to execute command");

    // Print the output of the command
    println!("{}", String::from_utf8_lossy(&output.stdout.as_slice()));
}