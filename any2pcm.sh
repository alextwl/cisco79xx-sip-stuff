#!/bin/bash
#
# Convert any audio to PCM (mulaw) format.
#
# Please note that number of samples must be not smaller than 240,
# not greater than 16080, and evenly divisible by 240 as described
# in the documentation from Cisco.
#
# This script sets the upper bound of output samples to 16080 cause
# I assume that the input length shall be longer than the limit. 
# (16080 samples == 2.010 seconds)
#
# Reference:
# CallManager Express: Add Custom Rings for Cisco 7960 and 7940 IP Phones
# http://www.cisco.com/c/en/us/support/docs/voice-unified-communications/unified-communications-manager-express/68483-cme-add-custom-rings.html#conf

function print_usage()
{
    echo "Usage:"
    echo "${0} input.mp3 output.pcm [start_time] [end_time]"
    echo "start_time and end_time may be a number in seconds, or in \"hh:mm:ss[.xxx]\" form."
}

INPUT_FN="${1}"
OUTPUT_FN="${2}"
START_TIME=""
END_TIME=""

if [ "${INPUT_FN}" == '' -o "${OUTPUT_FN}" == '' ]; then
    print_usage
    exit
fi

[ "${3}" != '' ] && START_TIME="-ss ${3}"
[ "${4}" != '' ] && END_TIME="-to ${4}"

type ffmpeg >/dev/null 2>&1 || { echo >&2 "I require ffmpeg but it's not installed.  Aborting."; exit 1; }

ffmpeg -i ${INPUT_FN} -vn -f mulaw -acodec pcm_mulaw \
    -map_metadata -1 -ar 8000 -ac 1 -fs 16080 \
    ${START_TIME} ${END_TIME} ${OUTPUT_FN}

OUTPUT_SIZE=`ls -ln ${OUTPUT_FN} | awk '{print $5}'`

if (( ${OUTPUT_SIZE} % 240 != 0 ))
then
    # output is not evenly divisible by 240.
    BS_COUNT=$(( ${OUTPUT_SIZE} / 240 ))
    dd if=${OUTPUT_FN} of=${OUTPUT_FN}.new bs=240 count=${BS_COUNT}
    echo -e "Caution! The size of ${OUTPUT_FN} is not evenly divisible by 240." \
        "A truncated version is created as ${OUTPUT_FN}.new" \
        "in order to meet the requirement of ringtones for cisco79xx."
fi
