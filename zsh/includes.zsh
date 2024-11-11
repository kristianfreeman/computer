function g() {
  git add .
  git commit -m "$(date +%Y-%m-%d-%H:%M:%S)"
}

function gp() {
  g && git push
}
