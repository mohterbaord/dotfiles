all: polybar zsh

polybar:
	@(cd .config/polybar/; ./install.sh)

zsh:
	@install --verbose --compare --directory $$HOME/.config/zsh $$HOME/.local/bin
	@install --verbose --compare --mode=644 --target-directory=$$HOME .zshenv
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/zsh .config/zsh/.zshenv .config/zsh/.zshrc
	@install --verbose --compare --target-directory=$$HOME/.local/bin .local/bin/frameshot
