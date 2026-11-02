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
