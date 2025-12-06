# Announcement / Survey Admin Rules

Use this prompt as the single source of truth for creating announcements, surveys, quizzes, and data collection items in the admin dashboard. Keep the mobile sync service unaffected by following the guardrails below.

## Principles
- Never expose or embed the Supabase service role key in the client; only the anon key is used in the browser.
- All announcements must respect start/end windows and audience filters before being sent to the mobile app.
- Limit user fatigue: set `max_impressions` and use the carousel + notification center sparingly.
- Surveys and quizzes share the same delivery system as announcements but render as a form modal when opened.

## Announcement Fields
- `title`, `body`, `kind` (`announcement` or `survey`), `priority` (`low`, `normal`, `high`)
- `audience`: `all`, `doctors`, `residents`, or `students`
- `start_at` / `end_at`: ISO timestamps that control visibility
- `show_in_carousel` and `show_in_notifications`: booleans for placement
- `max_impressions`: how many times a user sees the item before it hides

## Survey / Quiz Fields
- `questions`: array of items with `prompt`, `type` (`yes_no`, `single_choice`, `multi_choice`, `text`, `number`), `required`, and optional `options`
- Each response is stored in `announcement_responses` keyed by `announcement_id`, `user_id`, and `question_id`
- Results aggregate on the server into `responses` so charts remain fast

## Delivery Rules (enforce with RLS)
- Only admins in `admin_users` with `is_active = true` can insert/update/delete announcements.
- Readers must satisfy: `start_at <= now() <= end_at` AND (`audience = 'all'` OR matches their profile) AND (impression count < `max_impressions` OR `max_impressions` IS NULL).
- Surveys require authentication; anonymous users can only see public announcements with no form payload.

## UX Notes
- Use short titles (<= 60 chars) and concise bodies (<= 280 chars) to avoid truncation.
- Prefer one survey at a time; stagger high-priority items.
- Always provide a closing date for surveys to avoid stale forms in the carousel.

## QA Checklist Before Publishing
- [ ] Start/end time valid and in UTC
- [ ] Audience and placement verified
- [ ] max_impressions set to prevent notification fatigue
- [ ] Questions validated (options filled in for choice questions)
- [ ] Admin user confirmed in `admin_users` and RLS policies enabled
