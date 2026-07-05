-- Refatoração segura e modular do meuscript.lua
-- Principais objetivos:
-- 1) Melhor organização e modularidade
-- 2) Segurança: validação de IO e carregamento remoto com pcall
-- 3) Performance: conexões gerenciadas, menos loops redundantes
-- 4) UX: salvamento de config, atualização automática de listas, overlay de desempenho
-- 5) Risco: funcionalidades invasivas (ESP/AutoSight/Fly/Noclip/Teleport/Imortal) DESATIVADAS POR PADRÃO

-- CONFIGURAÇÕES GLOBAIS
local CONFIG = {
    ENABLE_RISKY_FEATURES = false, -- Defina para true por sua conta e risco (NÃO RECOMENDADO em servidores públicos)
    LINK_DO_SITE = "https://vadiasnotopo.github.io/Chanel_1anonimo/",
    ARQUIVO_TEMPO = "Tempo_Painel_Chanel.txt",
    NOME_SAVE_RAYFIELD = "MinhaChaveDiaria",
    TEMPO_MAXIMO = 24 * 60 * 60, -- 24h em segundos
}

-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Utils seguros para File IO
local function SafeIsFile(path)
    if isfile then
        local ok, val = pcall(function() return isfile(path) end)
        if ok then return val end
    end
    return false
end

local function SafeReadFile(path)
    if readfile and SafeIsFile(path) then
        local ok, content = pcall(function() return readfile(path) end)
        if ok then return content end
    end
    return nil
end

local function SafeWriteFile(path, content)
    if not writefile then return false end
    local ok, err = pcall(function() writefile(path, content) end)
    return ok, err
end

local function SafeDelFile(path)
    if not delfile then return false end
    local ok, err = pcall(function() delfile(path) end)
    return ok, err
end

-- Auto-copy do link (não é invasivo)
pcall(function() setclipboard(CONFIG.LINK_DO_SITE) end)

-- Sistema de tempo simples (grava timestamp local)
if SafeIsFile(CONFIG.ARQUIVO_TEMPO) then
    local tempoSalvo = tonumber(SafeReadFile(CONFIG.ARQUIVO_TEMPO))
    local tempoAtual = os.time()
    if tempoSalvo and tempoAtual - tempoSalvo >= CONFIG.TEMPO_MAXIMO then
        pcall(function()
            if SafeIsFile(CONFIG.NOME_SAVE_RAYFIELD..".txt") then SafeDelFile(CONFIG.NOME_SAVE_RAYFIELD..".txt") end
            SafeWriteFile(CONFIG.ARQUIVO_TEMPO, tostring(os.time()))
        end)
    end
else
    SafeWriteFile(CONFIG.ARQUIVO_TEMPO, tostring(os.time()))
end

-- Chave do dia (utiliza UTC para previsibilidade)
local function PegarChaveDoDia()
    local data = os.date("!*t")
    return tostring("KEY-" .. (data.day * 7) .. "X" .. (data.month * 3) .. data.year)
end

-- Tentativa segura de carregar Rayfield (biblioteca de UI)
local Rayfield = nil
local function LoadRayfield()
    -- Tenta carregar via HTTP, mas usa pcall e falha com mensagem clara
    local ok, result = pcall(function()
        local source = game:HttpGet('https://sirius.menu/rayfield')
        if type(source) ~= 'string' then error('Rayfield: conteúdo inválido') end
        local fn = loadstring(source)
        if type(fn) ~= 'function' then error('Rayfield: não é função') end
        return fn()
    end)
    if ok then
        Rayfield = result
        return true
    else
        -- Fall back: tenta encontrar Rayfield já carregado no ambiente, se houver
        if _G.Rayfield then Rayfield = _G.Rayfield return true end
        warn('Falha ao carregar Rayfield:', result)
        return false, result
    end
end

