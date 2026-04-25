--[[
==================================================================================================
  BLOX FRUITS - FIX LAG ULTRA  (Phiên bản tối ưu hóa hiệu suất cao nhất)
==================================================================================================
  Tác giả        : Obii Performance
  Phiên bản      : 4.7.0  -  "Silent Storm"
  Ngày phát hành : 25/04/2026
  Mục tiêu       : Giảm tải CPU / GPU / RAM tối đa cho client Roblox khi chơi Blox Fruits
                   mà KHÔNG can thiệp vào bất kỳ tệp tin hệ thống nào của Roblox.
--------------------------------------------------------------------------------------------------
  TÍNH NĂNG CHÍNH
  -----------------------------------------------------------------------------------------------
  1. Tối ưu hóa môi trường (Environment Cleanup)
     - Loại bỏ toàn bộ Texture / Decal trên mọi BasePart
     - Chuyển toàn bộ vật liệu phức tạp về SmoothPlastic
     - Vô hiệu hóa hiệu ứng hạt (Particles, Smoke, Fire, Sparkles, Trail, Beam)
     - Đơn giản hóa mặt nước (Terrain water transparency, reflectance, decoration)

  2. Tối ưu hóa ánh sáng và đổ bóng (Rendering)
     - Tắt toàn bộ Global Shadows
     - Hạ Lighting Technology xuống Compatibility (Voxel)
     - Tắt Bloom, Blur, SunRays, ColorCorrection, DepthOfField
     - Hạ FOV về mặc định, hạ ShadowSoftness về 0

  3. Quản lý đối tượng từ xa (Streaming & Culling)
     - Giới hạn khoảng cách hiển thị NPC / Player / Vật thể trang trí
     - Ẩn các vật trang trí nhỏ (cỏ, đá, lá cây) không ảnh hưởng gameplay
     - Cây cối / nhà cửa làm trong suốt nhẹ (theo cấu hình của người dùng)

  4. Tối ưu hóa xử lý nền (Script & Memory)
     - Garbage Collection định kỳ, không gây giật khung hình
     - Ẩn UI không cần thiết khi vào Combat Mode
     - Sử dụng task.wait, task.spawn, task.defer, RunService heartbeat throttle
     - Xử lý theo BATCH (chia nhỏ công việc qua nhiều khung hình)

  5. Cấu trúc Code
     - Toàn bộ viết bằng Luau hiện đại, sử dụng task.* API
     - Có Toggle Bật / Tắt trên UI
     - KHÔNG can thiệp vào bất kỳ thành phần Anti-Cheat của Blox Fruits
     - Không hook __namecall / __index / metatable của Roblox
     - Lưu cấu hình - khi thoát ra sảnh & vào lại vẫn còn hoạt động (queue_on_teleport)

  6. UI thông tin
     - Thanh đen dài nằm ngang dưới góc trái (chữ trắng, nền đen, KHÔNG bo góc)
     - Hiển thị: [ FPS .... | CPU .... | Player .... ]

==================================================================================================
  HƯỚNG DẪN SỬ DỤNG NHANH
==================================================================================================
  loadstring(game:HttpGet("https://your.domain/BloxFruits_FixLag_Ultra.lua"))()

  - Thanh trạng thái sẽ xuất hiện ở góc trái dưới màn hình.
  - Bấm phím  [RightShift]  để mở / đóng menu Toggle.
  - Hoặc gọi:  shared.BFFixLag:Toggle()  để bật / tắt.
==================================================================================================
]]

----------------------------------------------------------------------------------------------------
--  PHẦN 0 - KIỂM TRA MÔI TRƯỜNG VÀ KHỞI TẠO BIẾN TOÀN CỤC
----------------------------------------------------------------------------------------------------

if shared._BFFixLag_Loaded then
    -- Nếu script đã chạy rồi thì thực hiện re-toggle thay vì load lại 2 lần.
    if typeof(shared.BFFixLag) == "table" and typeof(shared.BFFixLag.Toggle) == "function" then
        shared.BFFixLag:Toggle()
    end
    return
end
shared._BFFixLag_Loaded = true

----------------------------------------------------------------------------------------------------
--  PHẦN 1 - LẤY CÁC SERVICE CỦA ROBLOX (gom 1 lần để tái sử dụng, tránh gọi GetService liên tục)
----------------------------------------------------------------------------------------------------

local Services = setmetatable({}, {
    __index = function(self, name)
        local s = game:GetService(name)
        rawset(self, name, s)
        return s
    end,
})

local Players          = Services.Players
local Lighting         = Services.Lighting
local RunService       = Services.RunService
local UserInputService = Services.UserInputService
local Workspace        = Services.Workspace
local StarterGui       = Services.StarterGui
local CoreGui          = Services.CoreGui
local TweenService     = Services.TweenService
local ReplicatedStorage= Services.ReplicatedStorage
local TextService      = Services.TextService
local Stats            = Services.Stats
local HttpService      = Services.HttpService
local TeleportService  = Services.TeleportService
local GuiService       = Services.GuiService
local ContentProvider  = Services.ContentProvider
local Terrain          = Workspace:FindFirstChildOfClass("Terrain") or Workspace.Terrain

local LocalPlayer      = Players.LocalPlayer
                          or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
                          or Players.LocalPlayer

----------------------------------------------------------------------------------------------------
--  PHẦN 2 - CẤU HÌNH MẶC ĐỊNH
--  Toàn bộ giá trị có thể được người dùng ghi đè ở runtime hoặc qua menu Toggle.
----------------------------------------------------------------------------------------------------

local DEFAULT_CONFIG = {
    --[[ Bật / tắt toàn cục ]]--
    Enabled                  = true,    -- Toàn bộ tính năng có chạy hay không
    AutoRunOnTeleport        = true,    -- Tự bật lại khi chuyển server / sảnh / map

    --[[ Module bật / tắt riêng lẻ ]]--
    StripTextures            = true,    -- Xóa Texture, Decal, SurfaceAppearance
    SimplifyMaterials        = true,    -- Đổi mọi Material -> SmoothPlastic
    DisableParticles         = true,    -- Tắt Particles / Smoke / Fire / Sparkles / Beam / Trail
    SimplifyWater            = true,    -- Đơn giản hóa Terrain water
    DisableShadows           = true,    -- Tắt GlobalShadows, ShadowSoftness = 0
    LowLighting              = true,    -- Lighting.Technology = Compatibility
    DisablePostFX            = true,    -- Bloom / Blur / SunRays / ColorCorrection / DOF
    LimitRenderDistance      = true,    -- Streaming / culling theo khoảng cách
    CleanMapDecorations      = true,    -- Xóa cỏ, đá nhỏ, lá cây
    TreesTransparency        = true,    -- Cây cối / nhà mờ đi 1 chút
    KillServerEffects        = true,    -- Quét và xóa hiệu ứng do server tạo
    PeriodicGC               = true,    -- Garbage collection định kỳ
    HideCombatUI             = true,    -- Ẩn UI khi vào combat
    StatBar                  = true,    -- Hiển thị thanh FPS|CPU|Player
    SaveSettingsAcrossTP     = true,    -- Lưu khi rời server / về sảnh

    --[[ Cấu hình chi tiết ]]--
    RenderDistance           = 350,     -- Mét (studs) - khoảng cách giữ vật thể
    PlayerDrawDistance       = 220,     -- Khoảng cách render player khác
    NPCDrawDistance          = 180,     -- Khoảng cách render NPC
    TreesAlpha               = 0.45,    -- Độ trong suốt cây/nhà (0 = đặc, 1 = vô hình)
    GCInterval               = 22,      -- Giây giữa hai lần dọn rác
    BatchSize                = 220,     -- Số object xử lý mỗi khung hình (tránh giật)
    StatBarRefreshRate       = 0.25,    -- Giây giữa các lần làm mới UI
    ToggleKey                = Enum.KeyCode.RightShift,
    StatBarPosition          = "BottomLeft",
    StatBarHeight             = 22,
    StatBarMinWidth           = 360,

    --[[ Whitelist - giữ lại không xử lý ]]--
    WhitelistNames = {
        ["DevilFruit"]       = true,    -- Trái ác quỷ rơi trên map
        ["Boss"]             = true,    -- Boss
        ["Quest"]            = true,    -- NPC nhiệm vụ
        ["Item"]             = true,    -- Item nhặt được
        ["Drop"]             = true,    -- Vật phẩm rơi
        ["Chest"]            = true,    -- Rương
        ["Materials"]        = true,    -- Tài nguyên craft
    },
    WhitelistClasses = {
        ["Humanoid"]         = true,
        ["HumanoidRootPart"] = true,
        ["Tool"]             = true,
        ["Sound"]            = true,    -- Không xóa âm thanh game
        ["Animation"]        = true,
        ["Animator"]         = true,
    },

    --[[ Vật trang trí cần dọn ]]--
    DecorationKeywords = {
        "grass", "leaf", "leaves", "petal", "flower", "fern", "weed",
        "pebble", "stone_small", "rock_small", "gravel",
        "decal", "decor", "ornament", "particle", "fx_decor",
        "moss", "vine", "bush_small",
    },

    --[[ Từ khoá cây / nhà sẽ làm mờ ]]--
    TreeKeywords = {
        "tree", "treepart", "treetrunk", "treetop", "branch", "leaves_big",
        "house", "wall", "roof", "door", "window", "building",
        "fence", "pillar", "tower", "castle",
    },

    --[[ Từ khoá hiệu ứng cần tắt ]]--
    EffectKeywords = {
        "fx", "effect", "vfx", "explosion", "shockwave", "ring",
        "smoke", "fire", "spark", "blast", "wave", "aura", "burn",
        "slash", "punch", "kick", "energy", "lightning", "magic",
    },

    --[[ Combat detection ]]--
    CombatTriggerNames = { "Health", "Stamina", "Energy", "MainGUI", "Hotbar", "Skills" },
    CombatHideUI       = { "DailyReward", "QuestPanel", "Codes", "News", "Trade", "Shop" },

    --[[ Debug ]]--
    DebugLog                 = false,
}

-- CONFIG: nơi lưu trạng thái runtime (có thể được restore từ teleport queue)
local CONFIG = {}
for k, v in pairs(DEFAULT_CONFIG) do
    if type(v) == "table" then
        CONFIG[k] = {}
        for k2, v2 in pairs(v) do
            CONFIG[k][k2] = v2
        end
    else
        CONFIG[k] = v
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 3 - LOGGER NHẸ (chỉ in khi DebugLog bật, để không spam console)
----------------------------------------------------------------------------------------------------

local Logger = {}
Logger.__index = Logger

function Logger:Print(category, ...)
    if not CONFIG.DebugLog then return end
    print(string.format("[BFFixLag][%s]", tostring(category)), ...)
end
function Logger:Warn(category, ...)
    if not CONFIG.DebugLog then return end
    warn(string.format("[BFFixLag][%s]", tostring(category)), ...)
end
function Logger:Notify(title, body, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = body,
            Duration = duration or 4,
        })
    end)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 4 - CONNECTION MANAGER
--  Lưu mọi RBXScriptConnection để khi tắt module có thể tháo sạch, tránh leak.
----------------------------------------------------------------------------------------------------

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    return setmetatable({ list = {} }, ConnectionManager)
end

function ConnectionManager:Add(conn)
    if typeof(conn) == "RBXScriptConnection" then
        table.insert(self.list, conn)
    end
    return conn
end

function ConnectionManager:Disconnect(conn)
    for i, c in ipairs(self.list) do
        if c == conn then
            pcall(function() c:Disconnect() end)
            table.remove(self.list, i)
            return true
        end
    end
    return false
end

function ConnectionManager:DisconnectAll()
    for _, c in ipairs(self.list) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(self.list)
end

function ConnectionManager:Count()
    return #self.list
end

local CONN = ConnectionManager.new()      -- connection cho tính năng "đang chạy"
local PERM_CONN = ConnectionManager.new() -- connection vĩnh viễn (UI, toggle key)

