-- POTENT HUB - Throw Food For Animals
-- Full · Clean unload · Tab sound spam · Slide anim (no light)

print("POTENT_HUB_STARTING")

if _G.__PotentThrowCleanup then pcall(_G.__PotentThrowCleanup) end

pcall(function()
	local cg = game:GetService("CoreGui")
	local target = (gethui and gethui()) or cg:FindFirstChild("RobloxGui") or cg
	if target then
		for _, c in ipairs(target:GetChildren()) do
			if c.Name:find("WindUI") or c.Name:find("POTENTHUB") or c.Name:find("Jenicakes") or c.Name == "PotentPerfOverlay" then
				c:Destroy()
			end
		end
	end
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local StatsSvc = game:GetService("Stats")
local LP = Players.LocalPlayer

local Alive = true

local SFX = {
	Click = "rbxassetid://6895079853",
	Toggle = "rbxassetid://6895079853",
	Success = "rbxassetid://6026984224",
	Notify = "rbxassetid://4590662766",
	Open = "rbxassetid://6895079853",
	Throw = "rbxassetid://6895079853",
	Tab1 = "rbxassetid://10066927508",
	Tab2 = "rbxassetid://9113889752",
	Tab3 = "rbxassetid://6895079853",
}

local function playSound(id, vol, pitch)
	if not Alive then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = vol or 0.45
		s.PlaybackSpeed = pitch or 1
		s.Parent = SoundService
		s:Play()
		s.Ended:Connect(function() s:Destroy() end)
		task.delay(3, function() if s and s.Parent then s:Destroy() end end)
	end)
end

local function getHum()
	local c = LP.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
	local c = LP.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local Conns = {}
local function on(sig, fn)
	local c = sig:Connect(fn)
	table.insert(Conns, c)
	return c
end

-- FPS / MS
local perfGui = Instance.new("ScreenGui")
perfGui.Name = "PotentPerfOverlay"
perfGui.ResetOnSpawn = false
perfGui.IgnoreGuiInset = true
perfGui.DisplayOrder = 99999
pcall(function() perfGui.Parent = (gethui and gethui()) or CoreGui end)
if not perfGui.Parent then perfGui.Parent = LP:WaitForChild("PlayerGui") end

local perfFrame = Instance.new("Frame")
perfFrame.Size = UDim2.new(0, 160, 0, 52)
perfFrame.Position = UDim2.new(1, -172, 0, 12)
perfFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
perfFrame.BackgroundTransparency = 0.25
perfFrame.BorderSizePixel = 0
perfFrame.Parent = perfGui
Instance.new("UICorner", perfFrame).CornerRadius = UDim.new(0, 10)
local ps = Instance.new("UIStroke")
ps.Color = Color3.fromRGB(245, 215, 122)
ps.Thickness = 1.2
ps.Transparency = 0.35
ps.Parent = perfFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -12, 0, 22)
fpsLabel.Position = UDim2.new(0, 6, 0, 4)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.TextColor3 = Color3.fromRGB(100, 255, 140)
fpsLabel.Text = "FPS: --"
fpsLabel.Parent = perfFrame

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(1, -12, 0, 22)
msLabel.Position = UDim2.new(0, 6, 0, 26)
msLabel.BackgroundTransparency = 1
msLabel.Font = Enum.Font.GothamBold
msLabel.TextSize = 14
msLabel.TextXAlignment = Enum.TextXAlignment.Left
msLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
msLabel.Text = "MS: --"
msLabel.Parent = perfFrame

local fpsCount, fpsLast, fpsFrames = 0, tick(), 0
on(RunService.RenderStepped, function()
	if not Alive then return end
	fpsFrames += 1
	local now = tick()
	if now - fpsLast >= 1 then
		fpsCount = fpsFrames
		fpsFrames = 0
		fpsLast = now
		fpsLabel.TextColor3 = fpsCount >= 55 and Color3.fromRGB(100, 255, 140) or fpsCount >= 30 and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(255, 90, 90)
		fpsLabel.Text = "FPS: " .. fpsCount
	end
end)

task.spawn(function()
	while Alive and perfGui and perfGui.Parent do
		local ms = 0
		pcall(function()
			if StatsSvc and StatsSvc.Network then
				local item = StatsSvc.Network.ServerStatsItem
				local ping = item and item["Data Ping"]
				if ping and ping.GetValue then ms = math.floor(ping:GetValue() + 0.5) end
			end
			if ms <= 0 and LP.GetNetworkPing then ms = math.floor(LP:GetNetworkPing() * 1000 + 0.5) end
		end)
		msLabel.TextColor3 = ms <= 80 and Color3.fromRGB(120, 200, 255) or ms <= 150 and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(255, 90, 90)
		msLabel.Text = "MS: " .. ms
		task.wait(0.5)
	end
end)

-- Optimizer
local origLighting, optimized = {}, false
local function saveLighting()
	pcall(function()
		origLighting = {
			GlobalShadows = Lighting.GlobalShadows,
			Brightness = Lighting.Brightness,
			FogEnd = Lighting.FogEnd,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
		}
	end)
