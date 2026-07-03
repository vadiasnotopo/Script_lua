-- Carrega a Biblioteca de UI Profissional (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cria a Janela Principal do Painel
local Window = Rayfield:CreateWindow({
   Name = "Painel Profissional",
   LoadingTitle = "Carregando Scripts...",
   LoadingSubtitle = "por Você",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "PainelConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true 
   },
   KeySystem = false,
})

-- Cria as Abas
local Tab = Window:CreateTab("Aba-1", 4483362458) 
local Tab2 = Window:CreateTab("Aba-2 (Portais)", 4483362458) 

-------------------------------------------------------------------------
-- VARIÁVEIS E FUNÇÕES GERAIS (ABA-1)
-------------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP_Ativado = false
local NoclipAtivado = false
local VelocidadeDesejada = 16
local PuloDesejado = 50 

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
            
            if VelocidadeDesejada ~= 16 then
                humanoid.WalkSpeed = VelocidadeDesejada
            end
            
            if PuloDesejado ~= 50 then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = PuloDesejado
            end
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

-- Pegar nomes
local function PegarNomesJogadores()
    local nomes = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(nomes, player.Name)
        end
    end
    if #nomes == 0 then
        table.insert(nomes, "Nenhum outro jogador")
    end
    return nomes
end

-------------------------------------------------------------------------
-- SISTEMA DE PORTAIS (ABA-2)
-------------------------------------------------------------------------
local PortalVerde = nil
local PortalAzul = nil
local ProximoPortal = "Verde"
local EmCooldownTeleporte = false -- Evita loop infinito de teleporte

local function SoltarPortal()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Pega a posição do jogador e joga um pouco para baixo (para ficar no chão)
    local posicaoChao = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)

    if ProximoPortal == "Verde" then
        if not PortalVerde then
            -- Cria o bloco Verde se não existir
            PortalVerde = Instance.new("Part")
            PortalVerde.Size = Vector3.new(6, 0.2, 6) -- Grandinho e achatado
            PortalVerde.Anchored = true
            PortalVerde.CanCollide = false
            PortalVerde.Material = Enum.Material.Neon
            PortalVerde.Color = Color3.fromRGB(0, 255, 0)
            PortalVerde.Parent = Workspace
            PortalVerde.Name = "PortalVerdeLocal"

            -- Sistema de pisar e teleportar
            PortalVerde.Touched:Connect(function(hit)
                if hit.Parent == char and PortalAzul and not EmCooldownTeleporte then
                    EmCooldownTeleporte = true
                    char.HumanoidRootPart.CFrame = PortalAzul.CFrame + Vector3.new(0, 3, 0)
                    Rayfield:Notify({Title = "Portal", Content = "Teleportado para o Azul!", Duration = 1})
                    task.wait(1.5) -- Tempo de recarga
                    EmCooldownTeleporte = false
                end
            end)
        end
        -- Move o portal verde para o jogador
        PortalVerde.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = "Azul"
        Rayfield:Notify({Title = "Release", Content = "Portal Verde posicionado!", Duration = 2})

    else
        if not PortalAzul then
            -- Cria o bloco Azul se não existir
            PortalAzul = Instance.new("Part")
            PortalAzul.Size = Vector3.new(6, 0.2, 6)
            PortalAzul.Anchored = true
            PortalAzul.CanCollide = false
            PortalAzul.Material = Enum.Material.Neon
            PortalAzul.Color = Color3.fromRGB(0, 0, 255)
            PortalAzul.Parent = Workspace
            PortalAzul.Name = "PortalAzulLocal"

            -- Sistema de pisar e teleportar
            PortalAzul.Touched:Connect(function(hit)
                if hit.Parent == char and PortalVerde and not EmCooldownTeleporte then
                    EmCooldownTeleporte = true
                    char.HumanoidRootPart.CFrame = PortalVerde.CFrame + Vector3.new(0, 3, 0)
                    Rayfield:Notify({Title = "Portal", Content = "Teleportado para o Verde!", Duration = 1})
                    task.wait(1.5) -- Tempo de recarga
                    EmCooldownTeleporte = false
                end
            end)
        end
        -- Move o portal azul para o jogador
        PortalAzul.CFrame = CFrame.new(posicaoChao)
        ProximoPortal = "Verde"
        Rayfield:Notify({Title = "Release", Content = "Portal Azul posicionado!", Duration = 2})
    end
