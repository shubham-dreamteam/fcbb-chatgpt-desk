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
