--[[
  REKMOTE / UltraSpy — loader (LOADER.LUAU)
  Cole este script no seu executor ou use a loadstring abaixo.

  Loadstring:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/LOADER.LUAU"))()
]]

local URL = "https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/ULTRASPY.LUAU"

-- Aguarda o jogo carregar (necessário em alguns executors)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Baixa o código do UltraSpy
local ok, src = pcall(function()
    return game:HttpGet(URL)
end)

if not ok or type(src) ~= "string" or src == "" then
    return warn("[REKMOTE] Falha ao baixar UltraSpy: " .. tostring(src))
end

-- Compila o código
local fn, err = loadstring(src)
if not fn then
    return warn("[REKMOTE] Erro de loadstring: " .. tostring(err))
end

-- Executa o UltraSpy
return fn()
