# Codeblue Community

A Rails community app for member profiles, incident reports with optional photos, report comments, private one-to-one messages, and a searchable public-official directory with member ratings.

## Requirements and setup

- Ruby 4.0.6 (see `.ruby-version`)
- SQLite

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

Open `http://localhost:3000`, create an account, and use the incident board or member profiles.

## Accounts and roles

New registrations are regular members. Administrators can manage roles at `/admin/users`; members cannot grant themselves admin privileges. Bootstrap the first administrator from the Rails console after registering that account:

```ruby
User.find_by!(email: "admin@example.com").update!(role: :admin)
```

Thereafter, admins can change other accounts' roles in the admin area. An administrator cannot remove their own admin role through that screen.

## Community features

- Signed-in members can publish reports with a title, description, location, occurrence time, and one optional image (image content type, max 10 MB).
- Incident reports can optionally be linked to an official directory entry; the incident board can be filtered by official and sorted by official name, report title, or recency.
- Authors and admins can edit or remove reports; other signed-in members can read and comment.
- Member profiles include display names and bios. Members can edit their own profiles; admins can edit other profiles.
- Private chats are one-to-one, and only the two participants can read or send messages.
- Signed-in members can add and search directory entries for police officers, district attorneys, and judges. Filter and sort entries by role-specific fields such as district, badge number, precinct, case number, history, decisions, city, and state.
- Signed-in members can submit one rating per directory entry for professionalism and overall experience (both from 1–10), update or remove their rating, and see community averages. Entries and ratings are community-submitted; check primary sources and do not treat them as verified findings.
- `bin/rails db:seed` adds 5 explicitly fictional sample records for each official category, all listed in New York City. These demo entries are for development/testing and do not represent real people or events.
- Uploaded images use Rails Active Storage's local disk service by default. Configure a durable object-storage service before deploying to production.

## Tests

```sh
bin/rails test
bin/rubocop app/controllers app/models test/controllers/community_features_test.rb
```

## Deployment notes

Set an application-specific `config.action_mailer.default_url_options` and a real `Devise.mailer_sender`/mail delivery service for password recovery. Configure persistent Active Storage storage, HTTPS, and production secrets before deployment. Keep the admin role limited to trusted accounts.
