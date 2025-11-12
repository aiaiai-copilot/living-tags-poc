# Living Tags PoC

AI-powered text tagging system for Russian jokes and anecdotes using Claude API and Supabase.

## Overview

This Proof of Concept demonstrates semantic text analysis using Claude AI to automatically tag Russian text content (jokes/anecdotes) with relevant categories. The system analyzes text content and assigns tags with confidence scores ranging from 0.0 to 1.0.

### Key Features

- **Auto-Tagging**: AI-powered semantic analysis using Claude API
- **Confidence Scores**: Each tag assignment includes a confidence metric (0.0-1.0)
- **Live Search**: Real-time filtering by tag names
- **Tag Management**: Pre-populated with 15 common Russian humor categories
- **Type-Safe**: Full TypeScript strict mode with comprehensive type definitions

## Technology Stack

### Frontend
- **React** 18.3.1 + **TypeScript** 5.8.3
- **Vite** 7.1.11 (dev server & build tool)
- **shadcn/ui** + **Tailwind CSS** 3.4.17 (UI components & styling)
- **React Router** 6.30.1 (client-side routing)

### Data & State Management
- **Supabase** 2.74.0 (PostgreSQL database)
- **@tanstack/react-query** 5.83.0 (async state management)
- **react-hook-form** 7.61.1 + **zod** 3.25.76 (form handling & validation)

### AI Integration
- **@anthropic-ai/sdk** (Claude API client)

## Prerequisites

Before you begin, ensure you have:

