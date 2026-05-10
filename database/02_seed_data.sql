-- ============================================================
-- weekly-life-planner-ai — Seed Verisi
-- ============================================================
-- Amaç: Şema doğrulaması + sunum/demo için örnek veri
-- Kullanım: Supabase SQL Editor'da bu dosyayı çalıştır
-- Telegram ID gerçek kullanıcı değil (999000111), test için
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1 demo kullanıcı
-- ────────────────────────────────────────────────────────────
INSERT INTO users (
    telegram_id, ad, yas, meslek,
    uyanma_saati, uyku_saati,
    is_baslangic, is_bitis,
    enerji_zirvesi, kvkk_onay
)
VALUES (
    999000111, 'Demo Kullanıcı', 24, 'Yazılım Mühendisi',
    '07:30', '23:30',
    '09:00', '18:00',
    'sabah', TRUE
)
ON CONFLICT (telegram_id) DO NOTHING;

-- ────────────────────────────────────────────────────────────
-- 3 hedef (farklı kategoriler, farklı öncelikler)
-- ────────────────────────────────────────────────────────────
WITH u AS (SELECT id FROM users WHERE telegram_id = 999000111)
INSERT INTO user_goals (user_id, kategori, hedef_metin, oncelik)
SELECT u.id, 'saglik', 'Haftada 3 gün 30 dk koşu yapmak', 5 FROM u
UNION ALL
SELECT u.id, 'ogrenme', 'Bu ay 1 teknik kitap bitirmek', 4 FROM u
UNION ALL
SELECT u.id, 'sosyal', 'Haftada 1 arkadaşla buluşmak', 3 FROM u;

-- ────────────────────────────────────────────────────────────
-- 1 weekly input (geçen haftaya ait refleksiyon)
-- ────────────────────────────────────────────────────────────
WITH u AS (SELECT id FROM users WHERE telegram_id = 999000111)
INSERT INTO weekly_inputs (
    user_id, hafta_baslangic,
    gecen_hafta_puan, gecen_hafta_iyi, gecen_hafta_kotu,
    bu_hafta_etkinlikler, enerji_seviyesi
)
SELECT
    u.id, '2026-05-12',
    7, 'Spor düzenli oldu, kitap okumaya başladım', 'Geç saatlere kadar çalıştım',
    'Çarşamba sunum, Cuma doktor randevusu', 6
FROM u
ON CONFLICT (user_id, hafta_baslangic) DO NOTHING;

-- ────────────────────────────────────────────────────────────
-- 1 örnek plan (gerçek AI çıktısı yapısında, kısaltılmış)
-- ────────────────────────────────────────────────────────────
WITH
    u  AS (SELECT id FROM users WHERE telegram_id = 999000111),
    wi AS (SELECT id FROM weekly_inputs
           WHERE user_id = (SELECT id FROM u)
             AND hafta_baslangic = '2026-05-12'
           LIMIT 1)
INSERT INTO plans (
    user_id, weekly_input_id, hafta_baslangic,
    plan_json, plan_markdown, model_kullanilan,
    prompt_token, completion_token
)
SELECT
    u.id, wi.id, '2026-05-12',
    $${
        "hafta_basligi": "12-18 Mayıs 2026",
        "ana_hedefler": [
            "Haftada 3 gün koşu (Pzt, Çar, Cum)",
            "Akşamları 1 saat kitap okuma",
            "Cumartesi arkadaş buluşması"
        ],
        "gunluk_plan": {
            "pazartesi": {"sabah": "Koşu 30 dk", "ogle": "İş", "aksam": "Kitap 1 saat"},
            "sali":      {"sabah": "Yoga 20 dk", "ogle": "İş", "aksam": "Kitap 30 dk"},
            "carsamba":  {"sabah": "Koşu 30 dk", "ogle": "Sunum", "aksam": "Dinlenme"},
            "persembe":  {"sabah": "Yürüyüş", "ogle": "İş", "aksam": "Kitap 1 saat"},
            "cuma":      {"sabah": "Koşu 30 dk", "ogle": "Doktor", "aksam": "Film"},
            "cumartesi": {"sabah": "Geç kalk", "ogle": "Arkadaş kahvaltı", "aksam": "Hobi"},
            "pazar":     {"sabah": "Yürüyüş", "ogle": "Hazırlık", "aksam": "Plan inceleme"}
        },
        "haftalik_aliskanliklar": [
            "Günde 8 bardak su",
            "23:30 öncesi yatak",
            "Sabah 5 dk meditasyon"
        ],
        "refleksiyon_sorulari": [
            "Bu hafta enerjini en çok ne yükseltti?",
            "Hangi alışkanlığı bir sonraki haftaya taşımak istersin?",
            "Geçen haftaya göre nasıl hissediyorsun?"
        ],
        "motivasyon_notu": "Demo Kullanıcı, geçen haftaki sporu sürdürmen harika. Bu hafta kitap okuma ile zihnin de güçlensin."
    }$$::jsonb,
    $$# 📅 12-18 Mayıs 2026

## 🎯 Ana Hedefler
1. Haftada 3 gün koşu
2. Akşamları kitap okuma
3. Cumartesi arkadaş buluşması

## 💪 Motivasyon
Demo Kullanıcı, geçen haftaki sporu sürdürmen harika.$$,
    'gemini-1.5-flash',
    420,
    1180
FROM u, wi;

-- ────────────────────────────────────────────────────────────
-- DOĞRULAMA SORGUSU
-- ────────────────────────────────────────────────────────────
SELECT
    u.ad,
    COUNT(DISTINCT g.id)  AS hedef_sayisi,
    COUNT(DISTINCT wi.id) AS input_sayisi,
    COUNT(DISTINCT p.id)  AS plan_sayisi
FROM users u
LEFT JOIN user_goals    g  ON g.user_id  = u.id
LEFT JOIN weekly_inputs wi ON wi.user_id = u.id
LEFT JOIN plans         p  ON p.user_id  = u.id
WHERE u.telegram_id = 999000111
GROUP BY u.ad;
-- Beklenen: 1 satır → hedef=3, input=1, plan=1
