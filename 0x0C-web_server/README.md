# Web Server
## Description
Interacting with local and remote server using bash scripting scp
## Files
### 0-transfer_file
Bash script that transfers a file from our client to a server
#### Description
- Usage: `./0-transfer_file PATH_TO_FILE IP USERNAME PATH_TO_SSH_KEY`
- `PATH_TO_FILE`: Path to the file to transfer
- `IP`: IP of the server
- `USERNAME`: Username for the server
- `PATH_TO_SSH_KEY`: Path to the SSH private key
- The file `PATH_TO_FILE` will be sent to the user `USERNAME` on the server `IP`. The `PATH_TO_FILE` will be in the `/tmp/` directory on the server
### 1-install_nginx_web_server