end

-------------------------------------------------------------------------
-- MENU DA INTERFACE (ABA-1)
-------------------------------------------------------------------------
Tab:CreateSection("👁️ Funções de ESP")

local ToggleESP = Tab:CreateToggle({
   Name = "Ativar ESP (Ver Jogadores)",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value)
        ESP_Ativado = Value
   end,
})

Tab:CreateSection("⚡ Speed (Velocidade)")

local DropdownVelocidade = Tab:CreateDropdown({
   Name = "Escolher Velocidade",
   Options = {"Normal (16)", "Rápido (35)", "Super Rápido (70)", "Flash (120)", "Velo (200)", "Velo (220)", "Velo (240)", "Insano (300)"},
   CurrentOption = {"Normal (16)"},
   MultipleOptions = false,
   Flag = "DropdownVel", 
   Callback = function(Option)
        local selecionado = Option[1]
        if selecionado == "Normal (16)" then VelocidadeDesejada = 16
        elseif selecionado == "Rápido (35)" then VelocidadeDesejada = 35
        elseif selecionado == "Super Rápido (70)" then VelocidadeDesejada = 70
        elseif selecionado == "Flash (120)" then VelocidadeDesejada = 120
        elseif selecionado == "Velo (200)" then VelocidadeDesejada = 200
        elseif selecionado == "Velo (220)" then VelocidadeDesejada = 220
        elseif selecionado == "Velo (240)" then VelocidadeDesejada = 240
        elseif selecionado == "Insano (300)" then VelocidadeDesejada = 300
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = VelocidadeDesejada
        end
   end,
})

Tab:CreateSection("⬆️ Jump (Pulo)")

local DropdownPulo = Tab:CreateDropdown({
   Name = "Escolher Pulo",
   Options = {"Normal (50)", "Alto (100)", "Super Alto (150)", "Gravidade Lunar (250)", "Foguete (400)"},
   CurrentOption = {"Normal (50)"},
   MultipleOptions = false,
   Flag = "DropdownPulo", 
   Callback = function(Option)
        local selecionado = Option[1]
        if selecionado == "Normal (50)" then PuloDesejado = 50
        elseif selecionado == "Alto (100)" then PuloDesejado = 100
        elseif selecionado == "Super Alto (150)" then PuloDesejado = 150
        elseif selecionado == "Gravidade Lunar (250)" then PuloDesejado = 250
        elseif selecionado == "Foguete (400)" then PuloDesejado = 400
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = PuloDesejado
        end
   end,
})

Tab:CreateSection("👻 Atravessar Parede (Noclip)")

local ToggleNoclip = Tab:CreateToggle({
   Name = "Ativar Noclip",
   CurrentValue = false,
   Flag = "ToggleNoclip", 
   Callback = function(Value)
        NoclipAtivado = Value
   end,
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
            if JogadorAlvo and JogadorAlvo.Character and JogadorAlvo.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = JogadorAlvo.Character.HumanoidRootPart.CFrame
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
            if JogadorAlvo and JogadorAlvo.Character and JogadorAlvo.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = JogadorAlvo.Character.Humanoid
            end
        end
   end,
})

local BotaoSairVisual = Tab:CreateButton({
   Name = "Desativar Visual (Voltar para mim)",
   Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
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
   Callback = function()
        SoltarPortal()
   end,
})

-- Mensagem ao carregar
Rayfield:Notify({
    Title = "Painel Atualizado!",
    Content = "Aba-2 e Portais Pessoais carregados.",
    Duration = 5,
    Image = 4483362458,
})