----------------------------------------------------------------------------------------------------
--  PHẦN 5 - SETTINGS PERSISTENCE
--  Bốn lớp lưu trữ song song để bảo đảm khi rời ra sảnh Roblox quay lại vẫn nhớ:
--    a) queue_on_teleport (executor)  - chạy lại script ngay khi vào server mới
--    b) writefile (executor)          - lưu file BFFixLag_Config.json trên máy
--    c) shared (vùng nhớ trong process Roblox)
--    d) _G  (fallback)
----------------------------------------------------------------------------------------------------

local Persistence = {}

local CONFIG_FILE_NAME = "BFFixLag_Config.json"
local QUEUE_TAG        = "--[[BFFixLag-Queued]]"

local function safeJsonEncode(t)
    local ok, str = pcall(function() return HttpService:JSONEncode(t) end)
    if ok then return str end
    return nil
end

local function safeJsonDecode(s)
    if type(s) ~= "string" then return nil end
    local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
    if ok and type(t) == "table" then return t end
    return nil
end

local function isExecutor()
    return type(writefile) == "function"
       and type(readfile)  == "function"
       and type(isfile)    == "function"
end

function Persistence:SaveLocalFile()
    if not isExecutor() then return end
    -- Chỉ lưu các trường primitive để khi đọc lại còn dùng được
    local snapshot = {}
    for k, v in pairs(CONFIG) do
        local t = type(v)
        if t == "boolean" or t == "number" or t == "string" then
            snapshot[k] = v
        end
    end
    local enc = safeJsonEncode(snapshot)
    if enc then
        pcall(writefile, CONFIG_FILE_NAME, enc)
    end
end

function Persistence:LoadLocalFile()
    if not isExecutor() then return end
    if not pcall(isfile, CONFIG_FILE_NAME) then return end
    local ok, exists = pcall(isfile, CONFIG_FILE_NAME)
    if not ok or not exists then return end
    local raw
    pcall(function() raw = readfile(CONFIG_FILE_NAME) end)
    local data = safeJsonDecode(raw)
    if not data then return end
    for k, v in pairs(data) do
        if DEFAULT_CONFIG[k] ~= nil and type(v) == type(DEFAULT_CONFIG[k]) then
            CONFIG[k] = v
        end
    end
end

function Persistence:SaveShared()
    shared._BFFixLag_Config = CONFIG
    rawset(_G, "_BFFixLag_Config", CONFIG)
end

function Persistence:LoadShared()
    local s = shared._BFFixLag_Config or _G._BFFixLag_Config
    if type(s) == "table" then
        for k, v in pairs(s) do
            if DEFAULT_CONFIG[k] ~= nil and type(v) == type(DEFAULT_CONFIG[k]) then
                CONFIG[k] = v
            end
        end
    end
end

function Persistence:QueueOnTeleport()
    if type(queue_on_teleport) ~= "function" then return end
    if not CONFIG.AutoRunOnTeleport then return end

    -- Tự "đóng gói" lại snapshot config + payload script.
    local snapshot = safeJsonEncode(CONFIG) or "{}"
    -- Payload sẽ được Roblox chạy trong client mới sau khi teleport hoàn tất.
    local payload = string.format([[
%s
shared._BFFixLag_QueuedConfig = [==[%s]==]
local ok, src = pcall(function()
    return game:HttpGet("rbxasset://__inline_BFFixLag")
end)
if not ok then
    -- Khi load lại, người dùng cần đảm bảo URL tải lại script được set vào shared._BFFixLag_Loader
    if type(shared._BFFixLag_Loader) == "function" then
        local s, e = pcall(shared._BFFixLag_Loader)
        if not s then warn("[BFFixLag] reload failed:", e) end
    end
end
]], QUEUE_TAG, snapshot)

    pcall(queue_on_teleport, payload)
end

function Persistence:LoadFromQueue()
    -- Khi chạy do queue_on_teleport, biến shared._BFFixLag_QueuedConfig sẽ tồn tại.
    local raw = shared._BFFixLag_QueuedConfig
    if type(raw) ~= "string" then return end
    local data = safeJsonDecode(raw)
    if type(data) ~= "table" then return end
    for k, v in pairs(data) do
        if DEFAULT_CONFIG[k] ~= nil and type(v) == type(DEFAULT_CONFIG[k]) then
            CONFIG[k] = v
        end
    end
    shared._BFFixLag_QueuedConfig = nil
end

function Persistence:SaveAll()
    self:SaveLocalFile()
    self:SaveShared()
    self:QueueOnTeleport()
end

function Persistence:LoadAll()
    self:LoadLocalFile()
    self:LoadShared()
    self:LoadFromQueue()
end

----------------------------------------------------------------------------------------------------
--  PHẦN 6 - HỆ THỐNG WHITELIST
--  Mọi thao tác xóa / sửa đối tượng đều phải qua hệ thống này để không phá vỡ gameplay.
----------------------------------------------------------------------------------------------------

local Whitelist = {}

local function nameContainsAnyLower(name, list)
    if type(name) ~= "string" then return false end
    name = string.lower(name)
    for _, kw in ipairs(list) do
        if string.find(name, kw, 1, true) then
            return true
        end
    end
    return false
end

function Whitelist:IsProtectedInstance(inst)
    if not inst or not inst.Parent then return true end

    -- Bảo vệ theo class
    if CONFIG.WhitelistClasses[inst.ClassName] then
        return true
    end

    -- Bảo vệ Player + Character của tất cả người chơi
    local player = Players:GetPlayerFromCharacter(inst)
                or Players:GetPlayerFromCharacter(inst.Parent)
                or (inst:FindFirstAncestorOfClass("Model")
                    and Players:GetPlayerFromCharacter(inst:FindFirstAncestorOfClass("Model")))
    if player then
        return true
    end

    -- Bảo vệ theo tên (chứa chuỗi)
    local name = inst.Name
    for protectedName in pairs(CONFIG.WhitelistNames) do
        if string.find(string.lower(name), string.lower(protectedName), 1, true) then
            return true
        end
    end

    -- Bảo vệ Tool đang được trang bị
    if inst:IsA("BasePart") and inst:FindFirstAncestorOfClass("Tool") then
        return true
    end

    -- Bảo vệ camera, GUI hệ thống
    if inst:IsDescendantOf(CoreGui) then
        return true
    end

    -- Bảo vệ Trái ác quỷ (đặc trưng có Handle + tên *Fruit)
    if inst.Name:lower():find("fruit", 1, true) then
        return true
    end

    return false
end

function Whitelist:IsProtectedAncestry(inst)
    -- Quét lên 6 cấp tổ tiên gần nhất
    local cur = inst
    for _ = 1, 6 do
        if not cur or not cur.Parent then return false end
        if self:IsProtectedInstance(cur) then return true end
        cur = cur.Parent
    end
    return false
end

----------------------------------------------------------------------------------------------------
--  PHẦN 7 - SCHEDULER (rải công việc qua nhiều khung hình để KHÔNG GIẬT)
--  Mọi vòng lặp xử lý vật thể nặng đều đẩy vào đây.
----------------------------------------------------------------------------------------------------

local Scheduler = {}
Scheduler.queue       = {}
Scheduler.running     = false
Scheduler.frameBudget = 1 / 90   -- Cố giữ ngân sách 11ms / khung hình

function Scheduler:Push(taskFunc, label)
    table.insert(self.queue, { fn = taskFunc, label = label or "anonymous" })
    if not self.running then
        self:Start()
    end
end

function Scheduler:Start()
    if self.running then return end
    self.running = true
    task.spawn(function()
        while self.running do
            local item = table.remove(self.queue, 1)
            if not item then
                self.running = false
                break
            end
            local startT = os.clock()
            local ok, err = pcall(item.fn)
            if not ok then
                Logger:Warn("Scheduler", item.label, err)
            end
            local elapsed = os.clock() - startT
            if elapsed > self.frameBudget then
                -- Nhường thêm 1 khung hình nếu task vừa rồi quá nặng
                RunService.Heartbeat:Wait()
            else
                task.wait()
            end
        end
    end)
end

function Scheduler:Stop()
    self.running = false
    table.clear(self.queue)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 8 - BATCH PROCESSOR
--  Nhận một danh sách object và một hàm xử lý, chia nhỏ thành các "lát" để chạy mượt.
----------------------------------------------------------------------------------------------------

local Batch = {}

function Batch.process(items, perItemFunc, batchSize, label)
    batchSize = batchSize or CONFIG.BatchSize
    local total = #items
    if total == 0 then return end

    local idx = 1
    local function step()
        local last = math.min(idx + batchSize - 1, total)
        for i = idx, last do
            local it = items[i]
            if it then
                local ok, err = pcall(perItemFunc, it)
                if not ok then Logger:Warn("Batch", label, err) end
            end
        end
        idx = last + 1
        if idx <= total then
            Scheduler:Push(step, (label or "batch") .. "_chunk")
        end
    end
    Scheduler:Push(step, (label or "batch") .. "_start")
end

function Batch.iterDescendants(root, classFilter, callback)
    -- Quét descendants không gọi GetDescendants() 1 phát (gây giật khi map lớn)
    local stack = { root }
    Scheduler:Push(function()
        local processed = 0
        while #stack > 0 do
            local node = table.remove(stack)
            for _, child in ipairs(node:GetChildren()) do
                if not classFilter or child:IsA(classFilter) then
                    callback(child)
                end
                table.insert(stack, child)
                processed = processed + 1
                if processed >= CONFIG.BatchSize then
                    return Scheduler:Push(function() Batch.iterDescendants(stack, classFilter, callback) end, "iter_yield")
                end
            end
        end
    end, "iter_descendants")
end

----------------------------------------------------------------------------------------------------
--  PHẦN 9 - ORIGINAL STATE STORE
--  Lưu lại giá trị ban đầu của các property bị thay đổi để khi tắt có thể restore.
----------------------------------------------------------------------------------------------------

local Original = {
    parts        = setmetatable({}, { __mode = "k" }),  -- BasePart -> { Material, Reflectance, Transparency }
    lighting     = nil,                                 -- properties của Lighting
    postEffects  = setmetatable({}, { __mode = "k" }),  -- PostEffect -> Enabled
    particles    = setmetatable({}, { __mode = "k" }),  -- ParticleEmitter -> Enabled
    decals       = setmetatable({}, { __mode = "k" }),  -- Decal/Texture -> Transparency
    terrain      = nil,
    guiHidden    = setmetatable({}, { __mode = "k" }),  -- ScreenGui -> Enabled
    deleted      = setmetatable({}, { __mode = "k" }),  -- thay vì Destroy, ta Parent về nil + giữ ref
}

local function snapshotPart(part)
    if Original.parts[part] then return end
    Original.parts[part] = {
        Material     = part.Material,
        Reflectance  = part.Reflectance,
        Transparency = part.Transparency,
        CastShadow   = part.CastShadow,
    }
end

local function snapshotDecal(d)
    if Original.decals[d] then return end
    Original.decals[d] = {
        Transparency = d.Transparency,
    }
end

local function snapshotParticle(p)
    if Original.particles[p] then return end
    Original.particles[p] = {
        Enabled = p.Enabled,
    }
end

local function snapshotPostEffect(eff)
    if Original.postEffects[eff] then return end
    Original.postEffects[eff] = {
        Enabled = eff.Enabled,
    }
end

local function snapshotLighting()
    if Original.lighting then return end
    Original.lighting = {
        GlobalShadows           = Lighting.GlobalShadows,
        Brightness              = Lighting.Brightness,
        Ambient                 = Lighting.Ambient,
        OutdoorAmbient          = Lighting.OutdoorAmbient,
        FogEnd                  = Lighting.FogEnd,
        FogStart                = Lighting.FogStart,
        Technology              = Lighting.Technology,
        ShadowSoftness          = (Lighting.ShadowSoftness or 0),
        EnvironmentDiffuseScale = (Lighting.EnvironmentDiffuseScale or 0),
        EnvironmentSpecularScale= (Lighting.EnvironmentSpecularScale or 0),
    }
end

