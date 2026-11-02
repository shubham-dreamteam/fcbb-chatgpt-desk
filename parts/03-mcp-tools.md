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
