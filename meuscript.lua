-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------------------------------
-- SISTEMA DE TEMPO (40 MINUTOS) E AUTO-COPY LINK
-------------------------------------------------------------------------
local LinkDoSite = "https://vadiasnotopo.github.io/Chanel_1anonimo/"

-- Copia o link para a área de transferência do jogador automaticamente
pcall(function()
    setclipboard(LinkDoSite)
end)

local ArquivoTempo = "Tempo_Painel_Chanel.txt"
local NomeDoSaveRayfield = "MinhaChaveDiaria"
local TempoMaximo = 40 * 60 -- 40 minutos calculados em segundos
local PrecisaDeNovaKey = true
local TempoAgora = os.time()

-- Verifica se o jogador já tem o arquivo de tempo salvo
if isfile and isfile(ArquivoTempo) then
    local TempoSalvo = tonumber(readfile(ArquivoTempo))
    if TempoSalvo and (TempoAgora - TempoSalvo) <= TempoMaximo then
        -- Se o tempo atual menos o tempo salvo for menor que 40 min, ele passa direto!
        PrecisaDeNovaKey = false 
    end
end

-- Se for a primeira vez ou já tiver passado 40 minutos
if PrecisaDeNovaKey then
    pcall(function()
        -- Deleta a memória da key antiga no exploit do cara para forçar a tela de Key
        if isfile(NomeDoSaveRayfield) then delfile(NomeDoSaveRayfield) end
        if isfile(NomeDoSaveRayfield..".txt") then delfile(NomeDoSaveRayfield..".txt") end
        if isfile("Rayfield/Configuration/"..NomeDoSaveRayfield..".txt") then delfile("Rayfield/Configuration/"..NomeDoSaveRayfield..".txt") end
        
        -- Atualiza o arquivo de tempo para AGORA (reiniciando as portas por 40 min)
        writefile(ArquivoTempo, tostring(TempoAgora))
    end)
end

-------------------------------------------------------------------------
-- SISTEMA DE CHAVE DIÁRIA (Site)
-------------------------------------------------------------------------
local function PegarChaveDoDia()
    local data = os.date("!*t") 
    local dia = data.day
    local mes = data.month
    local ano = data.year
    return tostring("KEY-" .. (dia * 7) .. "X" .. (mes * 3) .. ano)
end

local ChaveCertaHoje = PegarChaveDoDia()

-------------------------------------------------------------------------
-- CRIAÇÃO DA JANELA COM O SISTEMA DE KEY ATIVADO
-------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional Unificado",
   LoadingTitle = "Verificando Acesso...",
   LoadingSubtitle = "Sistema de Proteção Ativo",
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "PainelConfig" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   
   -- CONFIGURAÇÕES DO TOKEN
   KeySystem = true, 
   KeySettings = {
      Title = "Acesso Limitado (40 Minutos)",
      Subtitle = "Link do site já foi copiado para você!",
      Note = "Pegue o token no site. Ele expira em 40 minutos após o uso.",
      FileName = NomeDoSaveRayfield, 
      SaveKey = true, -- Mantém True para ele não ter que colocar de novo dentro dos 40 min
      GrabKeyFromSite = true, 
      KeyLink = LinkDoSite, -- Adiciona o botão "Get Key" direto no painel também
      Key = {ChaveCertaHoje} 
   }
})

-- Cria as Abas
local Tab = Window:CreateTab("Aba-1", 4483362458) 
local Tab2 = Window:CreateTab("Aba-2 (Portais)", 4483362458) 
local Tab3 = Window:CreateTab("Aba-3 (Gráficos)", 4483362458) 

-------------------------------------------------------------------------
-- VARIÁVEIS GERAIS
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

local function ObterRaiz(char)
    if not char then return nil end
    if char.PrimaryPart then return char.PrimaryPart end
    if char:FindFirstChild("HumanoidRootPart") then return char.HumanoidRootPart end
    if char:FindFirstChild("Torso") then return char.Torso end
    if char:FindFirstChild("UpperTorso") then return char.UpperTorso end
    return char:FindFirstChildWhichIsA("BasePart")
end

-------------------------------------------------------------------------
-- SISTEMAS INTERNOS (ESP, MOVI, NOCLIP, WALL)
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

-- Movimentação
task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed ~= VelocidadeDesejada then humanoid.WalkSpeed = VelocidadeDesejada end
            if humanoid.JumpPower ~= PuloDesejado then humanoid.UseJumpPower = true humanoid.JumpPower = PuloDesejado end
        end
    end)
end)

-- Noclip
task.spawn(function()
    game:GetService("RunService").Stepped:Connect(function()
        if NoclipAtivado and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end)
end)

