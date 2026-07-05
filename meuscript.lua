-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------------------------------
-- SISTEMA DE TEMPO (24 HORAS) E AUTO-COPY LINK
-------------------------------------------------------------------------
local LinkDoSite = "https://vadiasnotopo.github.io/Chanel_1anonimo/"
local ArquivoTempo = "Tempo_Painel_Chanel.txt"
local NomeDoSaveRayfield = "MinhaChaveDiaria"
local TempoMaximo = 24 * 60 * 60

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

local function PegarChaveDoDia()
    local data = os.date("!*t")
    return tostring("KEY-" .. (data.day * 7) .. "X" .. (data.month * 3) .. data.year)
end

-------------------------------------------------------------------------
-- CRIAÇÃO DA JANELA PRINCIPAL
-------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional Unificado",
   LoadingTitle = "Carregando Scripts...",
   LoadingSubtitle = "Aguarde...",
   ConfigurationSaving = { 
       Enabled = true, 
       FolderName = "MeuPainelConfig", 
       FileName = "SavePrincipal" 
   },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   
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
local Tab2 = Window:CreateTab("Aba-2 (Portais e Mira)", 4483362458) 
local Tab3 = Window:CreateTab("Aba-3 (Gráficos)", 4483362458) 

-------------------------------------------------------------------------
-- VARIÁVEIS, PRE-DECLARAÇÃO DA UI E FUNÇÕES GERAIS
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
local InvisibleAtivado = false
local FlySpeed = 50
local WallPart = nil
local VelocidadeDesejada = 16
local PuloDesejado = 50 

local AutoSightTarget = nil 

-- PRÉ-DECLARAÇÃO DAS VARIÁVEIS DA INTERFACE (Necessário para o botão Reset funcionar visualmente)
local ToggleClima, ToggleESP, DropdownVelocidade, DropdownPulo, SliderGravidade
local ToggleNoclip, DropdownTeleporte, DropdownVisual, ToggleFly, SliderFly, ToggleInvisivel
local DropdownSight, ToggleWall, ToggleImmortal, DropdownGraficos

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
-- SISTEMAS INTERNOS MELHORADOS (ESTRATÉGIA OTIMIZADA)
-------------------------------------------------------------------------

-- Auto Sight (Melhorado: Mais suave e não foca em jogadores mortos)
RunService.RenderStepped:Connect(function()
    if AutoSightTarget and AutoSightTarget.Character and AutoSightTarget.Character:FindFirstChild("HumanoidRootPart") then
        local hum = AutoSightTarget.Character:FindFirstChild("Humanoid")
        -- Estratégia nova: Só mira se o jogador estiver vivo
        if hum and hum.Health > 0 then
            local targetPart = AutoSightTarget.Character.HumanoidRootPart
            local targetVel = targetPart.AssemblyLinearVelocity
            local previsaoPos = targetPart.Position + (targetVel * 0.05) 
            local objetivoCFrame = CFrame.lookAt(Camera.CFrame.Position, previsaoPos)
            -- Lerp dinâmico para cravar suavemente
            Camera.CFrame = Camera.CFrame:Lerp(objetivoCFrame, 0.5)
        end
    end
end)

-- Invisibilidade (Melhorado: Previne o "bloco" cinza e remove campos de força visualmente)
RunService.RenderStepped:Connect(function()
    if InvisibleAtivado and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                if v.Name ~= "NomeAlvoTag" then v.Enabled = false end
            elseif v:IsA("ForceField") then
                v.Visible = false
            end
        end
    end
end)

-- ESP (Melhorado: Limpeza automática inteligente e ignora mortos)
task.spawn(function()
    while task.wait(1) do
        if ESP_Ativado then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
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

-- Velocidade e Pulo (Gatilho contínuo de segurança)
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if VelocidadeDesejada ~= 16 then humanoid.WalkSpeed = VelocidadeDesejada end
            if PuloDesejado ~= 50 then humanoid.UseJumpPower = true humanoid.JumpPower = PuloDesejado end
        end
    end)
end)

