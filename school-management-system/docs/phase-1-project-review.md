# Phase 1 Project Review - School Management System

Review date: 2026-07-05

## Source Inventory

Uploaded archive: `shine_system-main.zip`

Extracted project contains only:

- `index.html` - 5,713 lines; all UI, styles, routing, data access, auth, reporting, and business logic.
- `config.js` - Supabase URL and anon key assignment on `window`.
- `vercel.json` - SPA rewrite and a few security headers.

The current application should be treated as a feature reference, not an architecture to preserve.

## Current Feature Surface

Existing feature coverage found in the monolith:

- Authentication-like flows: login, logout, registration, password reset code, 2FA code, session timeout.
- Roles: admin, teacher, parent/student. Accountant and student as separate roles are not implemented.
- Dashboard with role-sensitive summary cards.
- Students: CRUD, photo as base64, transfer, bulk import, alumni archive.
- Classes, subjects, teacher/class assignments, subject assignments.
- Scores: classwork items, weighted class score, exam score, final score, Excel export.
- Attendance: term attendance and daily attendance.
- Report cards: remarks, ranking, print one, print all.
- Users: create, approve, reject, deactivate, delete.
- Settings: school info, logo, academic year, term, grading, EmailJS, security settings, account settings.
- Parent portal: parent/student linking and parent views.
- Notices and messages.
- Progress chart, failure report, audit log, data management exports/deletes.
- Fees and payments.
- Calendar, exam timetable, awards, rankings, term rollover.

## Major Findings

### Architecture

- The application is a 5,713-line single HTML file with 237 top-level functions and about 30 page render functions.
- CSS, HTML, routing, services, data mapping, auth, business rules, exports, and UI state are tightly coupled.
- Navigation uses global functions and inline `onclick` handlers. There are about 173 inline handlers.
- Rendering relies heavily on `innerHTML`; about 76 occurrences were found.
- There is no module boundary, no component layer, no formal state management, and no build/deployment separation.

### Supabase/Data Layer

- The app calls Supabase REST directly with the anon key as both `apikey` and `Authorization`.
- There is no Supabase JS client usage, no Supabase Auth session token, and no user-scoped authorization in requests.
- All reads use broad `dbGetAll(...)` calls, usually with `limit=5000`, followed by client-side filtering.
- Table mappings imply the current schema includes: `settings`, `users`, `classes`, `subjects`, `students`, `scores`, `remarks`, `attendance`, `daily_attendance`, `subject_assignments`, `custom_grades`, `transfer_log`, `notices`, `messages`, `audit_log`, `two_factor_tokens`, `class_components`, `score_work_items`, `score_work_scores`, `fees`, `events`, `timetables`, and `awards`.
- No schema files, migrations, RLS policies, indexes, or database documentation are included in the uploaded source.

### Authentication and Security

- The app does not use Supabase Auth. It stores application users and password hashes in a `users` table.
- Password hashing is plain SHA-256 in browser JavaScript with no salt, no server-side verification, and no Supabase Auth protections.
- Password reset codes and 2FA codes are generated client-side. If EmailJS is not configured, reset codes can be displayed in the UI.
- Authorization is mostly UI-level role checks. A user can potentially call underlying REST endpoints directly if RLS is not strict.
- Sensitive integration settings such as SMS API keys and EmailJS configuration are stored/read through browser-accessible settings.
- Several destructive data-management operations are exposed in browser code.
- Many user-provided values are interpolated into HTML. Some fields use `escHtml`, but usage is inconsistent.

### UX/UI

- The current UI has useful patterns: sidebar, topbar, cards, tables, filters, toasts, modals, print views, dark mode, mobile sidebar.
- Icons are emoji-based, not Lucide.
- There is no reusable component system, no standard table/form/modal API, and no centralized empty/loading/error state pattern.
- Accessibility is incomplete: inline click targets, missing semantic buttons/labels in dynamic areas, limited keyboard/focus management, and no dialog focus trapping.
- Some text appears mojibake-corrupted in the extracted file, which indicates encoding problems or prior copy/paste corruption.

### Performance

