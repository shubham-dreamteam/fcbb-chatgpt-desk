# Part 8. The desk: canvas view and live ChatGPT app

There are two ways to show Tony his desk. Start with the canvas. Build the live app only if Tony wants buttons that change Dreamteam.

| | Canvas desk | Live app (Apps SDK) |
|---|---|---|
| What it is | An HTML page ChatGPT draws in a canvas from live data | A ChatGPT app: an MCP server with a widget inside ChatGPT |
| Data | Read by ChatGPT through the connectors, then drawn | Read and written by the app's own server |
| Buttons | Work only inside the page. They cannot change Dreamteam | Change Dreamteam |
| Effort | One prompt | A developer project (a few days) |

## Reference code

The design to copy: **`ui/fcbb-desk-reference.html`** in this repo. Raw file:
`https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html`

It is one self-contained HTML file (inline CSS and JavaScript, Google Fonts). All its data is made up and sits in a few arrays near the top of the `<script>`: `pool` (buyers), `deals`, `moves`, `leads`, `replies`, `followups`, `lenders`. Everything below `/* helpers */` draws the page from those arrays. To make it live, replace only the arrays.

Look:
- Colours: ink `#1D2A2E`, background `#F6F8F7`, turquoise `#1F8A84`, chamisa yellow `#E2B33C`, clay red `#B5483B`, indigo `#3A4A86`.
- Fonts: Bricolage Grotesque (headings), Instrument Sans (text).
- Tabs: Today · New leads · Replies · Deals · Buyers · Lenders. A deal opens its own page.

## Canvas desk: the prompt

Tony pastes this in the FCBB Desk project (or says "draw my desk"):

```
Draw my desk. Using Dreamteam and Gmail, build a canvas with one HTML page that copies the reference design at
https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html
Keep its HTML, CSS and drawing code. Replace only the data arrays (pool, deals, moves, leads, replies, followups, lenders) with my real data:
- leads: Dreamteam contacts not Qualified or Disqualified, with company, person, Seller/Buyer, industry, town, source, date, status, one-line context.
- deals: every deal with stage, listing number, asking price, seller, town, and its offers (buyer, stage, amount, backup or withdrawn, one-line note), plus its last 2 emails.
- moves: stage moves you suggest from yesterday's emails (Part 6.7). Don't apply them.
- replies and followups: from Gmail, as in Part 6.5, with a short draft for each reply.
- pool: buyer companies with what they want, one fact, and how they'd pay.
- lenders: lender companies with contact, what they do, last contact date, and due = true if 45+ days.
Map deal stage ids to names: 1000110 Qualified, 1000111 Valuation, 1000112 MPA Delivered, 1000113 Listing Signed, 1000114 Contracting / Negotiation, 1000115 Closed Won, 1000116 Closed Lost. Offer stages: inquiry Inquiry, nda NDA, loi_proposal LOI / Proposal, contracting_negotiation Contracting / Negotiation, financing Financing, funded Funded.
Change the footer to "Live from Dreamteam and Gmail, <time> MT".
If you can't open the link, tell me and I'll attach the file.
```

If ChatGPT cannot open the raw link, download `ui/fcbb-desk-reference.html` from the repo and attach it to the chat with the same prompt.

**Acting from the canvas.** The canvas has no connection to Dreamteam, so its buttons only change the page. To act, Tony types in chat: "qualify Rio Grande Tire", "approve move 1", "add Sam Lee to Sunrise Auto Body", "draft 2". ChatGPT does it through the connector, then: "redraw my desk".

## Data shape (both versions)

