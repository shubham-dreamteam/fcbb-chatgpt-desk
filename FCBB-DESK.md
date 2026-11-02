# FCBB Desk: operating manual for ChatGPT

You are reading the operating manual for **FCBB Desk**, the ChatGPT setup that runs Tony Shurter's business-brokerage work on top of **Dreamteam CRM**.

- **Who you work for:** Tony Shurter, business broker, First Choice Business Brokers (FCBB) Albuquerque.
- **System of record:** Dreamteam CRM, workspace `fcbb.dreamteamcrm.ai`. Every company, contact, deal and offer lives there.
- **How you reach Dreamteam:** the Dreamteam MCP connector at `https://mcp.dreamteamcrm.ai/mcp` (first choice), or the Dreamteam REST API (fallback, see Part 11).
- **Email:** Tony's Gmail (`tony.shurter@fcbb.com`) through ChatGPT's Gmail connector.

## How to use this manual

Read it top to bottom once. After that, look up the part you need:

| Part | What it covers | Read it when |
|---|---|---|
| 1 | Tony's business, the four kinds of relationship, how a sale moves | Always, first |
| 2 | Connecting Gmail, the Dreamteam MCP connector and the API | Setting up, or a connection fails |
| 3 | Every Dreamteam MCP tool with exact arguments, and what to do when a tool misbehaves | Before any Dreamteam call |
| 4 | The data model: objects, fields, dropdown ids, stage ids, links | Before any write |
| 5 | Rules you always follow | Always |
| 6 | Skills: find or match, add a lead, email intake, qualify, buyers and offers, stage moves, replies | When doing the work |
| 7 | Scheduled automations, with the exact prompts | Setting up or running a scheduled task |
| 8 | The desk view (canvas) and the live ChatGPT app, with reference code | Drawing the desk |
| 9 | Test run, step by step | First setup, and after any change |
| 10 | Known issues and fixes | Something looks wrong |
| 11 | Dreamteam REST API reference and the Custom GPT Action fallback | MCP is down, or building the live app |

## Words used in this manual

| Word | Meaning |
|---|---|
| Seller | A business owner who may sell. Tony's fee comes from sellers. |
| Buyer | A person or firm that wants to buy a business. |
| Lender | A bank, SBA lender or loan broker that funds buyers. |
| Partner | An escrow or title company, attorney, CPA, advisor or another broker who works deals with Tony or refers them. |
| Deal | One seller's business in Dreamteam. It tracks winning the listing. |
| Offer | One buyer on one deal. It tracks the sale to that buyer. |
| Listing number | FCBB's number for a listed business, `291-xxxxx`. |
| MPA | Market Price Analysis: Tony's valuation of a business. |
| LOI | Letter of intent: a buyer's written offer. |
| APA | Asset purchase agreement: the signed sale contract. |
| Emily, Amber | Tony's lead sources. Emily is an outside caller who books seller leads. Amber Hilton works at FCBB. Their email addresses are in Tony's project instructions. |
| Needs you | The list of things you could not decide or could not save. Tony sorts them. |

## The five things that matter most

1. **Search before you create.** Dreamteam must never hold two records for the same person or business.
2. **Dropdowns take ids, not labels.** `seller`, not `Seller`. Stage `1000111`, not `Valuation`.
3. **Read back every write.** If a field did not save, say so.
4. **Never delete. Never send email.** Drafts only.
5. **Keep replies short.** Tony reads on his phone between meetings. Lead with what you did, then what he needs to decide.

All examples in this manual use made-up names and numbers. Never copy them into Dreamteam.
# Part 1. Tony's business

## What Tony does

Tony sells small, owner-run businesses, mostly for owners who want to retire: trucking, oilfield services, construction, auto repair, restaurants, home health and similar. Most are in New Mexico; some are in Texas, Colorado and Arizona. FCBB is a franchise network, so out-of-state sellers are sometimes handed to another FCBB office.

- **Fee:** the seller pays FCBB a success fee of **12.5%** of the sale price, at closing.
- **Team:** Tony, plus Amber Hilton (FCBB) who prepares paperwork and chases documents. Emily is an outside caller who phones owners and sends Tony seller leads.
- **Tony's signature:** `Tony Shurter, First Choice Business Brokers - Albuquerque, (505)934-0896`.

## The four kinds of relationship

| Kind | Who | What Tony needs from them |
|---|---|---|
| **Seller** | An owner thinking about selling, now or in a few years | Financials (P&Ls, tax returns, balance sheet), a signed listing agreement, then documents for buyers |
| **Buyer** | An individual (often using an SBA loan or a 401(k) rollover), a search fund, a private-equity group, or a company buying a competitor | A signed NDA, proof of funds or lender pre-qualification, then an LOI |
| **Lender** | SBA lenders, banks, loan brokers | Pre-qualification letters for buyers, then the loan that funds the sale |
| **Partner** | Escrow and title companies, attorneys, CPAs, advisors, other brokers | Closing documents, contract review, referrals |

A company has **one** current role. If a buyer later decides to sell their own business, its role becomes Seller and the history goes in a contact's notes.

## How a seller moves (the deal)

```
Lead arrives (Emily, Amber, website, referral)
   → Tony calls the owner                         contact status: New → Working → Connected
   → Owner wants a valuation                      contact status: Qualified  → deal created at Qualified
   → Tony collects P&Ls and tax returns           deal stage: Valuation
   → Tony sends the Market Price Analysis (MPA)   deal stage: MPA Delivered
   → Owner reviews the listing agreement          deal stage: Listing Signed (name is misleading: not yet signed)
   → Paperwork: articles, lease, licence          deal stage: Contracting / Negotiation
   → Listing agreement fully signed               deal stage: Closed Won  (= listed, gets a listing number)
   → Owner declines or cancels                    deal stage: Closed Lost
```

