# VSFTPD Configurator

This repository contains a shell script for configuring VSFTPD on Rocky Linux 8.7 and 9.1 with VSFTPD 3.0.5.

## Overview

The `vsftpd-configurator.sh` script provides an easy-to-use command-line interface to simplify the configuration of your VSFTPD server. With multiple settings options, this script allows you to quickly modify the configuration of your server to your desired preferences.

## Features

The script offers the following configuration options:

1. Reset to default settings
2. Allow root account access
3. Allow anonymous account access
4. Deny local account access (use anonymous users only)
5. Enable anonymous account uploads
6. Enable anonymous account directory creation
7. Display the local user access directory as the root (/) directory through chroot configuration

## Prerequisites

- Rocky Linux 8.7 or 9.1
- VSFTPD 3.0.5 installed and configured

## Installation

1. Clone this repository to your local machine
2. Navigate to the directory containing the script
3. Grant execute permissions to the script by running `chmod +x vsftpd-configurator.sh`

## Usage

1. Run the script with `./vsftpd-configurator.sh`
2. The available configuration options will be displayed in a numbered list
3. Enter the number corresponding to the desired option and press Enter
4. Follow the on-screen prompts for your selected configuration
5. Once configured, restart the VSFTPD service using `systemctl restart vsftpd` for the changes to take effect

## Contributing

If you'd like to contribute to this project, please feel free to fork the repository, make your changes, and submit pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Disclaimer

Please use this script at your own risk. While it has been tested on Rocky Linux 8.7 and 9.1 with VSFTPD 3.0.5, always ensure you have a backup of your configuration files before making any changes.
