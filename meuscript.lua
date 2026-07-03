-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-------------------------------------------------------------------------
-- SISTEMA DE CHAVE DIÁRIA (Deve ser igual à fórmula do site)
-------------------------------------------------------------------------
local function PegarChaveDoDia()
    local data = os.date("!*t") -- Data UTC para sincronizar com o site
    local dia = data.day
    local mes = data.month
    local ano = data.year
    -- A matemática secreta: KEY-Dia*7-Mes*3-Ano
    return tostring("KEY-" .. (dia * 7) .. "X" .. (mes * 3) .. ano)
end

local ChaveCertaHoje = PegarChaveDoDia()

-------------------------------------------------------------------------
-- CRIAÇÃO DA JANELA COM O SISTEMA DE KEY ATIVADO
-------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional",
   LoadingTitle = "Verificando Acesso...",
   LoadingSubtitle = "Sistema de Proteção Ativo",
   ConfigurationSaving = { Enabled = false, FolderName = nil, FileName = "PainelConfig" },
   Discord = { Enabled = false, Invite = "noinvitelink", RememberJoins = true },
   
   -- CONFIGURAÇÕES DE SEGURANÇA
   KeySystem = true, 
   KeySettings = {
      Title = "Sistema de Acesso",
      Subtitle = "Resolva a tarefa no site para obter o Token",
      Note = "O Token muda todos os dias.",
      FileName = "MinhaKey",
      SaveKey = false, -- FALSE: Obriga a colocar a chave toda vez que abrir o jogo
      GrabKeyFromSite = false, 
      Key = {ChaveCertaHoje} -- O Script vai exigir exatamente a chave calculada hoje
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

-- Sistema de Movimentação
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

-- Sistema de Wall
game:GetService("RunService").RenderStepped:Connect(function()
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
                WallPart.Parent = Workspace
            end
            local offset = (hum.RigType == Enum.HumanoidRigType.R15 and hum.HipHeight or 2) + 1
            WallPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - offset, root.Position.Z)
        end
    else
        if WallPart then WallPart:Destroy() WallPart = nil end
    end
end)

local function PegarNomesJogadores()
    local nomes = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(nomes, player.Name) end
    end
    if #nomes == 0 then table.insert(nomes, "Nenhum outro jogador") end
    return nomes
end

-------------------------------------------------------------------------
-- PORTAIS
-------------------------------------------------------------------------
local PortalVerde, PortalAzul, ProximoPortal = nil, nil, "Verde"
local TempoNoVerde, TempoNoAzul, TempoParaTeleporte = 0, 0, 3.5

local function SoltarPortal()
    local char = LocalPlayer.Character
    local root = ObterRaiz(char)
    if not root then return end
    local posicaoChao = root.Position - Vector3.new(0, 3, 0)
    if ProximoPortal == "Verde" then
        if not PortalVerde then PortalVerde = Instance.new("Part", Workspace) PortalVerde.Size = Vector3.new(6, 0.2, 6) PortalVerde.Anchored = true PortalVerde.Material = Enum.Material.Neon PortalVerde.Color = Color3.fromRGB(0, 255, 0) end
        PortalVerde.CFrame = CFrame.new(posicaoChao) ProximoPortal = "Azul"
    else
        if not PortalAzul then PortalAzul = Instance.new("Part", Workspace) PortalAzul.Size = Vector3.new(6, 0.2, 6) PortalAzul.Anchored = true PortalAzul.Material = Enum.Material.Neon PortalAzul.Color = Color3.fromRGB(0, 0, 255) end
        PortalAzul.CFrame = CFrame.new(posicaoChao) ProximoPortal = "Verde"
    end
end

task.spawn(function()
    while task.wait(0.1) do 
        local char = LocalPlayer.Character
        local root = ObterRaiz(char)
        if root and PortalVerde and PortalAzul then
            local hrpPos = root.Position
            if (hrpPos - PortalVerde.Position).Magnitude <= 6 then TempoNoVerde = TempoNoVerde + 0.1 if TempoNoVerde >= TempoParaTeleporte then root.CFrame = PortalAzul.CFrame + Vector3.new(0, 3, 0) TempoNoVerde = 0 end else TempoNoVerde = 0 end
            if (hrpPos - PortalAzul.Position).Magnitude <= 6 then TempoNoAzul = TempoNoAzul + 0.1 if TempoNoAzul >= TempoParaTeleporte then root.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0) TempoNoAzul = 0 end else TempoNoAzul = 0 end
        end
    end
end)

-------------------------------------------------------------------------
-- UI (ABAS)
-------------------------------------------------------------------------
-- Aba 1
Tab:CreateToggle({Name = "Ativar ESP", Callback = function(v) ESP_Ativado = v end})
Tab:CreateDropdown({Name = "Escolher Velocidade", Options = {"Normal (16)", "Rápido (35)", "Insano (300)"}, Callback = function(o) VelocidadeDesejada = tonumber(o[1]:match("%d+")) end})
Tab:CreateToggle({Name = "Ativar Noclip", Callback = function(v) NoclipAtivado = v end})

-- Aba 2
Tab2:CreateButton({Name = "Soltar Portal", Callback = SoltarPortal})
Tab2:CreateToggle({Name = "Segurança de Queda (Wall)", Callback = function(v) WallAtivado = v end})

-- Aba 3
Tab3:CreateDropdown({
   Name = "Gráficos (Anti-Lag)",
   Options = {"Baixo", "Médio", "Alto"},
   Callback = function(Option)
        local n = Option[1]
        if n == "Baixo" then settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        elseif n == "Médio" then settings().Rendering.QualityLevel = Enum.QualityLevel.Level07
        elseif n == "Alto" then settings().Rendering.QualityLevel = Enum.QualityLevel.Level13 end
   end,
})

Rayfield:Notify({Title = "Painel Liberado!", Content = "Bem-vindo ao painel profissional.", Duration = 5})
