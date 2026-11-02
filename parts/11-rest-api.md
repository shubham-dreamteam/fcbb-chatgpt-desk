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
