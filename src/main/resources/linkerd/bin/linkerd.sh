\ufeff#!/bin/bash
path="${BASH_SOURCE-$0}"
path="$(dirname "${path}")"
path="$(cd "${path}";pwd)"
base=${path}/..
base_path="$(cd "${base}";pwd)"

app_name=linkerd
conf=${base_path}/config/linkerd.yaml

sys_bit="`getconf LONG_BIT`"
cd ${base_path}
echo root dir: ${base_path},sys_bit:${sys_bit}

for file in "${base_path}"/*
do
    file=${file##*/}
    filename=${file%.*}
    if [[ $filename =~ $app_name ]]; then
    	service_name=$file
    	echo ----file=${file},filename=${filename}-------
    	if [[ $filename =~ $sys_bit ]]; then
    		break;
    	fi
    fi
done

log=${base_path}/logs/${app_name}.log
pid=${base_path}/data/${app_name}.pid

if [ -n "${app_name}" ] ; then
	kid = `ps -ef |grep ${app_name}|grep -v grep|awk '{print $2}'`
	echo --pid[$kid] from `uname` system process!
fi

if [ -z "${kid}" ] ; then
	kid = `ps -ef |grep ${service_name}|grep -v grep|awk '{print $2}'`
	echo ++pid[$kid] from `uname` system process!
fi

if [ -z "$kid" -a -e "$pid" ] ; then
	chmod +x $pid
	kid=`cat $pid`
	echo pid[$kid] from pid file!
fi

if [ -n "${kid}" ] ; then
	echo ==[`uname`] ${app_name} process [$kid] is Running!
	echo ${service_name} Stopping ...
	kill -9 ${kid}
fi

if [ -f $log -o -f $pid ] ; then
	rm -rf ${base_path}/logs/*
	rm -rf $pid
fi

if [ ! -d ${base_path}/logs ] ; then
	mkdir -p ${base_path}/logs
fi

if [ ! -d ${base_path}/data ] ; then
	mkdir -p ${base_path}/data
fi

if [ -e $conf -a -d ${base_path}/logs ]
then
	echo -------------------------------------------------------------------------------------------
	cd ${base_path}
	
	echo ${service_name} Starting ...
	echo ----service_name:$service_name,conf:$conf------
	./$service_name $conf >$log 2>&1 &
	echo $! > $pid
	
	kid=`ps -ef |grep ${app_name}|grep -v grep|awk '{print $2}'`
	if [ -n "${kid}" ] ; then
		echo ----------------------------${app_name} STARTED SUCCESS------------------------------------
	else
		echo ----------------------------${app_name} STARTED ERROR------------------------------------
	fi
	echo -------------------------------------------------------------------------------------------
else
	echo "${app_name} config($conf) Or logs direction is not exist,please create first!"
	rm -rf $pid
fi