- Repeated full-table reads and client-side filtering will degrade quickly with real school data.
- Rendering large tables through `innerHTML` and global event handlers increases layout/reflow cost and XSS risk.
- Photos/logos are stored as base64 strings instead of Supabase Storage objects.
- Charts use custom DOM/CSS bars; Chart.js is not integrated even though it is required by the target stack.
- CDN dependencies are loaded globally without version governance beyond URL versions.

### Deployment Readiness

- `vercel.json` has SPA rewrites and basic security headers.
- Missing: package metadata, environment variable workflow, README, install/deployment guide, Supabase migration docs, local development instructions, and production checklist.
- Supabase public config is committed in `config.js`; anon keys can be public, but production should use Vercel environment injection and strict RLS.

## Required Rebuild Direction

The rebuild should preserve the existing feature intent while replacing the foundation with:

- `src/js` ES modules by responsibility.
- Supabase JS client and Supabase Auth.
- Row Level Security backed by roles and ownership rules.
- Reusable services for each domain table.
- Reusable UI components for layout, modals, tables, forms, toasts, pagination, filters, empty/error/loading states.
- Storage-backed profile pictures and school logos.
- Chart.js-backed analytics.
- Lucide icons.
- Environment-based configuration.
- Documentation and deployment artifacts.

## Proposed Target Structure

```text
src/
  index.html
  css/
    base.css
    theme.css
    layout.css
    components.css
    pages.css
  js/
    app.js
    router.js
    config/
      env.js
      constants.js
      roles.js
    lib/
      supabaseClient.js
      validators.js
      sanitizer.js
      errors.js
      dates.js
      export.js
    services/
      auth.service.js
      profile.service.js
      student.service.js
      teacher.service.js
      parent.service.js
      class.service.js
      subject.service.js
      attendance.service.js
      score.service.js
      report.service.js
      fee.service.js
      notification.service.js
      settings.service.js
      audit.service.js
      storage.service.js
    components/
      appShell.js
      sidebar.js
      topbar.js
      breadcrumb.js
      modal.js
      toast.js
      dataTable.js
      formField.js
      confirmDialog.js
      pagination.js
      emptyState.js
      loadingState.js
    pages/
      auth/
      dashboard/
      students/
      teachers/
      parents/
      classes/
      subjects/
      attendance/
      exams/
      results/
      fees/
      reports/
      settings/
      users/
      notifications/
      school-profile/
      academic-year/
      terms/
      departments/
assets/
  images/
docs/
  installation.md
  deployment.md
  database.md
  api.md
  developer-notes.md
supabase/
  migrations/
  policies/
```

## Refactoring Plan

### Phase 2 - Database

1. Obtain or inspect the live Supabase schema.
2. Document existing tables, columns, constraints, relationships, indexes, triggers, storage buckets, and RLS policies.
3. Recommend minimal schema changes only where needed.
4. Define role model and RLS policy matrix for administrator, teacher, accountant, parent, and student.
5. Prepare migration scripts and seed strategy.

### Phase 3 - Authentication and Authorization

1. Replace custom password login with Supabase Auth.
2. Add profile/role table linked to `auth.users`.
3. Implement login, logout, forgot password, reset password, email verification, and session restore.
4. Move password reset and email verification to Supabase-supported flows.
5. Gate routes and services by role, and enforce the same rules through RLS.

### Phase 4 - Core Layout

1. Create app shell, route registry, sidebar, topbar, breadcrumbs, modal, toast, table, form, confirmation dialog, and loading/empty/error components.
2. Establish responsive, accessible, mobile-first CSS.
3. Replace emoji controls with Lucide icons.
4. Implement dark mode as a first-class theme.

### Subsequent Module Phases

Proceed module by module in the requested roadmap. Each module should be migrated from the monolith into services, pages, reusable components, validation, access checks, and tests/review notes before moving on.

## Phase 1 Recommendation

Do not patch the monolith except for emergency fixes. The next approved step should be Phase 2: database/schema review, because the authentication, authorization, service layer, and module migration all depend on the real Supabase schema and RLS posture.

