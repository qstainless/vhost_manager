#!/usr/bin/env zsh

# Where your sites are located
export SitesDir="${HOME}/Sites"

# If you follow the setup guide mentioned in the README, this should be where your vhosts live
export VHostsDir="/opt/homebrew/etc/httpd/vhosts"

# Define variables for better readability
export ColorWhite="\033[1;37m"   # White
export ColorLtGreen="\033[1;32m" # Light Green
export ColorReset="\033[0m"      # Reset color to default
export TextUnderline="\e[4m"     # Underline text
export TextReset="\e[0m"         # Underline text

confirmDeletion() {
  printf "Are you sure you want to delete the virtual host for %b%s%b? [y/N]: " \
    "${ColorWhite}" "$1.test" "${ColorReset}"
  read -r confirm

  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    printf "%bOperation cancelled.%b\n" \
      "${ColorWhite}" "${ColorReset}"

    return 1
  fi

  return 0
}

confirmCreation() {
  printf "You are about to create a virtual host for %b%s%b. Continue? [y/N]: " \
    "${ColorWhite}" "$1" "${ColorReset}"

  read -r confirm

  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    printf "%bOperation cancelled.%b\n" \
      "${ColorWhite}" "${ColorReset}"

    return 1
  fi

  return 0
}

setSiteUrl() {
  local inputSiteName="$1"
  # Default extension
  SiteExtension="test"

  # Check if the site name contains a period indicating an extension
  if [[ "$inputSiteName" == *.* ]]; then
    SiteUrl="$inputSiteName"
    SiteExtension="${inputSiteName##*.}"
  else
    SiteUrl="${inputSiteName}.${SiteExtension}"
  fi
}

restartServices() {
  printf "\nRestarting services\n"
  printf "==> %bRestarting %bPHP%b...\n" \
    "${ColorWhite}" "${ColorLtGreen}" "${ColorReset}"

  brew services restart php
  printf "\n==> %bRestarting%b Apache%b...\n" \
    "${ColorWhite}" "${ColorLtGreen}" "${ColorReset}"

  brew services restart httpd
  printf "\n==> %bbrew services%b\n" \
    "${ColorLtGreen}" "${ColorReset}"

  brew services
  printf "\n"

  apachectl -t -D DUMP_VHOSTS
}

checkExtension() {
  local baseName="$1"
  local siteUrl="" # Initialize siteUrl as empty

  # Debugging aid
  printf "Checking extension for: %s" "$baseName" >&2

  if [[ "$baseName" == *.* ]]; then
    siteUrl="$baseName"
  else
    local found=false

    # Safeguard against glob expansion issues when no files match
    setopt localoptions null_glob

    for siteDir in "${SitesDir}/${baseName}".*; do
      if [[ -d "$siteDir" ]]; then
        siteUrl=$(basename "$siteDir") # Found the directory, update siteUrl
        found=true
        # Debugging aid
        printf "Found directory: %s" "$siteDir" >&2
        break # Assuming you only need the first match
      fi
    done

    # No need to explicitly unset null_glob due to localoptions
    if ! $found; then
      printf "No matching directory found for %s with any extension." "$baseName"
    fi
  fi

  # Only echo the siteUrl if found, to avoid influencing the script's flow with unintended output
  if [[ -n "$siteUrl" ]]; then
    echo "$siteUrl"
  fi
}

