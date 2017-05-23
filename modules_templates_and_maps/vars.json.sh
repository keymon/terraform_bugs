#!/bin/bash
v="$(date +%s)"
cat <<EOF
{
	"hash_map_vars": {
		"AAAA": "${v}",
		"BBBB": "fixed_value"
	}
}
EOF

