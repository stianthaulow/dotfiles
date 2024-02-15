alias dot='chezmoi'
alias dotdir='cd $(dot source-path)/..'

alias ls='eza --icons'

alias zupdate='source $ZDOTDIR/.zshrc'

edit_alias_and_apply() {
	dot edit $ZDOTDIR/aliases.sh
	dot apply
	zupdate
}
alias zalias='edit_alias_and_apply'

edit_config_and_apply() {
	dot edit $ZDOTDIR/.zshrc
	dot apply
	zupdate
}
alias zedit='edit_config_and_apply'

list_aliases() {
	if command -v bat >/dev/null 2>&1; then
		grep '^alias' $ZDOTDIR/aliases.sh | bat --language=zsh --file-name=Aliases
	else
		grep '^alias' $ZDOTDIR/aliases.sh
	fi
}
alias lalias='list_aliases'
