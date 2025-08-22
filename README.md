# XGen

XGen is a Bash automation tool designed for penetration testers and cybersecurity professionals. It helps in quickly generating commands to download files from a simple HTTP or SMB server, and can also start these servers. It supports various download tools like `wget`, `curl`, `iwr` (PowerShell), and `certutil`.

## Features
- Generates file download commands for `wget`, `curl`, `iwr`, and `certutil`.
- Supports HTTP and SMB server types for file hosting.
- Automatically retrieves the IP address of a specified network interface.
- Copies the generated command to the clipboard for easy use.
- Can start a simple Python HTTP server or an Impacket SMB server.

## Usage
```bash
./XGen.sh [-w] [-t <tool>] [-s <server>] <interface> <filename>
```

### Options:
- `-w`: Add `-O <filename>` (wget style) or `-o <filename>` (curl style) to save the file with the specified name.
- `-t <tool>`: Specify the download tool: `wget`, `curl`, `iwr`, or `certutil` (default: `wget`).
- `-s <server>`: Specify the server type: `http` or `smb` (default: `http`).

### Examples:
- Download `payload.exe` via HTTP using `wget` on `eth0`:
  ```bash
  ./XGen.sh eth0 payload.exe
  ```
- Download `shell.ps1` via SMB using `curl` on `tun0`, saving the file:
  ```bash
  ./XGen.sh -w -t curl -s smb tun0 shell.ps1
  ```
- Download `script.sh` via HTTP using `iwr` on `wlan0`:
  ```bash
  ./XGen.sh -t iwr wlan0 script.sh
  ```

## Customization
Edit `XGen.sh` to add or modify tasks. The script is modular and can be extended easily.

## License
MIT License
