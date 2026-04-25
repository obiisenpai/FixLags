-- ROY HUB PREMIUM v2 | By Minh Thật | Blox Fruits
-- Fixed & Cleaned Version

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CS = game:GetService("CollectionService")
local RUN = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TelS = game:GetService("TeleportService")
local VU = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- Safe stubs
isfile = isfile or function() return false end
readfile = readfile or function() return "" end
writefile = writefile or function() end
getclipboard = getclipboard or function() return "" end
setclipboard = setclipboard or function() end
sethiddenproperty = sethiddenproperty or function() end
cloneref = cloneref or function(r) return r end
getgc = getgc or function() return {} end
setupvalue = setupvalue or function() end
setfpscap = setfpscap or function() end

-- World detect
local W1, W2, W3 = false, false, false
if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then W1 = true
elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then W2 = true
elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then W3 = true end

-- Globals
StartBring = false; NeedAttacking = false; MonFarm = ""; Mon = ""
PosMon = CFrame.new(0,0,0); MaterialMon = {}; MaterialPos = CFrame.new(0,0,0)

-- _G flags
_G.SelectWeapon     = "Melee"
_G.SelectMaterial   = ""
_G.SelectIsland     = "WindMill"
_G.WalkSpeedValue   = tonumber(isfile("spd.txt") and readfile("spd.txt")) or 26
_G.JumpValue        = tonumber(isfile("jmp.txt") and readfile("jmp.txt")) or 50
_G.FlySpeed         = tonumber(isfile("fly.txt") and readfile("fly.txt")) or 350
_G.FlyEnabled       = false
_G.AutoFarmNearest  = false
_G.AutoSafeMode     = false
_G.AutoFarmBones    = false
_G.AutoKillSoulReaper= false
_G.AutoTradeBones   = false
_G.AutoPray         = false
_G.AutoTryLuck      = false
_G.FarmKatakuri     = false
_G.FarmKatakuriV2   = false
_G.FarmDoughKing    = false
_G.AutoPiratesSea   = false
_G.AutoFactory      = false
_G.AutoFarmChestTween= false
_G.AutoFarmChestBypass= false
_G.AutoKillBoss     = false
_G.AutoKillDarkBeard= false
_G.AutoKillCursed   = false
_G.AutoKillIndra    = false
_G.KillEliteHunter  = false
_G.AutoRandomFruits = false
_G.AutoStoreFruits  = false
_G.TeleportFruit    = false
_G.AutoTeleportFruits=false
_G.AutoTweenIsland  = false
_G.FastAttack       = true
_G.BringMob         = true
_G.WalkOnWater      = true
_G.FullBright       = false
_G.RemoveSkyFog     = false
_G.FPSBoost         = false
_G.AutoRaceV3       = false
_G.AutoRaceV4       = false
_G.InfiniteSoru     = false
_G.DodgeNoCD        = false
_G.InfiniteGeppo    = false
_G.DeleteLava       = false
_G.WhiteScreen      = false
_G.AntiReset        = false
_G.SetHomePoint     = false
_G.AutoHakiToggle   = false
_G.FarmTyrant       = false
_G.SummonTyrant     = false
_G.AutoFarmMaterial = false
_G.AutoFarmQuest    = false
_G.AutoKillEnemy    = false
_G.MobAura          = false
_G.AutoHopAdmin     = true
_G.AutoFarmRaid     = false
_G.AutoBuyFruit     = false

-- Helpers
local function Char() return LP.Character end
local function Root() local c=Char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c=Char(); return c and c:FindFirstChild("Humanoid") end

topos = function(cf) pcall(function() local r=Root(); if r then r.CFrame=cf end end) end
TP1 = topos; BTP = topos

AutoHaki = function()
    pcall(function() RS.Remotes.CommE:FireServer("Buso") end)
end

EquipWeapon = function(name)
    if not name or name=="" then return end
    pcall(function()
        local h = Hum(); if not h then return end
        local tool = LP.Backpack:FindFirstChild(name)
        if tool then h:EquipTool(tool) end
    end)
end

UnEquipWeapon = function()
    pcall(function() local h=Hum(); if h then h:UnequipTools() end end)
end

Hop = function()
    pcall(function() TelS:Teleport(game.PlaceId, LP) end)
end

CheckQuest = function() end

-- Notify helper
local function Notify(t, m)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="RoyHub — "..t,Text=m,Duration=4})
    end)
end

-- ══ FLY (Tween, safe) ════════════════════════════
local FlyConn, FlyBV, FlyBG, FlyOn = nil, nil, nil, false
local FK = {W=false,A=false,S=false,D=false,Space=false,Q=false,E=false,LC=false}

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    local k=i.KeyCode
    if k==Enum.KeyCode.W then FK.W=true elseif k==Enum.KeyCode.A then FK.A=true
    elseif k==Enum.KeyCode.S then FK.S=true elseif k==Enum.KeyCode.D then FK.D=true
    elseif k==Enum.KeyCode.Space then FK.Space=true elseif k==Enum.KeyCode.E then FK.E=true
    elseif k==Enum.KeyCode.Q then FK.Q=true elseif k==Enum.KeyCode.LeftControl then FK.LC=true end
end)
UIS.InputEnded:Connect(function(i)
    local k=i.KeyCode
    if k==Enum.KeyCode.W then FK.W=false elseif k==Enum.KeyCode.A then FK.A=false
    elseif k==Enum.KeyCode.S then FK.S=false elseif k==Enum.KeyCode.D then FK.D=false
    elseif k==Enum.KeyCode.Space then FK.Space=false elseif k==Enum.KeyCode.E then FK.E=false
    elseif k==Enum.KeyCode.Q then FK.Q=false elseif k==Enum.KeyCode.LeftControl then FK.LC=false end
end)

local function StopFly()
    FlyOn=false
    if FlyConn then FlyConn:Disconnect(); FlyConn=nil end
    pcall(function() if FlyBV and FlyBV.Parent then FlyBV:Destroy() end end)
    pcall(function() if FlyBG and FlyBG.Parent then FlyBG:Destroy() end end)
    FlyBV=nil; FlyBG=nil
    pcall(function() local h=Hum(); if h then h.PlatformStand=false end end)
end

local function StartFly()
    local r=Root(); local h=Hum()
    if not r or not h then return end
    StopFly(); FlyOn=true; h.PlatformStand=true
    FlyBV=Instance.new("BodyVelocity",r)
    FlyBV.Velocity=Vector3.zero; FlyBV.MaxForce=Vector3.new(1e9,1e9,1e9); FlyBV.P=1e4
    FlyBG=Instance.new("BodyGyro",r)
    FlyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); FlyBG.P=1e4; FlyBG.D=100; FlyBG.CFrame=r.CFrame
    FlyConn=RUN.Heartbeat:Connect(function(dt)
        if not FlyOn then return end
        local r2=Root(); if not r2 then StopFly(); return end
        local cam=workspace.CurrentCamera; local spd=_G.FlySpeed or 350
        local dir=Vector3.zero
        if FK.W then dir=dir+cam.CFrame.LookVector end
        if FK.S then dir=dir-cam.CFrame.LookVector end
        if FK.A then dir=dir-cam.CFrame.RightVector end
        if FK.D then dir=dir+cam.CFrame.RightVector end
        if FK.Space or FK.E then dir=dir+Vector3.new(0,1,0) end
        if FK.LC or FK.Q then dir=dir-Vector3.new(0,1,0) end
        local target = dir.Magnitude>0 and dir.Unit*spd or Vector3.zero
        FlyBV.Velocity = FlyBV.Velocity:Lerp(target, math.min(dt*12,1))
        if dir.Magnitude>0 and (dir*Vector3.new(1,0,1)).Magnitude>0.01 then
            FlyBG.CFrame=CFrame.new(r2.Position,r2.Position+dir*Vector3.new(1,0,1))
        end
    end)
end

LP.CharacterAdded:Connect(function()
    FlyOn=false; FlyBV=nil; FlyBG=nil
    if FlyConn then FlyConn:Disconnect(); FlyConn=nil end
    if _G.FlyEnabled then task.wait(1.5); StartFly() end
end)

-- ══ STATS ════════════════════════════════════════
local function ApplyStats(char)
    local h=char:WaitForChild("Humanoid",5); if not h then return end
    h.WalkSpeed=_G.WalkSpeedValue; h.JumpPower=_G.JumpValue
    h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() h.WalkSpeed=_G.WalkSpeedValue end)
    h:GetPropertyChangedSignal("JumpPower"):Connect(function() h.JumpPower=_G.JumpValue end)
end
LP.CharacterAdded:Connect(function(c) task.wait(0.5); ApplyStats(c) end)
if LP.Character then task.spawn(function() ApplyStats(LP.Character) end) end

-- ══ FULLBRIGHT ════════════════════════════════════
local OL={A=Lighting.Ambient,CB=Lighting.ColorShift_Bottom,CT=Lighting.ColorShift_Top,B=Lighting.Brightness,GS=Lighting.GlobalShadows}
local function SetFullBright(on)
    if on then Lighting.Ambient=Color3.new(1,1,1);Lighting.ColorShift_Bottom=Color3.new(1,1,1);Lighting.ColorShift_Top=Color3.new(1,1,1);Lighting.Brightness=3;Lighting.GlobalShadows=false
    else Lighting.Ambient=OL.A;Lighting.ColorShift_Bottom=OL.CB;Lighting.ColorShift_Top=OL.CT;Lighting.Brightness=OL.B;Lighting.GlobalShadows=OL.GS end
end

-- ══ ADMINS ════════════════════════════════════════
local Admins={red_game43=true,rip_indra=true,Axiore=true,Polkster=true,wenlocktoad=true,
    Daigrock=true,toilamvidamme=true,oofficialnoobie=true,Uzoth=true,Azarth=true,
    arlthmetic=true,Death_King=true,Lunoven=true,TheGreateAced=true,rip_fud=true,
    drip_mama=true,layandikit12=true,Hingoi=true}

task.spawn(function()
    while task.wait(3) do
        if _G.AutoHopAdmin then
            for _,p in pairs(Players:GetPlayers()) do
                if Admins[p.Name] then Hop(); break end
            end
        end
    end
end)

-- Anti-AFK
pcall(function() VU:CaptureController() end)

-- Keep stats
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local h=Hum(); if not h then return end
            h.WalkSpeed=_G.WalkSpeedValue; h.JumpPower=_G.JumpValue
        end)
    end
end)

-- Tool select loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local s=_G.SelectWeapon
            local tipMatch={Melee="Melee",Sword="Sword",Gun="Gun",["Blox Fruit"]="Blox Fruit"}
            local tip=tipMatch[s]
            if tip then
                for _,v in pairs(LP.Backpack:GetChildren()) do
                    if v:IsA("Tool") and v.ToolTip==tip then _G.SelectWeapon=v.Name end
                end
            end
        end)
    end
