theme_gruvbox dark hard
alias ls=exa
alias grep=rg
alias vi=nvim
alias vim=nvim

if status --is-interactive
  if ! set -q TMUX
  	exec tmux
  end
end

