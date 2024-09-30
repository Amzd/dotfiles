# Pull on new machine with:
```zsh
git clone -b macos --bare https://github.com/Amzd/dotfiles "$HOME/dev/dotfiles"
git --git-dir="$HOME/dev/dotfiles/" --work-tree="$HOME" checkout
```
Install dependencies:
```zsh
# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Restart terminal and run `dot config status.showuntrackedfiles no`