end)

-- Join team
pcall(function() RS:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam","Marines") end)

-- ══ MATERIAL DATA ════════════════════════════════
local MatDB={
    ["Magma Ore"]     ={w=W1,mob={"Military Spy"},         pos=CFrame.new(-5850.28,77.28,8848.67)},
    ["Angel Wings"]   ={w=W1,mob={"Royal Soldier"},         pos=CFrame.new(-7827.15,5606.91,-1705.58)},
    ["Leather S1"]    ={w=W1,mob={"Pirate"},                pos=CFrame.new(-1211.87,4.78,3916.83)},
    ["Scrap S1"]      ={w=W1,mob={"Brute"},                 pos=CFrame.new(-1132.42,14.84,4293.3)},
    ["Radioactive"]   ={w=W2,mob={"Factory Staff"},         pos=CFrame.new(-507.78,73,-126.45)},
    ["Mystic Droplet"]={w=W2,mob={"Water Fighter"},         pos=CFrame.new(-3352.9,285.01,-10534.84)},
    ["Magma Ore S2"]  ={w=W2,mob={"Lava Pirate"},           pos=CFrame.new(-5234.6,51.95,-4732.27)},
    ["Leather S2"]    ={w=W2,mob={"Marine Captain"},        pos=CFrame.new(-2010.5,73,-3326.62)},
    ["Ectoplasm"]     ={w=W2,mob={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"},pos=CFrame.new(911.35,125.95,33159.53)},
    ["Scrap S2"]      ={w=W2,mob={"Mercenary"},             pos=CFrame.new(-972.3,73.04,1419.29)},
    ["Leather S3"]    ={w=W3,mob={"Jungle Pirate"},         pos=CFrame.new(-11975.78,331.77,-10620.03)},
    ["Scrap S3"]      ={w=W3,mob={"Pirate Millionaire"},    pos=CFrame.new(-289.63,43.82,5583.66)},
    ["Conjured Cocoa"]={w=W3,mob={"Chocolate Bar Battler"}, pos=CFrame.new(744.79,24.76,-12637.72)},
    ["Dragon Scale"]  ={w=W3,mob={"Dragon Crew Warrior","Dragon Crew Archer"},pos=CFrame.new(5824.06,51.38,-1106.69)},
    ["Gunpowder"]     ={w=W3,mob={"Pistol Billionaire"},    pos=CFrame.new(-379.61,73.84,5928.52)},
    ["Fish Tail"]     ={w=W3,mob={"Fishman Captain"},       pos=CFrame.new(-10961.01,331.79,-8914.29)},
    ["Mini Tusk"]     ={w=W3,mob={"Mithological Pirate"},   pos=CFrame.new(-13516.04,469.81,-6899.16)},
    ["Dark Fragment"] ={w=true,mob={"Order"},               pos=CFrame.new(4875.33,5.652,734.85)},
    ["Vampire Fang"]  ={w=true,mob={"Vampire"},             pos=CFrame.new(-9515.372,164.006,5786.061)},
}
local MatList={}
for k,v in pairs(MatDB) do if v.w then table.insert(MatList,k) end end
table.sort(MatList)
if #MatList==0 then MatList={"Leather S1","Scrap S1"} end

local function SetMat(m) local d=MatDB[m]; if d then MaterialMon=d.mob; MaterialPos=d.pos end end

-- ══ ISLANDS ══════════════════════════════════════
local Islands={
    ["WindMill"]=CFrame.new(979.8,16.5,1429.0),["Marine"]=CFrame.new(-2566.4,6.9,2045.3),
    ["Middle Town"]=CFrame.new(-690.3,15.1,1582.2),["Jungle"]=CFrame.new(-1612.8,36.9,149.1),
    ["Pirate Village"]=CFrame.new(-1181.3,4.8,3803.5),["Desert"]=CFrame.new(944.2,20.9,4373.3),
    ["Snow Island"]=CFrame.new(1347.8,104.7,-1319.7),["MarineFord"]=CFrame.new(-4914.8,51.0,4281.0),
    ["Magma Village"]=CFrame.new(-5247.7,12.9,8505.0),["Fountain City"]=CFrame.new(5127.1,59.5,4105.4),
    ["Sky Island 1"]=CFrame.new(-483.7,332.0,595.3),["Sky Island 2"]=CFrame.new(2284.4,15.2,875.7),
    ["Sky Island 3"]=CFrame.new(-2448.5,73.0,-3210.6),["Prison"]=CFrame.new(4875.3,5.7,734.9),
    ["Colosseum"]=CFrame.new(-11.3,29.3,2771.5),["Under Water"]=CFrame.new(-2850.2,7.4,5355.0),
    ["Shank Room"]=CFrame.new(-1442.2,29.9,-28.4),["The Cafe"]=CFrame.new(-380.5,77.2,255.8),
    ["Dark Area"]=CFrame.new(3780.0,22.7,-3498.6),["Factory"]=CFrame.new(424.1,211.2,-427.5),
    ["Colossuim S2"]=CFrame.new(-1503.6,219.8,1369.3),["Two Snow Mtn"]=CFrame.new(753.1,408.2,-5274.6),
    ["Punk Hazard"]=CFrame.new(-6127.7,16.0,-5040.3),["Zombie Island"]=CFrame.new(-6509,83,-133),
    ["Cursed Ship"]=CFrame.new(923,126,32852),["Mansion"]=CFrame.new(-12471.2,374.9,-7551.7),
    ["Castle On Sea"]=CFrame.new(-5083.3,314.6,-3175.7),["Port Town"]=CFrame.new(-226.8,20.6,5538.3),
    ["Great Tree"]=CFrame.new(2681.3,1682.8,-7191.0),["Hydra Island"]=CFrame.new(5291.2,1005.4,393.8),
    ["Floating Turtle"]=CFrame.new(-13274.5,531.8,-7579.2),["Haunted Castle"]=CFrame.new(-9515.4,164.0,5786.1),
    ["Ice Cream Island"]=CFrame.new(-902.6,79.9,-10988.8),["Peanut Island"]=CFrame.new(-2062.7,50.5,-10232.6),
    ["Cake Island"]=CFrame.new(-1884.8,19.3,-11666.9),["Cocoa Island"]=CFrame.new(87.9,73.6,-12319.5),
    ["Candy Island"]=CFrame.new(-1014.4,149.1,-14556.0),["Tiki Outpost"]=CFrame.new(-16218.7,9.1,445.6),
    ["Dragon Dojo"]=CFrame.new(5743.3,1206.9,936.0),["Graveyard"]=CFrame.new(-8652.9,143.5,6170.5),
    ["Bone Cave"]=CFrame.new(-9508.6,142.1,5737.4),["Dimensional Shift"]=CFrame.new(-2097.3,4776.2,-15013.5),
    ["Temple of Time"]=CFrame.new(28286,14897,103),["Beautiful Pirate"]=CFrame.new(5319,23,-93),
}
local IList
if W1 then IList={"WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert","Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2","Sky Island 3","Prison","Magma Village","Under Water","Fountain City","Shank Room"}
elseif W2 then IList={"The Cafe","Dark Area","Factory","Colossuim S2","Two Snow Mtn","Punk Hazard","Zombie Island","Cursed Ship"}
elseif W3 then IList={"Mansion","Castle On Sea","Port Town","Great Tree","Hydra Island","Floating Turtle","Haunted Castle","Ice Cream Island","Peanut Island","Cake Island","Cocoa Island","Candy Island","Tiki Outpost","Dragon Dojo","Graveyard","Bone Cave","Dimensional Shift","Beautiful Pirate","Temple of Time"}
else IList={"WindMill","Marine","Middle Town","Prison","Colosseum","Fountain City","Cake Island"} end

-- ══ UI BUILD ═════════════════════════════════════
pcall(function()
    if LP.PlayerGui:FindFirstChild("RoyHub") then LP.PlayerGui.RoyHub:Destroy() end
end)

local function Inst(c,p)
    local o=Instance.new(c)
    for k,v in pairs(p) do if k~="P" then pcall(function() o[k]=v end) end end
    if p.P then o.Parent=p.P end
    return o
end
local function Cor(o,r) Inst("UICorner",{CornerRadius=UDim.new(0,r or 6),P=o}) end
local function Str(o,c,t) Inst("UIStroke",{Color=c or Color3.fromRGB(50,35,80),Thickness=t or 1,P=o}) end
local function Pad(o,l,r,t,b) Inst("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b),P=o}) end
local function Lst(o,g,h) Inst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,FillDirection=h and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,Padding=UDim.new(0,g or 0),P=o}) end
local function Tw(o,t,p) TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad),p):Play() end
local function C(r,g,b) return Color3.fromRGB(r,g,b) end

-- Colors
local BG=C(10,10,16); local SIDE=C(13,13,20); local CARD=C(22,22,34); local HDR=C(11,11,17)
local BDR=C(38,32,58); local BDR2=C(50,40,75); local PUR=C(140,60,240); local PUR2=C(120,40,220)
local PDIM=C(55,25,90); local TW=C(220,210,240); local TG=C(110,95,145); local TP=C(175,120,255)
local TOFF=C(48,45,65); local TBDR=C(65,58,90)

local SG=Inst("ScreenGui",{Name="RoyHub",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,P=LP.PlayerGui})

