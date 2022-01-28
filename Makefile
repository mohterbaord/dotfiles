all: polybar zsh i3

polybar:
	@(cd user/.config/polybar/; ./install.sh)

zsh:
	@install --verbose --compare --directory \
		$$HOME/.config/zsh \
		$$HOME/.local/bin
	@install --verbose --compare --mode=644 --target-directory=$$HOME \
		user/.zshenv
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/zsh \
		user/.config/zsh/.zshenv \
		user/.config/zsh/.zshrc
	@install --verbose --compare --target-directory=$$HOME/.local/bin \
		user/.local/bin/frameshot

i3:
	@install --verbose --compare --directory \
		$$HOME/.config/i3 \
		$$HOME/.local/bin
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/i3 \
		user/.config/i3/config
	@install --verbose --compare --target-directory=$$HOME/.local/bin \
		user/.local/bin/pa-set-sink-volume-limited \
		user/.local/bin/playerctl
