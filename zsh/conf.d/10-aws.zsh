# AWS — Shibboleth federation helpers
# `aws login` + login_session handles CLI auth natively.
# Terraform's Go SDK can't read login_session, so we also export raw
# credentials from the login cache for Terraform/Terragrunt to use.

aws-export() {
  # Ensure we have a valid session (opens browser if needed)
  if ! aws sts get-caller-identity &>/dev/null; then
    aws login || return 1
  fi

  # Export raw credentials from the login cache (Terraform needs these)
  local cache_file
  cache_file=$(command ls -t "$HOME/.aws/login/cache"/*.json 2>/dev/null | head -1)
  [[ -z "$cache_file" ]] && { echo "ERROR: No login cache file found."; return 1; }

  eval "$(python3 - "$cache_file" <<'PYEOF'
import json, sys
with open(sys.argv[1]) as f:
    t = json.load(f)["accessToken"]
print(f'export AWS_ACCESS_KEY_ID="{t["accessKeyId"]}"')
print(f'export AWS_SECRET_ACCESS_KEY="{t["secretAccessKey"]}"')
print(f'export AWS_SESSION_TOKEN="{t["sessionToken"]}"')
print(f'export AWS_ACCOUNT_ID="{t["accountId"]}"')
PYEOF
)"

  export TF_VAR_account_id="$AWS_ACCOUNT_ID"
  export TF_VAR_aws_region="${AWS_REGION:-us-east-1}"

  echo "AWS credentials ready for account $AWS_ACCOUNT_ID"
  echo "  TF_VAR_account_id=$TF_VAR_account_id"
  echo "  TF_VAR_aws_region=$TF_VAR_aws_region"
}

aws-export-tf() {
  source "$HOME/.aws/terraform-creds.sh" "$@" || return 1
}

aws-unexport() {
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
  unset AWS_ACCOUNT_ID TF_VAR_account_id TF_VAR_aws_region
  echo "AWS credential env vars cleared."
}
