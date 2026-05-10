# Tasarım Dokümanı: AI Haftalık Yaşam Planlayıcısı

**Proje adı:** `weekly-life-planner-ai`
**Yazan:** Beyza Ata (GitHub: [@ataabeeyzaa](https://github.com/ataabeeyzaa))
**Tarih:** 2026-05-10
**Teslim:** 2026-05-18
**Ders:** Veri Tabanı (Database) — Database-AI Entegrasyonu ödevi
**Durum:** Onaylandı (kullanıcı onayı: 2026-05-10)

---

## 1. Problem ve Motivasyon

Modern bireyler haftalık planlama yaparken iki sorunla karşılaşır:

1. **Bilişsel yük:** Hedefleri, takvimi, alışkanlıkları ve enerjiyi aynı anda dengelemek zor.
2. **Süreklilik eksikliği:** Plan yapılır ama haftadan haftaya öğrenme/uyum yoktur.

Bu projede, kullanıcının profilini ve geçen hafta deneyimini PostgreSQL veritabanında saklayan, OpenAI gpt-4o-mini ile kişiselleştirilmiş haftalık yaşam planı üreten ve sonucu Telegram üzerinden teslim eden bir otomasyon sistemi inşa edilir. Tüm orkestrasyon n8n (kod yazmadan otomasyon) ile yapılır.

## 2. Kapsam

**Yapılacak (in-scope):**

- Telegram bot arayüzü (Türkçe), `/start`, `/profil`, `/hedef`, `/plan`, `/gecmis`, `/geri_bildirim`, `/sil` komutları
- Supabase üzerinde 5 tablolu PostgreSQL şeması (foreign key'ler, index'ler ile)
- 5 adet n8n workflow (JSON olarak repoda; 4 komut + 1 cron)
- Pazar 20:00 cron tetiklemesi (haftalık otomatik plan)
- AI prompt tasarımı (system + user template)
- KVKK uyumlu veri yönetimi (kod adı, opt-out, silme)
- IEEE formatında 3-4 sayfalık makale
- 5-8 dakikalık demo videosu (sesli anlatımlı)

**Yapılmayacak (out-of-scope, YAGNI):**

- Mobil uygulama (Telegram bot zaten mobil-uyumlu)
- Web frontend
- Çoklu dil (sadece Türkçe)
- Plana takvim entegrasyonu (Google Calendar, vb.)
- Kullanıcılar arası sosyal özellikler
- Premium/ücretli planlar
- Analitik dashboard

## 3. Sistem Mimarisi

```
   ┌─────────────────┐
   │   Kullanıcı     │  (Telefon / Telegram uygulaması)
   └────────┬────────┘
            │ /start, /profil, /plan, /geri_bildirim
            ▼
   ┌─────────────────┐         ┌──────────────────────┐
   │  Telegram Bot   │◄───────►│  n8n (Docker, local) │
   │  @PlanlaBot     │ webhook │  5 adet workflow     │
   └─────────────────┘         └────┬──────────┬──────┘
                                    │          │
                          ┌─────────▼───┐   ┌──▼─────────────────┐
                          │  Supabase   │   │  OpenAI API        │
                          │ PostgreSQL  │   │  (gpt-4o-mini)     │
                          │  5 tablo    │   │  Yedek: Gemini     │
                          └─────────────┘   └────────────────────┘
                                ▲
                                │ cron (Pazar 20:00)
                          ┌─────┴────────┐
                          │ n8n Schedule │
                          └──────────────┘
```

**Bileşenler arası veri akışı:**

1. Kullanıcı Telegram'a komut/mesaj yazar
2. Telegram webhook → n8n trigger node tetiklenir
3. n8n workflow Supabase'den ilgili veriyi okur
4. n8n OpenAI'ya yapılandırılmış prompt gönderir
5. OpenAI JSON formatında haftalık plan döner
6. n8n planı Supabase'e yazar + Markdown formatlar
7. n8n Telegram'a cevap gönderir

## 4. Teknoloji Stack'i

| Katman | Araç | Versiyon | Sebep |
|---|---|---|---|
| Veritabanı | Supabase (PostgreSQL) | 15+ | Gerçek RDBMS, ücretsiz tier 500 MB, web UI ile sunum-dostu |
| Otomasyon | n8n | son sürüm | Açık kaynak, workflow JSON → versiyon kontrol uyumlu |
| Konteyner | Docker Desktop | son sürüm | n8n self-hosting için |
| AI | OpenAI gpt-4o-mini | API v1 | Türkçe kalitesi yüksek, ucuz ($0.15 / 1M input) |
| AI yedek | Google Gemini 1.5 Flash | API v1 | Ücretsiz tier (1500 istek/gün), kredi kartı yok |
| Mesajlaşma | Telegram Bot API | son | BotFather'da 5 dk'da bot, ücretsiz |
| VCS | GitHub | — | Public repo, hocaya gösterim + portfolio |
| Doküman | Markdown + Word (IEEE) | — | README.md + IEEE şablonu |

## 5. Veritabanı Şeması

### Tablo: `users`

| Sütun | Tip | Kısıt | Açıklama |
|---|---|---|---|
| `id` | UUID | PK, default `gen_random_uuid()` | Birincil anahtar |
| `telegram_id` | BIGINT | UNIQUE, NOT NULL | Telegram kullanıcı ID'si |
| `ad` | TEXT | NOT NULL | Kullanıcının adı (kod adı veya gerçek) |
| `yas` | INT | CHECK (yas BETWEEN 13 AND 100) | Yaş |
| `meslek` | TEXT | | Meslek/öğrencilik durumu |
| `uyanma_saati` | TIME | NOT NULL | Tipik uyanma saati |
| `uyku_saati` | TIME | NOT NULL | Tipik uyku saati |
| `is_baslangic` | TIME | | İş/okul başlangıç |
| `is_bitis` | TIME | | İş/okul bitiş |
| `enerji_zirvesi` | TEXT | CHECK IN ('sabah', 'oglen', 'aksam') | Enerji zirvesi |
| `kvkk_onay` | BOOLEAN | DEFAULT FALSE | Aydınlatılmış onam |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Kayıt tarihi |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Güncelleme tarihi |

### Tablo: `user_goals`

| Sütun | Tip | Kısıt | Açıklama |
|---|---|---|---|
| `id` | UUID | PK | Birincil anahtar |
| `user_id` | UUID | FK → `users(id)` ON DELETE CASCADE | Kullanıcı |
| `kategori` | TEXT | CHECK IN ('kariyer', 'saglik', 'sosyal', 'hobi', 'ogrenme', 'aile') | Hedef kategorisi |
| `hedef_metin` | TEXT | NOT NULL | Hedef açıklaması |
| `oncelik` | INT | CHECK (oncelik BETWEEN 1 AND 5) | 1=düşük, 5=yüksek |
| `aktif` | BOOLEAN | DEFAULT TRUE | Pasif edilebilir |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | |

Index: `idx_goals_user_active ON user_goals(user_id, aktif)`

### Tablo: `weekly_inputs`

| Sütun | Tip | Kısıt | Açıklama |
|---|---|---|---|
| `id` | UUID | PK | |
| `user_id` | UUID | FK → `users(id)` ON DELETE CASCADE | |
| `hafta_baslangic` | DATE | NOT NULL | Hafta başlangıç tarihi (Pazartesi) |
| `gecen_hafta_puan` | INT | CHECK (1-10) | Geçen hafta genel puan |
| `gecen_hafta_iyi` | TEXT | | Neyin iyi gittiği |
| `gecen_hafta_kotu` | TEXT | | Neyin zorladığı |
| `bu_hafta_etkinlikler` | TEXT | | Bu hafta sabit etkinlikler |
| `enerji_seviyesi` | INT | CHECK (1-10) | Bu hafta öngörülen enerji |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | |

UNIQUE constraint: `(user_id, hafta_baslangic)` — bir kullanıcı bir hafta için bir input

### Tablo: `plans`

| Sütun | Tip | Kısıt | Açıklama |
|---|---|---|---|
| `id` | UUID | PK | |
| `user_id` | UUID | FK → `users(id)` ON DELETE CASCADE | |
| `weekly_input_id` | UUID | FK → `weekly_inputs(id)` ON DELETE CASCADE | |
| `hafta_baslangic` | DATE | NOT NULL | |
| `plan_json` | JSONB | NOT NULL | AI'dan gelen yapılandırılmış plan |
| `plan_markdown` | TEXT | NOT NULL | Telegram'da gösterilen biçim |
| `model_kullanilan` | TEXT | DEFAULT 'gpt-4o-mini' | Hangi LLM |
| `prompt_token` | INT | | Maliyet takibi |
| `completion_token` | INT | | Maliyet takibi |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | |

Index: `idx_plans_user_week ON plans(user_id, hafta_baslangic DESC)`

### Tablo: `feedback`

| Sütun | Tip | Kısıt | Açıklama |
|---|---|---|---|
| `id` | UUID | PK | |
| `plan_id` | UUID | FK → `plans(id)` ON DELETE CASCADE | |
| `puan` | INT | CHECK (1-5) NOT NULL | Plan puanı |
| `yorum` | TEXT | | Opsiyonel açıklama |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | |

### İlişkiler (özet)

- `users 1—N user_goals`
- `users 1—N weekly_inputs`
- `weekly_inputs 1—1 plans` (her input için tek plan)
- `users 1—N plans`
- `plans 1—N feedback`

ER diyagramı `database/er_diagram.png` olarak repo'ya eklenecek (dbdiagram.io ile çıkarılır).

## 6. Kullanıcı Akışları

### Akış A: İlk kullanım (Onboarding)

1. Kullanıcı Telegram'da bota `/start` yazar
2. Bot: KVKK aydınlatma metni + "Devam etmek için /profil yaz"
3. Kullanıcı `/profil` → bot 8 soruyu sırayla sorar (yaş, meslek, uyanma...)
4. Yanıtlar `users` tablosuna yazılır, `kvkk_onay = TRUE` set edilir
5. Bot: "Şimdi 3-5 hedef belirleyelim, /hedef yaz"
6. Kullanıcı `/hedef` → bot her seferinde 1 hedef alır (kategori + metin + öncelik)
7. Hedefler `user_goals` tablosuna yazılır
8. Bot: "Hazırsın! Bu Pazar 20:00'de ilk planını alacaksın, ya da hemen `/plan` yazabilirsin"

### Akış B: Haftalık plan (otomatik veya manuel)

1. **Tetikleyici A:** n8n cron her Pazar 20:00 tüm aktif kullanıcılar için döner
2. **Tetikleyici B:** Kullanıcı `/plan` yazar
3. Bot weekly input için 4 soru sorar:
   - Geçen hafta 1-10 nasıldı?
   - Ne iyi gitti?
   - Ne zorladı?
   - Bu hafta sabit etkinliklerin neler?
4. Yanıtlar `weekly_inputs` tablosuna yazılır
5. n8n: profil + aktif hedefler + weekly input → OpenAI'ya gönderir
6. OpenAI JSON döner → n8n parse eder → Markdown formatlar
7. `plans` tablosuna kaydedilir
8. Telegram'a 3 mesaj olarak gönderilir (Telegram 4096 karakter limiti):
   - Ana hedefler + motivasyon
   - Günlük zaman blokları
   - Alışkanlık takibi + refleksiyon soruları

### Akış C: Geri bildirim

1. Kullanıcı `/geri_bildirim` yazar
2. Bot son planı bulur, "Bu plan için 1-5 puan ver"
3. Puan + opsiyonel yorum `feedback` tablosuna yazılır
4. Bot: "Teşekkürler, bir sonraki plan daha iyi olacak"

### Akış D: Geçmiş

1. Kullanıcı `/gecmis` yazar
2. Bot son 4 haftanın plan başlıklarını listeler (numara ile)
3. Kullanıcı numara seçer → o haftanın planını gösterir

### Akış E: Veri Silme (KVKK)

1. Kullanıcı `/sil` yazar
2. Bot onay sorar: "Tüm verin silinecek, EVET yaz"
3. Kullanıcı "EVET" yazarsa → Supabase'de `users` satırı silinir (CASCADE ile bağlı tüm tablolar temizlenir)
4. Bot: "Verilerin silindi, görüşmek üzere"

## 7. n8n Workflow'ları

### Workflow 1: `01_onboarding`

- **Tetikleyici:** Telegram Trigger (mesaj türü: `/start`, `/profil`, `/hedef`, `/sil`)
- **Adımlar:** Switch (komut türü) → her komut için ayrı dal:
  - `/start`: KVKK metni gönder, Supabase'de kullanıcı var mı kontrol et
  - `/profil`: Soru-cevap state machine (n8n Wait + Set node'ları)
  - `/hedef`: Tek hedef ekleme akışı
  - `/sil`: Onay iste → Supabase Delete (`users` satırı, CASCADE)

### Workflow 2: `02_weekly_input`

- **Tetikleyici:** Telegram Trigger (`/plan`)
- **Adımlar:** 4 soru sırayla → Wait node ile cevap bekle → Supabase Insert

### Workflow 3: `03_plan_generator`

- **Tetikleyici:** Webhook (workflow 2 ve cron'dan tetiklenir)
- **Adımlar:**
  1. Supabase: profil + aktif hedefler + son weekly_input çek
  2. Function node: OpenAI prompt'unu hazırla
  3. OpenAI node: gpt-4o-mini, JSON mode, max 2000 token
  4. Function node: JSON validate + Markdown formatla
  5. Supabase Insert: `plans` tablosu
  6. Telegram: 3 mesaj olarak gönder

### Workflow 4: `04_feedback`

- **Tetikleyici:** Telegram Trigger (`/geri_bildirim`)
- **Adımlar:** Son planı çek → puan iste → Supabase Insert

### Workflow 5 (cron): `05_weekly_cron`

- **Tetikleyici:** Schedule (Pazar 20:00)
- **Adımlar:** Aktif kullanıcı listesini çek → her biri için Workflow 3'ü tetikle (HTTP Request → kendi webhook'una)

## 8. AI Prompt Tasarımı

### System Prompt

```
Sen "Hayat Planlayıcısı" adında bir yapay zeka koçsun.
Görevin: kullanıcının profili, hedefleri ve geçen hafta deneyimine
bakarak SMART, gerçekçi, sürdürülebilir bir HAFTALIK plan üretmek.

KURALLAR:
1. Türkçe yaz, sıcak ama profesyonel ton kullan.
2. Aşırı yüklenme. Maksimum 3 ana hedef. Günde maksimum 3 zaman bloku.
3. Kullanıcının uyanma/uyku saatlerine MUTLAKA saygı göster.
4. Geçen hafta puanı 5'in altındaysa bu haftayı HAFİFLET, dinlenme öner.
5. Bu hafta sabit etkinlikleri (toplantı, sınav vb.) plana dahil et.
6. Asla tıbbi, mali veya hukuki tavsiye verme.
7. JSON formatında döndür, şema sabit.
8. Motivasyon notunu kullanıcının adıyla kişiselleştir.

ÇIKTI ŞEMASI (JSON, başka metin YAZMA):
{
  "hafta_basligi": "12-18 Mayıs 2026",
  "ana_hedefler": ["...", "...", "..."],
  "gunluk_plan": {
    "pazartesi": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "sali": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "carsamba": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "persembe": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "cuma": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "cumartesi": {"sabah": "...", "ogle": "...", "aksam": "..."},
    "pazar": {"sabah": "...", "ogle": "...", "aksam": "..."}
  },
  "haftalik_aliskanliklar": ["...", "...", "..."],
  "refleksiyon_sorulari": ["...", "...", "..."],
  "motivasyon_notu": "..."
}
```

### User Prompt Template

```
KULLANICI PROFİLİ:
- Ad: {{ad}}
- Yaş: {{yas}}, Meslek: {{meslek}}
- Uyanma: {{uyanma_saati}}, Uyku: {{uyku_saati}}
- İş saatleri: {{is_baslangic}} – {{is_bitis}}
- Enerji zirvesi: {{enerji_zirvesi}}

AKTİF HEDEFLER:
{{#each goals}}
- [{{kategori}}, öncelik {{oncelik}}] {{hedef_metin}}
{{/each}}

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

### OpenAI Parametreleri

- Model: `gpt-4o-mini`
- Temperature: `0.4` (tutarlı ama yaratıcı)
- Max tokens: `2000`
- Response format: `json_object`

## 9. KVKK ve Güvenlik

1. **Aydınlatılmış onam:** İlk `/start`'ta uzun metin sunulur, kullanıcı `/profil` yazarak onaylar (`kvkk_onay = TRUE`).
2. **Kod adı:** Kullanıcı isterse gerçek adı yerine kod adı kullanabilir; OpenAI'ya gönderilen prompt'ta sadece `ad` kullanılır.
3. **OpenAI veri saklama:** API üzerinden gönderilen veriler default olarak modele eğitim için kullanılmaz.
4. **n8n loglar:** `Settings > Workflow Settings > Save Data Successful Execution = "none"` ayarı yapılır.
5. **Veri silme:** `/sil` komutu kullanıcının tüm verisini siler (ON DELETE CASCADE sayesinde tek query).
6. **Supabase Row Level Security (RLS):** Bu projede aktive edilmeyecek (tek admin kullanıcı), ama IEEE makalesinde bahsedilecek.

## 10. GitHub Repo Yapısı

```
weekly-life-planner-ai/
├── README.md                           # Türkçe, kurulum + ekran görüntüleri
├── LICENSE                             # MIT
├── .gitignore                          # .env, node_modules, *.db
├── .env.example                        # API key placeholder'lar
├── docs/
│   ├── architecture.md                 # Detaylı mimari
│   ├── database-schema.md              # Şema açıklaması + örnek query'ler
│   ├── superpowers/specs/              # Bu doküman + sonrakiler
│   └── ieee-paper/
│       ├── beyza-ata-ieee-paper.docx   # IEEE şablonundan
│       └── figures/                    # Ekran görüntüleri
├── database/
│   ├── 01_schema.sql                   # CREATE TABLE'lar + FK + index
│   ├── 02_seed_data.sql                # Demo veri
│   ├── 03_useful_queries.sql           # Sunum için örnek sorgular
│   └── er_diagram.png                  # dbdiagram.io export
├── n8n-workflows/
│   ├── 01_onboarding.json
│   ├── 02_weekly_input.json
│   ├── 03_plan_generator.json
│   ├── 04_feedback.json
│   └── 05_weekly_cron.json
├── prompts/
│   ├── system_prompt.md
│   └── user_prompt_template.md
├── docker/
│   └── docker-compose.yml              # n8n için
├── screenshots/                        # README ve makale için
│   ├── 01_telegram_demo.png
│   ├── 02_supabase_tables.png
│   ├── 03_n8n_workflow.png
│   └── 04_er_diagram.png
└── demo-video/
    └── README.md                       # YouTube/Drive linki + senaryo
```

## 11. 8 Günlük Takvim

| # | Tarih | İş | Çıktı |
|---|---|---|---|
| 1 | 10 May | GitHub repo, Supabase proje, BotFather, OpenAI API | README iskeleti commit'lendi |
| 2 | 11 May | Supabase 5 tablo + FK + seed + ER diagram | `database/` klasörü tamam |
| 3 | 12 May | n8n Docker, Workflow 1 (onboarding) | İlk Telegram-Supabase entegrasyonu çalışıyor |
| 4 | 13 May | Workflow 2 (input) + Workflow 3 (plan generator) | İlk uçtan uca plan üretildi |
| 5 | 14 May | Workflow 4 (feedback) + Workflow 5 (cron) + uçtan uca test | Tüm akış çalışıyor |
| 6 | 15 May | Bug fix, ekran görüntüleri, README detay, prompt iyileştirme | Sunum-hazır kalite |
| 7 | 16 May | Demo videosu (5-8 dk, sesli, ekran kaydı) | Video YouTube'a yüklü |
| 8 | 17 May | IEEE makalesi (3-4 sayfa) yaz | Makale repo'da |
| Buffer | 18 May | Son rötuş, teslim | Final |

## 12. Demo Video Akışı (5-8 dk)

| # | Bölüm | Süre | Ne Gösterilir |
|---|---|---|---|
| 1 | Giriş & motivasyon | 30 sn | Webcam: kendini tanıt, problemi anlat |
| 2 | Mimari diyagram | 45 sn | Slide veya whiteboard: sistem akışı |
| 3 | Supabase tabloları | 60 sn | Web UI'da 5 tabloyu gez, FK'ları göster |
| 4 | n8n workflow'ları | 90 sn | Tarayıcıda her workflow'u aç, dal yapısını göster |
| 5 | Canlı demo | 120 sn | Telefonda Telegram aç, `/plan` yaz, plan gelmesini izle |
| 6 | AI prompt | 30 sn | `prompts/system_prompt.md`'yi göster, oku |
| 7 | KVKK & güvenlik | 20 sn | Slide veya code'dan KVKK akışını anlat |
| 8 | Kapanış | 15 sn | GitHub repo linki, teşekkür |

## 13. Risk ve Karşılığı

| Risk | Olasılık | Karşılık |
|---|---|---|
| OpenAI API kredisi yok | Orta | Plan B: Gemini Flash'a geç (1 saat iş) |
| n8n Docker'da çalışmaz | Düşük | Plan B: n8n.cloud free tier (sınır var ama yeter) |
| Telegram webhook localhost'tan tetiklenmez | Yüksek | ngrok kullan veya n8n.cloud'a deploy |
| Supabase free tier yetmez | Çok düşük | 500 MB > 1000 plan, sorun olmaz |
| Demo videosu kalitesizleşir | Orta | OBS Studio + Audacity, 2 deneme yap |
| 8 gün yetmez | Orta | Workflow 4 (feedback) ve Workflow 5 (cron) opsiyonel; demo öncesi 1-2-3 yeter |

## 14. Başarı Kriterleri (teslimde tamam olmalı)

- [ ] GitHub repo public, README Türkçe ve detaylı
- [ ] Supabase'de 5 tablo + örnek veri + ER diagram repo'da
- [ ] En az 3 n8n workflow JSON'u repo'da
- [ ] Telegram bot çalışıyor, `/start` ve `/plan` test edilebilir
- [ ] AI plan üretiyor, Türkçe, mantıklı, kullanıcıya özel
- [ ] Demo videosu YouTube/Drive'da, link README'de
- [ ] IEEE makalesi (3-4 sayfa) repo'da Word formatında

---

## 15. Sonraki Adım

Bu doküman onaylandıktan sonra `writing-plans` skill'i çağrılarak detaylı implementasyon planı çıkarılacak. Plan adım-adım, her adım tek küçük commit boyutunda olacak ve sırasıyla:
1. GitHub repo açılışı + ilk commit
2. Supabase setup + schema
3. n8n Docker setup
4. Workflow'ların inşası
5. Test + iterasyon
6. Video + makale
