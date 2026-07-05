# Developer Notes

The uploaded app is currently a monolithic single-page application.

Recommended future refactor:

```text
src/
  css/
  js/
    components/
    pages/
    services/
    config/
    utilities/
  assets/
supabase/
  migrations/
  policies/
docs/
```

Priority order:

1. Database/RLS review.
2. Supabase Auth migration.
3. App shell and reusable components.
4. Dashboard.
5. Student management.
6. Remaining modules.

Do not introduce multi-school architecture yet. Keep the code single-school friendly, but avoid decisions that would make future expansion impossible.

