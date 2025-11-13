# Project Handoff: Living Tags Prototype

**Status:** Ready for implementation
**Phase:** Prototype (Stage 2)
**Specification Version:** 1.2
**Date:** 2025-11-13

---

## Quick Start

### What You're Building

A **multi-user AI text tagging platform** where users can:
- Store collections of Russian jokes/anecdotes
- Auto-tag them using Claude AI with confidence scores
- Manually correct AI mistakes with inline editing
- Manage their personal tag glossary
- Import/export collections with full fidelity

**Demo Use Case:** Russian humor categorization (Вовочка, Штирлиц, Программисты, etc.)

### What's Already Done

✅ **PoC (Proof of Concept)** - Fully validated:
- Single-user frontend app (React + TypeScript + Vite)
- Auto-tagging with Claude API (80%+ accuracy, <2s response time)
- Basic UI with shadcn/ui components
- Supabase database with simple schema
- Live search by tags

📁 **Code Location:** Current repository (`/home/user/living-tags-poc`)

### What You Need to Build (Prototype)

This is an **incremental upgrade** of the PoC, adding:

1. **Multi-user system** (Supabase Auth + RLS)
2. **Tag glossary management** (CRUD operations)
3. **Manual tag editing** (inline UI to fix AI mistakes)
4. **Import/Export** (with AI/manual source preservation)

**Timeline:** 3-6 days (4 phases)

---

## Essential Documents

Read these **in order**:

1. **[docs/prototype-specification.md](./docs/prototype-specification.md)** (THIS IS YOUR BIBLE)
   - Complete feature specs
   - Database schema with migration SQL
   - UI mockups and component structure
   - Implementation examples
   - Testing checklists

2. **[CLAUDE.md](./CLAUDE.md)** (DEVELOPMENT RULES - MANDATORY)
   - **CRITICAL:** You MUST use specialized subagents (see below)
   - Technology stack restrictions
   - Code standards (strict TypeScript, no `any`, etc.)
   - Monitoring and compliance

3. **[docs/poc-specification.md](./docs/poc-specification.md)** (Context)
   - What the PoC accomplished
   - Current tech stack details

4. **[docs/text-collection-saas-plan.md](./docs/text-collection-saas-plan.md)** (Vision)
   - Full product roadmap (PoC → Prototype → MVP → Production)
   - Stage 2 is what you're building now

---

## Critical: Subagent Usage (MANDATORY)

**You MUST NOT implement features directly.** All work goes through specialized subagents:

### frontend-specialist
**Use for:**
- React components (Auth, Tag Manager, Import/Export, Inline Tag Editor)
- UI/UX implementation with shadcn/ui
- React hooks and state management
- Responsive design

**Location:** `.claude/subagents/frontend-specialist.md`

### claude-integration-specialist
**Use for:**
- Claude API integration
- Auto-tagging logic (including preserving manual tags)
- Batch processing for imports
- Queue management

**Location:** `.claude/subagents/claude-integration-specialist.md`

### database-specialist
**Use for:**
- New migration file for multi-tenant schema
- RLS policies testing
- Database optimization

**Location:** `.claude/subagents/database-specialist.md`

**Violation = Non-compliance.** See CLAUDE.md for monitoring details.

---

## Key Technical Decisions

### Architecture

**Database Strategy:** Clean schema approach (Option B)
- No migration from PoC data
- Fresh multi-tenant schema with `user_id` from the start
- See `docs/prototype-specification.md` lines 84-270 for complete SQL

**Auth Strategy:** Frontend-only with Supabase Auth
- No custom backend needed
- Row Level Security (RLS) for data isolation
- Email/password (social login optional)

**AI/Manual Tag Distinction:** Source tracking
- `text_tags.source`: `'ai'` or `'manual'`
- Manual tags preserved during AI re-tagging
- Visual distinction in UI (AI = gray with %, Manual = solid with ✓)

**Import/Export:** Flexible format support
- Format 1: String array → manual tags
- Format 2: Object without source → AI tags
- Format 3: Full object with source → preserves distinction
- Export always includes source for lossless backup

### Technology Stack (ENFORCED)

**Must Use:**
- React 18.3.1 + TypeScript 5.8.3 (strict mode)
- shadcn/ui components ONLY
- Tailwind CSS (no inline styles)
- Supabase 2.74.0
- @anthropic-ai/sdk
- React Query 5.83.0

