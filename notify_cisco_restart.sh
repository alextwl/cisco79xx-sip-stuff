#!/bin/bash
#
# Send NOTIFY message to cisco79xx to reboot.
#
# Usage:
#   ./notify_cisco_restart.sh sip:lineX_name@ipaddress:5060
#
# Reference:
# How to Upgrade Your Cisco SIP IP Phone Firmware Image and Reboot Remotely
# http://www.cisco.com/c/en/us/td/docs/voice_ip_comm/cuipph/7960g_7940g/sip/8_0/english/administration/guide/8_0/sipmn80.html#wp1144188

function print_usage()
{
    echo "Usage:"
    echo "${0} sip:lineX_name@ipaddress:5060"
}

TO_SIPURI="${1}"
if [ "${TO_SIPURI}" == '' ]; then
    print_usage
    exit
fi

type sipsak >/dev/null 2>&1 || { echo >&2 "I require sipsak but it's not installed.  Aborting."; exit 1; }

FROM_SIPURI="sip:admin@${HOSTNAME}"
CALLID=`head -c16 /dev/urandom | md5sum | head -c16`

sipsak -v -s ${TO_SIPURI} -f -<<-EOM
NOTIFY ${TO_SIPURI} SIP/2.0
From: <${FROM_SIPURI}>
To: <${TO_SIPURI}>
Call-ID: ${CALLID}
CSeq: 10 NOTIFY
Event: check-sync
Contact: <${FROM_SIPURI}>
Content-Length: 0

EOM

