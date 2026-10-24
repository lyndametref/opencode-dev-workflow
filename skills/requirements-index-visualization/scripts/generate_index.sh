#!/bin/sh
# Parse REQ/NFR Markdown, validate records, then render the HTML template.
# Usage: generate_index.sh [requirements-dir [output.html]]

set -eu

base=${1:-docs/requirements}
output=${2:-$base/index.html}
[ -d "$base" ] || { echo "error: requirements directory not found: $base" >&2; exit 1; }
fail() { echo "error: $*" >&2; exit 1; }

base_abs=$(CDPATH= cd "$base" && pwd) || fail "requirements directory not found: $base"
base_name=$(basename "$base_abs")
parent=$(dirname "$base_abs")
parent_name=$(basename "$parent")
if [ "$base_name" = "requirements" ] && [ "$parent_name" = "docs" ]; then project_root=$(dirname "$parent"); else project_root=$parent; fi
raw_title=$(basename "$project_root")
raw_title=$(printf '%s' "$raw_title" | sed 's/[_-]/ /g')
project_title=$(printf '%s' "$raw_title" | awk '{ for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print }')
[ -n "$project_title" ] || project_title="Requirements"
if [ "$project_title" = "Requirements" ]; then full_title="Requirements"; else full_title="$project_title - Requirements"; fi

set --
group_count=0
leaf_count=0
for g in "$base"/business/REQ-[0-9][0-9].md; do
	[ -f "$g" ] || fail "no business group files"
	set -- "$@" "$g"
	group_count=$((group_count + 1))
	stem=${g##*/}; stem=${stem%.md}
	for a in "$base/business/$stem".[0-9][0-9][0-9].md; do [ -f "$a" ] || continue; set -- "$@" "$a"; leaf_count=$((leaf_count + 1)); done
done
for g in "$base"/non-functional/NFR-[0-9][0-9].md; do
	[ -f "$g" ] || fail "no non-functional group files"
	set -- "$@" "$g"
	group_count=$((group_count + 1))
	stem=${g##*/}; stem=${stem%.md}
	for a in "$base/non-functional/$stem".[0-9][0-9][0-9].md; do [ -f "$a" ] || continue; set -- "$@" "$a"; leaf_count=$((leaf_count + 1)); done
done

disk_ids=$(for f in "$base"/business/REQ-[0-9][0-9].[0-9][0-9][0-9].md "$base"/non-functional/NFR-[0-9][0-9].[0-9][0-9][0-9].md; do [ -f "$f" ] || continue; b=${f##*/}; printf '%s\n' "${b%.md}"; done | sort)
script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
template="$script_dir/../templates/index.html"
renderer="$script_dir/../../html-template-migration/scripts/render_html_template.sh"
[ -f "$template" ] || fail "requirements HTML template not found: $template"
[ -f "$renderer" ] || fail "shared HTML template renderer not found: $renderer"
page_title=$full_title
page_heading=$full_title
data_tmp="$base/.index.data.$$"
trap 'rm -f "$data_tmp"' EXIT HUP INT TERM

awk '
function jesc(s,   out, i, c, n) {
	out = ""; n = length(s)
	for (i = 1; i <= n; i++) {
		c = substr(s, i, 1)
		if (c == "\\" || c == "\"") out = out "\\" c
		else if (c == "\n") out = out "\\n"
		else if (c == "\r") out = out "\\r"
		else if (c == "\t") out = out "\\t"
		else out = out c
	}
	return out
}
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
function reset_body() { title = ""; sec = ""; story = ""; crit = ""; desc = ""; rati = ""; veri = ""; ac = "" }
function flush_file(   id, rest, gid, i, obj) {
	if (title == "") return
	if (!match(title, /^(REQ|NFR)-[0-9][0-9](\.[0-9][0-9][0-9])?([ \t]+|$)/)) { print "bad title: " title > "/dev/stderr"; exit 1 }
	id = trim(substr(title, 1, RLENGTH))
	rest = trim(substr(title, RLENGTH + 1))
	if (index(id, ".")) {
		gid = substr(id, 1, 6)
		i = gi[gid]
		if (i == 0) { print "group " gid " not seen before " id > "/dev/stderr"; exit 1 }
		if (id ~ /^REQ-/) {
			obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(rest) "\",\"criticality\":\"" jesc(trim(crit)) "\",\"userStory\":\"" jesc(trim(story)) "\",\"description\":\"" jesc(trim(desc)) "\",\"criteria\":\"" jesc(trim(ac)) "\"}"
		} else {
			obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(rest) "\",\"description\":\"" jesc(trim(desc)) "\",\"rationale\":\"" jesc(trim(rati)) "\",\"verification\":\"" jesc(trim(veri)) "\"}"
		}
		gchild[i] = gchild[i] (gchild[i] == "" ? "" : ",") obj
		nleaf++
	} else {
		if (gi[id]) { print "duplicate group ID " id > "/dev/stderr"; exit 1 }
		gi[id] = ++ngroup; gids[ngroup] = id; gtitle[ngroup] = rest
		gstory[ngroup] = trim(story); gdesc[ngroup] = trim(desc); gchild[ngroup] = ""
	}
	title = ""
}
function group_json(i) {
	return "{\"id\":\"" jesc(gids[i]) "\",\"title\":\"" jesc(gtitle[i]) "\",\"userStory\":\"" jesc(gstory[i]) "\",\"description\":\"" jesc(gdesc[i]) "\",\"children\":[" gchild[i] "]}"
}
function build_payload(   out, i, first) {
	out = "{\"business\":["; first = 1
	for (i = 1; i <= ngroup; i++) if (gids[i] ~ /^REQ-/) { out = out (first ? "" : ",") group_json(i); first = 0 }
	out = out "],\"nfr\":["; first = 1
	for (i = 1; i <= ngroup; i++) if (gids[i] ~ /^NFR-/) { out = out (first ? "" : ",") group_json(i); first = 0 }
	return out "]}"
}
BEGIN { ngroup = 0; nleaf = 0; prevfile = ""; done = 0 }

FILENAME == "-" {
	if (prevfile != "") flush_file()
	payload = build_payload()
	print payload
	done = 1
	next
}

{
	if (FILENAME != prevfile) { if (prevfile != "") { flush_file(); reset_body() }; prevfile = FILENAME }
	if ($0 ~ /^# /) { title = substr($0, 3); next }
	if ($0 ~ /^## /) { sec = substr($0, 4); next }
	if (sec == "Group") next
	if (sec == "Acceptance Criteria") { if ($0 ~ /^- /) ac = ac "\n" substr($0, 3); else ac = ac "\n" $0; next }
	if (sec == "User Story") story = story "\n" $0
	else if (sec == "Criticality") crit = crit "\n" $0
	else if (sec == "Description") desc = desc "\n" $0
	else if (sec == "Rationale") rati = rati "\n" $0
	else if (sec == "Verification Method") veri = veri "\n" $0
}
' "$@" - > "$data_tmp" <<'DATA_END'
__RENDER_DATA__
DATA_END

n_json_ids=$(grep -o '"id":"' "$data_tmp" | wc -l | tr -d ' ')
expected_ids=$((group_count + leaf_count))
[ "$n_json_ids" -eq "$expected_ids" ] || fail "expected $expected_ids id entries, found $n_json_ids"
for id in $disk_ids; do grep -q "\"$id\"" "$data_tmp" || fail "id $id missing from parsed data"; done

"$renderer" "$template" "$output" "$data_tmp" "$page_title" "$page_heading"
echo "wrote $output: $leaf_count requirements ($group_count groups)"
