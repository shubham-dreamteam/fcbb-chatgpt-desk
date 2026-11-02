# FCBB Desk: full setup run

ChatGPT, you have been given this file to **set up FCBB Desk end to end**, not only to check it. Do all four steps below, in order, in this chat. Ask Tony only when a step says so.

The full operating manual is here (read it now, and again whenever a task names a Part):
`https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/FCBB-DESK.md`
If you can't open it, ask Tony to add `FCBB-DESK.md` to this project's files.

## Step 1. Check the connections (1 minute)

1. Using Dreamteam: `user_me`. It must be Tony (`1000001`). List 5 companies with `object_filter` `type: "company"`.
2. Using Gmail: list Tony's last 3 emails.
3. Tell Tony in one line: `Dreamteam OK (Tony), Gmail OK.` If either fails, stop and show the fix from Part 2 of the manual.

## Step 2. Create the scheduled tasks

Create these **5 scheduled tasks** inside this project, one at a time, with the exact names, times and prompts in the next section ("Part 7. Scheduled automations"). Time zone: America/Denver (Mountain Time).

| # | Name | Schedule |
|---|---|---|
| 1 | FCBB B. Email check | Weekdays 7:00, 12:00, 17:00; Saturday 9:00 |
| 2 | FCBB C. Morning brief | Weekdays 6:30 |
| 3 | FCBB D. New deals and buyers | Weekdays 8:00, 13:00, 18:00 |
| 4 | FCBB E. Weekly review | Monday 7:00 |
| 5 | FCBB A. Lead alert | Every 2 hours, weekdays 8:00 to 18:00 |

- If one task can't hold several times a day, create one task per time (for example "FCBB B. Email check 7:00", "... 12:00") until the plan's limit, B and D first.
- If you hit the plan's task limit, stop and tell Tony which ones were not created.
- If you can't create scheduled tasks from this chat, give Tony each one as a numbered block (name, schedule, prompt) to create under the profile menu → Tasks, and continue.
- When done, list the tasks you created with their next run time.

Then create **one extra task** that runs once, 5 minutes from now, named `FCBB test`: `Using Dreamteam, list 3 companies and my last 3 emails. Then tell me the stage_id for Valuation from the FCBB Desk manual.` Tell Tony: "When it runs, check it shows companies, emails and 1000111. If not, see Part 9, Test 7."

## Step 3. Draw the desk (artifact)

Open a **canvas** and build the desk with the prompt in "Canvas desk: the prompt" at the end of this file, using live Dreamteam and Gmail data and the reference design:
`https://raw.githubusercontent.com/shubham-dreamteam/fcbb-chatgpt-desk/main/ui/fcbb-desk-reference.html`

## Step 4. Report

Reply in under 8 lines:
```
FCBB Desk is set up.
Connections: Dreamteam OK, Gmail OK.
Scheduled: 5 tasks (next: Morning brief, tomorrow 6:30 MT). Test task runs at <time>.
Desk: drawn in the canvas.
Needs you: <anything that failed, or "nothing">.
Say "draw my desk" any time to refresh it, or "check my email" to run the email check now.
```

---

