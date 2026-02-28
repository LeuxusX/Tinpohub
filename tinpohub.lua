local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/LeuxusX/OrionUI/refs/heads/main/Orion%20Ui.lua"))()

OrionLib:MakeNotification({
    Name = "Script Loaded",
    Content = "Script Load Successfully",
    Time = 3
})

local Window = OrionLib:MakeWindow({
    Name = "TINPO Hub",
    HidePremium = false,
    SaveConfig = false,
    Color = Color3.fromRGB(255, 0, 0)
})

local CombatTab = Window:MakeTab({
    Name = "メイン",
    Icon = "rbxassetid://8834748103",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "プレイヤー",
    Icon = "rbxassetid://8834748103", -- Orion UI 標準アイコン
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "ビジュアル",
    Icon = "",  
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "テレポート",
    Icon = "",  -- map-pin 代替
    PremiumOnly = false
})

local TrollTab = Window:MakeTab({
    Name = "荒らし",
    Icon = "",  -- zap 代替
    PremiumOnly = false
})

local EmoteTab = Window:MakeTab({
    Name = "エモート",
    Icon = "",  -- 通知用アイコン
    PremiumOnly = false
})

local MusicTab = Window:MakeTab({
    Name = "ミュージック",
    Icon = "",  -- map-pin 代替
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "ミスク",
    Icon = "",  -- box 代替
    PremiumOnly = false
})

