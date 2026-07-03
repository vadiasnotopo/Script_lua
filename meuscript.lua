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

-- Cria a Aba-1
local Tab = Window:CreateTab("Aba-1", 4483362458) 

-------------------------------------------------------------------------
-- VARIÁVEIS E FUNÇÕES GERAIS
-------------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ESP_Ativado = false
local VelocidadeDesejada = 16

-- Sistema de ESP (Ver jogadores)
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

-- Sistema para manter a Velocidade
task.spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if VelocidadeDesejada ~= 16 then
                LocalPlayer.Character.Humanoid.WalkSpeed = VelocidadeDesejada
            end
        end
    end)
end)

-- Função para pegar o nome dos jogadores no mapa
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
-- MENU DA INTERFACE (ABA-1)
-------------------------------------------------------------------------
Tab:CreateSection("Funções de ESP")

-- 1. Botão de Ligar/Desligar ESP
local ToggleESP = Tab:CreateToggle({
   Name = "Ativar ESP (Ver Jogadores)",
   CurrentValue = false,
   Flag = "ToggleESP", 
   Callback = function(Value)
        ESP_Ativado = Value
        if Value then
            Rayfield:Notify({Title = "ESP", Content = "Ativado!", Duration = 2, Image = 4483362458})
        else
            Rayfield:Notify({Title = "ESP", Content = "Desativado.", Duration = 2, Image = 4483362458})
        end
   end,
})

Tab:CreateSection("Movimentação")

-- 2. Escolher Velocidade
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

Tab:CreateSection("Telp (Teleporte)")

-- 3. Menu de Teleporte
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
                    Rayfield:Notify({Title = "Teleporte", Content = "Você foi até " .. nomeAlvo, Duration = 3, Image = 4483362458})
                end
            end
        end
   end,
})

Tab:CreateSection("Visual (Assistir Tela)")

-- 4. Menu de Visual / Spectate
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
                -- Muda o foco da sua câmera para o personagem do outro jogador
                Camera.CameraSubject = JogadorAlvo.Character.Humanoid
                Rayfield:Notify({Title = "Visual Ativado", Content = "Assistindo a tela de: " .. nomeAlvo, Duration = 3, Image = 4483362458})
            else
                Rayfield:Notify({Title = "Erro", Content = "Jogador não está vivo no momento.", Duration = 3})
            end
        end
   end,
})

-- 5. Botão para Sair do Visual
local BotaoSairVisual = Tab:CreateButton({
   Name = "Desativar Visual (Voltar para mim)",
   Callback = function()
        -- Retorna o foco da câmera para o SEU personagem
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
            Rayfield:Notify({Title = "Visual Desativado", Content = "A câmera voltou para você.", Duration = 3, Image = 4483362458})
        end
   end,
})

Tab:CreateSection("Utilitários")

-- 6. Botão para atualizar TODAS as listas
local BotaoAtualizarLista = Tab:CreateButton({
   Name = "Atualizar Listas (Jogadores Novos)",
   Callback = function()
        local novaLista = PegarNomesJogadores()
        DropdownTeleporte:Refresh(novaLista)
        DropdownVisual:Refresh(novaLista)
        Rayfield:Notify({Title = "Listas Atualizadas", Content = "As opções de Telp e Visual foram atualizadas!", Duration = 2})
   end,
})

-- Mensagem ao carregar
Rayfield:Notify({
    Title = "Painel Atualizado!",
    Content = "Visual e Botão de Sair carregados.",
    Duration = 5,
    Image = 4483362458,
})