```
{
  today:   { replies, oldestWaitDays, promises, waitingOn, openLeads, leadsByStatus, moves, listed, buyersOnListings },
  leads:   [ { contactId, company, person, town, type, industry, source, date, status, isNew, context } ],
  replies: [ { id, name, company, type, question, waitingDays, threadUrl, draft } ],
  waitingOn: [ { id, name, company, what, daysAgo } ],
  moves:   [ { id, kind: "deal"|"offer", recordId, name, from, to, proof } ],
  deals:   [ { id, name, stage, listingNumber, askingPrice, seller, town,
               buyers:    [ { offerId, company, person, stage, amount, backup, withdrawn, note } ],
               suggested: [ { companyId, company, fit: "strong"|"possible", reason } ],
               emails:    [ { date, line } ] } ],
  buyers:  [ { companyId, company, person, wants, fact, money } ],
  lenders: [ { companyId, company, person, does, lastContact, due } ]
}
```

---

## Live app (Apps SDK): build brief

Give this section, plus the reference HTML, to a developer or to Codex.

### What to build
**FCBB Desk**, a ChatGPT app made with OpenAI's **Apps SDK**: a remote MCP server plus a UI widget that renders inside ChatGPT. The widget is the reference HTML, made live: it reads real data from Dreamteam and its buttons write back.

Check the current Apps SDK docs before starting. The names below (`text/html+skybridge`, `openai/outputTemplate`, `window.openai.*`) are what we expect; follow the docs where they differ.

### Architecture
- **MCP server:** TypeScript, `@modelcontextprotocol/sdk`, Streamable HTTP at `/mcp`. Host on Cloudflare Workers (or Vercel). A small KV store for suggestions and the write log.
- **Widget:** one HTML resource (`text/html+skybridge`) built from the reference HTML, with its arrays replaced by `window.openai.toolOutput`. Buttons call tools with `window.openai.callTool`. "Draft reply" uses `window.openai.sendFollowUpMessage` so drafting happens in chat. Fullscreen via `window.openai.requestDisplayMode`.
- **Dreamteam access:** server-side only, over the REST API (Part 11) with a token in a secret (`DT_API_KEY`). Never send the token or raw API responses to the widget.
- **Protect it:** OAuth 2.1 on the MCP server (for example Cloudflare `workers-oauth-provider`) with one allowed user, so nobody else with the URL can read Tony's CRM.

### Tools

| Tool | Called by | Does |
|---|---|---|
| `open_desk` | model | Renders the widget (`openai/outputTemplate`) and returns the desk data |
| `qualify_lead(contact_id)` | widget | Contact → Qualified. If its company is a seller with no open deal, creates the deal at Qualified (Part 6.6) |
| `disqualify_lead(contact_id)` | widget | Contact → Disqualified |
| `add_buyer(deal_id, buyer_company_id)` | widget | Creates the offer at `inquiry`, linked to both. Refuses a duplicate |
| `propose_buyers(deal_id, buyers[])` | model | Saves suggested buyers (KV), plus the server's own industry matches |
| `propose_moves(moves[])` | model | Saves suggested stage moves (KV), skipping any already at that stage |
| `approve_move(move_id)` / `dismiss_move(move_id)` | widget | Applies the move in Dreamteam, or drops it |
| `propose_replies(items[])` | model | Saves replies owed and waiting-on (KV). The model builds them from Gmail |
| `mark_replied(item_id)` | widget | Removes the item |

Every write tool returns fresh desk data so the widget re-renders. Build the data in as few Dreamteam calls as possible and cache it for 60 seconds.

### Rules
Never delete. Never send email. Read back every write and surface a failure in the widget. Log every write (time, tool, record, before, after) for 30 days. Show a clear error when Dreamteam cannot be reached, never empty lists that look like "no data".

### Done when
1. `open_desk` shows real fcbb data and its counts match Dreamteam.
2. Qualifying a TEST seller creates its deal at Qualified, visible straight away.
3. Adding a suggested buyer creates one offer linked to the deal and the buyer; pressing Add twice makes no duplicate.
4. Approve changes the stage in Dreamteam; Not now changes nothing.
5. Works in ChatGPT on the web and on a phone.
6. Without signing in, the `/mcp` URL returns nothing from Dreamteam.

Deliver: the repo, a README with deploy steps and secrets, and how to add the app in ChatGPT (Settings → Apps → Developer mode → Create app → the `/mcp` URL).