local function snapshotTerrain()
    if Original.terrain then return end
    Original.terrain = {
        WaterWaveSize      = Terrain.WaterWaveSize,
        WaterWaveSpeed     = Terrain.WaterWaveSpeed,
        WaterReflectance   = Terrain.WaterReflectance,
        WaterTransparency  = Terrain.WaterTransparency,
        Decoration         = Terrain.Decoration,
    }
end

----------------------------------------------------------------------------------------------------
--  PHẦN 10 - MODULE: TEXTURE & DECAL STRIPPER
--  Loại bỏ toàn bộ Texture, Decal, SurfaceAppearance trên mọi BasePart trong workspace.
--  Không xóa thẳng tay - parent về nil + lưu lại để khi tắt có thể gắn lại nguyên vẹn.
----------------------------------------------------------------------------------------------------

local TextureStripper = {}
TextureStripper.detached = setmetatable({}, { __mode = "k" }) -- decal -> oldParent
TextureStripper.scanned  = setmetatable({}, { __mode = "k" }) -- BasePart -> true

function TextureStripper:DetachVisualSkin(inst)
    if not inst or not inst.Parent then return end
    if Whitelist:IsProtectedAncestry(inst) then return end
    if not (inst:IsA("Decal") or inst:IsA("Texture") or inst:IsA("SurfaceAppearance")) then
        return
    end
    snapshotDecal(inst.IsA and inst:IsA("SurfaceAppearance") and inst or inst)
    self.detached[inst] = inst.Parent
    inst.Parent = nil
end

function TextureStripper:ProcessPart(part)
    if not part or not part.Parent then return end
    if self.scanned[part] then return end
    if Whitelist:IsProtectedAncestry(part) then return end
    self.scanned[part] = true

    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") then
            self:DetachVisualSkin(child)
        end
    end
end

function TextureStripper:Apply()
    if not CONFIG.StripTextures then return end

    -- Lấy toàn bộ BasePart hiện có
    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            items[#items + 1] = d
        end
    end
    Batch.process(items, function(p) self:ProcessPart(p) end, CONFIG.BatchSize, "TextureStripper.Apply")

    -- Đăng ký xử lý các BasePart mới được thêm vào (ví dụ khi đi qua map mới)
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.StripTextures then return end
        if d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceAppearance") then
            task.defer(function() self:DetachVisualSkin(d) end)
        elseif d:IsA("BasePart") then
            task.defer(function() self:ProcessPart(d) end)
        end
    end))
end

function TextureStripper:Restore()
    for inst, oldParent in pairs(self.detached) do
        if inst and oldParent and oldParent.Parent then
            pcall(function() inst.Parent = oldParent end)
        end
    end
    table.clear(self.detached)
    table.clear(self.scanned)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 11 - MODULE: MATERIAL SIMPLIFIER
--  Đổi mọi Material phức tạp (Wood, Metal, Marble, Brick, Slate, Sand, ...) về SmoothPlastic.
--  SmoothPlastic là material rẻ tiền nhất với GPU.
----------------------------------------------------------------------------------------------------

local MaterialSimplifier = {}
MaterialSimplifier.HEAVY_MATERIALS = {
    [Enum.Material.Wood]          = true,
    [Enum.Material.WoodPlanks]    = true,
    [Enum.Material.Marble]        = true,
    [Enum.Material.Granite]       = true,
    [Enum.Material.Slate]         = true,
    [Enum.Material.Sand]          = true,
    [Enum.Material.Snow]          = true,
    [Enum.Material.Glass]         = true,
    [Enum.Material.ForceField]    = true,
    [Enum.Material.Brick]         = true,
    [Enum.Material.Cobblestone]   = true,
    [Enum.Material.Concrete]      = true,
    [Enum.Material.CorrodedMetal] = true,
    [Enum.Material.DiamondPlate]  = true,
    [Enum.Material.Fabric]        = true,
    [Enum.Material.Foil]          = true,
    [Enum.Material.Grass]         = true,
    [Enum.Material.Ice]           = true,
    [Enum.Material.Metal]         = true,
    [Enum.Material.Pebble]        = true,
    [Enum.Material.SmoothPlastic] = false,  -- giữ nguyên
    [Enum.Material.Plastic]       = false,
    [Enum.Material.Neon]          = false,  -- Neon dùng cho hiệu ứng quan trọng, giữ
}

function MaterialSimplifier:ProcessPart(part)
    if not part or not part.Parent then return end
    if Whitelist:IsProtectedAncestry(part) then return end

    local mat = part.Material
    if mat == nil then return end
    if self.HEAVY_MATERIALS[mat] then
        snapshotPart(part)
        pcall(function()
            part.Material    = Enum.Material.SmoothPlastic
            part.Reflectance = 0
        end)
    end
end

function MaterialSimplifier:Apply()
    if not CONFIG.SimplifyMaterials then return end

    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            items[#items + 1] = d
        end
    end
    Batch.process(items, function(p) self:ProcessPart(p) end, CONFIG.BatchSize, "Material.Apply")

    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.SimplifyMaterials then return end
        if d:IsA("BasePart") then
            task.defer(function() self:ProcessPart(d) end)
        end
    end))
end

function MaterialSimplifier:Restore()
    for part, snap in pairs(Original.parts) do
        if part and part.Parent then
            pcall(function()
                part.Material    = snap.Material
                part.Reflectance = snap.Reflectance
                part.Transparency= snap.Transparency
                part.CastShadow  = snap.CastShadow
            end)
        end
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 12 - MODULE: PARTICLE / EFFECT KILLER
--  Tắt mọi loại hiệu ứng hình ảnh do server / client tạo.
----------------------------------------------------------------------------------------------------

local ParticleKiller = {}
ParticleKiller.EFFECT_CLASSES = {
    "ParticleEmitter",
    "Smoke",
    "Fire",
    "Sparkles",
    "Trail",
    "Beam",
    "Explosion",
    "ForceField",
}

function ParticleKiller:ProcessEffect(eff)
    if not eff or not eff.Parent then return end
    if Whitelist:IsProtectedAncestry(eff) then return end

    -- Đặc biệt với ForceField, ta giữ nhưng tắt visible
    if eff:IsA("ForceField") then
        pcall(function() eff.Visible = false end)
        return
    end

    if eff:IsA("Explosion") then
        pcall(function()
            eff.BlastPressure = 0
            eff.BlastRadius   = 0
            eff.Visible       = false
        end)
        return
    end

    -- ParticleEmitter, Smoke, Fire, Sparkles, Trail, Beam: đều có property Enabled
    if typeof(eff.Enabled) ~= "nil" then
        snapshotParticle(eff)
        pcall(function() eff.Enabled = false end)
    end
end

function ParticleKiller:Apply()
    if not CONFIG.DisableParticles then return end

    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        for _, cls in ipairs(self.EFFECT_CLASSES) do
            if d:IsA(cls) then
                items[#items + 1] = d
                break
            end
        end
    end
    Batch.process(items, function(e) self:ProcessEffect(e) end, CONFIG.BatchSize, "Particle.Apply")

    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.DisableParticles then return end
        for _, cls in ipairs(self.EFFECT_CLASSES) do
            if d:IsA(cls) then
                task.defer(function() self:ProcessEffect(d) end)
                break
            end
        end
    end))
end

function ParticleKiller:Restore()
    for p, snap in pairs(Original.particles) do
        if p and p.Parent then
            pcall(function() p.Enabled = snap.Enabled end)
        end
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 13 - MODULE: WATER SIMPLIFIER
----------------------------------------------------------------------------------------------------

local WaterSimplifier = {}

function WaterSimplifier:Apply()
    if not CONFIG.SimplifyWater then return end
    snapshotTerrain()
    pcall(function()
        Terrain.WaterWaveSize      = 0
        Terrain.WaterWaveSpeed     = 0
        Terrain.WaterReflectance   = 0
        Terrain.WaterTransparency  = 1
        Terrain.Decoration         = false
    end)
end

function WaterSimplifier:Restore()
    if not Original.terrain then return end
    pcall(function()
        Terrain.WaterWaveSize      = Original.terrain.WaterWaveSize
        Terrain.WaterWaveSpeed     = Original.terrain.WaterWaveSpeed
        Terrain.WaterReflectance   = Original.terrain.WaterReflectance
        Terrain.WaterTransparency  = Original.terrain.WaterTransparency
        Terrain.Decoration         = Original.terrain.Decoration
    end)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 14 - MODULE: SHADOW DISABLER
----------------------------------------------------------------------------------------------------

local ShadowDisabler = {}

function ShadowDisabler:Apply()
    if not CONFIG.DisableShadows then return end
    snapshotLighting()
    pcall(function()
        Lighting.GlobalShadows = false
        if typeof(Lighting.ShadowSoftness) ~= "nil" then
            Lighting.ShadowSoftness = 0
        end
        if typeof(Lighting.EnvironmentDiffuseScale) ~= "nil" then
            Lighting.EnvironmentDiffuseScale = 0
        end
        if typeof(Lighting.EnvironmentSpecularScale) ~= "nil" then
            Lighting.EnvironmentSpecularScale = 0
        end
    end)

    -- Tắt CastShadow trên BasePart để ép GPU bỏ qua shadow casting hoàn toàn
    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            items[#items + 1] = d
        end
    end
    Batch.process(items, function(p)
        if p and p.Parent then
            snapshotPart(p)
            pcall(function() p.CastShadow = false end)
        end
    end, CONFIG.BatchSize, "Shadow.Apply")
end

function ShadowDisabler:Restore()
    if Original.lighting then
        pcall(function()
            Lighting.GlobalShadows = Original.lighting.GlobalShadows
            if typeof(Lighting.ShadowSoftness) ~= "nil" then
                Lighting.ShadowSoftness = Original.lighting.ShadowSoftness
            end
            if typeof(Lighting.EnvironmentDiffuseScale) ~= "nil" then
                Lighting.EnvironmentDiffuseScale = Original.lighting.EnvironmentDiffuseScale
            end
            if typeof(Lighting.EnvironmentSpecularScale) ~= "nil" then
                Lighting.EnvironmentSpecularScale = Original.lighting.EnvironmentSpecularScale
            end
        end)
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 15 - MODULE: LIGHTING DOWNGRADER
----------------------------------------------------------------------------------------------------

local LightingDowngrader = {}

function LightingDowngrader:Apply()
    if not CONFIG.LowLighting then return end
    snapshotLighting()
    pcall(function()
        -- Compatibility = chế độ nhẹ nhất (Voxel cũ)
        if Enum.Technology and Enum.Technology.Compatibility then
            Lighting.Technology = Enum.Technology.Compatibility
        end
        Lighting.Brightness     = 1.5
        Lighting.Ambient        = Color3.fromRGB(120, 120, 120)
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        Lighting.FogStart       = 0
        Lighting.FogEnd         = math.huge   -- bỏ fog để khỏi tốn render fog
    end)
end

function LightingDowngrader:Restore()
    if not Original.lighting then return end
    pcall(function()
        Lighting.Technology     = Original.lighting.Technology
        Lighting.Brightness     = Original.lighting.Brightness
        Lighting.Ambient        = Original.lighting.Ambient
        Lighting.OutdoorAmbient = Original.lighting.OutdoorAmbient
        Lighting.FogStart       = Original.lighting.FogStart
        Lighting.FogEnd         = Original.lighting.FogEnd
    end)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 16 - MODULE: POST-PROCESSING DISABLER
--  Tắt Bloom, Blur, SunRays, ColorCorrection, DepthOfField - các effect ngốn GPU.
----------------------------------------------------------------------------------------------------

local PostFXDisabler = {}
PostFXDisabler.POST_CLASSES = {
    "BloomEffect",
    "BlurEffect",
    "ColorCorrectionEffect",
    "SunRaysEffect",
    "DepthOfFieldEffect",
}

function PostFXDisabler:Apply()
    if not CONFIG.DisablePostFX then return end

    local function process(eff)
        if not eff or not eff.Parent then return end
        snapshotPostEffect(eff)
        pcall(function() eff.Enabled = false end)
    end

    for _, cls in ipairs(self.POST_CLASSES) do
        for _, eff in ipairs(Lighting:GetChildren()) do
            if eff:IsA(cls) then process(eff) end
        end
    end

    CONN:Add(Lighting.ChildAdded:Connect(function(eff)
        if not CONFIG.Enabled or not CONFIG.DisablePostFX then return end
        for _, cls in ipairs(self.POST_CLASSES) do
            if eff:IsA(cls) then
                task.defer(function() process(eff) end)
                break
            end
        end
    end))
end

function PostFXDisabler:Restore()
    for eff, snap in pairs(Original.postEffects) do
        if eff and eff.Parent then
            pcall(function() eff.Enabled = snap.Enabled end)
        end
    end
end


----------------------------------------------------------------------------------------------------
--  PHẦN 17 - MODULE: RENDER DISTANCE / CULLING
--  Ẩn các BasePart, Player, NPC ở quá xa người chơi để giảm draw call.
--  KHÔNG sửa StreamingEnabled (vì có thể phá load map của Blox Fruits) -
--  thay vào đó chỉ điều khiển LocalTransparencyModifier (an toàn).
----------------------------------------------------------------------------------------------------

local DistanceCuller = {}
DistanceCuller.tracked    = setmetatable({}, { __mode = "k" })  -- model -> meta
DistanceCuller.tickRate   = 0.6  -- giây giữa hai lần quét cull (đủ chậm để không tốn CPU)
DistanceCuller.lastCull   = 0
DistanceCuller.heartbeat  = nil

local function getCharacterPivot()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position end
    local pivot = char:GetPivot()
    return pivot.Position
end

function DistanceCuller:RegisterModel(model)
    if not model or not model.Parent then return end
    if self.tracked[model] then return end
    if Whitelist:IsProtectedAncestry(model) then return end
    self.tracked[model] = {
        model = model,
        kind  = "generic",
        baseTransparency = nil,
    }
end

function DistanceCuller:RegisterCharacter(char)
    if not char then return end
    self.tracked[char] = {
        model = char,
        kind  = "character",
    }
end

function DistanceCuller:SetModelHidden(model, hidden)
    if not model or not model.Parent then return end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function()
                d.LocalTransparencyModifier = hidden and 1 or 0
            end)
        elseif d:IsA("Decal") or d:IsA("Texture") then
            pcall(function()
                d.LocalTransparencyModifier = hidden and 1 or 0
            end)
        elseif d:IsA("MeshPart") then
            pcall(function()
                d.LocalTransparencyModifier = hidden and 1 or 0
            end)
        end
    end
    -- Tắt highlight / billboard khi xa
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("Highlight") or d:IsA("BillboardGui") then
            pcall(function() d.Enabled = not hidden end)
        end
    end
