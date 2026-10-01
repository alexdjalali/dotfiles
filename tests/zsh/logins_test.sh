#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# shellcheck disable=SC2016  # zsh code is passed to zsh_with unexpanded on purpose
# Tests for the per-identity sign-in helpers in zsh/conf.d/11-logins.zsh and the
# Chrome-profile launcher in zsh/libexec/vv-browser/open.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"
# shellcheck source=../lib/zsh.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/zsh.sh"

VV_OPEN="$REPO_ROOT/zsh/libexec/vv-browser/open"

# env_mock NAME puts a PATH shim for NAME in front of PATH that records, per
# call, its argv, $BROWSER, which `open` the PATH resolves to (the two ways the
# AWS and Auth0 CLIs pick the browser they launch), and the VV_CHROME_PROFILE
# the launcher would see.
env_mock() {
  cat > "$MOCK_BIN/$1" <<EOF
#!/usr/bin/env bash
printf '%s|BROWSER=%s|open=%s|chrome=%s\n' "\$*" "\${BROWSER-}" "\$(command -v open)" "\${VV_CHROME_PROFILE-}" >> "$MOCK_DIR/$1.calls"
EOF
  chmod +x "$MOCK_BIN/$1"
}

# Why this test is important:
#   - The vv Identity Center sign-in must land in its dedicated Chrome profile,
#     not the default browser's other identity.
# What it tests:
#   - aws-login-vv runs `aws sso login` for VV_SSO_SESSION with BROWSER set to
#     the Chrome launcher.
test_aws_login_vv_opens_dedicated_chrome_profile() {
  env_mock aws
  zsh_with 'unset BROWSER VV_CHROME_PROFILE; VV_SSO_SESSION=vv-sso aws-login-vv' 11-logins.zsh >/dev/null 2>&1
  assert_eq "sso login --sso-session vv-sso|BROWSER=$VV_OPEN|open=/usr/bin/open|chrome=" \
    "$(mock_calls aws)" "aws call"
}

# Why this test is important:
#   - gt signs in from the default browser; routing it to the vv profile would
#     mix the two identities.
# What it tests:
#   - aws-login-gt runs `aws login` for GT_AWS_PROFILE with no browser override.
test_aws_login_gt_uses_default_browser() {
  env_mock aws
  zsh_with 'unset BROWSER VV_CHROME_PROFILE; GT_AWS_PROFILE=gt-prof aws-login-gt' 11-logins.zsh >/dev/null 2>&1
  assert_eq "login --profile gt-prof|BROWSER=|open=/usr/bin/open|chrome=" \
    "$(mock_calls aws)" "aws call"
}

# Why this test is important:
#   - The Auth0 CLI opens its device-login page with `open`, so the vv sign-in
#     only reaches its Chrome profile — the Auth0 admin's, not the AWS one —
#     through the PATH launcher.
# What it tests:
#   - auth0-login-vv runs `auth0 login` with the launcher first on PATH and
#     VV_AUTH0_CHROME_PROFILE as the launcher's profile (overriding
#     VV_CHROME_PROFILE), then makes VV_AUTH0_TENANT the default without it.
test_auth0_login_vv_opens_dedicated_chrome_profile() {
  env_mock auth0
  zsh_with 'unset BROWSER VV_CHROME_PROFILE; VV_CHROME_PROFILE="Profile 1"; VV_AUTH0_TENANT=vv.example.auth0.com VV_AUTH0_CHROME_PROFILE="Profile 9" auth0-login-vv' 11-logins.zsh >/dev/null 2>&1
  assert_eq "login|BROWSER=|open=$VV_OPEN|chrome=Profile 9
tenants use vv.example.auth0.com|BROWSER=|open=/usr/bin/open|chrome=" \
    "$(mock_calls auth0)" "auth0 calls"
}

# Why this test is important:
#   - gt's Auth0 tenants are signed into from the default browser.
# What it tests:
#   - auth0-login-gt runs `auth0 login` with the system `open` and no override.
test_auth0_login_gt_uses_default_browser() {
  env_mock auth0
  zsh_with 'unset BROWSER VV_CHROME_PROFILE; auth0-login-gt' 11-logins.zsh >/dev/null 2>&1
  assert_eq "login|BROWSER=|open=/usr/bin/open|chrome=" "$(mock_calls auth0)" "auth0 call"
}

# Why this test is important:
#   - The account/tenant names live only in the untracked ~/.zshrc.local; with
#     one missing, a helper must stop instead of signing in to the wrong place.
# What it tests:
#   - Each name-dependent helper exits non-zero, names every unset variable,
#     and never runs the CLI.
test_logins_refuse_unset_names() {
  env_mock aws
  env_mock auth0
  local err
  err=$(zsh_with 'unset VV_SSO_SESSION GT_AWS_PROFILE VV_AUTH0_TENANT VV_AUTH0_CHROME_PROFILE
    aws-login-vv; print rc=$?; aws-login-gt; print rc=$?; auth0-login-vv; print rc=$?' 11-logins.zsh 2>&1)
  assert_contains "$err" "VV_SSO_SESSION is not set" "aws-login-vv"
  assert_contains "$err" "GT_AWS_PROFILE is not set" "aws-login-gt"
  assert_contains "$err" "VV_AUTH0_TENANT is not set" "auth0-login-vv"
  assert_contains "$err" "VV_AUTH0_CHROME_PROFILE is not set" "auth0-login-vv profile"
  assert_not_contains "$err" "rc=0" "exit codes"
  assert_eq "" "$(mock_calls aws)$(mock_calls auth0)" "CLI calls"
}

# Why this test is important:
#   - The launcher is what actually picks the Chrome profile; a wrong flag opens
#     the URL in whichever profile Chrome last used.
# What it tests:
#   - The launcher opens the URL in Google Chrome with --profile-directory set to
#     VV_CHROME_PROFILE, defaulting to "Profile 1".
test_vv_browser_opens_url_in_chrome_profile() {
  mock_cmd sysopen
  VV_OPEN_BIN="$MOCK_BIN/sysopen" "$VV_OPEN" https://example.com/a </dev/null
  VV_OPEN_BIN="$MOCK_BIN/sysopen" VV_CHROME_PROFILE="Profile 2" "$VV_OPEN" https://example.com/b </dev/null
  assert_eq "-na Google Chrome --args --profile-directory=Profile 1 https://example.com/a
-na Google Chrome --args --profile-directory=Profile 2 https://example.com/b" \
    "$(mock_calls sysopen)" "open calls"
}

run_test test_aws_login_vv_opens_dedicated_chrome_profile
run_test test_aws_login_gt_uses_default_browser
run_test test_auth0_login_vv_opens_dedicated_chrome_profile
run_test test_auth0_login_gt_uses_default_browser
run_test test_logins_refuse_unset_names
run_test test_vv_browser_opens_url_in_chrome_profile
finish
