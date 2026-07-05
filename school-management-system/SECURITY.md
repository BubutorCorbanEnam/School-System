# Security Notes

This package preserves the currently uploaded working application so it can be deployed and used.

Before storing sensitive student, parent, fee, or staff data in production, complete these hardening tasks:

1. Replace the custom `users` password flow with Supabase Auth.
2. Link app profiles to `auth.users`.
3. Enable and verify Row Level Security on every table.
4. Restrict table access by role: administrator, teacher, accountant, parent, and student.
5. Move profile pictures and school logos to Supabase Storage.
6. Do not store SMS provider secrets in browser-readable settings.
7. Review all dynamic HTML rendering for XSS exposure.
8. Add database constraints, indexes, and audit protection.

The Supabase anon key is allowed to be public, but it is only safe when RLS policies are correct.