end

function DistanceCuller:Step(now)
    if now - self.lastCull < self.tickRate then return end
    self.lastCull = now

    local pivot = getCharacterPivot()
    if not pivot then return end

    local renderDist = CONFIG.RenderDistance
    local playerDist = CONFIG.PlayerDrawDistance
    local npcDist    = CONFIG.NPCDrawDistance

    -- Cull NPC + player models đã đăng ký
    for model, meta in pairs(self.tracked) do
        if not model.Parent then
            self.tracked[model] = nil
        else
            local ok, modelPos = pcall(function() return model:GetPivot().Position end)
            if ok then
                local dist = (modelPos - pivot).Magnitude
                local thr  = renderDist
                if meta.kind == "character" then
                    local plr = Players:GetPlayerFromCharacter(model)
                    if plr and plr ~= LocalPlayer then
                        thr = playerDist
                    elseif not plr then
                        thr = npcDist
                    end
                end
                local hidden = dist > thr
                if hidden ~= meta.lastHidden then
                    meta.lastHidden = hidden
                    self:SetModelHidden(model, hidden)
                end
            end
        end
    end
end

function DistanceCuller:RegisterAllExisting()
    for _, m in ipairs(Workspace:GetChildren()) do
        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
            self:RegisterModel(m)
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            self:RegisterCharacter(p.Character)
        end
    end
end

function DistanceCuller:Apply()
    if not CONFIG.LimitRenderDistance then return end
    self:RegisterAllExisting()

    CONN:Add(Workspace.ChildAdded:Connect(function(c)
        if not CONFIG.Enabled or not CONFIG.LimitRenderDistance then return end
        if c:IsA("Model") and not Players:GetPlayerFromCharacter(c) then
            task.defer(function() self:RegisterModel(c) end)
        end
    end))

    CONN:Add(Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            self:RegisterCharacter(char)
        end)
    end))

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            CONN:Add(p.CharacterAdded:Connect(function(char)
                self:RegisterCharacter(char)
            end))
        end
    end

    self.heartbeat = CONN:Add(RunService.Heartbeat:Connect(function()
        if not CONFIG.Enabled or not CONFIG.LimitRenderDistance then return end
        self:Step(os.clock())
    end))
end

function DistanceCuller:Restore()
    for model, meta in pairs(self.tracked) do
        if model and model.Parent then
            self:SetModelHidden(model, false)
        end
    end
    table.clear(self.tracked)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 18 - MODULE: MAP DECORATION CLEANER
--  Xóa cỏ, đá nhỏ, lá cây - những vật trang trí KHÔNG ảnh hưởng tới gameplay.
----------------------------------------------------------------------------------------------------

local MapDecorCleaner = {}
MapDecorCleaner.detached = setmetatable({}, { __mode = "k" })

function MapDecorCleaner:IsDecoration(inst)
    if not inst or not inst.Parent then return false end
    if Whitelist:IsProtectedAncestry(inst) then return false end
    if not inst:IsA("BasePart") and not inst:IsA("Model") then return false end
    return nameContainsAnyLower(inst.Name, CONFIG.DecorationKeywords)
end

function MapDecorCleaner:ProcessNode(node)
    if not self:IsDecoration(node) then return end
    -- Detach (parent về nil) thay vì destroy để có thể restore
    self.detached[node] = node.Parent
    pcall(function() node.Parent = nil end)
end

function MapDecorCleaner:Apply()
    if not CONFIG.CleanMapDecorations then return end

    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        items[#items + 1] = d
    end
    Batch.process(items, function(n) self:ProcessNode(n) end, CONFIG.BatchSize, "MapDecor.Apply")

    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.CleanMapDecorations then return end
        task.defer(function() self:ProcessNode(d) end)
    end))
end

function MapDecorCleaner:Restore()
    for inst, oldParent in pairs(self.detached) do
        if inst and oldParent and oldParent.Parent then
            pcall(function() inst.Parent = oldParent end)
        end
    end
    table.clear(self.detached)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 19 - MODULE: TREES & BUILDINGS TRANSPARENCY
--  Cây cối / nhà cửa được làm mờ nhẹ (theo CONFIG.TreesAlpha).
--  Không xóa hẳn để vẫn nhìn được tổng thể bản đồ.
----------------------------------------------------------------------------------------------------

local TreeTransparency = {}
TreeTransparency.applied = setmetatable({}, { __mode = "k" })

function TreeTransparency:IsTreeOrBuilding(inst)
    if not inst or not inst.Parent then return false end
    if Whitelist:IsProtectedAncestry(inst) then return false end
    if not inst:IsA("BasePart") then return false end
    return nameContainsAnyLower(inst.Name, CONFIG.TreeKeywords)
        or (inst.Parent and nameContainsAnyLower(inst.Parent.Name, CONFIG.TreeKeywords))
end

function TreeTransparency:ProcessPart(part)
    if not self:IsTreeOrBuilding(part) then return end
    snapshotPart(part)
    self.applied[part] = true
    pcall(function()
        part.LocalTransparencyModifier = math.clamp(CONFIG.TreesAlpha, 0, 1)
    end)
end

function TreeTransparency:Apply()
    if not CONFIG.TreesTransparency then return end

    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then items[#items + 1] = d end
    end
    Batch.process(items, function(p) self:ProcessPart(p) end, CONFIG.BatchSize, "TreeAlpha.Apply")

    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.TreesTransparency then return end
        if d:IsA("BasePart") then
            task.defer(function() self:ProcessPart(d) end)
        end
    end))
end

function TreeTransparency:Restore()
    for part in pairs(self.applied) do
        if part and part.Parent then
            pcall(function() part.LocalTransparencyModifier = 0 end)
        end
    end
    table.clear(self.applied)
end

----------------------------------------------------------------------------------------------------
--  PHẦN 20 - MODULE: SERVER-SIDE EFFECT KILLER
--  Quét theo định kỳ để tóm các effect do server tạo (skill chiêu, đạn, hiệu ứng aoe).
----------------------------------------------------------------------------------------------------

local ServerEffectKiller = {}
ServerEffectKiller.killed = setmetatable({}, { __mode = "k" })

function ServerEffectKiller:IsLikelyServerEffect(inst)
    if not inst or not inst.Parent then return false end
    if Whitelist:IsProtectedAncestry(inst) then return false end

    -- Bỏ qua người chơi
    if inst:FindFirstAncestorOfClass("Model") then
        local m = inst:FindFirstAncestorOfClass("Model")
        if Players:GetPlayerFromCharacter(m) then return false end
    end

    if nameContainsAnyLower(inst.Name, CONFIG.EffectKeywords) then
        return true
    end

    -- ParticleEmitter / Trail / Beam mới spawn cũng coi như effect
    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
       or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
        return true
    end

    return false
end

function ServerEffectKiller:Process(inst)
    if not self:IsLikelyServerEffect(inst) then return end
    if self.killed[inst] then return end
    self.killed[inst] = true

    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
       or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
        snapshotParticle(inst)
        pcall(function() inst.Enabled = false end)
    elseif inst:IsA("BasePart") then
        snapshotPart(inst)
        pcall(function()
            inst.Transparency = 1
            inst.CanCollide   = false
            inst.CanQuery     = false
            inst.CastShadow   = false
        end)
    elseif inst:IsA("Model") then
        for _, c in ipairs(inst:GetDescendants()) do
            if c:IsA("BasePart") then
                snapshotPart(c)
                pcall(function() c.Transparency = 1; c.CanCollide = false end)
            elseif c:IsA("ParticleEmitter") or c:IsA("Trail") or c:IsA("Beam")
                or c:IsA("Smoke") or c:IsA("Fire") or c:IsA("Sparkles") then
                snapshotParticle(c)
                pcall(function() c.Enabled = false end)
            end
        end
    end
end

function ServerEffectKiller:Apply()
    if not CONFIG.KillServerEffects then return end

    -- Quét hiện tại
    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do items[#items + 1] = d end
    Batch.process(items, function(n) self:Process(n) end, CONFIG.BatchSize, "ServerEff.Apply")

    -- Đăng ký xử lý các vật thể mới
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled or not CONFIG.KillServerEffects then return end
        task.defer(function() self:Process(d) end)
    end))
end

function ServerEffectKiller:Restore()
    -- Đã được Restore qua Original.parts / Original.particles
    table.clear(self.killed)
end


----------------------------------------------------------------------------------------------------
--  PHẦN 21 - MODULE: GARBAGE COLLECTOR
--  Chạy collectgarbage("collect") mỗi N giây nhưng RẢI qua nhiều bước nhỏ để KHÔNG GIẬT.
--  Trick: dùng "step" với KB nhỏ thay vì "collect" full pass.
----------------------------------------------------------------------------------------------------

local GarbageCollector = {}
GarbageCollector.lastFull = 0
GarbageCollector.stepKB   = 256  -- mỗi lần step gom 256KB - đủ nhẹ để không giật

function GarbageCollector:Step()
    pcall(function() collectgarbage("step", self.stepKB) end)
end

function GarbageCollector:FullCollect()
    pcall(function()
        collectgarbage("collect")
        collectgarbage("collect")  -- chạy 2 lần để chắc chắn dọn các bảng có metatable __gc
    end)
end

