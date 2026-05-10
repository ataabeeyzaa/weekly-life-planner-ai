# weekly-life-planner-ai Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Telegram-based AI weekly life planner backed by PostgreSQL/Supabase, orchestrated by self-hosted n8n, delivered with IEEE paper + demo video by 18 May 2026.

**Architecture:** User chats with `@PlanlaBot` on Telegram. Telegram webhook → n8n workflow → Supabase read/write + Google Gemini 1.5 Flash call → response back to Telegram. Five n8n workflows (4 command-triggered + 1 weekly cron). All workflow JSON, SQL, prompts, and IEEE paper are version-controlled in a public GitHub repo.

**Tech Stack:** Supabase (PostgreSQL 15), n8n (Docker self-hosted), Telegram Bot API, Google Gemini 1.5 Flash (fallback Gemini Flash), GitHub, Docker Desktop on Windows 11.

**Spec reference:** [docs/superpowers/specs/2026-05-10-weekly-life-planner-ai-design.md](../specs/2026-05-10-weekly-life-planner-ai-design.md)

**Reading guidance:** Each phase corresponds to one calendar day. Tasks within a phase are sequential. Each step is a single action — read, do, verify, move on. Commit after every meaningful change (the plan calls out commit points explicitly).

---

## Phase 0 — Repo, Accounts, and Local Setup (Day 1, 10 May)

### Task 0.1: Install GitHub CLI on Windows

**Files:** none (system install)

- [ ] **Step 1: Open PowerShell as Administrator**

Right-click Start → "Windows PowerShell (Admin)".

- [ ] **Step 2: Install gh via winget**

```powershell
winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements
```

Expected: "Successfully installed".

- [ ] **Step 3: Open a new bash terminal and verify**

```bash
gh --version
```

Expected output (version may differ):
```
gh version 2.x.x (yyyy-mm-dd)
```

If `gh: command not found`, close and reopen the terminal so PATH refreshes.

### Task 0.2: Authenticate gh with GitHub account

- [ ] **Step 1: Start auth flow**

```bash
gh auth login
```

Answer prompts:
- "What account?" → **GitHub.com**
- "Protocol?" → **HTTPS**
- "Authenticate Git with credentials?" → **Yes**
- "How to authenticate?" → **Login with a web browser**

Browser opens, paste the one-time code shown in terminal, authorize.

- [ ] **Step 2: Verify auth**

```bash
gh auth status
```

Expected: `Logged in to github.com as ataabeeyzaa`.

### Task 0.3: Create the GitHub repository

- [ ] **Step 1: Create empty public repo**

```bash
cd "C:/Users/User/Desktop/Veri_Tabani_Project"
gh repo create weekly-life-planner-ai \
  --public \
  --description "AI-powered weekly life planner — Telegram bot + n8n + Supabase + OpenAI" \
  --source . \
  --remote origin
```

Expected: `✓ Created repository ataabeeyzaa/weekly-life-planner-ai on GitHub`.

- [ ] **Step 2: Verify remote**

```bash
git remote -v
```

Expected:
```
origin  https://github.com/ataabeeyzaa/weekly-life-planner-ai.git (fetch)
origin  https://github.com/ataabeeyzaa/weekly-life-planner-ai.git (push)
```

### Task 0.4: Add .gitignore

**Files:**
- Create: `.gitignore`

- [ ] **Step 1: Write .gitignore**

```
# Secrets
.env
.env.local
*.pem
*.key

# n8n local data
n8n_data/
*.db

# Docker
docker/n8n_data/

# OS / IDE
.DS_Store
Thumbs.db
.vscode/
.idea/

# Build
node_modules/
__pycache__/
*.pyc

# Course materials (kept local only)
# Note: pptx and docx already on disk are intentionally tracked
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore"
```

### Task 0.5: Add LICENSE (MIT)

**Files:**
- Create: `LICENSE`

- [ ] **Step 1: Create MIT LICENSE file**

```
MIT License

Copyright (c) 2026 Beyza Ata

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 2: Commit**

```bash
git add LICENSE
git commit -m "chore: add MIT license"
```

### Task 0.6: Create README skeleton

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README skeleton**

````markdown
# weekly-life-planner-ai

> Yapay zeka destekli haftalık yaşam planlayıcısı — Telegram + n8n + Supabase + OpenAI

**Yazar:** Beyza Ata · [GitHub @ataabeeyzaa](https://github.com/ataabeeyzaa)
**Ders:** Veri Tabanı (Database-AI Entegrasyonu)
**Teslim:** 18 Mayıs 2026

## Ne yapar?

Telegram'da `@PlanlaBot`'a profilinizi anlatırsınız (uyanma saati, hedefler, iş düzeniniz). Her Pazar 20:00'de bot geçen haftayı sorar, AI sizin için kişiselleştirilmiş bir haftalık plan üretir, mesaj olarak gönderir. Tüm veri Supabase PostgreSQL'de saklanır, otomasyon n8n ile yapılır.

## Mimari

```
Kullanıcı (Telegram)
       ↓
Telegram Bot ↔ n8n (Docker)
       ↓
   Supabase + Google Gemini 1.5 Flash
```

Detay: [docs/architecture.md](docs/architecture.md)

## Hızlı Başlangıç

(Kurulum adımları faz-faz tamamlandıkça eklenecek.)

## Demo

- 🎬 Demo videosu: (eklenecek)
- 📄 IEEE makalesi: [docs/ieee-paper/](docs/ieee-paper/)

## Lisans

MIT
````

- [ ] **Step 2: Commit and push**

```bash
git add README.md
git commit -m "docs: add README skeleton"
git push -u origin main
```

Expected: All commits pushed, repo visible at `https://github.com/ataabeeyzaa/weekly-life-planner-ai`.

### Task 0.7: Create Supabase project

**No file changes — external setup.**

- [ ] **Step 1: Open supabase.com and sign in**

Go to https://supabase.com → "Sign in" → use GitHub OAuth (uses same GitHub account).

- [ ] **Step 2: Create new project**

- Click "New Project"
- Organization: default (your personal org)
- Name: `weekly-life-planner-ai`
- Database password: **generate a strong one and save it in your password manager**
- Region: `Europe Central (Frankfurt) — eu-central-1` (closest to Turkey)
- Plan: Free
- Click "Create new project"

Wait ~2 minutes for provisioning.

- [ ] **Step 3: Capture credentials**

