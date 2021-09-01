local key = matches[2]
local value = matches[3]
local valid = {
  location = true,
  format = true,
  font = true,
  fontSize = true,
  updateTime = true,
  enabled = true,
  height = true,
  width = true,
  metric = true,
}
if not valid[key] then
  cecho(f"<red>WTTR<r>: Invalid config name. You gave {key} and valid options are {table.concat(table.keys(valid), ',')}\n")
  return
end
if table.contains({"fontSize", "height", "width", "updateTime"}, key) then
  local numValue = tonumber(value)
  if numValue == nil then
    cecho(f"<red>WTTR<r>: config item {key} must be a number, but '{value}' cannot be turned into a number")
  end
  value = numValue
end
WTTR.config[key] = value
if key == "location"then
  if value == "default" then
    WTTR.config.location = ""
  end
  if WTTR.config.enabled then
    WTTR.start()
  end
  return
end
if key == "font" then
  WTTR.mc:setFont(value)
  return
end
if key == "fontSize" then
  WTTR.mc:setFontSize(value)
  return
end
if key == "enabled" then
  if value == "false" or value == "no" then
    WTTR.config.enabled = false
    WTTR.stop()
  else
    WTTR.config.enabled = true
    WTTR.start()
  end
  return
end
if key == "metric" then
  if value == "false" or value == "no" then
    WTTR.config.metric = false
  else
    WTTR.config.metric = true
  end
  if WTTR.config.enabled then
    WTTR.start()
  end
  return
end
if key == "updateTime" or key == "format" then
  if WTTR.config.enabled then
    WTTR.start()
  end
  return
end
