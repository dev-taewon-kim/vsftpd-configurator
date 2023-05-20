#!/bin/bash

VSFTPD_DIR="/etc/vsftpd"
VSFTPD_CONF="${VSFTPD_DIR}/vsftpd.conf"
VSFTPD_USER_LIST="${VSFTPD_DIR}/user_list"
VSFTPD_FTPUSERS="${VSFTPD_DIR}/ftpusers"

if [ "$(id -u)" != "0" ]; then
  echo "Unauthorized user. Please run with root privileges."
  exit 1
fi

function check_vsftpd_installed() {
  if ! rpm -q vsftpd >/dev/null; then
    echo "vsftpd is not installed. Please install it (dnf install vsftpd)."
    exit 1
  fi
}

function stop_firewalld_setenforce() {
  systemctl stop firewalld.service
  setenforce 0
}

check_vsftpd_installed
stop_firewalld_setenforce

function restart_vsftpd() {
  systemctl restart vsftpd 2>/dev/null
  systemctl status vsftpd --no-pager | grep "Active: active (running)" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "[+] OK!"
  else
    echo "[!] Restart failed. Reset to default settings is recommended."
  fi
}

function reset_config() {
  cat >$VSFTPD_CONF <<EOL
# Example config file /etc/vsftpd/vsftpd.conf
#
# The default compiled in settings are fairly paranoid. This sample file
# loosens things up a bit, to make the ftp daemon more usable.
# Please see vsftpd.conf.5 for all compiled in defaults.
#
# READ THIS: This example file is NOT an exhaustive list of vsftpd options.
# Please read the vsftpd.conf.5 manual page to get a full idea of vsftpd's
# capabilities.
#
# Allow anonymous FTP? (Beware - allowed by default if you comment this out).
anonymous_enable=NO
#
# Uncomment this to allow local users to log in.
local_enable=YES
#
# Uncomment this to enable any form of FTP write command.
write_enable=YES
#
# Default umask for local users is 077. You may wish to change this to 022,
# if your users expect that (022 is used by most other ftpd's)
local_umask=022
#
# Uncomment this to allow the anonymous FTP user to upload files. This only
# has an effect if the above global write enable is activated. Also, you will
# obviously need to create a directory writable by the FTP user.
# When SELinux is enforcing check for SE bool allow_ftpd_anon_write, allow_ftpd_full_access
#anon_upload_enable=YES
#
# Uncomment this if you want the anonymous FTP user to be able to create
# new directories.
#anon_mkdir_write_enable=YES
#
# Activate directory messages - messages given to remote users when they
# go into a certain directory.
dirmessage_enable=YES
#
# Activate logging of uploads/downloads.
xferlog_enable=YES
#
# Make sure PORT transfer connections originate from port 20 (ftp-data).
connect_from_port_20=YES
#
# If you want, you can arrange for uploaded anonymous files to be owned by
# a different user. Note! Using "root" for uploaded files is not
# recommended!
#chown_uploads=YES
#chown_username=whoever
#
# You may override where the log file goes if you like. The default is shown
# below.
#xferlog_file=/var/log/xferlog
#
# If you want, you can have your log file in standard ftpd xferlog format.
# Note that the default log file location is /var/log/xferlog in this case.
xferlog_std_format=YES
#
# You may change the default value for timing out an idle session.
#idle_session_timeout=600
#
# You may change the default value for timing out a data connection.
#data_connection_timeout=120
#
# It is recommended that you define on your system a unique user which the
# ftp server can use as a totally isolated and unprivileged user.
#nopriv_user=ftpsecure
#
# Enable this and the server will recognise asynchronous ABOR requests. Not
# recommended for security (the code is non-trivial). Not enabling it,
# however, may confuse older FTP clients.
#async_abor_enable=YES
#
# By default the server will pretend to allow ASCII mode but in fact ignore
# the request. Turn on the below options to have the server actually do ASCII
# mangling on files when in ASCII mode. The vsftpd.conf(5) man page explains
# the behaviour when these options are disabled.
# Beware that on some FTP servers, ASCII support allows a denial of service
# attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
# predicted this attack and has always been safe, reporting the size of the
# raw file.
# ASCII mangling is a horrible feature of the protocol.
#ascii_upload_enable=YES
#ascii_download_enable=YES
#
# You may fully customise the login banner string:
#ftpd_banner=Welcome to blah FTP service.
#
# You may specify a file of disallowed anonymous e-mail addresses. Apparently
# useful for combatting certain DoS attacks.
#deny_email_enable=YES
# (default follows)
#banned_email_file=/etc/vsftpd/banned_emails
#
# You may specify an explicit list of local users to chroot() to their home
# directory. If chroot_local_user is YES, then this list becomes a list of
# users to NOT chroot().
# (Warning! chroot'ing can be very dangerous. If using chroot, make sure that
# the user does not have write access to the top level directory within the
# chroot)
#chroot_local_user=YES
#chroot_list_enable=YES
# (default follows)
#chroot_list_file=/etc/vsftpd/chroot_list
#
# You may activate the "-R" option to the builtin ls. This is disabled by
# default to avoid remote users being able to cause excessive I/O on large
# sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
# the presence of the "-R" option, so there is a strong case for enabling it.
#ls_recurse_enable=YES
#
# When "listen" directive is enabled, vsftpd runs in standalone mode and
# listens on IPv4 sockets. This directive cannot be used in conjunction
# with the listen_ipv6 directive.
listen=NO
#
# This directive enables listening on IPv6 sockets. By default, listening
# on the IPv6 "any" address (::) will accept connections from both IPv6
# and IPv4 clients. It is not necessary to listen on *both* IPv4 and IPv6
# sockets. If you want that (perhaps because you want to listen on specific
# addresses) then you must run two copies of vsftpd with two configuration
# files.
# Make sure, that one of the listen options is commented !!
listen_ipv6=YES

pam_service_name=vsftpd
userlist_enable=YES
EOL

  cat >$VSFTPD_USER_LIST <<EOL
# vsftpd userlist
# If userlist_deny=NO, only allow users in this file
# If userlist_deny=YES (default), never allow users in this file, and
# do not even prompt for a password.
# Note that the default vsftpd pam config also checks /etc/vsftpd/ftpusers
# for users that are denied.
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
EOL

  cat >$VSFTPD_FTPUSERS <<EOL
# Users that are not allowed to login via ftp
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
EOL
  restart_vsftpd
}

