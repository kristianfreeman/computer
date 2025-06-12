function g() {
  git add .
  git commit -m "$(date +%Y-%m-%d-%H:%M:%S)"
}

function gp() {
  g && git push
}

function za() {
  local session_name=${1:-${PWD:t}}
  zellij attach "$session_name" || zellij -s "$session_name"
}

function pcat() {
  cat "$1" | pbcopy
}

# Batocera functions
BATOCERA_SSH_COMMAND="ssh root@batocera.local"
function batocera-reboot() {
  ssh root@batocera.local "batocera-es-swissknife --reboot"
}

export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

export PATH="$HOME/.npm-packages/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

export NODE_EXTRA_CA_CERTS="$HOME/Library/Application Support/Caddy/certificates/local/localhost/localhost.crt"
