#!/bin/bash

SED_BIN="/usr/bin/sed"
GETENT_BIN="/usr/bin/getent"
CUT_BIN="/usr/bin/cut"
CHAGE_BIN="/usr/bin/chage"

cUID_MIN=$(${SED_BIN} -ne "s/^UID_MIN[ 	]*\([0-9]*\)/\1/p" /etc/login.defs)

cUID_MAX=$(${SED_BIN} -ne "s/^UID_MAX[ 	]*\([0-9]*\)/\1/p" /etc/login.defs)

eval ${GETENT_BIN} passwd {${cUID_MIN}..${cUID_MAX}} | while read line
do
	vUsername=$(echo $line | ${CUT_BIN} -d: -f1)
	vIsActive=$(echo $line | ${CUT_BIN} -d: -f2) 
	vUID=$(echo $line | ${CUT_BIN} -d: -f3)
	vGID=$(echo $line | ${CUT_BIN} -d: -f4)
	vDescription=$(echo $line | ${CUT_BIN} -d: -f5)
	vHome=$(echo $line | ${CUT_BIN} -d: -f6)
	vShell=$(echo $line | ${CUT_BIN} -d: -f7)

	# Only deal with active no system users
	if [ $vUID -le $cUID_MAX -a $vUID -ge $cUID_MIN ]
	then
		vAccountExpires=''
		vAccountExpires=$(LANG=C LC_ALL=C ${CHAGE_BIN} -l ${vUsername} | ${SED_BIN} -ne "s/^Password expires[^:]*:[ ]*\(.*\)$/\1/p")
		if [ "x$vAccountExpires" != "xnever" ]
		then
			echo $vAccountExpires > ${vHome}/.expires
		fi
	fi
done