end
local function applyOptimize(on)
	optimized = on
	if on then
		saveLighting()
		pcall(function()
			Lighting.GlobalShadows = false
			Lighting.Brightness = 1.5
			Lighting.FogEnd = 1e6
			Lighting.EnvironmentDiffuseScale = 0
			Lighting.EnvironmentSpecularScale = 0
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		pcall(function()
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
					v.Enabled = false
				elseif v:IsA("Explosion") then
					v:Destroy()
				end
			end
		end)
		pcall(function()
			local t = Workspace:FindFirstChildOfClass("Terrain")
			if t then t.Decoration = false end
		end)
	else
		pcall(function()
			if origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = origLighting.GlobalShadows end
			if origLighting.Brightness then Lighting.Brightness = origLighting.Brightness end
			if origLighting.FogEnd then Lighting.FogEnd = origLighting.FogEnd end
			if origLighting.EnvironmentDiffuseScale then Lighting.EnvironmentDiffuseScale = origLighting.EnvironmentDiffuseScale end
			if origLighting.EnvironmentSpecularScale then Lighting.EnvironmentSpecularScale = origLighting.EnvironmentSpecularScale end
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		end)
	end
end

-- Game
local Shared = ReplicatedStorage:FindFirstChild("Shared")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local function safeReq(mod)
	if not mod then return nil end
	local ok, r = pcall(require, mod)
	return ok and r or nil
end
local RemotesMod = safeReq(Shared and Shared:FindFirstChild("Remotes"))
local function getRem(n) return Remotes and Remotes:FindFirstChild(n) end
local function inv(n, ...)
	if not Alive then return end
	if RemotesMod then
		local f = RemotesMod.Invoke or RemotesMod.invoke
		if type(f) == "function" then
			local ok, r = pcall(f, n, ...)
			if ok and r ~= nil then return r end
			local ok2, r2 = pcall(f, RemotesMod, n, ...)
			if ok2 and r2 ~= nil then return r2 end
		end
	end
	local r = getRem(n)
	if r then
		if r:IsA("RemoteFunction") then
			local ok, res = pcall(r.InvokeServer, r, ...)
			if ok then return res end
		elseif r:IsA("RemoteEvent") then
			pcall(r.FireServer, r, ...)
			return { Ok = true }
		end
	end
end

local function getCtrls()
	local ps = LP:FindFirstChild("PlayerScripts")
	local client = ps and (ps:FindFirstChild("Client") or ps:WaitForChild("Client", 3))
	return client and (client:FindFirstChild("Controllers") or client:WaitForChild("Controllers", 3))
end
local Ctrls = getCtrls()
local ThrowCtrl = Ctrls and safeReq(Ctrls:FindFirstChild("ThrowController"))
local ThrowMeter = Ctrls and safeReq(Ctrls:FindFirstChild("ThrowMeter"))
local RevealSeq = Ctrls and safeReq(Ctrls:FindFirstChild("RevealSequence"))
local TrainCtrl = Ctrls and safeReq(Ctrls:FindFirstChild("TrainingController"))
local DataCtrl = Ctrls and safeReq(Ctrls:FindFirstChild("DataController"))
local ClientState = Ctrls and safeReq(Ctrls:FindFirstChild("ClientState"))
local CfgFolder = ReplicatedStorage:FindFirstChild("Config") or ReplicatedStorage:WaitForChild("Config", 3)
local GameCfg = CfgFolder and safeReq(CfgFolder:FindFirstChild("GameConfig"))
local StandsCfg = CfgFolder and safeReq(CfgFolder:FindFirstChild("StandsConfig"))
local FoodsCfg = CfgFolder and safeReq(CfgFolder:FindFirstChild("FoodsConfig"))
local BalCurve = Shared and safeReq(Shared:FindFirstChild("BalanceCurve"))

local S = {
	AutoTrain = false, AutoTap = true, FastTrain = true, TrainSpeed = 3, AutoStand = true,
	AutoThrow = false, ThrowMode = "Visual", Perfect = true, SkipCut = true, SuperThrow = false, ThrowDelay = 0.35,
	AutoPets = false, AutoFence = false, AutoOffline = true, AutoGifts = true, AutoBuyFood = false, AutoEquipFood = false,
	Speed = false, SpeedVal = 35, SpeedMode = "CFrame", Jump = false, JumpVal = 65, InfJump = false, NoClip = false, AntiAFK = true,
	Sounds = true, Optimize = false, ShowPerf = true,
}

local throwLoop, oneShot, spam = false, false, false

if not _G.__P_TM_New and ThrowMeter and type(ThrowMeter.new) == "function" then _G.__P_TM_New = ThrowMeter.new end
if not _G.__P_TM_Run and ThrowMeter and type(ThrowMeter.Run) == "function" then _G.__P_TM_Run = ThrowMeter.Run end
if not _G.__P_RS_Play and RevealSeq and type(RevealSeq.Play) == "function" then _G.__P_RS_Play = RevealSeq.Play end
if not _G.__P_RS_Run and RevealSeq and type(RevealSeq.Run) == "function" then _G.__P_RS_Run = RevealSeq.Run end
if not _G.__P_TC_Start and ThrowCtrl and type(ThrowCtrl.Start) == "function" then _G.__P_TC_Start = ThrowCtrl.Start end

if ThrowMeter and _G.__P_TM_New then
	ThrowMeter.new = function(...)
		local inst = _G.__P_TM_New(...)
		if inst and type(inst.Run) == "function" then
			local raw = inst.Run
			inst.Run = function(self, ...)
				if not Alive then return raw(self, ...) end
				local auto = S.AutoThrow or oneShot or spam
				if auto then
					if S.Perfect then
						task.wait(0.28)
						local ratings = GameCfg and GameCfg.Throw and GameCfg.Throw.MeterRatings
						local maxR = (ratings and ratings[#ratings]) or { Text = "PERFECT!", Color = Color3.fromRGB(255, 215, 0) }
						local bonus = (GameCfg and GameCfg.Throw and GameCfg.Throw.MeterBonusStuds) or 20
						return 1, maxR, bonus
					end
					task.wait(0.25)
					return 0.85, nil, 10
				end
				self.Locked = S.Perfect and true or false
				return raw(self, ...)
			end
		end
		return inst
	end
end
if ThrowMeter and _G.__P_TM_Run then
	ThrowMeter.Run = function(self, ...)
		if not Alive then return _G.__P_TM_Run(self, ...) end
		local auto = S.AutoThrow or oneShot or spam
		if auto then
			if S.Perfect then
				task.wait(0.28)
				local ratings = GameCfg and GameCfg.Throw and GameCfg.Throw.MeterRatings
				local maxR = (ratings and ratings[#ratings]) or { Text = "PERFECT!", Color = Color3.fromRGB(255, 215, 0) }
				local bonus = (GameCfg and GameCfg.Throw and GameCfg.Throw.MeterBonusStuds) or 20
				return 1, maxR, bonus
			end
			task.wait(0.25)
			return 0.85, nil, 10
		end
		self.Locked = S.Perfect and true or false
		return _G.__P_TM_Run(self, ...)
	end
end
if RevealSeq then
	if _G.__P_RS_Play then
		RevealSeq.Play = function(p, ...)
			if not Alive then return _G.__P_RS_Play(p, ...) end
			if (S.AutoThrow or oneShot or spam) and S.SkipCut then task.wait(0.12) return end
			return _G.__P_RS_Play(p, ...)
		end
	end
	if _G.__P_RS_Run then
		RevealSeq.Run = function(...)
			if not Alive then return _G.__P_RS_Run(...) end
			if (S.AutoThrow or oneShot or spam) and S.SkipCut then task.wait(0.12) return end
			return _G.__P_RS_Run(...)
		end
	end
end

local function fireBtn(btn)
	if not Alive or not btn or not btn:IsA("GuiButton") then return end
	pcall(function() if firesignal then firesignal(btn.Activated) firesignal(btn.MouseButton1Click) end end)
	pcall(function()
		if getconnections then
			for _, sig in ipairs({ btn.Activated, btn.MouseButton1Click }) do
				local ok, cs = pcall(getconnections, sig)
				if ok and cs then
					for _, c in ipairs(cs) do
						if type(c.Fire) == "function" then c:Fire()
						elseif type(c.Function) == "function" then c.Function() end
					end
				end
			end
		end
	end)
	pcall(function() if type(btn.Activate) == "function" then btn:Activate() end end)
end

local function clickTap(btn)
	if not Alive or not S.AutoTap then return end
	if btn and btn:IsA("ImageButton") and btn.Parent and btn.Parent.Name == "TapBonusLayer" then
		task.defer(function()
			if btn.Parent then for _ = 1, 3 do fireBtn(btn) task.wait(0.02) end end
		end)
	end
end

on(LP.PlayerGui.DescendantAdded, function(d)
	if not Alive then return end
	if d:IsA("ImageButton") and d.Parent and d.Parent.Name == "TapBonusLayer" then clickTap(d) end
end)

local trainBonusRem = getRem("Training_Bonus")
if trainBonusRem then
	on(trainBonusRem.OnClientEvent, function(raw)
		if not Alive or not S.AutoTap then return end
		local id = (type(raw) == "table" and (raw.Id or raw[1])) or raw
		if id then task.spawn(function() for _ = 1, 3 do inv("Training_TapBonus", id) task.wait(0.04) end end) end
		local ts = LP.PlayerGui:FindFirstChild("TrainingSequence")
		local layer = ts and ts:FindFirstChild("TapBonusLayer")
		if layer then for _, c in ipairs(layer:GetChildren()) do clickTap(c) end end
	end)
end

on(RunService.Heartbeat, function()
	if not Alive then return end
	if S.AutoTap then
		local ts = LP.PlayerGui:FindFirstChild("TrainingSequence")
		local layer = ts and ts:FindFirstChild("TapBonusLayer")
		if layer then
			for _, b in ipairs(layer:GetChildren()) do
				if b:IsA("ImageButton") and b.Active and b.Parent then clickTap(b) end
			end
		end
	end
	if S.AutoTrain and S.FastTrain then
		local hum = getHum()
		if hum then
			for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
				local n = t.Name:lower()
				if n:find("train") or n:find("pull") or n:find("bar") or n:find("workout") or (t.Length > 0 and t.Speed == 1) then
					if t.Speed ~= S.TrainSpeed and t.Speed > 0 then t:AdjustSpeed(S.TrainSpeed) end
				end
			end
		end
	end
end)

local function myPlot()
	local idx = LP:GetAttribute("PlotIndex") or (DataCtrl and DataCtrl:Get("PlotIndex")) or 1
	local plots = Workspace:FindFirstChild("Plots")
	return plots and plots:FindFirstChild(tostring(idx))
end
local function trainSpot()
	local lpp = Workspace:FindFirstChild("LocalPlotProps")
	if lpp and lpp:FindFirstChild("TrainingArea") and lpp.TrainingArea:FindFirstChild("TrainingSpot") then
		local s = lpp.TrainingArea.TrainingSpot
		if s:IsA("BasePart") then return s end
	end
end
local function crossLine()
	local a = Workspace:FindFirstChild("StarterArea")
	return a and a:FindFirstChild("CrossLine")
end
local function tp(cf)
	if not Alive then return end
	local h = getHRP()
	if h then h.CFrame = typeof(cf) == "CFrame" and cf or CFrame.new(cf) end
end
local function pastLine()
	if not Alive then return false end
	local h = getHRP()
	if not h then return false end
	local cl = crossLine()
	if cl then
		if h.Position.Z > cl.Position.Z - 4 then
			h.CFrame = CFrame.new(cl.Position.X, cl.Position.Y + 2, cl.Position.Z - 8)
		end
	else h.CFrame = CFrame.new(0, 3.5, -42) end
	return true
end
local function backLine()
	local h = getHRP()
	if not h then return end
	local cl = crossLine()
	if cl then h.CFrame = CFrame.new(cl.Position.X, cl.Position.Y + 2, cl.Position.Z + 20)
	else h.CFrame = CFrame.new(0, 3.5, -15) end
end
local function money()
	local ls = LP:FindFirstChild("leaderstats")
	local m = ls and ls:FindFirstChild("Money")
	if m then
		local n = tonumber(tostring(m.Value):gsub("%$", ""):gsub(",", ""))
		if n then return n end
	end
	if DataCtrl and DataCtrl:IsReady() then return tonumber(DataCtrl:Get("Money")) or 0 end
	return 0
end
local function nextStandPrice()
	if not StandsCfg or not StandsCfg.Get or not DataCtrl then return end
	local cur = tonumber(DataCtrl:Get("Stand")) or 1
	local cnt = (StandsCfg.Count and StandsCfg.Count()) or 58
	if cur >= cnt then return end
	local nxt = StandsCfg.Get(cur + 1)
	if not nxt then return end
	if BalCurve and BalCurve.GetItemPrice then
		local ok, p = pcall(BalCurve.GetItemPrice, LP, nxt)
		if ok and tonumber(p) then return tonumber(p) end
	end
	return tonumber(nxt.Price)
end
local function standInfo()
	local cur = (DataCtrl and tonumber(DataCtrl:Get("Stand"))) or 1
	local d = StandsCfg and StandsCfg.Get and StandsCfg.Get(cur)
	local n = StandsCfg and StandsCfg.Get and StandsCfg.Get(cur + 1)
	return cur, (d and d.Name) or ("Stand #" .. cur), (d and d.XpPerRep) or 5, nextStandPrice(), n and n.XpPerRep
end

local lastThrow, cdEst, cdHits = 0, 1.15, 0
local function resetThrow()
	if ClientState then ClientState.Busy = nil end
	pcall(function() inv("Throw_Cancel") end)
	task.wait(0.05)
	pcall(function() inv("Throw_Cancel") end)
end
local function waitCD()
	local rem = cdEst - (os.clock() - lastThrow)
	if rem > 0.05 then task.wait(rem + 0.02) end
end
local function visualThrow()
	if not Alive then return false end
	local h = getHRP()
	if not h or not S.AutoThrow then return false end
	pastLine() task.wait(0.08)
	if not S.AutoThrow or not Alive then return false end
	if S.SuperThrow then pcall(function() inv("Throw_UseSuper") end) end
	if S.Sounds then playSound(SFX.Throw, 0.3, 1.1) end
	if ThrowCtrl then
		local f = ThrowCtrl.Start or ThrowCtrl.start
		if type(f) == "function" then pcall(function() f(ThrowCtrl) end) end
	else
		inv("Throw_Start") inv("Throw_Resolve", 1) task.wait(0.3) inv("Throw_Complete")
	end
	local t = math.max(S.ThrowDelay or 0.35, 0.2) + 0.7
	local s = os.clock()
	while Alive and S.AutoThrow and os.clock() - s < t do task.wait(0.04) end
	lastThrow = os.clock()
	return true
end
local function instantThrow()
	if not Alive then return false, false end
	local h = getHRP()
	if not h or not S.AutoThrow then return false, false end
	pastLine() waitCD()
	if not S.AutoThrow or not Alive then return false, false end
	if ClientState then ClientState.Busy = "Throw" end
	local was = h.Anchored
	h.Anchored = true
	if S.SuperThrow then pcall(function() inv("Throw_UseSuper") end) end
	if S.Sounds then playSound(SFX.Throw, 0.25, 1.2) end
	local start = inv("Throw_Start")
	local cd, done = false, false
	if type(start) == "table" and start.Ok then
		local res = inv("Throw_Resolve", 1)
		if type(res) == "table" and res.Ok then
			local w = math.max(S.ThrowDelay or 0.35, 0.15)
			local t0 = os.clock()
			while Alive and S.AutoThrow and os.clock() - t0 < w do task.wait(0.02) end
			if not S.AutoThrow or not Alive then
				pcall(function() inv("Throw_Cancel") end)
				if ClientState then ClientState.Busy = nil end
				h.Anchored = was
				return false, false
			end
			inv("Throw_Complete")
			lastThrow = os.clock()
			cdHits = 0
			done = true
		else pcall(function() inv("Throw_Cancel") end) end
	else
		if type(start) == "table" and start.Reason == "Cooldown" then
			cd = true
			cdHits += 1
			if cdHits >= 2 then cdEst = math.min(cdEst + 0.25, 2.5) cdHits = 0 end
		else pcall(function() inv("Throw_Cancel") end) end
	end
	h.Anchored = was
	if ClientState then ClientState.Busy = nil end
	return done, cd
end
local function stopThrow()
	S.AutoThrow = false
	throwLoop, oneShot, spam = false, false, false
	resetThrow()
	if ThrowCtrl then
		pcall(function()
			if type(ThrowCtrl.Stop) == "function" then ThrowCtrl.Stop(ThrowCtrl) end
			if type(ThrowCtrl.Cancel) == "function" then ThrowCtrl.Cancel(ThrowCtrl) end
			if ThrowCtrl._running ~= nil then ThrowCtrl._running = false end
			if ThrowCtrl.Running ~= nil then ThrowCtrl.Running = false end
		end)
	end
	local h = getHRP()
	if h then h.Anchored = false end
	pcall(backLine)
end
local function startThrow()
	if not Alive or throwLoop then return end
	throwLoop = true
	task.spawn(function()
		pastLine()
		while Alive and S.AutoThrow and throwLoop do
			if S.ThrowMode == "Instant" then
				local ok, cd = instantThrow()
				if cd then task.wait(0.4) elseif not ok then task.wait(0.25) end
			else visualThrow() end
			task.wait(0.05)
		end
		throwLoop = false
	end)
end
local function oneThrow()
	if not Alive or oneShot or spam then return end
	oneShot = true
	task.spawn(function()
		local prev = S.AutoThrow
		S.AutoThrow = true
		pastLine()
		if S.ThrowMode == "Instant" then instantThrow() else visualThrow() end
		S.AutoThrow = prev
		oneShot = false
		pcall(backLine)
	end)
end
local function spamThrow(n)
	if not Alive or spam or oneShot then return end
	spam = true
	task.spawn(function()
		local prev = S.AutoThrow
		S.AutoThrow = true
		pastLine()
		for i = 1, n do
			if not spam or not Alive then break end
			if S.ThrowMode == "Instant" then instantThrow() else visualThrow() end
			task.wait(0.08)
		end
		S.AutoThrow = prev
		spam = false
		pcall(backLine)
	end)
end

task.spawn(function()
	while Alive do
		task.wait(0.03)
		if S.Speed then
			local h, hum = getHRP(), getHum()
			if h and hum and hum.MoveDirection.Magnitude > 0 then
				if S.SpeedMode == "CFrame" or S.SpeedMode == "Both" then
					h.CFrame = h.CFrame + hum.MoveDirection * (S.SpeedVal / 60)
				end
				if S.SpeedMode == "WalkSpeed" or S.SpeedMode == "Both" then
					hum.WalkSpeed = S.SpeedVal
				end
			end
		end
		if S.NoClip then
			local c = LP.Character
			if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
		end
	end
end)

UserInputService.JumpRequest:Connect(function()
	if not Alive or not S.InfJump then return end
	local hum = getHum()
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

if S.AntiAFK then
	on(LP.Idled, function()
		if not Alive then return end
		pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
	end)
end

task.spawn(function()
	while Alive do
		task.wait(2)
		if not Alive then break end
		if S.AutoOffline then pcall(function() inv("Claim_Offline") end) end
		if S.AutoGifts then pcall(function() inv("Shop_ClaimGifts") end) pcall(function() inv("Claim_Gifts") end) end
		if S.AutoPets then pcall(function() inv("Plot_EquipBest") end) end
		if S.AutoFence then pcall(function() inv("Plot_UpgradeFence") end) end
		if S.AutoBuyFood then pcall(function() inv("Shop_BuyBest") end) end
		if S.AutoEquipFood then pcall(function() inv("Shop_EquipBest") end) end
		if S.AutoStand then
			local p = nextStandPrice()
			if p and money() >= p then pcall(function() inv("Stand_Upgrade") end) end
		end
	end
end)

task.spawn(function()
	while Alive do
		task.wait(0.8)
		if not Alive then break end
		if S.AutoTrain then
			if TrainCtrl and type(TrainCtrl.IsRunning) == "function" then
				if not TrainCtrl.IsRunning() then
					pcall(function() if type(TrainCtrl.Start) == "function" then TrainCtrl.Start(TrainCtrl) end end)
				end
			else pcall(function() inv("Training_Start") end) end
		end
	end
end)

-- UI
local gethui = gethui or function() return CoreGui end
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local function http(u)
	local ok, r = pcall(game.HttpGet, game, u)
	if ok and r ~= "" then return r end
	if req then local res = req({ Url = u, Method = "GET" }) if res and res.Body then return res.Body end end
	return ""
end
local DISCORD, BGID, LOGO = "https://discord.gg/X7Y4NzuC67", "72427773287138", "117299981730743"
local grads, vis = {}, false
RunService.RenderStepped:Connect(function(dt)
	if not Alive then return end
	for i = #grads, 1, -1 do
		local e = grads[i]
		if e.g and e.g.Parent then e.g.Rotation = (e.g.Rotation + e.s * dt) % 360 else table.remove(grads, i) end
	end
end)
local function findGui()
	local pools = {}
	pcall(function() table.insert(pools, gethui()) end)
	pcall(function() table.insert(pools, CoreGui) end)
	local pg = LP:FindFirstChild("PlayerGui")
	if pg then table.insert(pools, pg) end
	for _, pool in ipairs(pools) do
		for _, g in ipairs(pool:GetChildren()) do
			if g:IsA("ScreenGui") and (g.Name:find("WindUI") or g.Name:find("POTENTHUB") or g.Name:find("Footagesus")) then return g end
		end
	end
end
local function findBG(g)
	for _, d in ipairs(g:GetDescendants()) do
		if d:IsA("ImageLabel") and tostring(d.Image):find(BGID) then return d end
	end
end
local function rmStroke(r)
	if not r then return end
	for _, d in ipairs(r:GetDescendants()) do
		if d:IsA("UIStroke") then
			local p = d.Parent
			if p and not p.Name:find("Open") and not p.Name:find("Float") then pcall(d.Destroy, d) end
		elseif d:IsA("Frame") and d.Name:find("Outline") then pcall(d.Destroy, d)
		elseif d:IsA("ImageLabel") and (d.Name:find("Outline") or d.Name:find("Border")) then d.Visible = false end
	end
end
local function apply()
	if vis or not Alive then return end
	local g = findGui()
	if not g then return end
	local bg = findBG(g)
	if not bg then return end
	vis = true
	bg.ImageColor3 = Color3.fromRGB(120, 120, 140)
	bg.ImageTransparency = 0.35
	bg.ZIndex = 0
	local old = bg:FindFirstChild("PotentDarkOverlay")
	if old then old:Destroy() end
	local ov = Instance.new("Frame")
	ov.Name = "PotentDarkOverlay"
	ov.Size = UDim2.new(1, 0, 1, 0)
	ov.BackgroundColor3 = Color3.new()
	ov.BackgroundTransparency = 1
	ov.BorderSizePixel = 0
	ov.ZIndex = 0
	ov.Parent = bg
	Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 12)
	local gr = Instance.new("UIGradient", ov)
	gr.Color = ColorSequence.new(Color3.new())
	gr.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0.05) }
	gr.Rotation = 90
	TweenService:Create(ov, TweenInfo.new(0.6), { BackgroundTransparency = 0.25 }):Play()
	local c = bg.Parent or bg
	for _, d in ipairs(c:GetDescendants()) do
		if d ~= ov and d:IsA("GuiObject") and d.ZIndex < 2 then pcall(function() d.ZIndex = 2 end) end
	end
	c.DescendantAdded:Connect(function(d)
		if d:IsA("GuiObject") and d ~= ov and not d:IsDescendantOf(ov) then
			task.defer(function() if d.Parent and d.ZIndex < 2 then pcall(function() d.ZIndex = 2 end) end end)
		end
	end)
	task.defer(rmStroke, c)
end
local function getLib()
	local code = http("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
	if code == "" then code = http("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua") end
	local W = loadstring(code)()
	pcall(function()
		W:AddTheme({
			Name = "POTENT HUB",
			Background = W:Gradient({ ["0"] = { Color = Color3.fromHex("#161619"), Transparency = 0.12 }, ["100"] = { Color = Color3.fromHex("#161619"), Transparency = 0.12 } }, { Rotation = 90 }),
			Accent = W:Gradient({ ["0"] = { Color = Color3.fromHex("#17120A"), Transparency = 0 }, ["100"] = { Color = Color3.fromHex("#D6A83B"), Transparency = 0 } }, { Rotation = 90 }),
			Dialog = Color3.fromHex("#141418"), Outline = Color3.fromHex("#ffffff"), Text = Color3.fromHex("#ffffff"),
			Placeholder = Color3.fromHex("#a1a1aa"), Button = Color3.fromHex("#3A2D12"), Icon = Color3.fromHex("#F5D77A"),
			Toggle = Color3.fromHex("#F5D77A"), Slider = Color3.fromHex("#F5D77A"), Checkbox = Color3.fromHex("#F5D77A"),
			SliderIcon = Color3.fromHex("#71717a"), Primary = Color3.fromHex("#F5D77A"),
			PanelBackground = Color3.fromHex("#ffffff"), PanelBackgroundTransparency = 0.94,
			LabelBackground = Color3.fromHex("#000000"), LabelBackgroundTransparency = 0.8,
			ElementBackground = Color3.fromHex("#18181b"), ElementBackgroundTransparency = 0.3,
		})
		W:SetTheme("POTENT HUB")
	end)
	return W
end
local function createWin(W, folder, name)
	vis = false
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
	local ww = math.clamp(vp.X - 24, 320, 850)
	local wh = math.clamp(vp.Y - 24, 300, 560)
	local win = W:CreateWindow({
		Title = "POTENT HUB", Icon = "rbxassetid://" .. LOGO, Author = name or "Throw Food",
		Folder = folder, Background = "", Size = UDim2.fromOffset(ww, wh),
		MaxSize = Vector2.new(850, 560), MinSize = Vector2.new(320, 300),
		Resizable = true, Transparent = true, Theme = "POTENT HUB",
		BackgroundImageTransparency = 0.35, Acrylic = false, ShadowTransparency = 0.3,
		Radius = 18, IconRadius = 1, IconSize = 27, SideBarWidth = 185,
		Topbar = { Height = 56, ButtonsType = "Default" }, User = { Enabled = false, Anonymous = false },
		OpenButton = {
			Title = "POTENT HUB", Icon = "rbxassetid://" .. LOGO, CornerRadius = UDim.new(0, 16), StrokeThickness = 1,
			Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 168, 59)), ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 215, 122)) },
			OnlyMobile = false, Enabled = true, Draggable = true,
		},
	})
	pcall(function() win:Tag({ Title = "POTENT HUB", Icon = "terminal", Color = Color3.fromRGB(245, 215, 122) }) end)
	task.spawn(function()
		task.wait(0.15)
		if S.Sounds then playSound(SFX.Open, 0.5, 1) end
		local gui = findGui()
		if gui then
			local main = gui:FindFirstChild("Main", true)
			if main and main:IsA("GuiObject") then
				local orig = main.Size
				main.Size = UDim2.fromOffset(0, 0)
				TweenService:Create(main, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = orig }):Play()
			end
		end
	end)
	task.spawn(function()
		for _ = 1, 20 do
			if not Alive then return end
			pcall(apply)
			if vis then task.wait(0.3) pcall(rmStroke, findGui()) break end
			task.wait(0.2)
		end
	end)
	task.spawn(function()
		task.wait(1)
		if not Alive then return end
		pcall(function()
			local g = findGui()
			if not g then return end
			for _, d in ipairs(g:GetDescendants()) do
				if d:IsA("UIStroke") then
					local gr = d:FindFirstChildOfClass("UIGradient")
					if gr then grads[#grads + 1] = { g = gr, s = 70 } end
				end
			end
		end)
	end)
	task.spawn(function()
		local title
		for _ = 1, 120 do
			if not Alive then return end
			pcall(function()
				local g = findGui()
				local m = g and g:FindFirstChild("Main", true)
				local t = m and m:FindFirstChild("Topbar", true)
				local l = t and t:FindFirstChild("Left")
				local ti = l and l:FindFirstChild("Title")
				if ti and ti:IsA("TextLabel") then title = ti end
				if not title and m then
					for _, i in ipairs(m:GetDescendants()) do
						if i:IsA("TextLabel") and i.Text == "POTENT HUB" then title = i break end
					end
				end
			end)
			if title then break end
			RunService.RenderStepped:Wait()
		end
		if not title or not title.Parent or title:FindFirstChild("OnyxTitleSheen") then return end
		pcall(function()
			local gr = Instance.new("UIGradient", title)
			gr.Name = "OnyxTitleSheen"
			gr.Rotation = 12
			gr.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(148, 148, 164)),
				ColorSequenceKeypoint.new(0.45, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(0.55, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 148, 164)),
			}
			gr.Offset = Vector2.new(-0.55, 0)
			local st = Instance.new("UIStroke", title)
			st.Name = "OnyxTitleGlow"
			st.Color = Color3.fromRGB(236, 239, 250)
			st.Thickness = 1.4
			st.Transparency = 0.82
			TweenService:Create(gr, TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(0.55, 0) }):Play()
			TweenService:Create(st, TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.42 }):Play()
		end)
	end)
	return win