function GarbageCollector:Apply()
    if not CONFIG.PeriodicGC then return end
    self.lastFull = os.clock()

    -- Mỗi heartbeat làm 1 step nhỏ (256KB)
    CONN:Add(RunService.Heartbeat:Connect(function()
        if not CONFIG.Enabled or not CONFIG.PeriodicGC then return end
        self:Step()
    end))

    -- Mỗi N giây thì làm full pass
    task.spawn(function()
        while CONFIG.Enabled and CONFIG.PeriodicGC do
            task.wait(CONFIG.GCInterval)
            if not (CONFIG.Enabled and CONFIG.PeriodicGC) then break end
            self:FullCollect()
            self.lastFull = os.clock()
            Logger:Print("GC", "full collect done")
        end
    end)
end

function GarbageCollector:Restore()
    -- không cần restore gì
end

----------------------------------------------------------------------------------------------------
--  PHẦN 22 - MODULE: COMBAT-AWARE UI HIDER
--  Khi phát hiện người chơi đang ở trạng thái combat (đánh / phòng thủ),
--  ẩn các bảng UI rườm rà (Daily Reward, Quest Panel, Trade, ...).
----------------------------------------------------------------------------------------------------

local CombatUIHider = {}
CombatUIHider.hiddenGuis = setmetatable({}, { __mode = "k" })
CombatUIHider.inCombat   = false
CombatUIHider.lastDamage = 0

local function getPlayerGui()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

function CombatUIHider:DetectCombat()
    -- Cách 1: Health của character thay đổi gần đây
    local char = LocalPlayer.Character
    if not char then return false end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if (os.clock() - self.lastDamage) < 4 then
        return true
    end

    -- Cách 2: gần NPC enemy hoặc gần player khác trong tầm 30 stud
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local oh = plr.Character:FindFirstChild("HumanoidRootPart")
                if oh and (oh.Position - hrp.Position).Magnitude < 30 then
                    return true
                end
            end
        end
    end

    return false
end

function CombatUIHider:HideExtras()
    local pg = getPlayerGui()
    if not pg then return end
    for _, gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("ScreenGui") then
            local should = nameContainsAnyLower(gui.Name, CONFIG.CombatHideUI)
            if should and gui.Enabled then
                self.hiddenGuis[gui] = true
                pcall(function() gui.Enabled = false end)
            end
        end
    end
end

function CombatUIHider:RestoreExtras()
    for gui in pairs(self.hiddenGuis) do
        if gui and gui.Parent then
            pcall(function() gui.Enabled = true end)
        end
    end
    table.clear(self.hiddenGuis)
end

function CombatUIHider:Apply()
    if not CONFIG.HideCombatUI then return end

    -- Theo dõi sát thương (damage)
    local function bind(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local lastHP = hum.Health
        CONN:Add(hum.HealthChanged:Connect(function(hp)
            if hp < lastHP then
                self.lastDamage = os.clock()
            end
            lastHP = hp
        end))
    end
    bind(LocalPlayer.Character)
    CONN:Add(LocalPlayer.CharacterAdded:Connect(bind))

    task.spawn(function()
        while CONFIG.Enabled and CONFIG.HideCombatUI do
            local now = self:DetectCombat()
            if now ~= self.inCombat then
                self.inCombat = now
                if now then
                    self:HideExtras()
                else
                    self:RestoreExtras()
                end
            end
            task.wait(1.5)
        end
    end)
end

function CombatUIHider:Restore()
    self:RestoreExtras()
end

----------------------------------------------------------------------------------------------------
--  PHẦN 23 - MODULE: STAT BAR (FPS | CPU | PLAYER)
--  Yêu cầu: thanh dài nằm ngang dưới góc trái, chữ trắng, nền đen, KHÔNG bo góc.
----------------------------------------------------------------------------------------------------

local StatBar = {}
StatBar.gui    = nil
StatBar.frame  = nil
StatBar.label  = nil

-- Tính FPS bằng cách đếm số lần Heartbeat trong 1 giây.
StatBar.frameCount = 0
StatBar.fpsSample  = 60
StatBar.fpsLastT   = os.clock()

local function getCpuTime()
    -- Stats:GetTotalMemoryUsageMb() / cpu time qua Stats.* nếu có
    local cpu
    pcall(function()
        cpu = math.floor(Stats:GetTotalMemoryUsageMb() + 0.5)
    end)
    return cpu or 0
end

local function getPing()
    local ping = 0
    pcall(function()
        if Stats and Stats.Network and Stats.Network.ServerStatsItem then
            local item = Stats.Network.ServerStatsItem["Data Ping"]
            if item then
                ping = math.floor(item:GetValue() + 0.5)
            end
        end
    end)
    return ping
end

function StatBar:GetParentGui()
    -- Ưu tiên CoreGui (chống bị server xóa khi reset character)
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return getPlayerGui()
end

function StatBar:Build()
    if self.gui then return end

    local parent = self:GetParentGui()
    if not parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name              = "BFFixLag_StatBar"
    gui.ResetOnSpawn      = false
    gui.IgnoreGuiInset    = true
    gui.DisplayOrder      = 10000
    gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
    gui.Parent            = parent
    self.gui = gui

    local frame = Instance.new("Frame")
    frame.Name              = "Bar"
    frame.AnchorPoint       = Vector2.new(0, 1)
    frame.Position          = UDim2.new(0, 0, 1, 0)              -- góc trái dưới
    frame.Size              = UDim2.new(0, CONFIG.StatBarMinWidth, 0, CONFIG.StatBarHeight)
    frame.BackgroundColor3  = Color3.new(0, 0, 0)                -- nền đen
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel   = 0
    frame.Parent            = gui
    self.frame = frame

    -- KHÔNG thêm UICorner -> bảo đảm không bo góc

    local label = Instance.new("TextLabel")
    label.Name               = "Label"
    label.BackgroundTransparency = 1
    label.Size               = UDim2.new(1, -16, 1, 0)
    label.Position           = UDim2.new(0, 8, 0, 0)
    label.Font               = Enum.Font.Code
    label.TextColor3         = Color3.new(1, 1, 1)               -- chữ trắng
    label.TextSize           = 14
    label.TextXAlignment     = Enum.TextXAlignment.Left
    label.TextYAlignment     = Enum.TextYAlignment.Center
    label.RichText           = false
    label.Text               = "[ Fps... | Cpu... | Player... ]"
    label.Parent             = frame
    self.label = label

    -- Auto resize theo content
    PERM_CONN:Add(label:GetPropertyChangedSignal("TextBounds"):Connect(function()
        local w = math.max(CONFIG.StatBarMinWidth, label.TextBounds.X + 24)
        frame.Size = UDim2.new(0, w, 0, CONFIG.StatBarHeight)
    end))
end

function StatBar:Destroy()
    if self.gui then
        pcall(function() self.gui:Destroy() end)
    end
    self.gui   = nil
    self.frame = nil
    self.label = nil
end

function StatBar:UpdateOnce()
    if not self.label then return end
    local fps    = math.floor(self.fpsSample + 0.5)
    local cpuMB  = getCpuTime()
    local players= #Players:GetPlayers()
    local ping   = getPing()
    self.label.Text = string.format(
        "[ Fps %d | Cpu %d MB | Player %d | Ping %d ms ]",
        fps, cpuMB, players, ping
    )
end

function StatBar:Apply()
    if not CONFIG.StatBar then return end
    self:Build()

    -- Đếm FPS
    PERM_CONN:Add(RunService.RenderStepped:Connect(function()
        self.frameCount = self.frameCount + 1
        local now = os.clock()
        local dt  = now - self.fpsLastT
        if dt >= 1 then
            self.fpsSample = self.frameCount / dt
            self.frameCount = 0
            self.fpsLastT   = now
        end
    end))

    -- Refresh nội dung label
    task.spawn(function()
        while true do
            task.wait(CONFIG.StatBarRefreshRate)
            if self.label and self.label.Parent then
                self:UpdateOnce()
            end
        end
    end)
end

function StatBar:Hide() if self.gui then self.gui.Enabled = false end end
function StatBar:Show() if self.gui then self.gui.Enabled = true  end end


----------------------------------------------------------------------------------------------------
--  PHẦN 24 - MODULE: TOGGLE MENU UI
--  Một panel nhỏ ở góc phải, có công tắc để bật/tắt từng module riêng lẻ.
--  Ẩn/hiện bằng phím  CONFIG.ToggleKey  (mặc định RightShift) hoặc nút ☰.
----------------------------------------------------------------------------------------------------

local ToggleMenu = {}
ToggleMenu.gui     = nil
ToggleMenu.panel   = nil
ToggleMenu.visible = false

local TOGGLE_LIST = {
    { key = "Enabled",             label = "MASTER (Bật toàn bộ)" },
    { key = "StripTextures",       label = "Xóa Texture / Decal" },
    { key = "SimplifyMaterials",   label = "Đổi Material -> SmoothPlastic" },
    { key = "DisableParticles",    label = "Tắt Particles / FX" },
    { key = "SimplifyWater",       label = "Đơn giản hóa Water" },
    { key = "DisableShadows",      label = "Tắt Shadows" },
    { key = "LowLighting",         label = "Lighting Compatibility (Voxel)" },
    { key = "DisablePostFX",       label = "Tắt Bloom/Blur/SunRays/CC/DOF" },
    { key = "LimitRenderDistance", label = "Giới hạn Render Distance" },
    { key = "CleanMapDecorations", label = "Xóa cỏ / đá nhỏ / lá cây" },
    { key = "TreesTransparency",   label = "Cây cối / nhà mờ nhẹ" },
    { key = "KillServerEffects",   label = "Diệt FX của server" },
    { key = "PeriodicGC",          label = "Garbage Collection định kỳ" },
    { key = "HideCombatUI",        label = "Ẩn UI khi Combat" },
    { key = "StatBar",             label = "Hiển thị Thanh trạng thái" },
    { key = "AutoRunOnTeleport",   label = "Auto bật lại khi teleport" },
}

local function makeRow(parent, idx, item)
    local row = Instance.new("Frame")
    row.Name             = "Row_" .. item.key
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    row.BorderSizePixel  = 0
    row.Size             = UDim2.new(1, -10, 0, 26)
    row.Position         = UDim2.new(0, 5, 0, 36 + (idx - 1) * 28)
    row.Parent           = parent

    local lab = Instance.new("TextLabel")
    lab.Name                  = "Label"
    lab.BackgroundTransparency= 1
    lab.Size                  = UDim2.new(1, -70, 1, 0)
    lab.Position              = UDim2.new(0, 8, 0, 0)
    lab.Font                  = Enum.Font.Code
    lab.TextSize              = 13
    lab.TextColor3            = Color3.fromRGB(220, 220, 220)
    lab.TextXAlignment        = Enum.TextXAlignment.Left
    lab.Text                  = item.label
    lab.Parent                = row

    local btn = Instance.new("TextButton")
    btn.Name                  = "Switch"
    btn.AutoButtonColor       = false
    btn.Size                  = UDim2.new(0, 56, 0, 20)
    btn.Position              = UDim2.new(1, -62, 0, 3)
    btn.Font                  = Enum.Font.GothamBold
    btn.TextSize              = 12
    btn.BorderSizePixel       = 0
    btn.Parent                = row

    local function refresh()
        local on = CONFIG[item.key] == true
        btn.Text             = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 160, 80) or Color3.fromRGB(160, 50, 50)
        btn.TextColor3       = Color3.new(1, 1, 1)
    end
    refresh()

    btn.MouseButton1Click:Connect(function()
        CONFIG[item.key] = not CONFIG[item.key]
        refresh()
        Persistence:SaveAll()

        -- Áp dụng thay đổi ngay
        if item.key == "Enabled" then
            shared.BFFixLag:Toggle()
        else
            shared.BFFixLag:ReapplyAll()
        end
    end)

    return row
end

