require 'config'
require 'format'

function usage_ram()
  value = '$mem / $memmax ' .. color(color_fg_secondary) .. '($memperc%)'
  return key_value('RAM Usage: ', value) .. '\n'
    .. color(color_fg_secondary) .. '${memgraph 50 -t}$color\n'
end

function usage_cpu_n(n)
  return color(color_fg_secondary)
    .. '${cpubar cpu' .. n .. ' ' .. bar_height .. ',' .. bar_cpu_width .. '} '
    .. color(color_fg_value) .. '${cpu cpu' .. n .. '}%\n'
end

function usage_cpu()
  return key_value('${color}CPU Usage: ', usage_cpu_n(0))
    .. key_value(color(color_fg_secondary) .. '├──$color CPU 1: ', usage_cpu_n(1))
    .. key_value(color(color_fg_secondary) .. '├──$color CPU 2: ', usage_cpu_n(2))
    .. key_value(color(color_fg_secondary) .. '├──$color CPU 3: ', usage_cpu_n(3))
    .. key_value(color(color_fg_secondary) .. '└──$color CPU 4: ', usage_cpu_n(4))
end

function usage_fs_path(path)
  return color(color_fg_secondary)
    .. '${fs_bar ' .. bar_height .. ',' .. bar_fs_width .. ' ' .. path .. '} '
    .. color(color_fg_value) .. '${fs_used ' .. path .. '} / ${fs_size ' .. path .. '}\n'
end

function usage_fs()
  return '${color}FS Usage:\n'
    .. key_value(color(color_fg_secondary) .. '├──$color root: ', usage_fs_path('/'))
    .. key_value(color(color_fg_secondary) .. '├──$color home: ', usage_fs_path('/home'))
    .. key_value(color(color_fg_secondary) .. '└──$color HDD:  ', usage_fs_path('/media/riot-observer'))
end

function section_usage()
  return usage_ram() .. '\n'
    .. usage_cpu() .. '\n'
    .. usage_fs()
end
