# BetterUsbCopy

## Why

Because [USB-Copy](https://www.synology.com/en-global/dsm/packages/USBCopy) sucks!

## How

## Deploy

- `make deploy`

### Pre requirements

- SSH auth is enabled
- SSH user has sudo permissons without password

Copy the env_default file to .env and adjust the variables to your needs.

| Variable      | Description                                            |
| ------------- | --------------                                         |
| REMOTE_USER   | User on the NAS to login via SSH                       |
| REMOTE_HOST   | IP or Hostname of the NAS                              |
| SRC           | Path to the usb mountpoint without trailing slash      |
| DEST          | Destination directory on the NAS                       |
| TIMEOUT       | Timeout for waiting the source directory to be mounted |
| EMAIL         | Email address for error notifications                  |