local DiscordTab = Window:MakeTab({
    Name = "ディスコード",
    Icon = "",  -- info 代替
    PremiumOnly = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

CombatTab:AddSection({ Name = "Kill" })

local KillLabel = CombatTab:AddLabel("Kill: 0")
local BaseKillCount = 0
local LastKillCount = 0
local KillValueConnection

local function UpdateKills()
	if LocalPlayer:FindFirstChild("leaderstats")
	and LocalPlayer.leaderstats:FindFirstChild("Kills") then

		local currentKills = LocalPlayer.leaderstats.Kills.Value
		local displayKills = math.max(currentKills - BaseKillCount, 0)
		KillLabel:Set("Kill: " .. displayKills)

		if currentKills > LastKillCount then
			LastKillCount = currentKills
			OrionLib:MakeNotification({
				Name = "キル通知",
				Content = "キル数が " .. displayKills .. " に増えました！",
				Time = 3
			})
		end
	else
		KillLabel:Set("Kill: N/A")
	end
end

local function ConnectKills()
	if KillValueConnection then
		KillValueConnection:Disconnect()
	end

	if LocalPlayer:FindFirstChild("leaderstats")
	and LocalPlayer.leaderstats:FindFirstChild("Kills") then
		local kills = LocalPlayer.leaderstats.Kills
		BaseKillCount = kills.Value
		LastKillCount = BaseKillCount
		UpdateKills()
		KillValueConnection = kills:GetPropertyChangedSignal("Value"):Connect(UpdateKills)
	end
end

LocalPlayer.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		child:WaitForChild("Kills", 5)
		ConnectKills()
	end
end)

ConnectKills()

CombatTab:AddSection({ Name = "エイムボット" })

local AimEnabled = false
local AimDropdownTarget = ""
local AimInputTarget = ""
local AimSmoothness = 0.25

local function GetPlayerList()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(t, p.Name)
		end
	end
	return t
end

CombatTab:AddDropdown({
	Name = "プレイヤー",
	Options = GetPlayerList(),
	Callback = function(v)
		AimDropdownTarget = v
	end
})

CombatTab:AddTextbox({
	Name = "サーチプレイヤー",
	Default = "",
	TextDisappear = false,
	Callback = function(text)
		AimInputTarget = text
	end
})

CombatTab:AddToggle({
	Name = "エイムボット",
	Default = false,
	Callback = function(v)
		AimEnabled = v
	end
})

RunService.RenderStepped:Connect(function()
	if not AimEnabled then return end

	local targetName =
		(AimInputTarget ~= "" and AimInputTarget)
		or AimDropdownTarget
	if targetName == "" then return end

	local target = Players:FindFirstChild(targetName)
	if not (target and target.Character) then return end

	local hum = target.Character:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local part = target.Character:FindFirstChild("LowerTorso")
		or target.Character:FindFirstChild("HumanoidRootPart")
	if not part then return end

	local camPos = Camera.CFrame.Position
	local goalCF = CFrame.lookAt(camPos, part.Position)

	Camera.CFrame = Camera.CFrame:Lerp(goalCF, AimSmoothness)
end)

-- ======================
-- Silent Aim
-- ======================
getgenv().SilentAimRunning = getgenv().SilentAimRunning or false

CombatTab:AddToggle({
	Name = "サイレントエイム",
	Default = false,
	Callback = function(state)
		if state then
			if getgenv().SilentAimRunning then return end
			getgenv().SilentAimRunning = true

			local ok, err = pcall(function()
				loadstring(game:HttpGet("https://pastefy.app/05x2AvVC/raw"))()
			end)

			if not ok then
				warn("SilentAim Error:", err)
				getgenv().SilentAimRunning = false
			end
		else
			getgenv().SilentAimRunning = false
			local gui = LocalPlayer:FindFirstChild("PlayerGui")
			if gui and gui:FindFirstChild("SilentAimGui") then
				gui.SilentAimGui:Destroy()
			end
		end
	end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Orbit 状態
local orbitEnabled = false
local orbitSpeed = 2
local orbitRadius = 3
local targetName = nil
local orbitConn = nil

-- ターゲット取得
local function getTarget()
    if not targetName then return nil end
    return Players:FindFirstChild(targetName)
end

-- Orbit 開始
local function startOrbit()
    if orbitConn then orbitConn:Disconnect() end
    local t = 0

    orbitConn = RunService.Heartbeat:Connect(function(dt)
        if not orbitEnabled then return end

        local target = getTarget()
        local myChar = LocalPlayer.Character
        if not (target and target.Character and myChar) then return end

        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        local mhrp = myChar:FindFirstChild("HumanoidRootPart")
        if not (thrp and mhrp) then return end

        t += dt * orbitSpeed

        local offset = Vector3.new(
            math.cos(t) * orbitRadius,
            0,
            math.sin(t) * orbitRadius
        )

        local pos = thrp.Position + offset

        -- ★ 常に相手の方向を見る
        mhrp.CFrame = CFrame.new(pos, thrp.Position)
    end)
end

-- Orbit 停止
local function stopOrbit()
    if orbitConn then
        orbitConn:Disconnect()
        orbitConn = nil
    end
end

local function getPlayerNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    return list
end

CombatTab:AddSection({ Name = "回転" })

CombatTab:AddDropdown({
    Name = "プレイヤー",
    Options = getPlayerNames(),
    Callback = function(v)
        targetName = v
    end
})

-- プレイヤー更新時に自動更新
Players.PlayerAdded:Connect(function()
    CombatTab:Refresh()
end)
Players.PlayerRemoving:Connect(function()
    CombatTab:Refresh()
end)

CombatTab:AddToggle({
    Name = "回転",
    Default = false,
    Callback = function(v)
        orbitEnabled = v
        if v then
            startOrbit()
        else
            stopOrbit()
        end
    end
})

CombatTab:AddSection({ Name = "回転設定" })

-- ② 回転スピード
CombatTab:AddSlider({
    Name = "回転スピード",
    Min = 1,
    Max = 10,
    Default = 2,
    Increment = 0.5,
    Callback = function(v)
        orbitSpeed = v
    end
})

-- ③ 回転距離
CombatTab:AddSlider({
    Name = "回転距離",
    Min = 1,
    Max = 10,
    Default = 3,
    Increment = 0.5,
    Callback = function(v)
        orbitRadius = v
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local Anti = {
    Knockback = false,
    Hitstun = false,
    Fling = false,
    Ragdoll = false,
    AntiLag = false,
    AntiSlowWalk = false,
    AntiGravity = false  
}

local AntiGravityConnection = nil

local AntiConnection
local AntiKickdownConnection
local AntiCameraShakeConnection
local AntiAFKConnection
local AntiGravityConnection 

local function StartAnti()
    if AntiConnection then return end

    AntiConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum and hum.Health > 0) then return end

        if Anti.Fling then
            if hrp.AssemblyLinearVelocity.Magnitude > 60 then
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            if hrp.AssemblyAngularVelocity.Magnitude > 40 then
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end

        if Anti.Hitstun then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
            if hum.UseJumpPower and hum.JumpPower < 50 then
                hum.JumpPower = 50
            end
        end

        if Anti.AntiSlowWalk then
            if hum.WalkSpeed < 16 then
                hum.WalkSpeed = 16
            end
        end
    end)
end

local function StartAntiGravity()
    if AntiGravityConnection then return end
    AntiGravityConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.AssemblyLinearVelocity.Y < -50 then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            end
        end
    end)
end

local function StopAntiIfNeeded()
    if not (Anti.Knockback or Anti.Hitstun or Anti.Fling or Anti.AntiLag or Anti.AntiSlowWalk or Anti.AntiGravity) then
        if AntiConnection then
            AntiConnection:Disconnect()
            AntiConnection = nil
        end
    end

    if not Anti.AntiGravity and AntiGravityConnection then
        AntiGravityConnection:Disconnect()
        AntiGravityConnection = nil
    end
end

local AntiRagdollEnabled = false
local AntiRagdollConnection = nil

local function ToggleAntiRagdoll(state)
    AntiRagdollEnabled = state

    if AntiRagdollConnection then
        AntiRagdollConnection:Disconnect()
        AntiRagdollConnection = nil
    end

    if state then
        AntiRagdollConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not (hum and hrp and hum.Health > 0) then return end
            
            local stateType = hum:GetState()
            if stateType == Enum.HumanoidStateType.Ragdoll
            or stateType == Enum.HumanoidStateType.Physics
            or stateType == Enum.HumanoidStateType.FallingDown
            or stateType == Enum.HumanoidStateType.GettingUp
            or stateType == Enum.HumanoidStateType.PlatformStanding then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end

            for _, m in ipairs(char:GetDescendants()) do
                if m:IsA("Motor6D") and not m.Enabled then
                    m.Enabled = true
                end
            end

            hum.PlatformStand = false

            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.clamp(vel.Y, -5, 5), vel.Z)
        end)
    end
end

local AntiCameraShakeEnabled = false

local function ToggleAntiCameraShake(state)
    AntiCameraShakeEnabled = state

    if AntiCameraShakeConnection then
        AntiCameraShakeConnection:Disconnect()
        AntiCameraShakeConnection = nil
    end

    if state then
        AntiCameraShakeConnection = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.CameraOffset = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end

local AntiAFKEnabled = false

local function ToggleAntiAFK(state)
    AntiAFKEnabled = state

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if state then
        AntiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

local function StartAntiGravity()
    if AntiGravityConnection then return end

    AntiGravityConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local velocity = hrp.AssemblyLinearVelocity

        if velocity.Y < -50 then
            hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, 0, velocity.Z)
        end
    end)
end

