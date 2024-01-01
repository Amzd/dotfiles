# ~/.config/fish/config.fish

# always use neovim
alias vim="nvim"
alias vi="nvim"
alias vimconf="cd ~/.config/nvim;nvim ."
alias scripts="cd ~/dev/scripts;nvim ."

alias dotfiles="git --git-dir=$HOME/dev/dotfiles --work-tree=$HOME"

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function killea
  ps aux | grep -E "EA Desktop" | grep -v grep | awk '{print $2}' | xargs kill
end

function killuplay
  ps aux | grep -E "uplay" | grep -v grep | awk '{print $2}' | xargs kill
end

alias killollama="service ollama stop"

function swiftenv
  set selected $(find /usr/libexec/swift -type d -regex '/usr/libexec/swift/[^/]+' | sed 's/.usr.libexec.swift.//' | fzf); or return

  echo "Need sudo for access to /usr/bin"
  sudo echo "Access granted"; or return

  echo Linking /usr/libexec/swift/$selected/bin/swift to /usr/bin/swift
  sudo rm /usr/bin/swift
  sudo ln -s "/usr/libexec/swift/$selected/bin/swift" "/usr/bin/swift"

  echo Linking /usr/libexec/swift/$selected/bin/swiftc to /usr/bin/swiftc
  sudo rm /usr/bin/swiftc
  sudo ln -s "/usr/libexec/swift/$selected/bin/swiftc" "/usr/bin/swiftc"

  echo Linking /usr/libexec/swift/$selected/bin/sourcekit-lsp to /usr/bin/sourcekit-lsp
  sudo rm /usr/bin/sourcekit-lsp
  sudo ln -s "/usr/libexec/swift/$selected/bin/sourcekit-lsp" "/usr/bin/sourcekit-lsp"

  echo Linking /usr/libexec/swift/$selected to /usr/libexec/swift/usr for VSCode
  sudo rm /usr/libexec/swift/usr
  sudo ln -s "/usr/libexec/swift/$selected" "/usr/libexec/swift/usr"

  echo Done
end

# MARK: - Files

alias fcd='cd "$(find -type d | fzf)"'
alias lsn="ls -lGq"
alias lst="ls -lGqt"
alias lss="ls -lGqS"

function open
  if test -z $argv
    set file $(find -type f | fzf); or return
    xdg-open $file
  else
    xdg-open $argv
  end
end

function copy
  set file $(find -type f | fzf | sed 's/..//' | sed 's/ /\\\\ /g'); _pipesuccess; or return
  echo $file | tr -d '\n' | xclip -selection c
  echo -e "Copied \033[1m'$file'\033[0m to clipboard"
end

function copycdn -d "Copy the CDN url for a file. Must be in the amzd folder on the ftp server."
  set url $(find -type f | fzf | sed 's/./https:\/\/cdn\.amzd\.me/' | sed 's/ /%20/g'); _pipesuccess; or return
  echo $url | tr -d '\n' | xclip -selection c
  echo -e "Copied \033[1m'$url'\033[0m to clipboard"
end


# MARK: - Passwords

function aaa
  echo $argv[1]
  if not set test (printf $argv[1])
    set test $(read -P 'test: '); or return
  end
  echo $test
  echo $status
end

function pwget
  if not set username (printf $argv[1])
    set username $(read -P 'username: '); or return
  end
  if not set domain (printf $argv[2])
    set domain $(read -P 'domain: '); or return
  end

  # https://jdhao.github.io/2021/02/01/bracketed_paste_mode/
  # secret-tool sends bracketed paste mode codes so we remove them with sed
  set pw $(secret-tool lookup "username" "$username" "domain" "$domain" | sed "s/\x1B\[200\~//g" | sed "s/\x1B\[201\~//g")
  echo $pw | xclip -selection c
end

function pwset
  set label $(read -P 'label: '); or return
  set username $(read -P 'username: '); or return
  set domain $(read -P 'domain: '); or return

  secret-tool store --label="$label" "username" "$username" "domain" "$domain"
end

function pwrm
  set username $(read -P 'username: '); or return
  set domain $(read -P 'domain: '); or return

  secret-tool lookup "username" "$username" "domain" "$domain"

  if test $(_readyesno 'Do you want to remove this password? (y/N)' N) = yes
    secret-tool clear "username" "$username" "domain" "$domain"
  end
