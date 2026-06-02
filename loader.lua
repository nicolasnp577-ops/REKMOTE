--[[
  REKMOTE / UltraSpy — loader
  Cole no executor ou use como script.
]]

local URL = "https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/ULTRASPY.LUAU"

local ok, src = pcall(function()
	return game:HttpGet(URL)
end)

if not ok or type(src) ~= "string" or src == "" then
	return warn("[REKMOTE] Falha ao baixar: " .. tostring(src))
end

local fn, err = loadstring(src)
if not fn then
	return warn("[REKMOTE] loadstring erro: " .. tostring(err))
end

return fn()
