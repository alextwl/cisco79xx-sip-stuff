#!/bin/bash
#
# Increment IMAGE SYNC number by one.
#
# Usage:
#   ./incr_syncinfo.sh syncinfo.xml

# TODO: Rewrite for an XML-parsing version.

function print_usage()
{
    echo "Usage:"
    echo "${0} syncinfo.xml"
}

SYNCINFO_XML_PATH="${1}"
if [ "${SYNCINFO_XML_PATH}" == '' ]; then
    print_usage
    exit
elif [ ! -f ${SYNCINFO_XML_PATH} ]; then
    echo "Error: ${SYNCINFO_XML_PATH} not found."
    exit 1
fi


OLDSN=`grep IMAGE ${SYNCINFO_XML_PATH} | sed 's/^.*SYNC="\(.*\)".*$/\1/'`
NEWSN=`expr $OLDSN + 1`

echo "New SYNC number: ${NEWSN}."
echo -e "<SYNCINFO>\n   <IMAGE VERSION=\"*\" SYNC=\"${NEWSN}\"/>\n</SYNCINFO>" > ${SYNCINFO_XML_PATH}
