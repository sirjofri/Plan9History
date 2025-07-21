#!/bin/awk -F "\t" -f

function getx(year) {
	return (year - scalefrom) / (scaleto - scalefrom) * range
}

BEGIN {
	# which row per system
	height["HIST"] = 1
	height["PLAN9"] = 2
	height["INFERNO"] = 3
	height["9LEGACY"] = 4
	height["9FRONT"] = 3
	height["9ATOM"] = 5
	height["HARVEY"] = 8
	height["JEHANNE"] = 9
	height["P9P"] = 6
	height["9VX"] = 9
	height["AKAROS"] = 11
	height["NIX"] = 7
	height["NODE9"] = 10
	height["PLANB"] = 7
	height["HPC"] = 9
	
	# classes, used for color coding
	class["HIST"] = ""
	class["PLAN9"] = "plan9"
	class["INFERNO"] = "inferno"
	class["9LEGACY"] = "plan9"
	class["9FRONT"] = "plan9"
	class["9ATOM"] = "plan9"
	class["HARVEY"] = "plan9"
	class["JEHANNE"] = "plan9"
	class["P9P"] = "misc"
	class["9VX"] = "misc"
	class["AKAROS"] = "inferno"
	class["NIX"] = "plan9"
	class["NODE9"] = "inferno"
	class["PLANB"] = "plan9"
	class["HPC"] = "plan9"
	
	# label per system
	label["HIST"] = "General History"
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
	label["HPC"] = "HPC"
	
	# additional parameters
	stepheight = 80  # vertical line offset
	yoffset = 15     # vertical offset from top
	xoffset = 40     # save some space at the beginning of the graph
	xsave = 40       # save some space at the end of the graph
	labeloffset = -3 # offset for the system labels
	lineheight = 10  # equals font size
	stopheight = 3   # height of the small vertical event lines
	
	scalefrom = 1987 # first date of events
	scaleto = 2025   # last date of events
	size = 2000      # size of the graph
	
	titlefontsize = 15
	
	iboxsize = 20    # size of the interactive box
	
	####### code
	for (i in height)
		lastx[i] = -1
	
	maxheight = 0
	for (i in height)
		maxheight = height[i] > maxheight ? height[i] : maxheight
	
	range = size - xoffset - xsave  # size of the graph, minus offsets

	print "<svg xmlns=\"http://www.w3.org/2000/svg\""
	print "  width=\"500mm\" height=\"500mm\""
	printf "  viewBox=\"0 0 %d 500\">", size
	print "  <title>Plan 9 History</title>"
	print "  <desc>Timeline of Plan 9 systems and their children</desc>"
	print "  <style type=\"text/css\"><![CDATA["
	print ".ibox { display: block; fill: transparent; stroke: none; outline: dashed 1px #0000ff55; }"
	print ".stepgroup line { stroke-dasharray: 15; stroke: #00000022; }"
	print ".plan9 { stroke: blue; fill: blue; }"
	print ".inferno { stroke: green; fill: green; }"
	print ".misc { stroke: brown; fill: brown; }"
	print "text { font-family: sans-serif; }"
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
	
	print "  <g class=\"stepgroup\">"
	for (i = scalefrom; i < scaleto+1; i++) {
		x = xoffset + getx(i)
		strokewidth = 1
		if (i%10 == 0) {
			strokewidth = 3
		} else if (i%5 == 0) {
			strokewidth = 2
		}
		miny = yoffset+titlefontsize
		printf "  <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" stroke-width=\"%d\" />\n", x, miny, x, miny+maxheight*stepheight, strokewidth
	}
	print "  </g>"
	
	printf "  <g stroke=\"black\" stroke-width=\"1px\" font-size=\"%d\" text-anchor=\"middle\">\n", lineheight
}

function printline(text, step, h, line) {
	if (text ~ /^;$/)
		return
	printf "    <text x=\"%d\" y=\"%d\" stroke-width=\"0\">%s</text>\n", step+xoffset, h+labeloffset-line*lineheight, text
}

function dline(x1, y1, x2, y2, cls) {
	printf "    <line x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" class=\"%s\" />\n", x1, y1, x2, y2, cls
}

function dibox(x, y, id) {
	printf "    <rect width=\"%d\" height=\"%d\" x=\"%d\" y=\"%d\" class=\"ibox\" onclick=\"openinfo('%s')\" infobox=\"%s\" />\n", iboxsize, iboxsize, x-iboxsize/2+xoffset, y-iboxsize/2, id, id
}

function dinfo(x, y, id, text) {
	printf "    <g id=\"%s\" style=\"display:none;\">\n", id
	printline(text, x, y, 3)
	print "    </g>"
}

/^.+/ {
	type=$1
	year=$2
	date=$3
	note=$4
	extended=$5
	
	currentstep = getx(year)
	
	h = height[type] * stepheight + yoffset
	lx = lastx[type]
	tx = currentstep + xoffset
	cls = class[type]
	
	if (lx >= 0) {
		# line from lx to currentstep, label
		dline(lx+xoffset, h, tx, h, cls)
		dline(tx, h, tx, h+stopheight, cls)
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
		dline(tx, h, tx, h+stopheight, cls)
		printf "    <text x=\"%d\" y=\"%d\" stroke-width=\"0\" text-anchor=\"start\" font-weight=\"bold\" class=\"%s\">%s</text>\n", currentstep+xoffset, h-labeloffset+lineheight, cls, label[type]
	}
	
	lastx[type] = currentstep
}

END {
	print "  </g>"
	"git rev-parse --short HEAD" | getline hash; close("git rev-parse --short HEAD");
	printf "  <text x=\"%d\" y=\"%d\" text-anchor=\"baseline\" font-size=\"12\">%s%s (%s)</text>\n", xoffset, yoffset+titlefontsize+maxheight*stepheight, "Build: ", strftime("%Y-%m-%d"), hash
	print "</svg>"
}