-- Toggle button (draggable)
local TH=Inst("Frame",{Size=UDim2.new(0,52,0,70),Position=UDim2.new(0,16,0.28,0),BackgroundTransparency=1,P=SG})
local TB=Inst("ImageButton",{Size=UDim2.new(0,52,0,52),BackgroundColor3=C(18,14,28),Image="rbxassetid://99153110613948",P=TH})
Cor(TB,26); Str(TB,PUR,2)
local TLB=Inst("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,2),BackgroundColor3=C(14,12,22),Text="Hide",TextColor3=TG,TextSize=9,Font=Enum.Font.GothamBold,P=TH})
Cor(TLB,4); Str(TLB,BDR,1)

local td,tds,tdp=false,nil,nil
TB.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then td=true;tds=i.Position;tdp=TH.Position end end)
UIS.InputChanged:Connect(function(i) if td and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-tds;TH.Position=UDim2.new(tdp.X.Scale,tdp.X.Offset+d.X,tdp.Y.Scale,tdp.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then td=false end end)

-- Main window
local WIN=Inst("Frame",{Name="Win",Size=UDim2.new(0,860,0,540),Position=UDim2.new(0.5,-430,0.5,-270),BackgroundColor3=BG,BorderSizePixel=0,P=SG})
Cor(WIN,10); Str(WIN,BDR,1); Inst("UIScale",{Scale=0.88,P=WIN})

local wd,wds,wdp=false,nil,nil
WIN.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then wd=true;wds=i.Position;wdp=WIN.Position end end)
UIS.InputChanged:Connect(function(i) if wd and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-wds;WIN.Position=UDim2.new(wdp.X.Scale,wdp.X.Offset+d.X,wdp.Y.Scale,wdp.Y.Offset+d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then wd=false end end)

local vis=true
TB.MouseButton1Click:Connect(function()
    if td then return end
    vis=not vis; WIN.Visible=vis; TLB.Text=vis and "Hide" or "Show"
    local s=TB:FindFirstChildOfClass("UIStroke"); if s then s.Color=vis and PUR or BDR end
end)

-- Sidebar
local SBR=Inst("Frame",{Size=UDim2.new(0,230,1,0),BackgroundColor3=SIDE,BorderSizePixel=0,P=WIN})
Cor(SBR,10); Str(SBR,BDR,1)
Inst("Frame",{Size=UDim2.new(0,10,1,0),Position=UDim2.new(1,-10,0,0),BackgroundColor3=SIDE,BorderSizePixel=0,P=SBR})

-- Logo
local LG=Inst("Frame",{Size=UDim2.new(1,0,0,100),BackgroundTransparency=1,P=SBR})
Inst("TextLabel",{Size=UDim2.new(1,0,0,36),Position=UDim2.new(0,0,0,14),BackgroundTransparency=1,Text="ROY HUB",TextColor3=PUR,TextSize=26,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Center,P=LG})
Inst("TextLabel",{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,50),BackgroundTransparency=1,Text="PREMIUM v2",TextColor3=TP,TextSize=12,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Center,P=LG})
Inst("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,68),BackgroundTransparency=1,Text=(W1 and "🌊 Sea 1" or W2 and "🌊 Sea 2" or W3 and "🌊 Sea 3" or "🌊 ?"),TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,P=LG})
Inst("Frame",{Size=UDim2.new(1,-30,0,1),Position=UDim2.new(0,15,0,90),BackgroundColor3=BDR,P=LG})

-- Nav container
local NAV=Inst("Frame",{Size=UDim2.new(1,0,1,-160),Position=UDim2.new(0,0,0,100),BackgroundTransparency=1,P=SBR})
Pad(NAV,10,10,4,4); Lst(NAV,2)

-- User profile
local UPF=Inst("Frame",{Size=UDim2.new(1,-20,0,50),Position=UDim2.new(0,10,1,-58),BackgroundColor3=CARD,P=SBR})
Cor(UPF,8); Str(UPF,BDR,1)
local UAV=Inst("ImageLabel",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,8,0.5,-18),BackgroundColor3=PDIM,Image="rbxassetid://99153110613948",P=UPF})
Cor(UAV,18); Str(UAV,PUR,2)
Inst("TextLabel",{Size=UDim2.new(1,-52,0,18),Position=UDim2.new(0,50,0,7),BackgroundTransparency=1,Text="Royx Hub v2",TextColor3=TP,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,P=UPF})
Inst("TextLabel",{Size=UDim2.new(1,-52,0,14),Position=UDim2.new(0,50,0,26),BackgroundTransparency=1,Text=LP.Name,TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=UPF})

-- Pages + nav
local PAGES={}; local ACT=nil; local NBTN={}
local function ShowPage(n) for k,p in pairs(PAGES) do p.Visible=(k==n) end; ACT=n end

local navList={
    {"Discord","ℹ","Discord"},{"Farm","⌂","Farm"},{"Material","◈","Farm Material"},
    {"Quest","⚔","Quest | Items"},{"Fruits","✿","Fruits"},{"Teleport","⊕","Teleport"},
    {"Player","♟","Player / Fly"},{"Setting","⚙","Setting"},
}
for i,nd in ipairs(navList) do
    local row=Inst("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=i,P=NAV})
    local bg=Inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=PUR2,BackgroundTransparency=1,Text="",AutoButtonColor=false,P=row})
    Cor(bg,7)
    Inst("TextLabel",{Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=nd[2],TextColor3=TG,TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center,P=bg})
    local lbl=Inst("TextLabel",{Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,33,0,0),BackgroundTransparency=1,Text=nd[3],TextColor3=TG,TextSize=13,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,P=bg})
    local function sa(on)
        Tw(bg,0.15,{BackgroundTransparency=on and 0 or 1,BackgroundColor3=on and PUR2 or PUR2})
        lbl.TextColor3=on and C(255,255,255) or TG; lbl.Font=on and Enum.Font.GothamBold or Enum.Font.GothamSemibold
    end
    bg.MouseEnter:Connect(function() if ACT~=nd[1] then Tw(bg,0.1,{BackgroundTransparency=0.5,BackgroundColor3=PDIM}) end end)
    bg.MouseLeave:Connect(function() if ACT~=nd[1] then Tw(bg,0.1,{BackgroundTransparency=1}) end end)
    bg.MouseButton1Click:Connect(function() for _,b in pairs(NBTN) do b(false) end; sa(true); ShowPage(nd[1]) end)
    NBTN[nd[1]]=sa
end

-- Content area
local CON=Inst("Frame",{Size=UDim2.new(1,-230,1,0),Position=UDim2.new(0,230,0,0),BackgroundTransparency=1,P=WIN})
local HH=Inst("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=HDR,BorderSizePixel=0,P=CON})
Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=HH})
Inst("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text="Royx Hub v2 | By Minh Thật",TextColor3=TP,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,P=HH})

local WRAP=Inst("Frame",{Size=UDim2.new(1,0,1,-44),Position=UDim2.new(0,0,0,44),BackgroundTransparency=1,P=CON})
local LSC=Inst("ScrollingFrame",{Size=UDim2.new(1,-278,1,-8),Position=UDim2.new(0,6,0,4),BackgroundTransparency=1,ScrollBarThickness=4,ScrollBarImageColor3=PDIM,ScrollingDirection=Enum.ScrollingDirection.Y,BorderSizePixel=0,CanvasSize=UDim2.new(0,0,0,3000),P=WRAP})
Lst(LSC,6); Pad(LSC,2,2,0,4)
local RPN=Inst("ScrollingFrame",{Size=UDim2.new(0,262,1,-8),Position=UDim2.new(1,-267,0,4),BackgroundTransparency=1,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,1400),ScrollingDirection=Enum.ScrollingDirection.Y,BorderSizePixel=0,P=WRAP})
Lst(RPN,6)

-- ══ UI COMPONENTS ════════════════════════════════
local function Card(p)
    local c=Inst("Frame",{Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=CARD,P=p})
    Cor(c,8); Str(c,BDR,1); Pad(c,12,12,10,12); Lst(c,0); return c
end
local function SH(p,t,o)
    local h=Inst("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,LayoutOrder=o or 0,P=p})
    local iF=Inst("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,0,0.5,-6),BackgroundTransparency=1,P=h})
    for r=0,2 do
        Inst("Frame",{Size=UDim2.new(0,3,0,3),Position=UDim2.new(0,0,0,r*4+1),BackgroundColor3=TP,P=iF})
        Inst("Frame",{Size=UDim2.new(0,7,0,3),Position=UDim2.new(0,4,0,r*4+1),BackgroundColor3=TP,P=iF})
    end
    Inst("TextLabel",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,16,0,0),BackgroundTransparency=1,Text=t,TextColor3=TW,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,P=h})
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=h})
end

local function Tog(p,label,gk,order,sub,init,cb)
    local rh=sub and 44 or 36
    local row=Inst("Frame",{Size=UDim2.new(1,0,0,rh),BackgroundTransparency=1,LayoutOrder=order or 1,P=p})
    Inst("TextLabel",{Size=UDim2.new(1,-50,0,18),Position=UDim2.new(0,0,0,8),BackgroundTransparency=1,Text=label,TextColor3=TW,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=row})
    if sub then Inst("TextLabel",{Size=UDim2.new(1,-50,0,14),Position=UDim2.new(0,0,0,24),BackgroundTransparency=1,Text=sub,TextColor3=TG,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=row}) end
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=row})
    local tr=Inst("TextButton",{Size=UDim2.new(0,40,0,22),Position=UDim2.new(1,-42,0.5,-11),BackgroundColor3=TOFF,Text="",AutoButtonColor=false,P=row})
    Cor(tr,11); Str(tr,TBDR,1)
    local kn=Inst("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=C(70,63,95),P=tr})
    Cor(kn,8)
    local st=(init~=nil) and init or (gk and _G[gk]) or false
    local function upd()
        if st then Tw(tr,0.18,{BackgroundColor3=PUR}); Tw(kn,0.18,{Position=UDim2.new(0,21,0.5,-8),BackgroundColor3=C(255,255,255)})
            local s=tr:FindFirstChildOfClass("UIStroke"); if s then s.Color=PUR end
        else Tw(tr,0.18,{BackgroundColor3=TOFF}); Tw(kn,0.18,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=C(70,63,95)})
            local s=tr:FindFirstChildOfClass("UIStroke"); if s then s.Color=TBDR end end
    end
    upd()
    tr.MouseButton1Click:Connect(function()
        st=not st; if gk then _G[gk]=st end; upd(); if cb then pcall(cb,st) end
    end)
    return {row=row,Set=function(v) st=v; if gk then _G[gk]=v end; upd() end}
end

