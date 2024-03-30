# vhost_manager.zsh

**Author:** Queue Stainless  
**Date:** Mar 28, 2024  
**Version:** 1.2

## Description
This script automates the process of creating and deleting virtual hosts for local web development on macOS (Apple Silicon). It is designed to work within a macOS environment, using Homebrew services for managing Apache and PHP services. The script assumes a specific development environment setup as described in [this guide](https://getgrav.org/blog/macos-sonoma-apache-multiple-php-versions).

## Features
- **Create a new virtual host** by setting up the necessary Apache configuration, creating document root directories, and creating sample files (.htaccess, index.php, and info.php). Permissions are set accordingly, and Apache and PHP services are restarted to apply changes.
- **Delete an existing virtual host** by removing its Apache configuration and moving its document root directory to the system's Trash. Services are restarted afterward to reflect the changes.
- The script **performs safety checks** before operations, such as confirming the deletion of virtual hosts and checking for the existence of hosts before creating new ones.

## Usage
    ./vhost_manager.zsh -n [site_name] # Create a new virtual host named [site_name].
    ./vhost_manager.zsh -d [site_name] # Delete an existing virtual host named [site_name].

### Options
- `-n`: Specify the site name to create a new virtual host.
- `-d`: Specify the site name to delete an existing virtual host.

## Prerequisites
- Zsh shell.
- A development environment set up following [this guide](https://getgrav.org/blog/macos-sonoma-apache-multiple-php-versions).

## Notes
- Before running the script, ensure that the environmental variables (`SitesDir`, `VHostsDir`, etc.) at the beginning of the script are configured to match your system's directory structure and preferences.
- Execute permissions must be set for this script (`chmod +x vhost_manager.zsh`).
- Run the script with appropriate permissions, especially if modifying system-wide configuration files or restarting system services.
- Virtual host configuration (`.conf`), `.htaccess`, `index.php`, and `info.php` files are generated from the samples included in the `_template` directory for use in creating new virtual hosts.

## Disclaimer
This script is provided "as is", without warranty of any kind. Use it at your own risk. The author assumes no responsibility for any consequences that may arise from its use.
