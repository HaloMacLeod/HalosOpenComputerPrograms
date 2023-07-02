local version = "1"
for k, v in pairs(component.list()) do
  print(tostring(k)..": "..tostring(v))
end