- **Node.js** 22.x LTS or later
- **npm** (comes with Node.js)
- **Supabase Account** - [Sign up at supabase.com](https://supabase.com)
- **Anthropic API Key** - [Get from Anthropic Console](https://console.anthropic.com)

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd living-tags-poc
```

### 2. Install Dependencies

```bash
npm install
```

This installs all required packages including React, TypeScript, Vite, Supabase client, Anthropic SDK, and shadcn/ui dependencies.

### 3. Database Setup

#### Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the database to be provisioned

#### Apply Database Migration

Option A: **Using Supabase Dashboard**
1. Open your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `supabase/migrations/20251111000000_initial_schema.sql`
4. Paste into the SQL Editor and click **Run**

Option B: **Using Supabase CLI** (if installed)
```bash
supabase db push
```

This migration creates:
- `tags` table (15 pre-populated Russian tags)
- `texts` table (3 sample jokes for testing)
- `text_tags` junction table (with confidence scores)
- Row Level Security policies
- Performance indexes

#### Verify Database Setup

In your Supabase dashboard, go to **Table Editor** and verify:
- `tags` table has 15 rows
- `texts` table has 3 rows
- `text_tags` table exists (initially empty)

### 4. Environment Configuration

#### Create Environment File

```bash
cp .env.local.example .env.local
```

#### Add Your Credentials

Edit `.env.local` and add your keys:

```bash
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_ANTHROPIC_API_KEY=sk-ant-api03-...
```

**Where to find these:**

**Supabase Credentials:**
1. Go to your Supabase project dashboard
2. Click **Settings** → **API**
3. Copy **Project URL** → use as `VITE_SUPABASE_URL`
4. Copy **anon/public key** → use as `VITE_SUPABASE_ANON_KEY`

**Anthropic API Key:**
1. Go to [Anthropic Console](https://console.anthropic.com)
2. Navigate to **API Keys**
3. Create a new key or copy existing one
4. Use as `VITE_ANTHROPIC_API_KEY`

⚠️ **Important:** Never commit `.env.local` to git! It's already in `.gitignore`.

### 5. Install shadcn/ui Components (Optional)

The project is pre-configured for shadcn/ui. Install components as needed:

```bash
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
npx shadcn@latest add dialog
npx shadcn@latest add badge
```

See `.claude/skills/shadcn-ui/Skill.md` for complete component installation guide.

## Running the Project

### Development Server

```bash
npm run dev
```

The app will be available at **http://localhost:3000**

### Build for Production

```bash
npm run build
```

Output will be in the `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
living-tags-poc/
├── src/
│   ├── components/       # React components
│   │   └── ui/          # shadcn/ui components
│   ├── lib/             # Core utilities
│   │   ├── supabase.ts  # Supabase client
│   │   ├── claude.ts    # Claude API client (to be added)
│   │   └── utils.ts     # Helper functions
│   ├── hooks/           # Custom React hooks
│   ├── types/           # TypeScript type definitions
│   │   └── index.ts     # Database types
│   ├── pages/           # Page components
│   │   └── Home.tsx     # Main page
│   ├── App.tsx          # Root component
│   ├── main.tsx         # App entry point
│   └── index.css        # Global styles
├── supabase/
│   └── migrations/      # Database migrations
├── docs/                # Documentation
├── .claude/             # Claude Code configuration
│   ├── subagents/       # Specialized development agents
│   ├── skills/          # Reusable workflows
│   ├── hooks/           # Monitoring system
│   └── mcp/             # MCP configuration
├── package.json
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.js
└── components.json      # shadcn/ui config
```

## Development Workflow

This project follows strict development practices using specialized subagents. See `CLAUDE.md` for complete guidelines.

### Quick Reference

**For React/UI work:**
- Use `frontend-specialist` subagent
- Located at `.claude/subagents/frontend-specialist.md`

**For Claude API integration:**
- Use `claude-integration-specialist` subagent
- Located at `.claude/subagents/claude-integration-specialist.md`

**For database changes:**
- Use `database-specialist` subagent
- Located at `.claude/subagents/database-specialist.md`

## Common Tasks

### Adding a New Text/Joke

Use the UI to add texts, or manually via Supabase dashboard:

```sql
INSERT INTO texts (content) VALUES ('Your Russian joke text here');
```

### Adding New Tags

```sql
INSERT INTO tags (name) VALUES ('Новая категория');
```

### Viewing Auto-Tag Results

```sql
SELECT
  t.content,
  tg.name,
  tt.confidence
FROM texts t
JOIN text_tags tt ON t.id = tt.text_id
JOIN tags tg ON tt.tag_id = tg.id
ORDER BY t.created_at DESC, tt.confidence DESC;
```

## Troubleshooting

### "Supabase URL or anon key not set"

**Solution:** Ensure `.env.local` exists and contains valid `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.

### "Failed to fetch tags/texts"

**Solution:**
1. Verify Supabase database migration was applied
2. Check RLS policies are enabled
3. Confirm anon key has correct permissions

### "Claude API error"

**Solution:**
1. Verify `VITE_ANTHROPIC_API_KEY` is set correctly
2. Check API key has sufficient credits
3. Review Anthropic API status page

### Port 3000 already in use

**Solution:** Use a different port:
```bash
npm run dev -- --port 3001
```

## Documentation

- **PoC Specification:** `docs/poc-specification.md`
- **Project Guidelines:** `CLAUDE.md`
- **Session Handoff:** `SESSION-HANDOFF.md`
- **Database Schema:** `supabase/migrations/20251111000000_initial_schema.sql`

## Technology Documentation

- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs)
- [Vite Guide](https://vite.dev/guide)
- [Supabase Documentation](https://supabase.com/docs)
- [Anthropic API Reference](https://docs.anthropic.com)
- [shadcn/ui Components](https://ui.shadcn.com)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [React Query (TanStack Query)](https://tanstack.com/query/latest)

## Security Notes

⚠️ **This is a Proof of Concept for testing purposes only.**

- API keys are stored in the frontend (acceptable for PoC)
- RLS policies are permissive (`USING (true)`)
- **Do NOT use this architecture in production**
- For production, implement proper backend API and authentication

## License

This is a Proof of Concept project for demonstration purposes.

## Support

For questions or issues:
1. Check the documentation in `docs/`
2. Review `CLAUDE.md` for development guidelines
3. Consult technology-specific documentation linked above
