# This file is sourced for ANY invocation of zsh
# unlike .zshrc which is sourced only for interactive terminals.
#
# https://vi.stackexchange.com/a/16200/50380
#
# I want to always expose my custom aliases and functions
# so that I can do `:!<alias>` in NeoVim for example.

# Load all files in .zshrc.d folder
for file in ~/.zshrc.d/*.zsh; do
    source "$file"
done

# Custom functions
fpath=( ~/.zshrc.d/functions "${fpath[@]}" )
autoload -Uz ~/.zshrc.d/functions/*(:t)
fpath=( ~/.zshrc.d/functions/video "${fpath[@]}" )
autoload -Uz ~/.zshrc.d/functions/video/*(:t)

export GIT_EXTERNAL_DIFF="~/.zshrc.d/functions/gitdifftool"
