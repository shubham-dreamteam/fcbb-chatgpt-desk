#!/bin/sh
# FCBB-DESK.md = whole manual. SETUP.md = setup run. SITES-PROMPT.md = one standalone paste for ChatGPT Sites.
cd "$(dirname "$0")" || exit 1
cat parts/*.md > FCBB-DESK.md
{ cat setup/setup-head.md parts/07-automations.md; echo; echo '---'; echo
  awk '/^## Canvas desk: the prompt/{f=1} /^## Data shape/{f=0} f' parts/08-desk-ui.md; } > SETUP.md
{ cat setup/sites-head.md
  echo; echo '---'; echo; echo '## Appendix A. Dreamteam data model (fcbb)'; echo
  sed '1d' parts/04-data-model.md
  echo; echo '## Appendix B. Dreamteam REST API'; echo
  awk 'NR>1 && /^## Custom GPT/{exit} NR>1' parts/11-rest-api.md
  } > SITES-PROMPT.md
wc -c FCBB-DESK.md SETUP.md SITES-PROMPT.md