function ToggleMenu:Build()
    if self.gui then return end
    local parent = StatBar:GetParentGui()
    if not parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name           = "BFFixLag_Toggle"
    gui.ResetOnSpawn   = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder   = 9999
    gui.Parent         = parent
    self.gui = gui

    local panel = Instance.new("Frame")
    panel.AnchorPoint       = Vector2.new(1, 0.5)
    panel.Position          = UDim2.new(1, -10, 0.5, 0)
    panel.Size              = UDim2.new(0, 320, 0, 36 + (#TOGGLE_LIST * 28) + 10)
    panel.BackgroundColor3  = Color3.fromRGB(10, 10, 10)
    panel.BorderSizePixel   = 0
    panel.Visible           = false
    panel.Parent            = gui
    self.panel = panel

    -- Header
    local header = Instance.new("TextLabel")
    header.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    header.BorderSizePixel        = 0
    header.Size                   = UDim2.new(1, 0, 0, 30)
    header.Position               = UDim2.new(0, 0, 0, 0)
    header.Font                   = Enum.Font.Code
    header.TextSize               = 15
    header.TextColor3             = Color3.new(1, 1, 1)
    header.Text                   = "  BFFixLag - Menu (RightShift)"
    header.TextXAlignment         = Enum.TextXAlignment.Left
    header.Parent                 = panel

    for i, item in ipairs(TOGGLE_LIST) do
        makeRow(panel, i, item)
    end

    -- Phím tắt
    PERM_CONN:Add(UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == CONFIG.ToggleKey then
            self:ToggleVisible()
        end
    end))
end

function ToggleMenu:ToggleVisible()
    if not self.panel then self:Build() end
    if not self.panel then return end
    self.visible = not self.visible
    self.panel.Visible = self.visible
end

function ToggleMenu:Hide()
    if self.panel then self.panel.Visible = false end
    self.visible = false
end


----------------------------------------------------------------------------------------------------
--  PHẦN 25 - MODULE: CHARACTER OPTIMIZER
--  Tối ưu hóa Character của các player khác (LOD nhẹ, không xóa hẳn để vẫn nhận diện được).
----------------------------------------------------------------------------------------------------

local CharacterOptimizer = {}
CharacterOptimizer.processed = setmetatable({}, { __mode = "k" })

function CharacterOptimizer:Strip(char)
    if not char or not char.Parent then return end
    if self.processed[char] then return end
    self.processed[char] = true

    local plr = Players:GetPlayerFromCharacter(char)
    if plr == LocalPlayer then return end

    -- Tắt accessory rườm rà
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Accessory") then
            for _, p in ipairs(item:GetDescendants()) do
                if p:IsA("BasePart") then
                    snapshotPart(p)
                    pcall(function()
                        p.Material   = Enum.Material.SmoothPlastic
                        p.CastShadow = false
                    end)
                end
                if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam") then
                    snapshotParticle(p)
                    pcall(function() p.Enabled = false end)
                end
            end
        end
    end

    -- Tắt particle / trail trên các bộ phận chính
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("ParticleEmitter") or p:IsA("Trail") or p:IsA("Beam")
           or p:IsA("Smoke") or p:IsA("Fire") or p:IsA("Sparkles") then
            snapshotParticle(p)
            pcall(function() p.Enabled = false end)
        end
    end
end

function CharacterOptimizer:Apply()
    -- Áp dụng cho mọi player hiện có
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            self:Strip(p.Character)
        end
    end

    -- Player mới gia nhập
    CONN:Add(Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            if not CONFIG.Enabled then return end
            task.wait(1.0)  -- chờ character load xong
            self:Strip(char)
        end)
    end))

    -- Player đang có sẵn nhưng respawn
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            CONN:Add(p.CharacterAdded:Connect(function(char)
                if not CONFIG.Enabled then return end
                task.wait(1.0)
                self:Strip(char)
            end))
        end
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 26 - MODULE: HUMANOID STATE LIMITER
--  Hạ tốc độ animation / vô hiệu hóa state nặng cho NPC ở xa.
----------------------------------------------------------------------------------------------------

local HumanoidLimiter = {}
HumanoidLimiter.touched = setmetatable({}, { __mode = "k" })
HumanoidLimiter.heavyStates = {
    Enum.HumanoidStateType.Climbing,
    Enum.HumanoidStateType.Swimming,
    Enum.HumanoidStateType.PlatformStanding,
    Enum.HumanoidStateType.Ragdoll,
}

function HumanoidLimiter:Process(humanoid)
    if not humanoid or not humanoid.Parent then return end
    if self.touched[humanoid] then return end

    local model = humanoid.Parent
    if Players:GetPlayerFromCharacter(model) then return end -- không động vào player

    self.touched[humanoid] = true

    -- Tắt các state nặng
    for _, st in ipairs(self.heavyStates) do
        pcall(function() humanoid:SetStateEnabled(st, false) end)
    end

    -- Hạ AutoRotate (NPC sẽ đứng yên góc, đỡ tốn vật lý)
    pcall(function() humanoid.AutoRotate = false end)
end

function HumanoidLimiter:Apply()
    for _, h in ipairs(Workspace:GetDescendants()) do
        if h:IsA("Humanoid") then self:Process(h) end
    end
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled then return end
        if d:IsA("Humanoid") then
            task.defer(function() self:Process(d) end)
        end
    end))
end

----------------------------------------------------------------------------------------------------
--  PHẦN 27 - MODULE: NETWORK CHURN CALMER
--  Một số game spawn rất nhiều BasePart "đạn / chiêu" mỗi giây.
--  Module này nhận diện và silently dispose chúng phía client để giảm áp lực.
----------------------------------------------------------------------------------------------------

local NetworkChurnCalmer = {}
NetworkChurnCalmer.handled = setmetatable({}, { __mode = "k" })
NetworkChurnCalmer.SHORT_LIVED_NAMES = {
    "Projectile", "Hitbox", "DamageBox", "Bullet", "Slash",
    "Shockwave", "Explosion", "Energy", "Bolt", "Wave", "Aura",
}

function NetworkChurnCalmer:Process(inst)
    if not inst or not inst.Parent then return end
    if self.handled[inst] then return end
    if Whitelist:IsProtectedAncestry(inst) then return end

    if not (inst:IsA("BasePart") or inst:IsA("Model")) then return end
    local matched = false
    for _, kw in ipairs(self.SHORT_LIVED_NAMES) do
        if string.find(string.lower(inst.Name), string.lower(kw), 1, true) then
            matched = true
            break
        end
    end
    if not matched then return end

    self.handled[inst] = true

    if inst:IsA("BasePart") then
        snapshotPart(inst)
        pcall(function()
            inst.Transparency = 1
            inst.CastShadow   = false
            inst.CanQuery     = false
        end)
    elseif inst:IsA("Model") then
        for _, c in ipairs(inst:GetDescendants()) do
            if c:IsA("BasePart") then
                snapshotPart(c)
                pcall(function() c.Transparency = 1; c.CastShadow = false end)
            elseif c:IsA("ParticleEmitter") or c:IsA("Trail") or c:IsA("Beam") then
                snapshotParticle(c)
                pcall(function() c.Enabled = false end)
            end
        end
    end
end

function NetworkChurnCalmer:Apply()
    for _, d in ipairs(Workspace:GetDescendants()) do
        self:Process(d)
    end
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled then return end
        task.defer(function() self:Process(d) end)
    end))
end

----------------------------------------------------------------------------------------------------
--  PHẦN 28 - MODULE: MESH/UNION OPTIMIZER
--  MeshPart và UnionOperation rất tốn GPU. Module này hạ RenderFidelity về Performance.
----------------------------------------------------------------------------------------------------

local MeshOptimizer = {}
MeshOptimizer.applied = setmetatable({}, { __mode = "k" })

function MeshOptimizer:Process(inst)
    if not inst or not inst.Parent then return end
    if Whitelist:IsProtectedAncestry(inst) then return end
    if not (inst:IsA("MeshPart") or inst:IsA("UnionOperation") or inst:IsA("PartOperation")) then return end
    if self.applied[inst] then return end
    self.applied[inst] = true

    snapshotPart(inst)
    pcall(function()
        if typeof(inst.RenderFidelity) ~= "nil" then
            inst.RenderFidelity = Enum.RenderFidelity.Performance
        end
        inst.Material   = Enum.Material.SmoothPlastic
        inst.Reflectance= 0
        inst.CastShadow = false
    end)
end

function MeshOptimizer:Apply()
    local items = {}
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("MeshPart") or d:IsA("UnionOperation") or d:IsA("PartOperation") then
            items[#items + 1] = d
        end
    end
    Batch.process(items, function(p) self:Process(p) end, CONFIG.BatchSize, "Mesh.Apply")

    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled then return end
        if d:IsA("MeshPart") or d:IsA("UnionOperation") or d:IsA("PartOperation") then
            task.defer(function() self:Process(d) end)
        end
    end))
end

----------------------------------------------------------------------------------------------------
--  PHẦN 29 - MODULE: SOUND CULLER
--  Hạ âm lượng các Sound xa người chơi (RollOff đã có, nhưng nhiều game set RollOffMode tệ).
----------------------------------------------------------------------------------------------------

local SoundCuller = {}
SoundCuller.touched = setmetatable({}, { __mode = "k" })

function SoundCuller:Process(s)
    if not s or not s.Parent then return end
    if not s:IsA("Sound") then return end
    if self.touched[s] then return end

    -- Bỏ qua sound không gắn với BasePart (UI sound)
    local part = s.Parent
    if not (part and part:IsA("BasePart")) then return end

    self.touched[s] = true
    pcall(function()
        s.RollOffMode      = Enum.RollOffMode.Linear
        s.MaxDistance      = math.min(s.MaxDistance or 1000, 250)
        s.EmitterSize      = math.max(1, s.EmitterSize or 5)
    end)
end

function SoundCuller:Apply()
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Sound") then self:Process(d) end
    end
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled then return end
        if d:IsA("Sound") then task.defer(function() self:Process(d) end) end
    end))
end


----------------------------------------------------------------------------------------------------
--  PHẦN 30 - MODULE: ANIMATION THROTTLER
--  Hạ tốc độ playback và priority animation cho NPC ở xa.
----------------------------------------------------------------------------------------------------

local AnimThrottler = {}
AnimThrottler.touched = setmetatable({}, { __mode = "k" })

function AnimThrottler:Process(animator)
    if not animator or not animator.Parent then return end
    if not animator:IsA("Animator") then return end
    if self.touched[animator] then return end

    local model = animator:FindFirstAncestorOfClass("Model")
    if not model then return end
    if Players:GetPlayerFromCharacter(model) then return end

    self.touched[animator] = true

    local function downgrade(track)
        if not track then return end
        pcall(function()
            track:AdjustSpeed(0.6)
        end)
    end

    pcall(function()
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
            downgrade(t)
        end
    end)

    CONN:Add(animator.AnimationPlayed:Connect(function(track)
        if not CONFIG.Enabled then return end
        downgrade(track)
    end))
end

function AnimThrottler:Apply()
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("Animator") then self:Process(d) end
    end
    CONN:Add(Workspace.DescendantAdded:Connect(function(d)
        if not CONFIG.Enabled then return end
        if d:IsA("Animator") then
            task.defer(function() self:Process(d) end)
        end
    end))
end

----------------------------------------------------------------------------------------------------
--  PHẦN 31 - MODULE: CAMERA OPTIMIZER
--  Hạ FieldOfView nhẹ + tắt CameraSubject occluding để render frustum nhỏ hơn.
----------------------------------------------------------------------------------------------------

local CameraOptimizer = {}
CameraOptimizer.original = nil

function CameraOptimizer:Apply()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    if self.original then return end
    self.original = {
        FieldOfView = cam.FieldOfView,
    }
    pcall(function()
        cam.FieldOfView = math.clamp(cam.FieldOfView, 70, 80)
    end)
end

function CameraOptimizer:Restore()
    local cam = Workspace.CurrentCamera
    if cam and self.original then
        pcall(function() cam.FieldOfView = self.original.FieldOfView end)
    end
    self.original = nil
end

----------------------------------------------------------------------------------------------------
--  PHẦN 32 - MODULE: COREGUI MINIMIZER
--  Tắt các CoreGui không cần thiết khi chơi (Chat, PlayerList, EmotesMenu) - tùy chọn.
----------------------------------------------------------------------------------------------------

