# always use neovim
alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"

alias nvimconf="nvim --cmd 'cd ~/.config/nvim'"
alias zshconf="nvim ~/.zshrc ~/.zshenv -O2 --cmd 'cd ~/.zshrc.d'"
alias omz="nvim ~/.oh-my-zsh --cmd 'cd ~'"

alias scripts="cd ~/dev/scripts;nvim"

alias dot="dotfiles"
alias dotfiles="git --git-dir=$HOME/dev/dotfiles --work-tree=$HOME"
alias dotopen='open $(dot remote -v | grep -o "https[^ ]*" | uniq)'
alias gitopen='open $(git remote -v | grep -o "https[^ ]*" | uniq)'

alias ollama="~/dev/ollama/ollama"
# serve fails gracefully if already running
alias ai="(ollama serve > /dev/null 2>&1 &); ollama run codellama:13b"

alias fcd='cd "$(find -type d | fzf)"'
alias lsn="ls -lGq"
alias lst="ls -lGqt"
alias lss="ls -lGqS"
