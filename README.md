# FCBB Desk for ChatGPT

Operating manual that lets ChatGPT run First Choice Business Brokers Albuquerque's work on Dreamteam CRM (`fcbb.dreamteamcrm.ai`) through the Dreamteam MCP connector `https://mcp.dreamteamcrm.ai/mcp`, with Gmail and scheduled automations.

## Use it

Paste into ChatGPT (inside the FCBB Desk project):

```
Read and follow the FCBB Desk manual: https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md
Then run Test 0 and Test 1 from Part 9.
```

More reliable: download [FCBB-DESK.md](FCBB-DESK.md) and add it to the project's files.

## Files

| File | What |
|---|---|
| [FCBB-DESK.md](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md) | Everything in one file (built from `parts/` by `build.sh`) |
| [parts/](parts) | The manual by part: business, connections, MCP tools, data model, rules, skills, automations, desk UI, tests, issues, REST API |
| [ui/fcbb-desk-reference.html](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html) | Reference code for the canvas desk (made-up data) |
| [api/openapi.yaml](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/api/openapi.yaml) | Custom GPT Action schema for the REST fallback |

API docs: https://docs.dreamteam.co/api/

This repo is public: it holds no tokens, private addresses or client data. All examples are made up.