Once provisioned, go to **Settings → API**. Copy and save these temporarily (we'll put them in `.env` next):
- Project URL (e.g., `https://xxx.supabase.co`)
- `anon` public key
- `service_role` key (keep secret, never commit)

Also from **Settings → Database** → Connection string (URI form). You'll need this for n8n's Postgres node later.

### Task 0.8: Create Telegram bot via BotFather

- [ ] **Step 1: Open Telegram, search `@BotFather`, click "Start"**

- [ ] **Step 2: Create new bot**

Send: `/newbot`

BotFather asks:
- Bot name (display): `Beyza Hayat Planlayıcısı` (or your choice)
- Bot username: `BeyzaPlanlaBot` (must end with `bot`, must be unique — try alternatives if taken)

BotFather replies with: `HTTP API token: 1234567890:ABCdef...`

**Save this token** — we'll need it.

- [ ] **Step 3: Configure bot commands menu**

Send: `/setcommands`

Choose your bot, then paste:
```
start - Botu başlat ve KVKK metnini gör
profil - Profil bilgilerini gir veya güncelle
hedef - Yeni hedef ekle
plan - Bu hafta için plan iste
gecmis - Son 4 haftanın planlarını listele
geri_bildirim - Son plana puan ver
sil - Tüm verilerimi sil
```

Now in Telegram, the user sees these commands as a menu.

### Task 0.9: Get Google Gemini API key (PRIMARY)

- [ ] **Step 1: Go to Google AI Studio**

Open https://aistudio.google.com/app/apikey and sign in with your Google account.

- [ ] **Step 2: Create API key**

Click **"Create API key"** → choose "Create API key in new project" (or pick existing GCP project if you have one).

A key like `AIzaSyD...` is generated. **Copy it.**

- [ ] **Step 3: Note the free tier limits**

Gemini 1.5 Flash free tier:
- 15 requests per minute
- 1500 requests per day
- 1 million tokens per minute
- No credit card required

For our use case (~5-10 plan generations per week per user), this is **massively over-provisioned**.

- [ ] **Step 4: (Fallback) OpenAI API key — only if Gemini fails**

If you later want OpenAI as backup:
- platform.openai.com → add billing → API Keys → create

### Task 0.10: Create .env.example and local .env

**Files:**
- Create: `.env.example`
- Create: `.env` (NOT committed)

- [ ] **Step 1: Write .env.example**

```bash
# Supabase
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
SUPABASE_DB_PASSWORD=your-db-password
SUPABASE_DB_HOST=db.your-project-ref.supabase.co
SUPABASE_DB_PORT=5432
SUPABASE_DB_NAME=postgres
SUPABASE_DB_USER=postgres

# Telegram
TELEGRAM_BOT_TOKEN=1234567890:ABCdef...
TELEGRAM_BOT_USERNAME=BeyzaPlanlaBot

# OpenAI
OPENAI_API_KEY=sk-proj-...
OPENAI_MODEL=gpt-4o-mini

# Gemini (fallback)
GEMINI_API_KEY=AIza...
```

- [ ] **Step 2: Create local .env (NOT committed)**

```bash
cp .env.example .env
```

Open `.env` in your editor, paste the real values from Tasks 0.7, 0.8, 0.9.

- [ ] **Step 3: Verify .env is gitignored**

```bash
git status
```

Expected: `.env.example` shown as new file, `.env` NOT shown (because `.gitignore` excludes it).

- [ ] **Step 4: Commit and push**

```bash
git add .env.example
git commit -m "chore: add .env.example template"
git push
```

### Task 0.11: Phase 0 checkpoint

- [ ] **Step 1: Verify all phase 0 deliverables**

```bash
ls -la
git log --oneline
```

Expected files: `.env.example`, `.gitignore`, `LICENSE`, `README.md`, `docs/`. Expected: 5+ commits, all pushed.

- [ ] **Step 2: Open repo in browser to confirm**

```bash
gh repo view --web
```

Expected: GitHub page loads, shows README, all files visible.

---

## Phase 1 — Database Schema (Day 2, 11 May)

### Task 1.1: Create database/ folder and schema file

**Files:**
- Create: `database/01_schema.sql`

- [ ] **Step 1: Create folder**

```bash
mkdir -p database
```

- [ ] **Step 2: Write schema SQL**

Create `database/01_schema.sql`:

```sql
-- weekly-life-planner-ai
-- Şema: 5 tablo, foreign key'ler, index'ler
-- Hedef veritabanı: PostgreSQL 15+ (Supabase)

-- 1. KULLANICILAR
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_id BIGINT UNIQUE NOT NULL,
    ad TEXT NOT NULL,
    yas INT CHECK (yas BETWEEN 13 AND 100),
    meslek TEXT,
    uyanma_saati TIME NOT NULL,
    uyku_saati TIME NOT NULL,
    is_baslangic TIME,
    is_bitis TIME,
    enerji_zirvesi TEXT CHECK (enerji_zirvesi IN ('sabah', 'oglen', 'aksam')),
    kvkk_onay BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);

-- 2. HEDEFLER
CREATE TABLE IF NOT EXISTS user_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kategori TEXT NOT NULL CHECK (kategori IN ('kariyer','saglik','sosyal','hobi','ogrenme','aile')),
    hedef_metin TEXT NOT NULL,
    oncelik INT NOT NULL CHECK (oncelik BETWEEN 1 AND 5),
    aktif BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_goals_user_active ON user_goals(user_id, aktif);

-- 3. HAFTALIK GİRDİLER (refleksiyon)
CREATE TABLE IF NOT EXISTS weekly_inputs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hafta_baslangic DATE NOT NULL,
    gecen_hafta_puan INT CHECK (gecen_hafta_puan BETWEEN 1 AND 10),
    gecen_hafta_iyi TEXT,
    gecen_hafta_kotu TEXT,
    bu_hafta_etkinlikler TEXT,
    enerji_seviyesi INT CHECK (enerji_seviyesi BETWEEN 1 AND 10),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, hafta_baslangic)
);

-- 4. PLANLAR
CREATE TABLE IF NOT EXISTS plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weekly_input_id UUID NOT NULL REFERENCES weekly_inputs(id) ON DELETE CASCADE,
    hafta_baslangic DATE NOT NULL,
    plan_json JSONB NOT NULL,
    plan_markdown TEXT NOT NULL,
    model_kullanilan TEXT NOT NULL DEFAULT 'gemini-1.5-flash',
    prompt_token INT,
    completion_token INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_plans_user_week ON plans(user_id, hafta_baslangic DESC);

-- 5. GERİ BİLDİRİM
CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    puan INT NOT NULL CHECK (puan BETWEEN 1 AND 5),
    yorum TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- updated_at trigger (sadece users için)
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_users ON users;
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_updated_at();
```

- [ ] **Step 3: Commit**

```bash
git add database/01_schema.sql
git commit -m "feat(db): add 5-table PostgreSQL schema"
```

### Task 1.2: Apply schema to Supabase

- [ ] **Step 1: Open Supabase SQL Editor**

Supabase dashboard → your project → left sidebar → "SQL Editor" → "New query".

- [ ] **Step 2: Paste schema and run**

Open `database/01_schema.sql` in your code editor, copy entire content, paste into Supabase SQL Editor, click **Run** (or Ctrl+Enter).

Expected: "Success. No rows returned." for each statement.

- [ ] **Step 3: Verify tables exist**

Left sidebar → "Table Editor" → you should see: `users`, `user_goals`, `weekly_inputs`, `plans`, `feedback`.

- [ ] **Step 4: Verify foreign keys via SQL**

Run in SQL Editor:

```sql
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS references_table,
    ccu.column_name AS references_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
ORDER BY tc.table_name;
```

Expected output: 4 foreign keys (`user_goals.user_id`, `weekly_inputs.user_id`, `plans.user_id`, `plans.weekly_input_id`, `feedback.plan_id`).

### Task 1.3: Write seed data

**Files:**
- Create: `database/02_seed_data.sql`

- [ ] **Step 1: Write seed SQL**

```sql
-- Seed verisi: demo amaçlı 1 kullanıcı + hedefler + 1 hafta input + 1 plan
-- Telegram ID gerçek bir test kullanıcısının değildir, sadece schema doğrulama için.

-- 1 kullanıcı
INSERT INTO users (telegram_id, ad, yas, meslek, uyanma_saati, uyku_saati, is_baslangic, is_bitis, enerji_zirvesi, kvkk_onay)
VALUES (999000111, 'Test Kullanıcı', 24, 'Yazılım Mühendisi', '07:30', '23:30', '09:00', '18:00', 'sabah', TRUE)
ON CONFLICT (telegram_id) DO NOTHING;

-- 3 hedef
WITH u AS (SELECT id FROM users WHERE telegram_id = 999000111)
INSERT INTO user_goals (user_id, kategori, hedef_metin, oncelik)
SELECT u.id, 'saglik', 'Haftada 3 gün 30 dk koşu', 5 FROM u
UNION ALL
SELECT u.id, 'ogrenme', 'Bu ay 1 teknik kitap bitir', 4 FROM u
UNION ALL
SELECT u.id, 'sosyal', 'Haftada 1 arkadaş buluşması', 3 FROM u;

-- 1 weekly input
WITH u AS (SELECT id FROM users WHERE telegram_id = 999000111)
INSERT INTO weekly_inputs (user_id, hafta_baslangic, gecen_hafta_puan, gecen_hafta_iyi, gecen_hafta_kotu, bu_hafta_etkinlikler, enerji_seviyesi)
SELECT u.id, '2026-05-12', 7, 'Spor düzenli oldu', 'Geç saatlere kadar çalıştım', 'Çarşamba sunum, Cuma doktor', 6 FROM u
ON CONFLICT (user_id, hafta_baslangic) DO NOTHING;

-- 1 plan (örnek minimum JSON, gerçek plan AI'dan gelecek)
WITH u AS (SELECT id FROM users WHERE telegram_id = 999000111),
     wi AS (SELECT id FROM weekly_inputs WHERE hafta_baslangic = '2026-05-12' LIMIT 1)
INSERT INTO plans (user_id, weekly_input_id, hafta_baslangic, plan_json, plan_markdown, model_kullanilan)
SELECT u.id, wi.id, '2026-05-12',
    '{"hafta_basligi":"12-18 Mayıs 2026","ana_hedefler":["Test"],"motivasyon_notu":"Seed verisi"}'::jsonb,
    '# Seed Plan\n\nBu sadece şema doğrulama için.',
    'seed-data'
FROM u, wi;
```

- [ ] **Step 2: Apply seed in Supabase SQL Editor**

Copy contents of `02_seed_data.sql`, paste into a new Supabase SQL Editor query, run.

Expected: All inserts succeed.

- [ ] **Step 3: Verify seed**

```sql
SELECT u.ad, COUNT(DISTINCT g.id) AS hedef_sayisi, COUNT(DISTINCT p.id) AS plan_sayisi
FROM users u
LEFT JOIN user_goals g ON g.user_id = u.id
LEFT JOIN plans p ON p.user_id = u.id
WHERE u.telegram_id = 999000111
GROUP BY u.ad;
```

Expected: 1 row, `hedef_sayisi = 3`, `plan_sayisi = 1`.

- [ ] **Step 4: Commit**

```bash
git add database/02_seed_data.sql
git commit -m "feat(db): add seed data for schema validation"
```

### Task 1.4: Write useful queries (for paper + demo)

**Files:**
- Create: `database/03_useful_queries.sql`

- [ ] **Step 1: Write queries**

```sql
-- Bu dosya: IEEE makalesinde ve sunumda gösterilecek örnek SQL sorguları.

-- Q1: Bir kullanıcının aktif hedeflerini önceliklerine göre listele
SELECT g.kategori, g.hedef_metin, g.oncelik
FROM user_goals g
JOIN users u ON u.id = g.user_id
WHERE u.telegram_id = 999000111 AND g.aktif = TRUE
ORDER BY g.oncelik DESC, g.created_at;

-- Q2: Geçen 4 haftanın puan ortalaması (kullanıcı bazında)
SELECT u.ad, ROUND(AVG(wi.gecen_hafta_puan)::numeric, 2) AS ortalama_puan
FROM users u
JOIN weekly_inputs wi ON wi.user_id = u.id
WHERE wi.hafta_baslangic >= CURRENT_DATE - INTERVAL '28 days'
GROUP BY u.ad;

-- Q3: Plan başına ortalama kullanıcı puanı (en başarılı planlar)
SELECT p.hafta_baslangic, p.plan_json->>'hafta_basligi' AS hafta,
       ROUND(AVG(f.puan)::numeric, 2) AS ortalama_puan,
       COUNT(f.id) AS oy_sayisi
FROM plans p
LEFT JOIN feedback f ON f.plan_id = p.id
GROUP BY p.id, p.hafta_baslangic
ORDER BY ortalama_puan DESC NULLS LAST
LIMIT 10;

-- Q4: Bir kullanıcının token kullanım toplamı (maliyet)
SELECT u.ad,
       COUNT(p.id) AS plan_sayisi,
       SUM(p.prompt_token) AS toplam_prompt_token,
       SUM(p.completion_token) AS toplam_completion_token
FROM users u
JOIN plans p ON p.user_id = u.id
GROUP BY u.ad;

-- Q5: JSONB ile sorgu — planda "spor" geçen ana hedefleri ara
SELECT u.ad, p.hafta_baslangic, jsonb_array_elements_text(p.plan_json->'ana_hedefler') AS hedef
FROM plans p
JOIN users u ON u.id = p.user_id
WHERE p.plan_json->'ana_hedefler' @> '["spor"]'::jsonb
   OR EXISTS (
       SELECT 1 FROM jsonb_array_elements_text(p.plan_json->'ana_hedefler') h
       WHERE h ILIKE '%spor%'
   );

-- Q6: KVKK silme — bir kullanıcının tüm verisini sil (CASCADE)
-- DELETE FROM users WHERE telegram_id = 999000111;
-- (Test ederken yorumdan çıkar)
```

- [ ] **Step 2: Test each query in Supabase SQL Editor**

Run Q1–Q5, verify they return sensible results from seed data. Q6 leave commented.

- [ ] **Step 3: Commit**

```bash
git add database/03_useful_queries.sql
git commit -m "docs(db): add example queries for paper and demo"
```

### Task 1.5: Generate ER diagram

- [ ] **Step 1: Open dbdiagram.io**

Go to https://dbdiagram.io → "Go to App" (no signup needed).

- [ ] **Step 2: Import schema as DBML**

Click "Import" → "From PostgreSQL" → paste contents of `database/01_schema.sql` → click "Submit".

Expected: 5 tables auto-rendered with foreign key relationships.

- [ ] **Step 3: Arrange and export**

Drag tables to a clean layout (users in center, others around).
Click "Export" → "to PNG" → save as `database/er_diagram.png`.

- [ ] **Step 4: Add to README**

Append to `README.md` after the Mimari section:

```markdown
## Veritabanı Şeması

![ER Diagram](database/er_diagram.png)

5 tablo, 5 foreign key. Detay: [docs/database-schema.md](docs/database-schema.md) ve [database/](database/).
```

- [ ] **Step 5: Commit**

```bash
git add database/er_diagram.png README.md
git commit -m "docs(db): add ER diagram and README database section"
git push
```

### Task 1.6: Phase 1 checkpoint

- [ ] **Step 1: Verify Supabase has 5 tables with correct FKs**

In Supabase Table Editor sidebar, confirm: `users`, `user_goals`, `weekly_inputs`, `plans`, `feedback` all visible.

- [ ] **Step 2: Verify GitHub has database/ committed**

```bash
gh repo view --web
```

Click "database" folder, confirm 4 files: `01_schema.sql`, `02_seed_data.sql`, `03_useful_queries.sql`, `er_diagram.png`.

---

## Phase 2 — n8n Setup (Day 3 morning, 12 May AM)

### Task 2.1: Write docker-compose.yml for n8n

**Files:**
- Create: `docker/docker-compose.yml`

- [ ] **Step 1: Create docker folder**

```bash
mkdir -p docker
```

- [ ] **Step 2: Write docker-compose.yml**

```yaml
version: "3.8"

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: weekly-planner-n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=${N8N_WEBHOOK_URL:-http://localhost:5678/}
      - GENERIC_TIMEZONE=Europe/Istanbul
      - TZ=Europe/Istanbul
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_PERSONALIZATION_ENABLED=false
      - N8N_DEFAULT_LOCALE=tr
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
    name: weekly_planner_n8n_data
```

- [ ] **Step 3: Commit**

```bash
git add docker/docker-compose.yml
git commit -m "feat(docker): add n8n self-hosted setup"
```

### Task 2.2: Start n8n and complete first-time setup

- [ ] **Step 1: Make sure Docker Desktop is running**

Open Docker Desktop application on Windows. Wait for the whale icon in system tray to be steady (not animated).

- [ ] **Step 2: Start n8n**

```bash
cd "C:/Users/User/Desktop/Veri_Tabani_Project/docker"
docker compose up -d
```

Expected: `Container weekly-planner-n8n  Started`. First pull may take 2-3 minutes.

- [ ] **Step 3: Verify container is running**

```bash
docker ps --filter "name=weekly-planner-n8n"
```

Expected: STATUS = `Up X seconds`, PORTS = `0.0.0.0:5678->5678/tcp`.

- [ ] **Step 4: Open n8n in browser**

Navigate to http://localhost:5678

Expected: n8n setup wizard (first run only).

- [ ] **Step 5: Create owner account**

Fill in: email, first name, last name, password (min 8 chars, mixed case, number).

Skip the "tell us about yourself" survey.

- [ ] **Step 6: Verify dashboard loads**

You should see an empty workflows list at http://localhost:5678/workflows.

### Task 2.3: Install ngrok for Telegram webhook (so Telegram can reach localhost)

- [ ] **Step 1: Sign up for ngrok**

Go to https://ngrok.com → Sign up (GitHub OAuth) → free tier.

- [ ] **Step 2: Install ngrok via winget**

```powershell
winget install --id Ngrok.Ngrok --accept-source-agreements --accept-package-agreements
```

Verify in bash:
```bash
ngrok version
```

- [ ] **Step 3: Add your auth token**

From the ngrok dashboard "Setup & Installation" page, copy your auth token, then:

```bash
ngrok config add-authtoken YOUR_TOKEN_HERE
```

- [ ] **Step 4: Start a tunnel to n8n in a SEPARATE terminal (keep it open)**

```bash
ngrok http 5678
```

Expected: ngrok screen showing `Forwarding https://xxxx-xx-xx.ngrok-free.app -> http://localhost:5678`.

**Save this https URL** — Telegram needs it. Each ngrok restart gives a new URL (free tier).

- [ ] **Step 5: Update n8n WEBHOOK_URL and restart**

Stop n8n:
```bash
cd "C:/Users/User/Desktop/Veri_Tabani_Project/docker"
docker compose down
```

Set env var (replace with your ngrok URL):
```bash
export N8N_WEBHOOK_URL="https://xxxx-xx-xx.ngrok-free.app/"
docker compose up -d
```

(On Windows, you can also create a `.env` next to `docker-compose.yml` with `N8N_WEBHOOK_URL=https://...` — but **don't commit it**.)

### Task 2.4: Add Telegram credential in n8n

- [ ] **Step 1: Open n8n → Credentials**

http://localhost:5678 → left sidebar → "Credentials" → "Add credential".

- [ ] **Step 2: Choose "Telegram API"**

Search "Telegram", select "Telegram API".

- [ ] **Step 3: Paste bot token**

Paste the token from BotFather (Task 0.8). Click "Save".

Expected: "Connection tested successfully".

### Task 2.5: Add Postgres credential for Supabase

- [ ] **Step 1: Add credential → "Postgres"**

- [ ] **Step 2: Fill in Supabase DB connection**

From your `.env`:
- Host: `db.your-project-ref.supabase.co` (or use the "Connection string" form from Supabase Settings → Database)
- Database: `postgres`
- User: `postgres`
- Password: your DB password
- Port: `5432`
- SSL: **Require**

Click "Save".

Expected: "Connection tested successfully".

### Task 2.6: Add Google Gemini credential

- [ ] **Step 1: Add credential → "Google Gemini (PaLM) API"**

In n8n credentials, search "Gemini". Select **"Google Gemini(PaLM) API"** (or "Google Vertex AI" if Gemini variant unavailable).

- [ ] **Step 2: Paste API key**

Paste your `GEMINI_API_KEY` from `.env`. Click "Save".

Expected: "Connection tested successfully".

> **Note:** If your n8n version doesn't show a dedicated Gemini node, install the community node: Settings → Community Nodes → Install → search `n8n-nodes-google-gemini`. Or use the generic HTTP Request node — pattern shown in Task 4.4 alternative.

### Task 2.7: Smoke test — minimal "echo" workflow

This validates Telegram → n8n → Telegram works end-to-end before we build real workflows.

- [ ] **Step 1: Create new workflow**

Workflows → "+ Add workflow" → name it `00_smoke_test`.

- [ ] **Step 2: Add Telegram Trigger node**

Click "+", search "Telegram Trigger", drag in.
Configure:
- Credential: select the one from Task 2.4
- Updates: `message`

Click "Listen for test event" → in Telegram, send `/test` to your bot.

Expected: n8n captures the event, shows the JSON body with your message.

- [ ] **Step 3: Add Telegram "Send Message" node**

Click "+" after the trigger, search "Telegram", select "Send a text message".
Configure:
- Credential: same Telegram credential
- Resource: Message
- Operation: Send a text message
- Chat ID: `={{ $json.message.chat.id }}` (use expression mode)
- Text: `Echo: {{ $json.message.text }}`

- [ ] **Step 4: Activate workflow**

Top-right toggle: "Inactive" → "Active". Confirm save.

- [ ] **Step 5: Test in Telegram**

Send `/test merhaba` to your bot.

Expected: Bot replies `Echo: /test merhaba`.

- [ ] **Step 6: Deactivate test workflow**

Toggle back to "Inactive" so it doesn't interfere with later workflows.

### Task 2.8: Phase 2 checkpoint

- [ ] **Step 1: Confirm n8n is running and reachable**

```bash
docker ps --filter "name=weekly-planner-n8n"
curl -s http://localhost:5678/healthz
```

Expected: container UP, healthz returns `{"status":"ok"}`.

- [ ] **Step 2: Confirm 3 credentials saved**

n8n → Credentials list shows: Telegram API, Postgres, OpenAI.

- [ ] **Step 3: Commit any docker/.env.example update if needed**

If you set `N8N_WEBHOOK_URL` via a docker-side .env, add a `docker/.env.example` and commit:

```bash
echo "N8N_WEBHOOK_URL=https://your-ngrok-subdomain.ngrok-free.app/" > docker/.env.example
git add docker/.env.example
git commit -m "docs(docker): document n8n webhook env var"
git push
```

---

## Phase 3 — Workflow 1: Onboarding (Day 3 afternoon, 12 May PM)

> **Pattern note:** n8n state-machine flows for `/profil` and `/hedef` (where the bot asks question 1, waits for reply, asks question 2, etc.) are commonly built with a single workflow that uses a "state" column on a temporary table OR with the **Wait** node. We'll use the simpler pattern: a `user_state` table that stores "what question are we on for this user", and the workflow reads it on every incoming message.

### Task 3.1: Add user_state table to schema

**Files:**
- Modify: `database/01_schema.sql` (add table at end)

- [ ] **Step 1: Append to schema file**

```sql
-- 6. KULLANICI STATE (geçici, soru-cevap akışı için)
CREATE TABLE IF NOT EXISTS user_state (
    telegram_id BIGINT PRIMARY KEY,
    flow TEXT NOT NULL,           -- 'profil' | 'hedef' | 'plan_input' | 'feedback' | 'sil'
    step INT NOT NULL DEFAULT 0,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

- [ ] **Step 2: Apply migration to Supabase**

Run the new statement in Supabase SQL Editor.

Expected: "Success".

- [ ] **Step 3: Commit**

```bash
git add database/01_schema.sql
git commit -m "feat(db): add user_state table for multi-step bot flows"
```

### Task 3.2: Build Workflow 1 base (Telegram Trigger + command Switch)

- [ ] **Step 1: Create workflow `01_onboarding`**

n8n → Workflows → New → name `01_onboarding`.

- [ ] **Step 2: Add Telegram Trigger node**

Same as Task 2.7. Updates: `message`. Save.

- [ ] **Step 3: Add a Code node "Parse Command"**

After trigger. Code node, JavaScript:

```javascript
const msg = $input.first().json.message;
const text = (msg.text || '').trim();
const chatId = msg.chat.id;
const telegramId = msg.from.id;
const firstName = msg.from.first_name || '';

let command = null;
let args = '';
if (text.startsWith('/')) {
  const space = text.indexOf(' ');
  command = (space === -1 ? text : text.slice(0, space)).slice(1);
  args = space === -1 ? '' : text.slice(space + 1);
}

return [{ json: { chatId, telegramId, firstName, command, args, rawText: text } }];
```

- [ ] **Step 4: Add Switch node "Route Command"**

After Code node. Mode: Expression. Output dataset for each:

| Output | Expression |
|---|---|
| start | `{{ $json.command === 'start' }}` |
| profil | `{{ $json.command === 'profil' }}` |
| hedef | `{{ $json.command === 'hedef' }}` |
| sil | `{{ $json.command === 'sil' }}` |
| reply | `{{ !$json.command }}` (free-text answers to ongoing flow) |

- [ ] **Step 5: Save workflow (don't activate yet)**

### Task 3.3: Implement `/start` branch (KVKK welcome)

- [ ] **Step 1: From Switch "start" output, add Telegram "Send Message"**

Configure:
- Credential: Telegram API
- Operation: Send a text message
- Chat ID: `={{ $json.chatId }}`
- Text:

```
Merhaba {{ $json.firstName }} 👋

Ben Beyza Hayat Planlayıcısı. Sana her hafta yapay zekayla kişiselleştirilmiş bir plan üreteceğim.

🔒 KVKK Aydınlatma:
- Verilerin (yaş, hedefler, refleksiyon) Supabase PostgreSQL'de saklanır.
- Plan üretiminde Google Gemini 1.5 Flash API'si kullanılır.
- Üçüncü şahıslarla paylaşılmaz.
- /sil yazarak istediğin an tüm verini silebilirsin.

Devam etmek için /profil yaz.
```

- [ ] **Step 2: Test in Telegram**

Activate workflow. Send `/start` to bot.

Expected: KVKK welcome message arrives.

### Task 3.4: Implement `/profil` flow (8 questions, state machine)

Strategy: When `/profil` is sent, we (a) upsert a `user_state` row with `flow='profil', step=1`, (b) ask question 1. When user replies (no command), we look up `user_state`, save the answer, increment step, ask next question. After step 8, write to `users` table and clear state.

- [ ] **Step 1: From Switch "profil" output, add Postgres node "Init Profil State"**

Configure:
- Credential: Postgres (Supabase)
- Operation: Execute Query
- Query:

```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $json.telegramId }}, 'profil', 1, '{}'::jsonb, NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'profil', step = 1, payload = '{}'::jsonb, updated_at = NOW();
```

- [ ] **Step 2: Add Telegram "Send Message" — Q1**

Connect after the Postgres node above:
- Chat ID: `={{ $('Parse Command').item.json.chatId }}`
- Text: `1/8 — Adın ne? (ya da kullanmak istediğin kod ad)`

- [ ] **Step 3: Implement "reply" branch — looks up state and routes**

From Switch "reply" output, add Postgres node "Get State":

```sql
SELECT * FROM user_state WHERE telegram_id = {{ $json.telegramId }};
```

After Get State, add **IF** node "Has profil flow":
- Condition: `={{ $json.flow === 'profil' }}` is true

If true, add a **Switch** node "Profil Step" routing on `={{ $json.step }}` with outputs 1..8.

- [ ] **Step 4: Step 1 → save ad, ask Q2 (yas)**

After Profil Step output 1:

Postgres "Save Step 1":
```sql
UPDATE user_state
SET payload = payload || jsonb_build_object('ad', '{{ $('Parse Command').item.json.rawText }}'),
    step = 2,
    updated_at = NOW()
WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram "Send Q2":
- Chat ID: `={{ $('Parse Command').item.json.chatId }}`
- Text: `2/8 — Yaşın? (sayı olarak)`

- [ ] **Step 5: Repeat for Q2 (yas) → Q3 (meslek) → Q4 (uyanma) → Q5 (uyku) → Q6 (is_baslangic) → Q7 (is_bitis) → Q8 (enerji_zirvesi)**

For each step N (2 through 7):
- Add Postgres node updating `payload->>field_N` and `step = N+1`
- Add Telegram node asking question N+1

Question text bank:
- Q2: `2/8 — Yaşın? (sayı olarak)`
- Q3: `3/8 — Mesleğin/öğrencilik durumun? (kısa)`
- Q4: `4/8 — Tipik uyanma saatin? (örn: 07:30)`
- Q5: `5/8 — Tipik uyku saatin? (örn: 23:30)`
- Q6: `6/8 — İş/okul başlangıç saatin? (yoksa "yok")`
- Q7: `7/8 — İş/okul bitiş saatin? (yoksa "yok")`
- Q8: `8/8 — Enerji zirven sabah, oglen, yoksa aksam mı?`

For Q6/Q7 ("yok" handling), in the SQL use:
```sql
CASE WHEN '{{ $('Parse Command').item.json.rawText }}' = 'yok' THEN NULL
     ELSE '{{ $('Parse Command').item.json.rawText }}'::time END
```
when finally inserting to `users` (step 8 below). For now, just store the raw text in payload.

