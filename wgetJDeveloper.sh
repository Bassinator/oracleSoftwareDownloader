#!/bin/sh

#
# Generated onMon Feb 12 05:12:44 PST 2018# Start of user configurable variables
#
LANG=C
export LANG

# SSO username and password
#read -p 'SSO User Name:' SSO_USERNAME
#read -sp 'SSO Password:' SSO_PASSWORD
SSO_USERNAME=$1
SSO_PASSWORD=$2


# Path to wget command
WGET=/usr/bin/wget
# Location of cookie file
COOKIE_FILE=/tmp/$$.cookies

# Log directory and file
LOGDIR=.
LOGFILE=$LOGDIR/wgetlog-`date +%m-%d-%y-%H:%M`.log
# Output directory and file
OUTPUT_DIR=$3
DL_FILES=$4
#
# End of user configurable variable
#

if [ "$SSO_PASSWORD " = " " ]
then
 echo "Please edit script and set SSO_PASSWORD"
 exit
fi

SSO_RESPONSE=`$WGET --user-agent="Mozilla/5.0"  --no-check-certificate https://edelivery.oracle.com/osdc/faces/SoftwareDelivery 2>&1|grep Location`

# Extract request parameters for SSO
SSO_TOKEN=`echo $SSO_RESPONSE| cut -d '=' -f 2|cut -d ' ' -f 1`
SSO_SERVER=`echo $SSO_RESPONSE| cut -d ' ' -f 2|cut -d '/' -f 1,2,3`
SSO_AUTH_URL=/sso/auth
AUTH_DATA="ssousername=$SSO_USERNAME&password=$SSO_PASSWORD&site2pstoretoken=$SSO_TOKEN"

# The following command to authenticate uses HTTPS. This will work only if the wget in the environment
# where this script will be executed was compiled with OpenSSL. Remove the --secure-protocol option
# if wget was not compiled with OpenSSL
# Depending on the preference, the other options are --secure-protocol= auto|SSLv2|SSLv3|TLSv1
$WGET --proxy=http://proxy-surf.hel.kko.ch:8080 --user-agent="Mozilla/5.0" --secure-protocol=TLSv1_2 --post-data $AUTH_DATA --save-cookies=$COOKIE_FILE --keep-session-cookies $SSO_SERVER$SSO_AUTH_URL -O sso.out >> $LOGFILE 2>&1


for FILE_NAME in $DL_FILES
do
  $WGET --user-agent="Mozilla/5.0"  --no-check-certificate  --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies "https://edelivery.oracle.com/osdc/softwareDownload?fileName=${FILE_NAME}.zip&token=elZxckI1Z2oxcCtsMHNrN01QQjlYQSE6OiFmaWxlSWQ9OTI2Njg0NjYmZmlsZVNldENpZD04MDc1ODQmcmVsZWFzZUNpZHM9NTg5OTU5JnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjEmYWdyZWVtZW50SWQ9NDE1NTY2NyZlbWFpbEFkZHJlc3M9YmFzdGlhbi5idWthdHpAaXB0LmNoJnVzZXJOYW1lPUVQRC1CQVNUSUFOLkJVS0FUWkBJUFQuQ0gmaXBBZGRyZXNzPTE5My43My4xMDYuMTAyJnVzZXJBZ2VudD1Nb3ppbGxhLzUuMCAoV2luZG93cyBOVCA2LjM7IFdPVzY0OyBUcmlkZW50LzcuMDsgcnY6MTEuMCkgbGlrZSBHZWNrbyZjb3VudHJ5Q29kZT1DSA" -O $OUTPUT_DIR/${FILE_NAME}.zip>> $LOGFILE 2>&1
done