-- Noclip (Melhorado: Evita conflito com partes que já não tem colisão)
task.spawn(function()
    RunService.Stepped:Connect(function()
        if NoclipAtivado and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then 
                    part.CanCollide = false 
                end
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

-- Sistema Imortal (Melhorado: Não buga se o personagem morrer por insta-kill do mapa)
RunService.Heartbeat:Connect(function()
    if ImmortalAtivado and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end
end)

-- Sistema de Fly (Melhorado: Desliga corretamente os motores se desativado)
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

-- SISTEMA DE PORTAIS
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
            PortalVerde.Anchored = true; PortalVerde.CanCollide = false
            PortalVerde.Material = Enum.Material.Neon; PortalVerde.Color = Color3.fromRGB(0, 255, 0)
            PortalVerde.Parent = Workspace; PortalVerde.Name = "PortalVerdeLocal"
        end
        PortalVerde.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = "Azul"
        Rayfield:Notify({Title = "Release", Content = "Portal Verde posicionado!", Duration = 2})
    else
        if not PortalAzul then
            PortalAzul = Instance.new("Part")
            PortalAzul.Size = Vector3.new(6, 0.2, 6)
            PortalAzul.Anchored = true; PortalAzul.CanCollide = false
            PortalAzul.Material = Enum.Material.Neon; PortalAzul.Color = Color3.fromRGB(0, 0, 255)
            PortalAzul.Parent = Workspace; PortalAzul.Name = "PortalAzulLocal"
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
                    TempoNoVerde = 0; TempoNoAzul = 0; task.wait(0.5) 
                end
            else TempoNoVerde = 0 end
            
            local distAzul = (hrpPos - PortalAzul.Position).Magnitude
            if distAzul <= 6 then
                TempoNoAzul = TempoNoAzul + 0.1
                if TempoNoAzul >= TempoParaTeleporte then
                    root.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0)
                    TempoNoAzul = 0; TempoNoVerde = 0; task.wait(0.5)
                end
            else TempoNoAzul = 0 end
        end
    end
end)

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-1)
-------------------------------------------------------------------------

Tab:CreateSection("🔄 Resetar Tudo")
local BotaoReset = Tab:CreateButton({
   Name = "🚨 Restaurar Padrões (Desativar Tudo da Interface)",
   Callback = function()
        -- 1. Reseta o Backend
        ESP_Ativado = false; NoclipAtivado = false; WallAtivado = false
        ImmortalAtivado = false; FlyAtivado = false; InvisibleAtivado = false
        VelocidadeDesejada = 16; PuloDesejado = 50; FlySpeed = 50
        
        -- 2. Limpa a Mira Automática
        if AutoSightTarget and AutoSightTarget.Character and AutoSightTarget.Character:FindFirstChild("NomeAlvoTag") then
            AutoSightTarget.Character.NomeAlvoTag:Destroy()
        end
        AutoSightTarget = nil
        
        -- 3. Atualiza a Interface (Empurra as setinhas para a esquerda "Desativado")
        pcall(function()
            if ToggleClima then ToggleClima:Set(false) end
            if ToggleESP then ToggleESP:Set(false) end
            if ToggleNoclip then ToggleNoclip:Set(false) end
            if ToggleFly then ToggleFly:Set(false) end
            if ToggleInvisivel then ToggleInvisivel:Set(false) end
            if ToggleWall then ToggleWall:Set(false) end
            if ToggleImmortal then ToggleImmortal:Set(false) end
            
            if DropdownVelocidade then DropdownVelocidade:Set({"Normal (16)"}) end
            if DropdownPulo then DropdownPulo:Set({"Normal (50)"}) end
            if SliderGravidade then SliderGravidade:Set(196) end
            if SliderFly then SliderFly:Set(50) end
            if DropdownSight then DropdownSight:Set({""}) end
            if DropdownGraficos then DropdownGraficos:Set({"Médio"}) end
        end)
        
        -- 4. Reseta os atributos do personagem
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 16
                hum.UseJumpPower = true
                hum.JumpPower = 50
                hum.PlatformStand = false
            end
            
            -- FIX DO BLOCO: Restaura a visibilidade sem revelar o HumanoidRootPart!
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                    if v.Name == "HumanoidRootPart" then 
                        v.Transparency = 1 -- Isso impede o bloco cinza de aparecer!
                    else 
                        v.Transparency = 0 
                    end
                elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                    v.Enabled = true
                end
            end
        end
        
        Workspace.Gravity = 196
        Lighting.ClockTime = 14
        if WallPart then WallPart:Destroy() WallPart = nil end
        if BV then BV:Destroy() BV = nil end
        if BG then BG:Destroy() BG = nil end
        
        Rayfield:Notify({Title = "Resetado", Content = "Interface e Scripts restaurados!", Duration = 3})
   end,
})