- [ ] **Step 6: Step 8 (last) → write users row, clear state, send confirmation**

After Profil Step output 8:

Postgres "Finalize Profil":
```sql
WITH s AS (SELECT payload FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }})
INSERT INTO users (telegram_id, ad, yas, meslek, uyanma_saati, uyku_saati, is_baslangic, is_bitis, enerji_zirvesi, kvkk_onay)
SELECT
  {{ $('Parse Command').item.json.telegramId }},
  s.payload->>'ad',
  (s.payload->>'yas')::int,
  s.payload->>'meslek',
  (s.payload->>'uyanma_saati')::time,
  (s.payload->>'uyku_saati')::time,
  CASE WHEN s.payload->>'is_baslangic' = 'yok' THEN NULL ELSE (s.payload->>'is_baslangic')::time END,
  CASE WHEN s.payload->>'is_bitis' = 'yok' THEN NULL ELSE (s.payload->>'is_bitis')::time END,
  '{{ $('Parse Command').item.json.rawText }}',
  TRUE
FROM s
ON CONFLICT (telegram_id) DO UPDATE SET
  ad = EXCLUDED.ad,
  yas = EXCLUDED.yas,
  meslek = EXCLUDED.meslek,
  uyanma_saati = EXCLUDED.uyanma_saati,
  uyku_saati = EXCLUDED.uyku_saati,
  is_baslangic = EXCLUDED.is_baslangic,
  is_bitis = EXCLUDED.is_bitis,
  enerji_zirvesi = EXCLUDED.enerji_zirvesi,
  kvkk_onay = TRUE,
  updated_at = NOW();

DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram "Profil Done":
- Chat ID: `={{ $('Parse Command').item.json.chatId }}`
- Text: `Profilin kaydedildi ✅\n\nŞimdi 3-5 hedef belirleyelim. /hedef yaz.`

- [ ] **Step 7: Test full /profil flow**

In Telegram: `/start` → `/profil` → reply to all 8 questions.

Verify in Supabase:
```sql
SELECT * FROM users WHERE telegram_id = YOUR_TELEGRAM_ID;
SELECT * FROM user_state WHERE telegram_id = YOUR_TELEGRAM_ID;
```

Expected: `users` row populated, `user_state` row deleted.

### Task 3.5: Implement `/hedef` flow (3 questions per goal)

Strategy: When `/hedef` is sent, set state to `hedef, step=1`, ask category. step=2 ask metin. step=3 ask oncelik. On step=3 finalize INSERT into user_goals, ask "Bir hedef daha? /hedef yaz veya /plan ile başla".

- [ ] **Step 1: From Switch "hedef" output, add Postgres "Init Hedef State"**

```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $json.telegramId }}, 'hedef', 1, '{}'::jsonb, NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'hedef', step = 1, payload = '{}'::jsonb, updated_at = NOW();
```

Telegram "Hedef Q1":
- Text: `Hedef kategori? (kariyer, saglik, sosyal, hobi, ogrenme, aile)`

- [ ] **Step 2: Extend the "Has profil flow" IF node into a Switch on flow type**

Replace the IF with a Switch node "Flow Type":
- profil → existing profil step switch
- hedef → new hedef step switch
- (others added in later tasks)

- [ ] **Step 3: Hedef step 1 → save kategori, ask metin**

```sql
UPDATE user_state
SET payload = payload || jsonb_build_object('kategori', '{{ $('Parse Command').item.json.rawText }}'),
    step = 2, updated_at = NOW()
WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Hedef metni? (kısa cümle)`

- [ ] **Step 4: Hedef step 2 → save metin, ask oncelik**

```sql
UPDATE user_state
SET payload = payload || jsonb_build_object('hedef_metin', '{{ $('Parse Command').item.json.rawText }}'),
    step = 3, updated_at = NOW()
WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Öncelik? (1=düşük, 5=yüksek)`

- [ ] **Step 5: Hedef step 3 → finalize INSERT, clear state**

```sql
WITH s AS (SELECT payload FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }}),
     u AS (SELECT id FROM users WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }})
INSERT INTO user_goals (user_id, kategori, hedef_metin, oncelik)
SELECT u.id, s.payload->>'kategori', s.payload->>'hedef_metin', {{ $('Parse Command').item.json.rawText }}::int
FROM s, u;

DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Hedef eklendi ✅ Bir hedef daha için /hedef, plan üretmek için /plan yaz.`

- [ ] **Step 6: Test full /hedef flow (add 2-3 goals)**

Verify: `SELECT * FROM user_goals WHERE user_id = (SELECT id FROM users WHERE telegram_id = YOUR_ID);` returns rows.

### Task 3.6: Implement `/sil` flow (confirmation + cascade delete)

- [ ] **Step 1: From Switch "sil" output, add Postgres "Init Sil State"**

```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $json.telegramId }}, 'sil', 1, '{}'::jsonb, NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'sil', step = 1, payload = '{}'::jsonb, updated_at = NOW();
```

Telegram: `⚠️ Tüm verin (profil, hedefler, planlar, geri bildirim) silinecek. Onaylamak için EVET yaz, vazgeçmek için başka bir şey yaz.`

- [ ] **Step 2: Add "sil" branch to Flow Type switch**

Output → Sil Step Switch (only step 1 needed).

- [ ] **Step 3: Sil step 1 → IF EVET → DELETE; ELSE → cancel**

IF node: condition `={{ $('Parse Command').item.json.rawText.toUpperCase() === 'EVET' }}`

If TRUE:

Postgres:
```sql
DELETE FROM users WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Tüm verin silindi. /start ile her zaman geri dönebilirsin. 👋`

If FALSE:

Postgres:
```sql
DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Silme iptal edildi. ✅`

- [ ] **Step 4: Test /sil flow with both EVET and other answer**

### Task 3.7: Export workflow JSON and commit

- [ ] **Step 1: Open workflow → top-right ⋯ → Download**

Save to `n8n-workflows/01_onboarding.json` in the project.

- [ ] **Step 2: Create folder if missing**

```bash
mkdir -p n8n-workflows
mv ~/Downloads/01_onboarding.json n8n-workflows/
```

(Adjust path to wherever your browser saves downloads.)

- [ ] **Step 3: Commit**

```bash
git add n8n-workflows/01_onboarding.json
git commit -m "feat(n8n): add onboarding workflow (start, profil, hedef, sil)"
git push
```

---

## Phase 4 — Workflows 2 & 3: Plan Generator (Day 4, 13 May)

### Task 4.1: Write system prompt to file

**Files:**
- Create: `prompts/system_prompt.md`

- [ ] **Step 1: Create prompts folder and file**

```bash
mkdir -p prompts
```

Write `prompts/system_prompt.md` with the EXACT system prompt from the design spec section 8 (copy verbatim from `docs/superpowers/specs/2026-05-10-weekly-life-planner-ai-design.md`).

- [ ] **Step 2: Commit**

```bash
git add prompts/system_prompt.md
git commit -m "feat(prompt): add AI system prompt"
```

### Task 4.2: Write user prompt template

**Files:**
- Create: `prompts/user_prompt_template.md`

- [ ] **Step 1: Write template**

```markdown
KULLANICI PROFİLİ:
- Ad: {{ad}}
- Yaş: {{yas}}, Meslek: {{meslek}}
- Uyanma: {{uyanma_saati}}, Uyku: {{uyku_saati}}
- İş saatleri: {{is_baslangic}} – {{is_bitis}}
- Enerji zirvesi: {{enerji_zirvesi}}

