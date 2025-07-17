#!/bin/awk -F "\t" -f

BEGIN {
	height["PLAN9"] = 1
	height["INFERNO"] = 2
	height["9LEGACY"] = 3
	height["9FRONT"] = 2
	height["9ATOM"] = 4
	height["HARVEY"] = 7
	height["JEHANNE"] = 8
	height["P9P"] = 5
	height["9VX"] = 8
	height["AKAROS"] = 10
	height["NIX"] = 6
	height["NODE9"] = 9
	height["PLANB"] = 6
	
	lastx["PLAN9"] = -1
	lastx["INFERNO"] = -1
	lastx["9LEGACY"] = -1
	lastx["9FRONT"] = -1
	lastx["9ATOM"] = -1
	lastx["HARVEY"] = -1
	lastx["JEHANNE"] = -1
	lastx["P9P"] = -1
	lastx["9VX"] = -1
	lastx["AKAROS"] = -1
	lastx["NIX"] = -1
	lastx["NODE9"] = -1
	lastx["PLANB"] = -1
	
	label["PLAN9"] = "Plan 9"
	label["INFERNO"] = "Inferno"
	label["9LEGACY"] = "9legacy"
	label["9FRONT"] = "9front"
	label["9ATOM"] = "9atom"
	label["HARVEY"] = "Harvey OS"
	label["JEHANNE"] = "Jehanne OS"
	label["P9P"] = "Plan 9 from User Space"
	label["9VX"] = "9vx"
	label["AKAROS"] = "Akaros"
	label["NIX"] = "NIX"
	label["NODE9"] = "Node9"
	label["PLANB"] = "Plan B"
	
	stepheight = 80  # vertical line offset
	yoffset = 15
	xoffset = 40  # save some space at the beginning of the graph
	xsave = 40    # save some space at the end of the graph
	labeloffset = -3
	lineheight = 10 # equals font size
	stopheight = 3
	
	scalefrom = 1987
	scaleto = 2025  # last date of events
	size = 2000  # size of the graph
	
	titlefontsize = 15
	
	botcenter = size/2
	botheight = 550
	
	iboxsize = 20 # size of the interactive box
	
	range = size - xoffset - xsave  # size of the graph, minus offsets

	print "<svg xmlns=\"http://www.w3.org/2000/svg\""
	print "  width=\"500mm\" height=\"500mm\""
	printf "  viewBox=\"0 0 %d 500\">", size
	print "  <title>Plan 9 History</title>"
	print "  <desc>Timeline of Plan 9 systems and their children</desc>"
	print "  <style type=\"text/css\"><![CDATA["
	print ".ibox { display: block; fill: transparent; stroke: none; outline: dotted 1px blue; }"
	print "  ]]></style>"
	print "  <script><![CDATA["
	print "function openinfo(i) {"
	print "  el = document.getElementById(i);"
	print "  if (el.style.display == \"none\")"
	print "    el.style.display = \"block\";"
	print "  else"
	print "    el.style.display = \"none\";"
	print "  console.log(\"clicked\");"
	print "}"
	print "  ]]></script>"
	printf "  <text x=\"%d\" y=\"%d\" font-size=\"%d\" font-weight=\"bold\" font-family=\"sans-serif\" text-anchor=\"middle\">Plan 9 Timeline</text>", size/2, titlefontsize, titlefontsize
	printf "  <g stroke=\"black\" stroke-width=\"1px\" font-size=\"%d\" text-anchor=\"middle\">\n", lineheight
}

function printline(text, step, h, line) {
	if (text ~ /^;$/)
		return
	printf "    <text x=\"%d\" y=\"%d\" stroke-width=\"0\">%s</text>\n", step+xoffset, h+labeloffset-line*lineheight, text
}

function dline(x1, y1, x2, y2) {
	printf "    <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" />\n", x1, y1, x2, y2
}

function dibox(x, y, id) {
	printf "    <rect width=\"%d\" height=\"%d\" x=\"%d\" y=\"%d\" class=\"ibox\" onclick=\"openinfo('%s')\" infobox=\"%s\" />\n", iboxsize, iboxsize, x-iboxsize/2+xoffset, y-iboxsize/2, id, id
}

function dinfo(x, y, id, text) {
	printf "    <g id=\"%s\" style=\"display:none;\">\n", id
	printline(text, x, y, 3)
	print "    </g>"
}

function getx(year) {
	return (year - scalefrom) / (scaleto - scalefrom) * range
}

/^.+/ {
	type=$1
	year=$2
	date=$3
	note=$4
	extended=$5
	
	currentstep = getx(year)
	
	h=height[type] * stepheight + yoffset
	lx=lastx[type]
	tx = currentstep + xoffset
	
	if (lx >= 0) {
		# line from lx to currentstep, label
		dline(lx+xoffset, h, tx, h)
		dline(tx, h, tx, h+stopheight)
	}
	# print labels
	printline(year, currentstep, h, 0)
	printline(date, currentstep, h, 1)
	printline(note, currentstep, h, 2)
	if (NF >= 5) {
		dibox(currentstep, h, NR)
		dinfo(currentstep, h, NR, extended)
	}
	
	if (lx < 0) {
		# print line label and stop line
		dline(tx, h, tx, h+stopheight)
		printf "    <text x=\"%d\" y=\"%d\" stroke-width=\"0\" text-anchor=\"start\" font-weight=\"bold\">%s</text>\n", currentstep+xoffset, h-labeloffset+lineheight, label[type]
	}
	
	lastx[type] = currentstep
}

END {
	print "  </g>"
	print "</svg>"
}