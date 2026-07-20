# 📱 Phone Account Tracker

A single-file web app for tracking phone-number accounts. For every phone number you add, it
**auto-creates a disposable email inbox via [mail.tm](https://mail.tm)** (address + password),
stores everything in **Supabase**, and shows a grid where you tick off what each number has
been used for.

## How to use

1. Copy `config.example.js` to `config.js` (same folder) and fill in the Supabase URL +
   publishable key. (`config.js` is gitignored so the key never lands in a public repo.)
2. Open `index.html` in a browser — no build step, no server needed.
   (Everything is plain HTML/JS talking directly to the Supabase REST API and mail.tm API.)

- **＋ Add Account** — enter a phone number (that's the account's name). A mail.tm email
  address is created automatically and saved next to it, along with a generated password
  (or type your own).
- **＋ Field** — add a custom column (e.g. `Google`, `Facebook`, `Verified`). Each account
  gets a checkbox under every column so you can track what the number has been used for.
  Click a column header to rename it, `✕` to delete it.
- **📬** — opens that account's live mail.tm inbox right in the page (great for grabbing
  verification codes/links during sign-up testing).
- **⧉** — copy email / password to clipboard. Click the dots to reveal a password.
- **Notes** — free-text per account, saved on change.

## mail.tm — do I need an API key?

**No.** mail.tm's API is free and open — no key, no signup. Accounts are created with a
plain `POST https://api.mail.tm/domains` → `POST /accounts` call, and inboxes are read with
a JWT from `POST /token`. The app does all of this for you. (Rate limit: 8 requests/sec.)

## Backend (Supabase)

Project: `phone-account-tracker` (`lpnvlofzqzfqeaumcxxz`, ap-southeast-2).
Schema lives in [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql):

| table      | purpose                                              |
|------------|------------------------------------------------------|
| `accounts` | one row per phone number + its mail.tm email/password |
| `fields`   | your custom column headers                           |
| `checks`   | one checkbox state per (account × field)             |

The app connects with the project's **publishable key** (safe to embed client-side).
RLS is enabled with permissive policies for the anon role.

## ⚠️ Security notes

- Anyone who has your `config.js` (URL + publishable key) can read/write the tracker data,
  because RLS is intentionally open for the anon role. Keep `config.js` out of public repos
  (it's gitignored here). If you ever need real protection, add Supabase Auth and switch the
  RLS policies from `anon` to `authenticated`.
- This app was meant to live in its own **private** GitHub repo, but the Claude GitHub
  integration is currently scoped to `workepier-ai/HTML-TESTER` only and isn't allowed to
  create repositories. To move it: create a private repo at github.com/new, copy this folder
  in (including your local `config.js`, which git will ignore), and optionally grant the
  Claude GitHub App access to it for future sessions.
- mail.tm inboxes are **disposable/public-grade email** — never use them for anything you
  care about. Inboxes and messages are auto-deleted by mail.tm after a period of inactivity.
- Email passwords are stored in plain text on purpose (the app needs them to log into
  mail.tm to show the inbox). They are throwaway credentials, not real secrets.

## Next steps (planned)

- Sign-up automation against your own test sites: pick an account → auto-fill forms with
  its phone/email → poll the inbox for the verification code → tick the field checkbox.