local function DD(p,label,opts,def,order,gk,cb)
    local f=Inst("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=order or 1,P=p})
    Inst("TextLabel",{Size=UDim2.new(0.4,0,1,0),BackgroundTransparency=1,Text=label,TextColor3=TW,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=f})
    local sel=def or opts[1]
    local db=Inst("TextButton",{Size=UDim2.new(0,160,0,28),Position=UDim2.new(1,-162,0.5,-14),BackgroundColor3=C(24,22,38),Text=sel.."  ▾",TextColor3=TW,TextSize=11,Font=Enum.Font.Gotham,AutoButtonColor=false,P=f})
    Cor(db,6); Str(db,BDR2,1)
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=f})
    local open,lf=false,nil
    local function close() if lf then lf:Destroy(); lf=nil end; open=false end
    db.MouseButton1Click:Connect(function()
        if open then close(); return end; open=true
        local lh=math.min(#opts*26+6,200)
        lf=Inst("ScrollingFrame",{Size=UDim2.new(0,160,0,lh),Position=UDim2.new(1,-162,1,2),BackgroundColor3=C(18,16,28),ZIndex=60,ScrollBarThickness=3,ScrollBarImageColor3=PDIM,CanvasSize=UDim2.new(0,0,0,#opts*26+6),P=f})
        Cor(lf,6); Str(lf,BDR2,1); Lst(lf,0); Pad(lf,0,0,3,3)
        for _,opt in ipairs(opts) do
            local ob=Inst("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=opt==sel and C(38,26,60) or C(18,16,28),Text=opt,TextColor3=opt==sel and TP or TW,TextSize=11,Font=Enum.Font.Gotham,AutoButtonColor=false,ZIndex=61,P=lf})
            ob.MouseEnter:Connect(function() if opt~=sel then Tw(ob,0.08,{BackgroundColor3=C(28,20,45)}) end end)
            ob.MouseLeave:Connect(function() if opt~=sel then Tw(ob,0.08,{BackgroundColor3=C(18,16,28)}) end end)
            ob.MouseButton1Click:Connect(function()
                sel=opt; db.Text=opt.."  ▾"; if gk then _G[gk]=opt end; if cb then pcall(cb,opt) end; close()
            end)
        end
    end)
    return f
end

local function Btn(p,label,order,cb)
    local b=Inst("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=C(20,18,30),Text=label,TextColor3=TG,TextSize=12,Font=Enum.Font.Gotham,AutoButtonColor=false,LayoutOrder=order or 99,P=p})
    Cor(b,6); Str(b,BDR,1)
    b.MouseEnter:Connect(function() Tw(b,0.12,{BackgroundColor3=PDIM,TextColor3=TW}) end)
    b.MouseLeave:Connect(function() Tw(b,0.12,{BackgroundColor3=C(20,18,30),TextColor3=TG}) end)
    if cb then b.MouseButton1Click:Connect(function() pcall(cb) end) end
    return b
end

local function Sld(p,lbl,mn,mx,def,order,gk,cb)
    local f=Inst("Frame",{Size=UDim2.new(1,0,0,50),BackgroundTransparency=1,LayoutOrder=order,P=p})
    Inst("TextLabel",{Size=UDim2.new(0.6,0,0,18),BackgroundTransparency=1,Text=lbl,TextColor3=TW,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=f})
    local vl=Inst("TextLabel",{Size=UDim2.new(0.4,0,0,18),Position=UDim2.new(0.6,0,0,0),BackgroundTransparency=1,Text=tostring(def),TextColor3=TP,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,P=f})
    local tr=Inst("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,24),BackgroundColor3=TOFF,P=f})
    Cor(tr,3)
    local pct=(def-mn)/(mx-mn)
    local fi=Inst("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=PUR,P=tr}); Cor(fi,3)
    local kn=Inst("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(pct,-7,0.5,-7),BackgroundColor3=C(255,255,255),P=tr}); Cor(kn,7)
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,6),BackgroundColor3=BDR,P=f})
    local sl=false
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sl=false end end)
    UIS.InputChanged:Connect(function(i)
        if sl and i.UserInputType==Enum.UserInputType.MouseMovement then
            local r2=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
            local v=math.floor(mn+(mx-mn)*r2)
            vl.Text=tostring(v); fi.Size=UDim2.new(r2,0,1,0); kn.Position=UDim2.new(r2,-7,0.5,-7)
            if gk then _G[gk]=v end; if cb then pcall(cb,v) end
        end
    end)
end

local function Par(p,txt,order)
    local f=Inst("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,LayoutOrder=order,P=p})
    local lb=Inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=txt,TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=f})
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=f})
    return {Set=function(s) lb.Text=s end}
end

local function TB2(p,label,ph,order,cb)
    local f=Inst("Frame",{Size=UDim2.new(1,0,0,52),BackgroundTransparency=1,LayoutOrder=order,P=p})
    Inst("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=label,TextColor3=TW,TextSize=12,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=f})
    local bx=Inst("Frame",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,20),BackgroundColor3=C(16,14,26),P=f})
    Cor(bx,6); Str(bx,BDR2,1)
    local tb=Inst("TextBox",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,PlaceholderText=ph,PlaceholderColor3=TG,Text="",TextColor3=TW,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,P=bx})
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=f})
    tb.FocusLost:Connect(function(ent) if ent and cb then pcall(cb,tb.Text) end end)
end

local function NP(name)
    local pg=Inst("Frame",{Name=name,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false,P=LSC})
    Lst(pg,6); PAGES[name]=pg; return pg
end

-- ══ PAGES ════════════════════════════════════════

-- FARM
local PF=NP("Farm")
local cGF=Card(PF); SH(cGF,"General Farm",0)
DD(cGF,"Select Tool",{"Melee","Sword","Gun","Blox Fruit"},"Melee",1,"SelectWeapon")
DD(cGF,"UI Scale",{"Small","Normal","Large"},"Normal",2,nil,function(v)
    local sc=WIN:FindFirstChildOfClass("UIScale")
    if sc then sc.Scale=(v=="Small" and 0.72 or v=="Large" and 1.0 or 0.88) end
end)
Tog(cGF,"Auto Farm Nearest","AutoFarmNearest",3)
Tog(cGF,"Auto Safe Mode","AutoSafeMode",4)
Tog(cGF,"Mob Aura","MobAura",5)

if W3 then
    local cW3=Card(PF); SH(cW3,"Sea 3 — Pirates Sea",0)
    Tog(cW3,"Auto Pirates Sea","AutoPiratesSea",1,"Farm Raid Pirate")
    local ep=Par(cW3,"Eyes: Loading...",2)
    task.spawn(function() while task.wait(1) do pcall(function()
        local n=0; local m=workspace:FindFirstChild("Map")
        if m then local t=m:FindFirstChild("TikiOutpost"); if t then local il=t:FindFirstChild("IslandModel"); if il then for i=1,4 do local e=il:FindFirstChild("Eye"..i); if e and e:IsA("BasePart") and e.Transparency==0 then n=n+1 end end end end end
        ep.Set("Eyes: "..n.."/4  "..(n==4 and "✅ READY" or "⏳"))
    end) end end)
    Tog(cW3,"Auto Farm Tyrant","FarmTyrant",3)
    Tog(cW3,"Summon Tyrant","SummonTyrant",4)
end
if W2 then
    local cW2=Card(PF); SH(cW2,"Sea 2 — Factory",0)
    Tog(cW2,"Auto Factory","AutoFactory",1,"Spawns Every 1:30")
end

local cFB=Card(PF); SH(cFB,"Farm Bones",0)
local bPar=Par(cFB,"🦴 Bones: Loading...",1)
task.spawn(function() while task.wait(2) do pcall(function()
    local n=RS.Remotes.CommF_:InvokeServer("Bones","Check"); bPar.Set("🦴 Bones: "..tostring(n))
end) end end)
Tog(cFB,"Auto Farm Bones","AutoFarmBones",2)
Tog(cFB,"Auto Kill Soul Reaper","AutoKillSoulReaper",3)
Tog(cFB,"Auto Trade Bones","AutoTradeBones",4)
Tog(cFB,"Auto Pray","AutoPray",5)
Tog(cFB,"Auto Try Luck","AutoTryLuck",6)

local cKT=Card(PF); SH(cKT,"Katakuri",0)
local kPar=Par(cKT,"Cake Prince: Loading...",1)
task.spawn(function() while task.wait(2) do pcall(function()
    local r=RS.Remotes.CommF_:InvokeServer("CakePrinceSpawner"); local ln=#r
    if ln==88 then kPar.Set("Killed: "..r:sub(39,41).."/500")
    elseif ln==87 then kPar.Set("Killed: "..r:sub(39,40).."/500")
    elseif ln==86 then kPar.Set("Killed: "..r:sub(39,39).."/500")
    else kPar.Set("👑 Cake Prince SPAWNED!") end
end) end end)
Tog(cKT,"Farm Katakuri","FarmKatakuri",2)
Tog(cKT,"Farm Katakuri V2","FarmKatakuriV2",3)
Tog(cKT,"Farm Dough King","FarmDoughKing",4)

local cCH=Card(PF); SH(cCH,"Auto Farm Chest",0)
Tog(cCH,"Auto Farm Chest [Tween]","AutoFarmChestTween",1)
Tog(cCH,"Auto Farm Chest [Bypass]","AutoFarmChestBypass",2)

-- MATERIAL
local PM=NP("Material")
local cMM=Card(PM); SH(cMM,"Farm Material v2",0)
local mPar=Par(cMM,"Chọn material rồi bật toggle",1)
DD(cMM,"Material",MatList,MatList[1],2,"SelectMaterial",function(v)
    _G.SelectMaterial=v; SetMat(v)
    local d=MatDB[v]; if d then mPar.Set("Mob: "..table.concat(d.mob,", ")) end
end)
Tog(cMM,"Auto Farm Material","AutoFarmMaterial",3)
Btn(cMM,"TP To Material Spot",4,function()
    if _G.SelectMaterial~="" then SetMat(_G.SelectMaterial); topos(MaterialPos) end
end)

-- QUEST
local PQ=NP("Quest")
local cBS=Card(PQ); SH(cBS,"Boss & Elite",0)
Tog(cBS,"Kill Elite Hunter","KillEliteHunter",1,"Auto quest + kill")
Tog(cBS,"Auto Kill Rip Indra","AutoKillIndra",2)
Tog(cBS,"Auto Kill Cursed Captain","AutoKillCursed",3)
Tog(cBS,"Auto Kill Dark Beard","AutoKillDarkBeard",4)
Tog(cBS,"Auto Farm Raid","AutoFarmRaid",5)
local cKE=Card(PQ); SH(cKE,"Auto Combat",0)
Tog(cKE,"Auto Kill Nearest Enemy","AutoKillEnemy",1)
Tog(cKE,"Auto Farm Quest Mobs","AutoFarmQuest",2,"Theo quest đang active")

-- FRUITS
local PFR=NP("Fruits")
local cFR=Card(PFR); SH(cFR,"Fruit Sniper",0)
Tog(cFR,"Auto Random Fruits","AutoRandomFruits",1)
Tog(cFR,"Auto Store Fruits","AutoStoreFruits",2)
Tog(cFR,"Teleport To Fruit","TeleportFruit",3)
Tog(cFR,"Auto Grab Fruits","AutoTeleportFruits",4)
Tog(cFR,"Auto Buy Fruit (Shop)","AutoBuyFruit",5)