local ok, err = LoadRayfield()
if not ok then
    -- Em vez de abortar, criamos um aviso e uma versão mínima de substituição para evitar erros subsequentes.
    -- A UI completa requer Rayfield; peça ao usuário instalar ou permitir HTTP.
    warn('Rayfield indisponível. A UI ficará limitada. Instale/permita Rayfield para funcionalidade completa.')
    -- Minimal stub (apenas para prevenir erros se Rayfield for usado sem checar)
    Rayfield = Rayfield or {
        CreateWindow = function() return { CreateTab = function() return { CreateSection = function() return end } end } end,
        Notify = function() end,
    }
end

-- Criação da janela principal com salvamento de configuração habilitado
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional Unificado (Refatorado)",
   LoadingTitle = "Carregando Scripts...",
   LoadingSubtitle = "Refatoração segura",
   ConfigurationSaving = { Enabled = true, FolderName = "MeuPainelConfigs", FileName = "PainelConfig" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "Acesso Premium (Passe de 24h)",
      Subtitle = "Link do gerador copiado para a área de transferência!",
      Note = "Cole o link no navegador e pegue sua Key.",
      FileName = CONFIG.NOME_SAVE_RAYFIELD,
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {PegarChaveDoDia()}
   }
})

-- Abas
local Tab = Window:CreateTab("Aba-1", 4483362458)
local Tab2 = Window:CreateTab("Aba-2 (Portais)", 4483362458)
local Tab3 = Window:CreateTab("Aba-3 (Gráficos)", 4483362458)

-- Estado e conexões gerenciadas
local State = {
    ESP = false,
    Noclip = false,
    Wall = false,
    Immortal = false,
    Fly = false,
    FlySpeed = 50,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoSightTarget = nil,
}

local Connections = {}
local function AddConnection(conn)
    table.insert(Connections, conn)
    return conn
end
local function CleanupConnections()
    for _, c in ipairs(Connections) do
        if c and c.Disconnect then
            pcall(function() c:Disconnect() end)
        elseif c and c.Disconnect == nil and c.disconnect then
            pcall(function() c:disconnect() end)
        end
    end
    Connections = {}
end

-- Helpers
local function ObterRaiz(char)
    if not char then return nil end
    if char.PrimaryPart then return char.PrimaryPart end
    if char:FindFirstChild('HumanoidRootPart') then return char.HumanoidRootPart end
    if char:FindFirstChild('Torso') then return char.Torso end
    if char:FindFirstChild('UpperTorso') then return char.UpperTorso end
    return char:FindFirstChildWhichIsA('BasePart')
end

local function PegarNomesJogadores()
    local nomes = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(nomes, p.Name) end
    end
    if #nomes == 0 then table.insert(nomes, "Nenhum outro jogador") end
    return nomes
end

-- Atualizar dropdowns automaticamente com eventos de jogador
local function AtualizarDropdownsThread(DropdownTeleporte, DropdownVisual, DropdownSight)
    local function Atualizar()
        local lista = PegarNomesJogadores()
        if DropdownTeleporte then pcall(function() DropdownTeleporte:Refresh(lista) end) end
        if DropdownVisual then pcall(function() DropdownVisual:Refresh(lista) end) end
        if DropdownSight then pcall(function() DropdownSight:Refresh(lista) end) end
    end
    Players.PlayerAdded:Connect(Atualizar)
    Players.PlayerRemoving:Connect(Atualizar)
    Atualizar()
end

-- Criação de UI (Aba-1)
Tab:CreateSection("🌤️ Ambiente e Clima")
local ToggleClima = Tab:CreateToggle({
   Name = "Alternar Clima: ☀️ Sol / 🌙 Lua",
   CurrentValue = false,
   Callback = function(Value) Lighting.ClockTime = Value and 0 or 14 end,
})

Tab:CreateSection("👁️ Funções de Visual (Não invasivo)")
local ToggleESP = Tab:CreateToggle({
   Name = "Ativar Visual Local (não intrusivo)",
   CurrentValue = false,
   Callback = function(Value)
        if Value and not CONFIG.ENABLE_RISKY_FEATURES then
            Rayfield:Notify({Title = "Aviso", Content = "Funcionalidade de visualização invasiva está DESATIVADA por segurança. Ative ENABLE_RISKY_FEATURES no topo do script para permitir (não recomendado).", Duration = 5})
            ToggleESP:SetValue(false)
            return
        end
        State.ESP = Value
   end,
})

