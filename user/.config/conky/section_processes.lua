function processes_top_table(n)
  table = color(color_fg_secondary)
  for i=1,n do
    table = table .. '${top name ' .. i .. '}  ${top pid ' .. i .. '} ${top cpu ' .. n .. '} ${top mem ' .. i .. '}\n'
  end
  return table
end

function section_processes()
  return key_value('Processes: ', '$processes')
    .. color(color_fg_secondary) .. ' • '
    .. key_value('Running: ', '$running_processes') .. '\n\n'
    .. 'Name                  PID   CPU%   MEM%\n'
    .. processes_top_table(4)
end
