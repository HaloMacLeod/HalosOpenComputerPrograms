local shell = require "shell"
local event = require "event"
local kb = require "keyboard"
local os = require "os"
local sides = require "sides"
local component = require "component"
local internet = require "internet"
local ser = require "serialization"

local arg,opt = shell.parse(...)
if #arg < 1 or #arg > 2 or next(opt) then
   print("Use: print component list or specific types.")
   os.exit(1)
end

Comps = {}

if string.lower(arg[1]) == "all" then
    for k, v in pairs(component.list()) do
        print(tostring(k)..": "..tostring(v))
        if arg[2] ~= nil and string.lower(arg[2]) == "save" then
            table.insert(Comps, "comp: "..k.." = "..v)
        end
    end
else
    for k, v in pairs(component.list()) do
        if string.match(string.lower(v), string.lower(arg[1])) then
            print(tostring(k)..": "..tostring(v))
            if arg[2] ~= nil and string.lower(arg[2]) == "save" then
                table.insert(Comps, k.." = "..v)
            end
        end
    end
end

if #Comps > 0 then
    file=io.open("/comps","w")
    for i, comp in ipairs(Comps) do
        file:write(comp.."\n")
    end
    file:close()
end