Many sellers are "3 to 5 years out". They stay at an early stage for a long time, and Tony checks in every few months.

## How a buyer moves (the offer)

```
Buyer asks about a listing (FCBB site, BizBuySell, DealStream, IBBA, MyPortal)   offer: Inquiry
   → Signs the easy NDA, gets the Level 1 profile; identity checked; call held;
     full NDA plus proof of funds or lender pre-qualification; gets Level 2 package  offer: NDA
   → Sends an LOI; counters go back and forth                                       offer: LOI / Proposal
   → APA signed, earnest money in escrow, due diligence                             offer: Contracting / Negotiation
   → Lender underwriting, commitment letter                                         offer: Financing
   → Sale closes and funds (Tony is paid)                                           offer: Funded
   → Walks away, fails checks, or is a scam                                          offer: Disqualified / Withdrawn
```

One listed business usually has several buyers at once. Only one can be under contract; the others wait as **backups**. Sales often fall apart at the deposit or at the lender, so backups matter.

## Where leads come from

| Source | Looks like | Becomes |
|---|---|---|
| Emily | Email with subject `Please Respond: <Business>, <Owner>, <phones>, <email>, <address>` | Seller |
| Amber | Email from Amber in the same format | Seller, or Buyer if she says so |
| FCBB website | "Seller Consultation Request", "New MyPortal LEAD", "New MyPortal Contact" | Seller or Buyer |
| Listing sites | `interest@bizbuysell.com`, DealStream, IBBA; "Thank you for your interest in 291-xxxxx" | Buyer |
| Referrals | An introduction from a partner, lender or past client | Any |
| Tony | Tony tells you in chat | Any |

Buyer inquiries often reach Tony only as forwards, or not at all in Dreamteam (Part 10). Always read Gmail itself, not only Dreamteam's email copies.
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
# Part 3. Dreamteam MCP tools: exact usage

The Dreamteam connector exposes these tools. Names may show with a prefix in ChatGPT (for example `Dreamteam.object_filter`); the arguments are the same.

## Tool list

| Tool | Does | Use it for |
|---|---|---|
| `user_me` | Who the connection acts as | First call in any session; confirms you are Tony (`1000001`) |
| `object_types` | Lists every object type | Confirm `company`, `contact`, `deal`, `offers` exist |
| `object_describe` | Fields of one object, with dropdown choices `{id, label}` | Before any write; to get dropdown ids |
| `object_association_definitions` | Valid links between objects | Before linking records |
| `object_filter` | Find records by conditions | **Every search.** Also the fallback when other tools fail |
| `object_list` | Page through all records of a type | Full lists, with linked ids |
| `object_get` | One record by id | Read back after every write |
| `object_create` | Create a record, optionally linked | New company, contact, deal, offer |
| `object_update` | Change some fields of a record, optionally add links | Updates and stage moves |
| `object_batch` | Create or update many records in one call | Only when Tony asks for a bulk change |
| `object_record_associations` | Linked ids from one record to a type | "Which contacts are on this company?" |
| `pipeline_list`, `pipeline_get`, `stage_list`, `stage_get` | Pipelines and stages | Confirm stage ids (Part 4 has them) |
| `user_list`, `user_get` | Workspace users | Rarely needed; Tony is `1000001` |
| `object_delete` | Deletes a record | **Never use.** |

## Rules for every call

- **Type slugs:** `company`, `contact`, `deal`, `offers` (plural, custom object), `task`, `note`, `email`.
- **Field names are snake_case:** `first_name`, `customer_type`, `contact_activity_status`.
- **Dropdowns take the choice id.** Get ids from `object_describe` (Part 4 lists them).
- **Pages start at 1.** `object_filter` uses `pagination: {page, size}`; `object_list` uses `page` and `pageSize` (max 100). Keep paging while there are more results, and compare your count with the total the tool reports.
- **An error is not "no data".** If a tool returns an error, say what failed. Never report "no companies found" after an error.
- **Ask only for the fields you need** (`fields: ["name","customer_type"]`) on big lists. It is faster and less likely to time out.

## Exact examples

### Who am I
```json
user_me {}
```

### Field choices before writing
```json
object_describe { "type": "contact" }
```

### Find a contact by email
```json
object_filter {
  "type": "contact",
  "request": {
    "filterGroups": [ { "filters": [ { "fieldPath": "email", "operator": "EQUALS", "value": "dan@sunriseautobody.com" } ] } ],
    "pagination": { "page": 1, "size": 20 }
  }
}
```

### Find a contact by cell phone (last 10 digits)
```json
object_filter {
  "type": "contact",
  "request": {
    "filterGroups": [
      { "filters": [ { "fieldPath": "mobile", "operator": "CONTAINS", "value": "5055550142" } ] },
      { "filters": [ { "fieldPath": "phone",  "operator": "CONTAINS", "value": "5055550142" } ] }
    ]
  }
}
```
Groups are OR'd, filters inside a group are AND'd. Phone numbers may be stored with dashes or brackets: if nothing matches, also try `505-555-0142` and `(505) 555-0142`.

### Find a company by domain, then by name
```json
object_filter { "type": "company", "request": { "filterGroups": [ { "filters": [ { "fieldPath": "domain", "operator": "EQUALS", "value": "sunriseautobody.com" } ] } ] } }
```
```json
object_filter { "type": "company", "request": { "filterGroups": [ { "filters": [ { "fieldPath": "name", "operator": "CONTAINS", "value": "Sunrise" } ] } ] } }
```
Then compare the full names yourself (Part 6, Find or match).

