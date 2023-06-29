#!/bin/bash
# THIS IS STILL EMPTY (WORK IN PROGRESS),
# I'll try making one of those neat installer scripts so i don't need
# so much manual effort for everytime i need to setup my desktop

LOG="./dotfiles.log"
CONFIG_DIR="$HOME/.config/"
USER=aeron
DOTFILES_DIR="$(pwd)"

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
		sudo mkdir /opt/paru
		sudo chown $USER:$USER /opt/paru/
		_process "→Clonning Paru..."
		git clone https://aur.archlinux.org/paru.git /opt/paru
		cd /opt/paru/
		makepkg --noconfirm -si
		[[ $? ]] && _success "Paru compiled"
		cd $DOTFILES_DIR

	fi
}

enable_multilib(){
	if [[ $(sudo pacman -Sy | grep "multilib") ]]; then
		[[ $? ]] && _success "Multilib already enabled"
	else
		_process "→ Enabling multilib in /etc/pacman.conf"
		sudo sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf
		sudo sed -i '91s/#Include/Include/g' /etc/pacman.conf
		[[ $? ]] && _success "Enabled multilib"
	fi
}	

synchronize_pacman(){
	_process "→ Synchronizing pacman for multilib"
	sudo pacman -Sy
}

install_deps() {
	_process "→ Installing dependencies with pacman"
	sudo pacman -S --needed - < $DOTFILES_DIR/deps.txt 2>/tmp/script-pac.log 

	if [[ $(cat /tmp/script-pac.log | grep "target not found") ]]; then
		_error "Target not found for one or more packages"
	else
		[[ $? -eq 0 ]] && _success "Packages installed/skipped"
	fi
}

install_aur() {
	_process "→ Installing dependencies with paru"
	paru -S --needed - < $DOTFILES_DIR/deps_aur.txt 2>/tmp/script-pac.log

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

install() {
	compile_paru
	enable_multilib
	synchronize_pacman
	install_dependencies
	install_aur
	link_dotfiles
}
