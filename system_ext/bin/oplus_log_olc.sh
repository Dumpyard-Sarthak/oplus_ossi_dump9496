#! /system/bin/sh

OLC_COMMON_LOG_DEFAULT_PATH=/data/persist_log/olc/TMP/common_logs
OLC_COMMON_LOG_PATH=`getprop sys.olc.common.log.path ${OLC_COMMON_LOG_DEFAULT_PATH}`

CURTIME_FORMAT=`date "+%Y-%m-%d %H:%M:%S:%N"`
config="$1"

function traceLoggingState() {
    if [ ! -d ${OLC_COMMON_LOG_PATH} ]; then
        mkdir -p ${OLC_COMMON_LOG_PATH}
        chown system:system ${OLC_COMMON_LOG_PATH}
        chmod 777 ${OLC_COMMON_LOG_PATH} -R
        echo "${CURTIME_FORMAT} traceLoggingState:${OLC_COMMON_LOG_PATH} " >> ${OLC_COMMON_LOG_PATH}/olc_get_log.log
    fi

    content=$1
    echo "${CURTIME_FORMAT} ${content} " >> ${OLC_COMMON_LOG_PATH}/olc_get_log.log
}

#================================== COMMON LOG =========================
function get_main_log(){
    rotateSize=`getprop sys.olc.log.rotate.kbytes 4096`;
    rotateCount=`getprop sys.olc.log.rotate.count 4`;

    traceLoggingState "logcat -d -b crash -f ${OLC_COMMON_LOG_PATH}/crash.log -r${rotateSize} -n ${rotateCount}"
    /system/bin/logcat -d -b crash -f ${OLC_COMMON_LOG_PATH}/crash.log -r${rotateSize} -n ${rotateCount}
    traceLoggingState "logcat -d -b main -f ${OLC_COMMON_LOG_PATH}/main.log -r${rotateSize} -n ${rotateCount}"
    /system/bin/logcat -d -b main -f ${OLC_COMMON_LOG_PATH}/main.log -r${rotateSize} -n ${rotateCount}

    chown -R system:system ${OLC_COMMON_LOG_PATH}
    chmod 777 -R ${OLC_COMMON_LOG_PATH}
    traceLoggingState "olc get main log done"
}

function get_radio_log(){
    rotateSize=`getprop sys.olc.log.rotate.kbytes 4096`;
    rotateCount=`getprop sys.olc.log.rotate.count 4`;

    traceLoggingState "logcat -d -b radio -f ${OLC_COMMON_LOG_PATH}/radio.log -r ${rotateSize} -n ${rotateCount}"
    /system/bin/logcat -d -b radio -f ${OLC_COMMON_LOG_PATH}/radio.log -r ${rotateSize} -n ${rotateCount}

    chown -R system:system ${OLC_COMMON_LOG_PATH}
    chmod 777 -R ${OLC_COMMON_LOG_PATH}
    traceLoggingState "olc get radio log done"
}

function get_events_log(){
    rotateSize=`getprop sys.olc.log.rotate.kbytes 4096`;
    rotateCount=`getprop sys.olc.log.rotate.count 4`;

    traceLoggingState "logcat -d -b events -f ${OLC_COMMON_LOG_PATH}/events.log -r${rotateSize} -n ${rotateCount}"
    /system/bin/logcat -d -b events -f ${OLC_COMMON_LOG_PATH}/events.log -r${rotateSize} -n ${rotateCount}

    chown -R system:system ${OLC_COMMON_LOG_PATH}
    chmod 777 -R ${OLC_COMMON_LOG_PATH}
    traceLoggingState "olc get events log done"
}

function get_system_log(){
    rotateSize=`getprop sys.olc.log.rotate.kbytes 4096`;
    rotateCount=`getprop sys.olc.log.rotate.count 4`;

    traceLoggingState "logcat -d -b system -f ${OLC_COMMON_LOG_PATH}/system.log -r${rotateSize} -n ${rotateCount}"
    /system/bin/logcat -d -b system -f ${OLC_COMMON_LOG_PATH}/system.log -r${rotateSize} -n ${rotateCount}

    chown  -R system:system ${OLC_COMMON_LOG_PATH}
    chmod 777 -R ${OLC_COMMON_LOG_PATH}
    traceLoggingState "olc get system log done"
}

function get_kernel_log(){
    traceLoggingState "dmesg -T > ${OLC_COMMON_LOG_PATH}/kernel.log"
    dmesg -T > ${OLC_COMMON_LOG_PATH}/kernel.log
    chown -R system:system ${OLC_COMMON_LOG_PATH}
    chmod 777 -R ${OLC_COMMON_LOG_PATH}
    traceLoggingState "olc get kernel log done"
}


function copy_logs() {
    traceLoggingState "copylogs start... "
    setprop sys.olc.copy.log_ready 0

    log_path=`getprop sys.olc.copy.log_path`
    if [ "$log_path" ];then
        copy_root=${log_path}
    else
        copy_root="${OLC_COMMON_LOG_PATH}/copy/"
    fi

    mkdir -p ${copy_root}
    traceLoggingState "copy root: ${copy_root}"

    log_config_file=`getprop sys.olc.copy.log_config`
    traceLoggingState "log config file: ${log_config_file} "

    if [ "$log_config_file" ];then
        paths=`cat ${log_config_file}`

        for file_path in ${paths};do
            # create parent directory of each path
            dest_path=${copy_root}${file_path%/*}
            # replace dunplicate character '//' with '/' in directory
            dest_path=${dest_path//\/\//\/}
            mkdir -p ${dest_path}
            traceLoggingState "copy ${file_path} "
            cp -rf ${file_path} ${dest_path}
        done
        chown -R system:system ${copy_root}
        chmod -R 777 ${copy_root}

        setprop sys.olc.copy.log_config ''
    fi

    setprop sys.olc.copy.log_ready 1
    setprop sys.olc.copy.log_path ''
    traceLoggingState "copylogs end "
}

function main() {
    traceLoggingState "oplus_log_olc.sh ${config}"
    case "$config" in
        "get_main_log")
            get_main_log
            ;;
        "get_radio_log")
            get_radio_log
            ;;
        "get_events_log")
            get_events_log
            ;;
        "get_system_log")
            get_system_log
            ;;
        "get_kernel_log")
            get_kernel_log
            ;;
        "copy_logs")
            copy_logs
            ;;
        *)
          ;;
    esac
}

main "$@"