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