end

local W = getLib()
local gName = "Throw Food For Animals"
pcall(function() gName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
local Window = createWin(W, "POTENTHUB_THROWFOOD", gName)

-- Tab sound (spam ok) + slide anim (no light)
local TAB_SFX = { SFX.Tab1, SFX.Tab2, SFX.Tab3 }
local tabIdx, lastTab = 1, nil

local function onTabChange()
	if not Alive then return end
	-- always play, even spam
	if S.Sounds then
		local id = TAB_SFX[tabIdx]
		tabIdx = tabIdx % #TAB_SFX + 1
		playSound(id, 0.55, 0.9 + math.random() * 0.3)
	end
	-- slide only, no flash/light
	pcall(function()
		local gui = findGui()
		if not gui then return end
		local main = gui:FindFirstChild("Main", true)
		if not main then return end
		local content = main:FindFirstChild("Content", true) or main:FindFirstChild("Container", true) or main:FindFirstChild("Page", true)
		local target = content
		if not target then
			for _, d in ipairs(main:GetDescendants()) do
				if d:IsA("ScrollingFrame") or (d:IsA("Frame") and d.Name:lower():find("page")) then
					target = d
					break
				end
			end
		end
		if target and target:IsA("GuiObject") then
			local orig = target.Position
			target.Position = orig + UDim2.fromOffset(22, 0)
			target.BackgroundTransparency = target.BackgroundTransparency
			TweenService:Create(target, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = orig
			}):Play()
		end
	end)
