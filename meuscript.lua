-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cria a Janela Principal do Painel
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional",
   LoadingTitle = "Carregando Scripts...",
   LoadingSubtitle = "por Você",
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "PainelConfig" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   KeySystem = false,
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
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP_Ativado = false
local NoclipAtivado = false
local WallAtivado = false
local WallPart = nil
local VelocidadeDesejada = 16
local PuloDesejado = 50 

-- FUNÇÃO NOVA: Acha a peça principal do corpo, não importa se é humano ou animal
local function ObterRaiz(char)
    if not char then return nil end
    if char.PrimaryPart then return char.PrimaryPart end
    if char:FindFirstChild("HumanoidRootPart") then return char.HumanoidRootPart end
    if char:FindFirstChild("Torso") then return char.Torso end
    if char:FindFirstChild("UpperTorso") then return char.UpperTorso end
    return char:FindFirstChildWhichIsA("BasePart") -- Pega qualquer parte do corpo como último recurso
end

-- Sistema de ESP
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

-- Sistema de Movimentação (Velocidade e Pulo)
task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if VelocidadeDesejada ~= 16 then humanoid.WalkSpeed = VelocidadeDesejada end
            if PuloDesejado ~= 50 then humanoid.UseJumpPower = true humanoid.JumpPower = PuloDesejado end
        end
    end)
end)

-- Sistema de Noclip
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        if NoclipAtivado and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- Sistema de Wall (Plataforma Invisível embaixo do jogador)
game:GetService("RunService").RenderStepped:Connect(function()
    if WallAtivado and LocalPlayer.Character then
        local root = ObterRaiz(LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum then
            if not WallPart or not WallPart.Parent then
                WallPart = Instance.new("Part")
                WallPart.Size = Vector3.new(7, 1, 7)
                WallPart.Anchored = true
                WallPart.Transparency = 1 -- Totalmente invisível
                WallPart.CanCollide = true
                WallPart.Material = Enum.Material.SmoothPlastic
                WallPart.Parent = Workspace
                WallPart.Name = "PlataformaWallLocal"
            end
            -- Calcula a altura ideal abaixo dos pés baseando-se no tipo de corpo (R6 ou R15)
            local offset = (hum.RigType == Enum.HumanoidRigType.R15 and hum.HipHeight or 2) + 1
            WallPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - offset, root.Position.Z)
        end
    else
        if WallPart then
            WallPart:Destroy()
            WallPart = nil
        end
    end
end)

-- Pegar nomes
local function PegarNomesJogadores()
    local nomes = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(nomes, player.Name) end
    end
    if #nomes == 0 then table.insert(nomes, "Nenhum outro jogador") end
    return nomes
end

-------------------------------------------------------------------------
-- SISTEMA DE PORTAIS CORRIGIDO (ABA-2)
-------------------------------------------------------------------------
local PortalVerde = nil
local PortalAzul = nil
local ProximoPortal = "Verde"

local TempoNoVerde = 0
local TempoNoAzul = 0
local TempoParaTeleporte = 3.5 -- Alterado para 3.5 segundos conforme pedido

local function SoltarPortal()
    local char = LocalPlayer.Character
    local root = ObterRaiz(char) -- Usa o scanner inteligente
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

-- Scanner de distância (Radar)
task.spawn(function()
    while task.wait(0.1) do 
        local char = LocalPlayer.Character
        local root = ObterRaiz(char) -- Funciona mesmo em animais
        
        if root and PortalVerde and PortalAzul then
            local hrpPos = root.Position
            
            -- Distância pro Verde
            local distVerde = (hrpPos - PortalVerde.Position).Magnitude
            if distVerde <= 6 then 
                TempoNoVerde = TempoNoVerde + 0.1
                if TempoNoVerde >= TempoParaTeleporte then
                    root.CFrame = PortalAzul.CFrame + Vector3.new(0, 3, 0)
                    TempoNoVerde = 0
                    TempoNoAzul = 0
                    task.wait(0.5) 
                end
            else
                TempoNoVerde = 0 
            end
            
            -- Distância pro Azul
            local distAzul = (hrpPos - PortalAzul.Position).Magnitude
            if distAzul <= 6 then
                TempoNoAzul = TempoNoAzul + 0.1
                if TempoNoAzul >= TempoParaTeleporte then
                    root.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0)
                    TempoNoAzul = 0
                    TempoNoVerde = 0
                    task.wait(0.5)
                end
            else
                TempoNoAzul = 0
            end
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
        if Value then
            Lighting.ClockTime = 0 -- Fica Noite (Lua/Escuro)
            Rayfield:Notify({Title = "Clima", Content = "🌙 Modo Escuro ativado!", Duration = 2})
        else
            Lighting.ClockTime = 14 -- Fica Dia (Sol/Claro)
            Rayfield:Notify({Title = "Clima", Content = "☀️ Modo Claro ativado!", Duration = 2})
        end
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
   Range = {0, 196}, -- 196 é a gravidade normal
   Increment = 1,
   Suffix = "Grav.",
   CurrentValue = 196,
   Flag = "SliderGrav", 
   Callback = function(Value)
        Workspace.Gravity = Value
   end,
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
                if alvoRoot and meuRoot then
                    meuRoot.CFrame = alvoRoot.CFrame
                end
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
        if Value then
            Rayfield:Notify({Title = "Wall Ativado", Content = "Plataforma invisível criada sob você!", Duration = 2})
        else
            Rayfield:Notify({Title = "Wall Desativado", Content = "Plataforma invisível removida.", Duration = 2})
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
            -- Reduz tudo ao mínimo para o celular rodar liso sem travar
            Lighting.GlobalShadows = false
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = false end
            Rayfield:Notify({Title = "Gráficos: Baixo", Content = "Otimizado ao máximo! Jogo sem travamentos.", Duration = 3})
            
        elseif nivel == "Médio" then
            -- Gráfico balanceado, jogo bonito e desempenho bom
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level07 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos: Médio", Content = "Modo Equilibrado ativado com ótima performance!", Duration = 3})
            
        elseif nivel == "Alto" then
            -- Gráficos avançados mantendo estabilidade de FPS
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level13 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos: Alto", Content = "Visual incrível habilitado com boa taxa de FPS!", Duration = 3})
            
        elseif nivel == "Ultrapassado" then
            -- Gráficos no ultra com filtros inteligentes anti-lag ativos
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
            Rayfield:Notify({Title = "Gráficos: Ultrapassado", Content = "Gráficos Ultra ativos com FPS totalmente estável!", Duration = 3})
        end
   end,
})

-- Mensagem ao carregar
Rayfield:Notify({
    Title = "Painel Atualizado!",
    Content = "Portais ajustados para 3.5s, Wall adicionado e Nova Aba-3 de Gráficos liberada!",
    Duration = 5,
    Image = 4483362458,
})