-- Wall
game:GetService("RunService").RenderStepped:Connect(function()
    if WallAtivado and LocalPlayer.Character then
        local root = ObterRaiz(LocalPlayer.Character)
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum then
            if not WallPart or not WallPart.Parent then
                WallPart = Instance.new("Part")
                WallPart.Size = Vector3.new(7, 1, 7); WallPart.Anchored = true; WallPart.Transparency = 1; WallPart.CanCollide = true; WallPart.Parent = Workspace
            end
            local offset = (hum.RigType == Enum.HumanoidRigType.R15 and hum.HipHeight or 2) + 1
            WallPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - offset, root.Position.Z)
        end
    else
        if WallPart then WallPart:Destroy() WallPart = nil end
    end
end)

-------------------------------------------------------------------------
-- PORTAIS
-------------------------------------------------------------------------
local PortalVerde, PortalAzul, ProximoPortal, TempoNoVerde, TempoNoAzul, TempoParaTeleporte = nil, nil, "Verde", 0, 0, 3.5

local function SoltarPortal()
    local root = ObterRaiz(LocalPlayer.Character)
    if not root then return end
    local pos = root.Position - Vector3.new(0, 3, 0)
    if ProximoPortal == "Verde" then
        if not PortalVerde then PortalVerde = Instance.new("Part", Workspace); PortalVerde.Size = Vector3.new(6, 0.2, 6); PortalVerde.Anchored = true; PortalVerde.Material = Enum.Material.Neon; PortalVerde.Color = Color3.fromRGB(0, 255, 0) end
        PortalVerde.CFrame = CFrame.new(pos); ProximoPortal = "Azul"; Rayfield:Notify({Title = "Portal", Content = "Verde posicionado!", Duration = 2})
    else
        if not PortalAzul then PortalAzul = Instance.new("Part", Workspace); PortalAzul.Size = Vector3.new(6, 0.2, 6); PortalAzul.Anchored = true; PortalAzul.Material = Enum.Material.Neon; PortalAzul.Color = Color3.fromRGB(0, 0, 255) end
        PortalAzul.CFrame = CFrame.new(pos); ProximoPortal = "Verde"; Rayfield:Notify({Title = "Portal", Content = "Azul posicionado!", Duration = 2})
    end
end

task.spawn(function()
    while task.wait(0.1) do 
        local root = ObterRaiz(LocalPlayer.Character)
        if root and PortalVerde and PortalAzul then
            if (root.Position - PortalVerde.Position).Magnitude <= 6 then TempoNoVerde += 0.1 if TempoNoVerde >= TempoParaTeleporte then root.CFrame = PortalAzul.CFrame + Vector3.new(0, 3, 0); TempoNoVerde = 0 end else TempoNoVerde = 0 end
            if (root.Position - PortalAzul.Position).Magnitude <= 6 then TempoNoAzul += 0.1 if TempoNoAzul >= TempoParaTeleporte then root.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0); TempoNoAzul = 0 end else TempoNoAzul = 0 end
        end
    end
end)

-------------------------------------------------------------------------
-- INTERFACE (ABAS)
-------------------------------------------------------------------------
Tab:CreateSection("🌤️ Ambiente")
Tab:CreateToggle({Name = "Modo Escuro (🌙/☀️)", Callback = function(v) Lighting.ClockTime = v and 0 or 14 end})

Tab:CreateSection("👁️ Funções")
Tab:CreateToggle({Name = "ESP", Callback = function(v) ESP_Ativado = v end})
Tab:CreateToggle({Name = "Noclip", Callback = function(v) NoclipAtivado = v end})

Tab:CreateSection("⚡ Speed / Pulo")
Tab:CreateDropdown({Name = "Velocidade", Options = {"16", "35", "70", "120", "200", "300", "500", "800"}, Callback = function(o) VelocidadeDesejada = tonumber(o[1]) end})
Tab:CreateDropdown({Name = "Pulo", Options = {"50", "100", "150", "200", "250", "400", "700"}, Callback = function(o) PuloDesejado = tonumber(o[1]) end})

Tab:CreateSection("🌌 Gravidade")
Tab:CreateSlider({Name = "Gravidade", Range = {0, 196}, CurrentValue = 196, Callback = function(v) Workspace.Gravity = v end})

Tab2:CreateButton({Name = "Soltar Portal", Callback = SoltarPortal})
Tab2:CreateToggle({Name = "Segurança de Queda (Wall)", Callback = function(v) WallAtivado = v end})

Tab3:CreateDropdown({Name = "Otimização Gráfica", Options = {"Baixo", "Médio", "Alto", "Ultrapassado"}, Callback = function(o)
    local n = o[1]
    settings().Rendering.QualityLevel = (n == "Baixo" and Enum.QualityLevel.Level01) or (n == "Médio" and Enum.QualityLevel.Level07) or (n == "Alto" and Enum.QualityLevel.Level13) or Enum.QualityLevel.Level21
    Rayfield:Notify({Title = "Gráficos", Content = "Aplicado: "..n, Duration = 2})
end})

Rayfield:Notify({Title = "Painel Pronto!", Content = "Todas as funções carregadas com sucesso.", Duration = 5})