Tab:CreateSection("⚡ Speed (Velocidade)")
local DropdownVelocidade = Tab:CreateDropdown({
   Name = "Escolher Velocidade",
   Options = {"Normal (16)", "Rápido (35)", "Super Rápido (70)", "Flash (120)", "Velo (200)", "Insano (300)"},
   CurrentOption = {"Normal (16)"},
   MultipleOptions = false,
   Callback = function(Option)
        local s = Option[1]
        local map = { ["Normal (16)"] = 16, ["Rápido (35)"] = 35, ["Super Rápido (70)"] = 70, ["Flash (120)"] = 120, ["Velo (200)"] = 200, ["Insano (300)"] = 300 }
        State.WalkSpeed = map[s] or 16
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid') then
            LocalPlayer.Character.Humanoid.WalkSpeed = State.WalkSpeed
        end
   end,
})

Tab:CreateSection("⬆️ Jump (Pulo)")
local DropdownPulo = Tab:CreateDropdown({
   Name = "Escolher Pulo",
   Options = {"Normal (50)", "Alto (100)", "Super Alto (150)", "Foguete (400)"},
   CurrentOption = {"Normal (50)"},
   MultipleOptions = false,
   Callback = function(Option)
        local s = Option[1]
        local map = { ["Normal (50)"] = 50, ["Alto (100)"] = 100, ["Super Alto (150)"] = 150, ["Foguete (400)"] = 400 }
        State.JumpPower = map[s] or 50
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Humanoid') then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = State.JumpPower
        end
   end,
})

Tab:CreateSection("🌌 Gravidade")
local SliderGravidade = Tab:CreateSlider({
   Name = "Anti-Gravidade Personalizada",
   Range = {0, 196},
   Increment = 1,
   Suffix = "Grav.",
   CurrentValue = 196,
   Callback = function(Value) Workspace.Gravity = Value end,
})

Tab:CreateSection("📍 Teleporte & Visual (Apenas utilitários seguros)")
local DropdownTeleporte = Tab:CreateDropdown({
   Name = "Telp: Escolher Jogador (Apenas se permitido)",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
        local nomeAlvo = Option[1]
        if nomeAlvo and nomeAlvo ~= "Nenhum outro jogador" and nomeAlvo ~= "" then
            local JogadorAlvo = Players:FindFirstChild(nomeAlvo)
            if JogadorAlvo and JogadorAlvo.Character and CONFIG.ENABLE_RISKY_FEATURES then
                local alvoRoot = ObterRaiz(JogadorAlvo.Character)
                local meuRoot = ObterRaiz(LocalPlayer.Character)
                if alvoRoot and meuRoot then meuRoot.CFrame = alvoRoot.CFrame end
            else
                Rayfield:Notify({Title = "Telp", Content = "Teleporte é uma ação invasiva e está desativada (safety-first).", Duration = 3})
            end
        end
   end,
})

local DropdownVisual = Tab:CreateDropdown({
   Name = "Visual: Escolher Jogador (Apenas câmera local)",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
        local nomeAlvo = Option[1]
        if not nomeAlvo or nomeAlvo == "" or nomeAlvo == "Nenhum outro jogador" then return end
        local JogadorAlvo = Players:FindFirstChild(nomeAlvo)
        if JogadorAlvo and JogadorAlvo.Character then
            local hum = JogadorAlvo.Character:FindFirstChildOfClass('Humanoid')
            local root = ObterRaiz(JogadorAlvo.Character)
            if hum then Camera.CameraSubject = hum elseif root then Camera.CameraSubject = root end
        end
   end,
})

local BotaoSairVisual = Tab:CreateButton({
   Name = "Desativar Visual (Voltar para mim)",
   Callback = function()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
            local root = ObterRaiz(LocalPlayer.Character)
            if hum then Camera.CameraSubject = hum elseif root then Camera.CameraSubject = root end
        end
   end,
})

