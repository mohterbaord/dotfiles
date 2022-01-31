require 'config'

function color(rgb)
  return '${color ' .. rgb .. '}'
end

function hr()
  return color(color_fg_secondary_dimmed) .. '$hr$color\n'
end

function key_value(key, value)
  return '${color}' .. key .. color(color_fg_value) .. value .. '${color}' 
end
