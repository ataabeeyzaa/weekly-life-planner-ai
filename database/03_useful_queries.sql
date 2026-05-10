-- ============================================================
-- weekly-life-planner-ai — Örnek Sorgular
-- ============================================================
-- Bu dosya: IEEE makalesinde ve sunumda gösterilecek
--           PostgreSQL örnek sorguları
-- Kullanım: Sırayla Supabase SQL Editor'da çalıştır
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- Q1: Bir kullanıcının aktif hedeflerini önceliğe göre listele
-- ────────────────────────────────────────────────────────────
SELECT
    g.kategori,
    g.hedef_metin,
    g.oncelik
FROM user_goals g
JOIN users u ON u.id = g.user_id
WHERE u.telegram_id = 999000111
  AND g.aktif = TRUE
ORDER BY g.oncelik DESC, g.created_at;

-- ────────────────────────────────────────────────────────────
-- Q2: Geçen 4 haftanın puan ortalaması (kullanıcı bazında)
-- ────────────────────────────────────────────────────────────
SELECT
    u.ad,
    ROUND(AVG(wi.gecen_hafta_puan)::numeric, 2) AS ortalama_puan,
    COUNT(wi.id)                                AS hafta_sayisi
FROM users u
JOIN weekly_inputs wi ON wi.user_id = u.id
WHERE wi.hafta_baslangic >= CURRENT_DATE - INTERVAL '28 days'
GROUP BY u.ad
ORDER BY ortalama_puan DESC;

-- ────────────────────────────────────────────────────────────
-- Q3: Plan başına ortalama kullanıcı puanı (en başarılı planlar)
-- ────────────────────────────────────────────────────────────
SELECT
    p.hafta_baslangic,
    p.plan_json->>'hafta_basligi'                AS hafta_basligi,
    u.ad                                          AS kullanici,
    ROUND(AVG(f.puan)::numeric, 2)                AS ortalama_puan,
    COUNT(f.id)                                   AS oy_sayisi
FROM plans p
JOIN users u ON u.id = p.user_id
LEFT JOIN feedback f ON f.plan_id = p.id
GROUP BY p.id, p.hafta_baslangic, u.ad
ORDER BY ortalama_puan DESC NULLS LAST
LIMIT 10;

-- ────────────────────────────────────────────────────────────
-- Q4: Token kullanım toplamı (maliyet takibi)
-- ────────────────────────────────────────────────────────────
SELECT
    u.ad,
    COUNT(p.id)                AS plan_sayisi,
    SUM(p.prompt_token)        AS toplam_prompt_token,
    SUM(p.completion_token)    AS toplam_completion_token,
    SUM(p.prompt_token + p.completion_token) AS toplam_token
FROM users u
JOIN plans p ON p.user_id = u.id
GROUP BY u.ad
ORDER BY toplam_token DESC;

-- ────────────────────────────────────────────────────────────
-- Q5: JSONB sorgusu — planda "koşu" geçen ana hedefleri ara
-- ────────────────────────────────────────────────────────────
SELECT
    u.ad,
    p.hafta_baslangic,
    jsonb_array_elements_text(p.plan_json->'ana_hedefler') AS hedef
FROM plans p
JOIN users u ON u.id = p.user_id
WHERE EXISTS (
    SELECT 1
    FROM jsonb_array_elements_text(p.plan_json->'ana_hedefler') h
    WHERE h ILIKE '%koşu%' OR h ILIKE '%spor%'
);

-- ────────────────────────────────────────────────────────────
-- Q6: Günlük plan derinliğinde sorgu — Pazartesi sabah ne planlanmış?
-- ────────────────────────────────────────────────────────────
SELECT
    u.ad,
    p.hafta_baslangic,
    p.plan_json->'gunluk_plan'->'pazartesi'->>'sabah'  AS pazartesi_sabah,
    p.plan_json->'gunluk_plan'->'pazartesi'->>'aksam'  AS pazartesi_aksam
FROM plans p
JOIN users u ON u.id = p.user_id
ORDER BY p.hafta_baslangic DESC
LIMIT 5;

-- ────────────────────────────────────────────────────────────
-- Q7: KVKK onayı eksik kullanıcılar (bu kullanıcılara plan üretilmemeli)
-- ────────────────────────────────────────────────────────────
SELECT telegram_id, ad, created_at
FROM users
WHERE kvkk_onay = FALSE;

-- ────────────────────────────────────────────────────────────
-- Q8: KVKK silme — bir kullanıcının tüm verisini sil (CASCADE)
-- ────────────────────────────────────────────────────────────
-- DİKKAT: ON DELETE CASCADE sayesinde tek satırda
-- user_goals, weekly_inputs, plans, feedback satırları da silinir.
-- Demo amaçlı yorum içinde, kullanmak için yorumu aç:
--
-- DELETE FROM users WHERE telegram_id = 999000111;

-- ────────────────────────────────────────────────────────────
-- Q9: Bu hafta için planı eksik aktif kullanıcılar (cron için)
-- ────────────────────────────────────────────────────────────
SELECT
    u.id,
    u.telegram_id,
    u.ad
FROM users u
WHERE u.kvkk_onay = TRUE
  AND NOT EXISTS (
      SELECT 1 FROM plans p
      WHERE p.user_id = u.id
        AND p.hafta_baslangic = date_trunc('week', CURRENT_DATE)::date
  );

-- ────────────────────────────────────────────────────────────
-- Q10: Şema sağlık özet — toplam kayıt + en son aktivite
-- ────────────────────────────────────────────────────────────
SELECT 'users'         AS tablo, COUNT(*) AS kayit, MAX(created_at) AS son_aktivite FROM users
UNION ALL
SELECT 'user_goals',    COUNT(*), MAX(created_at) FROM user_goals
UNION ALL
SELECT 'weekly_inputs', COUNT(*), MAX(created_at) FROM weekly_inputs
UNION ALL
SELECT 'plans',         COUNT(*), MAX(created_at) FROM plans
UNION ALL
SELECT 'feedback',      COUNT(*), MAX(created_at) FROM feedback
ORDER BY tablo;