local function StopAntiGravity()
    if AntiGravityConnection then
        AntiGravityConnection:Disconnect()
        AntiGravityConnection = nil
    end
end

local function ToggleAntiGravity(state)
    Anti.AntiGravity = state
    if state then
        StartAntiGravity()
    else
        StopAntiGravity()
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ENABLED = false
local CONNECTION

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

local BLOCK = {
	BodyVelocity = true,
	BodyPosition = true,
	BodyGyro = true,
	BodyAngularVelocity = true,
	AlignPosition = true,
	AlignOrientation = true,
	LinearVelocity = true,
	AngularVelocity = true
}

local function setupHumanoid(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		DEFAULT_WALKSPEED = hum.WalkSpeed
		DEFAULT_JUMPPOWER = hum.JumpPower
	end
end

local function forceRestore(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if hum.WalkSpeed ~= DEFAULT_WALKSPEED then
		hum.WalkSpeed = DEFAULT_WALKSPEED
	end

	if hum.JumpPower ~= DEFAULT_JUMPPOWER then
		hum.JumpPower = DEFAULT_JUMPPOWER
	end

	hum.PlatformStand = false
	hum.AutoRotate = true

	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = false
		end
		if BLOCK[p.ClassName] then
			p:Destroy()
		end
	end
end

local function start()
	if CONNECTION then return end

	CONNECTION = RunService.Heartbeat:Connect(function()
		if not ENABLED then return end
		local char = LocalPlayer.Character
		if char then
			forceRestore(char)
		end
	end)
end

local function stop()
	if CONNECTION then
		CONNECTION:Disconnect()
		CONNECTION = nil
	end
end

_G.ToggleAntiSlow = function(state)
	ENABLED = state
	if state then
		start()
	else
		stop()
	end
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(0.3)
	setupHumanoid(char)
end)

if LocalPlayer.Character then
	setupHumanoid(LocalPlayer.Character)
end

local AntiKnockbackConn
local LAST_GOOD_CF
local Y_THRESHOLD = 30      
local H_THRESHOLD = 35      

local function StartAntiKnockback()
    if AntiKnockbackConn then return end

    AntiKnockbackConn = RunService.Stepped:Connect(function()
        if not Anti.Knockback then return end

        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp and hum.Health > 0) then return end

        local vel = hrp.AssemblyLinearVelocity
        local moveDir = hum.MoveDirection

        if math.abs(vel.Y) < Y_THRESHOLD and Vector3.new(vel.X,0,vel.Z).Magnitude < H_THRESHOLD then
            LAST_GOOD_CF = hrp.CFrame
            return
        end

        local hVel = Vector3.new(vel.X, 0, vel.Z)
        local horizontalKnock =
            hVel.Magnitude > H_THRESHOLD and
            (moveDir.Magnitude == 0 or hVel.Unit:Dot(moveDir) < -0.3)

        local verticalKnock = vel.Y > Y_THRESHOLD

        if (horizontalKnock or verticalKnock) and LAST_GOOD_CF then

            hrp.CFrame = LAST_GOOD_CF
           hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if hum:GetState() ~= Enum.HumanoidStateType.Running then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

local function StopAntiKnockback()
    if AntiKnockbackConn then
        AntiKnockbackConn:Disconnect()
        AntiKnockbackConn = nil
    end
    LAST_GOOD_CF = nil
end

local VirtualUser = game:GetService("VirtualUser")
local AntiAFKConn
local AntiAFKEnabled = false

local function StartAntiAFK()
    if AntiAFKConn then return end

    AntiAFKConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function StopAntiAFK()
    if AntiAFKConn then
        AntiAFKConn:Disconnect()
        AntiAFKConn = nil
    end
end

CombatTab:AddSection({
    Name = "アンチプレイヤー"
})

CombatTab:AddToggle({
    Name = "アンチノックバック",
    Default = false,
    Callback = function(v)
        Anti.Knockback = v
        if v then
            StartAntiKnockback()
        else
            StopAntiKnockback()
        end
    end
})

CombatTab:AddToggle({
    Name = "アンチ気絶",
    Default = false,
    Callback = function(v)
        ToggleAntiRagdoll(v)
    end
})

local Lighting = game:GetService("Lighting")

local SavedEffects = {}

function StartAntiLag()
    -- Graphics軽量化
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    -- Lightingエフェクト無効
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            SavedEffects[v] = v.Enabled
            v.Enabled = false
        end
    end

    -- パーティクル無効
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

function StopAntiLag()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

    -- Lighting戻す
    for effect, state in pairs(SavedEffects) do
        if effect then
            effect.Enabled = state
        end
    end

    -- パーティクル戻す
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = true
        end
    end
end

CombatTab:AddToggle({
    Name = "アンチラグ",
    Default = false,
    Callback = function(v)
        if v then
            StartAntiLag()
        else
            StopAntiLag()
        end
    end
})

CombatTab:AddToggle({
    Name = "アンチフリング",
    Default = false,
    Callback = function(v)
        Anti.Fling = v
        if v then
            StartAnti()
        else
            StopAntiIfNeeded()
        end
    end
})

CombatTab:AddToggle({
    Name = "アンチブレ",
    Default = false,
    Callback = function(v)
        ToggleAntiCameraShake(v)
    end
})

CombatTab:AddToggle({
    Name = "アンチ AFK",
    Default = false,
    Callback = function(v)
        AntiAFKEnabled = v
        if v then
            StartAntiAFK()
        else
            StopAntiAFK()
        end
    end
})

-- ===== Vars =====
local SpeedOn = false
local SpeedValue = 16

local JumpOn = false
local JumpValue = 50

local NoclipOn = false

-- ===== Utils =====
local function GetChar()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ===== SPEED（チェンソーマンテスト場対応）=====
local speedBV

local function EnableSpeed()
    local c = GetChar()
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if speedBV then speedBV:Destroy() end

    speedBV = Instance.new("BodyVelocity")
    speedBV.Name = "SpeedBoost"
    speedBV.MaxForce = Vector3.new(1e5, 0, 1e5) -- 横方向のみ
    speedBV.Velocity = Vector3.zero
    speedBV.Parent = hrp
end

local function DisableSpeed()
    if speedBV then
        speedBV:Destroy()
        speedBV = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not SpeedOn or not speedBV then return end

    local h = GetHumanoid()
    local c = GetChar()
    if not (h and c) then return end

    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dir = h.MoveDirection
    if dir.Magnitude > 0 then
        speedBV.Velocity = Vector3.new(
            dir.X * SpeedValue,
            0,
            dir.Z * SpeedValue
        )
    else
        speedBV.Velocity = Vector3.zero
    end
end)

