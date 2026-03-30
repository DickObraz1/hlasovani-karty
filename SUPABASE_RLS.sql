-- ============================================================
-- SUPABASE RLS (Row Level Security) pro hlasovani-karty
-- Spust tyto prikazy v Supabase SQL Editoru:
-- Supabase Dashboard > SQL Editor > New Query > vloz a spust
-- ============================================================

-- ============================================================
-- 1. ZAPNOUT RLS na vsech tabulkach (pokud uz neni)
-- ============================================================

ALTER TABLE cards   ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE contestants ENABLE ROW LEVEL SECURITY;
ALTER TABLE share_logs  ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 2. TABULKA: cards
-- - Vsichni mohou cist
-- - Vlozit moze kdokoli (anon), ale max 3 karty na e-mail
-- - Menit/mazat muze jen admin (authenticated user)
-- ============================================================

DROP POLICY IF EXISTS "cards_select_all"  ON cards;
DROP POLICY IF EXISTS "cards_insert_anon" ON cards;
DROP POLICY IF EXISTS "cards_update_admin" ON cards;
DROP POLICY IF EXISTS "cards_delete_admin" ON cards;

CREATE POLICY "cards_select_all"
    ON cards FOR SELECT
    USING (true);

-- Omezeni: max 3 navrhy na e-mail (server-side vynuceni)
CREATE POLICY "cards_insert_anon"
    ON cards FOR INSERT
    WITH CHECK (
        (SELECT COUNT(*) FROM cards c WHERE c.user_email = cards.user_email) < 3
    );

-- UPDATE a DELETE pouze pro prihlasene adminy
CREATE POLICY "cards_update_admin"
    ON cards FOR UPDATE
    USING (auth.role() = 'authenticated');

CREATE POLICY "cards_delete_admin"
    ON cards FOR DELETE
    USING (auth.role() = 'authenticated');

-- ============================================================
-- 3. TABULKA: votes
-- - Vsichni mohou cist (pro pocitani hlasu)
-- - Vlozit moze kdokoli, ale max 5 hlasu na e-mail
--   a jedna kombinace (card_id + user_email) musi byt unikatni
-- ============================================================

DROP POLICY IF EXISTS "votes_select_all"  ON votes;
DROP POLICY IF EXISTS "votes_insert_anon" ON votes;

CREATE POLICY "votes_select_all"
    ON votes FOR SELECT
    USING (true);

-- Omezeni: max 5 hlasu na e-mail a nesmis hlasovat dvakrat pro stejnou kartu
CREATE POLICY "votes_insert_anon"
    ON votes FOR INSERT
    WITH CHECK (
        (SELECT COUNT(*) FROM votes v WHERE v.user_email = votes.user_email) < 5
    );

-- Unikatni constraint pro (card_id, user_email) - pokud jeste neexistuje
-- Spust zvlast, pokud constraint uz existuje, preskoc:
-- ALTER TABLE votes ADD CONSTRAINT votes_card_email_unique UNIQUE (card_id, user_email);

-- ============================================================
-- 4. TABULKA: contestants
-- - Cist muze jen authenticated admin
-- - Vlozit muze kdokoli (registrace ucastnika)
-- ============================================================

DROP POLICY IF EXISTS "contestants_select_admin" ON contestants;
DROP POLICY IF EXISTS "contestants_insert_anon"  ON contestants;

CREATE POLICY "contestants_select_admin"
    ON contestants FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "contestants_insert_anon"
    ON contestants FOR INSERT
    WITH CHECK (true);

-- ============================================================
-- 5. TABULKA: share_logs
-- - Cist muze jen admin
-- - Vlozit muze kdokoli
-- ============================================================

DROP POLICY IF EXISTS "share_logs_select_admin" ON share_logs;
DROP POLICY IF EXISTS "share_logs_insert_anon"  ON share_logs;

CREATE POLICY "share_logs_select_admin"
    ON share_logs FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "share_logs_insert_anon"
    ON share_logs FOR INSERT
    WITH CHECK (true);

-- ============================================================
-- 6. VYTVORIT ADMIN UCET v Supabase Auth
-- Jdi na: Supabase Dashboard > Authentication > Users > Add User
-- Zadej e-mail a heslo admina — pouzij je pro prihlaseni na admin.html
-- ============================================================