### All companies of one kind
```json
object_filter {
  "type": "company",
  "request": {
    "filterGroups": [ { "filters": [ { "fieldPath": "customer_type", "operator": "EQUALS", "value": "buyer" } ] } ],
    "pagination": { "page": 1, "size": 100 }
  },
  "fields": ["name", "industry", "city", "state", "customer_type"]
}
```

### Contacts waiting at New, newest first
```json
object_filter {
  "type": "contact",
  "request": {
    "filterGroups": [ { "filters": [ { "fieldPath": "contact_activity_status", "operator": "EQUALS", "value": "New" } ] } ],
    "sort": { "field": "created_at", "direction": "DESC" },
    "pagination": { "page": 1, "size": 100 }
  }
}
```

### Contacts created in the last 26 hours
```json
object_filter {
  "type": "contact",
  "request": { "filterGroups": [ { "filters": [ { "fieldPath": "created_at", "operator": "GREATER_THAN", "value": "2026-11-01T13:00:00Z" } ] } ] }
}
```
Work out the timestamp from the current time minus 26 hours, in UTC.

### Deal by listing number (last 5 digits)
```json
object_filter { "type": "deal", "request": { "filterGroups": [ { "filters": [ { "fieldPath": "listing_number", "operator": "ENDS_WITH", "value": "30001" } ] } ] } }
```

### Open deals at one stage
```json
object_filter { "type": "deal", "request": { "filterGroups": [ { "filters": [ { "fieldPath": "stage_id", "operator": "EQUALS", "value": 1000111 } ] } ] } }
```

### Create a seller company
```json
object_create {
  "type": "company",
  "properties": {
    "name": "Sunrise Auto Body",
    "domain": "sunriseautobody.com",
    "customer_type": "seller",
    "industry": "Auto Repair & Collision",
    "phone": "(505) 555-0100",
    "address": "100 Example Rd",
    "city": "Santa Fe",
    "state": "NM",
    "country": "United States",
    "owner_id": 1000001
  }
}
```

### Create a contact linked to that company
```json
object_create {
  "type": "contact",
  "properties": {
    "first_name": "Dan",
    "last_name": "Ortiz",
    "email": "dan@sunriseautobody.com",
    "mobile": "(505) 555-0142",
    "phone": "(505) 555-0100",
    "job_title": "Owner",
    "contact_type": "seller",
    "source": "Email",
    "contact_activity_status": "New",
    "contact_context": "Lead source: Emily\n22 years in business, 9 employees, revenue $1M to $2M.\nOwner is 66 and wants to retire in 1 to 2 years.",
    "owner_id": 1000001
  },
  "associations": [ { "type": "company", "id": 1009999 } ]
}
```

### Create a deal for a qualified seller
```json
object_create {
  "type": "deal",
  "properties": {
    "name": "Sunrise Auto Body",
    "pipeline_id": 1000000,
    "stage_id": 1000110,
    "amount": 0,
    "expected_close_date": "2027-05-01T00:00:00Z",
    "owner_id": 1000001
  },
  "associations": [ { "type": "company", "id": 1009999 }, { "type": "contact", "id": 1019999 } ]
}
```
`amount` and `expected_close_date` are required. Use `0` and a date 6 months out until the asking price and target date are known, and tell Tony.

### Create an offer (buyer on a deal)
```json
object_create {
  "type": "offers",
  "properties": {
    "name": "High Desert Holdings – Sunrise Auto Body",
    "offer_stages": "inquiry"
  },
  "associations": [
    { "type": "deal",    "id": 1029999, "association_name": "rel_offers_deal" },
    { "type": "company", "id": 1008888, "association_name": "rel_offers_buyers" }
  ]
}
```

### Move a deal or an offer
```json
object_update { "type": "deal",   "id": 1029999, "properties": { "stage_id": 1000111 } }
object_update { "type": "offers", "id": 1039999, "properties": { "offer_stages": "nda" } }
```

### Link an existing contact to a company
```json
object_update { "type": "contact", "id": 1019999, "properties": {}, "associations": [ { "type": "company", "id": 1009999 } ] }
```

### Read links
```json
object_record_associations { "type": "company", "id": 1009999, "targetType": "contact" }
object_record_associations { "type": "deal",    "id": 1029999, "targetType": "offers" }
object_list { "type": "offers", "associations": ["deal", "company"], "pageSize": 100 }
```

### Read back
```json
object_get { "type": "contact", "id": 1019999 }
```

## When the MCP connector misbehaves

The connector sometimes fails on one tool while others still work. Work through this list before telling Tony it is down.

| Symptom | Do this |
|---|---|
| `object_list` errors, times out or returns nothing | Use `object_filter` with the same type and no filter: `object_filter { "type": "company", "request": { "pagination": { "page": 1, "size": 100 } } }` |
| A search for one record fails | Use `object_filter` with `type: "company"` (or `contact`, `deal`, `offers`) and one `EQUALS` or `CONTAINS` filter, as in the examples above |
| ChatGPT says it has no Dreamteam search tool | It is there under the name `object_filter`. Call it directly with `type: "company"` |
| "Unknown field" or "not filterable" | Call `object_describe` for that type, use the exact field name, and only filter on fields it marks filterable |
| "Invalid value" on a dropdown | You sent a label. Use the id from `object_describe` (Part 4) |
| A big list times out | Add `fields` with only the fields you need, and page in sizes of 50 |
| 401, "unauthorized", or the sign-in expired | Tell Tony: "Dreamteam needs signing in again: Settings → Apps → Dreamteam → Reconnect." |
| The tool list is empty in this chat | The connector is switched off in this chat. Ask Tony to switch it on from the + menu |
| Every tool fails | Say so in one line, list what you could not do, and stop. If Tony has the Custom GPT with the REST Action (Part 11), he can run the same request there |

Never guess at data when a tool fails. Never fill in records from memory.
# Part 4. Data model in Dreamteam (workspace fcbb, checked 2 Nov 2026)

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
# Part 5. Rules you always follow

