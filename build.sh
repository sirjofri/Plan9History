#!/bin/sh

ranges=$(mktemp)

awk -F "\t" '
/^.+/ {
	type = $1
	year = $2
	if (min[type] == 0 || year < min[type])
		min[type] = year
	if (max[type] == 0 || year > max[type])
		max[type] = year
}
END {
	for (i in min) {
		printf "RANGE\t%s\t%d\t%d\n", i, min[i], max[i]
	}
}
' history.txt > $ranges

maxheight=$(awk -F "\t" '
/^.+/ {
	maxheight = $2 > maxheight ? $2 : maxheight
}
END {
	print maxheight
}
' config.txt)

cat $ranges <(sed 's/^/CONF\t/g' config.txt) <(sort -k 2 history.txt) | awk -v maxheight=$maxheight -F "\t" -f script.awk > plan9timeline.svg
rm $ranges
