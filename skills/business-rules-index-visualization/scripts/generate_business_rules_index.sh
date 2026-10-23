#!/bin/sh
# Generate index.html visualizing a business-rules corpus.
#
# Reads BR-XXX-short-name.md files under <business-rules-dir> and emits only a
# self-contained <business-rules-dir>/index.html. Rule files are the sole
# source; no Markdown index is read or generated.
# Shell + awk only; deterministic output; no external dependencies.
#
# Usage: generate_business_rules_index.sh [business-rules-dir]
#   business-rules-dir defaults to docs/business-rules relative to the current
#   working directory. Run from the project root.

set -eu

base=${1:-docs/business-rules}
[ -d "$base" ] || { echo "error: business-rules directory not found: $base" >&2; exit 1; }

fail() { echo "error: $*" >&2; exit 1; }

# --- validate filenames and collect files ----------------------------------
set --
rule_count=0
for f in "$base"/BR-*.md; do
	[ -f "$f" ] || continue
	b=${f##*/}
	case "$b" in
		BR-[0-9][0-9][0-9]-*.md) ;;
		*) fail "bad business-rule filename: $b (expected BR-XXX-short-name.md)" ;;
	esac
	slug=${b#BR-[0-9][0-9][0-9]-}
	slug=${slug%.md}
	case "$slug" in
		''|-*|*-|*--*|*[!a-z0-9-]*) fail "bad business-rule filename: $b (expected BR-XXX-short-name.md)" ;;
	esac
	set -- "$@" "$f"
	rule_count=$((rule_count + 1))
done
[ "$rule_count" -gt 0 ] || fail "no business-rule files found in $base"

