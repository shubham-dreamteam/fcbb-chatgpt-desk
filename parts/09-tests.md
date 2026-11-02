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