AKTİF HEDEFLER:
{{hedefler_listesi}}

GEÇEN HAFTA REFLEKSİYONU:
- Genel puan: {{gecen_hafta_puan}}/10
- İyi giden: {{gecen_hafta_iyi}}
- Zorlayan: {{gecen_hafta_kotu}}

BU HAFTA:
- Sabit etkinlikler: {{bu_hafta_etkinlikler}}
- Öngörülen enerji: {{enerji_seviyesi}}/10
- Hafta tarihleri: {{hafta_baslangic}} – {{hafta_bitis}}

Bu kullanıcıya yukarıdaki kurallara uygun JSON haftalık plan üret.
```

- [ ] **Step 2: Commit**

```bash
git add prompts/user_prompt_template.md
git commit -m "feat(prompt): add user prompt template"
```

### Task 4.3: Build Workflow 2 — `/plan` weekly input collection

n8n → Workflows → New → name `02_weekly_input`.

- [ ] **Step 1: Add Telegram Trigger + Parse Command + Switch (same pattern as Workflow 1)**

Easier path: **Duplicate `01_onboarding`** and trim down. In n8n, click the `01_onboarding` workflow → ⋯ → Duplicate → rename to `02_weekly_input`. Delete all branches except trigger + parse + switch.

- [ ] **Step 2: Switch outputs**

| Output | Expression |
|---|---|
| plan | `{{ $json.command === 'plan' }}` |
| reply | `{{ !$json.command }}` |

- [ ] **Step 3: From "plan" output: check user exists**

Postgres "Check User":
```sql
SELECT id FROM users WHERE telegram_id = {{ $json.telegramId }};
```

IF "User exists": condition `={{ $json.length > 0 }}` (use `$('Check User').all().length > 0` if needed).

If FALSE → Telegram: `Önce /profil ile profilini gir, sonra /plan yaz.` (END)

If TRUE → continue:

- [ ] **Step 4: Init weekly input state**

Postgres "Init Plan State":
```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $('Parse Command').item.json.telegramId }}, 'plan_input', 1, '{}'::jsonb, NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'plan_input', step = 1, payload = '{}'::jsonb, updated_at = NOW();
```

Telegram Q1: `1/4 — Geçen hafta nasıldı? 1-10 arası puan ver.`

- [ ] **Step 5: Reply branch → load state → if flow='plan_input', route on step**

Same pattern as workflow 1 (Get State → Switch on flow → Switch on step). For plan_input, 4 steps:

Step 1 save → ask Q2: `2/4 — Ne iyi gitti? (kısa açıklama)`
Step 2 save → ask Q3: `3/4 — Ne zorladı?`
Step 3 save → ask Q4: `4/4 — Bu hafta sabit etkinliklerin neler? (toplantı, sınav, vs)`

- [ ] **Step 6: Step 4 (last) → save weekly_input, trigger plan generator webhook**

Postgres "Save Weekly Input":
```sql
WITH s AS (SELECT payload FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }}),
     u AS (SELECT id FROM users WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }})
INSERT INTO weekly_inputs (user_id, hafta_baslangic, gecen_hafta_puan, gecen_hafta_iyi, gecen_hafta_kotu, bu_hafta_etkinlikler, enerji_seviyesi)
SELECT u.id,
       date_trunc('week', CURRENT_DATE)::date,  -- bu haftanın Pazartesi'si
       (s.payload->>'puan')::int,
       s.payload->>'iyi',
       s.payload->>'kotu',
       '{{ $('Parse Command').item.json.rawText }}',
       6  -- default enerji, daha sonra eklenebilir
FROM s, u
ON CONFLICT (user_id, hafta_baslangic) DO UPDATE SET
  gecen_hafta_puan = EXCLUDED.gecen_hafta_puan,
  gecen_hafta_iyi = EXCLUDED.gecen_hafta_iyi,
  gecen_hafta_kotu = EXCLUDED.gecen_hafta_kotu,
  bu_hafta_etkinlikler = EXCLUDED.bu_hafta_etkinlikler
RETURNING id, user_id;

DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Teşekkürler! Şimdi planını üretiyorum, biraz bekle... ⏳`

HTTP Request "Trigger Plan Generator":
- Method: POST
- URL: `http://localhost:5678/webhook/generate-plan` (we'll create this webhook in Workflow 3)
- Body (JSON):
```json
{
  "weekly_input_id": "={{ $('Save Weekly Input').item.json.id }}",
  "user_id": "={{ $('Save Weekly Input').item.json.user_id }}",
  "telegram_id": "={{ $('Parse Command').item.json.telegramId }}",
  "chat_id": "={{ $('Parse Command').item.json.chatId }}"
}
```

- [ ] **Step 7: Save and activate Workflow 2**

### Task 4.4: Build Workflow 3 — Plan Generator

n8n → Workflows → New → `03_plan_generator`.

- [ ] **Step 1: Webhook Trigger**

Add "Webhook" node:
- HTTP Method: POST
- Path: `generate-plan`
- Response Mode: "When Last Node Finishes"

Test webhook URL shown: e.g., `http://localhost:5678/webhook-test/generate-plan`. The active URL drops `-test`.

- [ ] **Step 2: Postgres "Load User Data"**

Query (uses `$json.user_id` from webhook body):

```sql
SELECT
  u.ad, u.yas, u.meslek,
  to_char(u.uyanma_saati, 'HH24:MI') AS uyanma_saati,
  to_char(u.uyku_saati, 'HH24:MI') AS uyku_saati,
  COALESCE(to_char(u.is_baslangic, 'HH24:MI'), 'yok') AS is_baslangic,
  COALESCE(to_char(u.is_bitis, 'HH24:MI'), 'yok') AS is_bitis,
  u.enerji_zirvesi
FROM users u
WHERE u.id = '{{ $json.user_id }}';
```

- [ ] **Step 3: Postgres "Load Goals"**

```sql
SELECT kategori, hedef_metin, oncelik
FROM user_goals
WHERE user_id = '{{ $('Webhook').item.json.user_id }}' AND aktif = TRUE
ORDER BY oncelik DESC;
```

- [ ] **Step 4: Postgres "Load Weekly Input"**

```sql
SELECT
  to_char(hafta_baslangic, 'YYYY-MM-DD') AS hafta_baslangic,
  to_char(hafta_baslangic + INTERVAL '6 days', 'YYYY-MM-DD') AS hafta_bitis,
  gecen_hafta_puan, gecen_hafta_iyi, gecen_hafta_kotu,
  bu_hafta_etkinlikler, enerji_seviyesi
FROM weekly_inputs
WHERE id = '{{ $('Webhook').item.json.weekly_input_id }}';
```

- [ ] **Step 5: Code node "Build Prompts"**

JavaScript:

```javascript
const user = $('Load User Data').first().json;
const goals = $('Load Goals').all().map(g => g.json);
const wi = $('Load Weekly Input').first().json;

const hedeflerListesi = goals.length === 0
  ? '(henüz hedef girilmemiş)'
  : goals.map(g => `- [${g.kategori}, öncelik ${g.oncelik}] ${g.hedef_metin}`).join('\n');

const userPrompt = `KULLANICI PROFİLİ:
- Ad: ${user.ad}
- Yaş: ${user.yas}, Meslek: ${user.meslek || '-'}
- Uyanma: ${user.uyanma_saati}, Uyku: ${user.uyku_saati}
- İş saatleri: ${user.is_baslangic} – ${user.is_bitis}
- Enerji zirvesi: ${user.enerji_zirvesi}

AKTİF HEDEFLER:
${hedeflerListesi}

GEÇEN HAFTA REFLEKSİYONU:
- Genel puan: ${wi.gecen_hafta_puan}/10
- İyi giden: ${wi.gecen_hafta_iyi || '-'}
- Zorlayan: ${wi.gecen_hafta_kotu || '-'}

BU HAFTA:
- Sabit etkinlikler: ${wi.bu_hafta_etkinlikler || '-'}
- Öngörülen enerji: ${wi.enerji_seviyesi}/10
- Hafta tarihleri: ${wi.hafta_baslangic} – ${wi.hafta_bitis}

Bu kullanıcıya yukarıdaki kurallara uygun JSON haftalık plan üret.`;

const systemPrompt = `Sen "Hayat Planlayıcısı" adında bir yapay zeka koçsun.
Görevin: kullanıcının profili, hedefleri ve geçen hafta deneyimine
bakarak SMART, gerçekçi, sürdürülebilir bir HAFTALIK plan üretmek.

KURALLAR:
1. Türkçe yaz, sıcak ama profesyonel ton kullan.
2. Aşırı yüklenme. Maksimum 3 ana hedef. Günde maksimum 3 zaman bloku.
3. Kullanıcının uyanma/uyku saatlerine MUTLAKA saygı göster.
4. Geçen hafta puanı 5'in altındaysa bu haftayı HAFİFLET, dinlenme öner.
5. Bu hafta sabit etkinlikleri (toplantı, sınav vb.) plana dahil et.
6. Asla tıbbi, mali veya hukuki tavsiye verme.
7. JSON formatında döndür, şema sabit, başka metin YAZMA.
8. Motivasyon notunu kullanıcının adıyla kişiselleştir.

ÇIKTI ŞEMASI (JSON):
{
  "hafta_basligi": "12-18 Mayıs 2026",
  "ana_hedefler": ["...", "...", "..."],
  "gunluk_plan": {
    "pazartesi": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "sali": {...}, "carsamba": {...}, "persembe": {...},
    "cuma": {...}, "cumartesi": {...}, "pazar": {...}
  },
  "haftalik_aliskanliklar": ["...", "...", "..."],
  "refleksiyon_sorulari": ["...", "...", "..."],
  "motivasyon_notu": "..."
}`;

return [{ json: { systemPrompt, userPrompt, weekHeader: `${wi.hafta_baslangic} – ${wi.hafta_bitis}` } }];
```

- [ ] **Step 6: HTTP Request node "Generate Plan via Gemini"**

We use HTTP Request directly because it's version-stable across n8n updates and works without installing community nodes.