**Forbidden:**
- Any other UI library (MUI, Ant Design, etc.)
- Redux/MobX/Zustand
- Inline styles
- TypeScript `any` type

---

## Implementation Roadmap

### Phase 1: Database & Auth (Days 1-2)
```
□ Create migration: supabase/migrations/20251113000000_prototype_schema.sql
□ Test RLS policies with 2 test accounts
□ Build auth UI (Landing, Sign In/Up, Protected routes)
□ Verify complete data isolation
```

**Key Files to Create:**
- Migration SQL (copy from spec lines 84-270)
- `src/components/auth/LandingPage.tsx`
- `src/components/auth/AuthModal.tsx`
- `src/hooks/useAuth.ts`

### Phase 2: Tag Glossary Management (Days 3-4)
```
□ Tag CRUD UI (sidebar with add/edit/delete)
□ Sync logic (rename updates everywhere, delete cascades)
□ "Auto-tag existing texts" feature for new tags
□ Usage count display
```

**Key Files to Create:**
- `src/components/tags/TagManager.tsx`
- `src/components/tags/AddTagModal.tsx`
- `src/hooks/useTags.ts` (CRUD operations)

### Phase 3: Manual Tag Editing (Days 4-5)
```
□ Inline tag editor on text cards
□ Add tag dropdown (searchable)
□ Remove tag functionality (both AI and manual)
□ Visual distinction (AI tags vs manual tags)
□ Update auto-tag logic to preserve manual tags
```

**Key Files to Create:**
- `src/components/tags/InlineTagEditor.tsx`
- `src/components/tags/TagDropdown.tsx`
- `src/hooks/useManualTag.ts`
- Update `src/components/tags/TagBadge.tsx` (add `source` prop)

**Critical Implementation:**
See spec lines 547-586 for `parseImportedTag()` logic

### Phase 4: Import/Export (Days 5-6)
```
□ Import UI (file picker, preview, progress)
□ Tag format detection (string/object/full)
□ Export with source preservation
□ Test round-trip (export → import → verify)
```

**Key Files to Create:**
- `src/components/import-export/ImportModal.tsx`
- `src/components/import-export/ExportModal.tsx`
- `src/hooks/useImport.ts`
- `src/hooks/useExport.ts`

---

## Database Schema Overview

**Core Tables:**
```
tags          → user's tag glossary (user_id, name, created_at)
texts         → user's text collection (user_id, content, created_at)
text_tags     → many-to-many (text_id, tag_id, confidence, source)
```

**Key Addition from PoC:**
- All tables have `user_id` column
- RLS policies enforce data isolation
- `text_tags.source` tracks 'ai' vs 'manual'

**Complete SQL:** spec lines 84-270

---

## UI/UX Highlights

### Main Layout
```
┌────────────────────────────────────────────┐
│ Living Tags    [user@email.com] [Sign Out]│
├──────────────┬─────────────────────────────┤
│ TAG GLOSSARY │ [Search] [Import] [Export]  │
│ (15)         │                             │
│              │ ┌─────────────────────────┐ │
│ Вовочка (23) │ │ Text content...         │ │
│ Штирлиц (12) │ │ [AI tag 95%] [Manual ✓] │ │
│ ...          │ │ [+ Add tag ▾]           │ │
│              │ └─────────────────────────┘ │
│ [+ Add Tag]  │                             │
└──────────────┴─────────────────────────────┘
```

### Visual Language
- **AI tags:** Light gray, show confidence % (e.g., "Штирлиц 95%")
- **Manual tags:** Solid color, checkmark icon (e.g., "Абсурд ✓")
- **Inline editing:** No modals, dropdown appears on card

---

## Testing Requirements

### Must Test
- **Data isolation:** 2 users can't see each other's data
- **Manual tag preservation:** AI re-tag doesn't remove manual tags
- **Round-trip:** export → import → manual tags still manual
- **Import formats:** All 3 formats work (string/object/full)
- **Performance:** 100+ texts import in <5 minutes

**Complete checklist:** spec lines 1054-1158

---

## Environment Setup

### Required Credentials
```bash
# .env.local
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_ANTHROPIC_API_KEY=sk-ant-api03-...
```

### Initial Setup
```bash
# Dependencies already installed (package.json exists)
npm install

# Create migration in Supabase dashboard
# Copy SQL from spec lines 84-270

# Run dev server
npm run dev
```

