-- [[ NETKING BYPASS & PHASE ARENA TELEPORT UTILITY (2026) ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 1. ADVANCED ANTI-KICK BYPASS (Metatable Hook Method)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "Kick" or method == "kick") then
        -- Suppress local termination request; return fallback state safely
        return nil
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- 2. AUTOMATIC ANTI-TELEBACK SPEED BYPASS (Stable at Speed >= 55)
local maxAllowedSpeed = 65
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            hum.WalkSpeed = maxAllowedSpeed
            -- Hook network root properties dynamically to trick regional verification modules
            if root:Velocity().Magnitude > 50 then
                local currentVelocity = root.Velocity
                root.Velocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
            end
        end
    end
end)

-- 3. SERVER-VIEW PHASE ARENA TELEPORT INTERFACE
local UtilityGui = Instance.new("ScreenGui", CoreGui)
UtilityGui.Name = "ArenaPhaseUtility"

local PhaseToggle = Instance.new("TextButton", UtilityGui)
PhaseToggle.Size = UDim2.new(0, 150, 0, 45)
PhaseToggle.Position = UDim2.new(0.02, 0, 0.85, 0)
PhaseToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
PhaseToggle.Text = "PHASE TELEPORT: OFF"
PhaseToggle.TextColor3 = Color3.fromRGB(255, 60, 60)
PhaseToggle.Font = Enum.Font.GothamBold
PhaseToggle.TextSize = 11
Instance.new("UICorner", PhaseToggle).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", PhaseToggle).Thickness = 1.5

-- State variables
local phaseActive = false
local serverGhost = nil
local originalCFrame = nil
local targetArenaCFrame = CFrame.new(150, 20, -300) -- CHANGE THIS TO YOUR TARGET ARENA COORDINATES

PhaseToggle.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    phaseActive = not phaseActive
    if phaseActive then
        PhaseToggle.Text = "PHASE TELEPORT: ACTIVE"
        PhaseToggle.TextColor3 = Color3.fromRGB(60, 255, 60)
        
        -- Lock original position anchor mapping
        originalCFrame = root.CFrame
        
        -- Instantiate server view dummy profile
        char.Archivable = true
        serverGhost = char:Clone()
        serverGhost.Name = "Server_Phase_Ghost"
        serverGhost.Parent = workspace
        
        -- Send Ghost to target Arena zone ahead
        serverGhost:SetPrimaryPartCFrame(targetArenaCFrame)
        
        -- Anchor real local asset safely in place to reject incoming zone damage spikes
        root.Anchored = true
    else
        PhaseToggle.Text = "PHASE TELEPORT: OFF"
        PhaseToggle.TextColor3 = Color3.fromRGB(255, 60, 60)
        
        if serverGhost then
            serverGhost:Destroy()
            serverGhost = nil
        end
        
        if root then
            root.Anchored = false
            
            -- RIG VALIDATION BREAKPOINT HANDLING:
            local isR6 = (hum.RigType == Enum.HumanoidRigType.R6)
            
            if isR6 then
                -- Direct safe pipeline repositioning for clean rigid assets
                root.CFrame = targetArenaCFrame
            else
                -- R15/Damage Factor Validation: Suppress collision triggers during phase snap
                local protectionTime = 0.5
                local startTime = tick()
                
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if tick() - startTime > protectionTime then
                        conn:Disconnect()
                    else
                        -- Wipe structural velocity values down to clear force impact registers
                        root.Velocity = Vector3.new(0,0,0)
                        root.RotVelocity = Vector3.new(0,0,0)
                    end
                end)
                root.CFrame = targetArenaCFrame
            end
        end
    end
end)