- Method: `POST`
- URL: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`
- Authentication: Generic Credential Type → Query Auth
  - Name: `key`
  - Value: `={{ $env.GEMINI_API_KEY }}` (or paste directly if env not configured in n8n)
- Send Body: ON, Body Content Type: JSON, Specify Body: Using JSON
- JSON body:

```json
{
  "systemInstruction": {
    "parts": [{ "text": "={{ $json.systemPrompt }}" }]
  },
  "contents": [
    {
      "role": "user",
      "parts": [{ "text": "={{ $json.userPrompt }}" }]
    }
  ],
  "generationConfig": {
    "temperature": 0.4,
    "maxOutputTokens": 2000,
    "responseMimeType": "application/json"
  }
}
```

Expected response shape:
```json
{
  "candidates": [{
    "content": {
      "parts": [{ "text": "{\"hafta_basligi\":\"...\", ...}" }]
    }
  }],
  "usageMetadata": {
    "promptTokenCount": 450,
    "candidatesTokenCount": 1200
  }
}
```

> **Alternatif:** n8n Settings → Community Nodes → install `@n8n/n8n-nodes-langchain` → use "Google Gemini Chat Model" node. HTTP Request is simpler for first version.

- [ ] **Step 7: Code node "Parse and Format"**

```javascript
const raw = $input.first().json;
// Gemini returns: candidates[0].content.parts[0].text (a JSON string)
const text = raw.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
const planJson = JSON.parse(text);

const promptTokens = raw.usageMetadata?.promptTokenCount || 0;
const completionTokens = raw.usageMetadata?.candidatesTokenCount || 0;

// Markdown formatla (3 mesaj boyunda olacak şekilde böl)
const dayNames = {
  pazartesi: 'Pazartesi', sali: 'Salı', carsamba: 'Çarşamba',
  persembe: 'Perşembe', cuma: 'Cuma', cumartesi: 'Cumartesi', pazar: 'Pazar'
};
const days = planJson.gunluk_plan || {};
const dailyMd = Object.keys(days).map(d => {
  const blok = days[d] || {};
  return `*${dayNames[d] || d}*\n• Sabah: ${blok.sabah || '-'}\n• Öğle: ${blok.ogle || '-'}\n• Akşam: ${blok.aksam || '-'}`;
}).join('\n\n');

const msg1 = `📅 *${planJson.hafta_basligi || 'Haftalık Plan'}*\n\n*🎯 Ana Hedefler*\n${(planJson.ana_hedefler || []).map((h,i) => `${i+1}. ${h}`).join('\n')}\n\n*💪 Motivasyon*\n${planJson.motivasyon_notu || ''}`;
const msg2 = `*🗓️ Günlük Plan*\n\n${dailyMd}`;
const msg3 = `*🔁 Haftalık Alışkanlıklar*\n${(planJson.haftalik_aliskanliklar || []).map(a => `• ${a}`).join('\n')}\n\n*🤔 Pazar Refleksiyonu*\n${(planJson.refleksiyon_sorulari || []).map((r,i) => `${i+1}. ${r}`).join('\n')}`;

return [{
  json: {
    plan_json: planJson,
    plan_markdown: `${msg1}\n\n${msg2}\n\n${msg3}`,
    msg1, msg2, msg3,
    prompt_token: promptTokens,
    completion_token: completionTokens
  }
}];
```

- [ ] **Step 8: Postgres "Save Plan"**

```sql
INSERT INTO plans (user_id, weekly_input_id, hafta_baslangic, plan_json, plan_markdown, model_kullanilan, prompt_token, completion_token)
VALUES (
  '{{ $('Webhook').item.json.user_id }}',
  '{{ $('Webhook').item.json.weekly_input_id }}',
  date_trunc('week', CURRENT_DATE)::date,
  '{{ JSON.stringify($json.plan_json) }}'::jsonb,
  $${{ $json.plan_markdown }}$$,
  'gemini-1.5-flash',
  {{ $json.prompt_token }},
  {{ $json.completion_token }}
)
RETURNING id;
```

(`$$...$$` is Postgres's dollar-quoted string — handles markdown special chars cleanly.)

- [ ] **Step 9: Three Telegram "Send Message" nodes (msg1, msg2, msg3)**

For each:
- Chat ID: `={{ $('Webhook').item.json.chat_id }}`
- Text: `={{ $('Parse and Format').item.json.msg1 }}` (then msg2, msg3)
- Parse Mode: Markdown

Connect sequentially.

After msg3, add a final Telegram: `Plan tamam ✅\n\n/geri_bildirim ile puan ver, /gecmis ile eski planları gör.`

- [ ] **Step 10: Activate Workflow 3, then test full /plan flow**

In Telegram: `/plan` → answer 4 questions → wait ~10 sec → 4 messages arrive (3 plan parts + closing).

Verify in Supabase:
```sql
SELECT hafta_baslangic, plan_json->>'hafta_basligi', model_kullanilan, prompt_token, completion_token
FROM plans
ORDER BY created_at DESC LIMIT 1;
```

Expected: row inserted, JSON valid, tokens populated.

### Task 4.5: Iterate on prompt quality

- [ ] **Step 1: Check the produced plan**

Read your Telegram messages. Is the plan:
- In Turkish? ✓
- Respecting your wake/sleep times? ✓
- 7 days included? ✓
- Maximum 3 main goals? ✓
- Realistic? (no "8 hours of running daily")

If NO on any: edit `prompts/system_prompt.md` AND the system prompt in the Code node "Build Prompts" of Workflow 3 — keep them in sync.

- [ ] **Step 2: Re-run /plan and verify improvement**

- [ ] **Step 3: Commit prompt changes if any**

```bash
git add prompts/system_prompt.md
git commit -m "fix(prompt): improve plan realism and Turkish quality"
```

### Task 4.6: Export Workflows 2 and 3, commit

- [ ] **Step 1: Export both as JSON**

```bash
# After downloading from n8n UI:
mv ~/Downloads/02_weekly_input.json n8n-workflows/
mv ~/Downloads/03_plan_generator.json n8n-workflows/
```

- [ ] **Step 2: Commit**

```bash
git add n8n-workflows/02_weekly_input.json n8n-workflows/03_plan_generator.json
git commit -m "feat(n8n): add weekly_input and plan_generator workflows"
git push
```

---

## Phase 5 — Workflows 4 & 5: Feedback + Cron + History (Day 5, 14 May)

### Task 5.1: Build Workflow 4 — `/geri_bildirim`

n8n → New → `04_feedback`. Same trigger/parse/switch pattern.

- [ ] **Step 1: Switch outputs: `geri_bildirim`, `reply`**

- [ ] **Step 2: From `geri_bildirim`: load latest plan**

Postgres "Find Latest Plan":
```sql
SELECT p.id
FROM plans p
JOIN users u ON u.id = p.user_id
WHERE u.telegram_id = {{ $json.telegramId }}
ORDER BY p.created_at DESC LIMIT 1;
```

IF no plan → Telegram: `Henüz planın yok. Önce /plan yaz.` (END)

If plan exists → save plan_id to state, ask for puan:

```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $('Parse Command').item.json.telegramId }}, 'feedback', 1,
        jsonb_build_object('plan_id', '{{ $('Find Latest Plan').item.json.id }}'),
        NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'feedback', step = 1, payload = EXCLUDED.payload, updated_at = NOW();
```

Telegram: `Son plana 1-5 arası puan ver. (5 = mükemmel, 1 = işe yaramadı)`

- [ ] **Step 3: Reply branch (flow=feedback) → step 1: save puan, ask yorum**

```sql
UPDATE user_state
SET payload = payload || jsonb_build_object('puan', '{{ $('Parse Command').item.json.rawText }}'),
    step = 2, updated_at = NOW()
WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Yorumun? (boş geç için "yok" yaz)`

- [ ] **Step 4: Step 2 → finalize INSERT**

```sql
WITH s AS (SELECT payload FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }})
INSERT INTO feedback (plan_id, puan, yorum)
SELECT (s.payload->>'plan_id')::uuid,
       (s.payload->>'puan')::int,
       CASE WHEN '{{ $('Parse Command').item.json.rawText }}' = 'yok' THEN NULL ELSE '{{ $('Parse Command').item.json.rawText }}' END
FROM s;

DELETE FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }};
```

Telegram: `Geri bildirimin için teşekkürler 🙏`

- [ ] **Step 5: Test, export, commit**

```bash
mv ~/Downloads/04_feedback.json n8n-workflows/
git add n8n-workflows/04_feedback.json
git commit -m "feat(n8n): add feedback workflow"
```

### Task 5.2: Add `/gecmis` command (extend Workflow 4 or new workflow)

Decision: keep it simple, add `/gecmis` as a separate output in Workflow 4's Switch.

- [ ] **Step 1: Add `gecmis` output in Workflow 4 switch**

Expression: `{{ $json.command === 'gecmis' }}`

- [ ] **Step 2: From gecmis: query last 4 plans**

Postgres "Load History":
```sql
SELECT p.id, to_char(p.hafta_baslangic, 'DD Mon YYYY') AS hafta,
       p.plan_json->>'hafta_basligi' AS basligi
FROM plans p
JOIN users u ON u.id = p.user_id
WHERE u.telegram_id = {{ $json.telegramId }}
ORDER BY p.hafta_baslangic DESC
LIMIT 4;
```

- [ ] **Step 3: Code node "Format List"**

```javascript
const rows = $input.all().map(r => r.json);
if (rows.length === 0) {
  return [{ json: { text: 'Henüz planın yok. /plan yaz.' } }];
}
const list = rows.map((r, i) => `${i+1}. ${r.hafta} — ${r.basligi || '(başlık yok)'}`).join('\n');
return [{ json: { text: `Son ${rows.length} plan:\n\n${list}\n\nGörmek istediğin plan numarasını yaz.` , plan_ids: rows.map(r => r.id) } }];
```

- [ ] **Step 4: Save state for selection**

Postgres "Save List State":
```sql
INSERT INTO user_state (telegram_id, flow, step, payload, updated_at)
VALUES ({{ $('Parse Command').item.json.telegramId }}, 'gecmis', 1,
        jsonb_build_object('plan_ids', '{{ JSON.stringify($('Format List').item.json.plan_ids) }}'::jsonb),
        NOW())
ON CONFLICT (telegram_id) DO UPDATE
SET flow = 'gecmis', step = 1, payload = EXCLUDED.payload, updated_at = NOW();
```

Telegram: `={{ $('Format List').item.json.text }}`

- [ ] **Step 5: Reply branch (flow=gecmis) → fetch and show**

```sql
WITH s AS (SELECT payload FROM user_state WHERE telegram_id = {{ $('Parse Command').item.json.telegramId }}),
     idx AS (SELECT ({{ $('Parse Command').item.json.rawText }}::int - 1) AS i),
     pid AS (SELECT (s.payload->'plan_ids'->>(SELECT i FROM idx))::uuid AS plan_id FROM s)
