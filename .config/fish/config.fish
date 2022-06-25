alias ls=exa
alias grep=rg
alias vi=nvim
alias vim=nvim
alias cat=bat
alias docker=podman

if status --is-interactive
  theme_gruvbox dark hard
  if ! set -q TMUX
  	exec tmux -u
  end
end

