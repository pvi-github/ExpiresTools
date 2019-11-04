#!/bin/bash

[ ! -f $HOME/.expires ] && exit

DATE_BIN="/usr/bin/date"
CAT_BIN="/usr/bin/cat"
KDIALOG_BIN="/usr/bin/kdialog"
NOTIFY_SEND_BIN="/usr/bin/notify-send"

vExpires=$(LANG=C LC_ALL=C ${DATE_BIN} --date="$(${CAT_BIN} $HOME/.expires)" +%s)
vNow=$(LANG=C LC_ALL=C ${DATE_BIN} +%s)

if [ $vExpires -lt $vNow ]
then
	echo "Your account is expired"
	vMessage="SECURITY ALERT

	Your account is expired. 
	You should not have beenable to connect"
	${NOTIFY_SEND_BIN} "${vMessage}" 
elif [ $vExpires -lt $(($vNow + 30*24*60*60)) ]
then
	echo "Your account will expire in $(( ($vExpires - $vNow)/24/60/60 )) days"
	vMessage="SECURITY WARNING

	Your account will expire in $(( ($vExpires - $vNow)/24/60/60 )) days
	Please update your password as soon as possible !"
	${NOTIFY_SEND_BIN} "${vMessage}" 
fi