SELECT plan_markdown FROM plans WHERE id = (SELECT plan_id FROM pid);
```

Telegram: `={{ $json.plan_markdown }}` (Markdown parse mode)

Then DELETE state.

- [ ] **Step 6: Test /gecmis flow**

Send `/gecmis`, see list, send `1`, see first plan.

- [ ] **Step 7: Re-export workflow JSON, commit**

```bash
mv ~/Downloads/04_feedback.json n8n-workflows/
git add n8n-workflows/04_feedback.json
git commit -m "feat(n8n): add /gecmis command to feedback workflow"
```

### Task 5.3: Build Workflow 5 — Sunday 20:00 cron

n8n → New → `05_weekly_cron`.

- [ ] **Step 1: Schedule Trigger node**

- Mode: Custom Cron Expression
- Expression: `0 20 * * 0` (every Sunday 20:00, in n8n's timezone which we set to Istanbul in docker-compose)

- [ ] **Step 2: Postgres "Find Active Users with No Plan This Week"**

```sql
SELECT u.id AS user_id, u.telegram_id, u.ad
FROM users u
WHERE u.kvkk_onay = TRUE
  AND NOT EXISTS (
    SELECT 1 FROM plans p
    WHERE p.user_id = u.id
      AND p.hafta_baslangic = date_trunc('week', CURRENT_DATE)::date
  );
```

- [ ] **Step 3: For each user, send Telegram nudge**

After Postgres node, "Loop Over Items" splits results.

Inside loop:
- Telegram: `Merhaba {{ $json.ad }}! 🌟\n\nBu hafta için planını oluşturmaya hazır mısın? /plan yazarak başlayalım.`
- Chat ID: `={{ $json.telegram_id }}`

- [ ] **Step 4: Activate cron**

Top-right toggle to Active.

- [ ] **Step 5: Test cron manually**

In n8n, open the Schedule Trigger node → "Execute Workflow" button (manual trigger).

Verify all eligible users get the nudge in Telegram.

- [ ] **Step 6: Export and commit**

```bash
mv ~/Downloads/05_weekly_cron.json n8n-workflows/
git add n8n-workflows/05_weekly_cron.json
git commit -m "feat(n8n): add Sunday 20:00 weekly nudge cron"
git push
```

### Task 5.4: End-to-end smoke test

- [ ] **Step 1: Use a fresh Telegram account if possible (or /sil first)**

```
/sil → EVET
/start
/profil → 8 answers
/hedef → 3 categories (run 3 times)
/plan → 4 answers → see plan arrive
/geri_bildirim → 4 → "iyi plandı"
/gecmis → 1 → see first plan
```

- [ ] **Step 2: Verify Supabase rows exist**

```sql
SELECT 'users' AS t, COUNT(*) FROM users
UNION ALL SELECT 'goals', COUNT(*) FROM user_goals
UNION ALL SELECT 'inputs', COUNT(*) FROM weekly_inputs
UNION ALL SELECT 'plans', COUNT(*) FROM plans
UNION ALL SELECT 'feedback', COUNT(*) FROM feedback;
```

Expected: each ≥ 1.

- [ ] **Step 3: Run `gh repo view --web` and verify all 5 workflow JSON files visible in `n8n-workflows/`**

---

## Phase 6 — Polish: Screenshots, Docs (Day 6, 15 May)

### Task 6.1: Take screenshots

**Files (in order):**
- Create: `screenshots/01_telegram_demo.png`
- Create: `screenshots/02_supabase_tables.png`
- Create: `screenshots/03_n8n_workflows_list.png`
- Create: `screenshots/04_workflow3_canvas.png`
- Create: `screenshots/05_er_diagram.png` (copy from `database/er_diagram.png`)

- [ ] **Step 1: Telegram demo**

Open Telegram desktop, scroll to a recent /plan exchange showing 4 question answers + 4 plan messages. Use Win+Shift+S, save as `screenshots/01_telegram_demo.png`.

- [ ] **Step 2: Supabase tables**

Open Supabase dashboard → Table Editor → click `plans` table → screenshot showing rows. Save as `02_supabase_tables.png`.

- [ ] **Step 3: n8n workflows list**

http://localhost:5678/workflows → screenshot showing 5 workflows. Save as `03_n8n_workflows_list.png`.

- [ ] **Step 4: Workflow 3 canvas**

Open `03_plan_generator` → screenshot the full canvas (use browser zoom-out so all nodes fit). Save as `04_workflow3_canvas.png`.

- [ ] **Step 5: ER diagram**

```bash
cp database/er_diagram.png screenshots/05_er_diagram.png
```

- [ ] **Step 6: Commit**

```bash
git add screenshots/
git commit -m "docs: add demo screenshots"
```

### Task 6.2: Write detailed README

Replace `README.md` with detailed version.

- [ ] **Step 1: Write the full README**

Create `README.md` (overwrite skeleton):

````markdown
# weekly-life-planner-ai

> Yapay zeka destekli haftalık yaşam planlayıcısı — Telegram + n8n + Supabase + Google Gemini 1.5 Flash

**Yazar:** Beyza Ata · [@ataabeeyzaa](https://github.com/ataabeeyzaa)
**Ders:** Veri Tabanı (Database-AI Entegrasyonu) — Mayıs 2026

## Neden?

Modern hayatta haftalık planlama 3 sebepten zor: (1) bilişsel yük (hedef + takvim + alışkanlık), (2) sürekli iyileşmemen (her hafta sıfırdan başlar), (3) tek size uyacak şablon yok. Bu sistem profilinizi ve geçen hafta refleksiyonunuzu PostgreSQL'de tutar, AI ile size özel plan üretir, Telegram'dan gönderir.

## Demo

![Telegram Demo](screenshots/01_telegram_demo.png)

🎬 **Video:** [YouTube linki](VIDEO_LINK_BURAYA) (Phase 7'de eklenecek)

## Mimari

```
Kullanıcı (Telegram) ↔ n8n (Docker) ↔ Supabase PostgreSQL + Google Gemini 1.5 Flash
```

5 workflow: 4 komut işleyici + 1 Pazar 20:00 cron.

![Workflows](screenshots/03_n8n_workflows_list.png)

## Veritabanı Şeması

5 tablo, 5 foreign key. Detay: [docs/database-schema.md](docs/database-schema.md)

![ER Diagram](screenshots/05_er_diagram.png)

## Kurulum

### Önkoşullar

- Docker Desktop
- GitHub CLI (`gh`)
- Supabase hesabı (ücretsiz)
- Telegram Bot (BotFather'dan)
- OpenAI API key (gpt-4o-mini için $0.15/1M token)

### Adımlar

1. **Repo'yu klonla:**
   ```bash
   git clone https://github.com/ataabeeyzaa/weekly-life-planner-ai.git
   cd weekly-life-planner-ai
   ```

2. **`.env` dosyası oluştur:**
   ```bash
   cp .env.example .env
   # .env dosyasını aç, API key'leri ve Supabase credentials gir
   ```

3. **Supabase'i kur:**
   ```bash
   # Supabase SQL editöründe çalıştır:
   # database/01_schema.sql (önce)
   # database/02_seed_data.sql (test için, opsiyonel)
   ```

4. **n8n'i Docker ile başlat:**
   ```bash
   cd docker
   docker compose up -d
   # http://localhost:5678 → setup wizard
   ```

5. **n8n'de credentials ekle:**
   - Telegram API (BotFather token)
   - Postgres (Supabase DB connection)
   - OpenAI (API key)

6. **Workflow'ları içe aktar:**
   - n8n → Workflows → Import → `n8n-workflows/01_onboarding.json`
   - Aynı şekilde 02, 03, 04, 05 için tekrarla
   - Her workflow için credentials'ı seç ve "Active" et

7. **Telegram'da boto `/start` yaz**

## Komutlar

| Komut | Ne yapar |
|---|---|
| `/start` | KVKK metni + karşılama |
| `/profil` | Profil verisi gir/güncelle |
| `/hedef` | Yeni hedef ekle |
| `/plan` | Bu hafta için plan iste |
| `/gecmis` | Son 4 planı listele |
| `/geri_bildirim` | Son plana puan ver |
| `/sil` | Tüm verini sil (KVKK) |

## AI Prompt

System ve user prompt'lar `prompts/` klasöründe. Model: `gpt-4o-mini`, temperature `0.4`, JSON mode.

## Veri Güvenliği (KVKK)

- Aydınlatılmış onay `/start`'ta gösterilir, `/profil` ile alınır.
- Veri sadece Supabase EU-Frankfurt bölgesinde saklanır.
- OpenAI API üzerinden gönderilen veri eğitime dahil değildir (default).
- `/sil` ile cascade delete (1 SQL ile tüm veriyi siler).

## Lisans

MIT — bkz. [LICENSE](LICENSE).

## IEEE Makalesi

[docs/ieee-paper/](docs/ieee-paper/) altında bulunur.
````

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: expand README with screenshots, install steps, commands"
git push
```

### Task 6.3: Write architecture.md and database-schema.md

**Files:**
- Create: `docs/architecture.md`
- Create: `docs/database-schema.md`

- [ ] **Step 1: Write architecture.md**