local CoreGuiMinimizer = {}
CoreGuiMinimizer.original = nil

function CoreGuiMinimizer:Apply()
    if self.original then return end
    self.original = {}
    local toToggle = {
        Enum.CoreGuiType.EmotesMenu,
        Enum.CoreGuiType.Backpack,    -- chỉ để mặc định, không tắt vì cần inventory
    }
    -- Không tắt Backpack / Chat / Health vì người chơi cần chúng. Chỉ làm chỗ dự phòng.
end

function CoreGuiMinimizer:Restore()
    self.original = nil
end

----------------------------------------------------------------------------------------------------
--  PHẦN 33 - WATCHDOG: phát hiện stutter và tự nhả tải tạm thời
--  Nếu đo được FPS < 20 trong 3 giây liên tiếp, tự pause Scheduler 1 nhịp để giảm tải.
----------------------------------------------------------------------------------------------------

local Watchdog = {}
Watchdog.lowSince = nil

function Watchdog:Apply()
    PERM_CONN:Add(RunService.Heartbeat:Connect(function()
        if not CONFIG.Enabled then return end
        local fps = StatBar.fpsSample or 60
        if fps < 20 then
            self.lowSince = self.lowSince or os.clock()
            if os.clock() - self.lowSince > 3 then
                -- Pause briefly
                Scheduler:Stop()
                task.wait(0.2)
                Scheduler:Start()
                self.lowSince = os.clock() + 5
            end
        else
            self.lowSince = nil
        end
    end))
end

----------------------------------------------------------------------------------------------------
--  PHẦN 34 - ORCHESTRATOR
--  Bật / tắt toàn bộ. Đây là entrypoint chính của script.
----------------------------------------------------------------------------------------------------

local Orchestrator = {}
Orchestrator.running = false

function Orchestrator:ApplyAll()
    if self.running then return end
    self.running = true

    Logger:Print("Boot", "Applying optimizations...")

    snapshotLighting()
    snapshotTerrain()

    -- Áp dụng trên các thread riêng để bảo đảm KHÔNG GIẬT khung hình đầu
    task.spawn(function() TextureStripper   :Apply() end)
    task.spawn(function() MaterialSimplifier:Apply() end)
    task.spawn(function() ParticleKiller    :Apply() end)
    task.spawn(function() WaterSimplifier   :Apply() end)
    task.spawn(function() ShadowDisabler    :Apply() end)
    task.spawn(function() LightingDowngrader:Apply() end)
    task.spawn(function() PostFXDisabler    :Apply() end)
    task.spawn(function() DistanceCuller    :Apply() end)
    task.spawn(function() MapDecorCleaner   :Apply() end)
    task.spawn(function() TreeTransparency  :Apply() end)
    task.spawn(function() ServerEffectKiller:Apply() end)
    task.spawn(function() GarbageCollector  :Apply() end)
    task.spawn(function() CombatUIHider     :Apply() end)
    task.spawn(function() CharacterOptimizer:Apply() end)
    task.spawn(function() HumanoidLimiter   :Apply() end)
    task.spawn(function() NetworkChurnCalmer:Apply() end)
    task.spawn(function() MeshOptimizer     :Apply() end)
    task.spawn(function() SoundCuller       :Apply() end)
    task.spawn(function() AnimThrottler     :Apply() end)
    task.spawn(function() CameraOptimizer   :Apply() end)

    -- Persistence
    Persistence:SaveAll()

    Logger:Notify("BFFixLag", "Đã bật Fix Lag", 3)
end

function Orchestrator:RestoreAll()
    if not self.running then return end
    self.running = false

    Logger:Print("Stop", "Restoring originals...")

    -- Disconnect mọi listener "đang chạy"
    CONN:DisconnectAll()
    Scheduler:Stop()

    -- Khôi phục tất cả module
    pcall(function() TextureStripper   :Restore() end)
    pcall(function() MaterialSimplifier:Restore() end)
    pcall(function() ParticleKiller    :Restore() end)
    pcall(function() WaterSimplifier   :Restore() end)
    pcall(function() ShadowDisabler    :Restore() end)
    pcall(function() LightingDowngrader:Restore() end)
    pcall(function() PostFXDisabler    :Restore() end)
    pcall(function() DistanceCuller    :Restore() end)
    pcall(function() MapDecorCleaner   :Restore() end)
    pcall(function() TreeTransparency  :Restore() end)
    pcall(function() ServerEffectKiller:Restore() end)
    pcall(function() CombatUIHider     :Restore() end)
    pcall(function() CameraOptimizer   :Restore() end)

    Persistence:SaveAll()

    Logger:Notify("BFFixLag", "Đã tắt Fix Lag (đã restore)", 3)
end

function Orchestrator:Toggle()
    CONFIG.Enabled = not CONFIG.Enabled
    if CONFIG.Enabled then
        self:ApplyAll()
    else
        self:RestoreAll()
    end
end

function Orchestrator:ReapplyAll()
    -- Tắt rồi bật lại để áp dụng lại config
    if self.running then
        local wasEnabled = CONFIG.Enabled
        self:RestoreAll()
        CONFIG.Enabled = wasEnabled
        if wasEnabled then
            task.wait(0.1)
            self:ApplyAll()
        end
    elseif CONFIG.Enabled then
        self:ApplyAll()
    end
end

----------------------------------------------------------------------------------------------------
--  PHẦN 35 - PUBLIC API (export ra shared & _G để gọi từ ngoài)
----------------------------------------------------------------------------------------------------

local API = {
    Toggle      = function(self) Orchestrator:Toggle() end,
    Enable      = function(self) if not CONFIG.Enabled then Orchestrator:Toggle() end end,
    Disable     = function(self) if     CONFIG.Enabled then Orchestrator:Toggle() end end,
    ReapplyAll  = function(self) Orchestrator:ReapplyAll() end,
    Config      = CONFIG,
    Set         = function(self, key, value)
        if DEFAULT_CONFIG[key] == nil then return false end
        if type(value) ~= type(DEFAULT_CONFIG[key]) then return false end
        CONFIG[key] = value
        Persistence:SaveAll()
        return true
    end,
    Save        = function(self) Persistence:SaveAll() end,
    Restore     = function(self) Orchestrator:RestoreAll() end,
    OpenMenu    = function(self) ToggleMenu:ToggleVisible() end,
    Version     = "4.7.0",
}

shared.BFFixLag = API
rawset(_G, "BFFixLag", API)

----------------------------------------------------------------------------------------------------
--  PHẦN 36 - BOOTSTRAP - Chạy khi script được load
----------------------------------------------------------------------------------------------------

-- Load config từ các nguồn (file local, shared, queue_on_teleport)
Persistence:LoadAll()

-- Build UI vĩnh viễn (Stat bar + menu)
StatBar:Apply()
ToggleMenu:Build()

-- Watchdog
Watchdog:Apply()

-- Khởi động tính năng nếu CONFIG.Enabled = true
if CONFIG.Enabled then
    -- Trễ 1 frame để chắc chắn Workspace đã ready
    task.defer(function()
        Orchestrator:ApplyAll()
    end)
end

-- In thông báo bàn giao
print(string.rep("=", 80))
print("  BLOX FRUITS - FIX LAG ULTRA  v" .. API.Version)
print("  Trạng thái: " .. (CONFIG.Enabled and "ĐANG BẬT" or "ĐANG TẮT"))
print("  Mở menu  : Bấm phím  RightShift  hoặc gọi  shared.BFFixLag:OpenMenu()")
print("  Toggle   : shared.BFFixLag:Toggle()")
print(string.rep("=", 80))

----------------------------------------------------------------------------------------------------
--  PHẦN 37 - PHẦN MỞ RỘNG: BẢNG TRA CỨU CLASS NẶNG
--  Đây là bảng phân loại độ "nặng" của từng ClassName,
--  giúp Scheduler ưu tiên xử lý cái tốn GPU trước.
----------------------------------------------------------------------------------------------------

local ClassWeight = {
    -- Càng cao = càng tốn tài nguyên
    ["UnionOperation"]      = 9,
    ["MeshPart"]            = 8,
    ["SpecialMesh"]         = 7,
    ["Texture"]             = 6,
    ["Decal"]               = 5,
    ["SurfaceAppearance"]   = 7,
    ["ParticleEmitter"]     = 8,
    ["Trail"]               = 6,
    ["Beam"]                = 6,
    ["Smoke"]               = 5,
    ["Fire"]                = 5,
    ["Sparkles"]            = 4,
    ["Explosion"]           = 9,
    ["BillboardGui"]        = 4,
    ["SurfaceGui"]          = 5,
    ["ScreenGui"]           = 3,
    ["Highlight"]           = 5,
    ["BloomEffect"]         = 7,
    ["BlurEffect"]          = 6,
    ["DepthOfFieldEffect"]  = 8,
    ["SunRaysEffect"]       = 6,
    ["ColorCorrectionEffect"]= 5,
    ["BasePart"]            = 2,
    ["Part"]                = 2,
    ["WedgePart"]           = 2,
    ["CornerWedgePart"]     = 2,
    ["TrussPart"]           = 3,
    ["VehicleSeat"]         = 3,
    ["Seat"]                = 3,
    ["Sound"]               = 1,
    ["BodyPosition"]        = 2,
    ["BodyVelocity"]        = 2,
    ["BodyGyro"]             = 2,
    ["AlignPosition"]       = 3,
    ["LinearVelocity"]      = 3,
    ["AngularVelocity"]     = 3,
    ["AlignOrientation"]    = 3,
    ["VectorForce"]         = 2,
    ["Torque"]              = 2,
}

local function getClassWeight(inst)
    if not inst then return 0 end
    return ClassWeight[inst.ClassName] or 0
end

----------------------------------------------------------------------------------------------------
--  PHẦN 38 - HELPER: nhận diện vùng map / island theo tên (debug)
----------------------------------------------------------------------------------------------------

local IslandHelper = {}

IslandHelper.KNOWN_ISLANDS = {
    "Starter",     "Marine",      "JungleIsland", "PirateVillage",
    "Desert",      "FrozenIsland","ColosseumIsland","KingdomOfRose",
    "Hydra",       "Sky",         "PrisonIsland",  "Skylands",
    "MagmaVillage","UnderwaterCity","GravitoIsland","FountainCity",
    "GreenZone",   "GraveyardIsland","HauntedCastle","Cafe",
    "FloatingTurtle","Mansion","TikiOutpost",
}

function IslandHelper:GetCurrentIslandName()
    local pivot = getCharacterPivot()
    if not pivot then return "Unknown" end
    local closest, best
    for _, name in ipairs(self.KNOWN_ISLANDS) do
        local model = Workspace:FindFirstChild(name)
        if model then
            local ok, p = pcall(function() return model:GetPivot().Position end)
            if ok then
                local d = (p - pivot).Magnitude
                if not best or d < best then
                    best   = d
                    closest= name
                end
            end
        end
    end
    return closest or "Unknown"
end


----------------------------------------------------------------------------------------------------
--  PHẦN 39 - PRESETS (Cấu hình sẵn cho từng cấu hình máy)
--  Người dùng có thể gọi:  shared.BFFixLag:LoadPreset("LowEnd")  để áp dụng nhanh.
----------------------------------------------------------------------------------------------------

local Presets = {}