-- === SUPER JUMP x2 (ULTRA) ===
local jumpEnabled = false
local jumpValue = 50
local humConn

-- 倍率（ここを変えればさらに上がる）
local MULTIPLIER = 3.2  -- 前回 1.6 → 今回 3.2（倍）

local function setupHumanoid(hum)
    if humConn then
        humConn:Disconnect()
        humConn = nil
    end

    hum.UseJumpPower = false

    local function apply()
        if jumpEnabled then
            -- 1〜100 → 10〜320（超高）
            hum.JumpHeight = math.clamp(jumpValue * MULTIPLIER, 10, 320)
        end
    end

    apply()

    -- 上書き対策
    humConn = hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
        if jumpEnabled then
            apply()
        end
    end)
end

local function applyJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    setupHumanoid(hum)
end

-- リスポーン対応
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    applyJump()
end)

-- ジャンプ入力時も強制再適用
UserInputService.JumpRequest:Connect(function()
    if jumpEnabled then
        applyJump()
    end
end)

-- ===== NOCLIP =====
RunService.Stepped:Connect(function()
    if not NoclipOn then return end
    local c = GetChar()
    if not c then return end

    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- ===== UI =====
PlayerTab:AddSection({ Name = "プレイヤー" })

PlayerTab:AddToggle({
    Name = "スピードブースト",
    CurrentValue = false,
    Callback = function(v)
        SpeedOn = v
        if v then
            EnableSpeed()
        else
            DisableSpeed()
        end
    end
})

PlayerTab:AddSlider({
    Name = "スピードブースト",
    Range = {16, 100}, -- UI上限
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        SpeedValue = v * 5 -- ← ★内部で5倍（最大500）
    end
})

PlayerTab:AddSection({ Name = "ジャンプ力" })

PlayerTab:AddToggle({
    Name = "ジャンプ力",
    Default = false,
    Callback = function(v)
        jumpEnabled = v
        applyJump()
    end
})

PlayerTab:AddSlider({
    Name = "ジャンプ力",
    Min = 1,
    Max = 100,
    Default = 50,
    Increment = 1,
    Callback = function(v)
        jumpValue = v
        applyJump()
    end
})

PlayerTab:AddSection({ Name = "ノークリップ" })

PlayerTab:AddToggle({
    Name = "ノークリップ",
    CurrentValue = false,
    Callback = function(v)
        NoclipOn = v
    end
})

CombatTab:AddButton({
    Name = "リスポーン",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
    end
})
-- ===== RESPAWN FIX =====
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    local h = GetHumanoid()
    if not h then return end

    h.UseJumpPower = true
    h.JumpPower = JumpOn and JumpValue or 50
end)

-- ===== Services =====
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== 設定 =====
local BELLY_DIST = 1.2
local SWING_SPEED = 5
local flingPower = 15000

-- 検知設定
local RESET_COOLDOWN = 0.15
local VEL_TRIGGER = 70
local DIST_TRIGGER = 12

-- ===== 状態 =====
local hiddenfling = false
local targetPlayer = nil
local lastSafePos = nil
local lastResetTime = 0

-- カメラ退避
local oldCamType
local oldCamSubject

-- ===== ターゲット =====
local function getAnyTarget()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			return p
		end
	end
end

-- ===== 腹固定 + 回転 + 検知（安定版）=====
local angle = 0
RunService.RenderStepped:Connect(function(dt)
	if not hiddenfling then return end

	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	-- カメラ固定（1回だけ）
	if Camera.CameraType ~= Enum.CameraType.Scriptable then
		oldCamType = Camera.CameraType
		oldCamSubject = Camera.CameraSubject
		Camera.CameraType = Enum.CameraType.Scriptable
		hum.AutoRotate = false
	end

	if not targetPlayer then
		targetPlayer = getAnyTarget()
	end
	if not targetPlayer then return end

	local tChar = targetPlayer.Character
	local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
	if not tHRP then return end

	-- 回転ブレ防止
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- 状態取得
	local currentPos = tHRP.Position
	local velMag = tHRP.AssemblyLinearVelocity.Magnitude

	-- 安全位置保存
	if velMag < 10 then
		lastSafePos = currentPos
	end

	-- ===== fling検知 =====
	if lastSafePos
		and tick() - lastResetTime > RESET_COOLDOWN
		and (velMag > VEL_TRIGGER or (currentPos - lastSafePos).Magnitude > DIST_TRIGGER)
	then
		lastResetTime = tick()
		hiddenfling = false
		task.wait()

		hrp.CFrame = CFrame.new(
			lastSafePos + Vector3.new(0, 2, 0),
			lastSafePos
		)

		hrp.Velocity = Vector3.zero
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero

		hiddenfling = true
		return
	end

	-- ===== 腹 前後スイング =====
	angle += dt * SWING_SPEED
	local offset = Vector3.new(0, 0, math.sin(angle) * BELLY_DIST)

	local cf = CFrame.new(tHRP.Position + offset, tHRP.Position)
	hrp.CFrame = cf

	-- カメラを自分に固定（揺れ防止）
	Camera.CFrame = cf * CFrame.new(0, 2, 6)
end)

