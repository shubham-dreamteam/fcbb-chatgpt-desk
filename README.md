# FCBB Desk for ChatGPT

Operating manual that lets ChatGPT run First Choice Business Brokers Albuquerque's work on Dreamteam CRM (`fcbb.dreamteamcrm.ai`) through the Dreamteam MCP connector `https://mcp.dreamteamcrm.ai/mcp`, with Gmail and scheduled automations.

## Use it

**Set up everything** (connections check, 5 scheduled automations, desk canvas). Paste into ChatGPT inside the FCBB Desk project:

```
Set up FCBB Desk. Open https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/SETUP.md and do every step in it: check the connections, create all the scheduled tasks, draw my desk in a canvas, then report.
```

**Day to day** the project uses the full manual: https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md (or add the file to the project's files, which is more reliable).

## Files

| File | What |
|---|---|
| [SETUP.md](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/SETUP.md) | The setup run: checks, creates the automations, draws the desk |
| [FCBB-DESK.md](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md) | Everything in one file (built from `parts/` by `build.sh`) |
| [parts/](parts) | The manual by part: business, connections, MCP tools, data model, rules, skills, automations, desk UI, tests, issues, REST API |
| [ui/fcbb-desk-reference.html](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html) | Reference code for the canvas desk (made-up data) |
| [api/openapi.yaml](https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/api/openapi.yaml) | Custom GPT Action schema for the REST fallback |

API docs: https://docs.dreamteam.co/api/

This repo is public: it holds no tokens, private addresses or client data. All examples are made up.
