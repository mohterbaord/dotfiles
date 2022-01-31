require 'config'
require 'format'

function uptime()
  return key_value('Uptime: ', '$uptime_short') .. '\n'
end

function wifi()
  value = '${wireless_essid wlan0}'
    .. color(color_fg_secondary)
    .. ' (${wireless_link_qual_perc wlan0}%)'
  return key_value('Wi-Fi:  ', value) .. '\n'
end

function lan_ip()
  return key_value('LAN IP: ', '${addr wlan0}') .. '\n'
end
