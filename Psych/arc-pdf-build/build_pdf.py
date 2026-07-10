#!/usr/bin/env python3
"""Typeset THE_FOUR_WEEK_ARC.md into the FORM-system PDF (cream / Cormorant Garamond / Jost)."""
import html
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PSYCH = ROOT.parent

SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else PSYCH / "THE_FOUR_WEEK_ARC.md"
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "arc.html"
CSS = (ROOT / "arc_style.css").read_text()

FIELD_RE = re.compile(r"^([A-Z][\w /\u2019'-]{0,24}?):\s*(.*)$")


def inline(t):
    t = html.escape(t, quote=False)
    t = re.sub(r"\*\*\*(.+?)\*\*\*", r"<strong><em>\1</em></strong>", t, flags=re.S)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t, flags=re.S)
    t = re.sub(r"\*(.+?)\*", r"<em>\1</em>", t, flags=re.S)
    return t


def is_field_block(b):
    lines = [l for l in b.split("\n") if l.strip()]
    return len(lines) >= 2 and all(FIELD_RE.match(l) for l in lines)


def render_fields(b):
    rows = []
    for l in b.split("\n"):
        if not l.strip():
            continue
        m = FIELD_RE.match(l)
        label, val = m.group(1), m.group(2)
        if val.strip():
            rows.append(
                f'<div class="frow"><span class="flabel">{inline(label)}</span>'
                f'<span class="fval">{inline(val)}</span></div>'
            )
        else:
            rows.append(
                f'<div class="frow dfrow"><span class="flabel">{inline(label)}</span>'
                f'<span class="frule"></span></div>'
            )
    return '<div class="fields">' + "".join(rows) + "</div>"


md = SRC.read_text()
md = re.sub(r"\*TTS/audio:.*$", "", md, flags=re.S)
blocks = [b.strip() for b in re.split(r"\n\n+", md) if b.strip() and b.strip() != "---"]

out, i = [], 0
kicker = inline(blocks[0].strip("*"))
title = re.sub(r"^#\s*", "", blocks[1])
title = inline(title)
sub = inline(blocks[2])
i = 3
note = ""
if blocks[i].startswith("**How to use this.**"):
    note = f'<div class="cover-note">{inline(blocks[i])}</div>'
    i += 1
foot = [inline(x.strip()) for x in blocks[i].split("·")]
out.append(
    f'''<div class="cover"><div class="cover-top">
<div class="kicker">{kicker}</div>
<h1>{title.replace(" <em>", "<br><em>")}</h1>
<div class="cover-sub">{sub}</div>
{note}</div>
<div class="cover-foot"><span>{foot[0]}</span><span>{foot[1]}</span><span>{foot[2]}</span></div></div>'''
)
i += 1

section_open = False
first_para = False
dossier_done = False


def close_section():
    global section_open
    if section_open:
        out.append("</section>")
        section_open = False


while i < len(blocks):
    b = blocks[i]
    m = re.match(r"##\s*(\d+)\s*—\s*(.+)", b)
    if m:
        close_section()
        cls = ' class="flow"' if m.group(1) == "01" else ""
        keep = ' style="page-break-inside: avoid;"' if "Daily File" in m.group(2) else ""
        out.append(
            f'<section{cls}{keep}><div class="sec-head"><span class="sec-num">{m.group(1)}</span>'
            f"<h2>{inline(m.group(2))}</h2></div>"
        )
        section_open, first_para = True, True
    elif b.startswith("> *Operator.") and not dossier_done:
        out.append(f'<div class="dossier">{inline(b[2:].strip().strip("*"))}</div>')
        dossier_done = True
    elif b.startswith("> "):
        q = inline(re.sub(r"^>\s*", "", b, flags=re.M))
        out.append(f'<p class="pull">{q}</p>')
    elif b.startswith("`") and b.endswith("`"):
        if i == len(blocks) - 1:
            out.append(
                f'<div class="close-block"><hr class="rule"><div class="verbs">{inline(b.strip("`"))}</div></div>'
            )
        else:
            out.append(f'<div class="verbs">{inline(b.strip("`"))}</div>')
    elif re.match(r"^\*\*Week \w+ — ", b):
        first, _, rest = b.partition("\n")
        wm = re.match(r"\*\*(Week \w+) — (.+?)\*\*", first)
        out.append(
            f'<div class="week"><div class="week-label">{inline(wm.group(1))}</div>'
            f"<h3>{inline(wm.group(2))}</h3>"
        )
        if rest.strip():
            out.append(render_fields(rest) if is_field_block(rest) else f"<p>{inline(rest.strip())}</p>")
        while i + 1 < len(blocks) and not re.match(r"^(##|\*\*Week|`|>|I\. )", blocks[i + 1]):
            i += 1
            nxt = blocks[i]
            out.append(render_fields(nxt) if is_field_block(nxt) else f"<p>{inline(nxt)}</p>")
        out.append("</div>")
    elif re.match(r"^\*\*[^*]+\.\*\*\n", b):
        first, _, rest = b.partition("\n")
        term = first.strip("*").rstrip(".")
        out.append(
            f'<div class="stanza"><div class="stanza-term">{inline(term)}</div>'
            f"<p>{inline(rest.strip())}</p></div>"
        )
    elif re.match(r"^I\. ", b):
        items = re.findall(r"^([IVX]+)\.\s*(.+)$", b, flags=re.M)
        lis = "".join(f'<li><span class="num">{n}</span>{inline(t)}</li>' for n, t in items)
        out.append(f'<ul class="carriage">{lis}</ul>')
    elif is_field_block(b):
        out.append(render_fields(b))
        first_para = False
    else:
        cls = ' class="lead"' if first_para else ""
        out.append(f"<p{cls}>{inline(b)}</p>")
        first_para = False
    i += 1
close_section()

doc = (
    f'<!DOCTYPE html>\n<html lang="en"><head><meta charset="utf-8"><style>\n{CSS}\n</style></head><body>\n'
    + "\n".join(out)
    + "\n</body></html>"
)
OUT.write_text(doc)
print(f"wrote {OUT}: {len(out)} blocks")
