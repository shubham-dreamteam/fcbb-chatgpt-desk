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
