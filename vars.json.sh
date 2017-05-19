#!/bin/sh
v="$(date +%s)"
cat <<EOF
{
"container_env": {
    "VAL1": "val1-$v",
    "VAL2": "val2-$v",
    "VAL3": "val3-$v",
    "VAL4": "val4-$v",
    "VAL5": "val5-$v",
    "VAL6": "val6-$v",
    "VAL7": "val7-$v",
    "VAL8": "val8-$v",
    "VAL9": "val9-$v"
}
}
EOF
