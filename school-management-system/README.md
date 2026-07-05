# School Management System

A browser-based school management system for one school, backed by Supabase and deployable on Vercel.

This package contains the uploaded working application prepared as a GitHub/Vercel-ready repository.

## Features

- Dashboard
- Students
- Classes
- Subjects
- Attendance
- Daily attendance
- Scores
- Report cards
- Performance reports
- Users and approvals
- Parent portal
- Notices
- Messages
- Fees and payments
- Calendar
- Exam timetable
- Awards
- Rankings
- Audit log
- Data export
- Settings
- Dark mode

## Project Files

```text
.
├── index.html
├── config.js
├── vercel.json
├── README.md
├── SECURITY.md
├── .gitignore
├── .env.example
└── docs/
    ├── deployment.md
    ├── database.md
    └── developer-notes.md
```

## Quick Start

1. Create a new GitHub repository (or open an existing empty one).
2. Unzip this package on your computer first — you should see `index.html`, `config.js`, `vercel.json`, etc. sitting directly inside the unzipped folder.
3. On GitHub, use **Add file → Upload files**, then drag in the **contents** of that unzipped folder (select all the files and the `docs` folder together and drop them in) — do **not** drag the outer folder itself. `index.html` must land at the **root** of the repo, not inside a subfolder.
4. Commit the files to the default branch (e.g. `main`).
5. Open `config.js` and confirm your Supabase URL and anon key are correct.
6. In Vercel, import the repository. Framework preset: **Other**. Build command and Output directory: leave empty. **Root Directory: leave blank** (do not point it at a subfolder).
7. Deploy.

### How to verify before deploying
Open the repo on GitHub in your browser. The very first thing you should see listed is `index.html` — if you have to click into a folder first to find it, the upload was nested incorrectly and Vercel will return a 404. Move the files up to the root and re-commit.

The app is a static single-page app. No build step is required.

## Local Use

You can open `index.html` directly in a browser, but using a local static server is better:

```bash
npx serve .
```

Then open the local URL shown by the command.

## Supabase

This app expects an existing Supabase project with the tables used by the current system.

Required table names are documented in [docs/database.md](docs/database.md).

## Important Production Note

The current uploaded application uses custom browser-side authentication and direct Supabase REST calls. It is usable with your existing project, but before using it for sensitive real-school production data, migrate it to Supabase Auth and strict Row Level Security.

See [SECURITY.md](SECURITY.md).

