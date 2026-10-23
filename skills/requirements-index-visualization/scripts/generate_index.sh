#!/bin/sh
# Generate index.html visualizing a requirements corpus.
#
# Reads group and atomic files under <requirements-dir>/business/ and
# <requirements-dir>/non-functional/ (files are the source of truth), verifies
# they match INDEX.md, and emits a self-contained <requirements-dir>/index.html
# with the data embedded as JSON.
# Shell + awk only; no temp files outside the requirements directory;
# deterministic output.
#
# Usage: generate_index.sh [requirements-dir]
#   requirements-dir defaults to docs/requirements relative to the current
#   working directory. Run from the project root.

set -eu

base=${1:-docs/requirements}
[ -d "$base" ] || { echo "error: requirements directory not found: $base" >&2; exit 1; }

fail() { echo "error: $*" >&2; exit 1; }

# --- collect files (group first, then its atoms) ---------------------------
set --
group_count=0
leaf_count=0

for g in "$base"/business/REQ-[0-9][0-9].md; do
	[ -f "$g" ] || fail "no business group files"
	set -- "$@" "$g"
	group_count=$((group_count + 1))
	stem=${g##*/}
	stem=${stem%.md}
	for a in "$base/business/$stem".[0-9][0-9][0-9].md; do
		[ -f "$a" ] || continue
		set -- "$@" "$a"
		leaf_count=$((leaf_count + 1))
	done
done

for g in "$base"/non-functional/NFR-[0-9][0-9].md; do
	[ -f "$g" ] || fail "no non-functional group files"
	set -- "$@" "$g"
	group_count=$((group_count + 1))
	stem=${g##*/}
	stem=${stem%.md}
	for a in "$base/non-functional/$stem".[0-9][0-9][0-9].md; do
		[ -f "$a" ] || continue
		set -- "$@" "$a"
		leaf_count=$((leaf_count + 1))
	done
done

# --- INDEX.md sync guard ---------------------------------------------------
disk_ids=$(
	for f in "$base"/business/REQ-[0-9][0-9].[0-9][0-9][0-9].md \
		"$base"/non-functional/NFR-[0-9][0-9].[0-9][0-9][0-9].md; do
		[ -f "$f" ] || continue
		b=${f##*/}
		printf '%s\n' "${b%.md}"
	done | sort
)
index_ids=$(grep -ohE '(REQ|NFR)-[0-9]{2}\.[0-9]{3}' \
	"$base"/business/INDEX.md "$base"/non-functional/INDEX.md | sort -u || true)
if [ "$disk_ids" != "$index_ids" ]; then
	echo "INDEX.md out of sync with files:" >&2
	echo "-- only on disk:" >&2
	printf '%s\n' "$disk_ids" >&2
	echo "-- only in index:" >&2
	printf '%s\n' "$index_ids" >&2
	exit 1
fi

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
	title = ""; sec = ""
	story = ""; crit = ""; desc = ""; rati = ""; veri = ""; ac = ""
}
function flush_file(   id, rest, gid, i, obj) {
	if (title == "") return
	if (!match(title, /^(REQ|NFR)-[0-9][0-9](\.[0-9][0-9][0-9])?([ \t]+|$)/)) {
		print "bad title: " title > "/dev/stderr"
		exit 1
	}
	id = trim(substr(title, 1, RLENGTH))
	rest = trim(substr(title, RLENGTH + 1))
	if (index(id, ".")) {
		gid = substr(id, 1, 6)
		i = gi[gid]
		if (i == 0) {
			print "group " gid " not seen before " id > "/dev/stderr"
			exit 1
		}
		if (id ~ /^REQ-/) {
			obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(rest) "\"" \
				",\"criticality\":\"" jesc(trim(crit)) "\"" \
				",\"userStory\":\"" jesc(trim(story)) "\"" \
				",\"description\":\"" jesc(trim(desc)) "\"" \
				",\"criteria\":\"" jesc(trim(ac)) "\"}"
		} else {
			obj = "{\"id\":\"" jesc(id) "\",\"title\":\"" jesc(rest) "\"" \
				",\"description\":\"" jesc(trim(desc)) "\"" \
				",\"rationale\":\"" jesc(trim(rati)) "\"" \
				",\"verification\":\"" jesc(trim(veri)) "\"}"
		}
		gchild[i] = gchild[i] (gchild[i] == "" ? "" : ",") obj
		nleaf++
	} else {
		gi[id] = ++ngroup
		gids[ngroup] = id
		gtitle[ngroup] = rest
		gstory[ngroup] = trim(story)
		gdesc[ngroup] = trim(desc)
		gchild[ngroup] = ""
	}
	title = ""
}
function group_json(i) {
	return "{\"id\":\"" jesc(gids[i]) "\",\"title\":\"" jesc(gtitle[i]) "\"" \
		",\"userStory\":\"" jesc(gstory[i]) "\"" \
		",\"description\":\"" jesc(gdesc[i]) "\"" \
		",\"children\":[" gchild[i] "]}"
}
function build_payload(   out, i, first) {
	out = "{\"business\":["
	first = 1
	for (i = 1; i <= ngroup; i++) {
		if (gids[i] ~ /^REQ-/) {
			out = out (first ? "" : ",") group_json(i)
			first = 0
		}
	}
	out = out "],\"nfr\":["
	first = 1
	for (i = 1; i <= ngroup; i++) {
		if (gids[i] ~ /^NFR-/) {
			out = out (first ? "" : ",") group_json(i)
			first = 0
		}
	}
	out = out "]}"
	gsub(/<\//, "<\\/", out)
	return out
}
BEGIN { ngroup = 0; nleaf = 0; prevfile = ""; done_flush = 0; payload = "" }

FILENAME == "-" || FILENAME == "" {
	if (!done_flush) {
		flush_file()
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
			flush_file()
			reset_body()
		}
		prevfile = FILENAME
	}
	if ($0 ~ /^# /) { title = substr($0, 3); next }
	if ($0 ~ /^## /) { sec = substr($0, 4); next }
	if (sec == "Group") next
	if (sec == "Acceptance Criteria") {
		if ($0 ~ /^- /) ac = ac "\n" substr($0, 3)
		else ac = ac "\n" $0
		next
	}
	if (sec == "User Story") story = story "\n" $0
	else if (sec == "Criticality") crit = crit "\n" $0
	else if (sec == "Description") desc = desc "\n" $0
	else if (sec == "Rationale") rati = rati "\n" $0
	else if (sec == "Verification Method") veri = veri "\n" $0
}
' "$@" - > "$tmp" <<'TEMPLATE'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>KindleKeeper — Requirements</title>
<style>
  :root {
    --bg: #f4f4f2; --panel: #ffffff; --border: #e2e2df;
    --ink: #1c1c1a; --muted: #6b6b66; --accent: #2f6f4f;
    --accent-soft: #e7f1ec; --badge: #eceff1;
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
    color: var(--muted); margin: 14px 6px 6px;
  }
  .root-title:first-child { margin-top: 2px; }
  .group-head {
    display: flex; align-items: center; gap: 6px; width: 100%;
    background: none; border: 0; padding: 6px; font: inherit;
    font-weight: 600; font-size: 13.5px; color: var(--ink);
    cursor: pointer; border-radius: 6px; text-align: left;
  }
  .group-head:hover { background: #f0f0ee; }
  .caret { width: 12px; color: var(--muted); flex: none; transition: transform .12s; }
  .group.collapsed .caret { transform: rotate(-90deg); }
  .group.collapsed .leaves { display: none; }
  .leaves { list-style: none; margin: 0 0 4px; padding: 0 0 0 14px; }
  .leaf {
    display: flex; align-items: baseline; gap: 8px; width: 100%;
    background: none; border: 0; border-radius: 6px; padding: 5px 8px;
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
  .leaf.active .badge { background: #d5e8de; color: var(--accent); }
  .detail-pane { overflow-y: auto; padding: 26px 30px; }
  .detail .rid {
    font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
    font-size: 13px; color: var(--accent);
  }
  .detail h2 { margin: 2px 0 10px; font-size: 22px; }
  .tags { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
  .tag {
    font-size: 12px; border: 1px solid var(--border); border-radius: 999px;
    padding: 2px 10px; color: var(--muted); background: #fafaf9;
  }
  .tag.must { border-color: #bcd8c9; background: var(--accent-soft); color: var(--accent); }
  .detail h3 {
    font-size: 12px; letter-spacing: .07em; text-transform: uppercase;
    color: var(--muted); margin: 20px 0 6px;
  }
  .detail .story { font-style: italic; color: #444; margin: 0; }
  .detail p { margin: 0 0 8px; }
  .detail ul { margin: 4px 0 0; padding-left: 20px; }
  .detail li { margin: 3px 0; }
  .detail .empty { color: var(--muted); }
  .hidden { display: none !important; }
</style>
</head>
<body>
<div class="app">
  <header>
    <h1>KindleKeeper — Requirements</h1>
    <span class="sub" id="counts"></span>
  </header>
  <div class="panes">
    <nav class="tree-pane">
      <input id="filter" type="search" placeholder="Filter requirements…" autocomplete="off">
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
const paras = s => String(s || "").split(/\n\s*\n/)
  .map(t => t.trim()).filter(Boolean);
const items = s => String(s || "").split("\n")
  .map(t => t.trim()).filter(Boolean);

const SECTIONS = [
  { key: "business", label: "Business Requirements" },
  { key: "nfr", label: "Non-Functional Requirements" },
];

const nodes = {};

function leafButton(leaf) {
  const b = document.createElement("button");
  b.className = "leaf";
  b.dataset.id = leaf.id;
  b.dataset.search = (leaf.id + " " + leaf.title).toLowerCase();
  b.innerHTML = '<span class="badge">' + esc(leaf.id) + "</span><span>" +
    esc(leaf.title) + "</span>";
  b.addEventListener("click", () => select(leaf.id));
  nodes[leaf.id] = leaf;
  return b;
}

function renderTree() {
  const frag = document.createDocumentFragment();
  for (const sec of SECTIONS) {
    const t = document.createElement("div");
    t.className = "root-title";
    t.textContent = sec.label;
    t.dataset.root = sec.key;
    frag.appendChild(t);
    for (const group of DATA[sec.key]) {
      const wrap = document.createElement("div");
      wrap.className = "group";
      wrap.dataset.group = group.id;
      const head = document.createElement("button");
      head.className = "group-head";
      head.innerHTML = '<span class="caret">▾</span><span class="badge">' +
        esc(group.id) + "</span><span>" + esc(group.title) + "</span>";
      head.addEventListener("click", () => wrap.classList.toggle("collapsed"));
      wrap.appendChild(head);
      const ul = document.createElement("ul");
      ul.className = "leaves";
      for (const leaf of group.children) ul.appendChild(leafButton(leaf));
      wrap.appendChild(ul);
      frag.appendChild(wrap);
    }
  }
  treeEl.appendChild(frag);
}

function paraHtml(s) {
  const ps = paras(s);
  return ps.length
    ? ps.map(p => "<p>" + esc(p) + "</p>").join("")
    : '<p class="empty">—</p>';
}

function renderDetail(leaf) {
  const isReq = leaf.id.startsWith("REQ-");
  let html = '<div class="rid">' + esc(leaf.id) + "</div>" +
    "<h2>" + esc(leaf.title) + "</h2><div class='tags'>" +
    (isReq
      ? '<span class="tag ' + (leaf.criticality === "Must have" ? "must" : "") +
        '">' + esc(leaf.criticality || "—") + "</span>"
      : "") +
    '<span class="tag">' +
    (isReq ? "Business requirement" : "Non-functional requirement") +
    "</span></div>";
  if (isReq) {
    html += "<h3>User Story</h3>" +
      (leaf.userStory
        ? '<p class="story">' + esc(leaf.userStory) + "</p>"
        : '<p class="empty">—</p>');
    html += "<h3>Description</h3>" + paraHtml(leaf.description);
    const cs = items(leaf.criteria);
    html += "<h3>Acceptance Criteria</h3>" +
      (cs.length
        ? "<ul>" + cs.map(c => "<li>" + esc(c) + "</li>").join("") + "</ul>"
        : '<p class="empty">—</p>');
  } else {
    html += "<h3>Description</h3>" + paraHtml(leaf.description);
    html += "<h3>Rationale</h3>" + paraHtml(leaf.rationale);
    html += "<h3>Verification Method</h3>" + paraHtml(leaf.verification);
  }
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
  document.querySelectorAll(".group").forEach(g => {
    let shown = 0;
    g.querySelectorAll(".leaf").forEach(l => {
      const hit = !q || l.dataset.search.includes(q);
      l.classList.toggle("hidden", !hit);
      if (hit) shown++;
    });
    g.classList.toggle("hidden", shown === 0);
    if (q && shown) g.classList.remove("collapsed");
  });
  document.querySelectorAll(".root-title").forEach(t => {
    const key = t.dataset.root;
    const any = DATA[key].some(g => {
      const el = document.querySelector('.group[data-group="' + g.id + '"]');
      return el && !el.classList.contains("hidden");
    });
    t.classList.toggle("hidden", !any);
  });
}

filterEl.addEventListener("input", applyFilter);

renderTree();
document.getElementById("counts").textContent =
  DATA.business.reduce((n, g) => n + g.children.length, 0) + " business · " +
  DATA.nfr.reduce((n, g) => n + g.children.length, 0) + " non-functional";
select(SECTIONS.map(s => DATA[s.key]).flat()[0].children[0].id);
</script>
</body>
</html>
TEMPLATE

# --- validate output -------------------------------------------------------
if grep -q '__DATA__' "$tmp"; then fail "placeholder not replaced"; fi
n_json_ids=$(grep -o '"id":"' "$tmp" | wc -l | tr -d ' ')
expected_ids=$((group_count + leaf_count))
[ "$n_json_ids" -eq "$expected_ids" ] ||
	fail "expected $expected_ids id entries, found $n_json_ids"
for id in $disk_ids; do
	grep -q "\"$id\"" "$tmp" || fail "id $id missing from output"
done

mv "$tmp" "$base/index.html"
trap - EXIT HUP INT TERM
echo "wrote $base/index.html: $leaf_count requirements ($group_count groups)"
