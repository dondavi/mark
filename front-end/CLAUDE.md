# Next.js Frontend Development & Testing Best Practices

## Overview
This document outlines best practices for developing and testing Next.js applications, balancing productivity, reliability, maintainability, and performance.

---

## I. DEVELOPMENT BEST PRACTICES

### 1. Project Structure & Organization

```
my-nextjs-app/
├── src/
│   ├── app/                    # App Router (Next.js 13+)
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── [slug]/
│   │       └── page.tsx
│   ├── components/
│   │   ├── common/             # Reusable components
│   │   ├── features/           # Feature-specific components
│   │   └── ui/                 # UI library components
│   ├── hooks/                  # Custom React hooks
│   ├── lib/                    # Utility functions
│   ├── styles/                 # Global styles, Tailwind config
│   ├── types/                  # TypeScript types & interfaces
│   └── middleware.ts
├── public/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── next.config.js
├── tsconfig.json
└── package.json
```

**Rationale**: Clear separation of concerns enables faster navigation, easier testing, and smoother onboarding.

---

### 2. TypeScript Configuration

Always use TypeScript. Configure `tsconfig.json` for strict type safety:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "esModuleInterop": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src", "tests"],
  "exclude": ["node_modules", ".next", "out", "dist"]
}
```

---

### 3. Component Design Patterns

#### Functional Components with Hooks
Always use functional components with hooks (no class components unless legacy):

```typescript
// ✅ GOOD
interface UserProfileProps {
  userId: string;
  isLoading?: boolean;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId, isLoading = false }) => {
  const [user, setUser] = React.useState<User | null>(null);
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch(`/api/users/${userId}`);
        setUser(await response.json());
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      }
    };

    if (userId) fetchUser();
  }, [userId]);

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorBoundary message={error} />;
  if (!user) return null;

  return <div>{user.name}</div>;
};
```

#### Server Components (Default in App Router)

```typescript
// ✅ GOOD - Server Component (default)
// No "use client" directive - runs on server only
export default async function PostList() {
  const posts = await fetchPosts(); // Safe to call DB directly
  
  return (
    <ul>
      {posts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </ul>
  );
}

// ✅ Client Component when needed
'use client';

export const InteractivePost: React.FC<{ id: string }> = ({ id }) => {
  const [liked, setLiked] = React.useState(false);
  
  return (
    <button onClick={() => setLiked(!liked)}>
      {liked ? '❤️' : '🤍'} Like
    </button>
  );
};
```

**Key Principle**: Favor Server Components by default; use `'use client'` only when you need interactivity or hooks.

---

### 4. State Management

#### For Simple State
Use React hooks (useState, useReducer).

#### For Complex Global State
Prefer lightweight solutions:
- **Zustand** (recommended): Simple, minimal boilerplate
- **Jotai**: Primitive-based state
- **TanStack Query (React Query)**: For server state, caching, synchronization

```typescript
// Zustand example
import { create } from 'zustand';

interface AuthStore {
  user: User | null;
  setUser: (user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: () => set({ user: null }),
}));
```

**Avoid Redux in Next.js** unless you have extreme complexity; it's usually overkill.

---

### 5. Data Fetching Strategy

#### Server-Side Data Fetching (Preferred)

```typescript
// app/posts/page.tsx
async function PostsPage() {
  const posts = await fetch('https://api.example.com/posts', {
    next: { revalidate: 3600 } // ISR: revalidate every hour
  }).then(r => r.json());

  return <PostList posts={posts} />;
}
```

#### Client-Side with TanStack Query

```typescript
'use client';

import { useQuery } from '@tanstack/react-query';

export const UserPosts: React.FC<{ userId: string }> = ({ userId }) => {
  const { data: posts, isLoading, error } = useQuery({
    queryKey: ['posts', userId],
    queryFn: () => fetch(`/api/users/${userId}/posts`).then(r => r.json()),
  });

  if (isLoading) return <Skeleton />;
  if (error) return <Error message={error.message} />;

  return <PostList posts={posts} />;
};
```

---

### 6. Styling Strategy

#### Use Tailwind CSS + CSS Modules

```typescript
// styles/UserCard.module.css
.card {
  @apply p-4 border rounded-lg shadow-md hover:shadow-lg transition-shadow;
}

.title {
  @apply text-lg font-bold text-gray-900;
}
```

```typescript
// components/UserCard.tsx
import styles from '@/styles/UserCard.module.css';

export const UserCard: React.FC<{ user: User }> = ({ user }) => (
  <div className={styles.card}>
    <h2 className={styles.title}>{user.name}</h2>
  </div>
);
```

**Avoid styled-components in Server Components** — they require client-side JavaScript.

---

### 7. Error Handling & Error Boundaries

```typescript
'use client';

import React from 'react';

interface Props {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export class ErrorBoundary extends React.Component<Props> {
  state = { hasError: false, error: null as Error | null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="p-4 bg-red-50 border border-red-200 rounded">
            <p className="text-red-800">Something went wrong</p>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
```

---

## II. TESTING STRATEGY

### 1. Unit Tests (Jest + React Testing Library)

**Purpose**: Validate individual components and functions in isolation.

#### Setup

```bash
npm install --save-dev jest @testing-library/react @testing-library/jest-dom @types/jest
```

```typescript
// jest.config.js
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

module.exports = createJestConfig({
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  testMatch: [
    '<rootDir>/tests/unit/**/*.test.ts(x)?',
    '<rootDir>/src/**/__tests__/**/*.test.ts(x)?',
  ],
});
```

#### Example Unit Test

```typescript
// tests/unit/components/Button.test.tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/Button';

describe('Button Component', () => {
  it('should render with label', () => {
    render(<Button label="Click me" />);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('should call onClick handler when clicked', () => {
    const handleClick = jest.fn();
    render(<Button label="Click" onClick={handleClick} />);

    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('should be disabled when disabled prop is true', () => {
    render(<Button label="Click" disabled={true} />);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

**Best Practices**:
- Test user behavior, not implementation details
- Use semantic queries: `getByRole`, `getByLabelText`, `getByPlaceholderText`
- Avoid testing internal state directly; test outputs
- Mock external dependencies (API calls, third-party services)
