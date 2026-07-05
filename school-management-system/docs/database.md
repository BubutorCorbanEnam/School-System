# Database Notes

The current application expects an existing Supabase/PostgreSQL schema.

Tables referenced by the app:

- `settings`
- `users`
- `classes`
- `subjects`
- `students`
- `scores`
- `remarks`
- `attendance`
- `daily_attendance`
- `subject_assignments`
- `custom_grades`
- `transfer_log`
- `notices`
- `messages`
- `audit_log`
- `two_factor_tokens`
- `class_components`
- `score_work_items`
- `score_work_scores`
- `fees`
- `events`
- `timetables`
- `awards`

Recommended production improvements:

- Add foreign keys between students, classes, subjects, users, fees, attendance, scores, and messages.
- Add indexes for common filters such as `student_id`, `class_id`, `subject_id`, `term`, `academic_year`, `role`, and `status`.
- Enable Row Level Security on all tables.
- Keep destructive audit log actions administrator-only.
- Move file-like data such as photos and logos to Supabase Storage.