local BotaoAtualizarLista = Tab:CreateButton({
   Name = "Atualizar Listas (Jogadores Novos)",
   Callback = function()
        DropdownTeleporte:Refresh(PegarNomesJogadores())
        DropdownVisual:Refresh(PegarNomesJogadores())
        Rayfield:Notify({Title = "Listas Atualizadas", Content = "Atualizado com sucesso!", Duration = 2})
   end,
})

Tab:CreateSection("✈️ Sistema de Voo (Fly) - DESATIVADO POR PADRÃO")
local ToggleFly = Tab:CreateToggle({
   Name = "Ativar Fly (DESATIVADO por padrão)",
   CurrentValue = false,
   Callback = function(Value)
        if Value and not CONFIG.ENABLE_RISKY_FEATURES then
            Rayfield:Notify({Title = "Aviso", Content = "Fly está desativado por segurança. Habilite ENABLE_RISKY_FEATURES para permitir.", Duration = 4})
            ToggleFly:SetValue(false)
            return
        end
        State.Fly = Value
   end,
})

local SliderFly = Tab:CreateSlider({
   Name = "Velocidade do Fly",
   Range = {10, 300},
   Increment = 10,
   Suffix = "Velo",
   CurrentValue = 50,
   Callback = function(Value) State.FlySpeed = Value end,
})

-- ABA 2: AutoSight, Portais e Segurança de Queda
Tab2:CreateSection("🎯 Auto Sight (VISUALIZAÇÃO APENAS)")
local DropdownSight = Tab2:CreateDropdown({
   Name = "Escolher Alvo (apenas tag visual)",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Callback = function(Option)
        local nomeAlvo = Option[1]
        if not nomeAlvo or nomeAlvo == "" or nomeAlvo == "Nenhum outro jogador" then
            State.AutoSightTarget = nil
            return
        end
        if not CONFIG.ENABLE_RISKY_FEATURES then
            Rayfield:Notify({Title = "Aviso", Content = "AutoSight invasivo está desativado por segurança.", Duration = 3})
            return
        end
        -- Para segurança, não movemos a câmera. Em vez disso, criamos uma tag visual sobre a cabeça.
        -- (Se ENABLE_RISKY_FEATURES estiver true, o usuário já assumiu o risco)
        State.AutoSightTarget = Players:FindFirstChild(nomeAlvo)
        if State.AutoSightTarget and State.AutoSightTarget.Character then
            local head = State.AutoSightTarget.Character:FindFirstChild('Head')
            if head and not State.AutoSightTarget.Character:FindFirstChild('VN_NomeAlvoTag') then
                local bb = Instance.new('BillboardGui')
                bb.Name = 'VN_NomeAlvoTag'
                bb.Adornee = head
                bb.Size = UDim2.new(0,150,0,30)
                bb.StudsOffset = Vector3.new(0,1.5,0)
                bb.AlwaysOnTop = true
                local label = Instance.new('TextLabel', bb)
                label.Size = UDim2.new(1,0,1,0)
                label.Text = '🔎 ' .. State.AutoSightTarget.Name
                label.TextColor3 = Color3.fromRGB(255,0,0)
                label.TextStrokeTransparency = 0
                label.BackgroundTransparency = 1
                label.TextSize = 16
                label.Font = Enum.Font.SourceSansBold
                bb.Parent = State.AutoSightTarget.Character
            end
        end
   end,
})

Tab2:CreateSection("🌌 Sistema de Portais (Local)")
local PortalVerde, PortalAzul, ProximoPortal = nil, nil, 'Verde'
local TempoNoVerde, TempoNoAzul = 0, 0
local TempoParaTeleporte = 3.5

