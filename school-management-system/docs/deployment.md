# Deployment Guide

## GitHub

1. Create a new GitHub repository.
2. Upload all files from this package.
3. Commit to the default branch.

## Vercel

1. Open Vercel.
2. Import the GitHub repository.
3. Framework preset: Other.
4. Build command: leave empty.
5. Output directory: leave empty.
6. Deploy.

The included `vercel.json` rewrites all routes to `index.html`.

## Supabase Configuration

Open `config.js` and set:

```js
window.SUPABASE_URL = 'https://ewygeuwxnmemidfrhlua.supabase.co';
window.SUPABASE_ANON_KEY = 'your-public-anon-key';
```

The anon key is public by design, but the database must be protected with Row Level Security.