end

task.spawn(function()
	while Alive and Window do
		task.wait(0.08)
		pcall(function()
			local cur = Window.CurrentTab or Window.SelectedTab
			if not cur then
				local gui = findGui()
				if gui then
					for _, d in ipairs(gui:GetDescendants()) do
						if (d:IsA("TextButton") or d:IsA("ImageButton")) and d:GetAttribute("Selected") then
							cur = d.Name or d.Text
							break
						end
					end
				end
			end
			if cur and cur ~= lastTab then
				lastTab = cur
				onTabChange()
			end
		end)
	end
end)

local function notify(title, content, ok)
	if not Alive then return end
	if S.Sounds then playSound(SFX.Notify, 0.4, ok == false and 0.9 or 1.05) end
	W:Notify({ Title = title, Content = content, Duration = 2.5 })
end
local function toggleSound(v)
	if S.Sounds then playSound(SFX.Toggle, 0.35, v and 1.1 or 0.9) end
end
local function clickSound()
	if S.Sounds then playSound(SFX.Click, 0.3, 1) end
end

-- TABS
local Main = Window:Tab({ Title = "Main", Icon = "house" })
local Stats = Main:Paragraph({ Title = "Live Stats", Desc = "Loading..." })
task.spawn(function()
	while Alive do
		task.wait(1.5)
		if not Alive then break end
		pcall(function()
			local ls = LP:FindFirstChild("leaderstats")
			local mon = ls and ls:FindFirstChild("Money") and ls.Money.Value or "$0"
			local pow = ls and ls:FindFirstChild("Throw Power") and tostring(ls["Throw Power"].Value) or "0"
			local rate = ls and ls:FindFirstChild("Money/s") and ls["Money/s"].Value or "$0/s"
			local lvl = DataCtrl and DataCtrl:Get("Level") or 1
			local xp = DataCtrl and DataCtrl:Get("Xp") or 0
			local cur, name, cxp, nprice, nxp = standInfo()
			local nextT = nprice and string.format("Next: +%s XP ($%s)", tostring(nxp or "?"), tostring(nprice)) or "MAX TIER"
			Stats:SetDesc(string.format(
				"Money: %s | Income: %s\nLevel %d (XP %d) | Power: %s\nStand: %s (#%d)\n+%s XP/rep | %s",
				tostring(mon), tostring(rate), tonumber(lvl), tonumber(xp), tostring(pow), tostring(name), tonumber(cur), tostring(cxp), nextT
			))
		end)
	end
end)