-- ===== hidden fling（そのまま）=====
task.spawn(function()
	local hrp, vel
	local movel = 0.1

	while true do
		RunService.Heartbeat:Wait()
		if hiddenfling then
			local c = lp.Character
			hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				vel = hrp.Velocity
				hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)

				RunService.RenderStepped:Wait()
				if hrp then hrp.Velocity = vel end

				RunService.Stepped:Wait()
				if hrp then
					hrp.Velocity = vel + Vector3.new(0, movel, 0)
					movel = -movel
				end
			end
		end
	end
end)

-- ===== Orion ボタン =====
-- ===== プレイヤー一覧取得 =====
local function getPlayerNames()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			table.insert(list, p.Name)
		end
	end
	return list
end

TrollTab:AddDropdown({
	Name = "プレイヤー",
	Default = nil,
	Options = getPlayerNames(),
	Callback = function(name)
		local p = Players:FindFirstChild(name)
		if p then
			targetPlayer = p
		end
	end
})

TrollTab:AddToggle({
	Name = "Loop Kill",
	Default = false,
	Callback = function(v)
		hiddenfling = v
		if not v then
			lastSafePos = nil
			lastResetTime = 0

			local char = lp.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.AutoRotate = true end
			if oldCamType then
				Camera.CameraType = oldCamType
				Camera.CameraSubject = oldCamSubject
			end
		end
	end
})

-- ===== Services =====
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ===== 状態 =====
local followEnabled = false
local followConn
local followScriptLoaded = false
local selectedTargetName = nil

-- ===== ターゲット取得 =====
local function getTargetPlayer()
	if selectedTargetName then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name == selectedTargetName then
				return p
			end
		end
	end
	return nil
end

-- ===== プレイヤー名一覧を作る =====
local function getPlayerNames()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			table.insert(list, p.Name)
		end
	end
	return list
end

-- ===== Orion ドロップダウン追加（既存UIを壊さない） =====
TrollTab:AddSection({ Name = "ループゴミ箱" })

local targetDropdown = TrollTab:AddDropdown({
	Name = "プレイヤー",
	Default = nil,
	Options = getPlayerNames(),  -- 起動時に取得
	Callback = function(name)
		selectedTargetName = name
	end
})

-- 入退室時に更新（既存UIを残したまま）
Players.PlayerAdded:Connect(function()
	if targetDropdown and targetDropdown.RefreshOptions then
		targetDropdown:RefreshOptions(getPlayerNames())
	end
end)

Players.PlayerRemoving:Connect(function()
	if targetDropdown and targetDropdown.RefreshOptions then
		targetDropdown:RefreshOptions(getPlayerNames())
	end
end)

-- ===== フォロー処理 =====
local function StartFollowBehind()
	if followConn then
		followConn:Disconnect()
		followConn = nil
	end

	if not followScriptLoaded then
		followScriptLoaded = true
		task.spawn(function()
			loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man",
				true
			))()
		end)
	end

	followConn = RunService.Heartbeat:Connect(function()
		if not followEnabled then return end

		local target = getTargetPlayer()
		local myChar = lp.Character
		if not (target and target.Character and myChar) then return end

		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
		local myHRP = myChar:FindFirstChild("HumanoidRootPart")
		if not (targetHRP and myHRP) then return end

		local desiredPos = targetHRP.Position + targetHRP.CFrame.LookVector * 2
		local offset = desiredPos - myHRP.Position
		local dist = offset.Magnitude
		if dist > 0.1 then
			local dir = offset.Unit
			local speed = math.clamp(dist * 16, 18, 60)
			myHRP.AssemblyLinearVelocity = Vector3.new(
				dir.X * speed,
				myHRP.AssemblyLinearVelocity.Y,
				dir.Z * speed
			)
		end

		local lookPos = Vector3.new(
			targetHRP.Position.X,
			myHRP.Position.Y,
			targetHRP.Position.Z
		)
		myHRP.CFrame = CFrame.new(myHRP.Position, lookPos)
	end)
end

local function StopFollowBehind()
	if followConn then
		followConn:Disconnect()
		followConn = nil
	end
end

-- ===== Orion ボタン =====

TrollTab:AddToggle({
	Name = "ループゴミ箱",
	Default = false,
	Callback = function(v)
		followEnabled = v
		if v then
			StartFollowBehind()
		else
			StopFollowBehind()
		end
	end
})

-- ===== Services =====
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer

-- ===== 設定 =====
local RANGE = 30
local BELLY_DIST = 1.2
local SWING_SPEED = 6        -- 前後の速さ
local flingPower = 10000

-- ===== 状態 =====
local hiddenfling = false

-- ===== 近くの相手 =====
local function getTarget(hrp)
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
			if tHRP and (tHRP.Position - hrp.Position).Magnitude <= RANGE then
				return tHRP
			end
		end
	end
end

