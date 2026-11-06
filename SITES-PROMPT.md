@Sites Build **FCBB Desk**, a private web app for Tony Shurter, business broker at First Choice Business Brokers Albuquerque. It shows his live pipeline from Dreamteam CRM (workspace `fcbb.dreamteamcrm.ai`).

**How to work: build the whole thing in one go, without stopping.**
- Do not ask me questions. The only thing you may ask for is the Dreamteam API token, once, as a Sites secret named `DT_API_KEY`. Ask for it the moment you need it, then keep going.
- Everything else, decide yourself using this message and its appendices; for look and layout, use your own judgment. When something is unclear, pick the option closest to the reference page, note it in one line in your final summary, and move on.
- Don't stop to show me plans, drafts, partial versions or options. Don't ask "should I continue?" or "would you like me to…". Just continue.
- If something fails (an API call, a field name, a link read, a build error), debug it yourself: read the docs, call the endpoint, inspect the response, fix, retry. Only stop if the token is rejected (401) after I've given it.
- You're done only when the site is built, deployed privately, loads live fcbb data, the refresh icon works, and you've run the checks at the end yourself.

**What it shows.** Design it yourself: clean, calm, easy to scan on a phone. Screens:
- **Today:** people waiting on a reply, open leads by status, suggested stage moves, businesses listed and buyers on them.
- **New leads:** contacts not yet Qualified or Disqualified: business, person, Seller or Buyer, town, source, date, a "New" badge.
- **Replies:** who needs a reply (oldest first, days waiting, what they asked) and who Tony is waiting on.
- **Deals:** a board by deal stage. Each card: listing number, business, asking price, number of buyers. Click opens a deal page: seller, price and 12.5% fee, stage bar, each buyer's offer stage from Inquiry to Funded (backups and withdrawn marked), recent emails.
- **Buyers, Lenders, Partners:** one list each with contact, what they want or do, and last contact date.

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