Main:Section({ Title = "Training" })
Main:Toggle({ Title = "Auto Training", Value = S.AutoTrain, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.AutoTrain = v
	if v and S.AutoThrow then stopThrow() end
	if not v and TrainCtrl and TrainCtrl.IsRunning and TrainCtrl.IsRunning() then pcall(function() TrainCtrl.Stop() end) end
end })
Main:Toggle({ Title = "Auto Tap Bonus", Value = S.AutoTap, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoTap = v end })
Main:Toggle({ Title = "Fast Animations", Value = S.FastTrain, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.FastTrain = v
	if not v then pcall(function() local hum = getHum() if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end end) end
end })
Main:Slider({ Title = "Train Speed", Step = 0.5, Value = { Min = 1, Max = 5, Default = S.TrainSpeed }, Callback = function(v) if Alive then S.TrainSpeed = v end end })
Main:Toggle({ Title = "Auto Upgrade Stand", Value = S.AutoStand, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoStand = v end })
Main:Button({ Title = "Upgrade Stand Now", Callback = function()
	if not Alive then return end
	clickSound()
	local r = inv("Stand_Upgrade")
	notify("Stand", ((type(r) == "table" and r.Ok) or r == true) and "Upgraded!" or "Not enough money", true)
end })
Main:Button({ Title = "TP Training Spot", Callback = function()
	if not Alive then return end
	clickSound()
	local s = trainSpot()
	if s then tp(s.CFrame + Vector3.new(0, 3, 0)) notify("TP", "Training spot", true) else notify("TP", "Spot not found", false) end
end })

