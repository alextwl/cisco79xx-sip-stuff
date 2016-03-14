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
    echo "${0} input.mp3 output.pcm"
}

INPUT_FN="${1}"
OUTPUT_FN="${2}"

if [ "${INPUT_FN}" == '' -o "${OUTPUT_FN}" == '' ]; then
    print_usage
    exit
fi

type ffmpeg >/dev/null 2>&1 || { echo >&2 "I require ffmpeg but it's not installed.  Aborting."; exit 1; }

ffmpeg -i ${INPUT_FN} -vn -f mulaw -acodec pcm_mulaw \
    -map_metadata -1 -ar 8000 -ac 1 -ss 0 -to 2.010 \
    ${OUTPUT_FN}
