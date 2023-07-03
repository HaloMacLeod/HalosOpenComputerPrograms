-- Settings
--[[
redstoneSide: direction to output redstone (number)
doorTime: seconds door will be open
blacklist: filename of people to keep out
whitelist: filename of people to let in
accessScreen: UUID of second screen for printing messages
]]


-- These control the resolution and location of the ACCESS GRANTED message on the second screen.
-- You probably don't need to change this so it's not part of settings, but you can change it.
local accessX, accessY = 2, 2
local accessResolution = { 16, 12 }

-- DO NOT EDIT BELOW THIS LINE

-- Require all APIs
local event = require "event"
local kb = require "keyboard"
local os = require "os"
local component = require "component"
local internet = require "internet"
local ser = require "serialization"
-- Now get access to the redstone component
local redstone = component.redstone

local settings = {
    whitelist = {HaloMacLeod},
    --blacklist = {},
    doorTime = 5,
    maingpuaddr = "3627db68-bb13-4df9-ba22-dca33b75c1a8",
    secgpuaddr = "cb6d9713-0569-437a-91a9-415abbcbad8f",
    mainScreen = "735f9afb-653f-48ed-bad6-d2dcd8ab4e17",
    secScreen = "305099b1-c556-491b-b6e6-fec508f75d58",   
}

-- Pattern used to get the UUID from returned string
local UUID_PATTERN = [["id":"(%w+)"]]
-- Access messages
local ACCESS_GRANTED = "ACCESS GRANTED"
local ACCESS_DENIED  = "ACCESS DENIED "
local ACCESS_CLEAR   = "              "
-- This maps player names to UUIDs
local playerToUUID = nil
-- Current timer ID
local timerID = nil

-- This function will determine if the player is allowed in
local isAllowed = nil
-- This function will write to the secondary screen
local displayAccess = nil

-- Log an error to stderr and force-exit
local function fatal(...)
  io.stderr:write("Error:", ...)
  os.exit(1)
end

local cinvoke = component.invoke

local function loadWhitelist()
  if type(settings.whitelist) ~= "table" then fatal(settings.whitelist .. " did not return a table") end
  return settings.whitelist
end

-- Get the UUID of a player, or nil if unavailable
local function getUUID(player)
  local uuid = playerToUUID[player]
  if not uuid then
    local url = "https://api.mojang.com/users/profiles/minecraft/" .. player
    local data = ""
    for chunk in internet.request(url) do data = data .. chunk end
    uuid = string.match(data, UUID_PATTERN)
    if uuid then
      playerToUUID[player] = uuid
      print("Cached " .. uuid .. " as " .. player)
    end
  end
  return uuid
end

local function redstoneOff()
    local red, err = io.open("/red/b8505b59-79f3-461a-9547-9d57495f480d/easy/output", "w")
    red:write("0")
    displayAccess(ACCESS_CLEAR)
end

local function timerCallback()
  timerID = nil
  redstoneOff()
end

-- This is where the main logic starts

-- First we determine if we're using a whitelist or blacklist
-- If loading one doesn't work, exit with an error.
if settings.whitelist then
  print("Loading whitelist...")
  local whitelist = settings.whitelist
  isAllowed = function(player) return settings.whitelist[getUUID(player)] end
else
  fatal("No whitelist or blacklist specified!")
end

-- Load the playerToUUID map
do
  print("Loading cached data...")
  local fd,err = io.open("uuidmap.dat", "rb")
  if not fd then
    playerToUUID = {}
  else
    playerToUUID = ser.unserialize(fd:read("*a")) or {}
    fd:close()
  end
end

-- Now setup the secondary screen
if settings.secScreen and settings.mainScreen then
  local mainscreen = component.get(settings.mainScreen)
  local secscreen = component.get(settings.secScreen, "screen")
  cinvoke(mainscreen, "turnOn")
  cinvoke(secscreen, "turnOn")

  cinvoke(settings.maingpuaddr, "bind", settings.mainScreen, true)
  cinvoke(settings.secgpuaddr, "bind", settings.secScreen, true)

  displayAccessMain = function(msg)
    cinvoke(settings.maingpuaddr, "set", accessX, accessY, msg)
  end

  displayAccessSec = function(msg)
    cinvoke(settings.secgpuaddr, "set", accessX, accessY, msg)
  end

  displayAccessMain(ACCESS_CLEAR)
  displayAccessSec(ACCESS_CLEAR)

else
  -- Dummy function if no screen is available
  displayAccess = function(msg) end
end

print("Press enter to quit...")
while true do 
  local args = {event.pull()}
  if args[1] == "key_down" then
    -- Exit condition
    if args[4] == kb.keys.enter then break end
  elseif args[1] == "motion" then
    -- Handle motion detection 
    local player = args[6]
    if isAllowed(player) then
      local red, err = io.open("/red/b8505b59-79f3-461a-9547-9d57495f480d/easy/output", "w")
      red:write("1")
      -- Cancel the current redstoneOff timer
      if timerID then event.cancel(timerID) end
      timerID = event.timer(settings.doorTime, timerCallback)
      displayAccessMain(ACCESS_GRANTED)
      displayAccessSec(ACCESS_GRANTED)
      print("Granted: " .. player)
    else
      displayAccessMain(ACCESS_DENIED)
      displayAccessSec(ACCESS_DENIED)
      print("Denied:  " .. player)
    end
  end
end

redstoneOff()
-- Save the playerToUUID map
do
  local fd,err = io.open("uuidmap.dat", "wb")
  if fd then
    fd:write(ser.serialize(playerToUUID))
    fd:close()
  end
end