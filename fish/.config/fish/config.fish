# ~/.config/fish/config.fish

if type -q starship
    starship init fish | source
end

# Use default editor
set -Ux EDITOR nvim

# Helpful abbreviations (like bash aliases but more powerful)
abbr --add gs 'git status'
abbr --add ga 'git add'
abbr --add gc 'git commit'
abbr --add gp 'git push'
abbr --add gmr 'set -l cur (git rev-parse --abbrev-ref HEAD); and git stash; and git checkout main; and git pull; and git checkout $cur; and git merge main; and git stash pop'
abbr --add gdr 'set -l cur (git rev-parse --abbrev-ref HEAD); and git stash; and git checkout devtest; and git pull; and git checkout $cur; and git merge devtest; and git stash pop'
abbr -a pr 'gh pr create --fill'
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'

# Enable vi keybindings 
fish_vi_key_bindings

# Set PATH additions
set -Ua fish_user_paths $HOME/.local/bin

# Fish git prompt
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate ''
set __fish_git_prompt_showupstream 'none'
set -g fish_prompt_pwd_dir_length 3

function fish_prompt
	set_color brblack
	echo -n "["(date "+%H:%M")"] "
	set_color blue
	echo -n (hostnamectl hostname)
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ':'
		set_color yellow
		echo -n (basename $PWD)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

function fish_greeting
	echo
	echo -e (uname -ro | awk '{print " \\\\e[1mOS: \\\\e[0;32m"$0"\\\\e[0m"}')
	#echo -e (uptime -p | sed 's/^up //' | awk '{print " \\\\e[1mUptime: \\\\e[0;32m"$0"\\\\e[0m"}')
	#echo -e (uptime | awk -F'( |,|:)+' '{ 
	#    print " \\\e[1mUptime: \\\e[0;32m" $3 " hours, " $4 " minutes\\\e[0m"
	#}')
	echo -e (uptime | awk '
	    BEGIN { OFS = "" }
	    {
		for (i = 1; i <= NF; i++) {
		    if ($i == "up") {
			uptime_start = i + 1
			break
		    }
		}
		# Collect uptime info (everything until the next comma)
		uptime_str = ""
		for (j = uptime_start; j <= NF; j++) {
		    if (index($j, ",") > 0) break
		    uptime_str = uptime_str $j " "
		}
		gsub(/[[:space:]]+$/, "", uptime_str)
		print " \033[1mUptime: \033[0;32m" uptime_str "\033[0m"
	    }
	')
	echo -e (uname -n | awk '{print " \\\\e[1mHostname: \\\\e[0;32m"$0"\\\\e[0m"}')
	echo -e " \\e[1mDisk usage:\\e[0m"
	echo
	echo -ne (\
		df -l -h | grep -E 'dev/(xvda|sd|mapper)' | \
		awk '{printf "\\\\t%s\\\\t%4s / %4s  %s\\\\n\n", $6, $3, $2, $5}' | \
		sed -e 's/^\(.*\([8][5-9]\|[9][0-9]\)%.*\)$/\\\\e[0;31m\1\\\\e[0m/' -e 's/^\(.*\([7][5-9]\|[8][0-4]\)%.*\)$/\\\\e[0;33m\1\\\\e[0m/' | \
		paste -sd ''\
	)
	echo

	echo -e " \\e[1mNetwork:\\e[0m"
	echo
	# http://tdt.rocks/linux_network_interface_naming.html
	echo -ne (\
		ip addr show up scope global | \
			grep -E ': <|inet' | \
			sed \
				-e 's/^[[:digit:]]\+: //' \
				-e 's/: <.*//' \
				-e 's/.*inet[[:digit:]]* //' \
				-e 's/\/.*//'| \
			awk 'BEGIN {i=""} /\.|:/ {print i" "$0"\\\n"; next} // {i = $0}' | \
			sort | \
			column -t -R1 | \
			# public addresses are underlined for visibility \
			sed 's/ \([^ ]\+\)$/ \\\e[4m\1/' | \
			# private addresses are not \
			sed 's/m\(\(10\.\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\.\).*\)/m\\\e[24m\1/' | \
			# unknown interfaces are cyan \
			sed 's/^\( *[^ ]\+\)/\\\e[36m\1/' | \
			# ethernet interfaces are normal \
			sed 's/\(\(en\|em\|eth\)[^ ]* .*\)/\\\e[39m\1/' | \
			# wireless interfaces are purple \
			sed 's/\(wl[^ ]* .*\)/\\\e[35m\1/' | \
			# wwan interfaces are yellow \
			sed 's/\(ww[^ ]* .*\).*/\\\e[33m\1/' | \
			sed 's/$/\\\e[0m/' | \
			sed 's/^/\t/' \
		)
	echo

	set r (random 0 100)
	if [ $r -lt 5 ] # only occasionally show backlog (5%)
		echo -e " \e[1mBacklog\e[0;32m"
		set_color blue
		echo "  [project] <description>"
		echo
	end

	set_color normal
	echo -e " \e[1mTODOs\e[0;32m"
	echo
	if [ $r -lt 10 ]
		# unimportant, so show rarely
		set_color cyan
		# echo "  [project] <description>"
	end
	if [ $r -lt 25 ]
		# back-of-my-mind, so show occasionally
		set_color green
		# echo "  [project] <description>"
	end
	if [ $r -lt 50 ]
		# upcoming, so prompt regularly
		set_color yellow
		# echo "  [project] <description>"
	end

	# urgent, so prompt always
	set_color red
	# echo "  [project] <description>"

	echo

	if test -s ~/todo
		set_color magenta
		cat todo | sed 's/^/ /'
		echo
	end

	set_color normal
end

function reload
    source ~/.config/fish/config.fish
    echo "Fish config reloaded!"
end

function nix-conf
    sudo -E nvim /etc/nixos/configuration.nix
end