local Throw = Window:Tab({ Title = "Throw", Icon = "target" })
Throw:Section({ Title = "Auto Throw" })
Throw:Toggle({ Title = "Enable Auto Throw", Value = S.AutoThrow, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.AutoThrow = v
	if v then
		if S.AutoTrain then S.AutoTrain = false if TrainCtrl and TrainCtrl.IsRunning and TrainCtrl.IsRunning() then pcall(function() TrainCtrl.Stop() end) end end
		startThrow()
	else stopThrow() end
end })
Throw:Dropdown({ Title = "Mode", Values = { "Visual", "Instant" }, Value = S.ThrowMode, Callback = function(v) if Alive then clickSound() S.ThrowMode = v end end })
Throw:Toggle({ Title = "Always Perfect", Value = S.Perfect, Callback = function(v) if not Alive then return end toggleSound(v) S.Perfect = v end })
Throw:Toggle({ Title = "Skip Cutscene", Value = S.SkipCut, Callback = function(v) if not Alive then return end toggleSound(v) S.SkipCut = v end })
Throw:Toggle({ Title = "Use Super Throw", Value = S.SuperThrow, Callback = function(v) if not Alive then return end toggleSound(v) S.SuperThrow = v end })
Throw:Slider({ Title = "Throw Delay", Step = 0.05, Value = { Min = 0.15, Max = 1.5, Default = S.ThrowDelay }, Callback = function(v) if Alive then S.ThrowDelay = v end end })
Throw:Section({ Title = "Manual" })
Throw:Button({ Title = "Throw Once", Callback = function() if Alive then clickSound() oneThrow() end end })
Throw:Button({ Title = "Spam x5", Callback = function() if Alive then clickSound() spamThrow(5) end end })
Throw:Button({ Title = "Spam x10", Callback = function() if Alive then clickSound() spamThrow(10) end end })
Throw:Button({ Title = "TP Throw Line", Callback = function() if Alive then clickSound() pastLine() notify("TP", "Throw line", true) end end })
Throw:Button({ Title = "Emergency Stop", Callback = function() if Alive then clickSound() stopThrow() notify("Stop", "Stopped", true) end end })

