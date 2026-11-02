#!/bin/sh
# Joins parts/ into FCBB-DESK.md, the single file ChatGPT reads.
cd "$(dirname "$0")" && cat parts/*.md > FCBB-DESK.md && wc -c FCBB-DESK.md
