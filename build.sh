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

cat $ranges <(sort -k 2 history.txt) | awk -F "\t" -f script.awk > output.svg
rm $ranges
