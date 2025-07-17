#!/bin/sh

sort -k 2 history.txt | awk -F "\t" -f script.awk > output.svg
