WTTR = WTTR or {
  config = {}
}
local metaconfig = {
  location = "",
  format = "A0pq",
  font = "Bitstream Vera Sans Mono",
  fontSize = 9,
  updateTime = 60,
  enabled = true,
  color = "black",
  height = 11,
  width = 35,
  metric = false,
}

local filename = getMudletHomeDir() .. "/wttr.lua"

function WTTR.load()
  if io.exists(filename) then
    table.load(filename, WTTR.config)
  end
  setmetatable(WTTR.config, metaconfig)
  metaconfig.__index = metaconfig
end
WTTR.load()
local config = WTTR.config
local fwidth, fheight = calcFontSize(config.fontSize, config.font)
local startingWidth = fwidth * config.width
local startingHeight = fheight * config.height

WTTR.container = WTTR.container or Adjustable.Container:new({
  name = "WTTRContainer",
  x = -1 * startingWidth,
  y = 0,
  height = startingHeight,
  width = startingWidth,
})

WTTR.mc = WTTR.mc or Geyser.MiniConsole:new({
  name = "WTTRConsole",
  fontSize = config.fontSize,
  font = config.font,
  x = 0,
  y = 0,
  height = "100%",
  width = "100%",
  color = config.color
}, WTTR.container)

function WTTR.update(_, url, response)
  if not url:starts("https://wttr.in/") then return end
  local text = ansi2decho(response)
  WTTR.mc:clear()
  WTTR.mc:decho(text)
end

function WTTR.start()
  WTTR.stop()
  WTTR.eventID = registerAnonymousEventHandler("sysGetHttpDone", WTTR.update)
  local config = WTTR.config
  local url = f"https://wttr.in/{config.location}?{config.format}{config.metric and 'm' or ''}"
  WTTR.timerID = tempTimer(WTTR.config.updateTime, function()
    getHTTP(url)
  end, true)
  getHTTP(url)
end

function WTTR.stop()
  if WTTR.eventID then
    killAnonymousEventHandler(WTTR.eventID)
  end
  if WTTR.timerID then
    killTimer(WTTR.timerID)
  end
end

function WTTR.hide()
  WTTR.container:hide()
end

function WTTR.show()
  WTTR.container:show()
end

function WTTR.save()
  table.save(filename, WTTR.config)
end

function WTTR.usage()
  local function ce(msg)
    cecho(f"<red>WTTR<r>: {msg}")
  end
  ce("<green>wttr<r>: print this message\n")
  ce("<green>wttr save<r>: save the config to disk\n")
  ce("<green>wttr load<r>: load the config from disk\n")
  ce("<green>wttr hide<r>: hide the wttr window\n")
  ce("<green>wttr show<r>: show the wttr window\n")
  ce("<green>wttr stop<r>: stop and hide the wttr window\n")
  ce("<green>wttr start<r>: start and show the wttr window\n")
  ce("<green>wttr config <item> <value><r>: change config\n")
  ce("  <green>config    <r>: <purple>default\n")
  ce("  <green>location  <r>: <purple>auto determined by your IP. Use 'default' to change back to this.\n")
  ce("  <green>format    <r>: <purple>A0pq\n")
  ce("  <green>          <r>: <purple>see https://wttr.in/:help if you want to change this.\n")
  ce("  <green>font      <r>: <purple>Bitstream Vera Sans Mono\n")
  ce("  <green>fontSize  <r>: <purple>9\n")
  ce("  <green>updateTime<r>: <purple>60\n")
  ce("  <green>enabled   <r>: <purple>true\n")
  ce("  <green>metric    <r>: <purple>false\n")
  ce("  For example:\n")
  ce("  wttr config fontSize 10\n")
  ce("  wttr config metric true\n")
  ce("  wttr config location London\n")
  ce("  wttr config location default\n")
end

WTTR.save()
if WTTR.config.enabled then
  WTTR.start()
  WTTR.show()
end
if WTTR.exitID then
  killAnonymousEventHandler(WTTR.exitID)
end
WTTR.exitID = registerAnonymousEventHandler("sysExitEvent", WTTR.save)
if WTTR.uninstallID then
  killAnonymousEventHandler(WTTR.uninstallID)
end
WTTR.uninstallID = registerAnonymousEventHandler("sysUninstall", function()
  WTTR.save()
  WTTR.stop()
  WTTR.hide()
end)