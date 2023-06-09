#!/bin/bash

# Disclaimer! : I'm very much a beginner in shell scripting and linux in general
# so things might be broken or done in non-efficient ways.

# Some helpful variables
LOG="./dotfiles.log"
CONFIG_DIR="$HOME/.config/"
USER=aeron
DOTFILES_DIR="$(pwd)"
PAC_LOG="/tmp/script-pac.log"

# Check is script is being runned with sudo
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
	echo "This script must be run as sudo!"
else
	# Parameter functions
	dot_help() {
		# Display help
		echo "This install utility is made for getting my dotfiles set-up"
		echo "use the following command bash -c "install-dot.sh"; install"
		echo
		echo "Syntax: install-dot [h|V]"
		echo "options:"
		echo "h		Print this Help."
		echo "V		Print software version and exit."
		echo
	}

	dot_ver() {
		echo "install-dot.sh Version: 1.0.0"
	}

	# --------------------------------------------------------------------- #

	# Helper functions
	_process() {
		echo "$(date) PROCESSING: $@" >> $LOG
		printf "$(tput setaf 6) %s... $(tput sgr0)\n" "$@"
	}

	_success() {
		local message=$1
		printf "%s✓ Success:%s\n" "$(tput setaf 2)" "$(tput sgr0) $message"
	}

	_error() {
		echo "$(date) ERROR: $@" >> $LOG
		local message=$1
		printf "%s✖ Error: %s\n" "$(tput setaf 1)" "$(tput sgr0) $message"
	}

	# --------------------------------------------------------------------- #

	compile_paru(){
		if [[ -d "/opt/paru/" ]]; then
			_success "Paru installation found"
		else
				_process "→Creating paru folder in /opt and setting permissions..."
			mkdir /opt/paru
			chown $USER:$USER /opt/paru/
			_process "→Clonning Paru..."
			git clone https://aur.archlinux.org/paru.git /opt/paru
			cd /opt/paru/
			makepkg --noconfirm -si
			[[ $? ]] && _success "Paru compiled"
			cd $DOTFILES_DIR

		fi
	}

	enable_multilib(){
		# Probably not great way of doing this but it works
		if [[ $(pacman -Sy | grep "multilib") ]]; then		
			[[ $? ]] && _success "Multilib already enabled"
		else
			_process "→ Enabling multilib in /etc/pacman.conf"
			sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf
			# Also not ideal if the config ever changes, but i don't know any other way :x
			sed -i '91s/#Include/Include/g' /etc/pacman.conf
			[[ $? ]] && _success "Enabled multilib"
		fi
	}	

	synchronize_pacman(){
		_process "→ Synchronizing pacman for multilib"
		pacman -Sy
		_sucess "Pacman database synchronized"
	}

	install_deps() {
		_process "→ Installing dependencies with pacman"
		pacman -S --needed - < $DOTFILES_DIR/deps.txt 2>$PAC_LOG

		if [[ $(cat /tmp/script-pac.log | grep "target not found") ]]; then
			_error "Target not found for one or more packages"
		else
			[[ $? -eq 0 ]] && _success "Packages installed/skipped"
		fi
	}

	install_aur() {
		_process "→ Installing dependencies with paru"
		paru -S --needed - < $DOTFILES_DIR/deps_aur.txt 2>$PAC_LOG

		if [[ $(cat /tmp/script-pac.log | grep "could not find all") ]]; then
			_error "Target not found for one or more packages"
		else
			[[ $? ]] && _success "AUR Packages installed/skipped"
		fi
	}

	link_dotfiles () {
		_process "→ Symlinking dotfiles with stow"
		stow */
		[[ $? ]] && _success "Config files symlinked"
	}

	lemurs_setup() {
		_process "→ Installing lemurs trough paru"
		paru -S lemurs-git 2>$PAC_LOG
		[[ $? ]] && _success "lemurs installed"
		_process "→ Enabling lemurs service"
		systemctl enable lemurs.service
		[[ $? ]] && _sucess "lemurs service enabled"

		mkdir -p /etc/lemurs/wayland
		touch /etc/lemurs/wayland/hyprland
		echo "#!/bin/bash" | tee -a /etc/lemurs/wayland/hyprland > /dev/null 
		echo "exec Hyprland" | tee -a /etc/lemurs/wayland/hyprland > /dev/null 
		chmod +x /etc/lemurs/wayland/hyprland
	}

	install() {
		compile_paru
		enable_multilib
		synchronize_pacman
		install_dependencies
		install_aur
		link_dotfiles
		lemurs_setup
	}

	# --------------------------------------------------------------------- #
	# Parameter handling
	while getopts ":h" option; do
		case $option in
			h)
				dot_help
				exit;;
			V)
				print_ver
				exit;;
			\?)
				echo "Invalid options"
				exit;;
		esac
	done
	
	# --------------------------------------------------------------------- #
	# Actually run the program
	echo "Welcome to the installation script for my dotfiles"
	echo "Would you like to proceed with installation? (Y) (N)"
	read input

	if [[ $input =~ ^(y|Y|yes|Yes) ]]; then
		install
	else
		echo "Exiting program..."
	fi

	# --------------------------------------------------------------------- #

fi
