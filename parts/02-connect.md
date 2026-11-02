# Part 2. Connecting ChatGPT to Gmail and Dreamteam

Three connections. The first two are required. The third is a fallback.

| # | Connection | Used for | Required |
|---|---|---|---|
| 1 | Gmail connector | Reading Tony's email, finding replies owed, drafting | Yes |
| 2 | Dreamteam MCP connector `https://mcp.dreamteamcrm.ai/mcp` | Every read and write in Dreamteam | Yes |
| 3 | Dreamteam REST API (Custom GPT Action) | When the MCP connector is down | No |

## 1. Gmail

1. ChatGPT → **Settings → Apps** (called Connectors on some plans) → **Gmail** → Connect.
2. Sign in with **`tony.shurter@fcbb.com`**. Use no other Google account of Tony's.
3. Check: in a new chat, ask `List my last 5 emails.` You should see real subjects.

## 2. Dreamteam MCP connector

Dreamteam's MCP server: **`https://mcp.dreamteamcrm.ai/mcp`**. It signs in with Tony's own Dreamteam login, so ChatGPT sees exactly what Tony sees in `fcbb.dreamteamcrm.ai`.

1. ChatGPT → **Settings → Apps** → **Advanced settings** → turn on **Developer mode**. (On some plans this toggle sits under Settings → Security; OpenAI moves it from time to time.)
2. **Create app** (or **Add custom connector**):
   - Name: `Dreamteam`
   - MCP server URL: `https://mcp.dreamteamcrm.ai/mcp`
   - Authentication: **OAuth**
3. ChatGPT opens Dreamteam's sign-in page. Sign in as Tony (the `fcbb` workspace) and allow access.
4. ChatGPT warns that the connector is not verified by OpenAI. That is expected for a custom connector. Continue.
5. In each new chat, make sure the Dreamteam connector is switched on (the **+** menu → the connector list). In a project, switch it on once per chat.
6. Check: ask `Using Dreamteam, who am I? Then list 5 companies.` It must answer **Tony** (user id `1000001`) and list real companies. If it names someone else, it is signed in to the wrong workspace: disconnect and sign in again.

**Plan check.** Custom connectors need a paid ChatGPT plan with Developer mode. OpenAI's own pages and third-party guides disagree on which plans qualify (Plus, Pro, Business, Enterprise, Edu are all mentioned). On Business and Enterprise an admin can turn custom connectors off. If the Create app button is missing, the plan or the admin setting is the reason.

## 3. Dreamteam REST API (fallback)

Documentation: **https://docs.dreamteam.co/api/** (pages: Authentication, Conventions, Pagination & Sorting, Errors, Schema, Records, Find Records, Users, Pipelines).

- **Base URL:** `https://api.dreamteamcrm.ai/api/v1`
- **Auth:** `Authorization: Bearer <token>`. The token carries the workspace, so no workspace id is needed. (Checked on fcbb, 2 Nov 2026.)
- **Get a token:** in `fcbb.dreamteamcrm.ai`, Settings → API (see "Get your API token" in the docs). Treat it like a password.

ChatGPT cannot call a REST API from a normal chat. To use it, build a **Custom GPT** with an **Action** that uses the OpenAPI file in this repo (`api/openapi.yaml`). Steps are in Part 11.

**Never paste the API token into a chat, a project instruction, a file or this repo.** It goes only in the Custom GPT Action's authentication box.

## Where Tony's private details live

This manual is public, so it holds no private addresses or client data. Tony's **project instructions** (pasted into the ChatGPT project, never published) hold:

- Emily's email address and Amber's email address (used to spot leads).
- Any other address Tony wants treated as a lead source.

If a part of this manual says "Emily's address", read it from the project instructions.
