# Local Development Guide

This guide shows how to run the Nexus frontend locally and connect it to the remote Nexus server.

## Prerequisites

1. **Node.js 18+** installed
2. **npm** or **pnpm** package manager

## Quick Start

### Step 1: Install Dependencies

```bash
cd nexus-frontend-multifi
npm install
# or
pnpm install
```

### Step 2: Configure Environment

The `.env.local` file is already configured to connect to the remote server:
- **Server URL**: `https://nexus-server.multifi.ai`
- **API Key**: Empty (will prompt user for input)

If you need to change the server URL, edit `.env.local`:

```bash
# .env.local
VITE_NEXUS_API_URL=https://nexus-server.multifi.ai
VITE_NEXUS_SERVER_URL=https://nexus-server.multifi.ai
VITE_API_URL=https://nexus-server.multifi.ai
VITE_API_KEY=
```

### Step 3: Start the Development Server

```bash
npm run dev
# or
pnpm dev
```

The frontend will start on **http://localhost:5173** (or another port if 5173 is busy).

### Step 4: Enter Your API Key

When the app loads:

1. **Login Dialog** will appear automatically if you're not authenticated
2. Enter your Nexus API key (e.g., `sk-acme_admin_367bd69e_36243aca532386441d70b2b7ae22c9c0`)
3. Click **"Login"** or press Enter
4. The app will validate your API key and connect to the server

### Step 5: Use the Application

Once authenticated, you can:
- Browse files and folders
- Upload files
- Create folders
- Search files
- Use the chat/agent features
- Manage connections, agents, skills, etc.

## Changing API Key or Server URL

You can change your connection settings at any time:

1. Click the **"Connection"** button in the top navigation
2. Enter a new **Server URL** (if needed)
3. Enter a new **API Key**
4. Click **"Test Connection"** to verify
5. Click **"Save"** to update your connection

Your settings are saved in browser localStorage and will persist across sessions.

## Troubleshooting

### Login Dialog Doesn't Appear

If the login dialog doesn't appear automatically:
1. Click the **"Login"** button in the top navigation
2. Or check browser console for errors

### "Invalid API Key" Error

1. Verify your API key is correct
2. Check that the server URL is correct: `https://nexus-server.multifi.ai`
3. Test the connection using the connection management dialog

### CORS Errors

If you see CORS errors in the browser console:
- The remote server should already be configured to allow CORS
- If issues persist, check the server configuration

### Connection Refused

1. Verify the server is running: `curl https://nexus-server.multifi.ai/health`
2. Check your internet connection
3. Verify the server URL in `.env.local` is correct

## Environment Variables

The following environment variables are used:

- `VITE_NEXUS_API_URL` - Nexus API server URL (default: from .env.local)
- `VITE_NEXUS_SERVER_URL` - Nexus server URL for LangGraph (default: from .env.local)
- `VITE_API_URL` - Alternative API URL (default: from .env.local)
- `VITE_API_KEY` - API key (optional, can be entered via UI)

**Note**: Environment variables must start with `VITE_` to be accessible in the frontend code.

## Development Tips

### Hot Module Replacement (HMR)

The dev server supports HMR. Code changes will automatically reflect in the browser without full reload.

### TypeScript Errors

Check for TypeScript errors:
```bash
npx tsc --noEmit
```

### Clearing Cache

If you encounter strange behavior:
```bash
rm -rf node_modules dist .vite
npm install
npm run dev
```

### Inspecting Network Requests

Open browser DevTools (F12) → Network tab to see API requests and responses.

## Production Build

To build for production:

```bash
npm run build
```

The output will be in the `dist/` directory.

## Next Steps

- See [QUICKSTART.md](./QUICKSTART.md) for more detailed usage
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for deployment instructions
