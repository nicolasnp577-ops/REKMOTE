# 🚀 Developer Toolbox — Loadstring

Bem-vindo! Copie a loadstring abaixo e cole no seu executor do Roblox.

## ⚡ LOADSTRING PRINCIPAL (menu + UltraSpy + tudo embutido)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/loader.lua"))({["Owner"] = "PetewareServices"})
```

---

## 🔧 Alternativas

### Sem o Owner (caso a de cima dê erro):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/loader.lua"))()
```

### UltraSpy direto (só o Remote Spy):
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/nicolasnp577-ops/REKMOTE/main/ULTRASPY.LUA"))()
```

### Versão LOCAL (sem precisar de internet):
```lua
loadstring(readfile("loader.lua"))()
```

---

## 📦 O que vem no menu?

- ✅ **UltraSpy** (Remote Spy avançado — Action Hunt Mode, flow tracking, etc.)
- ✅ **Infinite Yield** (Admin commands)
- ✅ **Remote Spy** (SimpleSpy v3)
- ✅ **Dex Explorer** (Explorer de instâncias)
- ✅ **Hydroxide** (Runtime introspection)
- ✅ **Ketamine** (Script executor)
- ✅ **FPS Booster** (Aumenta FPS)
- ✅ **Addons** (Salve scripts customizados)
- ✅ **Server Hop / Rejoin**
- ✅ **Instance Scanner** (Busca por classes)
- ✅ **Tema Peteware** (Dark mode)

---

## 🐛 Solução de Problemas

### Erro: `attempt to call a nil value`
O `HttpGet` do seu executor retornou vazio. Tente:
1. Feche e reabra o executor
2. Aguarde 30 segundos (rate limit do GitHub)
3. Use a versão LOCAL: `loadstring(readfile("loader.lua"))()`

### Erro: `404 Not Found`
O GitHub pode estar com cache. Espere 1 minuto e tente de novo.

### Erro: `Incompatible Exploit`
Seu executor não tem `loadstring` ou `readfile`. Use um executor melhor (Delta, KRNL, etc.)

---

## 🔗 Links

- 📂 **Repositório:** https://github.com/nicolasnp577-ops/REKMOTE
- 🐛 **Reportar Bug:** Abra uma issue no GitHub
- 💬 **Suporte:** Discord Peteware (https://discord.gg/peteware)

---

## 📋 Créditos

- **Peteware Services** — Developer Toolbox base
- **nicolasnp577-ops (REKMOTE)** — Integração do UltraSpy
- **exx, Frosty** — UltraSpy (SimpleSpy)
- **EdgeIY** — Infinite Yield
- **AZY** — Dex Explorer
- **Hosvile** — Hydroxide
- **Cherry** — Ketamine
- **RIP#6666** — FPS Booster

---

**Peteware Development Team** • 2026