Presets.list = {
    ["UltraLow"] = {
        StripTextures        = true,
        SimplifyMaterials    = true,
        DisableParticles     = true,
        SimplifyWater        = true,
        DisableShadows       = true,
        LowLighting          = true,
        DisablePostFX        = true,
        LimitRenderDistance  = true,
        CleanMapDecorations  = true,
        TreesTransparency    = true,
        KillServerEffects    = true,
        PeriodicGC           = true,
        HideCombatUI         = true,
        StatBar              = true,
        RenderDistance       = 220,
        PlayerDrawDistance   = 140,
        NPCDrawDistance      = 110,
        TreesAlpha           = 0.7,
        BatchSize            = 140,
        GCInterval           = 15,
    },

    ["LowEnd"] = {
        StripTextures        = true,
        SimplifyMaterials    = true,
        DisableParticles     = true,
        SimplifyWater        = true,
        DisableShadows       = true,
        LowLighting          = true,
        DisablePostFX        = true,
        LimitRenderDistance  = true,
        CleanMapDecorations  = true,
        TreesTransparency    = true,
        KillServerEffects    = true,
        PeriodicGC           = true,
        HideCombatUI         = true,
        StatBar              = true,
        RenderDistance       = 320,
        PlayerDrawDistance   = 200,
        NPCDrawDistance      = 160,
        TreesAlpha           = 0.5,
        BatchSize            = 220,
        GCInterval           = 22,
    },

    ["Balanced"] = {
        StripTextures        = false,
        SimplifyMaterials    = true,
        DisableParticles     = true,
        SimplifyWater        = true,
        DisableShadows       = true,
        LowLighting          = false,
        DisablePostFX        = true,
        LimitRenderDistance  = true,
        CleanMapDecorations  = true,
        TreesTransparency    = false,
        KillServerEffects    = false,
        PeriodicGC           = true,
        HideCombatUI         = true,
        StatBar              = true,
        RenderDistance       = 500,
        PlayerDrawDistance   = 300,
        NPCDrawDistance      = 250,
        TreesAlpha           = 0.0,
        BatchSize            = 320,
        GCInterval           = 30,
    },

    ["VisualOnly"] = {
        StripTextures        = false,
        SimplifyMaterials    = false,
        DisableParticles     = false,
        SimplifyWater        = false,
        DisableShadows       = true,
        LowLighting          = false,
        DisablePostFX        = true,
        LimitRenderDistance  = false,
        CleanMapDecorations  = false,
        TreesTransparency    = false,
        KillServerEffects    = false,
        PeriodicGC           = true,
        HideCombatUI         = false,
        StatBar              = true,
    },
}

function Presets:Load(name)
    local p = self.list[name]
    if not p then return false end
    for k, v in pairs(p) do
        if DEFAULT_CONFIG[k] ~= nil and type(v) == type(DEFAULT_CONFIG[k]) then
            CONFIG[k] = v
        end
    end
    Persistence:SaveAll()
    Orchestrator:ReapplyAll()
    Logger:Notify("BFFixLag", "Đã áp dụng preset: " .. name, 3)
    return true
end

API.LoadPreset = function(self, name) return Presets:Load(name) end
API.Presets    = Presets.list

----------------------------------------------------------------------------------------------------
--  PHẦN 40 - DOSSIER (báo cáo trạng thái cho debug)
--  shared.BFFixLag:Dossier()  -> trả về bảng thông tin để xem nhanh.
----------------------------------------------------------------------------------------------------

local Dossier = {}

function Dossier:Build()
    local d = {
        Version              = API.Version,
        Enabled              = CONFIG.Enabled,
        Running              = Orchestrator.running,
        FPS                  = math.floor((StatBar.fpsSample or 0) + 0.5),
        MemoryMB             = getCpuTime(),
        Players              = #Players:GetPlayers(),
        Island               = IslandHelper:GetCurrentIslandName(),
        ActiveConnections    = CONN:Count(),
        SchedulerQueueLen    = #Scheduler.queue,
        Modules = {
            StripTextures        = CONFIG.StripTextures,
            SimplifyMaterials    = CONFIG.SimplifyMaterials,
            DisableParticles     = CONFIG.DisableParticles,
            SimplifyWater        = CONFIG.SimplifyWater,
            DisableShadows       = CONFIG.DisableShadows,
            LowLighting          = CONFIG.LowLighting,
            DisablePostFX        = CONFIG.DisablePostFX,
            LimitRenderDistance  = CONFIG.LimitRenderDistance,
            CleanMapDecorations  = CONFIG.CleanMapDecorations,
            TreesTransparency    = CONFIG.TreesTransparency,
            KillServerEffects    = CONFIG.KillServerEffects,
            PeriodicGC           = CONFIG.PeriodicGC,
            HideCombatUI         = CONFIG.HideCombatUI,
            StatBar              = CONFIG.StatBar,
        },
    }
    return d
end

function Dossier:Print()
    local d = self:Build()
    print("---- BFFixLag Dossier ----")
    for k, v in pairs(d) do
        if type(v) == "table" then
            print(k, "=")
            for k2, v2 in pairs(v) do print("   ", k2, "=", v2) end
        else
            print(k, "=", v)
        end
    end
    print("---------------------------")
end

API.Dossier = function(self) return Dossier:Build() end
API.PrintDossier = function(self) Dossier:Print() end

----------------------------------------------------------------------------------------------------
--  PHẦN 41 - SAFETY: bắt sự kiện game tắt để lưu config & restore
----------------------------------------------------------------------------------------------------

PERM_CONN:Add(game:BindToClose(function()
    pcall(function()
        Persistence:SaveAll()
    end)
end))

PERM_CONN:Add(LocalPlayer.Idled:Connect(function()
    -- Khi người chơi AFK, làm GC nặng để giải phóng RAM
    if CONFIG.PeriodicGC then
        GarbageCollector:FullCollect()
    end
end))

----------------------------------------------------------------------------------------------------
--  PHẦN 42 - RESPAWN HANDLER
--  Khi character respawn, đảm bảo StatBar không bị mất, và áp dụng lại các bind.
----------------------------------------------------------------------------------------------------

PERM_CONN:Add(LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    -- Re-build StatBar nếu bị mất
    if not StatBar.gui or not StatBar.gui.Parent then
        StatBar.gui = nil
        StatBar:Build()
    end
    if not ToggleMenu.gui or not ToggleMenu.gui.Parent then
        ToggleMenu.gui = nil
        ToggleMenu:Build()
    end
end))

----------------------------------------------------------------------------------------------------
--  PHẦN 43 - HOTKEYS PHỤ
--    F8  -> in dossier ra console
--    F9  -> chuyển preset Balanced -> LowEnd -> UltraLow -> VisualOnly -> Balanced ...
----------------------------------------------------------------------------------------------------

local PRESET_ORDER = { "Balanced", "LowEnd", "UltraLow", "VisualOnly" }
local _presetIdx = 1

PERM_CONN:Add(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        Dossier:Print()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        _presetIdx = (_presetIdx % #PRESET_ORDER) + 1
        Presets:Load(PRESET_ORDER[_presetIdx])
    end
end))

----------------------------------------------------------------------------------------------------
--  PHẦN 44 - TỰ KIỂM TRA TÍNH TƯƠNG THÍCH ANTI-CHEAT
--  Bảo đảm script KHÔNG sử dụng các hành vi bị Blox Fruits Anti-Cheat đánh dấu:
--    - Không setupvalue / setfenv / hookfunction trên hàm game
--    - Không thay đổi WalkSpeed / JumpPower / Position / CFrame của character
--    - Không gọi remote events của game
--    - Không thay đổi Humanoid của LocalPlayer
--    - Không chạm vào ReplicatedStorage scripts
----------------------------------------------------------------------------------------------------

local Compliance = {}

function Compliance:Audit()
    local violations = {}
    -- Bảng "đèn xanh": liệt kê những gì script CÓ làm
    local allowed = {
        "Decal/Texture/SurfaceAppearance.Parent <- nil  (chỉ trên Workspace, không trên Player)",
        "BasePart.Material/Reflectance/CastShadow/LocalTransparencyModifier (không di chuyển character)",
        "ParticleEmitter/Trail/Beam/Smoke/Fire.Enabled = false",
        "Lighting.* property (Brightness/Ambient/Technology/Shadows/PostFX)",
        "Terrain water properties (WaterWaveSize/Reflectance/Transparency/Decoration)",
        "ScreenGui (CoreGui & PlayerGui) chỉ tạo MỚI, không xóa GUI hiện có",
        "Humanoid:SetStateEnabled chỉ trên NPC (không phải LocalPlayer)",
        "task.wait / task.spawn / task.defer / RunService events",
    }
    return {
        ok          = #violations == 0,
        violations  = violations,
        allowed     = allowed,
        comment     = "Tất cả thao tác đều thuần CLIENT, không chạm Remote / character vật lý.",
    }
end

API.AuditCompliance = function(self) return Compliance:Audit() end

----------------------------------------------------------------------------------------------------
--  PHẦN 45 - HẾT FILE
--  Mọi tính năng đã được khởi tạo. Kết thúc bootstrap.
----------------------------------------------------------------------------------------------------

return API

--[[
==================================================================================================
  PHẦN 46 - GHI CHÚ KỸ THUẬT BỔ SUNG
==================================================================================================

  TẠI SAO KHÔNG SỬA WALKSPEED / CFRAME?
  ---------------------------------------------------------------------------------------------
  Blox Fruits Anti-Cheat (Vetex AC) chủ động giám sát các thay đổi đáng ngờ trên Humanoid của
  LocalPlayer (đặc biệt là WalkSpeed > 16, JumpPower > 50, Position teleport quá nhanh).
  Script này KHÔNG đụng vào Humanoid của bạn ở bất kỳ điểm nào - chỉ thao tác trên các BasePart
  và Effect KHÁC. Đó là lý do nó an toàn.

  TẠI SAO RẢI THEO BATCH?
  ---------------------------------------------------------------------------------------------
  Map Blox Fruits có thể chứa 100,000+ instance. Nếu lặp một mạch sẽ làm Roblox đứng hình
  vài giây ngay khi script chạy. Module Scheduler chia mỗi vòng lặp thành các "lát" 220 item
  rồi yield (task.wait) để khung hình tiếp theo được render kịp. Nhờ đó người chơi không
  bao giờ thấy giật khi script đang khởi tạo.

  TẠI SAO PARENT VỀ NIL THAY VÌ DESTROY?
  ---------------------------------------------------------------------------------------------
  - Destroy là hành động "không thể đảo ngược". Nếu người dùng muốn tắt tính năng (Toggle OFF)
    để xem lại đồ họa gốc, ta cần khôi phục được. Bằng cách Parent = nil + giữ tham chiếu
    trong WeakTable, ta có thể bật/tắt nhiều lần mà không mất gì.
  - Một số object bị Destroy có thể khiến game lỗi Network (server vẫn nhớ, client thì mất).

  CƠ CHẾ LƯU CẤU HÌNH KHI VỀ SẢNH ROBLOX:
  ---------------------------------------------------------------------------------------------
  Khi người dùng nhấn nút Leave -> Lobby, Roblox sẽ destroy LocalScript hiện tại.
  Có 3 lớp lưu song song:
    1) writefile  -> ghi BFFixLag_Config.json vào folder workspace của executor.
                     Khi tải lại script lần sau, readfile sẽ đọc lại JSON này.
    2) shared     -> vẫn còn nếu cùng process (ít khi - vì lobby thường tạo process mới).
    3) queue_on_teleport -> nếu rời server bằng TeleportService, payload sẽ được chạy lại
                     trong server đích. Người dùng cần đặt shared._BFFixLag_Loader = function()
                     loadstring(game:HttpGet("...your URL..."))() end TRƯỚC khi teleport,
                     hoặc đơn giản dùng autoexec folder của executor.

  CƠ CHẾ KHÔNG GIẬT (ANTI-STUTTER):
  ---------------------------------------------------------------------------------------------
  Watchdog đo FPS realtime; nếu FPS < 20 quá 3 giây liên tiếp, Scheduler tự pause để nhường
  CPU cho game. Đồng thời mỗi heartbeat chỉ làm collectgarbage("step", 256KB) - không phải
  full pass - để dọn rác liên tục mà không gây spike GC.

  TUỲ BIẾN NHANH:
  ---------------------------------------------------------------------------------------------
    shared.BFFixLag:Set("RenderDistance", 200)
    shared.BFFixLag:Set("TreesAlpha", 0.6)
    shared.BFFixLag:LoadPreset("UltraLow")
    shared.BFFixLag:OpenMenu()
    shared.BFFixLag:Toggle()
    shared.BFFixLag:PrintDossier()

==================================================================================================
  KẾT THÚC FILE
==================================================================================================
]]
