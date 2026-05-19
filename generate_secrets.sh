OP_CONNECT_TOKEN=$(op read "op://k3s/k3s connect api token/credential")
GITHUB_SECRET_KEY=$(op read "op://k3s/Argocd github key/private key")
echo "token=$OP_CONNECT_TOKEN" > bootstrap/.secrets/secrets.env
echo "url=git@github.com" > bootstrap/.secrets/github_ssh.env
echo "type=git" >> bootstrap/.secrets/github_ssh.env
echo "$GITHUB_SECRET_KEY" > bootstrap/.secrets/sshPrivateKey
