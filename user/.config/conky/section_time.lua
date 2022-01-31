require 'config'
require 'format'

function datetime()
  return '${time %A %-d} '
    .. color(color_fg_secondary)
    .. '• $color${time %b %Y} '
    .. color(color_fg_secondary)
    .. '• $color${time %-l:%M %p}\n'
end
