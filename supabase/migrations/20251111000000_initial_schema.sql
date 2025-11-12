-- Living Tags PoC - Initial Database Schema
-- Created: 2025-11-11
-- Description: Complete schema for AI-powered Russian text tagging system

-- ============================================================================
-- TABLES
-- ============================================================================

-- Tags table: stores available tags for categorizing texts
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE tags IS 'Available tags for categorizing Russian texts/jokes';
COMMENT ON COLUMN tags.name IS 'Unique tag name in Russian';

-- Texts table: stores Russian jokes/anecdotes to be tagged
CREATE TABLE texts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE texts IS 'Russian texts/jokes for semantic analysis and tagging';
COMMENT ON COLUMN texts.content IS 'The actual text content in Russian';

-- Text-Tags junction table: many-to-many relationship with confidence scores
CREATE TABLE text_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text_id UUID NOT NULL REFERENCES texts(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    confidence DECIMAL(3,2) NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(text_id, tag_id)
);

COMMENT ON TABLE text_tags IS 'Junction table linking texts to tags with AI confidence scores';
COMMENT ON COLUMN text_tags.confidence IS 'AI confidence score (0.00 to 1.00) for this tag assignment';
COMMENT ON CONSTRAINT text_tags_text_id_tag_id_key ON text_tags IS 'Prevents duplicate tag assignments to the same text';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Performance indexes for foreign key lookups
CREATE INDEX idx_text_tags_text_id ON text_tags(text_id);
CREATE INDEX idx_text_tags_tag_id ON text_tags(tag_id);

-- Index for filtering by confidence (useful for UI filtering)
CREATE INDEX idx_text_tags_confidence ON text_tags(confidence DESC);

-- Index for tag name lookups
CREATE INDEX idx_tags_name ON tags(name);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE texts ENABLE ROW LEVEL SECURITY;
ALTER TABLE text_tags ENABLE ROW LEVEL SECURITY;

-- PoC-simple policies: allow all operations for everyone
-- NOTE: In production, these should be restricted based on authentication

CREATE POLICY "Allow all operations on tags" ON tags
    FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all operations on texts" ON texts
    FOR ALL
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow all operations on text_tags" ON text_tags
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- SEED DATA: TAGS
-- ============================================================================

-- Insert 15 common Russian joke/anecdote categories
INSERT INTO tags (name) VALUES
    ('Вовочка'),        -- Little Vovochka jokes
    ('Штирлиц'),        -- Stirlitz jokes (Soviet spy character)
    ('Программисты'),   -- Programmer jokes
    ('Работа'),         -- Work-related
    ('Семья'),          -- Family-related
    ('Политика'),       -- Political humor
    ('Черный юмор'),    -- Dark humor
    ('Каламбур'),       -- Puns/wordplay
    ('Абсурд'),         -- Absurdist humor
    ('Советские'),      -- Soviet-era jokes
    ('Современные'),    -- Modern/contemporary
    ('Детские'),        -- Children/kids
    ('Медицина'),       -- Medical/doctors
    ('Студенты'),       -- Students
    ('Армия');          -- Military/army

-- ============================================================================
-- SEED DATA: TEST TEXTS
-- ============================================================================

-- Insert 3 test Russian jokes for initial testing
INSERT INTO texts (content) VALUES
    ('Штирлиц шёл по Берлину. Его выдавала волочащаяся за ним парашютная стропа.'),
    ('Программист звонит в библиотеку:
- Здравствуйте, Катю можно?
- Она в архиве.
- Разархивируйте её пожалуйста, она мне срочно нужна!'),
    ('Вовочка приходит домой из школы:
- Папа, тебя в школу вызывают!
- Что ты опять натворил?
- Да ничего особенного, химичку немного взорвал.
- Ну ладно, пойду завтра.
- Да не в школу идти надо, а сразу в больницу!');

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- The following comments document expected counts for verification:
-- Expected tags: 15
-- Expected texts: 3
-- Expected text_tags: 0 (will be populated by AI auto-tagging)
