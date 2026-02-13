#!/bin/bash
# Authorize Georgia Tech Office 365 account with OAuth2
#
# Override defaults via environment variables:
#   GT_EMAIL       - your GT email (default: read from prompt)
#   GT_CLIENT_ID   - Azure AD client ID

GT_EMAIL="${GT_EMAIL:-}"
GT_CLIENT_ID="${GT_CLIENT_ID:-08162f7c-0fd2-4200-a84a-f25a4db0b584}"
TOKEN_FILE="$HOME/.neomutt/gatech.tokens"

echo "==================================="
echo "GT Office 365 OAuth2 Authorization"
echo "==================================="
echo ""

if [ -z "$GT_EMAIL" ]; then
  read -p "Enter your GT email (e.g., user@gatech.edu): " GT_EMAIL
  if [ -z "$GT_EMAIL" ]; then
    echo "Error: GT email is required."
    exit 1
  fi
fi

echo "Email:     $GT_EMAIL"
echo "Client ID: $GT_CLIENT_ID"
echo "Tokens:    $TOKEN_FILE"
echo ""
echo "This will open your browser to authorize neomutt to access your GT email."
echo ""
echo "Steps:"
echo "1. Browser will open to Microsoft login"
echo "2. Sign in with your GT credentials ($GT_EMAIL)"
echo "3. Use your authenticator app/hardware token for 2FA"
echo "4. Approve the access request"
echo "5. Browser will redirect to localhost (this is normal!)"
echo "6. Authorization tokens will be saved"
echo ""
read -p "Press Enter to continue..."

# Run OAuth2 authorization using Microsoft provider with localhost flow
python3 ~/.neomutt/mutt_oauth2.py \
  --verbose \
  --authorize \
  --authflow localhostauthcode \
  --provider microsoft \
  --email "$GT_EMAIL" \
  --client-id "$GT_CLIENT_ID" \
  "$TOKEN_FILE"

if [ $? -eq 0 ]; then
  echo ""
  echo "Authorization successful!"
  echo ""
  echo "You can now use neomutt with your GT account."
  echo "Launch neomutt and press F3 or ,t to switch to GT account."
else
  echo ""
  echo "Authorization failed."
  echo ""
  echo "Common issues:"
  echo "- Make sure port 8080 is not in use"
  echo "- Check that your browser can access localhost"
  echo "- Verify you completed the login and approval"
  echo ""
  echo "If problems persist, contact GT OIT for help with IMAP access."
fi
