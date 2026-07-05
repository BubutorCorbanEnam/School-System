-- ══════════════════════════════════════════════════════════════
--  BCRYPT PASSWORD MIGRATION — safe to run on live data
--  Run this AFTER your main schema (it only adds functions/grants;
--  it does not touch any existing table structure or data).
-- ══════════════════════════════════════════════════════════════

-- pgcrypto is already enabled by the main schema, but this is safe to repeat.
create extension if not exists "pgcrypto";

-- ── verify_login ─────────────────────────────────────────────
-- Checks a username/password pair server-side. Supports the existing
-- legacy SHA-256 hashes seeded by the original schema AND silently
-- upgrades them to bcrypt on first successful login. Returns the user
-- row (as jsonb, password field stripped) on success, or null on any
-- failure (unknown user, wrong password, etc. — deliberately not
-- distinguished, so failed attempts can't be used to enumerate valid
-- usernames).
create or replace function verify_login(p_username text, p_password text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user   users%rowtype;
  v_match  boolean := false;
begin
  select * into v_user from users where username = p_username limit 1;
  if not found then
    return null;
  end if;

  if left(v_user.password, 4) in ('$2a$', '$2b$', '$2y$') then
    -- Already a bcrypt hash
    v_match := (crypt(p_password, v_user.password) = v_user.password);
  else
    -- Legacy SHA-256 hex hash (or, in principle, old plaintext) — check both
    v_match := (encode(digest(p_password, 'sha256'), 'hex') = v_user.password)
            or (p_password = v_user.password);
    if v_match then
      -- Upgrade silently to bcrypt now that we've verified the password
      update users set password = crypt(p_password, gen_salt('bf'))
      where id = v_user.id;
    end if;
  end if;

  if not v_match then
    return null;
  end if;

  return to_jsonb(v_user) - 'password';
end;
$$;

grant execute on function verify_login(text, text) to anon;

-- ── self_register_user ──────────────────────────────────────
-- Used by the public "Register" form. New accounts always start
-- as 'pending' regardless of what the caller passes in, requiring
-- admin approval before login.
create or replace function self_register_user(
  p_name text, p_username text, p_email text, p_password text,
  p_role text, p_student_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if exists (select 1 from users where username = p_username) then
    raise exception 'Username already taken';
  end if;
  if exists (select 1 from users where lower(email) = lower(p_email)) then
    raise exception 'Email already registered';
  end if;

  insert into users (username, password, name, email, role, status, student_id, created_at)
  values (p_username, crypt(p_password, gen_salt('bf')), p_name, p_email, p_role, 'pending', p_student_id, now())
  returning id into v_id;

  return jsonb_build_object('id', v_id);
end;
$$;

grant execute on function self_register_user(text, text, text, text, text, text) to anon;

-- ── admin_create_user ───────────────────────────────────────
-- Used by the admin "Create User" panel. Accounts are created
-- 'active' immediately (admin is trusted to vet the person).
create or replace function admin_create_user(
  p_name text, p_username text, p_email text, p_password text, p_role text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if exists (select 1 from users where username = p_username) then
    raise exception 'Username already taken';
  end if;

  insert into users (username, password, name, email, role, status, created_at)
  values (p_username, crypt(p_password, gen_salt('bf')), p_name, p_email, p_role, 'active', now())
  returning id into v_id;

  return jsonb_build_object('id', v_id);
end;
$$;

grant execute on function admin_create_user(text, text, text, text, text) to anon;

-- ── change_own_password ─────────────────────────────────────
-- Used by the logged-in user's "Change Password" form. Verifies the
-- current password (bcrypt or legacy SHA-256) before updating.
-- Returns true on success, false if the current password was wrong.
create or replace function change_own_password(
  p_user_id bigint, p_old_password text, p_new_password text
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pw    text;
  v_match boolean;
begin
  select password into v_pw from users where id = p_user_id;
  if v_pw is null then
    return false;
  end if;

  if left(v_pw, 4) in ('$2a$', '$2b$', '$2y$') then
    v_match := (crypt(p_old_password, v_pw) = v_pw);
  else
    v_match := (encode(digest(p_old_password, 'sha256'), 'hex') = v_pw) or (p_old_password = v_pw);
  end if;

  if not v_match then
    return false;
  end if;

  update users set password = crypt(p_new_password, gen_salt('bf')) where id = p_user_id;
  return true;
end;
$$;

grant execute on function change_own_password(bigint, text, text) to anon;

-- ── reset_user_password ─────────────────────────────────────
-- Used by the "Forgot Password" flow, AFTER the emailed 6-digit code
-- has already been verified client-side. No old password is needed
-- since code verification is what authorizes the reset.
create or replace function reset_user_password(p_user_id bigint, p_new_password text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update users set password = crypt(p_new_password, gen_salt('bf')) where id = p_user_id;
end;
$$;

grant execute on function reset_user_password(bigint, text) to anon;
