#!/bin/sh

#
# Generated onMon Jan 08 23:41:20 PST 2018# Start of user configurable variables
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
OUTPUT_FILE=$4
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
$WGET --user-agent="Mozilla/5.0" --secure-protocol=auto --post-data $AUTH_DATA --save-cookies=$COOKIE_FILE --keep-session-cookies $SSO_SERVER$SSO_AUTH_URL -O sso.out >> $LOGFILE 2>&1

$SSO_SERVER$SSO_AUTH_URL
#rm -f sso.out


$WGET --user-agent="Mozilla/5.0"  --no-check-certificate  --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V886426-01.zip&token=NzNRUExRQmkreFdrRFBnc2xmdnZ4USE6OiFmaWxlSWQ9OTYxMDkwMzAmZmlsZVNldENpZD04MzYyMjYmcmVsZWFzZUNpZHM9NjkzNzU0JnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjEmYWdyZWVtZW50SWQ9NDA0MzM3MSZlbWFpbEFkZHJlc3M9YmFzdGlhbi5idWthdHpAaXB0LmNoJnVzZXJOYW1lPUVQRC1CQVNUSUFOLkJVS0FUWkBJUFQuQ0gmaXBBZGRyZXNzPTE3OC4xOTcuMjI0LjE2NCZ1c2VyQWdlbnQ9TW96aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTNfMSkgQXBwbGVXZWJLaXQvNjA0LjMuNSAoS0hUTUwsIGxpa2UgR2Vja28pIFZlcnNpb24vMTEuMC4xIFNhZmFyaS82MDQuMy41JmNvdW50cnlDb2RlPUNI" -O $OUTPUT_DIR/${OUTPUT_FILE}.zip>> $LOGFILE 2>&1
