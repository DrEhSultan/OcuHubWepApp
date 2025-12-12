-- =====================================================
-- CREDITS/ACKNOWLEDGMENTS SYSTEM MIGRATION
-- OcuHub Mobile App + Admin Dashboard
-- Date: December 2025
-- =====================================================

-- =====================================================
-- CREDITS TABLES
-- =====================================================

-- 1. CREDIT_ASSET_TYPES TABLE
-- Stores types of assets (Icon, Image, Sound, Lottie, Video, etc.)
CREATE TABLE IF NOT EXISTS public.credit_asset_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. CREDIT_SITES TABLE
-- Stores attribution sites (Flaticon, Unsplash, etc.) under each asset type
CREATE TABLE IF NOT EXISTS public.credit_sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_type_id UUID NOT NULL REFERENCES public.credit_asset_types(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    website_url TEXT,
    attribution_format TEXT,
    description TEXT,
    logo_url TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(asset_type_id, name)
);

-- 3. CREDIT_LINKS TABLE
-- Stores individual attribution links for each site
CREATE TABLE IF NOT EXISTS public.credit_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES public.credit_sites(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    author TEXT,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.credit_asset_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_links ENABLE ROW LEVEL SECURITY;

-- Public read access for all credits tables (anyone can view credits)
CREATE POLICY "credit_asset_types_read_all" ON public.credit_asset_types 
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "credit_sites_read_all" ON public.credit_sites 
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "credit_links_read_all" ON public.credit_links 
    FOR SELECT USING (is_active = TRUE);

-- Service role has full access for admin operations
CREATE POLICY "credit_asset_types_service_all" ON public.credit_asset_types 
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "credit_sites_service_all" ON public.credit_sites 
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "credit_links_service_all" ON public.credit_links 
    FOR ALL USING (auth.role() = 'service_role');

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_credit_asset_types_active ON public.credit_asset_types(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_credit_asset_types_sort ON public.credit_asset_types(sort_order);

CREATE INDEX IF NOT EXISTS idx_credit_sites_asset_type ON public.credit_sites(asset_type_id);
CREATE INDEX IF NOT EXISTS idx_credit_sites_active ON public.credit_sites(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_credit_sites_sort ON public.credit_sites(sort_order);

CREATE INDEX IF NOT EXISTS idx_credit_links_site ON public.credit_links(site_id);
CREATE INDEX IF NOT EXISTS idx_credit_links_active ON public.credit_links(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_credit_links_sort ON public.credit_links(sort_order);

-- =====================================================
-- AUTOMATIC TIMESTAMP TRIGGERS
-- =====================================================

CREATE TRIGGER trigger_credit_asset_types_updated_at 
    BEFORE UPDATE ON public.credit_asset_types 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_credit_sites_updated_at 
    BEFORE UPDATE ON public.credit_sites 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_credit_links_updated_at 
    BEFORE UPDATE ON public.credit_links 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA - Default Asset Types
-- =====================================================

INSERT INTO public.credit_asset_types (name, display_name, description, icon, sort_order) VALUES
    ('icon', 'Icons', 'Icon assets used throughout the application', 'shapes-outline', 1),
    ('illustration', 'Illustrations', 'Illustration and vector graphics', 'brush-outline', 2),
    ('image', 'Images / Photos', 'Photographic images and pictures', 'image-outline', 3),
    ('sound', 'Sounds', 'Audio and sound effects', 'musical-notes-outline', 4),
    ('lottie', 'Lottie Animations', 'Lottie animation files', 'sparkles-outline', 5),
    ('video', 'Videos', 'Video content and clips', 'videocam-outline', 6),
    ('font', 'Fonts', 'Typography and font families', 'text-outline', 7)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- SEED DATA - Example Site (Flaticon)
-- =====================================================

-- Insert Flaticon as a site under Icons asset type
INSERT INTO public.credit_sites (asset_type_id, name, display_name, website_url, attribution_format, description, sort_order)
SELECT 
    id,
    'flaticon',
    'Flaticon',
    'https://www.flaticon.com',
    '<a href="{url}" title="{title}">{title} created by {author} - Flaticon</a>',
    'Icons by various contributors on Flaticon',
    1
FROM public.credit_asset_types 
WHERE name = 'icon'
ON CONFLICT (asset_type_id, name) DO NOTHING;

-- =====================================================
-- VIEW FOR ADMIN DASHBOARD
-- =====================================================

CREATE OR REPLACE VIEW public.credits_overview
WITH (security_invoker = true) AS
SELECT
    cat.id as asset_type_id,
    cat.name as asset_type_name,
    cat.display_name as asset_type_display_name,
    cat.icon as asset_type_icon,
    cat.sort_order as asset_type_sort,
    COUNT(DISTINCT cs.id) as site_count,
    COUNT(DISTINCT cl.id) as link_count
FROM public.credit_asset_types cat
LEFT JOIN public.credit_sites cs ON cs.asset_type_id = cat.id AND cs.is_active = TRUE
LEFT JOIN public.credit_links cl ON cl.site_id = cs.id AND cl.is_active = TRUE
WHERE cat.is_active = TRUE
GROUP BY cat.id, cat.name, cat.display_name, cat.icon, cat.sort_order
ORDER BY cat.sort_order;

-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
SELECT 'Credits Tables Migration Complete!' as status;