local Plot = Window:Tab({ Title = "Plot", Icon = "paw-print" })
Plot:Section({ Title = "Automation" })
Plot:Toggle({ Title = "Auto Best Pets", Value = S.AutoPets, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoPets = v end })
Plot:Toggle({ Title = "Auto Fence Upgrade", Value = S.AutoFence, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoFence = v end })
Plot:Section({ Title = "Actions" })
Plot:Button({ Title = "Equip Best Pets", Callback = function() if not Alive then return end clickSound() local r = inv("Plot_EquipBest") notify("Pets", ((type(r) == "table" and r.Ok) or r) and "Equipped" or "Failed", true) end })
Plot:Button({ Title = "Upgrade Fence", Callback = function() if not Alive then return end clickSound() local r = inv("Plot_UpgradeFence") notify("Fence", ((type(r) == "table" and r.Ok) or r == true) and "Upgraded" or "Failed", true) end })
Plot:Button({ Title = "Sell All Pets", Callback = function() if not Alive then return end clickSound() local r = inv("Plot_SellAll") notify("Sell", ((type(r) == "table" and r.Ok) or r) and "Sold" or "Failed", true) end })

local Shop = Window:Tab({ Title = "Shop", Icon = "shopping-cart" })
Shop:Section({ Title = "Automation" })
Shop:Toggle({ Title = "Auto Offline Claims", Value = S.AutoOffline, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoOffline = v end })
Shop:Toggle({ Title = "Auto Free Gifts", Value = S.AutoGifts, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoGifts = v end })
Shop:Toggle({ Title = "Auto Buy Best Food", Value = S.AutoBuyFood, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoBuyFood = v end })
Shop:Toggle({ Title = "Auto Equip Best Food", Value = S.AutoEquipFood, Callback = function(v) if not Alive then return end toggleSound(v) S.AutoEquipFood = v end })
Shop:Section({ Title = "Manual Food" })
local foods = {}
local list = FoodsCfg and (FoodsCfg.List or FoodsCfg.All) or {}
for i, f in ipairs(list) do foods[#foods + 1] = string.format("#%d %s", i, f.Name or "Food") end
local selFood = 1
Shop:Dropdown({ Title = "Food", Values = #foods > 0 and foods or { "#1 Carrot" }, Value = foods[1] or "#1 Carrot", Callback = function(v)
	if not Alive then return end
	clickSound() local n = v:match("#(%d+)") if n then selFood = tonumber(n) end
end })
Shop:Button({ Title = "Buy Food", Callback = function() if not Alive then return end clickSound() local r = inv("Shop_Buy", selFood) notify("Buy", ((type(r) == "table" and r.Ok) or r == true) and "Bought" or "Failed", true) end })
Shop:Button({ Title = "Equip Food", Callback = function() if not Alive then return end clickSound() local r = inv("Shop_Equip", selFood) notify("Equip", ((type(r) == "table" and r.Ok) or r == true) and "Equipped" or "Failed", true) end })

local TP = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
TP:Section({ Title = "Locations" })
TP:Button({ Title = "Plot Entrance", Callback = function()
	if not Alive then return end
	clickSound()
	local p = myPlot()
	if p then local off = (GameCfg and GameCfg.Plot and GameCfg.Plot.EntranceOffset) or Vector3.new(0, 3.5, -5) tp(p.Position + off) notify("TP", "Plot entrance", true)
	else notify("TP", "Plot not found", false) end
end })
TP:Button({ Title = "Training Spot", Callback = function()
	if not Alive then return end
	clickSound() local s = trainSpot()
	if s then tp(s.CFrame + Vector3.new(0, 3, 0)) notify("TP", "Training", true) else notify("TP", "Not loaded", false) end
end })
TP:Button({ Title = "Throw Line", Callback = function() if Alive then clickSound() pastLine() notify("TP", "Throw line", true) end end })
TP:Button({ Title = "Food Shop", Callback = function()
	if not Alive then return end
	clickSound() local p = myPlot()
	tp(p and (p.Position + Vector3.new(10.5, 3.5, -8.3)) or CFrame.new(10.5, 3.5, -8.3))
	notify("TP", "Shop", true)
end })
TP:Section({ Title = "Plots" })
local selPlot = 1
TP:Dropdown({ Title = "Plot #", Values = { "1", "2", "3", "4", "5", "6" }, Value = "1", Callback = function(v) if Alive then clickSound() selPlot = tonumber(v) or 1 end end })
TP:Button({ Title = "Go to Plot", Callback = function()
	if not Alive then return end
	clickSound()
	local plots = Workspace:FindFirstChild("Plots")
	local t = plots and plots:FindFirstChild(tostring(selPlot))
	if t then
		local pos = t.Position or (t:IsA("Model") and t:GetPivot().Position)
		if pos then tp(pos + Vector3.new(0, 4, -5)) notify("TP", "Plot " .. selPlot, true) return end
	end
	notify("TP", "Plot not available", false)
end })
TP:Section({ Title = "Biomes" })
local biomes = { "Forest", "Savana", "Desert", "Jungle", "Ocean", "Mountains", "Taiga", "Winter", "Hell" }
local selBio = biomes[1]
TP:Dropdown({ Title = "Biome", Values = biomes, Value = biomes[1], Callback = function(v) if Alive then clickSound() selBio = v end end })
TP:Button({ Title = "Go to Biome", Callback = function()
	if not Alive then return end
	clickSound()
	local bf = Workspace:FindFirstChild("Biomes")
	local b = bf and bf:FindFirstChild(selBio)
	if b then
		local p = b:IsA("BasePart") and b or b:FindFirstChildWhichIsA("BasePart")
		if p then tp(p.CFrame + Vector3.new(0, 6, 0)) notify("TP", selBio, true) return end
	end
	notify("TP", "Biome not loaded", false)
end })

local Misc = Window:Tab({ Title = "Player", Icon = "user" })
Misc:Section({ Title = "Performance" })
Misc:Toggle({ Title = "Show FPS / MS Overlay", Value = S.ShowPerf, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.ShowPerf = v
	perfGui.Enabled = v
end })
Misc:Toggle({ Title = "Optimize Game", Value = S.Optimize, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.Optimize = v
	applyOptimize(v)
	notify("Optimize", v and "Boost ON" or "Optimize OFF", true)
end })
Misc:Section({ Title = "Movement" })
Misc:Toggle({ Title = "Speed", Value = S.Speed, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.Speed = v
	if not v then local h = getHum() if h then h.WalkSpeed = 16 end end
end })
Misc:Slider({ Title = "Speed Value", Step = 1, Value = { Min = 16, Max = 200, Default = S.SpeedVal }, Callback = function(v)
	if not Alive then return end
	S.SpeedVal = v
	if S.Speed then local h = getHum() if h and (S.SpeedMode == "WalkSpeed" or S.SpeedMode == "Both") then h.WalkSpeed = v end end
end })
Misc:Dropdown({ Title = "Speed Mode", Values = { "CFrame", "WalkSpeed", "Both" }, Value = S.SpeedMode, Callback = function(v) if Alive then clickSound() S.SpeedMode = v end end })
Misc:Toggle({ Title = "Custom Jump", Value = S.Jump, Callback = function(v)
	if not Alive then return end
	toggleSound(v) S.Jump = v
	local h = getHum()
	if h then h.UseJumpPower = true h.JumpPower = v and S.JumpVal or 50 if not v then h.JumpHeight = 7.2 end end
end })
Misc:Slider({ Title = "Jump Power", Step = 1, Value = { Min = 50, Max = 250, Default = S.JumpVal }, Callback = function(v)
	if not Alive then return end
	S.JumpVal = v
	if S.Jump then
		local h = getHum()
		if h then
			h.UseJumpPower = true h.JumpPower = v
			pcall(function() local g = workspace.Gravity > 0 and workspace.Gravity or 196.2 h.JumpHeight = (v * v) / (2 * g) end)
		end
	end
end })
Misc:Toggle({ Title = "Infinite Jump", Value = S.InfJump, Callback = function(v) if not Alive then return end toggleSound(v) S.InfJump = v end })
Misc:Toggle({ Title = "NoClip", Value = S.NoClip, Callback = function(v) if not Alive then return end toggleSound(v) S.NoClip = v end })
Misc:Toggle({ Title = "Anti AFK", Value = S.AntiAFK, Callback = function(v) if not Alive then return end toggleSound(v) S.AntiAFK = v end })
Misc:Section({ Title = "System" })
Misc:Toggle({ Title = "UI Sounds", Value = S.Sounds, Callback = function(v) if not Alive then return end S.Sounds = v if v then playSound(SFX.Toggle, 0.4, 1.1) end end })
Misc:Button({ Title = "Copy Discord", Callback = function()
	if not Alive then return end
	clickSound()
	local ok = false local cb = setclipboard or toclipboard
	if type(cb) == "function" then ok = pcall(cb, DISCORD) end
	notify("Discord", ok and "Copied!" or DISCORD, ok)
end })
Misc:Button({ Title = "Unload", Callback = function()
	if not Alive then return end
	clickSound()
	if _G.__PotentThrowCleanup then _G.__PotentThrowCleanup() end
end })

-- CLEAN UNLOAD: kills everything
_G.__PotentThrowCleanup = function()
	Alive = false

	-- kill all features
	S.AutoThrow = false
	S.AutoTrain = false
	S.AutoTap = false
	S.AutoStand = false
	S.AutoPets = false
	S.AutoFence = false
	S.AutoOffline = false
	S.AutoGifts = false
	S.AutoBuyFood = false
	S.AutoEquipFood = false
	S.Speed = false
	S.Jump = false
	S.InfJump = false
	S.NoClip = false
	S.Optimize = false
	throwLoop, oneShot, spam = false, false, false

	stopThrow()
	applyOptimize(false)

	-- restore original game modules
	if ThrowMeter and _G.__P_TM_New then ThrowMeter.new = _G.__P_TM_New end
	if ThrowMeter and _G.__P_TM_Run then ThrowMeter.Run = _G.__P_TM_Run end
	if RevealSeq and _G.__P_RS_Play then RevealSeq.Play = _G.__P_RS_Play end
	if RevealSeq and _G.__P_RS_Run then RevealSeq.Run = _G.__P_RS_Run end
	if ThrowCtrl and _G.__P_TC_Start then ThrowCtrl.Start = _G.__P_TC_Start end

	for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
	Conns = {}

	pcall(function()
		local h = getHum()
		if h then
			h.WalkSpeed = 16
			h.JumpPower = 50
			h.JumpHeight = 7.2
			h.UseJumpPower = true
			for _, t in ipairs(h:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end
		end
	end)

	pcall(function() if perfGui then perfGui:Destroy() end end)
	pcall(function()
		local t = (gethui and gethui()) or CoreGui
		for _, c in ipairs(t:GetChildren()) do
			if c.Name:find("WindUI") or c.Name:find("POTENTHUB") or c.Name == "PotentPerfOverlay" then
				c:Destroy()
			end
		end
	end)
	pcall(function() if Window then Window:Destroy() end end)

	_G.__PotentThrowCleanup = nil
	print("POTENT_HUB_FULLY_STOPPED")
end

perfGui.Enabled = S.ShowPerf
if S.Sounds then playSound(SFX.Success, 0.5, 1) end
W:Notify({ Title = "POTENT HUB", Content = "Ready · Unload kills all options", Duration = 4 })
print("POTENT_HUB_READY")
