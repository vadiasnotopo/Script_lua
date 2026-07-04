-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------------------------------
-- SISTEMA DE TEMPO (24 HORAS) E AUTO-COPY LINK
-------------------------------------------------------------------------
local LinkDoSite = "https://vadiasnotopo.github.io/Chanel_1anonimo/"
local ArquivoTempo = "Tempo_Painel_Chanel.txt"
local NomeDoSaveRayfield = "MinhaChaveDiaria"
local TempoMaximo = 24 * 60 * 60 -- 24 horas em segundos (Sincronizado com o site)

-- Copia o link para o clipboard automaticamente
pcall(function() setclipboard(LinkDoSite) end)

if isfile and isfile(ArquivoTempo) then
    local TempoSalvo = tonumber(readfile(ArquivoTempo))
    local TempoAtual = os.time()
    
    if TempoAtual - TempoSalvo >= TempoMaximo then
        pcall(function()
            if isfile(NomeDoSaveRayfield..".txt") then delfile(NomeDoSaveRayfield..".txt") end
            writefile(ArquivoTempo, tostring(os.time()))
        end)
    end
else
    if writefile then writefile(ArquivoTempo, tostring(os.time())) end
end

-------------------------------------------------------------------------
-- SISTEMA DE CHAVE DIÁRIA (Sincronizado com a Web)
-------------------------------------------------------------------------
local function PegarChaveDoDia()
    local data = os.date("!*t") -- Usa o horário UTC (Universal) para bater certinho com o JS
    return tostring("KEY-" .. (data.day * 7) .. "X" .. (data.month * 3) .. data.year)
end

-------------------------------------------------------------------------
-- CRIAÇÃO DA JANELA PRINCIPAL
-------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional Unificado",
   LoadingTitle = "Carregando Scripts...",
   LoadingSubtitle = "Aguarde...",
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "PainelConfig" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   
   -- CONFIGURAÇÕES DA KEY ATIVADAS
   KeySystem = true, 
   KeySettings = {
      Title = "Acesso Premium (Passe de 24h)",
      Subtitle = "Link do gerador copiado para a área de transferência!",
      Note = "Cole o link no navegador e pegue sua Key.",
      FileName = NomeDoSaveRayfield, 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {PegarChaveDoDia()} 
   }
})

-- Cria as Abas
local Tab = Window:CreateTab("Aba-1", 4483362458) 
local Tab2 = Window:CreateTab("Aba-2 (Portais)", 4483362458) 
local Tab3 = Window:CreateTab("Aba-3 (Gráficos)", 4483362458) 

-------------------------------------------------------------------------
-- VARIÁVEIS E FUNÇÕES GERAIS
-------------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP_Ativado = false
local NoclipAtivado = false
local WallAtivado = false
local ImmortalAtivado = false
local FlyAtivado = false
local FlySpeed = 50
local WallPart = nil
local VelocidadeDesejada = 16
local PuloDesejado = 50 

local function ObterRaiz(char)
    if not char then return nil end
    if char.PrimaryPart then return char.PrimaryPart end
    if char:FindFirstChild("HumanoidRootPart") then return char.HumanoidRootPart end
    if char:FindFirstChild("Torso") then return char.Torso end
    if char:FindFirstChild("UpperTorso") then return char.UpperTorso end
    return char:FindFirstChildWhichIsA("BasePart")
end

local function PegarNomesJogadores()
    local nomes = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(nomes, player.Name) end
    end
    if #nomes == 0 then table.insert(nomes, "Nenhum outro jogador") end
    return nomes
end

-------------------------------------------------------------------------
-- SISTEMAS INTERNOS (ESP, MOVI, NOCLIP, WALL, IMORTAL, FLY)
-------------------------------------------------------------------------
-- ESP
task.spawn(function()
    while task.wait(1) do
        if ESP_Ativado then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not player.Character:FindFirstChild("MeuESP") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MeuESP"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
                        highlight.FillTransparency = 0.5
                        highlight.Parent = player.Character
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("MeuESP") then
                    player.Character.MeuESP:Destroy()
                end
            end
        end
    end
end)

-- Velocidade e Pulo
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if VelocidadeDesejada ~= 16 then humanoid.WalkSpeed = VelocidadeDesejada end
            if PuloDesejado ~= 50 then humanoid.UseJumpPower = true humanoid.JumpPower = PuloDesejado end
        end
    end)
end)

