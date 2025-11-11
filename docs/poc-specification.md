# PoC Specification: AI-Powered Text Tagging System

## Project Overview
Build a Proof of Concept for a SaaS platform that automatically tags text objects (jokes/anecdotes) using AI semantic analysis with Claude API.

## Technology Stack

### Core Dependencies
- **Node.js:** 22.x LTS
- **React:** 18.3.1
- **TypeScript:** 5.8.3
- **Vite:** 7.1.11
- **React Router:** 6.30.1
- **Supabase:** 2.74.0
- **UI Components:** shadcn/ui (already configured)
- **Styling:** Tailwind CSS 3.4.17
- **Forms:** react-hook-form 7.61.1 + zod 3.25.76

### Additional Required
- **API Client:** Anthropic SDK (@anthropic-ai/sdk)
- **State Management:** @tanstack/react-query 5.83.0 (already included)

## Database Schema (Supabase)

```sql
-- Tags table (flat structure, no categories)
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Text objects table
CREATE TABLE texts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Many-to-many relationship with confidence scores
CREATE TABLE text_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text_id UUID REFERENCES texts(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
  confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(text_id, tag_id)
);

-- Enable RLS
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE texts ENABLE ROW LEVEL SECURITY;
ALTER TABLE text_tags ENABLE ROW LEVEL SECURITY;

-- Simple policies for PoC (allow all operations)
CREATE POLICY "Allow all operations on tags" ON tags FOR ALL USING (true);
CREATE POLICY "Allow all operations on texts" ON texts FOR ALL USING (true);
CREATE POLICY "Allow all operations on text_tags" ON text_tags FOR ALL USING (true);
```

## Initial Data

### Pre-populated Tags (10-15 tags, flat list)
```javascript
const initialTags = [
  "Вовочка",
  "Штирлиц", 
  "Программисты",
  "Работа",
  "Семья",
  "Политика",
  "Черный юмор",
  "Каламбур",
  "Абсурд",
  "Советские",
  "Современные",
  "Детские",
  "Медицина",
  "Студенты",
  "Армия"
];
```

### Test Jokes for Demo
```javascript
const testJokes = [
  {
    content: "Штирлиц шёл по Берлину. Его выдавала волочащаяся за ним парашютная стропа."
  },
  {
    content: "Программист звонит в библиотеку:\n- Здравствуйте, Катю можно?\n- Она в архиве.\n- Разархивируйте её пожалуйста, она мне срочно нужна!"
  },
  {
    content: "Вовочка приходит домой из школы:\n- Папа, тебя в школу вызывают!\n- Что ты опять натворил?\n- Да ничего особенного, химичку немного взорвал.\n- Ну ладно, пойду завтра.\n- Да не в школу идти надо, а сразу в больницу!"
  }
];
```

## Claude API Integration

### Environment Variables (.env.local)
```bash
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_ANTHROPIC_API_KEY=your_claude_api_key
```

### API Request Structure
```typescript
interface TagAnalysisRequest {
  text: string;
  availableTags: Array<{
    id: string;
    name: string;
  }>;
}

interface TagAnalysisResponse {
  tags: Array<{
    id: string;
    name: string;
    confidence: number; // 0.0 to 1.0
    reasoning?: string; // optional explanation
  }>;
}
```

### Claude API Prompt Template
```typescript
const analyzeTextPrompt = (text: string, tags: Tag[]) => `
Analyze this Russian joke/anecdote and identify relevant tags from the provided list.

Available tags:
${JSON.stringify(tags.map(t => ({ id: t.id, name: t.name })), null, 2)}

Text to analyze:
"${text}"

Return a JSON object with the following structure:
{
  "tags": [
    {
      "id": "tag_uuid",
      "name": "tag_name", 
      "confidence": 0.95,
      "reasoning": "Brief explanation why this tag fits"
    }
  ]
}

Rules:
- Only use tags from the provided list
- Confidence score from 0.0 to 1.0
- Include tags with confidence > 0.3
- Maximum 5-7 most relevant tags
- Consider both explicit mentions and semantic meaning
- Reasoning is optional, only for debugging

Return ONLY valid JSON, no additional text.
`;
```

## UI Layout

### Main Application Structure
```
App
├── Header
│   └── App Title
├── Main Content
│   ├── Search Bar (Google-style)
│   ├── Add Text Button
│   └── Text List
│       └── Text Cards (with tags)
├── Add Text Modal
│   ├── Textarea
│   └── Submit Button
└── Tag Management Panel (collapsible)
    ├── Tag List
    └── Add Tag Input
```