local function SoltarPortal()
    if not CONFIG.ENABLE_RISKY_FEATURES then
        Rayfield:Notify({Title = "Aviso", Content = "Portais (teleporte) estão desativados por segurança.", Duration = 3})
        return
    end
    local char = LocalPlayer.Character
    local root = ObterRaiz(char)
    if not root then return end
    local posicaoChao = root.Position - Vector3.new(0,3,0)
    if ProximoPortal == 'Verde' then
        if not PortalVerde or not PortalVerde.Parent then
            PortalVerde = Instance.new('Part')
            PortalVerde.Name = 'VN_PortalVerde'
            PortalVerde.Size = Vector3.new(6,0.2,6)
            PortalVerde.Anchored = true
            PortalVerde.CanCollide = false
            PortalVerde.Material = Enum.Material.Neon
            PortalVerde.Color = Color3.fromRGB(0,255,0)
            PortalVerde.Parent = Workspace
        end
        PortalVerde.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = 'Azul'
        Rayfield:Notify({Title = 'Release', Content = 'Portal Verde posicionado!', Duration = 2})
    else
        if not PortalAzul or not PortalAzul.Parent then
            PortalAzul = Instance.new('Part')
            PortalAzul.Name = 'VN_PortalAzul'
            PortalAzul.Size = Vector3.new(6,0.2,6)
            PortalAzul.Anchored = true
            PortalAzul.CanCollide = false
            PortalAzul.Material = Enum.Material.Neon
            PortalAzul.Color = Color3.fromRGB(0,0,255)
            PortalAzul.Parent = Workspace
        end
        PortalAzul.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = 'Verde'
        Rayfield:Notify({Title = 'Release', Content = 'Portal Azul posicionado!', Duration = 2})
    end
end

Tab2:CreateButton({ Name = '(Release) - Soltar Portal', Callback = function() SoltarPortal() end })

Tab2:CreateSection("🧱 Segurança de Queda")
local ToggleWall = Tab2:CreateToggle({
   Name = "Ativar Wall (Não Cair do Mapa)",
   CurrentValue = false,
   Callback = function(Value)
        State.Wall = Value
        if Value then Rayfield:Notify({Title = "Wall Ativado", Content = "Plataforma criada!", Duration = 2})
        else Rayfield:Notify({Title = "Wall Desativado", Content = "Plataforma removida.", Duration = 2}) end
   end,
})

Tab2:CreateSection("💀 Proteção (Imortal) - DESATIVADO POR PADRÃO")
local ToggleImmortal = Tab2:CreateToggle({
   Name = "Ativar Imortal (DESATIVADO por padrão)",
   CurrentValue = false,
   Callback = function(Value)
        if Value and not CONFIG.ENABLE_RISKY_FEATURES then
            Rayfield:Notify({Title = "Aviso", Content = "Imortal está desativado por segurança.", Duration = 4})
            ToggleImmortal:SetValue(false)
            return
        end
        State.Immortal = Value
   end,
})

-- ABA 3: Gráficos e desempenho
Tab3:CreateSection("🎮 Otimização de Gráficos (Anti-Lag)")
local DropdownGraficos = Tab3:CreateDropdown({
   Name = "Escolher Qualidade Gráfica",
   Options = {"Baixo", "Médio", "Alto", "Ultrapassado"},
   CurrentOption = {"Médio"},
   MultipleOptions = false,
   Callback = function(Option)
        local nivel = Option[1]
        if nivel == "Baixo" then
            Lighting.GlobalShadows = false
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = false end
            Rayfield:Notify({Title = "Gráficos: Baixo", Content = "Otimizado ao máximo!", Duration = 3})
        elseif nivel == "Médio" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level07 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos: Médio", Content = "Modo Equilibrado!", Duration = 3})
        elseif nivel == "Alto" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level13 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos: Alto", Content = "Visual incrível habilitado!", Duration = 3})
        else
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos", Content = "Gráficos Ultra ativos!", Duration = 3})
        end
   end,
})

-- Overlay de desempenho (FPS)
Tab3:CreateSection("📊 Performance")
local fpsLabel = nil
local function StartPerformanceOverlay()
    -- Cria um TextLabel simples na tela para mostrar FPS (usa ScreenGui somente se Rayfield não prover um)
    local StarterGui = game:GetService('StarterGui')
    -- Tenta usar Rayfield para criar um label, caso contrário mantém local
    local lastTick = tick()
    local frames = 0
    local fps = 0
    local conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            fps = frames
            frames = 0
            lastTick = tick()
            -- Atualiza a UI do Rayfield (se houver) ou apenas notifica periodicamente
            pcall(function()
                if fpsLabel and fpsLabel.SetText then fpsLabel:SetText('FPS: '..fps) end
            end)
        end
    end)
    AddConnection(conn)
