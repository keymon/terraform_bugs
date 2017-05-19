#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
"container_env": {
	"TIMESTAMP": "${v}",
EOF
cat <<EOF
    "CONFLUENCE_HOSTNAME": "aslive-intranet.mergermarket.com",
    "CATALINA_OPTS": "-Xms3G -Xmx3G -XX:+AlwaysPreTouch -XX:OnOutOfMemoryError=\"kill -9 %p\" -XX:HeapDumpPath=/var/atlassian/application-data/confluence/ -XX:+HeapDumpOnOutOfMemoryError -Datlassian.mail.senddisabled=true -Datlassian.mail.fetchdisabled=true -Datlassian.mail.popdisabled=true -Datlassian.plugins.enable.wait=${v}",
	"FINAL": "final"
}
}
EOF

