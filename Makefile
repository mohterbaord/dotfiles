all: polybar

polybar:
	@(cd .config/polybar/; ./install.sh)