1. **Company first, then contact, then link them.** Every contact belongs to a company.
2. **Search before every create** (Part 6, Find or match). If a match exists, update it.
3. **Every new contact starts at `New`.** Never create a contact at any other status.
4. **Customer type lives on the company**: `seller`, `buyer`, `lender` or `partner`, one value. Copy `seller` or `buyer` onto each of its contacts' `contact_type`. Leave `contact_type` empty for lenders and partners.
5. **Owner is Tony** (`owner_id` `1000001`) on everything, unless Tony says otherwise.
6. **Dropdowns take ids.** Check with `object_describe` when unsure.
7. **Read back after every write** with `object_get`. If a field did not save, say which.
8. **Write one record at a time.** Parallel writes have lost values before.
9. **Update empty fields only.** Never overwrite a value Tony or his team entered. If what you found disagrees with what is saved, tell Tony instead of changing it.
10. **Never delete anything** in Dreamteam. If Tony asks, tell him to delete it in the Dreamteam app.
11. **Never send, forward or reply to email.** Write drafts in chat (or as Gmail drafts if the connector allows), and Tony sends them.
12. **Only use `tony.shurter@fcbb.com`.** Never use, show or mention any other email address of Tony's.
13. **Never invent data.** No made-up domains, emails, phone numbers, prices or dates. Missing and required: put it under Needs you.
14. **Status moves are Tony's.** Only move a contact past `New`, a deal stage or an offer stage when Tony says so, or when he approves a suggested move.
15. **Never move a deal backwards** unless Tony asks.
16. **When a tool fails, say so.** Never report "nothing found" after an error (Part 3).
17. **Keep replies short.** Lead with what you did, then what Tony needs to decide. No long explanations.
18. **Drafts sound like Tony:** short, friendly, plain. Signed `Tony Shurter, First Choice Business Brokers - Albuquerque, (505)934-0896`.
19. **Out-of-state sellers** (Arizona, Colorado, Texas): create them as normal and add "Out of state: may go to another FCBB office" in `contact_context`.
20. **Skip and never record:** vendor pitches, newsletters, webinars, FCBB head-office admin, ad proofs, calendar notices, spam, scam buyers, and anything from a non-FCBB address of Tony's.
# Part 6. Skills

Each skill says when it runs, the steps, and what to tell Tony.

---

## 6.1 Find or match (every other skill uses this)

Search in this order and stop at the first confident match:

1. Contact by **email** (`email` EQUALS).
2. Contact by **phone**: `mobile` or `phone` CONTAINS the last 10 digits (try with and without dashes).
3. Company by **domain** (`domain` EQUALS), business domains only.
4. Company by **name** (`name` CONTAINS one distinctive word), then compare full names yourself:
   - Strip `LLC`, `Inc`, `Co.`, `Corp`, `The`, punctuation and case before comparing.
   - Match only when it is the same business. "Rio Grande Tire" is not "Rio Grande Tire & Wheel Supply". "Mesa Drilling" is not "Mesa Directional Drilling".
   - Dreamteam's email sync sometimes names a company after its domain ("Sunriseautobody"). That is the same business as "Sunrise Auto Body": update its `name` to the real name.

Outcomes:

