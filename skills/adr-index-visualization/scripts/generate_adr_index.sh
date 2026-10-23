#!/bin/sh
# Generate index.html visualizing the architecture decision records (ADRs).
#
# Reads ADR-NNNN-*.md files under <adr-dir> (files are the source of truth)
# and emits a self-contained <adr-dir>/index.html with the data embedded as
# JSON. No separate ADR index file is read or maintained.
# Shell + awk only; no temp files outside the ADR directory; deterministic
# output.
#
# Usage: generate_adr_index.sh [adr-dir]
#   adr-dir defaults to docs/architecture relative to the current working
#   directory. Run from the project root.

set -eu

base=${1:-docs/architecture}
[ -d "$base" ] || { echo "error: ADR directory not found: $base" >&2; exit 1; }

fail() { echo "error: $*" >&2; exit 1; }

# --- reject ADR files that do not follow the naming convention --------------
for f in "$base"/ADR-*.md; do
	[ -f "$f" ] || continue
	b=${f##*/}
	# Legacy hand-maintained index; ignored if still present.
	[ "$b" = "ADR-INDEX.md" ] && continue
	case $b in
	ADR-[0-9][0-9][0-9][0-9]-*.md) ;;
	*) fail "bad ADR filename: $b (expected ADR-NNNN-kebab-case-title.md)" ;;
	esac
done

# --- collect files ---------------------------------------------------------
set --
adr_count=0
for f in "$base"/ADR-[0-9][0-9][0-9][0-9]-*.md; do
	[ -f "$f" ] || continue
	set -- "$@" "$f"
	adr_count=$((adr_count + 1))
done
[ "$adr_count" -gt 0 ] || fail "no ADR files found in $base"

