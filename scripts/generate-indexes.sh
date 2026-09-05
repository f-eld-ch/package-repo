#!/usr/bin/env bash
# Generates index.html directory listing pages for all subdirectories
# that do not already have one. Skips the repo root (Hugo handles that).
# Run from the gh-pages working tree root.
set -euo pipefail

generate_index() {
  local dir="$1"
  local rel="${dir#./}"
  local title="${rel:-Package Repository}"
  local depth
  depth=$(echo "$rel" | tr -cd '/' | wc -c)

  # Build relative path back to root for CSS (unused here, but handy reference)
  local root_rel=""
  for _ in $(seq 1 "$depth"); do root_rel="../${root_rel}"; done

  # Collect entries: directories first, then files, sorted
  local entries=()
  while IFS= read -r entry; do
    entries+=("$entry")
  done < <(
    find "$dir" -maxdepth 1 -mindepth 1 \( -type d -o -type f \) \
      ! -name "index.html" \
      ! -name ".nojekyll" \
      ! -name "CNAME" \
      -printf '%Y\t%f\n' \
    | sort -k1,1r -k2,2 \
    | awk -F'\t' '{print $2, $1}'
  )

  cat > "${dir}/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} — SitRep Packages</title>
  <style>
    :root {
      --bg: #ffffff; --fg: #1a1a1a; --muted: #6b7280;
      --border: #e5e7eb; --link: #2563eb; --hover: #f9fafb;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #0f0f0f; --fg: #e5e5e5; --muted: #9ca3af;
        --border: #374151; --link: #60a5fa; --hover: #1a1a1a;
      }
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: var(--bg); color: var(--fg);
      line-height: 1.6; padding: 2rem 1rem;
    }
    main { max-width: 800px; margin: 0 auto; }
    h1 { font-size: 1.25rem; margin-bottom: 1.5rem; }
    h1 a { color: var(--fg); text-decoration: none; }
    h1 a:hover { text-decoration: underline; }
    table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
    th { text-align: left; padding: 0.4rem 0.75rem; border-bottom: 2px solid var(--border); color: var(--muted); font-weight: 600; }
    td { padding: 0.35rem 0.75rem; border-bottom: 1px solid var(--border); }
    tr:hover td { background: var(--hover); }
    a { color: var(--link); text-decoration: none; }
    a:hover { text-decoration: underline; }
    .icon { width: 1.25rem; display: inline-block; }
    footer { margin-top: 2rem; color: var(--muted); font-size: 0.8rem; }
  </style>
</head>
<body>
<main>
  <h1>$(breadcrumb "$rel")</h1>
  <table>
    <thead><tr><th colspan="2">Name</th><th>Size</th></tr></thead>
    <tbody>
HTML

  # Parent link (skip for top-level dirs served under root)
  if [ -n "$rel" ]; then
    echo "      <tr><td class=\"icon\">📁</td><td><a href=\"../\">../</a></td><td>—</td></tr>" >> "${dir}/index.html"
  fi

  for entry_line in "${entries[@]+"${entries[@]}"}"; do
    local name type
    name=$(echo "$entry_line" | awk '{print $1}')
    type=$(echo "$entry_line" | awk '{print $2}')
    local path="${dir}/${name}"
    if [ "$type" = "d" ]; then
      echo "      <tr><td class=\"icon\">📁</td><td><a href=\"${name}/\">${name}/</a></td><td>—</td></tr>" >> "${dir}/index.html"
    else
      local size
      size=$(du -sh "$path" 2>/dev/null | cut -f1)
      echo "      <tr><td class=\"icon\">📄</td><td><a href=\"${name}\">${name}</a></td><td>${size}</td></tr>" >> "${dir}/index.html"
    fi
  done

  cat >> "${dir}/index.html" <<HTML
    </tbody>
  </table>
  <footer><a href="https://packages.sitrep.ch">packages.sitrep.ch</a></footer>
</main>
</body>
</html>
HTML
}

breadcrumb() {
  local rel="$1"
  if [ -z "$rel" ]; then
    echo '<a href="/">packages.sitrep.ch</a>'
    return
  fi
  local parts
  IFS='/' read -ra parts <<< "$rel"
  local result='<a href="/">packages.sitrep.ch</a>'
  local accumulated=""
  for part in "${parts[@]}"; do
    accumulated="${accumulated}${part}/"
    local depth
    depth=$(echo "$accumulated" | tr -cd '/' | wc -c)
    local back=""
    for _ in $(seq 1 "$depth"); do back="../${back}"; done
    result="${result} / <a href=\"${back}\">${part}</a>"
  done
  echo "$result"
}

# Export functions so subshells can use them
export -f breadcrumb generate_index

# Walk all subdirectories (not the root — Hugo handles that)
find . -mindepth 1 -type d \
  ! -path './.git' \
  ! -path './.git/*' \
| sort \
| while read -r d; do
    generate_index "$d"
  done

echo "Directory indexes generated."