Tab:CreateSection("🌤️ Ambiente e Clima")
ToggleClima = Tab:CreateToggle({
   Name = "Alternar Clima: ☀️ Sol / 🌙 Lua",
   CurrentValue = false,
   Flag = "ToggleClima", 
   Callback = function(Value)
        if Value then Lighting.ClockTime = 0 
        else Lighting.ClockTime = 14 end
   end,
})

Tab:CreateSection("👁️ Funções de ESP")
ToggleESP = Tab:CreateToggle({
   Name = "Ativar ESP (Ver Jogadores)",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value) ESP_Ativado = Value end,
})

Tab:CreateSection("⚡ Speed (Velocidade)")
DropdownVelocidade = Tab:CreateDropdown({
   Name = "Escolher Velocidade",
   Options = {"Normal (16)", "Rápido (35)", "Super Rápido (70)", "Flash (120)", "Velo (200)", "Insano (300)", "Extremo (500)", "Deus (800)"},
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
        elseif s == "Insano (300)" then VelocidadeDesejada = 300
        elseif s == "Extremo (500)" then VelocidadeDesejada = 500
        elseif s == "Deus (800)" then VelocidadeDesejada = 800 end
   end,
})

Tab:CreateSection("⬆️ Jump (Pulo)")
DropdownPulo = Tab:CreateDropdown({
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
   end,
})

Tab:CreateSection("🌌 Gravidade")
SliderGravidade = Tab:CreateSlider({
   Name = "Anti-Gravidade Personalizada",
   Range = {0, 196},
   Increment = 1,
   Suffix = "Grav.",
   CurrentValue = 196,
   Flag = "SliderGrav", 
   Callback = function(Value) Workspace.Gravity = Value end,
})

Tab:CreateSection("👻 Atravessar Parede (Noclip)")
ToggleNoclip = Tab:CreateToggle({
   Name = "Ativar Noclip",
   CurrentValue = false,
   Flag = "ToggleNoclip", 
   Callback = function(Value) NoclipAtivado = Value end,
})

