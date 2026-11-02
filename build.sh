#!/bin/sh
# FCBB-DESK.md = the whole manual. SETUP.md = setup run + automations + canvas prompt.
cd "$(dirname "$0")" || exit 1
cat parts/*.md > FCBB-DESK.md
{ cat setup/setup-head.md parts/07-automations.md; echo; echo '---'; echo
  awk '/^## Canvas desk: the prompt/{f=1} /^## Data shape/{f=0} f' parts/08-desk-ui.md; } > SETUP.md
wc -c FCBB-DESK.md SETUP.md
