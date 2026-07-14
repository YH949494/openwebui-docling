# OpenWebUI configuration

## Recommended connection

Assuming the Fly app name remains:

```text
yh-openwebui-docling
```

Use this URL in OpenWebUI:

```text
http://yh-openwebui-docling.internal:5001
```

Path:

```text
Admin Panel
→ Settings
→ Documents
→ Content Extraction Engine
→ Docling
```

Then save.

## Why no paid API is required

This deployment runs your own Docling Serve instance. OpenWebUI sends files directly to your private Docling service.

No external paid Docling API is required.

## API key

This private deployment does not enable a Docling API key by default because the service is not publicly exposed and is intended to be reachable only over Fly private networking.

For this setup, leave the OpenWebUI Docling API key field empty.

## Suggested Docling processing parameters

Start with the defaults first.

For your Excel validation, do not enable OCR just to process `.xlsx` files. OCR is irrelevant to native spreadsheet cells and adds unnecessary work.

For complex PDFs later, you can consider:

```json
{
  "do_ocr": true,
  "force_ocr": false,
  "table_mode": "accurate",
  "pipeline": "standard"
}
```

Do not add these until the basic Excel test is working.

## Test procedure

Use a fresh chat and re-upload the original file.

Ask:

```text
What is this file? Summarize every sheet, count the actual data rows, and list the monthly totals.
```

Expected behavior:

- Detect actual spreadsheet rows.
- Preserve table structure better than the previous default extraction path.
- Not report `0 rows` when the workbook visibly contains data.

## If OpenWebUI cannot reach Docling

Check:

1. Both Fly apps are in the same Fly organization.
2. Docling machine is running.
3. App name in the URL matches `fly.toml`.
4. Docling logs show a successful boot.
5. `UVICORN_HOST` is set to `::`.
6. Port is `5001`.

Useful commands:

```powershell
fly status -a yh-openwebui-docling
fly logs -a yh-openwebui-docling
```
