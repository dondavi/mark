# Front-End — Back-End Service Dashboard

A Next.js dashboard that monitors the health of a back-end API service running at `http://127.0.0.1:8000`.

## Tech Stack

- **Next.js** 16 (App Router)
- **React** 19
- **TypeScript** 5 (strict mode)
- **Tailwind CSS** 4

## Prerequisites

- Node.js 20+
- npm
- The back-end service running on `http://127.0.0.1:8000` (for health checks and API docs)

## Installation

```bash
npm install
```

## Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the dashboard.

The page auto-updates as you edit files.

## Available Scripts

| Script | Command | Description |
|--------|---------|-------------|
| `dev` | `npm run dev` | Start the development server |
| `build` | `npm run build` | Build for production |
| `start` | `npm run start` | Start the production server |
| `lint` | `npm run lint` | Run ESLint |

## Project Structure

```
front-end/
├── app/
│   ├── layout.tsx       # Root layout (Geist font, metadata)
│   ├── page.tsx         # Dashboard home page (health check UI)
│   ├── globals.css      # Global styles and Tailwind imports
│   └── favicon.ico
├── public/              # Static assets (SVGs)
├── next.config.ts       # Next.js configuration
├── tsconfig.json        # TypeScript configuration
├── postcss.config.mjs   # PostCSS / Tailwind plugin
├── eslint.config.mjs    # ESLint configuration
└── package.json
```

## Features

- **Health Status Monitor** — Fetches `/health` from the back-end API and displays a live status indicator (green/red).
- **Manual Refresh** — Button to re-check the API health on demand.
- **API Docs Link** — Direct link to the back-end Swagger documentation.
- **Dark Mode** — Automatic support via `prefers-color-scheme`.

## Deployment

Build and start the production server:

```bash
npm run build
npm run start
```

For Vercel deployment, see the [Next.js deployment docs](https://nextjs.org/docs/app/building-your-application/deploying).
