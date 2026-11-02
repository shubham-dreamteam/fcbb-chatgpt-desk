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
