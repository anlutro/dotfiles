#!/bin/sh

LIMIT=${LIMIT:=100}
tmpdir=$(mktemp -d)
echo "using temporary directory $tmpdir"

git rev-list --objects --all | sort -k 2 > $tmpdir/allfileshas.txt
git gc && git verify-pack -v .git/objects/pack/pack-*.idx \
    | egrep "^\w+ blob\W+[0-9]+ [0-9]+ [0-9]+$" \
    | sort -k 3 -n -r \
    > $tmpdir/bigobjects.txt

if [ $LIMIT -gt 0 ]; then
    echo "Finding $LIMIT largest files..."
else
    echo "Finding and sorting files by size..."
fi

i=0
for SHA in $(cut -f 1 -d' ' < $tmpdir/bigobjects.txt); do
    echo "$(grep $SHA $tmpdir/bigobjects.txt)" "$(grep $SHA $tmpdir/allfileshas.txt)" \
        | awk '{print $1,$3,$7}' \
        >> $tmpdir/bigtosmall.txt
    i=$(expr $i + 1)
    if [ $LIMIT -gt 0 ] && [ $i -gt $LIMIT ]; then
        break
    fi
done

echo "done! $tmpdir/bigtosmall.txt"