-- TELEPORT
local PT=NP("Teleport")
local cTL=Card(PT); SH(cTL,"Island Teleport",0)
DD(cTL,"Island",IList,IList[1],1,"SelectIsland")
Tog(cTL,"Auto Tween To Island","AutoTweenIsland",2)
Btn(cTL,"Teleport Now",3,function()
    local cf=Islands[_G.SelectIsland]; if cf then topos(cf) end
end)
local cST=Card(PT); SH(cST,"Teleport Sea",0)
Btn(cST,"Sea 1",1,function() pcall(function() RS.Remotes.CommF_:InvokeServer("TravelMain") end) end)
Btn(cST,"Sea 2",2,function() pcall(function() RS.Remotes.CommF_:InvokeServer("TravelDressrosa") end) end)
Btn(cST,"Sea 3",3,function() pcall(function() RS.Remotes.CommF_:InvokeServer("TravelZou") end) end)
local cQTP=Card(PT); SH(cQTP,"Quick TP",0)
local qtps={{"Graveyard",CFrame.new(-8652.9,143.5,6170.5)},{"Bone Cave",CFrame.new(-9508.6,142.1,5737.4)},{"Cake Island",CFrame.new(-1884.8,19.3,-11666.9)},{"Tiki Outpost",CFrame.new(-16218.7,9.1,445.6)},{"Factory S2",CFrame.new(424.1,211.2,-427.5)},{"Colosseum S1",CFrame.new(-11.3,29.3,2771.5)},{"Prison S1",CFrame.new(4875.3,5.7,734.9)},{"Dim Shift",CFrame.new(-2097.3,4776.2,-15013.5)}}
for i,q in ipairs(qtps) do local cf=q[2]; Btn(cQTP,q[1],i,function() topos(cf) end) end

-- PLAYER / FLY
local PP=NP("Player")
local cFL=Card(PP); SH(cFL,"✈ Fly — Tween Safe (Speed 350)",0)
Inst("TextLabel",{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text="WASD = Di chuyển  |  Space/E = Lên  |  Ctrl/Q = Xuống\nBodyVelocity Tween — không bypass physics",TextColor3=TG,TextSize=10,Font=Enum.Font.Gotham,TextWrapped=true,LayoutOrder=1,P=cFL})
Tog(cFL,"Enable Fly","FlyEnabled",2,nil,false,function(v)
    _G.FlyEnabled=v; if v then StartFly() else StopFly() end
end)
Sld(cFL,"Fly Speed",50,1200,350,3,"FlySpeed",function(v) writefile("fly.txt",tostring(v)) end)
Btn(cFL,"Stop Fly",4,function() _G.FlyEnabled=false; StopFly() end)

local cMV=Card(PP); SH(cMV,"Combat & Movement",0)
Sld(cMV,"Walk Speed",16,600,_G.WalkSpeedValue,1,"WalkSpeedValue",function(v)
    writefile("spd.txt",tostring(v)); pcall(function() LP.Character.Humanoid.WalkSpeed=v end)
end)
Sld(cMV,"Jump Power",50,500,_G.JumpValue,2,"JumpValue",function(v)
    writefile("jmp.txt",tostring(v)); pcall(function() LP.Character.Humanoid.JumpPower=v end)
end)
Tog(cMV,"Fast Attack","FastAttack",3,nil,true)
Tog(cMV,"Bring Mob","BringMob",4,nil,true)
Tog(cMV,"Infinite Soru","InfiniteSoru",5)
Tog(cMV,"Dodge No Cooldown","DodgeNoCD",6)
Tog(cMV,"Infinite Geppo","InfiniteGeppo",7)
Tog(cMV,"Auto Haki","AutoHakiToggle",8)
Tog(cMV,"Auto Race V3","AutoRaceV3",9)
Tog(cMV,"Auto Race V4","AutoRaceV4",10)

-- SETTING
local PS=NP("Setting")
local cSV=Card(PS); SH(cSV,"Server",0)
TB2(cSV,"Join Job ID","Paste Job ID...",1,function(v)
    if v~="" then pcall(function() TelS:TeleportToPlaceInstance(game.PlaceId,v) end) end
end)
Btn(cSV,"Join from Clipboard",2,function()
    local id=tostring(getclipboard())
    if id~="" then pcall(function() TelS:TeleportToPlaceInstance(game.PlaceId,id,LP) end) end
end)
Btn(cSV,"Rejoin",3,function() TelS:Teleport(game.PlaceId,LP) end)
Btn(cSV,"Server Hop",4,function() Hop() end)
Tog(cSV,"Anti-Reset (Hop/30min)","AntiReset",5,nil,false,function(v)
    if not v then return end
    task.spawn(function()
        while _G.AntiReset do task.wait(1800)
            if not _G.AntiReset then break end; Hop()
        end
    end)
end)
Tog(cSV,"Auto Hop Admin","AutoHopAdmin",6,nil,true)

local cMS=Card(PS); SH(cMS,"Visual / Misc",0)
Tog(cMS,"Walk on Water","WalkOnWater",1,nil,true)
Tog(cMS,"Full Bright","FullBright",2,nil,false,function(v) SetFullBright(v) end)
Tog(cMS,"Remove Sky Fog","RemoveSkyFog",3,nil,false,function(v)
    if v then pcall(function()
        if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
        if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
        if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
    end) end
end)
Tog(cMS,"Delete Lava","DeleteLava",4)
Tog(cMS,"FPS Boost","FPSBoost",5,nil,false,function(v)
    if v then for _,o in ipairs(game:GetDescendants()) do
        if o:IsA("BasePart") then o.Material=Enum.Material.SmoothPlastic; o.Reflectance=0
        elseif o:IsA("Decal") or o:IsA("Texture") then pcall(function() o:Destroy() end)
        elseif o:IsA("ParticleEmitter") or o:IsA("Trail") then o.Enabled=false end
    end; pcall(function() setfpscap(60) end) end
end)
Tog(cMS,"White Screen","WhiteScreen",6,nil,false,function(v)
    pcall(function() RUN:Set3dRenderingEnabled(not v) end)
end)
Tog(cMS,"Set Home Point","SetHomePoint",7)
Btn(cMS,"Join Pirates",8,function() pcall(function() RS.Remotes.CommF_:InvokeServer("SetTeam","Pirates") end) end)
Btn(cMS,"Join Marines",9,function() pcall(function() RS.Remotes.CommF_:InvokeServer("SetTeam","Marines") end) end)
Btn(cMS,"Open Title",10,function()
    pcall(function() RS.Remotes.CommF_:InvokeServer("getTitles"); LP.PlayerGui.Main.Titles.Visible=true end)
end)

local cCD=Card(PS); SH(cCD,"Redeem Codes",0)
local codes={"NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS","FIGHT4FRUIT","NOEXPLOITER","NOOB2ADMIN","CODESLIDE","ADMINHACKED","ADMINDARES","fruitconcepts","krazydares","TRIPLEABUSE","SEATROLLING","24NOADMIN","REWARDFUN","Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews","TheGreatAce","SECRET_ADMIN","SUB2GAMERROBOT_RESET1","SUB2OFFICIALNOOBIE","AXIORE","BIGNEWS","BLUXXY","CHANDLER","ENYU_IS_PRO","FUDD10","FUDD10_V2","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","SUB2CAPTAINMAUI","SUB2DAIGROCK","SUB2FER999","SUB2NOOBMASTER123","SUB2UNCLEKIZARU","TANTAIGAMING","THEGREATACE"}
local cdPar=Par(cCD,"Nhấn để redeem tất cả",1)
Btn(cCD,"🎁 Redeem All Codes",2,function()
    local ok,fail=0,0
    for _,c2 in ipairs(codes) do
        local s=pcall(function() RS:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(c2) end)
        if s then ok=ok+1 else fail=fail+1 end; task.wait(0.08)
    end
    cdPar.Set("✅ "..ok.." redeemed, ❌ "..fail.." failed")
end)

-- DISCORD
local PDI=NP("Discord")
local cDI=Card(PDI); SH(cDI,"Community",0)
Inst("TextLabel",{Size=UDim2.new(1,0,0,60),BackgroundTransparency=1,Text="Tham gia Discord Royx Hub!\nNhận update & hỗ trợ 24/7\n\n🔷  Royx Hub [ Pro ]",TextColor3=TW,TextSize=12,Font=Enum.Font.Gotham,TextWrapped=true,LayoutOrder=1,P=cDI})
Btn(cDI,"Copy Invite",2,function() pcall(function() setclipboard("Royx Hub [ Pro ]") end) end)
local cIF=Card(PDI); SH(cIF,"Info",0)
Inst("TextLabel",{Size=UDim2.new(1,0,0,80),BackgroundTransparency=1,Text="Roy Hub Premium v2\nBy: Minh Thật\nGame: Blox Fruits\nWorld: "..(W1 and "Sea 1" or W2 and "Sea 2" or W3 and "Sea 3" or "?").."\n\nFly | Farm | Material | Teleport\nBones | Katakuri | Tyrant | Boss",TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,P=cIF})

-- ══ RIGHT PANEL ══════════════════════════════════
Inst("Frame",{Size=UDim2.new(1,0,0,110),BackgroundColor3=PDIM,LayoutOrder=1,P=RPN})

local cST2=Inst("Frame",{Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=CARD,LayoutOrder=2,P=RPN})
Cor(cST2,8); Str(cST2,BDR,1); Pad(cST2,12,12,10,12); Lst(cST2,0)
Inst("TextLabel",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Text="⚡ Live Status",TextColor3=TP,TextSize=14,Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=0,P=cST2})
Inst("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=BDR,LayoutOrder=1,P=cST2})

local SL={}
local function SR(key,txt,lo)
    local r=Inst("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=lo,P=cST2})
    local lb=Inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=txt,TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,P=r})
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BDR,P=r})
    SL[key]=lb
end
SR("world","🌊 World: "..(W1 and "Sea 1" or W2 and "Sea 2" or W3 and "Sea 3" or "?"),2)
SR("player","👤 "..LP.Name,3)
SR("farm","⌂ Farm: OFF",4)
SR("fly","✈ Fly: OFF",5)
SR("bones","🦴 Bones: —",6)
SR("fruit","✿ Fruit: —",7)
SR("weapon","⚔ Weapon: Melee",8)
SR("mat","◈ Material: —",9)

