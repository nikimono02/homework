import subprocess
import html
import os

fmt = "%h|%ci|%s"
out = subprocess.run(
    ["git", "log", "--merges", "--first-parent", "--pretty=format:" + fmt],
    capture_output=True,
    text=True,
    check=True,
).stdout.strip()

rows = ""
for line in out.splitlines():
    if not line:
        continue
    sha, date, subject = line.split("|", 2)
    rows += (
        f"<tr><td>{html.escape(date)}</td>"
        f"<td>{html.escape(subject)}</td>"
        f"<td><code>{html.escape(sha)}</code></td></tr>\n"
    )

page = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Approved Merge Log - Production</title>
<style>
 body{{font-family:system-ui,sans-serif;margin:2rem;background:#0d1117;color:#e6edf3}}
 h1{{font-size:1.4rem}} table{{border-collapse:collapse;width:100%}}
 th,td{{text-align:left;padding:.5rem .75rem;border-bottom:1px solid #30363d}}
 th{{color:#8b949e}} code{{color:#7ee787}}
</style></head>
<body>
 <h1>Production Merge Log</h1>
 <p>History of successful merges promoted to <b>prd</b>.</p>
 <table><thead><tr><th>Date &amp; Time</th><th>Merge</th><th>Commit</th></tr></thead>
 <tbody>
{rows}
 </tbody></table>
</body></html>"""

os.makedirs("public", exist_ok=True)
with open("public/index.html", "w", encoding="utf-8") as f:
    f.write(page)

print("Wrote public/index.html")
