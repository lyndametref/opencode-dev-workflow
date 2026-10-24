#!/bin/sh
# Generate index.html visualizing a business glossary corpus.
#
# Reads one-Markdown-file-per-term glossary files under <glossary-dir> and
# emits only a self-contained <glossary-dir>/index.html. Term files are the
# sole source; no Markdown index is read or generated.
# Shell + awk only; deterministic output; no external dependencies.
#
# Usage: generate_business_glossary_index.sh [glossary-dir]
#   glossary-dir defaults to docs/domain-model/business-glossary relative to
#   the current working directory. Run from the project root.

set -eu

base=${1:-docs/domain-model/business-glossary}
[ -d "$base" ] || { echo "error: business glossary directory not found: $base" >&2; exit 1; }

fail() { echo "error: $*" >&2; exit 1; }

# --- validate filenames and collect files ----------------------------------
set --
term_count=0
for f in "$base"/*.md; do
	[ -f "$f" ] || continue
	b=${f##*/}
	case "$b" in
		*.md) ;;
		*) continue ;;
	esac
	slug=${b%.md}
	case "$slug" in
		''|-*|*-|*--*|*[!a-z0-9-]*) fail "bad glossary filename: $b (expected <kebab-case-term>.md)" ;;
	esac
	set -- "$@" "$f"
	term_count=$((term_count + 1))
done
[ "$term_count" -gt 0 ] || fail "no glossary term files found in $base"

disk_ids=$(
	for f in "$base"/*.md; do
		[ -f "$f" ] || continue
		b=${f##*/}
		printf '%s\n' "${b%.md}"
	done | sort
)
dupes=$(printf '%s\n' "$disk_ids" | uniq -d)
[ -z "$dupes" ] || fail "duplicate glossary term slug(s): $(printf '%s' "$dupes" | tr '\n' ' ')"

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
function reset_term() {
	title = ""; section = ""
	definition = ""; aliases = ""
}
function report_error(message) {
	print "error: " message > "/dev/stderr"
	exit 1
}
function flush_term(   b, slug, obj) {
	b = basename(previous_file)
	if (title == "") report_error("missing title heading in " b)
	if (substr(title, 1, 2) != "# ") {
		# title already stripped
	}
	name = trim(title)
	if (name == "") report_error("missing term title in " b)
	if (trim(definition) == "") report_error("missing Definition section in " b)
	slug = substr(b, 1, length(b) - 3)
	obj = "{\"id\":\"" jesc(slug) "\",\"term\":\"" jesc(name) "\"" \
		",\"definition\":\"" jesc(trim(definition)) "\"" \
		",\"aliases\":\"" jesc(trim(aliases)) "\"}"
	if (seen[slug]++) report_error("duplicate glossary term " slug)
	terms[++term_total] = obj
	title = ""
}
function build_payload(   out, i) {
	out = "{\"terms\":["
	for (i = 1; i <= term_total; i++) out = out (i > 1 ? "," : "") terms[i]
	out = out "]}"
	gsub(/<\//, "<\\/", out)
	return out
}
BEGIN { term_total = 0; previous_file = ""; done_flush = 0 }

FILENAME == "-" || FILENAME == "" {
	if (!done_flush) {
		if (previous_file != "") flush_term()
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
		if (previous_file != "") flush_term()
		previous_file = FILENAME
		reset_term()
	}
	if ($0 ~ /^# /) { title = substr($0, 3); next }
	if ($0 ~ /^## /) { section = substr($0, 4); next }
	if (section == "Definition") definition = definition "\n" $0
	else if (section == "Aliases") aliases = aliases "\n" $0
}
' "$@" - > "$tmp" <<'TEMPLATE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Business Glossary</title>
<style>
  :root {
    --bg: #f4f4f2; --panel: #fff; --border: #e2e2df;
    --ink: #1c1c1a; --muted: #6b6b66; --accent: #3b5b8a;
    --accent-soft: #e8eef7; --badge: #eceff1;
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
  .term {
    display: flex; align-items: baseline; gap: 8px; width: 100%;
    background: none; border: 0; border-radius: 6px; padding: 7px 8px;
    font: inherit; font-size: 13.5px; color: var(--ink);
    cursor: pointer; text-align: left;
  }
  .term:hover { background: #f0f0ee; }
  .term.active { background: var(--accent-soft); color: var(--accent); font-weight: 600; }
  .badge {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 11px; background: var(--badge); color: var(--muted);
    border-radius: 5px; padding: 1px 6px; flex: none;
  }
  .term.active .badge { background: #d5deec; color: var(--accent); }
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
    <h1>Business Glossary</h1>
    <span class="sub" id="counts"></span>
  </header>
  <div class="panes">
    <nav class="list-pane" aria-label="Business glossary terms">
      <input id="filter" type="search" placeholder="Filter terms…" autocomplete="off">
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

function select(term) {
  for (const button of buttons.values()) button.classList.remove("active");
  buttons.get(term.id).classList.add("active");
  detailEl.replaceChildren();
  const id = document.createElement("div");
  id.className = "rid";
  id.textContent = term.id;
  const title = document.createElement("h2");
  title.textContent = term.term;
  detailEl.append(id, title);
  addField("Definition", term.definition);
  addField("Aliases", term.aliases);
}

for (const term of DATA.terms) {
  const button = document.createElement("button");
  button.className = "term";
  button.dataset.search = [term.id, term.term, term.definition, term.aliases].join(" ").toLowerCase();
  const badge = document.createElement("span");
  badge.className = "badge";
  badge.textContent = term.term;
  const label = document.createElement("span");
  label.className = "label";
  label.textContent = term.term;
  button.append(badge, label);
  button.addEventListener("click", () => select(term));
  listEl.appendChild(button);
  buttons.set(term.id, button);
}

filterEl.addEventListener("input", () => {
  const query = filterEl.value.trim().toLowerCase();
  for (const button of buttons.values())
    button.classList.toggle("hidden", !button.dataset.search.includes(query));
});

document.getElementById("counts").textContent =
  DATA.terms.length + (DATA.terms.length === 1 ? " term" : " terms");
select(DATA.terms[0]);
</script>
</body>
</html>
TEMPLATE

# --- validate output -------------------------------------------------------
if grep -q '__DATA__' "$tmp"; then fail "placeholder not replaced"; fi
n_json_ids=$(grep -o '"id":"' "$tmp" | wc -l | tr -d ' ')
[ "$n_json_ids" -eq "$term_count" ] ||
	fail "expected $term_count id entries, found $n_json_ids"
for id in $disk_ids; do
	grep -q "\"$id\"" "$tmp" || fail "id $id missing from output"
done

mv "$tmp" "$base/index.html"
trap - EXIT HUP INT TERM
echo "wrote $base/index.html: $term_count business glossary terms"
