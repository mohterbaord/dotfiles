require 'config'
require 'section_network'
require 'section_processes'
require 'section_time'
require 'section_usage'

conky.config = {
  alignment = 'middle_left',
  background = true,
  border_width = 24,
  cpu_avg_samples = 2,
  default_color = color_fg_primary,
  default_outline_color = 'blue',
  default_shade_color = 'black',
  double_buffer = true,
  draw_borders = false,
  draw_graph_borders = true,
  draw_outline = false,
  draw_shades = false,
  extra_newline = false,
  font = '<% .global.font.monospaced %>:size=10',
  gap_x = 69,
  gap_y = 10,
  minimum_height = 5,
  minimum_width = 5,
  net_avg_samples = 2,
  no_buffers = true,
  out_to_console = false,
  out_to_ncurses = false,
  out_to_stderr = false,
  out_to_x = true,
  own_window = true,
  own_window_class = 'Conky',
  own_window_colour = color_black,
  own_window_type = 'override',
  own_window_transparent = false,
  own_window_argb_visual = true,
  own_window_argb_value = 185,
  show_graph_range = false,
  show_graph_scale = false,
  stippled_borders = 0,
  update_interval = 1.0,
  uppercase = false,
  use_spacer = 'none',
  use_xft = true,
}

conky.text = datetime() .. '\n'
  .. hr() .. '\n'
  .. uptime() .. wifi() .. lan_ip() .. '\n'
  .. hr() .. '\n'
  .. section_usage() .. '\n'
  .. hr() .. '\n'
  .. section_processes()
