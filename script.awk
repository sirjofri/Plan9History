#!/bin/awk -F "\t" -f

function getx(year) {
	return (year - scalefrom) / (scaleto - scalefrom) * range
}

BEGIN {
	debug = ENVIRON["debug"]
	
	# additional parameters
	stepheight = 80  # vertical line offset
	yoffset = 15     # vertical offset from top
	xoffset = 40     # save some space at the beginning of the graph
	xsave = 40       # save some space at the end of the graph
	labeloffset = -3 # offset for the system labels
	lineheight = 10  # equals font size
	stopheight = 5   # height of the small vertical event lines
	
	scalefrom = 1987 # first date of events
	scaleto = 2025   # last date of events
	size = 2000      # size of the graph
	
	titlefontsize = 15
	
	iboxsize = 20    # size of the interactive box
	
	####### code
	
	range = size - xoffset - xsave  # size of the graph, minus offsets

	print "<svg xmlns=\"http://www.w3.org/2000/svg\""
	printf "  viewBox=\"0 0 %d %d\">", size, yoffset+titlefontsize+maxheight*stepheight
	print "  <title>Plan 9 History</title>"
	print "  <desc>Timeline of Plan 9 systems and their children</desc>"
	print "  <style type=\"text/css\"><![CDATA["
	print ".ibox { display: block; fill: transparent; stroke: none; outline: dashed 1px #0000ff55; }"
	print ".interactive { cursor: pointer; }"
	print ".stepgroup line { stroke-dasharray: 15; stroke: #00000022; }"
	print ".inheritance { fill: none !important; stroke-dasharray: 5; stroke: #00000077; }"
	print ".plan9 { stroke: blue; fill: blue; }"
	print ".inferno { stroke: green; fill: green; }"
	print ".misc { stroke: brown; fill: brown; }"
	print "text { font-family: sans-serif; cursor: default; }"
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
	printf "stepheight = %d;", stepheight
	print "rows = Array();"
	print "  ]]></script>"
	printf "  <rect x=\"0\" y=\"0\" width=\"%d\" height=\"%d\" rx=\"5\" ry=\"5\" fill=\"white\" />\n", size, yoffset+titlefontsize+maxheight*stepheight
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

$1 == "RANGE" {
	min[$2] = $3
	max[$2] = $4
	if (debug)
		printf "  <!-- range %s %s %s -->\n", $2, $3, $4
	next
}

$1 == "CONF" {
	type = $2
	height[type] = $3
	class[type] = $4
	parent[type] = $5
	label[type] = $6
	lastx[type] = -1
	firstx[type] = -1
	next
}

$1 == "NUM" {
	numrows = $2
	next
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
	printf "    <rect width=\"%d\" height=\"%d\" x=\"%d\" y=\"%d\" class=\"ibox interactive\" onclick=\"openinfo('%s')\" infobox=\"%s\" />\n", iboxsize, iboxsize, x-iboxsize/2+xoffset, y-iboxsize, id, id
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
	
	printf "  <g class=\"%s\">", type
	
	# draw inheritance line
	parenth = height[parent[type]]
	if (lx < 0 && parenth > 0) {
		tpy = parenth * stepheight + yoffset  # target point y
		cpy = (tpy + h) * 0.6   # control point y
		if (cpy > h)
			cpy = h
		if (cpy < tpy)
			cpy = tpy
		
		# calculated min/max for parent line
		mn = getx(min[parent[type]])
		mx = getx(max[parent[type]])
		
		xminusone = getx(year-0.7)
		if (xminusone <= mx && xminusone >= mn) {
			mx = xminusone
		}
		mx += xoffset
		cpx = (mx + tx) * 0.5
		printf "  <path d=\"M %d %d Q %d %d %d %d\" class=\"inheritance %s %s\" />\n", tx, h, cpx, cpy, mx, tpy, cls, parent[type]
		if (debug)
			printf "  <circle cx=\"%d\" cy=\"%d\" r=\"4\" />\n", cpx, cpy
	}
	
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
		printf "    <text x=\"%d\" y=\"%d\" stroke-width=\"0\" text-anchor=\"start\" font-weight=\"bold\" class=\"%s interactive\" onclick=\"collapse('%s')\">%s</text>\n", currentstep+xoffset, h-labeloffset+lineheight, cls, type, label[type]
		print "    <script type=\"text/javascript\"><![CDATA["
		printf "rows[\"%s\"] = %d;\n", type, 1
		print "    ]]></script>"
		firstx[type] = currentstep
	}
	
	print "  </g>"
	
	if (lx < 0) {
		printf "  <text stroke-width=\"0\" text-anchor=\"start\" font-weight=\"bold\" id=\"%s\" onclick=\"collapse('%s')\" x=\"%d\" y=\"%d\" class=\"%s interactive\">%s</text>\n", type, type, xoffset, maxheight*stepheight - currentn*(lineheight+2), cls, label[type]
		currentn++;
	}
	
	lastx[type] = currentstep
}

END {
	print "  </g>"
	"git rev-parse --short HEAD" | getline hash; close("git rev-parse --short HEAD");
	printf "  <text x=\"%d\" y=\"%d\" text-anchor=\"baseline\" font-size=\"12\">%s%s (%s)</text>\n", xoffset, yoffset+titlefontsize+maxheight*stepheight, "Build: ", strftime("%Y-%m-%d"), hash
	
	print "<script type=\"text/javascript\"><![CDATA["
	print "function collapse(id) {"
	print "  els = document.getElementsByClassName(id);"
	print "  if (rows[id]) { // row visible"
	print "    rows[id] = 0;"
	print "    document.getElementById(id).style.opacity = \"0.4\";"
	print "    for (i = 0; i < els.length; i++) {"
	print "      els[i].style.display = \"none\";"
	print "    }"
	print "  } else { // row invisible"
	print "    rows[id] = 1;"
	print "    document.getElementById(id).style.opacity = \"1.0\";"
	print "    for (i = 0; i < els.length; i++) {"
	print "      els[i].style.display = \"block\";"
	print "    }"
	print "  }"
	print "}"
	print "]]></script>"
	print "</svg>"
}