local cSEA=Inst("Frame",{Size=UDim2.new(1,0,0,10),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=CARD,LayoutOrder=3,P=RPN})
Cor(cSEA,8); Str(cSEA,BDR,1); Pad(cSEA,12,12,10,12); Lst(cSEA,0)
Inst("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="Sea 3",TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,LayoutOrder=0,P=cSEA})
Tog(cSEA,"Auto Pirates Sea","AutoPiratesSea",1,"Farm Raid Pirate")
Inst("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="Sea 2",TextColor3=TG,TextSize=11,Font=Enum.Font.Gotham,LayoutOrder=2,P=cSEA})
Tog(cSEA,"Auto Factory","AutoFactory",3)

-- ══ ACTIVATE ═════════════════════════════════════
ShowPage("Farm"); NBTN["Farm"](true)
WIN.Size=UDim2.new(0,0,0,0); WIN.Position=UDim2.new(0.5,0,0.5,0)
Tw(WIN,0.35,{Size=UDim2.new(0,860,0,540),Position=UDim2.new(0.5,-430,0.5,-270)})

-- ══ STATUS UPDATER ════════════════════════════════
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local acts={}
            if _G.AutoFarmNearest then table.insert(acts,"Nearest") end
            if _G.FarmKatakuri then table.insert(acts,"Kata") end
            if _G.FarmKatakuriV2 then table.insert(acts,"KataV2") end
            if _G.AutoFarmBones then table.insert(acts,"Bones") end
            if _G.AutoFarmMaterial then table.insert(acts,"Mat:".._G.SelectMaterial) end
            if _G.FarmTyrant then table.insert(acts,"Tyrant") end
            if _G.FarmDoughKing then table.insert(acts,"Dough") end
            if SL.farm then SL.farm.Text="⌂ "..(#acts>0 and table.concat(acts,",") or "OFF") end
            if SL.fly then SL.fly.Text="✈ "..(FlyOn and "ON spd:".._G.FlySpeed or "OFF") end
            if SL.weapon then SL.weapon.Text="⚔ "..tostring(_G.SelectWeapon) end
            if SL.mat then SL.mat.Text="◈ "..(_G.SelectMaterial~="" and _G.SelectMaterial or "—") end
        end)
        pcall(function()
            local n=RS.Remotes.CommF_:InvokeServer("Bones","Check")
            if SL.bones then SL.bones.Text="🦴 "..tostring(n) end
        end)
    end
end)

-- Fruit scanner
task.spawn(function()
    while task.wait(2) do pcall(function()
        local r=Root(); if not r then return end
        local best,bd="—",math.huge
        for _,v in pairs(workspace:GetChildren()) do
            if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                local d=(v.Handle.Position-r.Position).Magnitude
                if d<bd then bd=d; best=v.Name.." ("..math.floor(d).."m)" end
            end
        end
        if SL.fruit then SL.fruit.Text="✿ "..best end
    end) end
end)

-- ══ ALL LOGIC LOOPS ═══════════════════════════════

-- Auto Farm Nearest
task.spawn(function()
    while task.wait(0.05) do
        if _G.AutoFarmNearest then
            pcall(function()
                local r=Root(); if not r then return end
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart")
                       and mob.Humanoid.Health>0 and (r.Position-mob.HumanoidRootPart.Position).Magnitude<=5000 then
                        repeat
                            task.wait(0.05)
                            StartBring=true; AutoHaki(); EquipWeapon(_G.SelectWeapon)
                            topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                            mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                            mob.HumanoidRootPart.Transparency=1
                            mob.Humanoid.JumpPower=0; mob.Humanoid.WalkSpeed=0
                            mob.HumanoidRootPart.CanCollide=false
                            MonFarm=mob.Name; PosMon=mob.HumanoidRootPart.CFrame
                        until not _G.AutoFarmNearest or not mob.Parent or mob.Humanoid.Health<=0
                        StartBring=false
                    end
                end
            end)
        end
    end
end)

-- Mob Aura
task.spawn(function()
    while task.wait(0.1) do
        if _G.MobAura then
            pcall(function()
                local r=Root(); if not r then return end
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart")
                       and mob.Humanoid.Health>0 and (r.Position-mob.HumanoidRootPart.Position).Magnitude<=40 then
                        VU:CaptureController()
                        VU:Button1Down(Vector2.new(1280,672))
                        VU:Button1Up(Vector2.new(1280,672))
                    end
                end
            end)
        end
    end
end)

-- Auto Safe Mode
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoSafeMode then
            pcall(function()
                local r=Root(); if r then r.CFrame=r.CFrame*CFrame.new(0,200,0) end
            end)
        end
    end
end)

-- Auto Pirates Sea
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoPiratesSea then
            pcall(function()
                local pirateCF=CFrame.new(-5496.17,313.77,-2841.53)
                local r=Root(); if not r then return end
                if (Vector3.new(-5539.31,313.8,-2972.37)-r.Position).Magnitude<=500 then
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if _G.AutoPiratesSea and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid")
                           and mob.Humanoid.Health>0 and (mob.HumanoidRootPart.Position-r.Position).Magnitude<2000 then
                            repeat
                                task.wait()
                                AutoHaki(); EquipWeapon(_G.SelectWeapon); NeedAttacking=true
                                mob.HumanoidRootPart.CanCollide=false
                                mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                            until mob.Humanoid.Health<=0 or not mob.Parent or not _G.AutoPiratesSea
                            NeedAttacking=false
                        end
                    end
                else
                    topos(pirateCF)
                end
            end)
        end
    end
end)

-- Auto Factory
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFactory then
            pcall(function()
                if workspace.Enemies:FindFirstChild("Core") then
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name=="Core" and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                topos(CFrame.new(448.47,199.36,-441.39))
                                VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                            until mob.Humanoid.Health<=0 or not _G.AutoFactory
                        end
                    end
                else
                    topos(CFrame.new(448.47,199.36,-441.39))
                end
            end)
        end
    end
end)

-- Farm Tyrant
task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmTyrant then
            pcall(function()
                local names={"Isle Outlaw","Island Boy","Isle Champion","Serpent Hunter","Skull Slayer"}
                if not workspace.Enemies:FindFirstChild("Tyrant of the Skies") then
                    local found=false
                    for _,n in ipairs(names) do if workspace.Enemies:FindFirstChild(n) then found=true; break end end
                    if found then
                        for _,mob in pairs(workspace.Enemies:GetChildren()) do
                            local isT=false
                            for _,n in ipairs(names) do if mob.Name==n then isT=true; break end end
                            if isT and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                    StartBring=true; mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                    PosMon=mob.HumanoidRootPart.CFrame; MonFarm=mob.Name
                                    topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0)); NeedAttacking=true
                                until not _G.FarmTyrant or not mob.Parent or mob.Humanoid.Health<=0
                            end
                        end
                    else
                        topos(CFrame.new(-16194.0,155.2,1420.7))
                    end
                else
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name=="Tyrant of the Skies" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,40,0)); NeedAttacking=true
                            until not _G.FarmTyrant or not mob.Parent or mob.Humanoid.Health<=0
                            task.wait(1)
                        end
                    end
                end
            end)
        end
    end
end)

-- Summon Tyrant (tween walk)
local TSPOS={
    CFrame.new(-16250.24,158.17,1313.02),CFrame.new(-16297.06,159.32,1317.22),
    CFrame.new(-16335.10,159.33,1324.89),CFrame.new(-16288.61,158.17,1470.37),
    CFrame.new(-16258.00,156.76,1461.40),CFrame.new(-16245.41,158.44,1463.37),
    CFrame.new(-16212.47,158.17,1466.34),
}
task.spawn(function()
    while task.wait(1) do
        if _G.SummonTyrant then
            pcall(function()
                for _,cf in ipairs(TSPOS) do
                    if not _G.SummonTyrant then break end
                    local r=Root(); if not r then break end
                    local dist=(r.Position-cf.Position).Magnitude
                    local tw=TS:Create(r,TweenInfo.new(dist/300,Enum.EasingStyle.Linear),{CFrame=cf*CFrame.new(0,5,0)})
                    tw:Play(); tw.Completed:Wait(); task.wait(0.5)
                    for _,k in ipairs({"Z","X","C","V"}) do
                        VIM:SendKeyEvent(true,Enum.KeyCode[k],false,game)
                        task.wait(0.05)
                        VIM:SendKeyEvent(false,Enum.KeyCode[k],false,game)
                    end
                    VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672)); task.wait(3)
                end
            end)
        end
    end
end)

-- Auto Farm Bones
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmBones then
            pcall(function()
                local bns={"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}
                local hasAny=false
                for _,n in ipairs(bns) do if workspace.Enemies:FindFirstChild(n) then hasAny=true; break end end
                if hasAny then
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        local isB=false
                        for _,n in ipairs(bns) do if mob.Name==n then isB=true; break end end
                        if isB and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); AutoHaki(); NeedAttacking=true; EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                StartBring=true; MonFarm=mob.Name; PosMon=mob.HumanoidRootPart.CFrame
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                pcall(function() sethiddenproperty(LP,"SimulationRadius",math.huge) end)
                            until not _G.AutoFarmBones or not mob.Parent or mob.Humanoid.Health<=0
                        end
                    end
                else
                    topos(CFrame.new(-9508.57,142.14,5737.36))
                end
            end)
        end
    end
end)

-- Auto Kill Soul Reaper
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoKillSoulReaper then
            pcall(function()
                if not workspace.Enemies:FindFirstChild("Soul Reaper") then
                    if LP.Backpack:FindFirstChild("Hallow Essence") or (LP.Character and LP.Character:FindFirstChild("Hallow Essence")) then
                        topos(CFrame.new(-8932.32,146.83,6062.55)); EquipWeapon("Hallow Essence")
                    end
                else
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name:find("Soul Reaper") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); EquipWeapon(_G.SelectWeapon); AutoHaki()
                                mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                VU:CaptureController(); VU:Button1Down(Vector2.new(1280,670))
                                mob.HumanoidRootPart.Transparency=1
                            until mob.Humanoid.Health<=0 or not _G.AutoKillSoulReaper
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Trade Bones
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoTradeBones then
            pcall(function() RS.Remotes.CommF_:InvokeServer("Bones","Buy",1,1) end)
        end
    end
end)

-- Auto Pray
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoPray then
            pcall(function()
                topos(CFrame.new(-8652.99,143.45,6170.51)); task.wait(0.1)
                RS.Remotes.CommF_:InvokeServer("gravestoneEvent",1)
            end)
        end
    end
end)

-- Auto Try Luck
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoTryLuck then
            pcall(function()
                topos(CFrame.new(-8652.99,143.45,6170.51)); task.wait(0.1)
                RS.Remotes.CommF_:InvokeServer("gravestoneEvent",2)
            end)
        end
    end
end)

-- Farm Katakuri
local kataPos=CFrame.new(-2130.81,69.96,-12327.84)
task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmKatakuri then
            pcall(function()
                local npcs={"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"}
                if not workspace.Enemies:FindFirstChild("Cake Prince") then
                    local hasNPC=false
                    for _,n in ipairs(npcs) do if workspace.Enemies:FindFirstChild(n) then hasNPC=true; break end end
                    if hasNPC then
                        for _,mob in pairs(workspace.Enemies:GetChildren()) do
                            local isN=false
                            for _,n in ipairs(npcs) do if mob.Name==n then isN=true; break end end
                            if isN and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                    StartBring=true; mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                    PosMon=mob.HumanoidRootPart.CFrame; MonFarm=mob.Name
                                    topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0)); NeedAttacking=true
                                until not _G.FarmKatakuri or not mob.Parent or mob.Humanoid.Health<=0
                            end
                        end
                    else
                        topos(kataPos)
                    end
                    topos(kataPos)
                else
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name=="Cake Prince" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(4,10,10)); NeedAttacking=true
                            until not _G.FarmKatakuri or not mob.Parent or mob.Humanoid.Health<=0
                            task.wait(1)
                        end
                    end
                end
            end)
        end
    end