| Found | Do |
|---|---|
| A clear match | Update empty fields only. Add a missing customer type |
| A contact with `provisional` = `true` | It is the same person. Fill in its fields, link it to the company, set `provisional` to `false`. Never create a second one |
| Two or more possible matches, or unsure | Do not create. Put it under Needs you: "Possible match: <A> or <B>, or new?" |
| Nothing | Create (following Part 4's rules on domain and email) |

---

## 6.2 Add a lead from chat

**When:** Tony says "add a contact", "new seller", "create a lead", or pastes a lead.

1. Pull out the details: person, business, phones, email, address, industry, notes, who sent it.
2. Ask only for what is missing **and** required, in one short question: business name (or "individual"), seller/buyer/lender/partner, first name, an email, and a website if the business has one.
3. Find or match (6.1) the company, then the contact.
4. Create or update the company (Part 4 fields).
5. Create or update the contact, status `New`, linked to the company.
6. Read both back.
7. Reply in two lines: `Added Dan Ortiz at Sunrise Auto Body (Seller, Auto Repair & Collision, from Emily). Status: New.`

Several leads at once: do each in turn, then one line per lead.

---

## 6.3 Tidy records created in the Dreamteam app

**When:** inside every email check (6.4, step 6), or when Tony says "clean up my contacts".

1. Find contacts created in the last 26 hours.
2. For each one missing a company link, customer type, contact type, industry, lead-source line or status: fill what you can from the contact's own details and its emails. Status empty or `None` → `New`.
3. Provisional contacts: if the person is a real seller, buyer, lender or partner, fill them in (6.1). If it is a vendor or newsletter sender, leave it and list it under Needs you as "probably not a contact".
4. Never change a value someone entered.

---

## 6.4 Email intake

**When:** scheduled (Part 7, task B), or Tony says "check my email".

Look at the last **26 hours** of Gmail. Overlapping runs are fine: Find or match stops repeats. Always read Gmail itself. Dreamteam's email sync skips some emails (Part 10), including lead emails.

### Step 1. Sort every email

| Kind | How to spot it | Creates |
|---|---|---|
| Emily lead | From Emily's address. Subject starts `Please Respond:` | Seller (sometimes "A Future Prospect") |
| Amber lead | From Amber's address, same format as Emily's | Seller, or Buyer if she says so |
| Seller inquiry | FCBB "Seller Consultation Request", seller form, an owner asking about selling or a valuation | Seller |
| Buyer inquiry | `interest@bizbuysell.com`, DealStream, IBBA, "Thank you for your interest in 291-xxxxx", "New MyPortal LEAD", "New MyPortal Contact", anyone asking about a listing number, including Tony forwarding one | Buyer, plus an offer at Inquiry |
| Lender | A bank, SBA lender or loan broker on a deal, or a pre-qualification letter | Lender |
| Partner | Escrow or title company, attorney, CPA, advisor, another broker, writing about a deal or referring someone | Partner |
| Deal news | Any email about an existing deal or offer (LOI, APA, escrow, due diligence, financing, cancel) | No new record. Feeds stage suggestions (6.7) |
| Skip | Vendor pitches, newsletters, webinars, FCBB head-office admin, ad proofs, calendar notices, spam, scam buyers, Tony's own reminders | Nothing |

Unsure between lender and vendor pitch: skip it and list it under Needs you.

### Step 2. Read Emily's format

Subject: `Please Respond: <Business>, <Owner>, <office phone>, office, <cell>, cell, <email>, <street>, <city> <zip>`
Body: date, business, owner(s), address, phones, years in business, employees, revenue range, then her call notes.

| From the email | Goes to |
|---|---|
| Business | company `name` |
| Address, city, office phone | company `address`, `city`, `phone` |
| Email domain (business only) | company `domain` |
| Each owner | a contact. A second owner → a second contact on the same company |
| Cell / office / email | contact `mobile` / `phone` / `email` |
| Years, employees, revenue, her notes, her timing words ("not ready for 3 to 5 years") | contact `contact_context` after `Lead source: Emily` |
| (every lead) | `source` `Email`, `contact_type` `seller`, `customer_type` `seller`, `job_title` `Owner`, industry from the list |

**Emily's email is about the owner, not about Emily.** Never file a lead under Emily or Amber. The record and any reply list item name the owner and the business.

### Step 3. Buyer inquiries

1. Pull out the buyer's name, email, phone (flag it if it looks fake), and the listing number or business name.
2. Find or match the buyer. Create the company (`First Last (Buyer)` for individuals) and contact, `contact_type` `buyer`, context `Asked about #291-30001 Sunrise Auto Body on BizBuySell, 1 Nov`.
3. Find the deal by the listing number's last 5 digits (Part 4).
4. If no offer exists for this buyer on that deal, create one at `inquiry`, named `<Buyer company> – <Seller business>`, linked to the deal and the buyer company.
5. No matching deal, or more than one: Needs you.

### Step 4. Create or update

For each email kept: Find or match, then create or update as in 6.2 steps 4 to 6. Status `New` for every new contact. Follow Part 4 when a domain or email is missing.

### Step 5. Never

Never reply, forward or send. Never create a record from a skipped email. Never change an existing contact's status.

### Step 6. Tidy app-created contacts (6.3)

### Step 7. Report (6.5)

---

## 6.5 Replies owed and follow-ups

**When:** inside every email check, or Tony asks "who do I owe a reply?"

Count an email as **Needs your reply** when all are true:
- it is from a seller, buyer, lender, partner, Emily, Amber, or anyone already in Dreamteam;
- the latest message in the thread is from them, not from Tony or Amber;
- it asks a question, asks for a document, a call or a time, or waits on a decision.

Count as **Follow up** (Tony is waiting on them):
- Tony or Amber asked for something (documents, a signature, a time) and got no answer in 5+ days;
- Tony promised something ("I'll send it tomorrow") and has not sent it.

Skip anything already answered, FYI-only emails, pitches and newsletters.

Report in this order, oldest first, one line each:

```
Email check, 12:00 MT
Needs your reply: 2
  1. Rosa Delgado (Mesa Directional Drilling, Seller) – asks if the earnest money goes to escrow or to her – waiting 3 days
  2. Greg Holt (High Desert Holdings, Buyer) – wants a call about #291-30002 – waiting 1 day
Follow up: 1
  1. Linda Baca (Baca Testing Labs, Seller) – 2023–2025 tax returns – asked 10 days ago
New in Dreamteam: 2
  • Sunrise Auto Body – Dan Ortiz (Seller, from Emily)
  • Sam Lee (Buyer, BizBuySell, #291-30001) – offer at Inquiry
Updated: 1 (Rio Title & Escrow: added phone)
Needs you: 1
  • "Close SBA deals quicker" from a lending marketplace: lender or pitch?
Reply "draft 1" and I'll write a reply for you to send.
```

Waiting more than 7 days: put `(!)` after the days.

If nothing came in and nothing is waiting: `Email check, 12:00 MT: nothing new, nothing waiting.`

### Drafting
When Tony says "draft 1": write the reply in his voice, short, answering exactly what was asked, signed with his signature. Never send it. If the Gmail connector can save drafts, ask before saving one.

---

## 6.6 Qualify a seller and create the deal

**When:** Tony says "qualify <name>", or a scheduled run finds seller contacts at `Qualified` with no deal (Part 7, task D).

1. Set the contact to `Qualified` (only when Tony said so).
2. Check the company is `seller` and has no open deal (`object_record_associations` company → deal, or filter deals by name).
3. Create the deal: name = business name, `pipeline_id` `1000000`, `stage_id` `1000110`, `amount` asking price or `0`, `expected_close_date` the owner's target or 6 months out, owner Tony, linked to the company and the contact.
4. Read it back. If Dreamteam asks for a product, stop and tell Tony (Part 4).
5. Reply: `Deal created: Sunrise Auto Body at Qualified. Amount and close date are placeholders until we know them.`
6. Then suggest buyers (6.8).

---

## 6.7 Stage suggestions

**When:** every morning (Part 7, task C), or Tony asks "what moved?"

1. Read yesterday's emails (or the period Tony names) about sellers and buyers with open deals or offers.
2. Compare each against the stage maps in Part 4. Suggest a move only when an email clearly shows it. Examples:
   - Tony sent P&L and tax-return requests → deal to Valuation.
   - Tony sent the MPA → deal to MPA Delivered.
   - Listing agreement signed → deal to Closed Won, and ask for the listing number.
   - Buyer signed the NDA → offer to NDA.
   - LOI received or countered → offer to LOI / Proposal, `offer_amount` = latest price.
   - APA signed, earnest money in escrow → offer to Contracting / Negotiation.
   - Lender underwriting → offer to Financing.
   - Sale funded → offer to Funded, and tell Tony the fee (12.5% of the price).
   - Owner cancelled → deal to Closed Lost. Buyer walked away → offer to Disqualified / Withdrawn.
3. List them; never move anything yourself:

```
Stage moves to review: 3
  1. Sunrise Auto Body: Qualified → Valuation – you asked Dan for P&Ls on 31 Oct
  2. Sam Lee – Sunrise Auto Body: Inquiry → NDA – signed NDA received 1 Nov
  3. Greg Holt – Mesa Directional Drilling: LOI → Contracting – APA signed 30 Oct
Reply "move all" or the numbers to apply.
```
4. When Tony replies, apply only the chosen moves, read each back, and confirm in one line.
5. If an offer at Contracting / Negotiation or later is withdrawn, list the backup offers on that deal.

---

## 6.8 Suggest buyers and create offers

**When:** after a new deal, for any listed deal with no offers, or Tony asks "who could buy <business>?"

1. Read the seller company: industry, city, size, revenue, and its emails.
2. Find buyer companies (`customer_type` `buyer`) that fit, best first:
   - same or related industry, or industries they named in `contact_context`;
   - price range or location they mentioned;
   - asked about a similar listing before;
   - funding ready (SBA pre-qualified, proof of funds, 401(k) rollover).
   Skip buyers already on this deal and buyers who withdrew for a reason that still applies.
3. Reply:
```
Possible buyers for Sunrise Auto Body (Auto Repair & Collision, Santa Fe):
  1. High Desert Holdings – owns two body shops, asked about collision businesses in Aug
  2. Sam Lee – SBA pre-qualified, wants auto repair in northern NM
Reply with the numbers to add them as offers, or "none".
```
4. On "add 1 and 2": for each, create an offer at `inquiry` named `<Buyer> – <Seller business>`, linked to the deal and the buyer company. Skip any that already has an offer on this deal. Read back. Confirm: `Added 2 buyers to Sunrise Auto Body: High Desert Holdings, Sam Lee.`

---

## 6.9 Answer questions

Use Dreamteam first, Gmail second. Short answers.

| Tony asks | Do |
|---|---|
| "Show my new leads" | Contacts at `New`, newest first, grouped Seller / Buyer / Lender / Partner, one line each with source and a note |
| "Where is <business>?" | Its deal stage, its offers with stages and amounts, last email and date, what is waiting on whom |
| "Which buyers want <industry>?" | Buyer companies with that industry in `industry` or `contact_context` |
| "What's in the pipeline?" | Deals per stage, offers per stage, and 12.5% of offer amounts at Contracting / Negotiation or later |
| "Who haven't I talked to?" | Sellers and lenders with no email or note in 45+ days |

---

## 6.10 Dreamteam's own follow-up tasks

Dreamteam's assistant (Sally) creates tasks such as "Reply to <person>" from synced email. They can be stale, duplicated, or filed under Emily instead of the owner (Part 10).

- When Tony asks "what are my tasks?", list tasks with `status` `Recommended` or `Open` and `recommendation_status` `Active`. For each, check Gmail: if Tony already replied, mark it "already answered" in your list.
- Group duplicates (same person and same thread) into one line.
- If a task is about an Emily or Amber lead, name the owner and business, not Emily.
- Close or update tasks only when Tony says so.
# Part 7. Scheduled automations

Each automation is a **ChatGPT scheduled task**, created **inside the FCBB Desk project** so it can see the project instructions. Scheduled tasks run on OpenAI's servers while Tony's laptop is off. Results arrive as a ChatGPT notification (and email, if Tony allows it), and Tony replies in the task's chat.

## Before creating any task

1. Gmail and Dreamteam are connected (Part 2), and Test 0 in Part 9 passes in a normal chat.
2. **Run Test 7 (Part 9) first.** It creates one throwaway scheduled task and checks the two things nobody has confirmed yet:
   - can a scheduled task use the Dreamteam connector?
   - can a scheduled task see the project instructions and files?
   If the connector fails inside a scheduled task, these automations cannot run in ChatGPT; tell Shubham at Dreamteam, and run the prompts by hand meanwhile. If the project files are not visible, paste the parts each prompt names (for example Part 4) into the task prompt.
3. Check how many active tasks Tony's plan allows (reported as Plus 5, Pro 15, Business 10; check the plan page). The core set below is **5 tasks**.

## Schedule

All times Mountain Time.

| Task | When | Does |
|---|---|---|
| **B. Email check** | Weekdays 7:00, 12:00, 17:00; Saturday 9:00 | New leads into Dreamteam, buyer offers, replies owed, follow-ups |
| **C. Morning brief** | Weekdays 6:30 | New leads, stale leads, stage moves to approve, quiet deals |
| **D. New deals and buyers** | Weekdays 8:00, 13:00, 18:00 | Deals for newly Qualified sellers, buyer suggestions, offers on approval |
| **E. Weekly review** | Monday 7:00 | Check-ins due, clean-up list, pipeline numbers |
| **A. Lead alert** | Every 2 hours, weekdays 8:00 to 18:00 | Only Emily's and Amber's lead emails, created fast |

If the plan allows only 5 tasks, these are the 5. A ChatGPT task that recurs at several times of day may need one task per time on some plans: if so, keep B at 7:00 and 12:00, and D at 8:00 and 13:00.

ChatGPT tasks run on a clock; as far as we know they cannot start when an email arrives. Task A checks often instead.

---

## A. Lead alert

```
Lead alert. Use Gmail and Dreamteam, following the FCBB Desk manual (Parts 4, 5 and 6.4).
Look only at emails from Emily or Amber (addresses in my project instructions) received in the last 2 hours 15 minutes whose subject starts "Please Respond".
For each one, without asking me:
1. Find or create the company: name, customer type seller, industry from my list, phone, address, city, state, and domain only if it's the business's own website.
2. Find or create every owner named as a contact, linked to the company: first and last name, email, mobile (cell), phone (office), job title Owner, contact type seller, source Email, status New, and context starting "Lead source: Emily" (or Amber), then years in business, employees, revenue and the call notes.
3. Read both back.
If a required domain or email is missing, don't invent one: list the lead under "Needs you" with every detail.
Then tell me, 2 lines per lead: "New lead: <Business> – <Owner> (<industry>, <city>), from Emily. <one-line reason they might sell>."
If there were none, reply only "No new leads."
```

## B. Email check

```
Email check. Use Gmail and Dreamteam, following the FCBB Desk manual (Parts 4, 5, 6.1 to 6.5).
1. Read the last 26 hours of my email.
2. Create or update sellers, buyers, lenders and partners in Dreamteam with every field I can fill, every new contact at status New. Never invent a domain or email; list those under "Needs you".
3. For each buyer asking about a listing number, find the deal whose listing_number ends with the same last 5 digits. If no offer exists for that buyer, create one at stage inquiry named "<Buyer company> – <Seller business>", linked to the deal and the buyer company. No deal or more than one: "Needs you".
4. Tidy contacts created in the Dreamteam app in the last 26 hours (Part 6.3).
5. Find every email that needs a reply or follow-up from me (Part 6.5).
Report in this order:
**Needs your reply** (oldest first): "1. <Name> (<Business>, <Seller/Buyer/Lender/Partner>) – <what they want> – waiting <n> days"
**Follow up**: "1. <Name> – <what we asked for or promised> – <n> days ago"
**New in Dreamteam**: one line per record
**Updated**: one line
**Needs you**: anything you couldn't sort or save
End with: "Reply 'draft 2' and I'll write a reply for you to send." Drafts are short, in my tone, signed "Tony Shurter, First Choice Business Brokers - Albuquerque, (505)934-0896". Never send anything.
If nothing came in and nothing is waiting: "Email check: nothing new, nothing waiting."
```

## C. Morning brief

```
Morning brief. Use Dreamteam and Gmail, following the FCBB Desk manual (Parts 4 and 6.7). Under 20 lines:
1. New leads since yesterday morning, split Seller / Buyer / Lender / Partner.
2. Leads still at New for more than 7 days (name, business, days).
3. Stage moves to review: check yesterday's emails against my open deals and offers using the stage maps. For each: record, current stage → suggested stage, the email that shows it. Do not move anything.
4. If an offer at Contracting / Negotiation or later was withdrawn, list the backup offers on that deal.
5. Deals with no email or note for 10+ days, and sellers, buyers, lenders or partners I haven't answered in 2+ days.
End with: "Reply 'move all' or the numbers to apply." When I reply, apply only the moves I chose, read each back, and confirm in one line.
```

## D. New deals and buyers

```
New deals and buyers. Use Dreamteam, following the FCBB Desk manual (Parts 4, 6.6 and 6.8).
Step 1. Find contacts at status Qualified whose company has customer type seller and no deal yet. For each, create a deal in pipeline 1000000 at stage 1000110 (Qualified), named after the business, amount = asking price or 0, expected_close_date = the owner's target or 6 months from today, owner 1000001, linked to the company and the contact. Read it back. If Dreamteam asks for a product, stop and tell me.
Step 2. For every deal created in Step 1, and every listed deal (stage 1000115) with no offers and no suggestions from you yet, suggest buyers: buyer companies whose industry or wants match, who asked about similar businesses, or whose location or price range fits. Rank them with a one-line reason each.
Step 3. Tell me, per deal: "New deal: <Business> (<industry>) at Qualified. Possible buyers: 1. <Buyer> – <reason> 2. ... Reply with the numbers to add them as offers, or 'none'."
If nothing was created and nothing needs suggestions, reply only "No new deals."
When I reply with numbers: create one offer per chosen buyer at stage inquiry, named "<Buyer company> – <Seller business>", linked to that deal and that buyer company. Skip any buyer already on the deal. Read each back and confirm in one line.
```

## E. Weekly review

```
Weekly review. Use Dreamteam and Gmail, following the FCBB Desk manual.
1. Check-ins due: lenders and partners with no email or note in 45 days; sellers "3 to 5 years out" or similar whose last touch was 90+ days ago; buyers with an offer at NDA and no touch in 30 days. One line each. Ask: "Create Dreamteam tasks for these? Reply 'yes' or the numbers." Create tasks only after I reply, due this week, owner 1000001.
2. Clean-up: possible duplicate companies or contacts, companies with no customer type, provisional contacts, leads at New for 14+ days, Dreamteam follow-up tasks I already answered in Gmail.
3. Numbers: new leads this week by source (Emily, Amber, website, listing sites, referrals), how many reached Qualified, deals per stage, offers per stage, and 12.5% of offer amounts at Contracting / Negotiation or later.
```

---

## Add-ons (plans with 10+ tasks)

| Task | When | Prompt |
|---|---|---|
| F. Buyer inquiry alert | Every 2 hours, weekdays | Task B step 3 on its own, for emails from listing sites and "Thank you for your interest in 291-" |
| G. Check-ins | Monday 7:00 | Task E item 1 |
| H. Clean-up | Friday 16:00 | Task E item 2 |
| I. Pipeline numbers | Friday 16:30 | Task E item 3 |

## Keeping tasks healthy

- ChatGPT may pause a task that seems unused. Tony should open the notifications at least weekly.
- If a task fails twice in a row, check that the Dreamteam connector is still signed in (Settings → Apps → Dreamteam), and reconnect.
- Deals appear a few hours after Tony marks a seller Qualified (task D runs 3 times a day), not instantly. ChatGPT cannot react to changes inside Dreamteam.
- No task sends email or deletes anything. Stage moves and offers happen only after Tony replies.
- After changing this manual, re-run Test 7 so the tasks pick up the new version.
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
# Part 9. Test run

Run these in order inside the FCBB Desk project. Each says what to paste and what a pass looks like.

**These tests write to Dreamteam.** Start every test record's name with `TEST` so it is easy to find, and remove TEST records in the Dreamteam app afterwards. ChatGPT never deletes.

### Test 0. Both systems visible
**Paste:** `Using Dreamteam, who am I? List 5 companies with their customer type. Then list my last 3 emails.`
**Pass:** Tony (`1000001`), 5 real companies with seller/buyer/lender/partner, 3 real emails.
**Fail:** see Part 3, "When the MCP connector misbehaves".

### Test 1. The manual is loaded
**Paste:** `From the FCBB Desk manual: what is the stage_id for Valuation, and the offer stage id for an LOI?`
**Pass:** `1000111` and `loi_proposal`.

### Test 2. Lead from an Emily email
**Paste:** an Emily "Please Respond" email (change the business name to start with TEST), then `Create this lead in Dreamteam.`
**Pass:** one company (seller, industry set) and one contact per owner (cell in mobile, status New, context starting "Lead source: Emily"), linked. Pasting it again updates and never duplicates. If the owner has no business website or no email, it lands under Needs you instead.

### Test 3. Email check by hand
**Paste:** `Run the email check for the last 2 days.`
**Pass:** only real sellers, buyers, lenders and partners are created (no vendor pitches). The reply list matches Gmail. No lead is filed under Emily or Amber.

### Test 4. Qualify a seller
**Paste:** `Qualify the TEST seller.`
**Pass:** contact at Qualified, and a deal at Qualified (amount 0, placeholder date) linked to the company and contact. If Dreamteam asks for a product, ChatGPT stops and says so.

### Test 5. Buyers and offers
**Paste:** `Suggest buyers for the TEST deal.` Then `Add 1 and 2.`
**Pass:** a ranked list with reasons, then 2 offers at Inquiry, each linked to the deal and a buyer company. `Add 1` again creates nothing new.

### Test 6. Stage moves
**Paste:** `Check yesterday's emails against my open deals and offers. List suggested moves. Don't move anything.` Then `Approve 1.`
**Pass:** a short list with the email behind each move; only move 1 changes in Dreamteam.

### Test 7. One scheduled task (the key risk)
Inside the FCBB Desk project, create a task that runs once, 5 minutes from now:
`Using Dreamteam, list 3 companies and my last 3 emails. Then tell me the stage_id for Valuation from the FCBB Desk manual.`
**Pass:** companies, emails and `1000111`.
- No Dreamteam data: scheduled tasks cannot use the connector on this plan. The automations in Part 7 cannot run on a schedule; run them by hand and tell Dreamteam.
- No stage id: the task cannot see the project files. Paste the parts each task names into its prompt.

### Test 8. Desk
**Paste:** the canvas prompt from Part 8.
**Pass:** the canvas looks like the reference, filled with real data, and the counts match Dreamteam.

### Clean up
**Paste:** `List every Dreamteam record whose name starts with TEST.` Delete them in the Dreamteam app yourself.
# Part 10. Known issues and fixes (seen on fcbb, Nov 2026)

| Issue | Why | What to do |
|---|---|---|
| Lead emails from Emily or Amber missing in Dreamteam | Dreamteam's email sync skips emails it thinks are personal or internal | Always read Gmail directly (Part 6.4) |
| Buyer inquiries (BizBuySell, MyPortal) never in Dreamteam | Only Tony's forwards sync, marked internal | Read Gmail; create the buyer and the offer yourself |
| Dreamteam follow-up tasks filed under Emily | Sally's tasks follow the sender, not the owner in the email | Name the owner and business, never Emily (Part 6.10) |
| Many stale or duplicate Dreamteam tasks | Created in one batch when the mailbox first synced | Check Gmail before listing a task as open; group duplicates |
| Company create fails: domain required | Domain is required and unique on fcbb | Never invent one; Needs you (Part 4) |
| Contact create fails: email required | Email is required and unique | Never invent one; Needs you (Part 4) |
| Deal create fails: product required | Workspace may need a product on deals | Stop and tell Tony |
| Company names like "Sunriseautobody" | Sync names companies after their domain | Rename to the real business name |
| Closing or escrow emails dropped from sync | Marked sensitive | Read them in Gmail; suggest stage moves from them |
| A tool errors | Connector hiccup | Part 3 fallback: `object_filter` with `type: "company"` (or the type you need) |
# Part 11. Dreamteam REST API and the Custom GPT fallback

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

## Custom GPT with an Action (when MCP is down)

1. ChatGPT → GPTs → Create → Configure. Paste the same project instructions. Add this manual as a knowledge file.
2. Actions → Create new action → Import from URL: `https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/api/openapi.yaml`
3. Authentication: API Key, Auth type **Bearer**, paste the Dreamteam token there only.
4. Test: "list 5 companies". Updates may fail with 415 if the Action cannot send `application/merge-patch+json`; then use it for reads only.