disk_ids=$(
	for f in "$base"/ADR-[0-9][0-9][0-9][0-9]-*.md; do
		[ -f "$f" ] || continue
		b=${f##*/}
		printf '%.8s\n' "$b"
	done | sort
)

dupes=$(printf '%s\n' "$disk_ids" | uniq -d)
[ -z "$dupes" ] || fail "duplicate ADR id(s): $(printf '%s' "$dupes" | tr '\n' ' ')"

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
function reset_body() {
	title = ""; status = ""; ns = 0; cur = ""
}
function flush_adr(   b, id, st, i, secs, first, obj) {
	if (title == "") {
		print "missing title heading in " prevfile > "/dev/stderr"
		exit 1
	}
	b = prevfile
	sub(/^.*\//, "", b)
	if (!match(b, /^ADR-[0-9][0-9][0-9][0-9]-/)) {
		print "bad filename: " b > "/dev/stderr"
		exit 1
	}
	id = substr(b, 1, 8)
	st = trim(status)
	if (st == "") {
		print "missing Status section in " b > "/dev/stderr"
		exit 1
	}
	if (!match(st, /^(Proposed|Accepted|Refused|Deprecated|Superseded)([ \t]|$)/)) {
		print "invalid status in " b ": " st > "/dev/stderr"
		exit 1
	}
	secs = ""
	first = 1
	for (i = 1; i <= ns; i++) {
		secs = secs (first ? "" : ",") \
			"{\"heading\":\"" jesc(trim(shead[i])) "\"" \
			",\"content\":\"" jesc(trim(sbody[i])) "\"}"
		first = 0
	}
	obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(title) "\"" \
		",\"status\":\"" jesc(st) "\",\"sections\":[" secs "]}"
	nadr++
	adrs[nadr] = obj
}
function build_payload(   out, i) {
	out = "{\"adrs\":["
	for (i = 1; i <= nadr; i++) out = out (i > 1 ? "," : "") adrs[i]
	out = out "]}"
	gsub(/<\//, "<\\/", out)
	return out
}
BEGIN { nadr = 0; ns = 0; prevfile = ""; done_flush = 0 }

FILENAME == "-" || FILENAME == "" {
	if (!done_flush) {
		flush_adr()
		reset_body()
		done_flush = 1
		payload = build_payload()
	}
	i = index($0, "__DATA__")
	if (i > 0)
		print substr($0, 1, i - 1) payload substr($0, i + 8)
	else
		print
	next
}

{
	if (FILENAME != prevfile) {
		if (prevfile != "") {
			flush_adr()
			reset_body()
		}
		prevfile = FILENAME
	}
	if ($0 ~ /^#[ \t]/) { title = trim(substr($0, 2)); cur = ""; next }
	if ($0 ~ /^##[ \t]/) {
		h = trim(substr($0, 3))
		if (h == "Status") { cur = "Status"; next }
		ns++
		shead[ns] = h
		sbody[ns] = ""
		cur = "sec"
		next
	}
	if (cur == "Status") { status = status "\n" $0; next }
	if (cur == "sec") { sbody[ns] = sbody[ns] "\n" $0; next }
}
' "$@" - > "$tmp" <<'TEMPLATE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Architecture Decision Records</title>
<style>
  :root {
    --bg: #f4f4f2; --panel: #ffffff; --border: #e2e2df;
    --ink: #1c1c1a; --muted: #6b6b66; --accent: #33506f;
    --accent-soft: #e8eef5; --badge: #eceff1;
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
  .tree-pane {
    border-right: 1px solid var(--border); overflow-y: auto;
    padding: 12px; background: #fafaf9;
  }
  #filter {
    width: 100%; padding: 7px 10px; margin-bottom: 10px;
    border: 1px solid var(--border); border-radius: 8px;
    font: inherit; font-size: 13px;
  }
  .root-title {
    font-size: 11px; letter-spacing: .08em; text-transform: uppercase;
    color: var(--muted); margin: 2px 6px 6px;
  }
  .leaf {
    display: flex; align-items: center; gap: 8px; width: 100%;
    background: none; border: 0; border-radius: 6px; padding: 6px 8px;
    font: inherit; font-size: 13.5px; color: var(--ink);
    cursor: pointer; text-align: left;
  }
  .leaf:hover { background: #f0f0ee; }
  .leaf.active { background: var(--accent-soft); color: var(--accent); font-weight: 600; }
  .badge {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 11px; background: var(--badge); color: var(--muted);
    border-radius: 5px; padding: 1px 6px; flex: none;
  }
  .leaf.active .badge { background: #d7e2ee; color: var(--accent); }
  .leaf .label { flex: 1 1 auto; }
  .dot { width: 8px; height: 8px; border-radius: 50%; flex: none; background: #c9c9c4; }
  .dot.proposed { background: #b6892b; }
  .dot.accepted { background: #2f6f4f; }
  .dot.refused { background: #b0443f; }
  .dot.deprecated { background: #8a8a85; }
  .dot.superseded { background: #4a6fa5; }
  .detail-pane { overflow-y: auto; padding: 26px 30px; }
  .detail .rid {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 13px; color: var(--accent);
  }
  .detail h2 { margin: 2px 0 10px; font-size: 22px; }
  .tags { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; align-items: center; }
  .tag {
    font-size: 12px; border: 1px solid var(--border); border-radius: 999px;
    padding: 2px 10px; color: var(--muted); background: #fafaf9;
  }
  .tag.status-proposed { border-color: #e4d3ab; background: #faf3e2; color: #7d5c15; }
  .tag.status-accepted { border-color: #bcd8c9; background: #e7f1ec; color: #2f6f4f; }
  .tag.status-refused { border-color: #e6c2c0; background: #f8eaea; color: #b0443f; }
  .tag.status-deprecated { border-color: #d8d8d3; background: #f0f0ee; color: #6b6b66; }
  .tag.status-superseded { border-color: #c3d0e2; background: #eaf0f7; color: #4a6fa5; }
  .detail h3 {
    font-size: 12px; letter-spacing: .07em; text-transform: uppercase;
    color: var(--muted); margin: 22px 0 6px;
  }
  .detail h4 { font-size: 14px; margin: 16px 0 6px; }
  .detail p { margin: 0 0 8px; }
  .detail ul, .detail ol { margin: 4px 0 10px; padding-left: 22px; }
  .detail li { margin: 3px 0; }
  .detail code {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 12.5px; background: #f2f2ef; border-radius: 4px; padding: 1px 4px;
  }
  .detail a { color: var(--accent); }
  .detail .note { color: var(--muted); font-size: 13px; }
  .detail .empty { color: var(--muted); }
  .detail pre {
    margin: 6px 0 12px; padding: 12px 14px; overflow-x: auto;
    background: #f7f7f4; border: 1px solid var(--border); border-radius: 8px;
    font: 12.5px/1.35 ui-monospace, SFMono-Regular, Menlo, monospace;
    white-space: pre; tab-size: 4;
  }
  .detail pre code { background: none; padding: 0; font-size: inherit; }
  .table-wrap { overflow-x: auto; margin: 6px 0 12px; }
  .detail table { border-collapse: collapse; font-size: 13.5px; }
  .detail th, .detail td {
    border: 1px solid var(--border); padding: 5px 9px;
    text-align: left; vertical-align: top;
  }
  .detail th { background: #fafaf9; font-weight: 600; }
  .hidden { display: none !important; }
</style>
</head>
<body>
<div class="app">
  <header>
    <h1>Architecture Decision Records</h1>
    <span class="sub" id="counts"></span>
  </header>
  <div class="panes">
    <nav class="tree-pane">
      <input id="filter" type="search" placeholder="Filter decisions…" autocomplete="off">
      <div class="root-title">Decisions</div>
      <div id="tree"></div>
    </nav>
    <main class="detail-pane"><div class="detail" id="detail"></div></main>
  </div>
</div>
<script id="data" type="application/json">__DATA__</script>
<script>
const DATA = JSON.parse(document.getElementById("data").textContent);
const treeEl = document.getElementById("tree");
const detailEl = document.getElementById("detail");
const filterEl = document.getElementById("filter");

const esc = s => String(s).replace(/[&<>"]/g,
  c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
const statusWord = s => (String(s || "").trim().split(/\s+/)[0] || "").toLowerCase();

const nodes = {};

function inline(s) {
  const codes = [];
  let t = esc(s).replace(/`([^`]+)`/g, (m, c) => {
    codes.push(c);
    return "\u0000" + (codes.length - 1) + "\u0000";
  });
  t = t.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  t = t.replace(/\*([^*\n]+)\*/g, "<b>$1</b>");
  t = t.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (m, text, href) =>
    /^(https?:|#|\/|\.{0,2}\/)/.test(href) || !href.includes(":")
      ? '<a href="' + href + '">' + text + "</a>" : text);
  t = t.replace(/\u0000(\d+)\u0000/g, (m, n) => "<code>" + codes[+n] + "</code>");
  return t;
}

const isSepRow = cells => cells.length > 0 &&
  cells.every(c => /^:?-{3,}:?$/.test(c));
const splitRow = line => line.trim().replace(/^\|/, "").replace(/\|$/, "")
  .split("|").map(c => c.trim());
const isUl = line => /^\s*[-*]\s+/.test(line);
const isOl = line => /^\s*\d+[.)]\s+/.test(line);
const isHeading = line => /^#{3,6}\s/.test(line);
const isTable = line => line.trim().startsWith("|");
const isFence = line => /^\s*(```|~~~)/.test(line);

function startsBlock(line) {
  return !line.trim() || isHeading(line) || isUl(line) || isOl(line) ||
    isTable(line) || isFence(line);
}

function renderMarkdown(src) {
  const lines = String(src || "").split("\n");
  const out = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) { i++; continue; }
    if (isFence(line)) {
      const marker = /^\s*(```|~~~)/.exec(line)[1];
      const lang = line.trim().slice(marker.length).trim();
      const buf = [];
      i++;
      while (i < lines.length && !lines[i].trim().startsWith(marker)) buf.push(lines[i++]);
      if (i < lines.length) i++;
      out.push("<pre><code" +
        (lang ? ' class="language-' + esc(lang) + '"' : "") + ">" +
        esc(buf.join("\n")) + "</code></pre>");
      continue;
    }
    const h = /^(#{3,6})\s+(.*)$/.exec(line);
    if (h) {
      const lvl = Math.min(h[1].length + 1, 6);
      out.push("<h" + lvl + ">" + inline(h[2]) + "</h" + lvl + ">");
      i++;
      continue;
    }
    if (isTable(line)) {
      const rows = [];
      while (i < lines.length && isTable(lines[i])) rows.push(splitRow(lines[i++]));
      let head = null, body = rows;
      if (rows.length > 1 && isSepRow(rows[1])) { head = rows[0]; body = rows.slice(2); }
      let html = '<div class="table-wrap"><table>';
      if (head) html += "<thead><tr>" +
        head.map(c => "<th>" + inline(c) + "</th>").join("") + "</tr></thead>";
      html += "<tbody>" + body.map(r => "<tr>" +
        r.map(c => "<td>" + inline(c) + "</td>").join("") + "</tr>").join("") +
        "</tbody></table></div>";
      out.push(html);
      continue;
    }
    if (isUl(line) || isOl(line)) {
      const tag = isUl(line) ? "ul" : "ol";
      const re = isUl(line) ? /^\s*[-*]\s+/ : /^\s*\d+[.)]\s+/;
      const items = [];
      while (i < lines.length && re.test(lines[i]))
        items.push(lines[i++].replace(re, ""));
      out.push("<" + tag + ">" +
        items.map(t => "<li>" + inline(t) + "</li>").join("") + "</" + tag + ">");
      continue;
    }
    const para = [line.trim()];
    i++;
    while (i < lines.length && !startsBlock(lines[i]))
      para.push(lines[i++].trim());
    out.push("<p>" + inline(para.join(" ")) + "</p>");
  }
  return out.length ? out.join("") : '<p class="empty">—</p>';
}

function leafButton(adr) {
  const b = document.createElement("button");
  b.className = "leaf";
  b.dataset.id = adr.id;
  b.dataset.search = (adr.id + " " + adr.title + " " + adr.status).toLowerCase();
  b.innerHTML = '<span class="dot ' + esc(statusWord(adr.status)) +
    '" title="' + esc(adr.status) + '"></span>' +
    '<span class="badge">' + esc(adr.id) + '</span>' +
    '<span class="label">' + esc(adr.title) + "</span>";
  b.addEventListener("click", () => select(adr.id));
  nodes[adr.id] = adr;
  return b;
}

function renderTree() {
  const frag = document.createDocumentFragment();
  for (const adr of DATA.adrs) {
    frag.appendChild(leafButton(adr));
  }
  treeEl.appendChild(frag);
}

function renderDetail(adr) {
  const word = statusWord(adr.status);
  let html = '<div class="rid">' + esc(adr.id) + "</div>" +
    "<h2>" + esc(adr.title) + "</h2>" +
    '<div class="tags"><span class="tag status-' + esc(word) + '">' +
    esc(adr.status) + "</span></div>";
  for (const sec of adr.sections)
    html += "<h3>" + esc(sec.heading) + "</h3>" + renderMarkdown(sec.content);
  detailEl.innerHTML = html;
}

function select(id) {
  document.querySelectorAll(".leaf.active")
    .forEach(e => e.classList.remove("active"));
  const btn = document.querySelector('.leaf[data-id="' + CSS.escape(id) + '"]');
  if (btn) btn.classList.add("active");
  renderDetail(nodes[id]);
}

function applyFilter() {
  const q = filterEl.value.trim().toLowerCase();
  let shown = 0;
  document.querySelectorAll(".leaf").forEach(l => {
    const hit = !q || l.dataset.search.includes(q);
    l.classList.toggle("hidden", !hit);
    if (hit) shown++;
  });
  let note = document.getElementById("no-results");
  if (!note) {
    note = document.createElement("p");
    note.id = "no-results";
    note.className = "empty";
    note.textContent = "No matching decisions.";
    treeEl.parentNode.appendChild(note);
  }
  note.classList.toggle("hidden", shown > 0);
}

filterEl.addEventListener("input", applyFilter);

renderTree();
const accepted = DATA.adrs.filter(a => /^Accepted/i.test(a.status)).length;
document.getElementById("counts").textContent =
  DATA.adrs.length + " decisions · " + accepted + " accepted";
select(DATA.adrs[0].id);
</script>
</body>
</html>
TEMPLATE

# --- validate output -------------------------------------------------------
if grep -q '__DATA__' "$tmp"; then fail "placeholder not replaced"; fi
n_json_ids=$(grep -o '"id":"' "$tmp" | wc -l | tr -d ' ')
[ "$n_json_ids" -eq "$adr_count" ] ||
	fail "expected $adr_count id entries, found $n_json_ids"
for id in $disk_ids; do
	grep -q "\"$id\"" "$tmp" || fail "id $id missing from output"
done

mv "$tmp" "$base/index.html"
trap - EXIT HUP INT TERM
if [ "$adr_count" -eq 1 ]; then noun="decision record"; else noun="decision records"; fi
echo "wrote $base/index.html: $adr_count $noun"
