local shell = require "shell"
local event = require "event"
local kb = require "keyboard"
local os = require "os"
local sides = require "sides"
local component = require "component"
local internet = require "internet"
local ser = require "serialization"

local arg,opt = shell.parse(...)
if #arg ~= 1 or next(opt) then
   print("Use: print component list or specific types.")
   os.exit(1)
end

Comps = {}

if string.lower(arg[1]) == "all" then
    if arg[2] ~= nil and string.lower(arg[2]) == "save" then
        for k, v in pairs(component.list()) do
            print(tostring(k)..": "..tostring(v))
            table.insert(Comps, "comp: "..k.." = "..v)
        end
        file=io.open("/comps","w")
        file:write(serial.serialize(Comps))
        file:close()
    else
        for k, v in pairs(component.list()) do
            print(tostring(k)..": "..tostring(v))
        end
    end
elseif arg[3] ~= nil and string.lower(arg[3]) == "save" then
    for k, v in pairs(component.list()) do
        if string.match(string.lower(v), string.lower(arg[1])) then
            print(tostring(k)..": "..tostring(v))
            table.insert(Comps, "comp: "..k.." = "..v)
        end
    end
    file=io.open("/comps","w")
    file:write(serial.serialize(Comps))
    file:close()
else
    for k, v in pairs(component.list()) do
        if string.match(string.lower(v), string.lower(arg[1])) then
            print(tostring(k)..": "..tostring(v))
        end
    end
end