-- Noclip
task.spawn(function()
    RunService.Stepped:Connect(function()
        if NoclipAtivado and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
end)

-- Wall (Segurança de Queda)
RunService.RenderStepped:Connect(function()
    if WallAtivado and LocalPlayer.Character then
        local root = ObterRaiz(LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum then
            if not WallPart or not WallPart.Parent then
                WallPart = Instance.new("Part")
                WallPart.Size = Vector3.new(7, 1, 7)
                WallPart.Anchored = true
                WallPart.Transparency = 1 
                WallPart.CanCollide = true
                WallPart.Material = Enum.Material.SmoothPlastic
                WallPart.Parent = Workspace
                WallPart.Name = "PlataformaWallLocal"
            end
            local offset = (hum.RigType == Enum.HumanoidRigType.R15 and hum.HipHeight or 2) + 1
            WallPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - offset, root.Position.Z)
        end
    else
        if WallPart then WallPart:Destroy() WallPart = nil end
    end
end)

-- Sistema Imortal
RunService.Heartbeat:Connect(function()
    if ImmortalAtivado and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

-- Sistema de Fly
local BV, BG
RunService.RenderStepped:Connect(function()
    if FlyAtivado and LocalPlayer.Character and ObterRaiz(LocalPlayer.Character) then
        local root = ObterRaiz(LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if not BV then
            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.Parent = root
        end
        if not BG then
            BG = Instance.new("BodyGyro")
            BG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            BG.CFrame = Camera.CFrame
            BG.Parent = root
        end
        
        if hum then
            hum.PlatformStand = true
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                BV.Velocity = Camera.CFrame.LookVector * FlySpeed
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
        end
        BG.CFrame = Camera.CFrame
    else
        if BV then BV:Destroy() BV = nil end
        if BG then BG:Destroy() BG = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)

-------------------------------------------------------------------------
-- SISTEMA DE PORTAIS
-------------------------------------------------------------------------
local PortalVerde = nil
local PortalAzul = nil
local ProximoPortal = "Verde"
local TempoNoVerde = 0
local TempoNoAzul = 0
local TempoParaTeleporte = 3.5 

local function SoltarPortal()
    local char = LocalPlayer.Character
    local root = ObterRaiz(char)
    if not root then return end
    local posicaoChao = root.Position - Vector3.new(0, 3, 0)

    if ProximoPortal == "Verde" then
        if not PortalVerde then
            PortalVerde = Instance.new("Part")
            PortalVerde.Size = Vector3.new(6, 0.2, 6)
            PortalVerde.Anchored = true
            PortalVerde.CanCollide = false
            PortalVerde.Material = Enum.Material.Neon
            PortalVerde.Color = Color3.fromRGB(0, 255, 0)
            PortalVerde.Parent = Workspace
            PortalVerde.Name = "PortalVerdeLocal"
        end
        PortalVerde.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = "Azul"
        Rayfield:Notify({Title = "Release", Content = "Portal Verde posicionado!", Duration = 2})
    else
        if not PortalAzul then
            PortalAzul = Instance.new("Part")
            PortalAzul.Size = Vector3.new(6, 0.2, 6)
            PortalAzul.Anchored = true
            PortalAzul.CanCollide = false
            PortalAzul.Material = Enum.Material.Neon
            PortalAzul.Color = Color3.fromRGB(0, 0, 255)
            PortalAzul.Parent = Workspace
            PortalAzul.Name = "PortalAzulLocal"
        end
        PortalAzul.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = "Verde"
        Rayfield:Notify({Title = "Release", Content = "Portal Azul posicionado!", Duration = 2})
    end
end

task.spawn(function()
    while task.wait(0.1) do 
        local char = LocalPlayer.Character
        local root = ObterRaiz(char) 
        if root and PortalVerde and PortalAzul then
            local hrpPos = root.Position
            local distVerde = (hrpPos - PortalVerde.Position).Magnitude
            if distVerde <= 6 then 
                TempoNoVerde = TempoNoVerde + 0.1
                if TempoNoVerde >= TempoParaTeleporte then
                    root.CFrame = PortalAzul.CFrame + Vector3.new(0, 3, 0)
                    TempoNoVerde = 0
                    TempoNoAzul = 0
                    task.wait(0.5) 
                end
            else TempoNoVerde = 0 end
            
            local distAzul = (hrpPos - PortalAzul.Position).Magnitude
            if distAzul <= 6 then
                TempoNoAzul = TempoNoAzul + 0.1
                if TempoNoAzul >= TempoParaTeleporte then
                    root.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0)
                    TempoNoAzul = 0
                    TempoNoVerde = 0
                    task.wait(0.5)
                end
            else TempoNoAzul = 0 end
        end
    end
end)

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-1)
-------------------------------------------------------------------------
Tab:CreateSection("🌤️ Ambiente e Clima")
local ToggleClima = Tab:CreateToggle({
   Name = "Alternar Clima: ☀️ Sol / 🌙 Lua",
   CurrentValue = false,
   Flag = "ToggleClima", 
   Callback = function(Value)
        if Value then Lighting.ClockTime = 0 
        else Lighting.ClockTime = 14 end
   end,
})

Tab:CreateSection("👁️ Funções de ESP")
local ToggleESP = Tab:CreateToggle({
   Name = "Ativar ESP (Ver Jogadores)",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value) ESP_Ativado = Value end,
})

