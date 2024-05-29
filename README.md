# BetterUsbCopy

## Why

Because [USB-Copy](https://www.synology.com/en-global/dsm/packages/USBCopy) sucks!
The problem with USBCopy is that when you set up a copy job in the USBCopy
application on your Synology, it works only for the specific device it
was set up for. That means if you insert another SD card into the USB port,
nothing happens, and you might wonder why.
After some [googling](https://community.synology.com/enu/forum/1/post/146608),
it turns out that one USBCopy job only works with one
device (hard drive, SD card, XQD card).

To be honest, I guess USBCopy has another purpose.
My use case is that I have 50+ SD and XQD cards, and I want to back them up
immediately after a job to have another backup so that I can use the card
directly again. I have one copy of the job on my MacBook in a
Capture One session, which is then backed up by another backup solution, and I
have an additional copy of the data on the NAS.

## How to install BetterUsbCopy

### Prerequisites

- [SSH is enabled](https://kb.synology.com/en-us/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)
- [SSH user setup to use key](https://kb.synology.com/en-us/DSM/tutorial/How_to_log_in_to_DSM_with_key_pairs_as_admin_or_root_permission_via_SSH_on_computers)
- [SSH user can use sudo without password](https://community.synology.com/enu/forum/1/post/142131)

### Installer

Copy the `env_default` file to `.env` and adjust the variables to your needs.

| Variable      | Description                                            |
| ------------- | --------------                                         |
| REMOTE_USER   | User on the NAS to login via SSH                       |
| REMOTE_HOST   | IP or Hostname of the NAS                              |
| SRC           | Path to the USB mount point without trailing slash     |
| DEST          | Destination directory on the NAS                       |
| TIMEOUT       | Timeout for waiting for the source directory to be mounted |
| EMAIL         | Email address for error notifications                  |

After that, you can run `make deploy`. This will copy all files to the right locations.

## How to use

When you have used the makefile to copy the files and configuration to your
Synology, you can connect any storage device (hard drive, SD card, XQD card) via
USB and the content of this device will be copied via [rsync](https://linux.die.net/man/1/rsync)
to the configured `DEST` in the config. The script will create one folder (datetime)
for each copy job. Also, in the folder is a logfile called `betterusbcopy.log`.

When you connect an SD card, for example, the NAS will beep two times at the
start and two times at the end of the job. While the copy job is in progress,
the status LED of the Synology will blink to indicate that it is still running.

If you hear 3 long beeps, something is wrong, and you need to check the logfile.

## Testing

Because udev events are involved, a real end-to-end test is not realistic.
However, you need to trust me that I have this running
on a `Synology DS916+` with `DSM 7.2.1-69057 Update 5`.

## License

This project is licensed under the GPL-3.0 License.
See the [LICENSE](LICENSE) file for details.

## Contribution

Contributions are welcome!
Please fork this repository, make your changes, and submit a pull request.
For major changes, please open an issue first to discuss what you would like to change.
