#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
	"container_env": {
		"AAAA": "${v}",
		"BBBB": "fixed_value"
	}
}
EOF