---

## Code Standards (ENFORCED)

### TypeScript
```typescript
// ✅ GOOD
interface TagBadgeProps {
  name: string;
  confidence: number;
  source: 'ai' | 'manual';
}

// ❌ BAD
const props: any = { ... };  // NO 'any' types
```

### Styling
```tsx
// ✅ GOOD
<div className="flex items-center gap-2 p-4">

// ❌ BAD
<div style={{ display: 'flex', padding: '16px' }}>  // NO inline styles
```

### Async Operations
```tsx
// ✅ ALWAYS include loading and error states
const { data, isLoading, error } = useTexts();

if (isLoading) return <Skeleton />;
if (error) return <ErrorDisplay />;
```

---

## Potential Gotchas

### 1. Import Format Detection
**Problem:** Need to distinguish 3 formats
**Solution:** Use `typeof tag === 'string'` and `tag.source` checks
**Reference:** spec lines 547-586

### 2. Manual Tag Preservation
**Problem:** AI re-tag might overwrite manual tags
**Solution:** Always filter by `source='ai'` before deleting
**Reference:** spec lines 861-896

### 3. RLS Policy Complexity
**Problem:** text_tags needs to check parent texts table for user_id
**Solution:** Use EXISTS subquery in policy
**Reference:** spec lines 195-233

### 4. Tag Glossary Sync
**Problem:** Rename tag should update all text associations
**Solution:** Tag ID stays same, only name changes (no CASCADE needed)
**Reference:** spec lines 387-395

---

## Success Criteria

**You're done when:**
- ✅ 2 test users can't see each other's data
- ✅ Manual tag editing works with clear AI/manual distinction
- ✅ Import 100+ texts successfully
- ✅ Export → re-import → all sources match
- ✅ All PoC features still work (auto-tag, search, confidence)
- ✅ No TypeScript errors, no `any` types
- ✅ No critical bugs in core workflows

---

## Help & Resources

### When Stuck
1. **Check spec first:** `docs/prototype-specification.md`
2. **Check CLAUDE.md:** For development rules
3. **Use correct subagent:** Don't implement directly
4. **Review PoC code:** See how things currently work

### Where Things Are
- **Database schema:** spec lines 84-270
- **Import logic:** spec lines 522-586
- **Manual tag editing:** spec lines 676-945
- **Component structure:** spec lines 1018-1063
- **Type definitions:** spec lines 938-1016
- **Testing checklist:** spec lines 1054-1158

### File Tree Reference
```
living-tags-poc/
├── docs/
│   ├── prototype-specification.md  ← YOUR BIBLE
│   ├── poc-specification.md        ← Context
│   └── text-collection-saas-plan.md ← Vision
├── .claude/
│   ├── subagents/                  ← MUST USE THESE
│   │   ├── frontend-specialist.md
│   │   ├── claude-integration-specialist.md
│   │   └── database-specialist.md
│   └── skills/
│       ├── project-setup.md
│       └── db-reset.md
├── supabase/
│   └── migrations/
│       └── 20251113000000_prototype_schema.sql  ← CREATE THIS
├── src/
│   ├── components/  ← BUILD THESE
│   ├── hooks/       ← BUILD THESE
│   ├── lib/         ← UPDATE THESE
│   └── types/       ← UPDATE THESE
├── CLAUDE.md        ← DEVELOPMENT RULES
├── README.md        ← Project info
└── package.json     ← Dependencies ready
```

---

## Final Notes

**This is an iterative upgrade, not a rewrite.** You're adding multi-user capabilities to a working single-user app.

**Key Insight:** The hardest part (AI tagging) is already solved in the PoC. Your job is plumbing (auth, RLS, CRUD) and UX polish (inline editing, import/export).

**Philosophy:** Simple > Complex. Users want to fix AI mistakes quickly → inline editing. Users want data safety → source preservation.

**Remember:** Use subagents. Follow the spec. Test thoroughly. Ship incrementally.

---

## Questions?

1. **"Where do I start?"** → Phase 1: Database migration + Auth
2. **"Which subagent?"** → See spec lines 950-993
3. **"How do imports work?"** → See spec lines 461-586
4. **"What if I'm stuck?"** → Read spec section again, check PoC code
5. **"Can I skip manual tags?"** → No, this addresses real user pain

**You have everything you need. The spec is comprehensive. Go build! 🚀**