Tab:CreateSection("📍 Telp (Teleporte)")
DropdownTeleporte = Tab:CreateDropdown({
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
DropdownVisual = Tab:CreateDropdown({
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
        if DropdownTeleporte then DropdownTeleporte:Refresh(novaLista) end
        if DropdownVisual then DropdownVisual:Refresh(novaLista) end
        if DropdownSight then DropdownSight:Refresh(novaLista) end
        Rayfield:Notify({Title = "Listas Atualizadas", Content = "Atualizado com sucesso!", Duration = 2})
   end,
})

Tab:CreateSection("✈️ Sistema de Voo (Fly)")
ToggleFly = Tab:CreateToggle({
   Name = "Ativar Fly (Voo)",
   CurrentValue = false,
   Flag = "ToggleFly", 
   Callback = function(Value) FlyAtivado = Value end,
})

SliderFly = Tab:CreateSlider({
   Name = "Velocidade do Fly",
   Range = {10, 300},
   Increment = 10,
   Suffix = "Velo",
   CurrentValue = 50,
   Flag = "SliderFly", 
   Callback = function(Value) FlySpeed = Value end,
})

Tab:CreateSection("🕵️ Invisibilidade")
ToggleInvisivel = Tab:CreateToggle({
   Name = "Ficar Invisível",
   CurrentValue = false,
   Flag = "ToggleInvisivel", 
   Callback = function(Value)
        InvisibleAtivado = Value
        if not Value and LocalPlayer.Character then
            -- Restaura SEM revelar o HumanoidRootPart (Adeus bloco cinza!)
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
                    if v.Name == "HumanoidRootPart" then v.Transparency = 1 else v.Transparency = 0 end
                elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                    v.Enabled = true
                end
            end
            Rayfield:Notify({Title = "Invisibilidade", Content = "Você voltou a ser visível.", Duration = 2})
        else
            Rayfield:Notify({Title = "Invisibilidade", Content = "Você está invisível agora.", Duration = 2})
        end
   end,
})

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-2)
-------------------------------------------------------------------------

Tab2:CreateSection("🎯 Auto Sight (Mira Automática Avançada)")
DropdownSight = Tab2:CreateDropdown({
   Name = "Escolher Alvo (Smooth Aim & Predict)",
   Options = PegarNomesJogadores(),
   CurrentOption = {""},
   MultipleOptions = false,
   Flag = "DropdownSight",
   Callback = function(Option)
        local nomeAlvo = Option[1]
        
        if not nomeAlvo or nomeAlvo == "" or nomeAlvo == "Nenhum outro jogador" then 
            AutoSightTarget = nil 
            return 
        end

        if AutoSightTarget and AutoSightTarget.Name == nomeAlvo then
            if AutoSightTarget.Character and AutoSightTarget.Character:FindFirstChild("NomeAlvoTag") then
                AutoSightTarget.Character.NomeAlvoTag:Destroy()
            end
            AutoSightTarget = nil
            Rayfield:Notify({Title = "Auto Sight", Content = "Mira desativada.", Duration = 2})
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("NomeAlvoTag") then
                    player.Character.NomeAlvoTag:Destroy()
                end
            end

            AutoSightTarget = Players:FindFirstChild(nomeAlvo)
            
            if AutoSightTarget and AutoSightTarget.Character then
                local bb = Instance.new("BillboardGui")
                bb.Name = "NomeAlvoTag"
                bb.Adornee = AutoSightTarget.Character:FindFirstChild("Head") or AutoSightTarget.Character:FindFirstChild("HumanoidRootPart")
                bb.Size = UDim2.new(0, 150, 0, 30) 
                bb.StudsOffset = Vector3.new(0, 1.5, 0) 
                bb.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel", bb)
                label.Size = UDim2.new(1,0,1,0)
                label.Text = "🎯 " .. AutoSightTarget.Name
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.TextStrokeTransparency = 0
                label.BackgroundTransparency = 1
                label.TextScaled = false
                label.TextSize = 16 
                label.Font = Enum.Font.SourceSansBold
                
                bb.Parent = AutoSightTarget.Character
                Rayfield:Notify({Title = "Auto Sight", Content = "Travado em: " .. nomeAlvo, Duration = 2})
            end
        end
   end,
})

local BotaoDesativarMira = Tab2:CreateButton({
   Name = "❌ Desativar Mira Automática",
   Callback = function()
        if AutoSightTarget and AutoSightTarget.Character and AutoSightTarget.Character:FindFirstChild("NomeAlvoTag") then
            AutoSightTarget.Character.NomeAlvoTag:Destroy()
        end
        AutoSightTarget = nil
        if DropdownSight then DropdownSight:Set({""}) end
        Rayfield:Notify({Title = "Auto Sight", Content = "Mira desativada com sucesso.", Duration = 2})
   end,
})

local BotaoAtualizarSight = Tab2:CreateButton({
   Name = "🔄 Atualizar Lista de Jogadores",
   Callback = function()
        if DropdownSight then 
            DropdownSight:Refresh(PegarNomesJogadores()) 
            Rayfield:Notify({Title = "Lista Atualizada", Content = "Novos jogadores carregados!", Duration = 2})
        end
   end,
})

Tab2:CreateSection("🌌 Sistema de Portais (Apenas Você Vê)")
local BotaoRelease = Tab2:CreateButton({
   Name = "(Release) - Soltar Portal",
   Callback = function() SoltarPortal() end,
})

Tab2:CreateSection("🧱 Segurança de Queda")
ToggleWall = Tab2:CreateToggle({
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
ToggleImmortal = Tab2:CreateToggle({
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
DropdownGraficos = Tab3:CreateDropdown({
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
        elseif nivel == "Médio" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level07 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
        elseif nivel == "Alto" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level13 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
        elseif nivel == "Ultrapassado" then
            Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
            if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.Decoration = true end
        end
   end,
})

Rayfield:Notify({Title = "Autenticado!", Content = "Chave válida reconhecida.", Duration = 5})

-------------------------------------------------------------------------
-- CARREGA AS CONFIGURAÇÕES SALVAS AUTOMATICAMENTE
-------------------------------------------------------------------------
Rayfield:LoadConfiguration()