disk_ids=$(
	for f in "$base"/BR-[0-9][0-9][0-9]-*.md; do
		[ -f "$f" ] || continue
		b=${f##*/}
		printf '%.6s\n' "$b"
	done | sort
)
dupes=$(printf '%s\n' "$disk_ids" | uniq -d)
[ -z "$dupes" ] || fail "duplicate BR ID(s): $(printf '%s' "$dupes" | tr '\n' ' ')"

# --- generate --------------------------------------------------------------
tmp="$base/.index.html.tmp"
trap 'rm -f "$tmp"' EXIT HUP INT TERM

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
function trim(s) {
	sub(/^[ \t\r\n]+/, "", s)
	sub(/[ \t\r\n]+$/, "", s)
	return s
}
function basename(s) {
	sub(/^.*\//, "", s)
	return s
}
function reset_rule() {
	title = ""; section = ""
	description = ""; rationale = ""; applicability = ""
}
function report_error(message) {
	print "error: " message > "/dev/stderr"
	exit 1
}
function flush_rule(   b, id, expected, name, obj) {
	b = basename(previous_file)
	if (title == "") report_error("missing title heading in " b)
	if (!match(title, /^BR-[0-9][0-9][0-9]:[ \t]+/))
		report_error("bad title in " b " (expected # BR-XXX: Title)")
	id = substr(title, 1, 6)
	expected = substr(b, 1, 6)
	if (id != expected) report_error("title ID does not match filename in " b)
	name = trim(substr(title, RLENGTH + 1))
	if (name == "") report_error("missing title in " b)
	if (trim(description) == "") report_error("missing Description section in " b)
	if (trim(rationale) == "") report_error("missing Rationale section in " b)
	if (trim(applicability) == "") report_error("missing Applicability section in " b)
	obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(name) "\"" \
		",\"description\":\"" jesc(trim(description)) "\"" \
		",\"rationale\":\"" jesc(trim(rationale)) "\"" \
		",\"applicability\":\"" jesc(trim(applicability)) "\"}"
	if (seen[id]++) report_error("duplicate BR ID " id)
	rules[++rule_total] = obj
	title = ""
}
function build_payload(   out, i) {
	out = "{\"rules\":["
	for (i = 1; i <= rule_total; i++) out = out (i > 1 ? "," : "") rules[i]
	out = out "]}"
	gsub(/<\//, "<\\/", out)
	return out
}
BEGIN { rule_total = 0; previous_file = ""; done_flush = 0 }

FILENAME == "-" || FILENAME == "" {
	if (!done_flush) {
		if (previous_file != "") flush_rule()
		done_flush = 1
		payload = build_payload()
	}
	i = index($0, "__DATA__")
	if (i > 0) print substr($0, 1, i - 1) payload substr($0, i + 8)
	else print
	next
}

{
	if (FILENAME != previous_file) {
		if (previous_file != "") flush_rule()
		previous_file = FILENAME
		reset_rule()
	}
	if ($0 ~ /^# /) { title = substr($0, 3); next }
	if ($0 ~ /^## /) { section = substr($0, 4); next }
	if (section == "Description") description = description "\n" $0
	else if (section == "Rationale") rationale = rationale "\n" $0
	else if (section == "Applicability") applicability = applicability "\n" $0
}
' "$@" - > "$tmp" <<'TEMPLATE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Business Rules</title>
<style>
  :root {
    --bg: #f4f4f2; --panel: #fff; --border: #e2e2df;
    --ink: #1c1c1a; --muted: #6b6b66; --accent: #765327;
    --accent-soft: #f4eddf; --badge: #eceff1;
  }
  * { box-sizing: border-box; }
  html, body { height: 100%; margin: 0; }
  body {
    background: var(--bg); color: var(--ink);
    font: 15px/1.5 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    display: grid; place-items: center; padding: 24px;
  }
  .app {
    width: min(1200px, 100%); height: min(88vh, 900px);
    background: var(--panel); border: 1px solid var(--border);
    border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,.08);
    display: grid; grid-template-rows: auto 1fr; overflow: hidden;
  }
  header {
    padding: 14px 20px; border-bottom: 1px solid var(--border);
    display: flex; align-items: baseline; gap: 12px;
  }
  header h1 { font-size: 17px; margin: 0; }
  header .sub { color: var(--muted); font-size: 13px; }
  .panes { display: grid; grid-template-columns: 330px 1fr; min-height: 0; }
  .list-pane {
    border-right: 1px solid var(--border); overflow-y: auto;
    padding: 12px; background: #fafaf9;
  }
  #filter {
    width: 100%; padding: 7px 10px; margin-bottom: 10px;
    border: 1px solid var(--border); border-radius: 8px;
    font: inherit; font-size: 13px;
  }
  .rule {
    display: flex; align-items: baseline; gap: 8px; width: 100%;
    background: none; border: 0; border-radius: 6px; padding: 7px 8px;
    font: inherit; font-size: 13.5px; color: var(--ink);
    cursor: pointer; text-align: left;
  }
  .rule:hover { background: #f0f0ee; }
  .rule.active { background: var(--accent-soft); color: var(--accent); font-weight: 600; }
  .badge {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 11px; background: var(--badge); color: var(--muted);
    border-radius: 5px; padding: 1px 6px; flex: none;
  }
  .rule.active .badge { background: #eadcc2; color: var(--accent); }
  .label { overflow-wrap: anywhere; }
  .detail-pane { overflow-y: auto; padding: 26px 30px; }
  .rid {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 13px; color: var(--accent);
  }
  h2 { margin: 2px 0 10px; font-size: 22px; }
  h3 {
    font-size: 12px; letter-spacing: .07em; text-transform: uppercase;
    color: var(--muted); margin: 20px 0 6px;
  }
  .content { margin: 0; white-space: pre-wrap; overflow-wrap: anywhere; }
  .empty { color: var(--muted); }
  .hidden { display: none !important; }
  @media (max-width: 720px) {
    body { padding: 0; }
    .app { height: 100vh; border-radius: 0; }
    .panes { grid-template-columns: minmax(150px, 40%) 1fr; }
    .detail-pane { padding: 18px; }
  }
</style>
</head>
<body>
<div class="app">
  <header>
    <h1>Business Rules</h1>
    <span class="sub" id="counts"></span>
  </header>
  <div class="panes">
    <nav class="list-pane" aria-label="Business rules">
      <input id="filter" type="search" placeholder="Filter rules…" autocomplete="off">
      <div id="list"></div>
    </nav>
    <main class="detail-pane"><article id="detail"></article></main>
  </div>
</div>
<script id="data" type="application/json">__DATA__</script>
<script>
const DATA = JSON.parse(document.getElementById("data").textContent);
const listEl = document.getElementById("list");
const detailEl = document.getElementById("detail");
const filterEl = document.getElementById("filter");
const buttons = new Map();

function addField(label, value) {
  const heading = document.createElement("h3");
  heading.textContent = label;
  const text = document.createElement("p");
  text.className = value ? "content" : "content empty";
  text.textContent = value || "—";
  detailEl.append(heading, text);
}

function select(rule) {
  for (const button of buttons.values()) button.classList.remove("active");
  buttons.get(rule.id).classList.add("active");
  detailEl.replaceChildren();
  const id = document.createElement("div");
  id.className = "rid";
  id.textContent = rule.id;
  const title = document.createElement("h2");
  title.textContent = rule.title;
  detailEl.append(id, title);
  addField("Description", rule.description);
  addField("Rationale", rule.rationale);
  addField("Applicability", rule.applicability);
}

for (const rule of DATA.rules) {
  const button = document.createElement("button");
  button.className = "rule";
  button.dataset.search = [rule.id, rule.title, rule.description,
    rule.rationale, rule.applicability].join(" ").toLowerCase();
  const badge = document.createElement("span");
  badge.className = "badge";
  badge.textContent = rule.id;
  const label = document.createElement("span");
  label.className = "label";
  label.textContent = rule.title;
  button.append(badge, label);
  button.addEventListener("click", () => select(rule));
  listEl.appendChild(button);
  buttons.set(rule.id, button);
}

filterEl.addEventListener("input", () => {
  const query = filterEl.value.trim().toLowerCase();
  for (const button of buttons.values())
    button.classList.toggle("hidden", !button.dataset.search.includes(query));
});

document.getElementById("counts").textContent =
  DATA.rules.length + (DATA.rules.length === 1 ? " business rule" : " business rules");
select(DATA.rules[0]);
</script>
</body>
</html>
TEMPLATE

# --- validate output -------------------------------------------------------
if grep -q '__DATA__' "$tmp"; then fail "placeholder not replaced"; fi
n_json_ids=$(grep -o '"id":"' "$tmp" | wc -l | tr -d ' ')
[ "$n_json_ids" -eq "$rule_count" ] ||
	fail "expected $rule_count id entries, found $n_json_ids"
for id in $disk_ids; do
	grep -q "\"$id\"" "$tmp" || fail "id $id missing from output"
done

mv "$tmp" "$base/index.html"
trap - EXIT HUP INT TERM
echo "wrote $base/index.html: $rule_count business rules"
