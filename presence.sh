##########################
#
# Bash Presence Detection
#
# Author: Cosimo Iaia  <cosimo.iaia@gmail.com>
# Date: 2/10/2015
#
# This file is distribuited under the terms of GNU General Public
# Copyright 2010 Cosimo Iaia
#
#
###########################

#!/bin/bash 


NAME=`basename ${0} .sh`
LOGFILE=~/${NAME}.log
TODAY=`date +%d_%m_%y`



######################### SUPPORT FUNCTIONS ####################################

LOG()
{
        echo -e "\e[33m$*\e[0m" 1>&2
        echo [LOG] [${TODAY}] $* &>>${LOGFILE}
}

ERR()
{
        echo -e "[\e[31mERROR\e[0m]" $* 1>&2
        echo [ERROR] [${TODAY}] $* >>${LOGFILE}
        echo -e "\e[31mFAILED !!!\e[0m" 1>&2
        exit -1;
}

_varme()
{
        printf -v "$1" "%s" "$(cat)"; declare -p "$1";
}


run_safe()
{
        LOG "[EXEC] $@"
        eval "$( $@ 2> >(_varme ERR_MSG) > >(_varme STD_MSG); <<<"$?" _varme RETVAL; )"
        if [ $RETVAL != 0 ];
        then
                ERR \'${*}\' '--->' $ERR_MSG
        fi
        echo $STD_MSG
}


###################### END SUPPORT FUNCTIONS ####################




IP_TO_CHECK=#INSERT_YOUR_MOBILE_PHONE_IP_HERE
stat=false

lights_on()
{
	turn_lights on
}


lights_off()
{
	turn_lights off
}

spotify_play_pause()
{
	qdbus org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
}

stop_s()
{
	if $stat ;
	then
		LOG "was present, turning off"
		echo "was present, turning off"
		spotify_play_pause
		lights_off
		xset dpms force off
		stat=false
		echo $stat
	fi
}

start_s()
{
	if ! $stat  ;
	then
		LOG "was not present, turning on"
		echo "was not present, turning on"
		xset dpms force on
		xset s reset
		lights_on
		spotify_play_pause
		stat=true
	fi
}



while true;
do 
	if `fping $IP_TO_CHECK | grep alive >/dev/null`;
	then
		start_s
	else
		stop_s
	fi
done
