use std::process::Command;

pub fn run(package: &String) {
    // Run the command to install the package
    let output = Command::new("nix-env")
        .args(&["-iA", package.as_str()])
        .output()
        .expect("Failed to execute command");

    // Print the output of the command
    println!("{}", String::from_utf8_lossy(&output.stdout.as_slice()));
}