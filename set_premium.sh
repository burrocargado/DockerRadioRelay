#!/bin/bash

function AddRadikoPremium() {
cat <<EOF
RADIKO_MAIL="$1"
RADIKO_PASS="$2"
EOF
}

read -p "Input e-mail for premium or blank to remove premium: " RADIKO_MAIL
if [ -n "$RADIKO_MAIL" ]; then
    read -sp "Password: " RADIKO_PASS
    echo
fi

sed -i -e '/^RADIKO_MAIL/d;/^RADIKO_PASS/d' data/local_settings.py

if [ -n "$RADIKO_MAIL" ] && [ -n "$RADIKO_PASS" ]; then
    AddRadikoPremium $RADIKO_MAIL $RADIKO_PASS >> data/local_settings.py
fi

