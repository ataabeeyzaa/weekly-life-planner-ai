-- ============================================================
-- weekly-life-planner-ai — Veritabanı Şeması
-- ============================================================
-- Hedef DB: PostgreSQL 15+ (Supabase)
-- Tablolar: 5 ana tablo + 1 yardımcı (user_state)
--
-- ANA VERİ MODELİ (IEEE makalesinde anlatılacak 5 tablo):
--   1. users           - Kullanıcı profili
--   2. user_goals      - Kullanıcı hedefleri (1-N)
--   3. weekly_inputs   - Haftalık refleksiyon girdileri
--   4. plans           - AI tarafından üretilen planlar
--   5. feedback        - Plan geri bildirimleri
--
-- YARDIMCI TABLO (bot iç akışı için, makalede yok):
--   6. user_state      - Telegram bot çok-adımlı diyalog state'i
--
-- İlişkiler (foreign key'lerle korunur, CASCADE ile silinir):
--   users (1) ── (N) user_goals
--   users (1) ── (N) weekly_inputs
--   weekly_inputs (1) ── (1) plans
--   users (1) ── (N) plans
--   plans (1) ── (N) feedback
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. KULLANICILAR
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_id     BIGINT       UNIQUE NOT NULL,
    ad              TEXT         NOT NULL,
    yas             INT          CHECK (yas BETWEEN 13 AND 100),
    meslek          TEXT,
    uyanma_saati    TIME         NOT NULL,
    uyku_saati      TIME         NOT NULL,
    is_baslangic    TIME,
    is_bitis        TIME,
    enerji_zirvesi  TEXT         CHECK (enerji_zirvesi IN ('sabah','oglen','aksam')),
    kvkk_onay       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);

COMMENT ON TABLE users IS 'Telegram bot kullanıcıları + profil bilgileri';
COMMENT ON COLUMN users.kvkk_onay IS 'KVKK aydınlatılmış onam — TRUE olmadan plan üretilmez';

-- ────────────────────────────────────────────────────────────
-- 2. HEDEFLER
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_goals (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kategori     TEXT         NOT NULL CHECK (kategori IN ('kariyer','saglik','sosyal','hobi','ogrenme','aile')),
    hedef_metin  TEXT         NOT NULL,
    oncelik      INT          NOT NULL CHECK (oncelik BETWEEN 1 AND 5),
    aktif        BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_goals_user_active ON user_goals(user_id, aktif);

COMMENT ON TABLE user_goals IS 'Kullanıcının uzun vadeli hedefleri (kategori bazlı, öncelikli)';

-- ────────────────────────────────────────────────────────────
-- 3. HAFTALIK GİRDİLER (refleksiyon)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS weekly_inputs (
    id                    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hafta_baslangic       DATE         NOT NULL,
    gecen_hafta_puan      INT          CHECK (gecen_hafta_puan BETWEEN 1 AND 10),
    gecen_hafta_iyi       TEXT,
    gecen_hafta_kotu      TEXT,
    bu_hafta_etkinlikler  TEXT,
    enerji_seviyesi       INT          CHECK (enerji_seviyesi BETWEEN 1 AND 10),
    created_at            TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, hafta_baslangic)
);

COMMENT ON TABLE weekly_inputs IS 'Her hafta /plan komutuyla toplanan refleksiyon — bir kullanıcı için bir hafta tek input';

-- ────────────────────────────────────────────────────────────
-- 4. PLANLAR
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS plans (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weekly_input_id   UUID         NOT NULL REFERENCES weekly_inputs(id) ON DELETE CASCADE,
    hafta_baslangic   DATE         NOT NULL,
    plan_json         JSONB        NOT NULL,
    plan_markdown     TEXT         NOT NULL,
    model_kullanilan  TEXT         NOT NULL DEFAULT 'gemini-1.5-flash',
    prompt_token      INT,
    completion_token  INT,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_plans_user_week ON plans(user_id, hafta_baslangic DESC);
CREATE INDEX IF NOT EXISTS idx_plans_jsonb_goals ON plans USING GIN ((plan_json->'ana_hedefler'));

COMMENT ON TABLE plans IS 'AI tarafından üretilen haftalık planlar — JSONB ile esnek sorgu';
COMMENT ON COLUMN plans.plan_json IS 'Yapılandırılmış JSON: hafta_basligi, ana_hedefler, gunluk_plan, haftalik_aliskanliklar, refleksiyon_sorulari, motivasyon_notu';

-- ────────────────────────────────────────────────────────────
-- 5. GERİ BİLDİRİM
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS feedback (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id     UUID         NOT NULL REFERENCES plans(id) ON DELETE CASCADE,
    puan        INT          NOT NULL CHECK (puan BETWEEN 1 AND 5),
    yorum       TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE feedback IS 'Plan başına kullanıcı puanı — model iyileştirme için';

-- ────────────────────────────────────────────────────────────
-- 6. KULLANICI STATE (yardımcı, bot çok-adımlı diyalog için)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_state (
    telegram_id  BIGINT       PRIMARY KEY,
    flow         TEXT         NOT NULL,
    step         INT          NOT NULL DEFAULT 0,
    payload      JSONB        NOT NULL DEFAULT '{}'::jsonb,
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE user_state IS 'Bot çok-adımlı sorgu state''i (profil/hedef/plan_input/feedback/sil/gecmis)';

-- ────────────────────────────────────────────────────────────
-- 7. updated_at OTOMATİK GÜNCELLEME (sadece users için)
-- ────────────────────────────────────────────────────────────
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

-- ============================================================
-- ŞEMA TAMAMLANDI
-- Doğrulama için aşağıdaki sorguyu çalıştırabilirsin:
--   SELECT table_name FROM information_schema.tables
--   WHERE table_schema = 'public' ORDER BY table_name;
-- Beklenen 6 tablo: feedback, plans, user_goals, user_state, users, weekly_inputs
-- ============================================================