Tab:CreateSection("⚡ Speed (Velocidade)")
local DropdownVelocidade = Tab:CreateDropdown({
   Name = "Escolher Velocidade",
   Options = {"Normal (16)", "Rápido (35)", "Super Rápido (70)", "Flash (120)", "Velo (200)", "Velo (220)", "Velo (240)", "Insano (300)", "Extremo (500)", "Deus (800)"},
   CurrentOption = {"Normal (16)"},
   MultipleOptions = false,
   Flag = "DropdownVel", 
   Callback = function(Option)
        local s = Option[1]
        if s == "Normal (16)" then VelocidadeDesejada = 16
        elseif s == "Rápido (35)" then VelocidadeDesejada = 35
        elseif s == "Super Rápido (70)" then VelocidadeDesejada = 70
        elseif s == "Flash (120)" then VelocidadeDesejada = 120
        elseif s == "Velo (200)" then VelocidadeDesejada = 200
        elseif s == "Velo (220)" then VelocidadeDesejada = 220
        elseif s == "Velo (240)" then VelocidadeDesejada = 240
        elseif s == "Insano (300)" then VelocidadeDesejada = 300
        elseif s == "Extremo (500)" then VelocidadeDesejada = 500
        elseif s == "Deus (800)" then VelocidadeDesejada = 800 end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = VelocidadeDesejada
        end
   end,
})

Tab:CreateSection("⬆️ Jump (Pulo)")
local DropdownPulo = Tab:CreateDropdown({
   Name = "Escolher Pulo",
   Options = {"Normal (50)", "Alto (100)", "Super Alto (150)", "Médio-Forte (200)", "Gravidade Lunar (250)", "Foguete (400)", "Espacial (700)"},
   CurrentOption = {"Normal (50)"},
   MultipleOptions = false,
   Flag = "DropdownPulo", 
   Callback = function(Option)
        local s = Option[1]
        if s == "Normal (50)" then PuloDesejado = 50
        elseif s == "Alto (100)" then PuloDesejado = 100
        elseif s == "Super Alto (150)" then PuloDesejado = 150
        elseif s == "Médio-Forte (200)" then PuloDesejado = 200
        elseif s == "Gravidade Lunar (250)" then PuloDesejado = 250
        elseif s == "Foguete (400)" then PuloDesejado = 400
        elseif s == "Espacial (700)" then PuloDesejado = 700 end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = PuloDesejado
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
   Flag = "SliderGrav", 
   Callback = function(Value) Workspace.Gravity = Value end,
})

Tab:CreateSection("👻 Atravessar Parede (Noclip)")
local ToggleNoclip = Tab:CreateToggle({
   Name = "Ativar Noclip",
   CurrentValue = false,
   Flag = "ToggleNoclip", 
   Callback = function(Value) NoclipAtivado = Value end,
})

Tab:CreateSection("📍 Telp (Teleporte)")
local DropdownTeleporte = Tab:CreateDropdown({
   Name = "Telp: Escolher Jogador",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "DropdownTelp", 
   Callback = function(Option)
        local nomeAlvo = Option[1]
        if nomeAlvo and nomeAlvo ~= "Nenhum outro jogador" and nomeAlvo ~= "" then
            local JogadorAlvo = Players:FindFirstChild(nomeAlvo)
            if JogadorAlvo and JogadorAlvo.Character then
                local alvoRoot = ObterRaiz(JogadorAlvo.Character)
                local meuRoot = ObterRaiz(LocalPlayer.Character)
                if alvoRoot and meuRoot then meuRoot.CFrame = alvoRoot.CFrame end
            end
        end
   end,
})

