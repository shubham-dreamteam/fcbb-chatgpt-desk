@Sites Build **FCBB Desk**, a private web app for Tony Shurter, business broker at First Choice Business Brokers Albuquerque. It shows his live pipeline from Dreamteam CRM (workspace `fcbb.dreamteamcrm.ai`).

**How to work: build the whole thing in one go, without stopping.**
- Do not ask me questions. The only thing you may ask for is the Dreamteam API token, once, as a Sites secret named `DT_API_KEY`. Ask for it the moment you need it, then keep going.
- Everything else, decide yourself using this message and its appendices; for look and layout, use your own judgment. When something is unclear, pick the simplest option that serves Tony, note it in one line in your final summary, and move on.
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