end

function cdn
  set -gx SSHPASS $(pwget amzd storage.bunnycdn.com); _pipesuccess; or return
  sshpass -e sftp amzd@storage.bunnycdn.com
  set -gx SSHPASS ""
end

function cdnmount
  pwget amzd storage.bunnycdn.com | sshfs -o password_stdin amzd@storage.bunnycdn.com:/ /media/cdn
end

function iphone
  set -gx SSHPASS $(pwget root@Caspers-iPhone-X ssh.com); _pipesuccess; or return
  sshpass -e sftp root@Caspers-iPhone-X
  set -gx SSHPASS ""
end

function iphonemount
  # for some reason piping the password doesnt work for my iphone
  # secret-tool lookup username root@Caspers-iPhone-X domain ssh.com |
  sshfs root@Caspers-iPhone-X:/ /media/iphone
end

function iphonepaste
  ssh mobile@Caspers-iPhone-X "clipme '$(wl-paste)'"
end

# MARK: - Video

function trim
  if not set input (printf $argv[1])
    set input $(find -type f \( -name "*.mp4" -o -name "*.mkv" \) | fzf | sed 's/..//'); _pipesuccess; or return
  end
  echo Trimming $input
  set start $(_readwithdefault 'Start time in mm:ss or seconds (00:00)' 00:00); or return
  set duration $(_readwithdefault 'Duration in seconds (10)' 10); or return
  set defaultoutput $(echo $input | sed -E 's/(.*)\./\1_trim\./')
  set output $(_readwithdefault 'New file name ('$defaultoutput')' $defaultoutput); or return

  ffmpeg -i $input -ss $start -t $duration -c:v copy -c:a copy $output
end

function lowerql
  if not set input (printf $argv[1])
    set input $(find -type f \( -name "*.mp4" -o -name "*.mkv" \) | fzf | sed 's/..//'); _pipesuccess; or return
  end
  echo "Lowering quality of $input"
  echo "Constant rate factor (CRF)"
  echo "23 is DVD quality, lower number is higher quality"
  set crf $(_readwithdefault "CRF (23)" 23); or return
  set defaultoutput $(echo $input | sed -E 's/(.*)\./\1_lowql\./')
  if not test $defaultoutput = '*.mp4'
    set convert $(_readyesno 'Convert to mp4 (Y/n)' Y); or return
    if test $convert = 'yes'
      set defaultoutput $(echo $defaultoutput | sed -E 's/(.*)\.(.+)/\1\.mp4/')
    end
  end
  set output $(_readwithdefault 'New file name ('$defaultoutput')' $defaultoutput); or return

  ffmpeg -i "$input" -crf $crf $output
end

function convert
  if not set input (printf $argv[1])
    set input $(find -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.MOV" \) | fzf | sed 's/..//'); _pipesuccess; or return
  end
  echo Converting $input
  set videotype $(_readwithdefault 'To video type' mp4); or return
  set defaultoutput $(echo $input | sed -E 's/\.(.*)$/\.'$videotype'/')
  set output $(_readwithdefault 'New file name ('$defaultoutput')' $defaultoutput); or return

  ffmpeg -i $input -q:v 0 $output
end


# MARK: - Helpers

function _success -d "returns $status"
  return $status
end

function _pipesuccess -d "returns the first non 0 status of the last pipe, needed when a pipe crashes before the last step"
  for s in $pipestatus
    if test $s != 0
      return $s
    end
  end
  return 0
end

function _readwithdefault -d "when read successfully returns empty string this returns the default value"
  read -P "$argv[1]: " -l prompt; or return
  if test -z "$prompt"
    echo $argv[2]
  else
    echo $prompt
  end
end

function _readyesno
  function standardise
    switch $argv[1]
      case true y Y yes YES Yes
        echo "yes"
      case false n N no NO No
        echo "no"
      case '*'
        return 1
    end
  end

  read -P "$argv[1]: " -l prompt; or return
  if test -z "$prompt"
    standardise $argv[2]
  else
    standardise $prompt
  end
end
