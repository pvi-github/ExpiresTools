#!/bin/bash

[ ! -f $HOME/.expires ] && exit

DATE_BIN="/usr/bin/date"
CAT_BIN="/usr/bin/cat"
KDIALOG_BIN="/usr/bin/kdialog"
NOTIFY_SEND_BIN="/usr/bin/notify-send"
PS_BIN="/usr/bin/ps"
GREP_BIN="/usr/bin/grep"
PGREP_BIN="/usr/bin/pgrep"
SED_BIN="/usr/bin/sed"

vExpires=$(LANG=C LC_ALL=C ${DATE_BIN} --date="$(${CAT_BIN} $HOME/.expires)" +%s)
vNow=$(LANG=C LC_ALL=C ${DATE_BIN} +%s)

ksession_pid=$(${PGREP_BIN} "kwin_x11")
export ksession_pid

[ ! -f /proc/${ksession_pid}/environ ] && exit

${GREP_BIN} -z DBUS_SESSION_BUS_ADDRESS /proc/${ksession_pid}/environ

DBUS_SESSION_BUS_ADDRESS=$(${GREP_BIN} -z DBUS_SESSION_BUS_ADDRESS /proc/${ksession_pid}/environ | ${SED_BIN} -e 's/DBUS_SESSION_BUS_ADDRESS=//')
export DBUS_SESSION_BUS_ADDRESS

if [ $vExpires -lt $vNow ]
then
	echo "Your account is expired"
	vMessage=" 
	Your account is expired. 
	You should not have beenable to connect"
	${NOTIFY_SEND_BIN} "SECURITY ALERT" "${vMessage}" 
elif [ $vExpires -lt $(($vNow + 30*24*60*60)) ]
then
	echo "Your account will expire in $(( ($vExpires - $vNow)/24/60/60 )) days"
	vMessage=" 
	Your account will expire in $(( ($vExpires - $vNow)/24/60/60 )) days
	Please update your password as soon as possible !"
	${NOTIFY_SEND_BIN} "SECURITY WARNING" "${vMessage}" 
fi

