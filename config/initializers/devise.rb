Devise.setup do |config|
  config.mailer_sender = "no-reply@codeblue7.local"
  require "devise/orm/active_record"

  config.authentication_keys = [ :email ]
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]
  config.stretches = Rails.env.test? ? 1 : 12
  config.sign_out_via = :delete
end