Tab:CreateSection("🎥 Visual (Assistir Tela)")
local DropdownVisual = Tab:CreateDropdown({
   Name = "Visual: Escolher Jogador",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "DropdownVisual", 
   Callback = function(Option)
        local nomeAlvo = Option[1]
        if nomeAlvo and nomeAlvo ~= "Nenhum outro jogador" and nomeAlvo ~= "" then
            local JogadorAlvo = Players:FindFirstChild(nomeAlvo)
            if JogadorAlvo and JogadorAlvo.Character then
                local hum = JogadorAlvo.Character:FindFirstChild("Humanoid")
                local root = ObterRaiz(JogadorAlvo.Character)
                if hum then Camera.CameraSubject = hum
                elseif root then Camera.CameraSubject = root end
            end
        end
   end,
})

local BotaoSairVisual = Tab:CreateButton({
   Name = "Desativar Visual (Voltar para mim)",
   Callback = function()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = ObterRaiz(LocalPlayer.Character)
            if hum then Camera.CameraSubject = hum
            elseif root then Camera.CameraSubject = root end
        end
   end,
})

Tab:CreateSection("⚙️ Utilitários")
local BotaoAtualizarLista = Tab:CreateButton({
   Name = "Atualizar Listas (Jogadores Novos)",
   Callback = function()
        local novaLista = PegarNomesJogadores()
        DropdownTeleporte:Refresh(novaLista)
        DropdownVisual:Refresh(novaLista)
        Rayfield:Notify({Title = "Listas Atualizadas", Content = "Atualizado com sucesso!", Duration = 2})
   end,
})

Tab:CreateSection("✈️ Sistema de Voo (Fly)")
local ToggleFly = Tab:CreateToggle({
   Name = "Ativar Fly (Voo)",
   CurrentValue = false,
   Flag = "ToggleFly", 
   Callback = function(Value) FlyAtivado = Value end,
})

local SliderFly = Tab:CreateSlider({
   Name = "Velocidade do Fly",
   Range = {10, 300},
   Increment = 10,
   Suffix = "Velo",
   CurrentValue = 50,
   Flag = "SliderFly", 
   Callback = function(Value) FlySpeed = Value end,
})

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-2)
-------------------------------------------------------------------------
Tab2:CreateSection("🌌 Sistema de Portais (Apenas Você Vê)")
local BotaoRelease = Tab2:CreateButton({
   Name = "(Release) - Soltar Portal",
   Callback = function() SoltarPortal() end,
})

Tab2:CreateSection("🧱 Segurança de Queda")
local ToggleWall = Tab2:CreateToggle({
   Name = "Ativar Wall (Não Cair do Mapa)",
   CurrentValue = false,
   Flag = "ToggleWall",
   Callback = function(Value)
        WallAtivado = Value
        if Value then Rayfield:Notify({Title = "Wall Ativado", Content = "Plataforma criada!", Duration = 2})
        else Rayfield:Notify({Title = "Wall Desativado", Content = "Plataforma removida.", Duration = 2}) end
   end,
})

Tab2:CreateSection("💀 Proteção Divina")
local ToggleImmortal = Tab2:CreateToggle({
   Name = "Ativar Imortal",
   CurrentValue = false,
   Flag = "ToggleImmortal",
   Callback = function(Value)
        ImmortalAtivado = Value
        if Value then
            Rayfield:Notify({Title = "Proteção", Content = "Ativou imortal!", Duration = 3})
        else
            Rayfield:Notify({Title = "Proteção", Content = "Imortalidade desativada.", Duration = 3})
        end
   end,
})

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-3)
-------------------------------------------------------------------------
Tab3:CreateSection("🎮 Otimização de Gráficos (Anti-Lag)")
local DropdownGraficos = Tab3:CreateDropdown({
   Name = "Escolher Qualidade Gráfica",
   Options = {"Baixo", "Médio", "Alto", "Ultrapassado"},
   CurrentOption = {"Médio"},
   MultipleOptions = false,
   Flag = "DropdownGraficos",
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
        elseif nivel == "Ultrapassado" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos", Content = "Gráficos Ultra ativos!", Duration = 3})
        end
   end,
})

Rayfield:Notify({Title = "Autenticado!", Content = "Chave válida reconhecida.", Duration = 5})