### Component Hierarchy
```
src/
├── components/
│   ├── layout/
│   │   └── Header.tsx
│   ├── search/
│   │   └── SearchBar.tsx
│   ├── texts/
│   │   ├── TextList.tsx
│   │   ├── TextCard.tsx
│   │   └── AddTextModal.tsx
│   └── tags/
│       ├── TagBadge.tsx
│       ├── TagManager.tsx
│       └── ConfidenceIndicator.tsx
├── lib/
│   ├── supabase.ts
│   ├── claude.ts
│   └── utils.ts
├── hooks/
│   ├── useTexts.ts
│   ├── useTags.ts
│   └── useAutoTag.ts
└── types/
    └── index.ts
```

## Core Features Implementation

### 1. Text Object Management
- **Add Text:** Modal with textarea, auto-tag on submit
- **List Texts:** Display all texts with assigned tags
- **Tag Display:** Show tags with confidence percentage

### 2. Tag Display with Confidence
```tsx
// Confidence visualization component
interface TagWithConfidence {
  name: string;
  confidence: number; // 0.0 to 1.0
}

// Display format: "Программисты (87%)"
// Background: gradient from white (0%) through gray (50%) to black (100%)
// Text color: auto-contrast based on background
```

### 3. Live Search Interface
```tsx
// Search behavior
- As user types tag names, filter texts in real-time
- Support multiple tags (comma or space separated)
- Debounce search input by 300ms
- Show results count
- Highlight matching tags in results
```

### 4. Auto-Tagging Flow
```typescript
1. User submits new text
2. Show loading state ("Analyzing...")
3. Send to Claude API with available tags
4. Parse response, validate tag IDs
5. Save text with tag relationships and confidence scores
6. Update UI optimistically
7. Handle errors gracefully
```

## Development Steps

### Step 1: Project Setup
```bash
# Clone the template with your package.json
# Install additional dependency
npm install @anthropic-ai/sdk

# Setup Supabase project
# Run the SQL schema provided above
# Add environment variables
```

### Step 2: Core Infrastructure (Day 1)
1. Configure Supabase client with TypeScript types
2. Create React Query hooks for data fetching
3. Setup routing with React Router
4. Create base layout components

### Step 3: Basic CRUD Operations
1. Implement add text functionality (without AI)
2. Create text list with static tags
3. Add tag management panel
4. Setup search bar UI

### Step 4: Claude API Integration (Day 2)
1. Setup Anthropic SDK client
2. Implement auto-tagging function
3. Add confidence visualization
4. Handle API errors and rate limiting

### Step 5: Live Search & Polish (Day 3)
1. Implement live filtering logic
2. Add debouncing for search
3. Create loading states
4. Add error boundaries
5. Final UI polish

## Success Metrics
- ✅ AI correctly identifies relevant tags in 80% of test cases
- ✅ Auto-tagging completes within 2 seconds
- ✅ Live search updates within 100ms of typing
- ✅ Confidence scores clearly visible and intuitive
- ✅ Zero crashes during basic operations

## Error Handling
```typescript
// API Errors
- Claude API timeout: Show fallback UI, allow manual tagging
- Rate limiting: Queue requests, show estimated wait time
- Invalid response: Log error, show generic message

// Supabase Errors
- Connection lost: Show offline indicator, retry automatically
- Query errors: Show user-friendly messages
```

## Optional Features (if time permits)
1. **Bulk Re-tagging:** When new tag is added, analyze all existing texts
2. **Confidence Threshold Setting:** User can set minimum confidence to display
3. **Tag Statistics:** Show usage count for each tag
4. **Export/Import:** JSON format for backup

## Testing Checklist
- [ ] Add 10+ different jokes
- [ ] Verify auto-tagging accuracy
- [ ] Test search with multiple tags
- [ ] Check confidence visualization
- [ ] Test error states (disable network)
- [ ] Verify responsive design
- [ ] Check performance with 100+ texts

## Deployment
```bash
# Build for production
npm run build

# Deploy to Vercel
vercel --prod

# Or deploy to Netlify
netlify deploy --prod
```

## Notes for Claude Code
- Start with the provided package.json configuration
- Use existing shadcn/ui components where possible
- Follow React Query patterns for data fetching
- Implement proper TypeScript types from the beginning
- Use Zod for runtime validation of API responses
- Keep components small and focused
- Use Tailwind classes for styling, avoid inline styles
- Implement proper loading and error states for all async operations