Briefly: copy section 3 (mimari) and section 7 (workflow'lar) from spec, with screenshots.

- [ ] **Step 2: Write database-schema.md**

Copy section 5 from spec, plus the queries from `database/03_useful_queries.sql` with explanations.

- [ ] **Step 3: Commit**

```bash
git add docs/architecture.md docs/database-schema.md
git commit -m "docs: add architecture and database-schema docs"
git push
```

---

## Phase 7 — Demo Video (Day 7, 16 May)

### Task 7.1: Write video script

**Files:**
- Create: `demo-video/script.md`

- [ ] **Step 1: Write 6-minute script**

```markdown
# Demo Video Script (~6 dakika)

## 0:00–0:30 — Giriş (webcam)
"Merhaba, ben Beyza Ata. Veri Tabanı dersi için yaptığım projeyi anlatacağım: AI Haftalık Yaşam Planlayıcısı. Telegram, n8n, Supabase ve OpenAI'yi kullanıyor."

## 0:30–1:15 — Mimari (slide veya whiteboard)
"Sistem şu şekilde çalışıyor: kullanıcı Telegram'da botuma yazıyor. Mesaj n8n'e webhook olarak geliyor. n8n Supabase'den profil verisini çekiyor, OpenAI'ya gönderiyor, gelen JSON planı tekrar Supabase'e yazıp Telegram'a gönderiyor."

## 1:15–2:15 — Veritabanı (Supabase ekranı)
"5 tablom var: users, user_goals, weekly_inputs, plans, feedback. Plans tablosunda plan_json bir JSONB sütun, Postgres'in JSON sorgu yetenekleri sayesinde plan içindeki hedeflerle filtreleme yapabiliyorum. ER diyagramına bakalım..."

## 2:15–3:45 — n8n Workflow'lar
"5 workflow'um var. 01_onboarding kullanıcının kayıt akışı. 03_plan_generator AI çağrısının yapıldığı yer. Şuradaki webhook node'u workflow 2'den tetikleniyor, ardından profil + hedefler + refleksiyon birleştirilip OpenAI'ya gönderiliyor..."

## 3:45–5:30 — CANLI DEMO (Telegram + Supabase yan yana)
"Şimdi telefondan canlı bir plan üreteyim. /plan yazıyorum... 4 soruya cevap veriyorum... ve 10 saniye içinde planım geliyor. Aynı anda Supabase'de plans tablosuna yeni satır düştüğünü görelim..."

## 5:30–5:50 — KVKK
"Tüm veri kullanıcının kontrolünde. /sil komutu CASCADE ile her şeyi siler. OpenAI API'sine sadece kod adı gönderiliyor."

## 5:50–6:00 — Kapanış
"Repo: github.com/ataabeeyzaa/weekly-life-planner-ai. Teşekkürler!"
```

- [ ] **Step 2: Commit**

```bash
mkdir -p demo-video
git add demo-video/script.md
git commit -m "docs(video): add demo video script"
```

### Task 7.2: Install and configure OBS Studio

- [ ] **Step 1: Install OBS**

```powershell
winget install --id OBSProject.OBSStudio --accept-source-agreements --accept-package-agreements
```

- [ ] **Step 2: Run OBS, complete auto-config wizard**

Choose: "Optimize for recording, I will not be streaming". Resolution: 1920x1080, FPS: 30.

- [ ] **Step 3: Set up scenes**

- Scene 1: "Webcam" — webcam fullscreen
- Scene 2: "Screen + Webcam" — display capture + webcam corner
- Scene 3: "Screen Only" — display capture only

### Task 7.3: Record video

- [ ] **Step 1: Open all needed windows BEFORE recording**

- Telegram desktop
- Browser tab 1: Supabase Table Editor
- Browser tab 2: n8n workflows
- Browser tab 3: dbdiagram.io showing your ER diagram
- Note app with the script

- [ ] **Step 2: Test audio level**

Speak normally — peak should hit yellow, not red.

- [ ] **Step 3: Record in 3-4 takes (each section)**

OBS → Start Recording → speak → stop. Repeat per section. Don't try to do it all in one take.

Recordings save to `Videos/` by default.

- [ ] **Step 4: Stitch with Clipchamp or Shotcut**

Free options:
- Windows Clipchamp (preinstalled): drag clips in order, export 1080p MP4.
- Shotcut (`winget install --id Meltytech.Shotcut`): more powerful.

Final length target: 5-8 minutes.

### Task 7.4: Upload to YouTube as Unlisted

- [ ] **Step 1: youtube.com → Create → Upload video**

- [ ] **Step 2: Title:** `Weekly Life Planner AI — Veri Tabanı Dersi Projesi (Beyza Ata)`

Description:
```
GitHub: https://github.com/ataabeeyzaa/weekly-life-planner-ai
Stack: n8n + Supabase + Google Gemini 1.5 Flash + Telegram

00:00 Giriş
00:30 Mimari
01:15 Veritabanı
02:15 n8n Workflow'lar
03:45 Canlı Demo
05:30 KVKK
05:50 Kapanış
```

- [ ] **Step 3: Visibility: Unlisted (link ile erişim)**

- [ ] **Step 4: Copy video URL**

### Task 7.5: Update README with video link

- [ ] **Step 1: Replace `VIDEO_LINK_BURAYA` placeholder in README.md with actual URL**

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add demo video link"
git push
```

---

## Phase 8 — IEEE Paper (Day 8, 17 May)

### Task 8.1: Set up paper folder using IEEE template

**Files:**
- Create: `docs/ieee-paper/beyza-ata-weekly-planner.docx`
- Create: `docs/ieee-paper/figures/` (folder)

- [ ] **Step 1: Copy IEEE template**

```bash
mkdir -p docs/ieee-paper/figures
cp "conference-template-IEEE (1).docx" "docs/ieee-paper/beyza-ata-weekly-planner.docx"
```

- [ ] **Step 2: Copy figures**

```bash
cp screenshots/05_er_diagram.png docs/ieee-paper/figures/fig1_er_diagram.png
cp screenshots/03_n8n_workflows_list.png docs/ieee-paper/figures/fig2_workflows.png
cp screenshots/04_workflow3_canvas.png docs/ieee-paper/figures/fig3_plan_generator.png
cp screenshots/01_telegram_demo.png docs/ieee-paper/figures/fig4_telegram.png
```

### Task 8.2: Write paper sections

Open `docs/ieee-paper/beyza-ata-weekly-planner.docx` in Word. Replace template content with:

- [ ] **Step 1: Title and authors**

Title: `Database-Driven AI System for Personalized Weekly Life Planning`
Authors: `Beyza Ata, Department of [Department], [University Name]`

- [ ] **Step 2: Abstract (~150 words)**

Sample:
> This paper presents the design and implementation of a database-driven, AI-augmented system that generates personalized weekly life plans through a conversational Telegram interface. The architecture combines a normalized PostgreSQL schema (Supabase), a no-code orchestration layer (n8n) running on Docker, and OpenAI's gpt-4o-mini model. Five workflows handle user onboarding, weekly reflection capture, plan generation, feedback collection, and a Sunday cron-based proactive nudge. We discuss the relational schema (five tables with cascade-delete foreign keys for KVKK-compliant data lifecycle), the prompt engineering approach (JSON-mode structured output with Turkish-language constraints), and the orchestration patterns that enable a stateful multi-step bot without writing application code. Initial usage shows that the database design supports ad-hoc analytical queries on JSONB plan content while maintaining referential integrity across user, goal, input, plan, and feedback entities.

- [ ] **Step 3: Introduction (~250 words)**

Cover: motivation (cognitive load of planning), problem statement, contributions (no-code architecture, JSONB-backed analytics, KVKK-by-design).

- [ ] **Step 4: System Design (~400 words + Figure 1 ER diagram + Figure 2 workflows)**

Subsections:
- 3.1 Overall Architecture
- 3.2 Database Schema (reference Figure 1)
- 3.3 Workflow Orchestration (reference Figure 2)

Discuss FK relationships, JSONB choice for plans, state-machine pattern for multi-step bot conversations.

- [ ] **Step 5: Implementation (~400 words + Figure 3)**

Subsections:
- 4.1 Database (PostgreSQL/Supabase)
- 4.2 Bot Layer (Telegram + n8n state-machine via `user_state` table)
- 4.3 AI Integration (Figure 3: Workflow 3 canvas)
- 4.4 Prompt Engineering (system prompt rules, JSON mode)

- [ ] **Step 6: Results & Discussion (~200 words + Figure 4)**

Discuss: Figure 4 sample output, query examples (one or two from `03_useful_queries.sql`), token cost per plan (~$0.001).

- [ ] **Step 7: KVKK / Privacy (~150 words)**

`/sil` cascade, data residency (eu-central-1), OpenAI API non-training default.

- [ ] **Step 8: Conclusion (~100 words)**

- [ ] **Step 9: References (5-8 items)**

Cite: PostgreSQL docs, n8n docs, OpenAI API docs, Supabase, KVKK regulation, any related work on AI planners.

### Task 8.3: Final commit

- [ ] **Step 1: Commit paper**

```bash
git add docs/ieee-paper/
git commit -m "docs: add IEEE paper draft"
git push
```

### Task 8.4: Final README polish

- [ ] **Step 1: Verify all sections in README accurate, all links work**

- [ ] **Step 2: Add badges (optional)**

```markdown
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)
![n8n](https://img.shields.io/badge/n8n-self--hosted-orange)
![OpenAI](https://img.shields.io/badge/OpenAI-gpt--4o--mini-green)
```

- [ ] **Step 3: Final commit and push**

```bash
git add README.md
git commit -m "docs: final README polish"
git push
```

---

## Phase 9 — Buffer / Submission (Day 9, 18 May)

### Task 9.1: End-to-end final test

- [ ] **Step 1: Fresh device test**

Use Telegram on phone (not the one used during dev) → run through `/start /profil /hedef /plan /geri_bildirim /gecmis /sil`.

- [ ] **Step 2: Verify everything still works in Supabase**

```sql
SELECT 'users' AS t, COUNT(*) FROM users
UNION ALL SELECT 'plans', COUNT(*) FROM plans;
```

- [ ] **Step 3: Verify YouTube video plays**

### Task 9.2: Submission checklist

Verify each item in spec section 14:

- [ ] GitHub repo public, README Türkçe ve detaylı
- [ ] Supabase'de 5 tablo + örnek veri + ER diagram repo'da
- [ ] En az 3 (ideali 5) n8n workflow JSON'u repo'da
- [ ] Telegram bot çalışıyor
- [ ] AI plan üretiyor, Türkçe, kişiselleştirilmiş
- [ ] Demo videosu YouTube'da (Unlisted), link README'de
- [ ] IEEE makalesi repo'da

- [ ] **Step 1: Submit to your professor with**:
  - GitHub repo URL
  - YouTube video URL
  - IEEE paper file (or its repo URL)

---

## Self-Review Notes (writing-plans skill compliance)

### Spec coverage

- ✅ All 7 commands have tasks (Tasks 3.3, 3.4, 3.5, 3.6, 4.3, 5.1, 5.2)
- ✅ 5 tables created (Tasks 1.1, 3.1)
- ✅ 5 workflows built (Tasks 3.2, 4.3, 4.4, 5.1, 5.3)
- ✅ AI prompt files created (Tasks 4.1, 4.2)
- ✅ Sunday 20:00 cron implemented (Task 5.3)
- ✅ KVKK `/sil` cascade delete (Task 3.6)
- ✅ Demo video script + recording + upload (Tasks 7.1–7.5)
- ✅ IEEE paper (Tasks 8.1–8.3)
- ✅ ER diagram (Task 1.5)

### Type / name consistency

- `user_state` table introduced in Task 3.1 with columns `telegram_id, flow, step, payload, updated_at` — used consistently across all subsequent SQL.
- Workflow filenames consistent: `01_onboarding.json`, `02_weekly_input.json`, `03_plan_generator.json`, `04_feedback.json`, `05_weekly_cron.json`.
- JSONB plan schema field names (`hafta_basligi`, `ana_hedefler`, `gunluk_plan`, etc.) used consistently in prompt, parse code, and UI rendering.

### Risks reminded in spec

- ngrok URL changes on free-tier restart → user warned in Task 2.3
- OpenAI credit might be missing → fallback Gemini noted in Task 0.9
- Telegram `/setcommands` makes commands discoverable in Task 0.8
- `text` literal escaping in SQL: use Postgres dollar-quoting (`$$...$$`) for markdown content (Task 4.4 step 8)

---

## Execution
