local shell = require "shell"

local arg,opt = shell.parse(...)
if #arg ~= 1 or next(opt) then
   print("Use: print component list or specific types.")
   os.exit(1)
end

local function print_component(arg[1])
    if arg == "all" then
        for k, v in pairs(component.list()) do
            print(tostring(k)..": "..tostring(v))
          end
        else
            for k, v in pairs(component.list()) do
                if string.match(string.lower(v), string.lower(arg[1])) then
                    print(tostring(k)..": "..tostring(v))
                end
              end
            end
        end
    end
end

