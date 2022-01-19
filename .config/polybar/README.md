# Dependencies

* [bluez]()
* [polybar]()

## Fonts

* [Termsyn]()
* [Siji]()
* [Flags Color World]()

# Installing

```sh
./install.sh
```

# Launching

The `bin/launch.sh` requires a `POLYBAR_HOME` environment variable that contains a path to the Polybar configs directory.
By default it is `$HOME/.config/polybar`.

```sh
POLYBAR_HOME="$HOME/.config/polybar"
POLYBAR_HOME="$POLYBAR_HOME" "$POLYBAR_HOME/bin/launch.sh" 
```

For example, in **i3** config you could write the following code to run Polybar:

```sh
set $POLYBAR_HOME $HOME/.config/polybar
exec_always --no-startup-id "POLYBAR_HOME=$POLYBAR_HOME $POLYBAR_HOME/bin/launch.sh"
```

# Troubleshooting

If the bar does not load the fonts correctly, use the following command:

```sh
fc-cache -rv
```
