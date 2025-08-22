#!/bin/bash

# Define key names and GitHub aliases
KEY_NAMES=("ntflabsdev" "webexpert" "personal")
HOST_ALIASES=("github-ntflabs" "github-webexpert" "github-personal")

# Ask for emails
read -p "Enter GitHub email for ntflabsdev: " EMAIL1
read -p "Enter GitHub email for webexpert: " EMAIL2
read -p "Enter GitHub email for personal: " EMAIL3
EMAILS=("$EMAIL1" "$EMAIL2" "$EMAIL3")

# Create .ssh folder if missing
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Backup SSH config if it exists
CONFIG_FILE=~/.ssh/config
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak_$(date +%s)"
fi

# Generate RSA SSH keys and add to config
for i in {0..2}; do
    KEY_PATH="$HOME/.ssh/${KEY_NAMES[$i]}"
    echo "🔑 Generating RSA SSH key for ${KEY_NAMES[$i]}..."

    ssh-keygen -t rsa -b 4096 -C "${EMAILS[$i]}" -f "$KEY_PATH" -N ""

    echo "⚙️  Adding SSH config for ${HOST_ALIASES[$i]}..."

    cat <<EOF >> "$CONFIG_FILE"

# GitHub Account for ${KEY_NAMES[$i]}
Host ${HOST_ALIASES[$i]}
    HostName github.com
    User git
    IdentityFile $KEY_PATH
    IdentitiesOnly yes
EOF

done

chmod 600 "$CONFIG_FILE"

# Start SSH agent and add keys
eval "$(ssh-agent -s)"
for i in {0..2}; do
    ssh-add "$HOME/.ssh/${KEY_NAMES[$i]}"
done

# Output public keys
echo ""
echo "✅ All keys created and SSH config updated!"
echo "📎 Copy the following public keys and add them to the corresponding GitHub accounts:"
for i in {0..2}; do
    echo ""
    echo "🔐 ${KEY_NAMES[$i]} (${EMAILS[$i]}):"
    cat "$HOME/.ssh/${KEY_NAMES[$i]}.pub"
done

echo ""
echo "👉 When cloning GitHub repos, use the alias:"
echo "   git@github-ntflabs:username/repo.git"
echo "   git@github-webexpert:username/repo.git"
echo "   git@github-personal:username/repo.git"
echo ""

