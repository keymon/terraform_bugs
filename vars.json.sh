#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
"container_env": {
EOF
for i in $(seq 1 ${1:-10}); do
    cat <<EOF
	"VAL${i}": "val${i}-$v",
EOF
done
cat <<EOF
	"FINAL": "final"
}
}
EOF