end)

-- Farm Katakuri V2
task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmKatakuriV2 then
            pcall(function()
                local char=Char(); if not char then return end
                local hasGod=LP.Backpack:FindFirstChild("God's Chalice") or char:FindFirstChild("God's Chalice")
                if not hasGod then
                    local hasSweet=LP.Backpack:FindFirstChild("Sweet Chalice") or char:FindFirstChild("Sweet Chalice")
                    if hasSweet then
                        local res=RS.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                        if res and res:find("Do you want to open the portal now?") then
                            RS.Remotes.CommF_:InvokeServer("CakePrinceSpawner")
                        elseif workspace.Enemies:FindFirstChild("Baking Staff") or workspace.Enemies:FindFirstChild("Head Baker") then
                            for _,mob in pairs(workspace.Enemies:GetChildren()) do
                                if (mob.Name=="Baking Staff" or mob.Name=="Head Baker" or mob.Name=="Cake Guard" or mob.Name=="Cookie Crafter") and mob.Humanoid.Health>0 then
                                    repeat
                                        task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                        PosMon=mob.HumanoidRootPart.CFrame
                                        topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                        mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                                        mob.HumanoidRootPart.Size=Vector3.new(70,70,70); MonFarm=mob.Name
                                        VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                                    until not _G.FarmKatakuriV2 or not mob.Parent or mob.Humanoid.Health<=0
                                end
                            end
                        else
                            topos(CFrame.new(-1820.06,210.75,-12297.5))
                        end
                    else
                        local hasRed=LP.Backpack:FindFirstChild("Red Key") or char:FindFirstChild("Red Key")
                        if hasRed then
                            RS.Remotes.CommF_:InvokeServer("CakeScientist","Check")
                        else
                            task.wait(0.5); RS.Remotes.CommF_:InvokeServer("EliteHunter")
                        end
                    end
                end
            end)
        end
    end
end)

-- Farm Dough King
task.spawn(function()
    while task.wait(0.1) do
        if _G.FarmDoughKing then
            pcall(function()
                if workspace.Enemies:FindFirstChild("Dough King") then
                    for _,mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name=="Dough King" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health>0 then
                            repeat
                                task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.Size=Vector3.new(70,70,70)
                                mob.HumanoidRootPart.CanCollide=false
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,-40,0))
                                VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                            until not _G.FarmDoughKing or not mob.Parent or mob.Humanoid.Health<=0
                        end
                    end
                else
                    topos(CFrame.new(-2009.28,4532.97,-14937.31))
                end
            end)
        end
    end
end)

-- Chest Tween
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmChestTween then
            pcall(function()
                local r=Root(); if not r then return end
                local best,bd=nil,math.huge
                for _,ch in ipairs(CS:GetTagged("_ChestTagged")) do
                    if not ch:GetAttribute("IsDisabled") then
                        local d=(ch:GetPivot().Position-r.Position).Magnitude
                        if d<bd then bd=d; best=ch end
                    end
                end
                if best then topos(CFrame.new(best:GetPivot().Position)) end
            end)
        end
    end
end)

-- Chest Bypass
task.spawn(function()
    while task.wait() do
        if _G.AutoFarmChestBypass then
            local char=LP.Character or LP.CharacterAdded:Wait()
            local t0=tick()
            while _G.AutoFarmChestBypass and tick()-t0<4 do
                pcall(function()
                    char=LP.Character or LP.CharacterAdded:Wait()
                    local best,bd=nil,math.huge
                    for _,ch in ipairs(CS:GetTagged("_ChestTagged")) do
                        if not ch:GetAttribute("IsDisabled") then
                            local d=(ch:GetPivot().Position-char:GetPivot().Position).Magnitude
                            if d<bd then bd=d; best=ch end
                        end
                    end
                    if best then char:PivotTo(CFrame.new(best:GetPivot().Position)) end
                end)
                task.wait(0.15)
            end
            if _G.AutoFarmChestBypass and LP.Character then
                pcall(function() LP.Character:BreakJoints(); LP.CharacterAdded:Wait() end)
            end
        end
    end
end)

-- Auto Farm Material
task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoFarmMaterial and _G.SelectMaterial~="" then
            pcall(function()
                SetMat(_G.SelectMaterial)
                if not MaterialMon or #MaterialMon==0 then return end
                local found=false
                for _,n in ipairs(MaterialMon) do if workspace.Enemies:FindFirstChild(n) then found=true; break end end
                if found then
                    for _,n in ipairs(MaterialMon) do
                        for _,mob in pairs(workspace.Enemies:GetChildren()) do
                            if mob.Name==n and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    PosMon=mob.HumanoidRootPart.CFrame; MonFarm=mob.Name
                                    mob.HumanoidRootPart.CanCollide=false; mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                                    topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                until not _G.AutoFarmMaterial or not mob.Parent or mob.Humanoid.Health<=0
                            end
                        end
                    end
                else
                    if _G.SelectMaterial=="Ectoplasm" then
                        pcall(function() RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(923.21,126.97,32852.83)) end)
                    end
                    topos(MaterialPos)
                end
            end)
        end
    end
end)

-- Kill Elite Hunter
task.spawn(function()
    while task.wait(0.1) do
        if _G.KillEliteHunter then
            pcall(function()
                local qUI=LP.PlayerGui:FindFirstChild("Main") and LP.PlayerGui.Main:FindFirstChild("Quest")
                if qUI and qUI.Visible then
                    local qt=qUI.Container.QuestTitle.Title.Text
                    if qt:find("Diablo") or qt:find("Deandre") or qt:find("Urban") then
                        for _,mob in pairs(workspace.Enemies:GetChildren()) do
                            if (mob.Name=="Diablo" or mob.Name=="Deandre" or mob.Name=="Urban")
                               and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health>0 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    NeedAttacking=true; mob.HumanoidRootPart.CanCollide=false
                                    mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                                    topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                    VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                                until not _G.KillEliteHunter or mob.Humanoid.Health<=0 or not mob.Parent
                                NeedAttacking=false
                            end
                        end
                    end
                else
                    pcall(function() RS.Remotes.CommF_:InvokeServer("EliteHunter") end)
                end
            end)
        end
    end
end)

-- Auto Kill Rip Indra
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoKillIndra then
            pcall(function()
                local indra=workspace.Enemies:FindFirstChild("Rip_Indra") or workspace.Enemies:FindFirstChild("Rip Indra")
                if indra and indra:FindFirstChild("Humanoid") and indra.Humanoid.Health>0 then
                    repeat
                        task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                        indra.HumanoidRootPart.Size=Vector3.new(60,60,60); indra.HumanoidRootPart.CanCollide=false
                        topos(indra.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                        VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                    until not _G.AutoKillIndra or not indra.Parent or indra.Humanoid.Health<=0
                else
                    pcall(function() RS.Remotes.CommF_:InvokeServer("requestEntrance",Vector3.new(-2097.3,4776.2,-15013.5)) end)
                    topos(CFrame.new(-2097.3,4776.2,-15013.5))
                end
            end)
        end
    end
end)

-- Auto Kill Dark Beard
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoKillDarkBeard then
            pcall(function()
                local boss=workspace.Enemies:FindFirstChild("Darkbeard") or workspace.Enemies:FindFirstChild("Dark Beard")
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health>0 then
                    repeat
                        task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                        boss.HumanoidRootPart.Size=Vector3.new(60,60,60); boss.HumanoidRootPart.CanCollide=false
                        topos(boss.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                        VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                    until not _G.AutoKillDarkBeard or not boss.Parent or boss.Humanoid.Health<=0
                else
                    topos(CFrame.new(3780.03,22.65,-3498.59))
                end
            end)
        end
    end
end)

-- Auto Kill Cursed Captain
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoKillCursed then
            pcall(function()
                local boss=workspace.Enemies:FindFirstChild("Cursed Captain")
                if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health>0 then
                    repeat
                        task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                        boss.HumanoidRootPart.Size=Vector3.new(60,60,60); boss.HumanoidRootPart.CanCollide=false
                        topos(boss.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                        VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                    until not _G.AutoKillCursed or not boss.Parent or boss.Humanoid.Health<=0
                else
                    topos(CFrame.new(923,126,32852))
                end
            end)
        end
    end
end)

-- Auto Farm Raid
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmRaid then
            pcall(function()
                local r=Root(); if not r then return end
                local best,bd=nil,math.huge
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                        local d=(mob.HumanoidRootPart.Position-r.Position).Magnitude
                        if d<bd then bd=d; best=mob end
                    end
                end
                if best then
                    AutoHaki(); EquipWeapon(_G.SelectWeapon)
                    best.HumanoidRootPart.CanCollide=false; best.HumanoidRootPart.Size=Vector3.new(60,60,60)
                    topos(best.HumanoidRootPart.CFrame*CFrame.new(0,30,0)); NeedAttacking=true
                else
                    NeedAttacking=false
                end
            end)
        end
    end
end)

-- Auto Kill Nearest Enemy
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoKillEnemy then
            pcall(function()
                local r=Root(); if not r then return end
                local best,bd=nil,math.huge
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                        local d=(mob.HumanoidRootPart.Position-r.Position).Magnitude
                        if d<bd then bd=d; best=mob end
                    end
                end
                if best then
                    AutoHaki(); EquipWeapon(_G.SelectWeapon)
                    topos(best.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                    VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
                end
            end)
        end
    end
end)

-- Auto Farm Quest Mobs
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarmQuest then
            pcall(function()
                local qUI=LP.PlayerGui:FindFirstChild("Main") and LP.PlayerGui.Main:FindFirstChild("Quest")
                if not qUI or not qUI.Visible then return end
                local title=qUI.Container.QuestTitle.Title.Text:lower()
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health>0 then
                        local mobLow=mob.Name:lower()
                        for word in mobLow:gmatch("%S+") do
                            if title:find(word,1,true) and #word>=4 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    StartBring=true; MonFarm=mob.Name; PosMon=mob.HumanoidRootPart.CFrame
                                    mob.HumanoidRootPart.CanCollide=false; mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                                    topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0)); NeedAttacking=true
                                until not _G.AutoFarmQuest or not mob.Parent or mob.Humanoid.Health<=0
                                StartBring=false; NeedAttacking=false
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Random Fruits
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoRandomFruits then
            pcall(function() RS.Remotes.CommF_:InvokeServer("Cousin","Buy") end)
        end
    end
