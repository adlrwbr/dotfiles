#!/bin/bash
# count the todos in a logseq graph
GRAPHDIR=~/logseqtest/
TODOS=$(rg -- "- TODO" $GRAPHDIR/assets/ $GRAPHDIR/journals/ $GRAPHDIR/pages/ | grep -v '^\s*$' | sed -e 's/^.*TODO /- /')

echo "📝 $(echo "$TODOS" | wc -l)"
printf "<i>TODO</i>\n\n$TODOS" | tr '\n' '\r'
