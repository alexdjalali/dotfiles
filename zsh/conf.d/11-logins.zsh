# Sign-in helpers, one per identity. "work" opens in a dedicated Chrome profile
# (zsh/libexec/work-browser/open); "gt" uses the default browser. Each AWS session
# is cached on its own, so both stay signed in at once.
#
# The names they sign in to are machine-only and live in the untracked
# ~/.zshrc.local, never in this public repo:
#   WORK_SSO_SESSION    the [sso-session] name in ~/.aws/config
#   WORK_AUTH0_TENANT   the Auth0 tenant domain to make the default
#   GT_AWS_PROFILE      the `aws login` profile in ~/.aws/config
#   WORK_CHROME_PROFILE the Chrome profile directory for AWS (default "Profile 1")
#   WORK_AUTH0_CHROME_PROFILE the Chrome profile directory for Auth0

_work_browser_dir="$DOTFILES/zsh/libexec/work-browser"

# _login_need fails with a pointer to ~/.zshrc.local for every unset name.
_login_need() {
  local v rc=0
  for v in "$@"; do
    [[ -n ${(P)v-} ]] || { print -u2 "$v is not set — add it to ~/.zshrc.local"; rc=1; }
  done
  return $rc
}

# aws-login-work signs in to the WORK_SSO_SESSION Identity Center session.
aws-login-work() {
  _login_need WORK_SSO_SESSION || return 1
  BROWSER="$_work_browser_dir/open" aws sso login --sso-session "$WORK_SSO_SESSION" "$@"
}

# aws-login-gt signs in the GT_AWS_PROFILE `aws login` session.
aws-login-gt() {
  _login_need GT_AWS_PROFILE || return 1
  aws login --profile "$GT_AWS_PROFILE" "$@"
}

# auth0-login-work signs the Auth0 CLI in from the WORK_AUTH0_CHROME_PROFILE Chrome
# profile (the Auth0 admin identity, separate from the AWS one) and makes
# WORK_AUTH0_TENANT the default tenant.
auth0-login-work() {
  _login_need WORK_AUTH0_TENANT WORK_AUTH0_CHROME_PROFILE || return 1
  WORK_CHROME_PROFILE="$WORK_AUTH0_CHROME_PROFILE" PATH="$_work_browser_dir:$PATH" auth0 login "$@" &&
    auth0 tenants use "$WORK_AUTH0_TENANT"
}

# auth0-login-gt signs the Auth0 CLI in from the default browser (the tenant is
# picked on the login page).
auth0-login-gt() { auth0 login "$@"; }