end)

-- Auto Store Fruits
local fruitPairs={
    {"Rocket Fruit","Rocket-Rocket"},{"Spin Fruit","Spin-Spin"},{"Blade Fruit","Blade-Blade"},
    {"Spring Fruit","Spring-Spring"},{"Bomb Fruit","Bomb-Bomb"},{"Smoke Fruit","Smoke-Smoke"},
    {"Spike Fruit","Spike-Spike"},{"Flame Fruit","Flame-Flame"},{"Eagle Fruit","Eagle-Eagle"},
    {"Ice Fruit","Ice-Ice"},{"Sand Fruit","Sand-Sand"},{"Dark Fruit","Dark-Dark"},
    {"Diamond Fruit","Diamond-Diamond"},{"Light Fruit","Light-Light"},{"Rubber Fruit","Rubber-Rubber"},
    {"Creation Fruit","Creation-Creation"},{"Ghost Fruit","Ghost-Ghost"},{"Magma Fruit","Magma-Magma"},
    {"Quake Fruit","Quake-Quake"},{"Buddha Fruit","Buddha-Buddha"},{"Love Fruit","Love-Love"},
    {"Spider Fruit","Spider-Spider"},{"Sound Fruit","Sound-Sound"},{"Phoenix Fruit","Phoenix-Phoenix"},
    {"Portal Fruit","Portal-Portal"},{"Lightning Fruit","Lightning-Lightning"},{"Pain Fruit","Pain-Pain"},
    {"Blizzard Fruit","Blizzard-Blizzard"},{"Gravity Fruit","Gravity-Gravity"},{"Mammoth Fruit","Mammoth-Mammoth"},
    {"T-Rex Fruit","T-Rex-T-Rex"},{"Dough Fruit","Dough-Dough"},{"Shadow Fruit","Shadow-Shadow"},
    {"Venom Fruit","Venom-Venom"},{"Gas Fruit","Gas-Gas"},{"Control Fruit","Control-Control"},
    {"Spirit Fruit","Spirit-Spirit"},{"Leopard Fruit","Leopard-Leopard"},{"Yeti Fruit","Yeti-Yeti"},
    {"Kitsune Fruit","Kitsune-Kitsune"},{"Dragon Fruit","Dragon-Dragon"},
}
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoStoreFruits then
            pcall(function()
                local char=LP.Character or LP.CharacterAdded:Wait()
                for _,pair in ipairs(fruitPairs) do
                    local tool=LP.Backpack:FindFirstChild(pair[1]) or char:FindFirstChild(pair[1])
                    if tool then RS.Remotes.CommF_:InvokeServer("StoreFruit",pair[2],tool); break end
                end
            end)
        end
    end
end)

-- Teleport To Fruit
task.spawn(function()
    while task.wait(0.2) do
        if _G.TeleportFruit then
            pcall(function()
                local r=Root(); if not r then return end
                local best,bd=nil,math.huge
                for _,v in pairs(workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        local d=(v.Handle.Position-r.Position).Magnitude
                        if d<bd then bd=d; best=v end
                    end
                end
                if best then topos(best.Handle.CFrame) end
            end)
        end
    end
end)

-- Auto Grab Fruits
task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoTeleportFruits then
            pcall(function()
                local r=Root(); if not r then return end
                for _,v in pairs(workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        r.CFrame=v.Handle.CFrame
                    end
                end
            end)
        end
    end
end)

-- Auto Buy Fruit
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoBuyFruit then
            pcall(function() RS.Remotes.CommF_:InvokeServer("BuyFruitShop") end)
        end
    end
end)

-- Auto Tween Island
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoTweenIsland and _G.SelectIsland then
            pcall(function()
                local cf=Islands[_G.SelectIsland]; if not cf then return end
                if _G.SelectIsland=="Mansion" or _G.SelectIsland=="Castle On Sea" then
                    local ok=pcall(function() RS.Remotes.CommF_:InvokeServer("requestEntrance",cf.Position) end)
                    if not ok then topos(cf) end
                else
                    topos(cf)
                end
            end)
        end
    end
end)

-- Bring Mob
task.spawn(function()
    while task.wait(0.1) do
        if _G.BringMob and MonFarm~="" then
            pcall(function()
                local r=Root(); if not r then return end
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name==MonFarm and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid")
                       and mob.Humanoid.Health>0 and (mob.HumanoidRootPart.Position-r.Position).Magnitude<=400 then
                        mob.HumanoidRootPart.CFrame=PosMon
                        mob.HumanoidRootPart.CanCollide=false; mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                        if mob.Humanoid:FindFirstChild("Animator") then pcall(function() mob.Humanoid.Animator:Destroy() end) end
                        pcall(function() sethiddenproperty(LP,"SimulationRadius",math.huge) end)
                    end
                end
            end)
        end
    end
end)

-- Skills auto-use during fight
task.spawn(function()
    while task.wait(0.3) do
        if NeedAttacking then
            pcall(function()
                for _,k in ipairs({"Z","X","C","V"}) do
                    VIM:SendKeyEvent(true,Enum.KeyCode[k],false,game); task.wait(0.03)
                    VIM:SendKeyEvent(false,Enum.KeyCode[k],false,game)
                end
                VU:CaptureController(); VU:Button1Down(Vector2.new(1280,672))
            end)
        end
    end
end)

-- Walk on Water
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local wp=workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("WaterBase-Plane")
            if wp then wp.Size=_G.WalkOnWater and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
        end)
    end
end)

-- Delete Lava
task.spawn(function()
    while task.wait(2) do
        if _G.DeleteLava then
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("lava") then pcall(function() v:Destroy() end) end
            end
        end
    end
end)

-- Set Home Point
task.spawn(function()
    while task.wait(1) do
        if _G.SetHomePoint then pcall(function() RS.Remotes.CommF_:InvokeServer("SetSpawnPoint") end) end
    end
end)

-- Auto Haki
task.spawn(function()
    while task.wait(0.1) do if _G.AutoHakiToggle then pcall(AutoHaki) end end
end)

-- Auto Race V3
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoRaceV3 then pcall(function() RS.Remotes.CommE:FireServer("ActivateAbility") end) end
    end
end)

-- Auto Race V4
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoRaceV4 then
            pcall(function()
                local char=Char(); if not char then return end
                local energy=char:FindFirstChild("RaceEnergy") or char:FindFirstChild("CyborgEnergy")
                local trans=char:FindFirstChild("RaceTransformed")
                if energy and energy.Value>=1 and (not trans or not trans.Value) then
                    VIM:SendKeyEvent(true,Enum.KeyCode.Y,false,game); task.wait(0.1)
                    VIM:SendKeyEvent(false,Enum.KeyCode.Y,false,game); task.wait(5)
                end
            end)
        end
    end
end)

-- Infinite Soru
task.spawn(function()
    while task.wait(1) do
        if _G.InfiniteSoru then
            pcall(function()
                local char=Char(); if not char then return end
                for _,v in next,getgc() do
                    pcall(function()
                        if getfenv(v).script==char:WaitForChild("Soru") then
                            for idx,val in pairs(debug.getupvalues and debug.getupvalues(v) or {}) do
                                if type(val)=="table" and val.LastUse then setupvalue(v,idx,{LastAfter=0,LastUse=0}) end
                            end
                        end
                    end)
                end
            end)
        end
    end
end)

-- Dodge No CD
task.spawn(function()
    while task.wait(0.5) do
        if _G.DodgeNoCD then
            pcall(function()
                local char=Char(); if not char then return end
                for _,v in next,getgc() do
                    pcall(function()
                        if typeof(v)=="function" and getfenv(v).script==char:WaitForChild("Dodge") then
                            for idx,val in next,getupvalues(v) do
                                if tostring(val)=="0.4" then setupvalue(v,idx,0) end
                            end
                        end
                    end)
                end
            end)
        end
    end
end)

-- Infinite Geppo
task.spawn(function()
    while task.wait(1) do
        if _G.InfiniteGeppo then
            pcall(function()
                local char=Char(); if not char then return end
                for _,v in next,getgc() do
                    pcall(function()
                        if getfenv(v).script==char:WaitForChild("Geppo") then
                            for idx,val in next,getupvalues(v) do
                                if tostring(val)=="0" then setupvalue(v,idx,0) end
                            end
                        end
                    end)
                end
            end)
        end
    end
end)

-- Fast Attack
local u4,u5=nil,nil
pcall(function()
    for _,folder in ipairs({RS.Util,RS.Common,RS.Remotes,RS.Assets}) do
        pcall(function()
            for _,ch in ipairs(folder:GetChildren()) do
                if ch:IsA("RemoteEvent") and ch:GetAttribute("Id") then u5=ch:GetAttribute("Id"); u4=ch end
            end
        end)
    end
end)
task.spawn(function()
    while task.wait(0.001) do
        if _G.FastAttack then
            pcall(function()
                local char=Char(); if not char then return end
                local r=Root(); if not r then return end
                local targets={}
                for _,folder in ipairs({workspace.Enemies}) do
                    for _,mob in ipairs(folder:GetChildren()) do
                        local mr=mob:FindFirstChild("HumanoidRootPart"); local mh=mob:FindFirstChild("Humanoid")
                        if mob~=char and mr and mh and mh.Health>0 and (mr.Position-r.Position).Magnitude<=60 then
                            for _,part in ipairs(mob:GetChildren()) do
                                if part:IsA("BasePart") then table.insert(targets,{mob,part}) end
                            end
                        end
                    end
                end
                local tool=char:FindFirstChildOfClass("Tool")
                if #targets>0 and tool then
                    pcall(function()
                        require(RS.Modules.Net):RemoteEvent("RegisterHit",true)
                        RS.Modules.Net["RE/RegisterAttack"]:FireServer()
                        local head=targets[1][1]:FindFirstChild("Head")
                        if head then
                            RS.Modules.Net["RE/RegisterHit"]:FireServer(head,targets,{},
                                tostring(LP.UserId):sub(2,4)..tostring(coroutine.running()):sub(11,15))
                        end
                    end)
                end
            end)
        end
    end
end)

-- Notify on load
task.spawn(function()
    task.wait(2)
    Notify("Loaded ✅","Roy Hub v2 | "..(W1 and "Sea 1" or W2 and "Sea 2" or W3 and "Sea 3" or "?"))
end)

print("[RoyHub v2] ✅ LOADED | "..LP.Name.." | "..(W1 and "Sea 1" or W2 and "Sea 2" or W3 and "Sea 3" or "?"))
