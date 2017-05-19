#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
"container_env": {
EOF
for i in $(seq 1 ${1:-10}); do
    cat <<EOF
	"VAL${i}": "val${i}-${v}",
EOF
done
cat <<EOF
    "CONFLUENCE_HOSTNAME": "aslive-intranet.mergermarket.com",
    "CATALINA_OPTS": "-Xms3G -Xmx3G -XX:+AlwaysPreTouch -XX:OnOutOfMemoryError=\"kill -9 %p\" -XX:HeapDumpPath=/var/atlassian/application-data/confluence/ -XX:+HeapDumpOnOutOfMemoryError -Datlassian.mail.senddisabled=true -Datlassian.mail.fetchdisabled=true -Datlassian.mail.popdisabled=true -Datlassian.plugins.enable.wait=${v}",
	"FINAL": "final"
},
EOF
cat <<EOF
"infra_container_env": {
EOF

for i in $(seq 1 ${1:-10}); do
    cat <<EOF
	"INFRA_VAL${i}": "val${i}-${v}",
EOF
done
cat <<EOF
	"FINAL": "final"
},
"secrets": {
            "SERVER_ID": "1234",
            "LICENSE_KEY": "1234",
            "DATABASE_PASSWORD": "1234"
}
}
EOF

