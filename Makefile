all: polybar zsh i3 conky

all-system: system-vconsole system-udev system-xorg

polybar:
	@(cd user/.config/polybar/; ./compile-bundle.sh)
	@install --verbose --compare --directory \
		$$HOME/.config/polybar \
		$$HOME/.config/polybar/bin \
		$$HOME/.config/polybar/bin/module \
		$$HOME/.config/polybar/config \
		$$HOME/.config/polybar/config/include \
		$$HOME/.config/polybar/config/include/bar \
		$$HOME/.config/polybar/config/include/global \
		$$HOME/.config/polybar/config/include/module
	@install --verbose --compare --target-directory=$$HOME/.config/polybar/bin \
		user/.config/polybar/dist/bin/launch.sh
	@install --verbose --compare --target-directory=$$HOME/.config/polybar/bin/module \
		user/.config/polybar/dist/bin/module/bluetooth.sh
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/polybar/config \
		user/.config/polybar/dist/config/config.ini
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/polybar/config/include \
		user/.config/polybar/dist/config/include/colors.ini \
		user/.config/polybar/dist/config/include/fonts.ini \
		user/.config/polybar/dist/config/include/settings.ini
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/polybar/config/include/bar \
		user/.config/polybar/dist/config/include/bar/status-bar.ini
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/polybar/config/include/global \
		user/.config/polybar/dist/config/include/global/wm.ini
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/polybar/config/include/module \
		user/.config/polybar/dist/config/include/module/backlight.ini \
		user/.config/polybar/dist/config/include/module/battery.ini \
		user/.config/polybar/dist/config/include/module/bluetooth.ini \
		user/.config/polybar/dist/config/include/module/date.ini \
		user/.config/polybar/dist/config/include/module/eth.ini \
		user/.config/polybar/dist/config/include/module/i3.ini \
		user/.config/polybar/dist/config/include/module/pulseaudio.ini \
		user/.config/polybar/dist/config/include/module/wlan.ini \
		user/.config/polybar/dist/config/include/module/xkeyboard.ini

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
		user/.local/bin/bluepoop \
		user/.local/bin/pa-set-sink-volume-limited \
		user/.local/bin/playerctl \
		user/.local/bin/scrotcrop

conky:
	@install --verbose --compare --directory \
		$$HOME/.config/conky
	@install --verbose --compare --mode=644 --target-directory=$$HOME/.config/conky \
		user/.config/conky/config.lua \
		user/.config/conky/conky.lua \
		user/.config/conky/format.lua \
		user/.config/conky/section_network.lua \
		user/.config/conky/section_processes.lua \
		user/.config/conky/section_time.lua \
		user/.config/conky/section_usage.lua

system-vconsole:
	@install --verbose --compare --mode=644 --group=root --owner=root --target-directory=/etc \
		system/etc/vconsole.conf

system-udev:
	@install --verbose --compare --mode=755 --group=root --owner=root --directory \
		/etc/udev/rules.d
	@install --verbose --compare --mode=644 --group=root --owner=root --target-directory=/etc/udev/rules.d \
		system/etc/udev/rules.d/81-backlight.rules

system-xorg:
	@install --verbose --compare --mode=755 --group=root --owner=root --directory \
		/etc/X11/xorg.conf.d
	@install --verbose --compare --mode=644 --group=root --owner=root --target-directory=/etc/X11/xorg.conf.d \
		system/etc/X11/xorg.conf.d/00-keyboard.conf \
		system/etc/X11/xorg.conf.d/10-monitor.conf \
		system/etc/X11/xorg.conf.d/20-intel.conf \
		system/etc/X11/xorg.conf.d/90-touchpad.conf