deleteVirtualHost() {
  local baseName="$1"

  # Echo for debugging; remove or comment out after confirming it works
  printf "Deleting virtual host for: %s" \
    "$baseName"

  # Attempt to determine the full site URL
  local siteUrl
  siteUrl=$(checkExtension "$baseName")

  # If siteUrl is empty, report no virtual host found
  if [[ -z "$siteUrl" ]]; then
    printf "No virtual host found for %b%s%b.\n" \
      "${ColorWhite}" "$baseName" "${ColorReset}"
    return
  fi

  local DocRoot="${SitesDir}/${siteUrl}"

  # Confirm deletion with the user
  printf "\nYou are about to delete the virtual host for %b%s%b. Continue? [y/N]: " \
    "${ColorWhite}" "${siteUrl}" "${ColorReset}"

  read -r confirm

  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    printf "%bOperation cancelled.%b\n" "${ColorWhite}" "${ColorReset}"
    return
  fi

  # Perform deletion
  printf "\nDeleting virtual host configuration file for %b%s%b.\n" \
    "${ColorWhite}" "${siteUrl}" "${ColorReset}"

  rm -Rf "${VHostsDir}/${siteUrl}.conf"

  printf "\nMoving %b%s%b to the trash.\n" \
    "${ColorWhite}" "${DocRoot}" "${ColorReset}"

  command mv "${DocRoot}" ~/.Trash

  # Restart services
  restartServices
  printf "\nVirtual host %b%s%b deleted successfully.\n" \
    "${ColorWhite}" "${siteUrl}" "${ColorReset}"
}

checkDir() {
  if [[ ! -d "$1" ]]; then
    printf "\nDirectory %b%s%b created.\n" \
      "${ColorWhite}" "$1" "${ColorReset}"

    mkdir -p "$1"
  fi
}

checkVhost() {
  if [[ -f "$1" ]]; then
    printf "Virtual host for %b%s%b already exists.\n" \
      "${ColorWhite}" "$SiteUrl" "${ColorReset}"

    return 1
  fi
}

createVirtualHost() {
  # Extract site name and check for an extension
  setSiteUrl "$1"

  confirmCreation "$SiteUrl" || return

  local DocRoot="${SitesDir}/${SiteUrl}/public"
  local LogsDir="${SitesDir}/_ApacheLogs"
  local TemplateDir="${SitesDir}/__templates"

  # Ensure that the Apache logs directory exists
  checkDir "${LogsDir}"

  # Check if the virtual host already exists
  checkVhost "${DocRoot}"

  printf "\nAdding vhost %b%s%b...\n" \
    "${ColorWhite}" "${SiteUrl}" "${ColorReset}"

  # Create the document root directory
  checkDir "${DocRoot}"
  chown -R "${USER}:staff" "${SitesDir}/${SiteUrl}/"

  # Create index.php from template
  sed "s|@SiteUrl@|$SiteUrl|g" "${TemplateDir}/index.tpl" >"${DocRoot}/index.php"

  # Create .htaccess and info.php
  cp "${TemplateDir}/htaccess" "${DocRoot}/.htaccess"
  cp "${TemplateDir}/info.php" "${DocRoot}"

  # Create the vhost configuration file
  local vhost_config="${TemplateDir}/httpd_vhost_config.tpl"
  sed -e "s|@SiteUrl@|$SiteUrl|g" -e "s|@Site_DocRoot@|$DocRoot|g" "$vhost_config" >"${VHostsDir}/$1.conf"

  # Display results
  printf "\nVirtual Hosts updated in Apache config.\n"

  printf "\nLogs are located at:"
  printf "\n    %b%s/%s-access.log%b" \
    "${ColorWhite}" "${LogsDir}" "${SiteUrl}" "${ColorReset}"
  printf "\n    %b%s/%s-error.log%b\n" \
    "${ColorWhite}" "${LogsDir}" "${SiteUrl}" "${ColorReset}"

  # Restart PHP and Apache services
  restartServices

  printf "\nVirtual Host created! Your new site is ready at %b%b%s%b%b\n\n" \
    "${ColorWhite}" "${TextUnderline}" "http://${SiteUrl}" "${TextReset}" "${ColorReset}"
}

# Main logic to parse arguments and call the appropriate function
if [[ $# -ne 2 ]]; then
  printf "Usage: %s -n site_name (to create new) | -d site_name (to delete)\n" "$0"
  exit 1
fi

# Parse arguments
while getopts ":n:d:" opt; do
  case $opt in
  n)
    createVirtualHost "$OPTARG"
    ;;
  d)
    deleteVirtualHost "$OPTARG"
    ;;
  \?)
    printf "Invalid option: -%s\n" "$OPTARG"
    exit 1
    ;;
  :)
    printf "Option -%s requires an argument.\n" "$OPTARG"
    exit 1
    ;;
  esac
done