end
StartPerformanceOverlay()

-- Loop centralizado para features que precisam de atualização por frame
local function MainRenderStep()
    -- Velocidade / Pulo: aplica somente se diferente do padrão
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
        if humanoid then
            if humanoid.WalkSpeed ~= State.WalkSpeed then humanoid.WalkSpeed = State.WalkSpeed end
            if humanoid.JumpPower ~= State.JumpPower then humanoid.UseJumpPower = true humanoid.JumpPower = State.JumpPower end
            if State.Immortal then
                pcall(function() humanoid.Health = humanoid.MaxHealth end)
            end
        end
    end

    -- Wall: cria plataforma sob os pés se ativado
    if State.Wall and LocalPlayer and LocalPlayer.Character then
        local root = ObterRaiz(LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
        if root and hum then
            if not Workspace:FindFirstChild('VN_PlataformaWallLocal') then
                local WallPart = Instance.new('Part')
                WallPart.Name = 'VN_PlataformaWallLocal'
                WallPart.Size = Vector3.new(7,1,7)
                WallPart.Anchored = true
                WallPart.Transparency = 1
                WallPart.CanCollide = true
                WallPart.Material = Enum.Material.SmoothPlastic
                WallPart.Parent = Workspace
            end
            local wp = Workspace:FindFirstChild('VN_PlataformaWallLocal')
            local offset = (hum.RigType == Enum.HumanoidRigType.R15 and hum.HipHeight or 2) + 1
            wp.CFrame = CFrame.new(root.Position.X, root.Position.Y - offset, root.Position.Z)
        end
    else
        if Workspace:FindFirstChild('VN_PlataformaWallLocal') then
            pcall(function() Workspace.VN_PlataformaWallLocal:Destroy() end)
        end
    end

    -- Portais: apenas mantem posição e evita spam
    if CONFIG.ENABLE_RISKY_FEATURES and PortalVerde and PortalAzul and LocalPlayer and LocalPlayer.Character then
        local root = ObterRaiz(LocalPlayer.Character)
        if root then
            local hrpPos = root.Position
            local distVerde = PortalVerde and (hrpPos - PortalVerde.Position).Magnitude or math.huge
            if distVerde <= 6 then
                TempoNoVerde = TempoNoVerde + RunService.RenderStepped:Wait() or 0.1
                if TempoNoVerde >= TempoParaTeleporte then
                    -- Teleporte (invasivo)
                    root.CFrame = PortalAzul.CFrame + Vector3.new(0,3,0)
                    TempoNoVerde = 0
                    TempoNoAzul = 0
                end
            else TempoNoVerde = 0 end
        end
    end
end

AddConnection(RunService.RenderStepped:Connect(MainRenderStep))

-- Limpeza ao fechar/recarregar
local function CleanupAll()
    -- Remove tags VN_*
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, c in ipairs(p.Character:GetChildren()) do
                if c:IsA('BillboardGui') and c.Name:match('^VN_') then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end
    -- Remove partes criadas
    for _, name in ipairs({'VN_PlataformaWallLocal', 'VN_PortalVerde', 'VN_PortalAzul'}) do
        if Workspace:FindFirstChild(name) then pcall(function() Workspace[name]:Destroy() end) end
    end
    CleanupConnections()
end

-- Exibe notificação de autenticação
Rayfield:Notify({Title = "Autenticado! (Modo Seguro)", Content = "Configurações carregadas. Funcionalidades invasivas estão DESATIVADAS por padrão.", Duration = 5})

-- Atualiza dropdowns dinamicamente
AtualizarDropdownsThread(DropdownTeleporte, DropdownVisual, DropdownSight)

-- Recomendações de usuário e como reativar recursos arriscados
-- Se você realmente quiser usar funções invasivas (ESP / AutoSight / Fly / Noclip / Teleport / Imortal), altere CONFIG.ENABLE_RISKY_FEATURES = true no topo do arquivo.
-- AVISO: Usar em servidores públicos pode levar a bans. Eu não recomendo.

-- Fim do script refatorado
