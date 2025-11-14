# GitHub Copilot Instructions for Absendo

## Project Overview

Absendo is a React-based web application that automates absence form filling for BBZW students. It integrates with school calendars and uses end-to-end encryption to secure student data.

**Key Features:**
- Automated absence form generation
- School calendar integration (iCal format)
- End-to-end encryption for personal data
- PDF form generation
- Supabase authentication and data storage

## Technology Stack

- **Framework:** React 19 with TypeScript
- **Build Tool:** Vite 6
- **Styling:** Tailwind CSS 4 + DaisyUI
- **Routing:** React Router DOM v7
- **Backend:** Supabase (auth, database)
- **Key Libraries:**
  - `pdf-lib` for PDF manipulation
  - `crypto-js` for encryption
  - `ical` for calendar parsing
  - `cally` for calendar UI

## Architecture & Patterns

### Directory Structure
- `src/components/` - Reusable React components
- `src/pages/` - Page-level components
- `src/services/` - Business logic and external integrations
- `src/data/` - Static data and constants
- `public/` - Static assets

### Code Style & Conventions

1. **TypeScript:**
   - Use strict TypeScript typing
   - Avoid `any` types; use proper type definitions
   - Define interfaces for complex data structures
   - Use type inference where appropriate

2. **React Components:**
   - Prefer functional components with hooks
   - Use TypeScript for prop types (no PropTypes)
   - Keep components focused and single-purpose
   - Extract reusable logic into custom hooks

3. **Styling:**
   - Use Tailwind CSS utility classes
   - Leverage DaisyUI components for consistent UI
   - Avoid inline styles unless necessary
   - Use semantic class names when needed

4. **File Naming:**
   - Components: PascalCase (e.g., `Calendar.tsx`)
   - Services/utilities: camelCase (e.g., `encryptionService.ts`)
   - Types/interfaces: PascalCase in dedicated files or inline

## Security Considerations

**CRITICAL:** This application handles sensitive student data with end-to-end encryption.

- Never log sensitive user data (passwords, calendar URLs, personal info)
- Always use encryption services for storing personal data
- Validate and sanitize user inputs, especially calendar URLs
- Follow secure coding practices for authentication flows
- Keep Supabase keys in environment variables only

## Development Workflow

### Commands
- `npm run dev` - Start development server (port 5173)
- `npm run build` - Build for production (TypeScript check + Vite build)
- `npm run lint` - Run ESLint
- `npm run preview` - Preview production build

### Testing & Validation
- Run `npm run build` before committing to catch TypeScript errors
- Run `npm run lint` to ensure code quality
- Test calendar import with various iCal formats
- Verify PDF generation works correctly

## Common Patterns in This Codebase

### Supabase Integration
```typescript
// Use the centralized Supabase client
import { supabase } from './supabaseClient';

// Authentication
const { data, error } = await supabase.auth.signIn({...});

// Database operations
const { data, error } = await supabase
  .from('table_name')
  .select('*');
```

### Encryption
```typescript
// Use encryptionService for sensitive data
import { encryptData, decryptData } from './services/encryptionService';

const encrypted = encryptData(sensitiveData, userKey);
const decrypted = decryptData(encrypted, userKey);
```

### Routing
```typescript
// Use React Router v7 patterns
import { useNavigate, useParams } from 'react-router-dom';
```

## Guidelines for AI Assistance

### When Writing Code:
1. **Maintain consistency** with existing patterns in the codebase
2. **Prioritize security** - especially for encryption and data handling
3. **Use TypeScript properly** - define types, avoid any
4. **Follow React best practices** - hooks, component composition
5. **Keep it simple** - prefer readability over cleverness

### When Making Changes:
1. **Preserve working functionality** - don't break existing features
2. **Update types** when changing data structures
3. **Test calendar parsing** if modifying iCal integration
4. **Verify PDF generation** if changing form logic
5. **Check responsive design** for UI changes

### When Adding Features:
1. Consider **security implications** first
2. Follow the **existing architecture** patterns
3. Add **proper error handling**
4. Use **TypeScript types** for new structures
5. Keep **components modular** and reusable

## Important Context

- **Users:** BBZW students (Swiss vocational school)
- **Language:** UI is likely in German (school context)
- **Data Privacy:** GDPR compliance is important
- **Deployment:** Hosted on Vercel
- **Backend:** Separate repository for backend services

## Dependencies to Know

- **Supabase:** Authentication, database, storage
- **pdf-lib:** Creating/modifying PDF forms
- **ical:** Parsing school calendar feeds
- **crypto-js:** Client-side encryption
- **DaisyUI:** Component library (check docs for available components)

## Avoid

- Adding unnecessary dependencies
- Breaking changes to the encryption scheme (would lose user data)
- Exposing sensitive data in logs or error messages
- Ignoring TypeScript errors
- Skipping build validation before changes
- Using deprecated React patterns (class components, legacy context)