function allow_root_login() {
  sed -i 's/#\?root/#root/g' $VSFTPD_USER_LIST
  sed -i 's/#\?root/#root/g' $VSFTPD_FTPUSERS
  restart_vsftpd
}

function allow_anonymous() {
  sed -i 's/^#\{0,1\}anonymous_enable=.*$/anonymous_enable=YES/' $VSFTPD_CONF
  restart_vsftpd
}

function deny_local_access() {
  sed -i 's/^#\{0,1\}local_enable=.*$/local_enable=NO/' $VSFTPD_CONF
  restart_vsftpd
}

function enable_anonymous_upload() {
  sed -i 's/^#\{0,1\}anon_upload_enable=.*$/anon_upload_enable=YES/' $VSFTPD_CONF
  restart_vsftpd
}

function enable_anonymous_mkdir() {
  sed -i 's/^#\{0,1\}anon_mkdir_write_enable=.*$/anon_mkdir_write_enable=YES/' $VSFTPD_CONF
  restart_vsftpd
}

function chroot_local_user() {
  if grep -q "^#\{0,1\}allow_writeable_chroot=" "$VSFTPD_CONF"; then
    sed -i 's/^#\{0,1\}allow_writeable_chroot=.*$/allow_writeable_chroot=YES/' "$VSFTPD_CONF"
  else
    sed -i '/^[#]*\s*chroot_local_user=/i allow_writeable_chroot=YES' "$VSFTPD_CONF"
  fi
  sed -i 's/^#\{0,1\}chroot_local_user=.*$/chroot_local_user=YES/' $VSFTPD_CONF
  restart_vsftpd
}

echo ""
echo "<VSFTPD Configurator by. Taewon Kim>"
echo "0. Reset to default settings"
echo "1. Allow root account access"
echo "2. Allow anonymous account access"
echo "3. Deny local account access (use anonymous users only)"
echo "4. Enable anonymous account uploads"
echo "5. Enable anonymous account directory creation"
echo "6. Display the local user access directory as the root (/) directory through chroot configuration"
echo ""
read -p "Enter number: " CHOICE

case $CHOICE in
  0)
    reset_config
    ;;
  1)
    allow_root_login
    ;;
  2)
    allow_anonymous
    ;;
  3)
    deny_local_access
    ;;
  4)
    enable_anonymous_upload
    ;;
  5)
    enable_anonymous_mkdir
    ;;
  6)
    chroot_local_user
    ;;
  *)
    echo "[!] Wrong number!"
    ;;
esac
