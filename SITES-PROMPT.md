# Prompt: build FCBB Desk as a ChatGPT Site

Paste everything below the line into ChatGPT (type `@Sites` first). Attach nothing; the links are public.

---

@Sites Build **FCBB Desk**, a private web app for Tony Shurter, business broker at First Choice Business Brokers Albuquerque. It shows his live pipeline from Dreamteam CRM (workspace `fcbb.dreamteamcrm.ai`).

**Design.** Copy this reference page exactly (layout, colours, fonts, tabs, deal page, phone layout). It has made-up sample data in arrays at the top of its script; replace those with live data from the server:
https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html

**Data source.** Dreamteam REST API, docs: https://docs.dreamteam.co/api/ (read Authentication, Records, Find Records, Schema, Pipelines, Pagination, Errors before coding). Full field and stage map: https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md (Part 4 and Part 11).
- Base `https://api.dreamteamcrm.ai/api/v1`, header `Authorization: Bearer <DT_API_KEY>`.
- Store the token as a **Sites secret** named `DT_API_KEY`. I will paste it in the Sites panel. Never put it in code, the page, the browser, logs or responses.
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

**Before you deploy**, show me a saved version and check: the counts on Today match Dreamteam (companies by type, deals per stage, offers), refresh changes the time and pulls a record I just edited in Dreamteam, and the token appears nowhere in the page source or network responses.
