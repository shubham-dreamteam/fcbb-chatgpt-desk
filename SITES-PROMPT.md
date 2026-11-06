@Sites` first). Attach nothing; the links are public.

---

@Sites Build **FCBB Desk**, a private web app for Tony Shurter, business broker at First Choice Business Brokers Albuquerque. It shows his live pipeline from Dreamteam CRM (workspace `fcbb.dreamteamcrm.ai`).

**How to work: build the whole thing in one go, without stopping.**
- Do not ask me questions. The only thing you may ask for is the Dreamteam API token, once, as a Sites secret named `DT_API_KEY`. Ask for it the moment you need it, then keep going.
- Everything else, decide yourself using this message and its appendices. When something is unclear, pick the option closest to the reference page, note it in one line in your final summary, and move on.
- Don't stop to show me plans, drafts, partial versions or options. Don't ask "should I continue?" or "would you like me to…". Just continue.
- If something fails (an API call, a field name, a link read, a build error), debug it yourself: read the docs, call the endpoint, inspect the response, fix, retry. Only stop if the token is rejected (401) after I've given it.
- You're done only when the site is built, deployed privately, loads live fcbb data, the refresh icon works, and you've run the checks at the end yourself.

**Design.** Copy the reference page in **Appendix C** exactly (layout, colours, fonts, tabs, deal page, phone layout). It has made-up sample data in arrays at the top of its script (`pool`, `deals`, `moves`, `leads`, `replies`, `followups`, `lenders`); replace those with live data from the server and keep the drawing code.

**Data source.** Dreamteam REST API, docs: https://docs.dreamteam.co/api/ (read Authentication, Records, Find Records, Schema, Pipelines, Pagination, Errors before coding). Everything you need is in this message: the field, id and stage map is **Appendix A**, and the API rules are **Appendix B**. The docs link is for extra detail only.
- Base `https://api.dreamteamcrm.ai/api/v1`, header `Authorization: Bearer <DT_API_KEY>`.
- Store the token as a **Sites secret** named `DT_API_KEY` (the one thing you ask me for). Never put it in code, the page, the browser, logs or responses.
- **All Dreamteam calls run on the server** (the site's Worker), never from the browser.

**Server endpoint** `GET /api/desk`: calls Dreamteam and returns one JSON object shaped like the reference arrays (`leads`, `deals` with `offers`, `pool` of buyers, `lenders`, `replies`, `followups`, `moves`), plus `refreshedAt`.
- Companies `GET /objects/company/records`, contacts, deals, `offers` (custom object), tasks, emails: `?page=1&page_size=100`, loop while `metadata.has_next`, and check the row count equals `metadata.total_elements`. Use `page_size`, not `size` (unknown params are silently ignored).
- An error response has no `results` key: show an error, never treat it as "no data".
- Stage names from `GET /pipelines/1000000`: 1000110 Qualified, 1000111 Valuation, 1000112 MPA Delivered, 1000113 Listing Signed, 1000114 Contracting / Negotiation, 1000115 Closed Won (show "Listed"), 1000116 Closed Lost (show "Lost").
- Offer stages (`offer_stages`): inquiry, nda, loi_proposal, contracting_negotiation, financing, funded, disqualified_withdrawn. Offer links: one deal (`rel_offers_deal`), one buyer company (`rel_offers_buyers`). Contact to company link: `company_contact_assoc`. Deal to company: `company_deal_assoc`. Record GETs leave links out; read them through `POST /objects/{type}/records/filter` or the associations endpoints described in the docs. Test each link read against a record you can see in Dreamteam.
- Company `customer_type`: seller, buyer, lender, partner. Buyers tab = buyer companies; Lenders tab = lender companies; partners in their own small list.
- Leads = contacts whose `contact_activity_status` is New, Working, Connected or Meeting booked, with their company, `contact_type`, `source`, `contact_context`, `created_at`.
- Replies and follow-ups = Dreamteam `email` records (`from`, `to`, `subject`, `sent_at`, `direction`, `ai_email_summary`): threads from the last 30 days whose latest message is Inbound from a seller, buyer, lender or partner = "needs your reply" with days waiting; latest Outbound asking for something with no answer in 5+ days = "waiting on them". Also show open Dreamteam tasks (`status` Recommended or Open, `recommendation_status` Active).
- Moves: leave empty unless a deal has an email newer than its last update that clearly shows a stage change; label them "suggested".
- Cache the result for 60 seconds (in memory or D1) so refreshes stay fast.

**Refresh icon.** A circular-arrow icon button in the header next to "Synced with Dreamteam". Click → spinner → `fetch('/api/desk?fresh=1')` (skips the cache) → redraw every tab without a page reload → header shows "Synced with Dreamteam, <time> MT". On failure, keep the old data and show "Couldn't reach Dreamteam. Try again." Also load fresh data when the page opens.

**Read-only.** No writes to Dreamteam, no deletes, no email sending. The buttons in the reference (Qualified, Approve, Add, Draft reply) become links that open the record in Dreamteam (`https://fcbb.dreamteamcrm.ai`) or are hidden.

**Access.** Keep the site private: owner and admins only. No public link. It holds client names, deal prices and emails.

**Rules.** Never show any email address of Tony's except `tony.shurter@fcbb.com`. Short labels. Works at phone width.

**Finish by checking it yourself**, fixing anything that fails, and redeploying until all pass:
1. `/api/desk` returns data with row counts equal to each list's `metadata.total_elements`.
2. Every tab renders with real data at desktop and phone width, with no console errors.
3. The refresh icon fetches fresh data, updates the sync time and redraws without a reload.
4. The token appears nowhere in the page source, the browser's network responses or logs.
5. The site is private (owner and admins only).

Then reply with only: the site URL, the counts it shows (companies by type, deals per stage, offers), and any judgment calls you made, one line each.

---

## Appendix A. Dreamteam data model (fcbb)


If anything here disagrees with `object_describe`, trust `object_describe` and tell Tony.

## Objects

| Object | Slug | One record is |
|---|---|---|
| Company | `company` | A business, firm, or an individual buyer/lender/partner (see "People with no company") |
| Contact | `contact` | A person, linked to one or more companies |
| Deal | `deal` | One seller's business |
| Offer | `offers` | One buyer company on one deal |
| Task | `task` | A to-do. Dreamteam's assistant (Sally) creates email follow-up tasks on its own |
| Note | `note` | A note on a record |
| Email | `email` | Dreamteam's synced copy of an email (read-only for you) |

## Company

| Field | Type | Rules |
|---|---|---|
| `name` | Text | **Required.** The business name exactly as written ("Sunrise Auto Body", not "Sunriseautobody") |
| `domain` | URL | **Required and unique.** Website domain, e.g. `sunriseautobody.com`. Never `gmail.com`, `yahoo.com`, `hotmail.com`, `comcast.net` or any other email provider |
| `customer_type` | Dropdown | `seller`, `buyer`, `lender`, `partner`. One value |
| `industry` | Text | One value from the industry list below |
| `phone`, `address`, `city`, `state`, `country` | Text | Business phone and location. Country `United States` unless stated |
| `company_size` | Number | Employees |
| `owner_id` | User | `1000001` (Tony) |

AI fields (`ai_about`, `ai_exec_summary`, `type` and others starting `ai_`) are filled by Dreamteam. Read them; never write them.

## Contact

| Field | Type | Rules |
|---|---|---|
| `first_name` | Text | **Required** |
| `last_name` | Text | |
| `email` | Email | **Required and unique** |
| `mobile` | Phone | Cell. Tony prefers cell numbers |
| `phone` | Phone | Office |
| `job_title` | Text | Owner, Co-owner, President, Loan Officer, Escrow Officer, Attorney |
| `contact_type` | Dropdown | `seller`, `buyer`. Same as the company. Empty for lenders and partners |
| `source` | Dropdown | `Email` (from the email check), `Website Form` (FCBB site, MyPortal), `Others` (chat), also `Outbound`, `Import`, `Meeting` |
| `contact_activity_status` | Dropdown | **Required.** `New`, `Working`, `Connected`, `Meeting booked`, `Qualified`, `Disqualified` (also `None`, never set it) |
| `contact_context` | Long text | First line `Lead source: <source>`, then 2 to 4 short lines (Part 6) |
| `provisional` | Yes/No | `true` on contacts Dreamteam's email sync made on its own. Set `false` once you fill it in |
| `owner_id` | User | `1000001` |

## People with no website or no email

Dreamteam requires a **domain** on every company and an **email** on every contact, and each must be unique. Many of Tony's people have neither: an individual buyer with a Gmail address, or an owner Emily reached by phone only.

- **Never invent a domain or an email.** A made-up value would be saved as if it were real.
- Owner with a business email (`dan@sunriseautobody.com`): use its domain for the company.
- Owner with a personal email only: create the contact with that email. For the company, look for the business's own website in the email or signature. If there is none, do not create the company; put the lead under **Needs you** with all its details ("Sunrise Auto Body, Dan Ortiz, cell (505) 555-0142: no website, add the company in Dreamteam or tell me its website").
- Owner with no email at all: do not create the contact. Put it under **Needs you** with the details.
- Individual buyer with no company: the company is named `First Last (Buyer)`. It still needs a domain, so it goes under **Needs you** unless Tony gives one.

If Tony's admin turns off "required" for Website Domain and Email in Dreamteam (Settings → Objects → the field), these records can be created normally. Then: no domain for individuals, and name the company `First Last (Buyer)`, `First Last (Lender)` or `First Last (Partner)`.

## Deal

| Field | Type | Rules |
|---|---|---|
| `name` | Text | **Required.** The business name |
| `pipeline_id` | Lookup | **Required.** `1000000` (Default Pipeline) |
| `stage_id` | Lookup | **Required.** A stage id below |
| `amount` | Money | **Required.** Asking price. `0` until known |
| `expected_close_date` | Date-time | **Required.** Target date. 6 months out until known |
| `expected_selling_date` | Date | When the owner wants to sell |
| `listing_number` | Text | `291-xxxxx` once listed |
| `owner_id` | User | `1000001` |

Links: one company (`company_deal_assoc`), any number of contacts (`contact_deal_assoc`), any number of offers.

Dreamteam may refuse a deal with "A product is required". If so, stop and tell Tony: a product (for example "Business sale") must be added in Dreamteam first.

### Deal stages (Default Pipeline, `pipeline_id` 1000000)

| Order | Stage | `stage_id` | Move a deal here when |
|---|---|---|---|
| 1 | Qualified | `1000110` | The seller contact reaches Qualified: the owner wants a consultation or a valuation |
| 2 | Valuation | `1000111` | A meeting is booked or held, and Tony has asked for P&Ls, tax returns, balance sheet |
| 3 | MPA Delivered | `1000112` | Tony has sent the Market Price Analysis |
| 4 | Listing Signed | `1000113` | The owner is reviewing the listing agreement (not yet signed, despite the name) |
| 5 | Contracting / Negotiation | `1000114` | The owner agrees to list; paperwork under way (articles, lease, licence, resolution to sell) |
| 6 | Closed Won | `1000115` | Listing agreement signed. The business is listed. Show it as **Listed** |
| 7 | Closed Lost | `1000116` | The owner declines, cancels or withdraws, or Tony declines. Show it as **Lost** |

### Listing numbers

FCBB gives a listed business a number: office `291` and five digits, saved as `291-30001`. People write it many ways: `#291-30001`, `Listing #291-30001`, `listing number 30001`, `291-30001 Directional drilling`. To match, take the **last five digits** and filter `listing_number` `ENDS_WITH` them. No match, or more than one: put it under **Needs you**.

## Offer (`offers`)

| Field | Type | Rules |
|---|---|---|
| `name` | Text | **Required and unique.** `<Buyer company> – <Seller business>`. A backup buyer: add ` (Backup)` |
| `offer_stages` | Dropdown | Stage id below |
| `offer_amount` | Money | Buyer's latest offer price |
| `offer_expected_close_date` | Date | Target closing |

Links: exactly one deal (`rel_offers_deal`) and exactly one buyer company (`rel_offers_buyers`).

### Offer stages

| Stage | Id | Covers |
|---|---|---|
| Inquiry | `inquiry` | Buyer asked about the listing |
| NDA | `nda` | NDA signed, profile sent, identity and funds checked, call held, Level 2 package sent |
| LOI / Proposal | `loi_proposal` | Offer letter sent, counters going back and forth. Backups wait here |
| Contracting / Negotiation | `contracting_negotiation` | APA signed, earnest money in escrow, due diligence |
| Financing | `financing` | Lender underwriting, commitment letter pending |
| Funded | `funded` | Sale closed and funded. Tony is paid |
| Disqualified / Withdrawn | `disqualified_withdrawn` | Walked away, failed checks, or a scam |

Only one offer per deal should be at Contracting / Negotiation or later. If that buyer withdraws, tell Tony which backups are waiting.

## Task (read, and close only when Tony says)

| Field | Values |
|---|---|
| `title`, `description` | Text |
| `status` | `Open`, `Pending`, `Done`, `Recommended` |
| `task_type` | `SUGGESTED_RESPONSE`, `NO_RESPONSE_FOLLOWUP`, `PRE_MEETING_BRIEF`, `CREATE_DEAL`, `UPDATE_DEAL`, `INTRO_EMAIL`, `MEETING_FOLLOWUP`, `STALLED_DEAL_FOLLOWUP`, `CREATE_MEETING`, `RESCHEDULE_MEETING` |
| `task_source` | `SALLY` (Dreamteam's assistant), `USER`, `SYSTEM`, `RACHEL` |
| `section` | `emailFollowups`, `meetingPrep`, `dealSignal`, `emailOutreach`, `company` |
| `recommendation_status` | `Active`, `Snoozed`, `Dismissed`, `Completed`, `Manually-completed`, `Auto-resolved`, `Auto-expired`, `Auto-executed` |
| `due_at`, `priority` (`High`, `Medium`, `Low`), `owner_id` | |

## Users

| User | id | Role |
|---|---|---|
| Tony Shurter | `1000001` | admin |

## Industry list (use exactly one)

Trucking & Transport · Oilfield Services · Construction & Contracting · Roofing · Plumbing, HVAC & Electrical · Drilling & Utilities · Manufacturing & Machining · Auto Repair & Collision · Landscaping & Tree Care · Restaurant & Food · Retail · Healthcare & Pharmacy · Home Health · Professional Services · Personal Services · Hospitality & Lodging · Agriculture & Feed · Other

For buyers, the industries they want go in `contact_context` ("Wants: Roofing; Plumbing, HVAC & Electrical"). A buyer firm's own industry goes in `industry`.

## Appendix B. Dreamteam REST API


Docs: https://docs.dreamteam.co/api/ (Authentication, Records, Find Records, Schema, Users, Pipelines).

| | |
|---|---|
| Base URL | `https://api.dreamteamcrm.ai/api/v1` |
| Auth | `Authorization: Bearer <token>` (token from fcbb.dreamteamcrm.ai settings; it carries the workspace) |
| Schema | `GET /objects/{type}`: fields and dropdown ids |
| Links | `GET /objects/{type}/associations` |
| List | `GET /objects/{type}/records?page=1&page_size=100`: rows in `results`, more while `metadata.has_next`, total `metadata.total_elements` |
| One | `GET /objects/{type}/records/{id}` |
| Find | `POST /objects/{type}/records/filter` body `{"filter_groups":[{"filters":[{"field_path":"email","operator":"EQUALS","value":"x@y.com"}]}],"pagination":{"page":1,"page_size":100}}` |
| Create | `POST /objects/{type}/records` body `{"properties":{...}}` |
| Update | `PATCH /objects/{type}/records/{id}` body `{"properties":{...}}`, header `Content-Type: application/merge-patch+json` (plain JSON returns 415) |
| Pipelines | `GET /pipelines`, `GET /pipelines/1000000` |
| Users | `GET /users` |

Traps: unknown query params are silently ignored (use `page_size`, not `size`); an error body has no `results` key, so never read an error as "no data"; a malformed filter body returns everything, so test filters on a known record; write one record at a time and read it back; never DELETE.

```bash
curl -s 'https://api.dreamteamcrm.ai/api/v1/objects/company/records/filter' -X POST \
  -H "Authorization: Bearer $DT_TOKEN" -H 'Content-Type: application/json' \
  -d '{"filter_groups":[{"filters":[{"field_path":"customer_type","operator":"EQUALS","value":"buyer"}]}],"pagination":{"page":1,"page_size":100}}'
```


## Appendix C. Reference page (copy this design; its data is made up)

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FCBB Desk sample</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,500;12..96,700&family=Instrument+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<style>
:root{
  --ink:#1D2A2E; --ink-soft:#56666B; --ink-faint:#8A9A9E;
  --sky:#F6F8F7; --paper:#FFFFFF; --line:#D9E1DE;
  --turq:#1F8A84; --turq-deep:#145F5B; --turq-tint:#E3F2F0;
  --chamisa:#E2B33C; --chamisa-deep:#7A5A0E; --chamisa-tint:#FBF2DC;
  --clay:#B5483B; --clay-tint:#F7E5E2;
  --indigo:#3A4A86; --indigo-tint:#E9ECF7;
  --display:"Bricolage Grotesque",system-ui,sans-serif;
  --body:"Instrument Sans",system-ui,sans-serif;
}
*{box-sizing:border-box}
html,body{margin:0}
body{background:var(--sky);color:var(--ink);font:15px/1.5 var(--body);-webkit-font-smoothing:antialiased}
button{font:inherit;color:inherit;cursor:pointer}
button:disabled{cursor:default}
:focus-visible{outline:2px solid var(--turq);outline-offset:2px;border-radius:6px}

.chat{max-width:1180px;margin:0 auto;padding:20px 16px 48px}
.you{display:flex;justify-content:flex-end;margin:4px 0 18px}
.you p{margin:0;background:#E8ECEB;padding:10px 16px;border-radius:18px}
.assistant-note{color:var(--ink-soft);margin:0 0 12px;font-size:14px}
.composer{margin-top:18px;border:1px solid var(--line);background:var(--paper);border-radius:26px;padding:12px 18px;color:var(--ink-soft)}

.app{background:var(--paper);border:1px solid var(--line);border-radius:16px;overflow:hidden;position:relative}
.app-head{display:flex;align-items:center;gap:14px;padding:16px 20px;border-bottom:1px solid var(--line);flex-wrap:wrap}
.mark{width:34px;height:34px;border-radius:9px;background:var(--turq);color:#fff;display:grid;place-items:center;font:700 15px var(--display)}
.app-title{font:700 19px/1.1 var(--display);letter-spacing:-.01em}
.app-sub{color:var(--ink-soft);font-size:13px}
.synced{margin-left:auto;font-size:13px;color:var(--ink-soft);display:flex;align-items:center;gap:6px}
.synced::before{content:"";width:8px;height:8px;border-radius:50%;background:var(--turq)}

.tabs{display:flex;gap:4px;padding:8px 12px;border-bottom:1px solid var(--line);overflow-x:auto}
.tab{background:none;border:0;padding:8px 14px;border-radius:999px;white-space:nowrap;color:var(--ink-soft);font-weight:500}
.tab[aria-selected="true"]{background:var(--ink);color:#fff}
.n{display:inline-block;min-width:20px;margin-left:6px;padding:0 6px;border-radius:999px;background:var(--chamisa);color:var(--ink);font-size:12px;font-weight:600;text-align:center}
.n:empty{display:none}

.view{padding:22px 20px 28px;min-width:0}
.view[hidden]{display:none}
h2{font:700 22px/1.2 var(--display);letter-spacing:-.015em;margin:0 0 4px}
h3{font:600 15px/1.3 var(--body);margin:0 0 10px}
.lede{color:var(--ink-soft);margin:0 0 18px}
.muted{color:var(--ink-soft)}

.btn{border:1px solid var(--line);background:var(--paper);padding:6px 12px;border-radius:8px;font-size:13px;font-weight:500;white-space:nowrap}
.btn:hover:not(:disabled){border-color:var(--ink-soft)}
.btn.primary{background:var(--turq);border-color:var(--turq);color:#fff}
.btn.primary:hover:not(:disabled){background:var(--turq-deep)}
.btn.done{background:var(--turq-tint);border-color:var(--turq-tint);color:var(--turq-deep)}
.btn.quiet{border-color:transparent;color:var(--ink-soft)}
.chip{display:inline-block;font-size:12px;font-weight:500;padding:1px 8px;border-radius:999px;background:var(--sky);border:1px solid var(--line);color:var(--ink-soft);white-space:nowrap}
.chip.seller{background:var(--turq-tint);border-color:transparent;color:var(--turq-deep)}
.chip.buyer{background:var(--indigo-tint);border-color:transparent;color:var(--indigo)}
.chip.lender,.chip.sugg{background:var(--chamisa-tint);border-color:transparent;color:var(--chamisa-deep)}
.chip.warn{background:var(--clay-tint);border-color:transparent;color:var(--clay)}
button.chip:hover{border-color:var(--turq)}

/* today tiles */
.tiles{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}
.tile{display:block;width:100%;text-align:left;background:var(--paper);border:1px solid var(--line);border-radius:14px;padding:18px 18px 16px}
.tile:hover{border-color:var(--turq)}
.tile.hot{border-color:var(--chamisa);box-shadow:inset 0 4px 0 var(--chamisa)}
.tile .big{font:700 44px/1 var(--display);letter-spacing:-.03em}
.tile .what{font-weight:600;margin-top:4px}
.tile .detail{color:var(--ink-soft);font-size:14px;margin-top:8px}
.tile .go{display:inline-block;margin-top:12px;font-size:13px;font-weight:600;color:var(--turq)}
.split{display:flex;height:8px;border-radius:99px;overflow:hidden;background:var(--sky);margin-top:12px}
.split span{display:block;height:100%}
.legend{display:flex;flex-wrap:wrap;gap:4px 14px;font-size:13px;color:var(--ink-soft);margin-top:6px}
.legend i{display:inline-block;width:8px;height:8px;border-radius:2px;margin-right:5px;vertical-align:0}

/* leads */
.filters{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:14px}
.filter{border:1px solid var(--line);background:var(--paper);padding:5px 12px;border-radius:999px;font-size:13px}
.filter[aria-pressed="true"]{background:var(--ink);border-color:var(--ink);color:#fff}
.lead{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:4px 16px;padding:14px 0;border-top:1px solid var(--line)}
.lead .name{font-weight:600}
.lead .ctx{color:var(--ink-soft);font-size:14px;max-width:72ch}
.lead .acts{grid-row:1/span 2;grid-column:2;display:flex;gap:6px;align-items:flex-start}
.lead.gone{opacity:.45}
.status{font-size:12px;font-weight:600;color:var(--ink-soft)}

/* replies */
.stats{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-bottom:22px}
.stat{border:1px solid var(--line);border-radius:12px;padding:12px 14px}
.stat b{display:block;font:700 26px/1.1 var(--display)}
.stat span{font-size:13px;color:var(--ink-soft)}
.stat.hot{border-color:var(--chamisa);background:var(--chamisa-tint)}
.msg{border:1px solid var(--line);border-radius:12px;padding:14px 16px;margin-bottom:10px}
.msg-top{display:flex;gap:8px;align-items:baseline;flex-wrap:wrap}
.msg-top .who{font-weight:600}
.msg-top .age{margin-left:auto;font-size:13px;color:var(--ink-soft)}
.msg-top .age.late{color:var(--clay);font-weight:600}
.subject{font-size:13px;color:var(--ink-soft);margin-top:2px}
.quote{margin:10px 0 0;padding-left:12px;border-left:3px solid var(--line);color:var(--ink);font-size:14px}
.msg .acts{display:flex;gap:6px;margin-top:12px;flex-wrap:wrap}
.draft{margin-top:12px;background:var(--sky);border-radius:10px;padding:12px 14px;font-size:14px;white-space:pre-line}
.draft .acts{margin-top:10px}
.msg.done{opacity:.5}

/* deals board */
.moves{border:1px solid var(--chamisa);background:var(--chamisa-tint);border-radius:12px;padding:12px 14px;margin-bottom:18px}
.moves-head{display:flex;justify-content:space-between;align-items:center;gap:10px}
.moves-head h3{margin:0}
.move{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:4px 12px;padding:10px 0;border-top:1px solid rgba(122,90,14,.18)}
.moves-head + .move{margin-top:6px}
.move .path{font-size:14px}
.move .path b{font-weight:600}
.move .proof{font-size:13px;color:var(--ink-soft)}
.move .acts{grid-row:1/span 2;grid-column:2;display:flex;gap:6px;align-items:center}
.board{display:flex;gap:12px;overflow-x:auto;padding-bottom:8px;scroll-snap-type:x proximity}
.col{flex:1 0 200px;background:var(--sky);border-radius:12px;padding:10px;scroll-snap-align:start;min-height:180px}
.col.won{background:var(--turq-tint)}
.col.empty{flex:0 0 112px}
.col.empty .col-head{flex-direction:column;gap:2px}
.lost-line{margin-top:10px;font-size:14px;color:var(--ink-soft)}
.lost-line button{background:none;border:0;padding:0;color:var(--ink-soft);text-decoration:underline;text-underline-offset:2px}
.col-head{display:flex;justify-content:space-between;align-items:baseline;padding:2px 4px 10px;font-weight:600;font-size:14px}
.col-head span{color:var(--ink-soft);font-weight:500}
.card{display:block;width:100%;text-align:left;background:var(--paper);border:1px solid var(--line);border-radius:10px;padding:10px 12px;margin-bottom:8px}
.card:hover{border-color:var(--turq)}
.card .listing{font:700 17px/1.1 var(--display);color:var(--turq);letter-spacing:-.01em}
.card .listing.none{font:600 12px var(--body);color:var(--clay)}
.card .biz{font-weight:600;line-height:1.3;margin-top:2px}
.card .meta{color:var(--ink-soft);font-size:13px}
.card .buyers{display:flex;align-items:center;gap:8px;margin-top:9px;padding-top:8px;border-top:1px solid var(--line);font-size:12.5px;color:var(--ink-soft)}
.dots{display:flex;gap:3px}
.dot{display:inline-block;width:10px;height:10px;border-radius:50%;background:var(--turq)}
.dot.backup{background:var(--paper);border:2px dashed var(--turq)}
.dot.s{background:var(--paper);border:2px dotted var(--chamisa)}
.card.lost .biz{color:var(--ink-soft)}
.card.flash{animation:flash 1.6s ease-out}
@keyframes flash{0%{box-shadow:0 0 0 3px var(--chamisa)}100%{box-shadow:0 0 0 3px transparent}}

/* deal page */
.back{background:none;border:0;padding:0;color:var(--turq);font-weight:600;margin-bottom:14px}
.deal-head{display:grid;grid-template-columns:auto minmax(0,1fr) auto;gap:6px 24px;align-items:end}
.big-listing{font:700 clamp(40px,7vw,68px)/.9 var(--display);letter-spacing:-.03em;color:var(--turq)}
.big-listing.none{font-size:clamp(20px,3vw,26px);color:var(--clay);line-height:1.2}
.deal-name{font:700 24px/1.15 var(--display);letter-spacing:-.015em}
.deal-facts{color:var(--ink-soft);font-size:14px}
.deal-money{text-align:right}
.deal-head.no-listing{grid-template-columns:minmax(0,1fr) auto}
.deal-money .amt{font:700 26px/1 var(--display)}
.deal-money .fee{color:var(--ink-soft);font-size:13px}
.seller-track{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));gap:4px;margin:18px 0 22px}
.seller-track div{font-size:12px;color:var(--ink-faint);padding-top:8px;border-top:4px solid var(--line)}
.seller-track div.on{border-top-color:var(--turq);color:var(--ink-soft)}
.seller-track div.now{color:var(--ink);font-weight:600}
.deal-grid{display:grid;grid-template-columns:minmax(0,1fr) 290px;gap:28px}
.deal-grid>*{min-width:0}

.section-head{display:flex;align-items:baseline;justify-content:space-between;gap:10px;margin-bottom:4px;flex-wrap:wrap}
.section-head h3{margin:0;font:700 18px/1.2 var(--display)}
.key{display:flex;gap:14px;font-size:12.5px;color:var(--ink-soft);flex-wrap:wrap}
.key span{display:flex;align-items:center;gap:5px}

/* buyer lanes: the centrepiece */
.lanes{margin-top:12px}
.lane-scale,.lane{display:grid;grid-template-columns:230px minmax(0,1fr);gap:16px;align-items:center}
.lane-scale{padding:0 0 6px}
.scale{display:grid;grid-template-columns:repeat(6,minmax(0,1fr));font-size:11.5px;color:var(--ink-faint)}
.scale span{text-align:center}
.lane{padding:12px 0;border-top:1px solid var(--line)}
.lane .who b{display:block;font-weight:600;line-height:1.25}
.lane .who small{display:block;color:var(--ink-soft);font-size:13px}
.track{position:relative;height:30px}
.track::before{content:"";position:absolute;left:8.33%;right:8.33%;top:14px;height:2px;background:var(--line)}
.fill{position:absolute;left:8.33%;top:13px;height:4px;border-radius:4px;background:var(--turq)}
.stops{position:absolute;inset:0;display:grid;grid-template-columns:repeat(6,minmax(0,1fr))}
.stops i{justify-self:center;align-self:center;width:10px;height:10px;border-radius:50%;background:var(--paper);border:2px solid var(--line)}
.stops i.past{background:var(--turq);border-color:var(--turq)}
.stops i.here{width:20px;height:20px;background:var(--turq);border-color:var(--paper);box-shadow:0 0 0 2px var(--turq)}
.lane .note{grid-column:2;font-size:13px;color:var(--ink-soft);margin-top:-4px}
.lane .here-label{display:none}
.lane.backup .fill{background:repeating-linear-gradient(90deg,var(--turq) 0 6px,transparent 6px 10px)}
.lane.out{opacity:.55}
.lane.out .fill,.lane.out .stops i.past,.lane.out .stops i.here{background:var(--ink-faint);border-color:var(--ink-faint)}
.lane.out .stops i.here{box-shadow:0 0 0 2px var(--ink-faint)}
.lane.out .who b{text-decoration:line-through}
.lane.fresh{animation:arrive .7s ease-out}
@keyframes arrive{from{background:var(--turq-tint);transform:translateY(10px)}to{background:transparent;transform:none}}
.lane-move{grid-column:2;display:flex;gap:8px;align-items:center;font-size:13px;background:var(--chamisa-tint);border-radius:8px;padding:6px 10px;margin-top:4px;flex-wrap:wrap}
.lane-move .btn{margin-left:auto}

.suggested{margin-top:26px;border:1.5px dashed var(--chamisa);border-radius:14px;padding:14px 16px}
.suggested .section-head h3{color:var(--chamisa-deep)}
.s-row{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:6px 16px;padding:12px 0;border-top:1px dashed var(--line)}
.s-row:first-of-type{border-top:0}
.s-row .who b{font-weight:600}
.fit{font-size:12px;font-weight:600;margin-left:6px}
.fit.strong{color:var(--turq-deep)}
.fit.possible{color:var(--chamisa-deep)}
.tags{display:flex;flex-wrap:wrap;gap:4px;margin-top:6px}
.tags .chip{font-size:11.5px}
.s-row .why{font-size:13px;color:var(--ink-soft)}
.s-row .btn{grid-row:1/span 2;grid-column:2;align-self:start}

.side .panel{border:1px solid var(--line);border-radius:12px;padding:14px 16px;margin-bottom:14px}
.mail{padding:8px 0;border-top:1px solid var(--line);font-size:14px}
.mail:first-of-type{border-top:0}
.mail .d{color:var(--ink-soft);font-size:12.5px}
.kv{display:grid;grid-template-columns:auto 1fr;gap:4px 12px;font-size:14px;margin:0}
.kv dt{color:var(--ink-soft)}
.kv dd{margin:0}

.badge-new{display:inline-block;font-size:11.5px;font-weight:600;padding:1px 7px;border-radius:999px;background:var(--chamisa);color:var(--ink);margin-left:6px;vertical-align:1px}
.mtable{width:100%;border-collapse:collapse;background:var(--paper);border:1px solid var(--line);border-radius:12px;overflow:hidden;margin-bottom:20px}
.mtable caption{text-align:left;font-weight:600;padding:0 0 8px}
.mtable td{padding:10px 14px;border-top:1px solid var(--line);font-size:14px;vertical-align:middle}
.mtable tr:first-child td{border-top:0}
.mtable td.deal{font-weight:600}
.mtable .from{color:var(--ink-soft)}
.mtable .arrow{color:var(--ink-faint);padding:0 6px}
.mtable .to{font-weight:600;color:var(--turq-deep)}
.mtable td.acts{text-align:right;white-space:nowrap}
.mtable td.acts .btn+.btn{margin-left:6px}
/* tables */
.list{width:100%;border-collapse:collapse}
.list th{text-align:left;font-size:13px;font-weight:600;color:var(--ink-soft);padding:8px 10px;border-bottom:1px solid var(--line)}
.list td{padding:12px 10px;border-bottom:1px solid var(--line);vertical-align:top;font-size:14px}
.list td:first-child{font-weight:600}
.sub{display:block;font-weight:400;color:var(--ink-soft);font-size:13px}
.table-wrap{overflow-x:auto}

.toast{position:absolute;left:50%;bottom:64px;transform:translate(-50%,20px);opacity:0;background:var(--ink);color:#fff;border-radius:10px;padding:10px 14px;font-size:14px;display:flex;gap:12px;align-items:center;transition:.25s;pointer-events:none;max-width:calc(100% - 32px)}
.toast.show{opacity:1;transform:translate(-50%,0);pointer-events:auto}
.toast button{background:none;border:0;color:var(--chamisa);font-weight:600;padding:0}
.foot-note{color:var(--ink-soft);font-size:12.5px;padding:14px 20px;border-top:1px solid var(--line)}

@media (max-width:900px){
  .deal-grid{grid-template-columns:1fr}
  .deal-head{grid-template-columns:1fr}
  .deal-money{text-align:left}
  .stats{grid-template-columns:repeat(2,minmax(0,1fr))}
}
@media (max-width:640px){
  .tiles{grid-template-columns:1fr}
  .lead,.s-row,.move{grid-template-columns:1fr}
  .lead .acts,.s-row .btn,.move .acts{grid-row:auto;grid-column:1;justify-self:start}
  .lane-scale{display:none}
  .lane{grid-template-columns:1fr;gap:6px}
  .lane .note,.lane-move{grid-column:1}
  .lane .here-label{display:inline;font-size:12.5px;color:var(--turq-deep);font-weight:600;margin-left:6px}
  .seller-track{grid-template-columns:repeat(3,minmax(0,1fr))}
}
@media (prefers-reduced-motion:reduce){.lane.fresh,.card.flash{animation:none}.toast{transition:none}}
</style>
</head>
<body>
<div class="chat">
  <div class="you"><p>Open my desk</p></div>
  <p class="assistant-note">Here's your FCBB desk from Dreamteam.</p>

  <section class="app" aria-label="FCBB desk">
    <header class="app-head">
      <div class="mark" aria-hidden="true">FC</div>
      <div>
        <div class="app-title">FCBB Desk</div>
        <div class="app-sub">First Choice Business Brokers, Albuquerque</div>
      </div>
      <div class="synced">Synced with Dreamteam 6:30 AM</div>
    </header>

    <nav class="tabs" role="tablist" aria-label="Views">
      <button class="tab" role="tab" data-view="today" aria-selected="true">Today</button>
      <button class="tab" role="tab" data-view="leads" aria-selected="false">New leads<span class="n" id="n-leads"></span></button>
      <button class="tab" role="tab" data-view="replies" aria-selected="false">Replies<span class="n" id="n-replies"></span></button>
      <button class="tab" role="tab" data-view="deals" aria-selected="false">Deals<span class="n" id="n-moves"></span></button>
      <button class="tab" role="tab" data-view="buyers" aria-selected="false">Buyers</button>
      <button class="tab" role="tab" data-view="lenders" aria-selected="false">Lenders</button>
    </nav>

    <div class="view" id="v-today">
      <h2>Good morning, Tony</h2>
      <p class="lede" id="today-lede"></p>
      <div class="tiles" id="tiles"></div>
    </div>

    <div class="view" id="v-leads" hidden>
      <h2>New leads</h2>
      <p class="lede">Qualifying a seller creates their deal.</p>
      <div id="leads"></div>
    </div>

    <div class="view" id="v-replies" hidden>
      <h2>Replies</h2>
      <p class="lede">People waiting on you, and people you're waiting on. Drafts are never sent for you.</p>
      <div class="stats" id="reply-stats"></div>
      <h3>Needs your reply</h3>
      <div id="replies"></div>
      <h3 style="margin-top:22px">You're waiting on them</h3>
      <div id="followups"></div>
    </div>

    <div class="view" id="v-deals" hidden>
      <div id="board-wrap">
        <h2 style="margin-bottom:16px">Deals</h2>
        <div id="moves"></div>
        <div class="board" id="board"></div>
        <p class="lost-line" id="lost"></p>
      </div>
      <div id="deal" hidden></div>
    </div>

    <div class="view" id="v-buyers" hidden>
      <h2>Buyers</h2>
      <p class="lede">Everyone looking to buy, what they want, and which deals they're on.</p>
      <div class="table-wrap"><table class="list" id="buyers"></table></div>
    </div>

    <div class="view" id="v-lenders" hidden>
      <h2>Lenders</h2>
      <p class="lede">Keep in touch every 45 days.</p>
      <div class="table-wrap"><table class="list" id="lenders"></table></div>
    </div>

    <div class="foot-note">Reference design with made-up data. In ChatGPT, fill it with live Dreamteam and Gmail data.</div>
    <div class="toast" id="toast" role="status" aria-live="polite"></div>
  </section>

  <div class="composer">Ask anything, e.g. "which buyers want a roofing business?"</div>
</div>

<script>
const STAGES=["Qualified","Valuation","MPA Delivered","Listing Signed","Contracting / Negotiation","Closed Won","Closed Lost"];
const LABEL={"Closed Won":"Listed","Closed Lost":"Lost"};
const OSTAGES=["Inquiry","NDA","LOI / Proposal","Contracting / Negotiation","Financing","Funded"];
const OSHORT=["Inquiry","NDA","LOI","Contract","Financing","Funded"];
const money=n=>n?"$"+n.toLocaleString("en-US"):"";
const $=s=>document.querySelector(s);
const esc=s=>String(s??"").replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));
const bare=b=>b.replace(" (Buyer)","");

/* SAMPLE DATA: every name, number and email here is made up.
   In ChatGPT, replace these arrays with live Dreamteam and Gmail data (see Part 8). */
const pool=[
 {b:"High Desert Holdings",p:"Greg Holt",wants:["Drilling & Utilities"],fact:"LOI on Mesa Directional Drilling",money:"Wants seller financing"},
 {b:"Juniper Capital",p:"Maria Ruiz",wants:["Drilling & Utilities","Oilfield Services"],fact:"Asked for Mesa's backlog and customer mix",money:"Funded search fund"},
 {b:"Ridgeline Roofing Group",p:"Tom Keller",wants:["Roofing","Construction & Contracting"],fact:"Targets $5M+ revenue, $750k+ EBITDA",money:"Private equity backed"},
 {b:"Sam Lee (Buyer)",p:"Sam Lee",wants:["Auto Repair & Collision"],fact:"Asked about Sunrise Auto Body on BizBuySell, 1 Nov",money:"SBA pre-qualified"},
 {b:"Ana Torres (Buyer)",p:"Ana Torres",wants:["Restaurant & Food"],fact:"Call with you on 14 Oct about Blue Mesa Cafe",money:""},
 {b:"Kevin Park (Buyer)",p:"Kevin Park",wants:["Restaurant & Food"],fact:"Asked if Blue Mesa Cafe was still available, 20 Oct",money:""},
 {b:"Lucia Gomez (Buyer)",p:"Lucia Gomez",wants:["Personal Services"],fact:"Buying Clearline Windows",money:"SBA loan in progress"},
 {b:"Paul Novak (Buyer)",p:"Paul Novak",wants:["Personal Services"],fact:"Withdrew from Clearline Windows, 22 Sep",money:"401(k) rollover"},
 {b:"Ben Archer (Buyer)",p:"Ben Archer",wants:["Any"],fact:"Wants to use his 401(k) for the down payment",money:"401(k) rollover"}
];
const deals=[
 {id:"mdd",biz:"Mesa Directional Drilling",ind:"Drilling & Utilities",city:"Albuquerque, NM",seller:"Rosa and Luis Delgado",stage:"Closed Won",listing:"291-30002",ask:1100000,
  offers:[{b:"High Desert Holdings",st:"LOI / Proposal",amt:1100000,note:"Sellers countered 29 Oct: $750k cash at closing"},
          {b:"Juniper Capital",st:"LOI / Proposal",backup:true,note:"Backup if Greg's deal falls through"}],
  mail:[{d:"31 Oct",t:"Amber asked the sellers for 2025 tax returns and a trailing 12-month P&L"},{d:"29 Oct",t:"Amber sent the sellers' counter to Greg's LOI"}]},
 {id:"clw",biz:"Clearline Windows",ind:"Personal Services",city:"Las Cruces, NM",seller:"Victor Ramos",stage:"Closed Won",listing:"291-30003",ask:640000,
  offers:[{b:"Lucia Gomez (Buyer)",st:"Financing",amt:620000,note:"SBA loan in underwriting; escrow open"},
          {b:"Paul Novak (Buyer)",st:"LOI / Proposal",out:true,amt:600000,note:"Chose not to proceed, 22 Sep"}],
  mail:[{d:"30 Oct",t:"Victor sent the renewed customer contract for the lender"}]},
 {id:"bmc",biz:"Blue Mesa Cafe",ind:"Restaurant & Food",city:"Albuquerque, NM",seller:"Owner",stage:"Closed Won",listing:"291-30004",ask:0,
  offers:[{b:"Ana Torres (Buyer)",st:"NDA",note:"Call held 14 Oct"},
          {b:"Kevin Park (Buyer)",st:"Inquiry",note:"NDA link sent 20 Oct"}],
  mail:[{d:"20 Oct",t:"New NDA request forwarded to Amber"}]},
 {id:"sab",biz:"Sunrise Auto Body",ind:"Auto Repair & Collision",city:"Santa Fe, NM",seller:"Dan Ortiz",stage:"Closed Won",listing:"291-30001",ask:850000,offers:[],
  mail:[{d:"1 Nov",t:"BizBuySell inquiry from Sam Lee"}]},
 {id:"cv",biz:"Canyon View Storage",ind:"Other",city:"Rio Rancho, NM",seller:"Tom Hale",stage:"MPA Delivered",listing:"",offers:[],mail:[{d:"27 Oct",t:"You sent the signed Market Price Analysis"}]},
 {id:"btl",biz:"Baca Testing Labs",ind:"Healthcare & Pharmacy",city:"Albuquerque, NM",seller:"Linda Baca",stage:"Valuation",listing:"",offers:[],mail:[{d:"23 Oct",t:"You asked for 2023 to 2025 tax returns"}]},
 {id:"pfh",biz:"Pinon Home Health",ind:"Home Health",city:"Santa Fe, NM",seller:"Carla Ortega",stage:"Valuation",listing:"",offers:[],mail:[{d:"21 Sep",t:"You asked again for P&Ls"}]},
 {id:"rgt",biz:"Rio Grande Tire",ind:"Auto Repair & Collision",city:"Belen, NM",seller:"Joe Vigil",stage:"Qualified",listing:"",offers:[],mail:[{d:"28 Oct",t:"You introduced yourself after Emily's call"}]},
 {id:"hfc",biz:"High Plains Fence Co.",ind:"Construction & Contracting",city:"Clovis, NM",seller:"Ron Hart",stage:"Qualified",listing:"",offers:[],mail:[{d:"25 Oct",t:"You followed up on the valuation documents"}]},
 {id:"fix",biz:"FixIt Phone Repair",ind:"Personal Services",city:"Albuquerque, NM",seller:"Alan Price",stage:"Closed Lost",listing:"",offers:[],mail:[{d:"19 Oct",t:"Asked to cancel the listing agreement"}]}
];
let moves=[
 {id:1,kind:"deal",deal:"cv",to:"Listing Signed",proof:"You sent the signed MPA on 27 Oct"},
 {id:2,kind:"offer",deal:"bmc",buyer:"Kevin Park (Buyer)",to:"NDA",proof:"Signed NDA notice received 22 Oct"},
 {id:3,kind:"deal",deal:"hfc",to:"Valuation",proof:"You asked Ron for financial documents on 25 Oct"}
];
const leads=[
 {id:1,n:"Saguaro Fuel Supply",p:"Ron and Carol West",type:"Seller",ind:"Oilfield Services",city:"Yuma, AZ",src:"Emily",d:"31 Oct",status:"New",ctx:"Owners open to selling and retiring.",warn:"Arizona: may go to an FCBB Arizona office"},
 {id:2,n:"Juniper Capital",p:"Maria Ruiz",type:"Buyer",ind:"Any",city:"",src:"Email",d:"30 Oct",status:"New",ctx:"Search fund. Aims to close an acquisition this year."},
 {id:3,n:"Black Range Exploration",p:"Cody Dunn",type:"Seller",ind:"Oilfield Services",city:"Silver City, NM",src:"Emily",d:"27 Oct",status:"New",ctx:"\"Liked the idea of selling and retiring.\""},
 {id:4,n:"Front Range Maintenance",p:"Shawn Miller",type:"Seller",ind:"Construction & Contracting",city:"Pueblo, CO",src:"Emily",d:"24 Oct",status:"New",ctx:"Tired, considering a sale; dislikes large fees up front."},
 {id:5,n:"Ridgeline Roofing Group",p:"Tom Keller",type:"Buyer",ind:"Roofing",city:"",src:"Email",d:"22 Oct",status:"New",ctx:"Buying roofing companies in Albuquerque: $5M+ revenue."},
 {id:6,n:"Sunrise Auto Body",p:"Dan Ortiz",type:"Seller",ind:"Auto Repair & Collision",city:"Santa Fe, NM",src:"Emily",d:"20 Oct",status:"Qualified",ctx:"Owner is 66 and wants to retire in 1 to 2 years."},
 {id:7,n:"Rio Grande Tire",p:"Joe Vigil",type:"Seller",ind:"Auto Repair & Collision",city:"Belen, NM",src:"Emily",d:"15 Oct",status:"Connected",ctx:"40 years in business, wants to sell and retire."},
 {id:8,n:"Llano Machine Works",p:"Will Barker",type:"Seller",ind:"Manufacturing & Machining",city:"Hobbs, NM",src:"Emily",d:"8 Oct",status:"Working",ctx:"Has an offer and a valuation he isn't happy with."}
];
const sig="\n\nTony Shurter\nFirst Choice Business Brokers - Albuquerque\n(505)934-0896";
const replies=[
 {id:1,who:"Victor Ramos",biz:"Clearline Windows",type:"seller",deal:"clw",age:2,subj:"Renewed contract for the lender",q:"Attached is the renewed contract. Please forward it to the lender. Financials should be done by the end of next week.",draft:"Great news, Victor. I've forwarded the renewed contract to the lender. Send the financials as soon as they're ready and I'll get them straight over."+sig},
 {id:2,who:"Maria Ruiz",biz:"Juniper Capital",type:"buyer",deal:"",age:3,subj:"Acquisition opportunities",q:"Could we do a quick call next week to discuss what's on the market? We intend to close an acquisition this year.",draft:"Hi Maria,\n\nHappy to talk. What size and type of business are you looking for? I'm free Tuesday or Wednesday afternoon Mountain Time."+sig},
 {id:3,who:"Rosa Delgado",biz:"Mesa Directional Drilling",type:"seller",deal:"mdd",age:9,subj:"Re: LOI Mesa Directional Drilling",q:"Any down payment given, does it go to escrow as earnest money or does it go to the seller?",draft:"Hi Rosa,\n\nThe earnest money goes to escrow and is credited to the price at closing. The rest of the down payment is paid to you at closing through escrow."+sig}
];
const followups=[
 {id:5,who:"Rosa Delgado",biz:"Mesa Directional Drilling",deal:"mdd",what:"2025 tax returns and trailing 12-month P&L for Greg",age:2},
 {id:6,who:"Carla Ortega",biz:"Pinon Home Health",deal:"pfh",what:"2024 and 2025 P&Ls for the valuation",age:39},
 {id:7,who:"Linda Baca",biz:"Baca Testing Labs",deal:"btl",what:"2023 to 2025 tax returns and P&Ls",age:10}
];
const lenders=[
 {b:"Example SBA Lender",p:"Dana Brooks",does:"SBA acquisition loans",last:"30 Oct",due:false},
 {b:"Sandia Community Bank",p:"Lee Chen",does:"SBA lending",last:"11 Sep",due:false},
 {b:"Mesa Business Funding",p:"Jo Martin",does:"Buyer financing",last:"22 Jul",due:true}
];

/* helpers */
const openLeads=()=>leads.filter(l=>!["Qualified","Disqualified"].includes(l.status));
const openReplies=()=>replies.filter(r=>!r.done);
const dealById=id=>deals.find(d=>d.id===id);
function suggestions(d){
  if(d.stage==="Closed Lost")return [];
  const on=new Set(d.offers.map(o=>o.b));
  return pool.filter(p=>!on.has(p.b)&&!/Withdrew|Walked away/.test(p.fact)&&(p.wants.includes(d.ind)||p.wants.includes("Any")))
    .map(p=>{const same=p.wants.includes(d.ind),tags=[same?"Same industry":"Open to any industry"];
      if(/Asked about|Call with you|LOI on|Asked for|Asked if/.test(p.fact))tags.push("Has engaged before");if(p.money)tags.push(p.money);
      return {...p,strong:same,tags};})
    .sort((a,b)=>b.strong-a.strong);
}
function toast(html){const t=$("#toast");t.innerHTML=html;t.classList.add("show");clearTimeout(t._h);t._h=setTimeout(()=>t.classList.remove("show"),4200);}
function badges(){$("#n-leads").textContent=openLeads().length||"";$("#n-replies").textContent=openReplies().length||"";$("#n-moves").textContent=moves.length||"";}

/* today */
function renderToday(){
  const ol=openLeads(),sel=ol.filter(l=>l.type==="Seller").length,buy=ol.filter(l=>l.type==="Buyer").length;
  const byStatus=["New","Working","Connected","Meeting booked"].map(s=>[s,ol.filter(l=>l.status===s).length]).filter(x=>x[1]);
  const emily=ol.filter(l=>l.src==="Emily").length;
  const rp=openReplies(),oldest=rp.length?Math.max(...rp.map(r=>r.age)):0,prom=rp.filter(r=>r.promise).length;
  const listed=deals.filter(d=>d.stage==="Closed Won"),active=listed.reduce((n,d)=>n+d.offers.filter(o=>!o.out).length,0);
  const working=deals.filter(d=>!["Closed Won","Closed Lost"].includes(d.stage)).length;
  const fresh=ol.filter(l=>l.status==="New").length;
  $("#today-lede").textContent=`${rp.length} ${rp.length===1?"person is":"people are"} waiting on you, and ${fresh} ${fresh===1?"lead hasn't":"leads haven't"} had a first call.`;
  const colors={New:"var(--chamisa)",Working:"var(--turq)",Connected:"var(--indigo)","Meeting booked":"var(--turq-deep)"};
  $("#tiles").innerHTML=`
   <button class="tile ${rp.length?"hot":""}" data-go="replies"><div class="big">${rp.length}</div><div class="what">${rp.length===1?"person needs":"people need"} a reply</div>
     <div class="detail">${rp.length?`Oldest has waited ${oldest} days${prom?`. You promised ${prom} of them something`:""}. `:""}You're waiting on ${followups.length} people.</div><span class="go">Open replies</span></button>
   <button class="tile" data-go="leads"><div class="big">${ol.length}</div><div class="what">open leads</div>
     <div class="split">${byStatus.map(([s,n])=>`<span style="width:${n/ol.length*100}%;background:${colors[s]}"></span>`).join("")}</div>
     <div class="legend">${byStatus.map(([s,n])=>`<span><i style="background:${colors[s]}"></i>${n} ${s}</span>`).join("")}</div>
     <div class="detail">${sel} sellers, ${buy} buyers. ${emily} came from Emily.</div><span class="go">Open new leads</span></button>
   <button class="tile ${moves.length?"hot":""}" data-go="deals"><div class="big">${moves.length}</div><div class="what">stage ${moves.length===1?"move":"moves"} to review</div>
     <div class="detail">Found in yesterday's emails. Nothing moves until you approve it.</div><span class="go">Review on the deals board</span></button>
   <button class="tile" data-go="deals"><div class="big">${listed.length}</div><div class="what">businesses listed</div>
     <div class="detail">${active} buyers working on them. ${working} more sellers on the way to a listing.</div><span class="go">Open deals</span></button>`;
}

/* leads */
function renderLeads(){
  const list=leads.filter(l=>l.status!=="Disqualified"&&(l.status!=="Qualified"||l.justQ));
  $("#leads").innerHTML=list.length?list.map(l=>`<div class="lead ${l.justQ?"gone":""}">
     <div><span class="name">${esc(l.n)}</span>${l.status==="New"?`<span class="badge-new">New</span>`:""} <span class="chip ${l.type.toLowerCase()}">${l.type}</span>${l.warn?` <span class="chip warn">Arizona</span>`:""}</div>
     <div class="ctx">${esc(l.p)}${l.city?`, ${esc(l.city)}`:""}</div>
     <div class="acts">${l.justQ?`<button class="btn done" disabled>Qualified</button>`:`<button class="btn primary" data-qualify="${l.id}">Qualified</button><button class="btn" data-dq="${l.id}">Disqualified</button>`}</div></div>`).join("")
   :`<p class="lede">No new leads.</p>`;
}

/* replies */
function renderReplies(){
  const rp=openReplies();
  $("#reply-stats").innerHTML=`
   <div class="stat ${rp.length?"hot":""}"><b>${rp.length}</b><span>need your reply</span></div>
   <div class="stat"><b>${rp.length?Math.max(...rp.map(r=>r.age)):0} days</b><span>longest wait</span></div>
   <div class="stat"><b>${rp.filter(r=>r.promise).length}</b><span>things you promised</span></div>
   <div class="stat"><b>${followups.length}</b><span>you're waiting on</span></div>`;
  $("#replies").innerHTML=[...replies].sort((a,b)=>a.done-b.done||b.age-a.age).map(r=>`<div class="msg ${r.done?"done":""}">
    <div class="msg-top"><span class="who">${esc(r.who)}</span><span class="chip ${r.type}">${r.type==="seller"?"Seller":"Buyer"}</span>${r.deal?`<button class="chip" data-open="${r.deal}">${esc(dealById(r.deal).listing||r.biz)}</button>`:`<span class="chip">${esc(r.biz)}</span>`}${r.promise?`<span class="chip warn">You promised</span>`:""}<span class="age ${r.age>7?"late":""}">waiting ${r.age} days</span></div>
    <div class="subject">${esc(r.subj)}</div>
    <p class="quote">${esc(r.q)}</p>
    ${r.open&&!r.done?`<div class="draft">${esc(r.draft)}<div class="acts"><button class="btn primary" data-copy="${r.id}">Copy draft</button><button class="btn quiet" data-redo="${r.id}">Write it differently</button></div></div>`:""}
    <div class="acts">${r.done?`<button class="btn done" disabled>Replied</button>`:`<button class="btn ${r.open?"":"primary"}" data-draft="${r.id}">${r.open?"Hide draft":"Draft reply"}</button><button class="btn" data-replied="${r.id}">Mark replied</button>`}</div></div>`).join("");
  $("#followups").innerHTML=followups.map(f=>`<div class="msg"><div class="msg-top"><span class="who">${esc(f.who)}</span><button class="chip" data-open="${f.deal}">${esc(f.biz)}</button><span class="age ${f.age>30?"late":""}">asked ${f.age} days ago</span></div><p class="quote">${esc(f.what)}</p><div class="acts"><button class="btn" data-nudge="${f.id}">Draft a reminder</button></div></div>`).join("");
}

/* deals board */
function moveText(m){const d=dealById(m.deal);
  if(m.kind==="deal")return `<b>${esc(d.biz)}</b>: ${esc(LABEL[d.stage]||d.stage)} to <b>${esc(LABEL[m.to]||m.to)}</b>`;
  const o=d.offers.find(x=>x.b===m.buyer);return `<b>${esc(bare(m.buyer))}</b> on ${esc(d.biz)}: ${esc(o.st)} to <b>${esc(m.to)}</b>`;}
function moveRow(m){const d=dealById(m.deal);
  const name=m.kind==="deal"?d.biz:`${bare(m.buyer)}, ${d.biz}`;
  const from=m.kind==="deal"?(LABEL[d.stage]||d.stage):d.offers.find(o=>o.b===m.buyer).st;
  return `<tr><td class="deal">${esc(name)}</td><td><span class="from">${esc(from)}</span><span class="arrow">&rarr;</span><span class="to">${esc(LABEL[m.to]||m.to)}</span></td><td class="acts"><button class="btn primary" data-approve="${m.id}">Approve</button><button class="btn" data-skip="${m.id}">Not now</button></td></tr>`;}
function renderMoves(){
  const box=$("#moves");if(!moves.length){box.innerHTML="";return;}
  box.innerHTML=`<table class="mtable"><caption>Stage moves</caption><tbody>${moves.map(moveRow).join("")}</tbody></table>`;
}
function renderBoard(flash){
  renderMoves();
  $("#board").innerHTML=STAGES.slice(0,6).map(s=>{const list=deals.filter(d=>d.stage===s);
    const cls=(s==="Closed Won"?"won ":"")+(list.length?"":"empty");
    return `<div class="col ${cls}"><div class="col-head">${LABEL[s]||s}<span>${list.length}</span></div>${list.map(d=>{
      const on=d.offers.filter(o=>!o.out);
      return `<button class="card ${flash===d.id?"flash":""}" data-open="${d.id}">
        ${d.listing?`<div class="listing">${d.listing}</div>`:""}
        <div class="biz">${esc(d.biz)}</div>
        ${on.length?`<div class="buyers"><span class="dots">${on.map(o=>`<i class="dot ${o.backup?"backup":""}"></i>`).join("")}</span><span>${on.length} ${on.length>1?"buyers":"buyer"}</span></div>`:""}</button>`;}).join("")}</div>`;}).join("");
  const lost=deals.filter(d=>d.stage==="Closed Lost");
  $("#lost").innerHTML=lost.length?`Lost: ${lost.map(d=>`<button data-open="${d.id}">${esc(d.biz)}</button>`).join(", ")}`:"";
}

/* deal page */
function lane(o,d,fresh){
  const i=OSTAGES.indexOf(o.st),pct=i/5*83.34;
  const pending=moves.find(m=>m.kind==="offer"&&m.deal===d.id&&m.buyer===o.b);
  const person=(pool.find(p=>p.b===o.b)||{}).p||"";
  const sub=[person&&person!==bare(o.b)?person:"",o.amt?money(o.amt):""].filter(Boolean).join(", ");
  return `<div class="lane ${o.backup?"backup":""} ${o.out?"out":""} ${fresh?"fresh":""}">
    <div class="who"><b>${esc(bare(o.b))}</b><small>${esc(sub)}${o.backup?" <span class='chip'>Backup</span>":""}${o.out?" <span class='chip warn'>Withdrawn</span>":""}<span class="here-label">${o.out?"":"At "+esc(o.st)}</span></small></div>
    <div class="track" role="img" aria-label="${esc(bare(o.b))} at ${esc(o.st)}"><div class="fill" style="width:${pct}%"></div><div class="stops">${OSTAGES.map((s,k)=>`<i class="${k<i?"past":k===i?"here":""}" title="${esc(s)}"></i>`).join("")}</div></div>
    ${pending?`<div class="lane-move"><span class="from">${esc(o.st)}</span>&rarr;<b>${esc(pending.to)}</b><button class="btn primary" data-approve="${pending.id}">Approve</button></div>`:""}
  </div>`;
}
function renderDeal(id,freshBuyer){
  const d=dealById(id),si=STAGES.indexOf(d.stage);
  const on=[...d.offers].sort((a,b)=>(!!a.out-!!b.out)||(OSTAGES.indexOf(b.st)-OSTAGES.indexOf(a.st)));
  const sg=suggestions(d),pendingDeal=moves.find(m=>m.kind==="deal"&&m.deal===d.id);
  $("#deal").innerHTML=`<button class="back" data-back>Back to deals</button>
   <div class="deal-head ${d.listing?"":"no-listing"}">
     ${d.listing?`<div class="big-listing">${d.listing}</div>`:""}
     <div><div class="deal-name">${esc(d.biz)}</div><div class="deal-facts">${esc(d.seller)}, ${esc(d.city)}</div></div>
     <div class="deal-money">${d.ask?`<div class="amt">${money(d.ask)}</div><div class="fee">${money(Math.round(d.ask*.125))} fee</div>`:""}</div>
   </div>
   ${d.stage==="Closed Lost"?`<p class="lede" style="margin-top:14px">This deal is lost.</p>`:`<div class="seller-track">${STAGES.slice(0,6).map((s,k)=>`<div class="${k<=si?"on":""} ${k===si?"now":""}">${LABEL[s]||s}</div>`).join("")}</div>`}
   ${pendingDeal?`<table class="mtable"><tbody>${moveRow(pendingDeal)}</tbody></table>`:""}
   <div class="deal-grid">
     <div>
       <div class="section-head"><h3>Buyers</h3></div>
       ${on.length?`<div class="lanes"><div class="lane-scale"><span></span><div class="scale">${OSHORT.map(s=>`<span>${s}</span>`).join("")}</div></div>${on.map(o=>lane(o,d,o.b===freshBuyer)).join("")}</div>`
        :`<p class="lede" style="margin-top:8px">None yet.</p>`}
       ${d.stage==="Closed Lost"?"":`<div class="suggested">
         <div class="section-head"><h3>Suggested</h3></div>
         ${sg.length?sg.slice(0,4).map(s=>`<div class="s-row"><div class="who"><b>${esc(bare(s.b))}</b><span class="fit ${s.strong?"strong":"possible"}">${s.strong?"Strong fit":"Possible fit"}</span></div>
            <div class="why">${esc(s.fact)}</div>
            <button class="btn" data-add="${esc(s.b)}">Add</button></div>`).join("")
          :`<p class="muted" style="margin:6px 0 0;font-size:14px">No matches yet.</p>`}
       </div>`}
     </div>
     <div class="side">
       <div class="panel"><h3>Emails</h3>${d.mail.length?d.mail.map(m=>`<div class="mail"><div class="d">${m.d}</div>${esc(m.t)}</div>`).join(""):`<p class="muted" style="margin:0">No emails yet.</p>`}</div>
     </div>
   </div>`;
  $("#deal").dataset.id=id;
}

/* buyers and lenders */
function renderBuyers(){
  $("#buyers").innerHTML=`<thead><tr><th>Buyer</th><th>Wants</th><th>On deals</th></tr></thead><tbody>${pool.map(p=>{
    const on=deals.flatMap(d=>d.offers.filter(o=>o.b===p.b).map(o=>`${d.biz}: ${o.out?"withdrawn":o.st}${o.backup?" (backup)":""}`));
    return `<tr><td>${esc(bare(p.b))}<span class="sub">${esc(p.p)}</span></td><td>${esc(p.wants.join(", ").replace("Any","Any industry"))}<span class="sub">${esc(p.money)}</span></td><td>${on.length?on.map(esc).join("<br>"):"<span class='muted'>None yet</span>"}</td></tr>`;}).join("")}</tbody>`;
  $("#lenders").innerHTML=`<thead><tr><th>Lender</th><th>What they fund</th><th>Last in touch</th><th></th></tr></thead><tbody>${lenders.map(l=>`<tr><td>${esc(l.b)}<span class="sub">${esc(l.p)}</span></td><td>${esc(l.does)}</td><td>${esc(l.last)}</td><td>${l.due?`<span class="chip lender">Check in due</span>`:""}</td></tr>`).join("")}</tbody>`;
}

/* navigation and actions */
function show(view){document.querySelectorAll(".tab").forEach(t=>t.setAttribute("aria-selected",t.dataset.view===view));document.querySelectorAll(".view").forEach(v=>v.hidden=v.id!=="v-"+view);}
function openDeal(id,fresh){renderDeal(id,fresh);$("#board-wrap").hidden=true;$("#deal").hidden=false;show("deals");window.scrollTo({top:0});}
function closeDeal(flash){$("#deal").hidden=true;$("#board-wrap").hidden=false;renderBoard(flash);}
function refresh(){badges();renderToday();renderLeads();renderReplies();renderBuyers();if($("#deal").hidden)renderBoard();else renderDeal($("#deal").dataset.id);}
function applyMove(m){const d=dealById(m.deal);if(m.kind==="deal")d.stage=m.to;else d.offers.find(o=>o.b===m.buyer).st=m.to;moves=moves.filter(x=>x.id!==m.id);return d;}

document.addEventListener("click",e=>{
  const t=e.target.closest("button");if(!t)return;const ds=t.dataset;
  if(t.classList.contains("tab")){show(ds.view);if(ds.view==="deals")closeDeal();}
  else if(ds.go){show(ds.go);if(ds.go==="deals")closeDeal();}
  else if(ds.open){$("#toast").classList.remove("show");openDeal(ds.open);}
  else if(ds.back!==undefined){closeDeal();}
  else if(ds.qualify){const l=leads.find(x=>x.id==ds.qualify);l.status="Qualified";l.justQ=true;
    if(l.type==="Seller"){const id="new"+l.id;deals.push({id,biz:l.n,ind:l.ind,city:l.city,seller:l.p,stage:"Qualified",listing:"",offers:[],mail:[{d:"Today",t:`Deal created when you marked ${l.p} qualified`}]});
      toast(`Deal created: ${esc(l.n)} in Qualified <button data-open="${id}">Open deal</button>`);}
    else{pool.push({b:l.n,p:l.p,wants:[l.ind],fact:l.ctx,money:""});toast(`${esc(l.n)} marked qualified and added to Buyers`);}
    refresh();}
  else if(ds.dq){const l=leads.find(x=>x.id==ds.dq);l.status="Disqualified";toast(`${esc(l.n)} disqualified`);refresh();}
  else if(ds.draft){const r=replies.find(x=>x.id==ds.draft);r.open=!r.open;renderReplies();}
  else if(ds.copy){navigator.clipboard?.writeText(replies.find(x=>x.id==ds.copy).draft).catch(()=>{});toast("Draft copied. Paste it into Gmail to send.");}
  else if(ds.redo){toast("ChatGPT would write a new version here.");}
  else if(ds.replied){const r=replies.find(x=>x.id==ds.replied);r.done=true;r.open=false;toast(`Marked replied: ${esc(r.who)}`);refresh();}
  else if(ds.nudge){const f=followups.find(x=>x.id==ds.nudge);toast(`Reminder drafted for ${esc(f.who)} in the chat below`);}
  else if(ds.approve){const m=moves.find(x=>x.id==ds.approve);if(!m)return;const name=m.kind==="deal"?dealById(m.deal).biz:bare(m.buyer);const d=applyMove(m);
    toast(`Moved: ${esc(name)} to ${esc(LABEL[m.to]||m.to)}`);badges();renderToday();if($("#deal").hidden)renderBoard(d.id);else renderDeal(d.id);}
  else if(ds.approveAll!==undefined){const first=moves[0]?.deal,n=moves.length;[...moves].forEach(applyMove);toast(`${n} moves applied`);badges();renderToday();renderBoard(first);}
  else if(ds.skip){moves=moves.filter(x=>x.id!=ds.skip);badges();renderToday();renderBoard();}
  else if(ds.add){const d=dealById($("#deal").dataset.id);d.offers.push({b:ds.add,st:"Inquiry",note:"Added from suggestions today"});
    toast(`Offer created: ${esc(bare(ds.add))} on ${esc(d.biz)}, at Inquiry`);renderDeal(d.id,ds.add);renderBuyers();renderBoard();}
});

refresh();
const h=location.hash.slice(1);
if(h.startsWith("deal="))openDeal(h.slice(5));else if(h.startsWith("view-")){show(h.slice(5));if(h==="view-deals")closeDeal();}else if(["leads","replies","deals","buyers","lenders"].includes(h)){show(h);if(h==="deals")closeDeal();}
</script>
</body>
</html>
```
