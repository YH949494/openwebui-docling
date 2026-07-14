# Private Docling Serve on Fly.io for OpenWebUI

This repository deploys **Docling Serve CPU** as a separate Fly.io app for OpenWebUI document extraction.

It is designed for this architecture:

```text
Office users
    ↓
OpenWebUI on Fly.io
    ↓  Fly private network
Docling Serve on Fly.io
    ↓
XLSX / PDF / DOCX / PPTX extraction
```

## Why this deployment is private

There is intentionally **no `[http_service]` or `[[services]]` block** in `fly.toml`.

That means Docling is not exposed through a public `*.fly.dev` endpoint. OpenWebUI should connect through Fly's private network using:

```text
http://yh-openwebui-docling.internal:5001
```

Both apps must be in the **same Fly.io organization**.

---

## Files

```text
.
├── Dockerfile
├── fly.toml
├── .dockerignore
├── .gitignore
├── README.md
├── deploy.ps1
├── test-local.ps1
├── OPENWEBUI_SETUP.md
└── .github/
    └── workflows/
        └── fly-deploy.yml
```

---

## 1. Push to GitHub

Create a new GitHub repository and push these files.

Example:

```powershell
git init
git add .
git commit -m "Deploy private Docling Serve on Fly.io"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

---

## 2. Check the Fly app name

The default app name is:

```text
yh-openwebui-docling
```

Fly app names are globally unique. If that name is taken, change this line in `fly.toml`:

```toml
app = "yh-openwebui-docling"
```

After changing it, also update the Docling URL used in OpenWebUI.

---

## 3. Deploy manually from Windows

Install and log in to Fly CLI, then run:

```powershell
fly auth login
fly apps create yh-openwebui-docling
fly deploy
```

If `fly apps create` says the app already exists under your account, continue with:

```powershell
fly deploy
```

Or simply run:

```powershell
.\deploy.ps1
```

---

## 4. Verify Docling

Check machine status:

```powershell
fly status -a yh-openwebui-docling
```

Check logs:

```powershell
fly logs -a yh-openwebui-docling
```

Verify from inside the machine:

```powershell
fly ssh console -a yh-openwebui-docling -C "python -c \"import urllib.request; print(urllib.request.urlopen('http://localhost:5001/docs').status)\""
```

Expected result:

```text
200
```

---

## 5. Configure OpenWebUI

In OpenWebUI:

```text
Admin Panel
→ Settings
→ Documents
→ Content Extraction Engine
→ Docling
```

Set the Docling server URL to:

```text
http://yh-openwebui-docling.internal:5001
```

Then save.

More detail is in `OPENWEBUI_SETUP.md`.

---

## 6. Important: upload the Excel again

Previously uploaded files may already have been extracted and cached using the old extractor.

After switching to Docling:

1. Start a fresh chat.
2. Upload `Claim.xlsx` again.
3. Ask: `What is this file?`
4. Confirm that actual rows and totals are detected.

Do not use the old attachment as the validation test.

---

## Resource settings

This bundle starts with:

```text
2 shared CPUs
4 GB RAM
1 worker
50 MB max file
200 page max
10 minute document timeout
```

The 4 GB starting point is deliberate. Docling loads ML models and table/layout processing can be memory-heavy. Starting too low creates false failures and OOM restarts.

For your initial office rollout, reliability matters more than saving a small amount of RAM cost.

---

## GitHub Actions deployment

The included workflow deploys automatically on pushes to `main`.

Create a GitHub Actions secret:

```text
FLY_API_TOKEN
```

Generate a token using Fly CLI:

```powershell
fly tokens create deploy -a yh-openwebui-docling
```

Add the generated token in:

```text
GitHub repository
→ Settings
→ Secrets and variables
→ Actions
→ New repository secret
```

Name:

```text
FLY_API_TOKEN
```

---

## Security

This configuration is private by network design and does not publish a public HTTP service.

Do not add `[http_service]` unless you intentionally want Docling exposed publicly.

If your OpenWebUI and Docling apps are in different Fly organizations, `.internal` private networking will not work directly. Move them into the same organization or use another secured networking approach.