-- ===== 腹〜背中 前後回転（往復）=====
local t = 0
RunService.Heartbeat:Connect(function(dt)
	if not hiddenfling then return end

	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local target = getTarget(hrp)
	if not target then return end

	t += dt * SWING_SPEED
	local swing = math.sin(t) -- -1 ～ 1

	local cf = target.CFrame
	local offset = cf.LookVector * (swing * BELLY_DIST)

	-- 常に相手を向きながら前後に動く
	hrp.CFrame = CFrame.new(
		cf.Position + offset,
		cf.Position
	)
end)

-- ===== hidden fling（そのまま）=====
task.spawn(function()
	local hrp, c, vel
	local movel = 0.1

	while true do
		RunService.Heartbeat:Wait()

		if hiddenfling then
			while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
				RunService.Heartbeat:Wait()
				c = lp.Character
				hrp = c and c:FindFirstChild("HumanoidRootPart")
			end

			if hrp then
				vel = hrp.Velocity
				hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)

				RunService.RenderStepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel
				end

				RunService.Stepped:Wait()
				if hrp and hrp.Parent then
					hrp.Velocity = vel + Vector3.new(0, movel, 0)
					movel = -movel
				end
			end
		end
	end
end)

-- ===== Orion ボタン =====
TrollTab:AddSection({ Name = "フリング" })

TrollTab:AddToggle({
	Name = "フリングオーラ",
	Default = false,
	Callback = function(v)
		hiddenfling = v
	end
})

TrollTab:AddButton({
    Name = "フリングオール",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/aW96SQyL/raw"))()
    end
})

-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================
-- Player Dropdown
-- =========================
TeleportTab:AddSection({ Name = "Player Select" })

local SelectedPlayer = nil

local function GetPlayerNames()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(t, p.Name)
        end
    end
    return t
end

TeleportTab:AddDropdown({
    Name = "プレイヤー",
    Options = GetPlayerNames(),
    Callback = function(v)
        SelectedPlayer = v
    end
})

Players.PlayerAdded:Connect(function()
    -- dropdown更新用（再実行時に反映される）
end)

Players.PlayerRemoving:Connect(function(p)
    if SelectedPlayer == p.Name then
        SelectedPlayer = nil
    end
end)

-- =========================
-- Teleport Button
-- =========================
TeleportTab:AddButton({
    Name = "テレポート",
    Callback = function()
        if not SelectedPlayer then return end

        local target = Players:FindFirstChild(SelectedPlayer)
        if not (target and target.Character) then return end

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")

        if myHRP and tHRP then
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -3)
        end
    end
})

-- =========================
-- Loop Teleport
-- =========================
local LoopTP = false

TeleportTab:AddToggle({
    Name = "ループテレポート",
    Default = false,
    Callback = function(v)
        LoopTP = v
    end
})

RunService.RenderStepped:Connect(function()
    if not LoopTP then return end
    if not SelectedPlayer then return end

    local target = Players:FindFirstChild(SelectedPlayer)
    if not (target and target.Character) then return end

    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")

    if myHRP and tHRP then
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, -3)
    end
end)

-- =========================
-- Camera Lock
-- =========================
local CameraLock = false

TeleportTab:AddToggle({
    Name = "カメラロック",
    Default = false,
    Callback = function(v)
        CameraLock = v
    end
})

RunService.RenderStepped:Connect(function()
    if not CameraLock then return end
    if not SelectedPlayer then return end

    local target = Players:FindFirstChild(SelectedPlayer)
    if not (target and target.Character) then return end

    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =====================
-- Highlight V1
-- =====================
local HighlightEnabled = false
local HighlightColor = Color3.fromRGB(255, 0, 0)
local HighlightTransparency = 0.35
local HighlightObjects = {}

local function CreateHighlight(plr)
    if plr == LocalPlayer then return end
    if HighlightObjects[plr] then return end
    if not plr.Character then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HIGHLIGHT_V1"
    hl.Adornee = plr.Character
    hl.FillColor = HighlightColor
    hl.OutlineColor = HighlightColor
    hl.FillTransparency = HighlightTransparency
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = workspace

    HighlightObjects[plr] = hl
end

local function RemoveHighlight(plr)
    if HighlightObjects[plr] then
        HighlightObjects[plr]:Destroy()
        HighlightObjects[plr] = nil
    end
end

local function RefreshHighlight()
    for _, plr in ipairs(Players:GetPlayers()) do
        if HighlightEnabled then
            CreateHighlight(plr)
        else
            RemoveHighlight(plr)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not HighlightEnabled then return end
    for _, hl in pairs(HighlightObjects) do
        if hl then
            hl.FillColor = HighlightColor
            hl.OutlineColor = HighlightColor
            hl.FillTransparency = HighlightTransparency
        end
    end
end)

-- =====================
-- Highlight V2 (RGB)
-- =====================
local V2Enabled = false
local V2Highlights = {}
local ColorConn

local ColorList = {
    Color3.fromRGB(255,0,0),
    Color3.fromRGB(255,128,0),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(0,0,255),
    Color3.fromRGB(255,0,255),
}

local ColorIndex, NextIndex, Blend = 1, 2, 0
local Speed = 0.35

local function AddV2(plr)
    if plr == LocalPlayer then return end
    if V2Highlights[plr] or not plr.Character then return end

    local h = Instance.new("Highlight")
    h.Name = "ESP_HIGHLIGHT_V2"
    h.Adornee = plr.Character
    h.FillTransparency = HighlightTransparency
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = workspace

    V2Highlights[plr] = h
end

local function RemoveV2()
    for _, h in pairs(V2Highlights) do
        if h then h:Destroy() end
    end
    table.clear(V2Highlights)
end

