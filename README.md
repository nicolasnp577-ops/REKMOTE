# REKMOTE

Remote spy / UltraSpy para Roblox (client).

## 🚀 Carregar com loadstring

**⚡ LOADSTRING PRINCIPAL (menu + UltraSpy + tudo embutido):**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/loader.lua"))({["Owner"] = "PetewareServices"})
```

**Ou só o UltraSpy:**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/ULTRASPY.LUA"))()
```

> 📋 Mais opções em **[LOADSTRING.md](LOADSTRING.md)**

Execute o mais cedo possível na sessão (antes de módulos cachearem `FireServer`).

## Developer Toolbox (LOADER.LUAU)

No menu **Tools**, use o botão **UltraSpy (REKMOTE)** — baixa e executa o script do GitHub (com cache na sessão).

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `ULTRASPY.LUAU` | Script principal |
| `LOADER.LUAU` | Developer Toolbox com opção UltraSpy em Tools |
| `loader.lua` | Baixa e executa o principal via GitHub raw |

## Config (opcional, antes do load)

```lua
_G.SIMPLESPYCONFIG_ActionHuntMode = true
_G.SIMPLESPYCONFIG_RunSelfTest = true
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/ULTRASPY.LUAU"))()
```

## Repositório

https://github.com/nicolasnp577-ops/REKMOTE
