/// OAuth/password recovery redirects must exactly match [`supabase/config.toml`].
const autolifeOAuthRedirect = String.fromEnvironment(
  'AUTOLIFE_OAUTH_REDIRECT',
  defaultValue: 'autolife://login-callback',
);