local function StartV2()
    if ColorConn then return end
    ColorConn = RunService.RenderStepped:Connect(function(dt)
        Blend += dt * Speed
        if Blend >= 1 then
            Blend = 0
            ColorIndex = NextIndex
            NextIndex = (NextIndex % #ColorList) + 1
        end

        local col = ColorList[ColorIndex]:Lerp(ColorList[NextIndex], Blend)
        for _, h in pairs(V2Highlights) do
            if h then
                h.FillColor = col
                h.OutlineColor = col
                h.FillTransparency = HighlightTransparency
            end
        end
    end)
end

local function StopV2()
    if ColorConn then
        ColorConn:Disconnect()
        ColorConn = nil
    end
    RemoveV2()
end

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local fovEnabled = false
local fovValue = 70

-- 常に維持
RunService.RenderStepped:Connect(function()
    if fovEnabled and Camera then
        Camera.FieldOfView = fovValue
    end
end)

VisualsTab:AddToggle({
    Name = "視野チェンジャー",
    Default = false,
    Callback = function(v)
        fovEnabled = v
        if not v and Camera then
            Camera.FieldOfView = 70 -- OFF時は通常に戻す
        end
    end
})

VisualsTab:AddSlider({
    Name = "視野",
    Range = {50, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(v)
        fovValue = v
        if fovEnabled and Camera then
            Camera.FieldOfView = fovValue
        end
    end
})

VisualsTab:AddSection({
    Name = "ESP Highlight"
})

VisualsTab:AddToggle({
    Name = "ESP Highlight V1",
    Default = false,
    Callback = function(v)
        HighlightEnabled = v
        RefreshHighlight()
    end
})

VisualsTab:AddToggle({
    Name = "ESP Highlight V2",
    Default = false,
    Callback = function(v)
        V2Enabled = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                AddV2(p)
            end
            StartV2()
        else
            StopV2()
        end
    end
})

VisualsTab:AddColorpicker({
    Name = "Highlight Color",
    Default = HighlightColor,
    Callback = function(c)
        HighlightColor = c
    end
})

VisualsTab:AddSlider({
    Name = "色の濃さ•薄さ",
    Min = 0,
    Max = 1,
    Default = HighlightTransparency,
    Increment = 0.01,
    Callback = function(v)
        HighlightTransparency = v
    end
})

Players.PlayerAdded:Connect(function(plr)
    if HighlightEnabled then CreateHighlight(plr) end
    if V2Enabled then AddV2(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    RemoveHighlight(plr)
    if V2Highlights[plr] then
        V2Highlights[plr]:Destroy()
        V2Highlights[plr] = nil
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local EspIconEnabled = false
local EspObjects = {}

local function RemoveEspIcon(plr)
    if EspObjects[plr] then
        EspObjects[plr]:Destroy()
        EspObjects[plr] = nil
    end
end

local function CreateEspIcon(plr)
    if not EspIconEnabled then return end
    if plr == LocalPlayer then return end
    if EspObjects[plr] then return end
    if not plr.Character then return end

    local head = plr.Character:WaitForChild("Head", 5)
    if not head then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_ICON"
    gui.Size = UDim2.new(0, 70, 0, 80)
    gui.StudsOffset = Vector3.new(0, 2.2, 0)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local img = Instance.new("ImageLabel", frame)
    img.Size = UDim2.new(0, 44, 0, 44)
    img.Position = UDim2.new(0.5, -22, 0, 0)
    img.BackgroundTransparency = 1
    img.Image =
        ("rbxthumb://type=AvatarHeadShot&id=%d&w=180&h=180")
        :format(plr.UserId)

    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 0, 18)
    txt.Position = UDim2.new(0, 0, 0, 46)
    txt.BackgroundTransparency = 1
    txt.Text = plr.Name
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = Color3.new(1,1,1)
    txt.TextStrokeTransparency = 0.25
    txt.TextStrokeColor3 = Color3.new(0,0,0)

    EspObjects[plr] = gui
end

VisualsTab:AddSection({ Name = "ESP Icon" })

VisualsTab:AddToggle({
    Name = "ESP (Icon)",
    Default = false,
    Callback = function(v)
        EspIconEnabled = v

        for _, plr in ipairs(Players:GetPlayers()) do
            RemoveEspIcon(plr)
            if v then
                task.spawn(function()
                    CreateEspIcon(plr)
                end)
            end
        end
    end
})

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local RainbowConnection
local hue = 0

-- ColorCorrection作成
local colorEffect = Lighting:FindFirstChild("RainbowEffect")
if not colorEffect then
    colorEffect = Instance.new("ColorCorrectionEffect")
    colorEffect.Name = "RainbowEffect"
    colorEffect.Parent = Lighting
end

function StartRainbow()
    RainbowConnection = task.spawn(function()
        while true do
            hue += 0.05
            if hue > 1 then
                hue = 0
            end

            colorEffect.TintColor = Color3.fromHSV(hue, 1, 1)
            task.wait(0.3) -- 0.3秒ごとに変化
        end
    end)
end

function StopRainbow()
    if RainbowConnection then
        task.cancel(RainbowConnection)
        RainbowConnection = nil
    end
    colorEffect.TintColor = Color3.new(1,1,1) -- 元に戻す
end

VisualsTab:AddSection({ Name = "えーそこまで" })

VisualsTab:AddToggle({
    Name = "レインボーマップ",
    Default = false,
    Callback = function(v)
        if v then
            StartRainbow()
        else
            StopRainbow()
        end
    end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local backpack = LocalPlayer:WaitForChild("Backpack")

local function GetHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local humanoid = GetHumanoid()

local animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
    animator = Instance.new("Animator")
    animator.Parent = humanoid
end

-- =====================
-- Animations
-- =====================
local Animations = {
    ["Faint"] = "rbxassetid://181526230",
    ["Levitate"] = "rbxassetid://313762630",
    ["Spinner"] = "rbxassetid://188632011",
    ["Float Sit"] = "rbxassetid://179224234",
    ["Scared"] = "rbxassetid://180612465",
    ["Floating Head"] = "rbxassetid://121572214",
    ["Crouch"] = "rbxassetid://182724289",
    ["Moving Dance"] = "rbxassetid://429703734",
    ["Spin Dance"] = "rbxassetid://429730430",
    ["Spin Dance 2"] = "rbxassetid://186934910",
    ["Floor Faint"] = "rbxassetid://181525546",
    ["Bow Down"] = "rbxassetid://204292303",
    ["Sword Slam"] = "rbxassetid://204295235",
    ["Insane"] = "rbxassetid://33796059",
    ["Mega Insane"] = "rbxassetid://184574340",
    ["Moon Dance"] = "rbxassetid://45834924",
    ["Arm Turbine"] = "rbxassetid://259438880",
    ["Barrel Roll"] = "rbxassetid://136801964",
    ["Insane Arms"] = "rbxassetid://27432691",
}

local currentTrack
local currentTool

local function ToggleAnimation(animId, tool)
    if currentTrack and currentTool == tool then
        currentTrack:Stop()
        currentTrack:Destroy()
        currentTrack = nil
        currentTool = nil
        return
    end

    if currentTrack then
        currentTrack:Stop()
        currentTrack:Destroy()
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    currentTrack = animator:LoadAnimation(anim)
    currentTrack.Looped = true
    currentTrack:Play()
    currentTool = tool
end

EmoteTab:AddSection({ Name = "エモートツール" })

local SelectedEmote = ""

local emoteList = {}
for name in pairs(Animations) do
    table.insert(emoteList, name)
end
table.sort(emoteList)

EmoteTab:AddDropdown({
    Name = "エモート",
    Default = "",
    Options = emoteList,
    Callback = function(v)
        if typeof(v) == "table" then
            SelectedEmote = v[1] or ""
        else
            SelectedEmote = v or ""
        end
    end
})

EmoteTab:AddButton({
    Name = "エモートゲット",
    Callback = function()
        if SelectedEmote == "" then return end
        if backpack:FindFirstChild(SelectedEmote) then return end

        local animId = Animations[SelectedEmote]
        if not animId then return end

        local tool = Instance.new("Tool")
        tool.Name = SelectedEmote
        tool.RequiresHandle = false
        tool.Parent = backpack

        tool.Activated:Connect(function()
            ToggleAnimation(animId, tool)
        end)
    end
})

local SoundService = game:GetService("SoundService")

local MusicSound = Instance.new("Sound")
MusicSound.Name = "MiscMusicPlayer"
MusicSound.Volume = 2
MusicSound.Looped = true
MusicSound.Parent = SoundService

local CurrentMusicId = ""

MusicTab:AddSection({ Name = "ミュージック" })

MusicTab:AddTextbox({
    Name = "オーディオ ID",
    Default = "",
    TextDisappear = false,
    Callback = function(text)
        CurrentMusicId = text
    end
})

MusicTab:AddButton({
    Name = "プレイ",
    Callback = function()
        if CurrentMusicId == "" then return end
        MusicSound:Stop()
        MusicSound.SoundId = "rbxassetid://" .. CurrentMusicId
        MusicSound:Play()
    end
})

MusicTab:AddButton({
    Name = "ストップ",
    Callback = function()
        MusicSound:Stop()
    end
})

MusicTab:AddSlider({
    Name = "音量",
    Min = 0,
    Max = 5,
    Default = 2,
    Increment = 0.1,
    Callback = function(v)
        MusicSound.Volume = v
    end
})

TrollTab:AddSection({ Name = "トロール" })

TrollTab:AddButton({
    Name = "透明",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/OBYJ1UWC/raw"))()
    end
})

TrollTab:AddButton({
    Name = "キルオール",
    Callback = function()
        loadstring(game:HttpGet("https://pastefy.app/aW96SQyL/raw"))()
    end
})

MiscTab:AddSection({ Name = "スクリプト" })

MiscTab:AddButton({
    Name = "IY (Admin)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

MiscTab:AddButton({
    Name = "Fly Gui V3",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})

local TeleportService = game:GetService("TeleportService")

MiscTab:AddSection({ Name = "サーバー" })

MiscTab:AddButton({
    Name = "サーバー再参加",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            player
        )
    end
})

MiscTab:AddButton({
    Name = "サーバーホップ",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end
})

CombatTab:AddSection({ Name = "TSB" })

CombatTab:AddButton({
    Name = "五条悟 1 (サイタマ)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-Gojo-V2-Moveset-23988"))()
    end
})

CombatTab:AddButton({
    Name = "五条悟 2 (サイタマ)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/KJ-The-Strongest-Battlegrounds-battleground-gojo-script-saitama-to-gojo-26980"))()
    end
})

CombatTab:AddButton({
    Name = "五条悟 3 (サイタマ)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/BaldyToSorcerer/refs/heads/main/LatestV2.lua"))()
    end
})

DiscordTab:AddSection({ Name = "Discord" })

DiscordTab:AddLabel("ディスコードサーバーに入ってください")

DiscordTab:AddButton({
    Name = "サーバーリンクコピー",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/midoru")
        end

        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "コピーしました！",
            Time = 3
        })
    end
})

OrionLib:Init()
