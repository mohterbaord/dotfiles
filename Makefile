all: polybar zsh

polybar:
	@(cd user/.config/polybar/; ./install.sh)

zsh:
	@install --verbose --compare --directory $$HOME/.config/zsh $$HOME/.local/bin
	@install --verbose --compare --mode=644 --target-directory=$$HOME user/.zshenv
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/zsh user/.config/zsh/.zshenv user/.config/zsh/.zshrc
	@install --verbose --compare --target-directory=$$HOME/.local/bin user/.local/bin/frameshot
