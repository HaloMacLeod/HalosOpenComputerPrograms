local shell = require "shell"
local event = require "event"
local kb = require "keyboard"
local os = require "os"
local sides = require "sides"
local component = require "component"
local internet = require "internet"
local ser = require "serialization"

local smeltIron = component.proxy("9882b341-aa1d-40c7-8971-147d0ad60c66")
local smeltCopper = component.proxy("582498d8-3387-4a9f-b588-e56570252d93")
local smeltLead = component.proxy("a1a71aa3-1207-4792-a919-aebca4537ce2")
local Drain = component.proxy("d7ad0645-174b-4344-8fde-e37ab3088548")

local arg,opt = shell.parse(...)
if #arg == 0 or next(opt) then
   print("Use: print component list or specific types.")
   os.exit(1)
end

if string.lower(arg[1]) == "iron" then
    if arg[3] ~= nil then
        smeltCopper.setOutput(sides.west, 0)
        smeltLead.setOutput(sides.west, 0)
        smeltIron.setOutput(sides.west, 15)

        wait(arg[3])
        smeltIron.setOutput(sides.west,0)
        Drain.setOutput(sides.top, 0)
        os.exit(1)
    end
    if arg[2] ~= nil and string.lower(arg[2]) == "drain"
        smeltLead.setOutput(sides.west, 0)
        smeltCopper.setOutput(sides.west, 0)
        Drain.setOutput(sides.top, 15)
        smeltIron.setOutput(sides.west, 15)
        os.exit(1)
    end
    Drain.setOutput(sides.top, 0)
    smeltLead.setOutput(sides.west, 0)
    smeltCopper.setOutput(sides.west, 0)
    smeltIron.setOutput(sides.west, 15)
    os.exit(1)
elseif string.lower(arg[1]) == "copper" then
    Drain.setOutput(sides.top, 0)
    smeltCopper.setOutput(sides.west, 15)
    if arg[3] ~= nil then
        smeltIron.setOutput(sides.west, 0)
        smeltCopper.setOutput(sides.west, 15)

        wait(arg[3])
        smeltCopper.setOutput(sides.west,0)
        Drain.setOutput(sides.top, 0)
        os.exit(1)
    end
    if arg[2] ~= nil and string.lower(arg[2]) == "drain"
        Drain.setOutput(sides.top, 15)
        smeltIron.setOutput(sides.west, 0)
        os.exit(1)
    end
    os.exit(1)
elseif string.lower(arg[1]) == "drain" then
    smeltIron.setOutput(sides.west, 0)
    Drain.setOutput(sides.top, 15)
    os.exit(1)
elseif string.lower(arg[1]) == "stop" then
    smeltIron.setOutput(sides.west, 0)
    Drain.setOutput(sides.top, 0)
end