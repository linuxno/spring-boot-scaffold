#!/bin/sh

PRG_NAME=@project.artifactId@
PRG_VERSION=@project.version@

LIB_DIR=../lib
LOG_DIR=../logs
RUN_DIR=../run
CONF_DIR=../conf

SPRING_CONFIGS=$CONF_DIR/application.yml,$CONF_DIR/application-prod.yml,$CONF_DIR/application-dev.yml
JAR_FILE=$LIB_DIR/$PRG_NAME-$PRG_VERSION-with-dependencies.jar
PID_FILE=$RUN_DIR/$PRG_NAME.pid

PRG_STATUS=""
PID=""
ERROR=0

opr=$1

# start function
start(){
	is_running
    RUNNING=$?
    if [ $RUNNING -eq 1 ]; then
        echo "$0 $ARG: $PRG_NAME  (pid $PRG_PID) already running"
	exit
    fi

    echo "Starting program...  "
    echo =========================================================
    echo "arg:" $opr
    echo JAVA_HOME:$JAVA_HOME
    echo =========================================================
	echo "try starting $PRG_NAME"

    if [ $opr == daemon ]; then
        nohup java $JAVA_OPTS \
        -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
		-Dspring.config.location=$SPRING_CONFIGS \
	    -jar $JAR_FILE \
	    >>$LOG_DIR/console.out 2>&1 &

		echo $! > $PID_FILE

		COUNTER=40
	    while [ $RUNNING -eq 0 ] && [ $COUNTER -ne 0 ]; do
	        COUNTER=`expr $COUNTER - 1`
	        sleep 3
	        is_running
	        RUNNING=$?
	    done
	    if [ $RUNNING -eq 0 ]; then
	        ERROR=1
	    fi
	    if [ $ERROR -eq 0 ]; then
		    echo "$0 $ARG: $PRG_NAME  started at port $PORT"
		    sleep 2
	    else
		    echo "$0 $ARG: $PRG_NAME  could not be started"
		    ERROR=3
	    fi
    else
        java $JAVA_OPTS \
        -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 \
		-Dspring.config.location=$SPRING_CONFIGS \
	    -jar $JAR_FILE \  
    fi    
}

stop(){
    NO_EXIT_ON_ERROR=$1
    is_running
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        echo "$0 $ARG: $PRG_STATUS"
        if [ "x$NO_EXIT_ON_ERROR" != "xno_exit" ]; then
            exit
        else
            return
        fi
    fi
	
	kill $PRG_PID

    COUNTER=40
    while [ $RUNNING -eq 1 ] && [ $COUNTER -ne 0 ]; do
        COUNTER=`expr $COUNTER - 1`
        sleep 3
        is_running
        RUNNING=$?
    done

    is_running
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
            echo "$0 $ARG: $PRG_NAME stopped"
            rm -f $PID_FILE
        else
            echo "$0 $ARG: $PRG_NAME could not be stopped"
            ERROR=4
    fi
}

#帮助
help(){
    echo    "--------------------------------------------------"
    echo    "Usage: run.sh  help"
    echo    "       run.sh (start|daemon|stop) "
    echo -e "       run.sh  help \n"
    echo    "help       - this screen"
    echo    "start      - Start the program in the foreground"
	echo    "daemon     - Start the program in the background"
    echo    "stop       - stop  the service"
}

#判断程序进程是否已经启动
get_pid() {
    PID=""
    PIDFILE=$1
    # check for pidfile
    if [ -f "$PIDFILE" ] ; then
        PID=`cat $PIDFILE`
    fi
}

get_PRG_PID() {
    get_pid $PID_FILE
    if [ ! "$PID" ]; then
        return
    fi
    if [ "$PID" -gt 0 ]; then
        PRG_PID=$PID
    fi
}

is_service_running() {
    PID=$1
    if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
        RUNNING=1
    else
        RUNNING=0
    fi
    return $RUNNING
}

is_running() {
    get_PRG_PID
    is_service_running $PRG_PID
    RUNNING=$?
    if [ $RUNNING -eq 0 ]; then
        PRG_STATUS="$PRG_NAME not running"
    else
        PRG_STATUS="$PRG_NAME already running"
    fi
    return $RUNNING
}

if [ ! -n "$opr" ]; then
	help
fi


case $opr in
start|-s|daemon)
	start
	;;
stop|exit|quit)
	stop
	exit 0
	;;
help)
	help
	;;
esac

exit $ERROR