-- ═══════════════════════════════════════════════════════════════════════
-- 🔱 A_A PANEL | نسخ + أوامر + سبام + تحكم 🔱
-- ═══════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════
-- 🧹 تنظيف القديم
-- ═══════════════════════════════════════════════════════════════════════

for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "A_A_Panel" or gui.Name == "A_A_Spam" or gui.Name == "A_A_Skins" then
        gui:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎨 الألوان
-- ═══════════════════════════════════════════════════════════════════════

local Colors = {
    Background = Color3.fromRGB(8, 12, 18),
    PanelBg = Color3.fromRGB(15, 20, 28),
    Accent = Color3.fromRGB(0, 220, 100),
    AccentDark = Color3.fromRGB(0, 140, 65),
    Red = Color3.fromRGB(220, 50, 50),
    Orange = Color3.fromRGB(255, 140, 0),
    Blue = Color3.fromRGB(0, 150, 255),
    Purple = Color3.fromRGB(147, 0, 211),
    Pink = Color3.fromRGB(255, 105, 180),
    Yellow = Color3.fromRGB(255, 215, 0),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(180, 180, 180)
}

-- ═══════════════════════════════════════════════════════════════════════
-- 📦 المتغيرات
-- ═══════════════════════════════════════════════════════════════════════

local SelectedPlayer = nil
local SpamActive = false
local SpamThread = nil
local AdminPrefix = ";"
local CurrentTab = "نسخ"
local ChatHidden = false

-- ═══════════════════════════════════════════════════════════════════════
-- 💬 شات افتراضي (Virtual Chat)
-- ═══════════════════════════════════════════════════════════════════════

local function SendVirtualMessage(msg)
    pcall(function()
        local dataService = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if dataService then
            local remote = dataService:FindFirstChild("DataService")
            if remote and remote:IsA("RemoteEvent") then
                remote:FireServer(msg)
            end
        end
    end)

    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if channel then
                channel:SendAsync(msg)
            end
        end
    end)

    pcall(function()
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents then
            local sayEvent = chatEvents:FindFirstChild("SayMessageRequest")
            if sayEvent then
                sayEvent:FireServer(msg, "All")
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🏗️ الواجهة الرئيسية
-- ═══════════════════════════════════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "A_A_Panel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.15, 0)
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Colors.Accent
MainStroke.Thickness = 2

-- ═══════════════════════════════════════════════════════════════════════
-- 📌 شريط العنوان
-- ═══════════════════════════════════════════════════════════════════════

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Colors.PanelBg
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "A_A + K4 + IFQ"
Title.TextColor3 = Colors.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Colors.Red
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.White
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ═══════════════════════════════════════════════════════════════════════
-- 📑 علامات التبويب
-- ═══════════════════════════════════════════════════════════════════════

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 40)
TabFrame.Position = UDim2.new(0, 10, 0, 52)
TabFrame.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabFrame)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 12)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -20, 1, -100)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundTransparency = 1

local function CreateTab(name)
    local tabBtn = Instance.new("TextButton", TabFrame)
    tabBtn.Size = UDim2.new(0, 130, 1, 0)
    tabBtn.BackgroundColor3 = (name == CurrentTab) and Colors.AccentDark or Colors.PanelBg
    tabBtn.Text = name
    tabBtn.TextColor3 = Colors.White
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 16
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)

    local tabContent = Instance.new("Frame", ContentFrame)
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = (name == CurrentTab)
    tabContent.Name = name .. "Content"

    tabBtn.MouseButton1Click:Connect(function()
        CurrentTab = name
        for _, btn in ipairs(TabFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Text == name) and Colors.AccentDark or Colors.PanelBg
            end
        end
        for _, content in ipairs(ContentFrame:GetChildren()) do
            if content:IsA("Frame") then
                content.Visible = (content.Name == name .. "Content")
            end
        end
    end)

    return tabContent
end

local CopyTab = CreateTab("نسخ")
local ControlTab = CreateTab("تحكم")

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 تبويب النسخ - قائمة اللاعبين
-- ═══════════════════════════════════════════════════════════════════════

local PlayerList = Instance.new("ScrollingFrame", CopyTab)
PlayerList.Size = UDim2.new(0.55, -5, 1, 0)
PlayerList.Position = UDim2.new(0, 0, 0, 0)
PlayerList.BackgroundColor3 = Colors.PanelBg
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = Colors.Accent
Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 12)

local PlayerLayout = Instance.new("UIListLayout", PlayerList)
PlayerLayout.Padding = UDim.new(0, 6)
PlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ═══════════════════════════════════════════════════════════════════════
-- ⚡ تبويب النسخ - منطقة الأوامر
-- ═══════════════════════════════════════════════════════════════════════

local CmdArea = Instance.new("Frame", CopyTab)
CmdArea.Size = UDim2.new(0.43, -5, 1, 0)
CmdArea.Position = UDim2.new(0.57, 0, 0, 0)
CmdArea.BackgroundColor3 = Colors.PanelBg
CmdArea.BorderSizePixel = 0
Instance.new("UICorner", CmdArea).CornerRadius = UDim.new(0, 12)

local CmdLayout = Instance.new("UIListLayout", CmdArea)
CmdLayout.Padding = UDim.new(0, 6)
CmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
CmdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- حالة الاختيار
local StatusLabel = Instance.new("TextLabel", CmdArea)
StatusLabel.Size = UDim2.new(0.92, 0, 0, 35)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
StatusLabel.Text = "لم يتم اختيار لاعب"
StatusLabel.TextColor3 = Colors.Gray
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)

-- حقل علامة الأدمن
local AdminFrame = Instance.new("Frame", CmdArea)
AdminFrame.Size = UDim2.new(0.92, 0, 0, 38)
AdminFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 45)
AdminFrame.BorderSizePixel = 0
Instance.new("UICorner", AdminFrame).CornerRadius = UDim.new(0, 8)

local AdminIcon = Instance.new("TextLabel", AdminFrame)
AdminIcon.Size = UDim2.new(0, 35, 1, 0)
AdminIcon.BackgroundColor3 = Colors.Blue
AdminIcon.Text = "ℹ"
AdminIcon.TextColor3 = Colors.White
AdminIcon.Font = Enum.Font.GothamBold
AdminIcon.TextSize = 18
Instance.new("UICorner", AdminIcon).CornerRadius = UDim.new(0, 8)

local AdminInput = Instance.new("TextBox", AdminFrame)
AdminInput.Size = UDim2.new(1, -45, 1, -8)
AdminInput.Position = UDim2.new(0, 42, 0, 4)
AdminInput.BackgroundTransparency = 1
AdminInput.Text = ""
AdminInput.PlaceholderText = "اكتب علامة الادمن"
AdminInput.TextColor3 = Colors.White
AdminInput.PlaceholderColor3 = Colors.Gray
AdminInput.Font = Enum.Font.GothamSemibold
AdminInput.TextSize = 13
AdminInput.ClearTextOnFocus = false

AdminInput.FocusLost:Connect(function()
    if AdminInput.Text ~= "" then
        AdminPrefix = AdminInput.Text
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- 🔘 دالة إنشاء زر
-- ═══════════════════════════════════════════════════════════════════════

local function CreateButton(parent, text, color, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.BackgroundColor3 = color or Colors.AccentDark
    btn.Text = text
    btn.TextColor3 = Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- ═══════════════════════════════════════════════════════════════════════
-- 📋 أزرار النسخ الرئيسية
-- ═══════════════════════════════════════════════════════════════════════

CreateButton(CmdArea, "📋 اسم كامل", Colors.Accent, function()
    if not SelectedPlayer then StatusLabel.Text = "❌ اختر لاعب أولاً"; return end
    local cmd = AdminPrefix .. "name " .. SelectedPlayer.Name
    pcall(function() setclipboard(cmd) end)
    StatusLabel.Text = "✅ تم النسخ: " .. cmd
end)

CreateButton(CmdArea, "🔄 ثلاث حروف", Colors.AccentDark, function()
    if not SelectedPlayer then StatusLabel.Text = "❌ اختر لاعب أولاً"; return end
    local short = string.sub(SelectedPlayer.Name, 1, 3)
    local cmd = AdminPrefix .. "name " .. short
    pcall(function() setclipboard(cmd) end)
    StatusLabel.Text = "✅ تم النسخ: " .. cmd
end)

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 صف الأزرار السفلي (سبام / تشغيل / إيقاف)
-- ═══════════════════════════════════════════════════════════════════════

local BottomRow = Instance.new("Frame", CmdArea)
BottomRow.Size = UDim2.new(0.92, 0, 0, 40)
BottomRow.BackgroundTransparency = 1

local BottomLayout = Instance.new("UIListLayout", BottomRow)
BottomLayout.FillDirection = Enum.FillDirection.Horizontal
BottomLayout.Padding = UDim.new(0, 6)

local SpamLabelBtn = Instance.new("TextButton", BottomRow)
SpamLabelBtn.Size = UDim2.new(0.3, 0, 1, 0)
SpamLabelBtn.BackgroundColor3 = Colors.PanelBg
SpamLabelBtn.Text = "سبام"
SpamLabelBtn.TextColor3 = Colors.Orange
SpamLabelBtn.Font = Enum.Font.GothamBold
SpamLabelBtn.TextSize = 14
Instance.new("UICorner", SpamLabelBtn).CornerRadius = UDim.new(0, 10)

local ExecuteBtn = Instance.new("TextButton", BottomRow)
ExecuteBtn.Size = UDim2.new(0.35, 0, 1, 0)
ExecuteBtn.BackgroundColor3 = Colors.Red
ExecuteBtn.Text = "تشغيل"
ExecuteBtn.TextColor3 = Colors.White
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 14
Instance.new("UICorner", ExecuteBtn).CornerRadius = UDim.new(0, 10)

local StopBtn = Instance.new("TextButton", BottomRow)
StopBtn.Size = UDim2.new(0.3, 0, 1, 0)
StopBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
StopBtn.Text = "إيقاف"
StopBtn.TextColor3 = Colors.Gray
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 14
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 10)

-- ═══════════════════════════════════════════════════════════════════════
-- 🔄 تحديث قائمة اللاعبين
-- ═══════════════════════════════════════════════════════════════════════

local function UpdatePlayers()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerList)
            btn.Size = UDim2.new(0.95, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(28, 36, 46)
            btn.Text = plr.Name
            btn.TextColor3 = Colors.White
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 14
            btn.LayoutOrder = 1
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                SelectedPlayer = plr
                StatusLabel.Text = "✅ تم اختيار: " .. plr.Name
                StatusLabel.TextColor3 = Colors.Accent
            end)
        end
    end

    PlayerList.CanvasSize = UDim2.new(0, 0, 0, PlayerLayout.AbsoluteContentSize.Y + 10)
end

UpdatePlayers()
Players.PlayerAdded:Connect(UpdatePlayers)
Players.PlayerRemoving:Connect(UpdatePlayers)

-- ═══════════════════════════════════════════════════════════════════════
-- ⚙️ تبويب التحكم
-- ═══════════════════════════════════════════════════════════════════════

local ControlScroll = Instance.new("ScrollingFrame", ControlTab)
ControlScroll.Size = UDim2.new(1, 0, 1, 0)
ControlScroll.BackgroundTransparency = 1
ControlScroll.ScrollBarThickness = 4
ControlScroll.ScrollBarImageColor3 = Colors.Accent

local ControlLayout = Instance.new("UIListLayout", ControlScroll)
ControlLayout.Padding = UDim.new(0, 10)
ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateControlBtn(text, txtColor, callback)
    local frame = Instance.new("Frame", ControlScroll)
    frame.Size = UDim2.new(0.95, 0, 0, 48)
    frame.BackgroundColor3 = Colors.PanelBg
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = txtColor or Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- ═══════════════════════════════════════════════════════════════════════
-- 🎯 أزرار التحكم المعدلة
-- ═══════════════════════════════════════════════════════════════════════

-- 1. سبام غامض
CreateControlBtn("🔥 سبام غامض", Colors.Orange, function()
    if not SelectedPlayer then
        StatusLabel.Text = "❌ اختر لاعب أولاً"
        return
    end
    local name = SelectedPlayer.Name
    local cmds = {
        AdminPrefix .. "explode " .. name,
        AdminPrefix .. "warp " .. name,
        AdminPrefix .. "freeze " .. name,
        AdminPrefix .. "volume " .. name,
        AdminPrefix .. "cmdbar " .. name,
        AdminPrefix .. "logs " .. name,
        AdminPrefix .. "nv " .. name,
        AdminPrefix .. "res " .. name,
        AdminPrefix .. "fling " .. name,
        AdminPrefix .. "jail " .. name,
        AdminPrefix .. "name " .. name,
        AdminPrefix .. "ice " .. name,
        AdminPrefix .. "Char miri " .. name,
        AdminPrefix .. "dog " .. name,
        AdminPrefix .. "ping " .. name
    }
    for _, cmd in ipairs(cmds) do
        SendVirtualMessage(cmd)
        task.wait(0.15)
    end
end)

-- 2. سبام هيد أدمن
CreateControlBtn("⚡ سبام هيد أدمن", Colors.Red, function()
    if not SelectedPlayer then
        StatusLabel.Text = "❌ اختر لاعب أولاً"
        return
    end
    local name = SelectedPlayer.Name
    local cmds = {
        AdminPrefix .. "explode " .. name,
        AdminPrefix .. "volume " .. name,
        AdminPrefix .. "cmdbar " .. name,
        AdminPrefix .. "logs " .. name,
        AdminPrefix .. "nv " .. name,
        AdminPrefix .. "res " .. name,
        AdminPrefix .. "fling " .. name,
        AdminPrefix .. "jail " .. name,
        AdminPrefix .. "name " .. name,
        AdminPrefix .. "ice " .. name,
        AdminPrefix .. "Char miri " .. name,
        AdminPrefix .. "dog " .. name,
        AdminPrefix .. "ping " .. name
    }
    for _, cmd in ipairs(cmds) do
        SendVirtualMessage(cmd)
        task.wait(0.15)
    end
end)

-- 3. إخفاء رسائل سبام HD
CreateControlBtn("👁️ إخفاء رسائل سبام", Colors.Yellow, function()
    ChatHidden = not ChatHidden
    pcall(function()
        local chatFrame = LocalPlayer.PlayerGui:FindFirstChild("Chat")
        if chatFrame then
            chatFrame.Enabled = not ChatHidden
        end
        for _, bubble in ipairs(workspace:GetDescendants()) do
            if bubble.Name == "BubbleChat" or bubble.Name == "ChatBubble" then
                bubble.Enabled = not ChatHidden
            end
        end
    end)
end)

-- 4. تحكم الرابع
CreateControlBtn("🎮 تحكم الرابع", Colors.Accent)

-- 5. تشغيل الدوران
CreateControlBtn("🔄 تشغيل الدوران", Colors.Accent)

-- 6. إيقاف الدوران
CreateControlBtn("⏹️ إيقاف الدوران", Colors.Red)

-- 7. حماية من logs / clogs
CreateControlBtn("🛡️ حماية من logs", Colors.Blue)

-- 8. نسخه معسلة من سكربت بلو
CreateControlBtn("🔧 نسخه معسلة", Colors.Accent)

-- 9. تحكم في هات ال allk
CreateControlBtn("🎯 تحكم في allk", Colors.Accent)

ControlScroll.CanvasSize = UDim2.new(0, 0, 0, ControlLayout.AbsoluteContentSize.Y + 20)

-- ═══════════════════════════════════════════════════════════════════════
-- 🟢 الأزرار العائمة
-- ═══════════════════════════════════════════════════════════════════════

local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0.02, 0, 0.45, -27)
FloatBtn.BackgroundColor3 = Colors.AccentDark
FloatBtn.Text = "A_A"
FloatBtn.TextColor3 = Colors.White
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 18
FloatBtn.Draggable = true
FloatBtn.ZIndex = 5
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatBtn).Color = Colors.Accent
Instance.new("UIStroke", FloatBtn).Thickness = 2

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ═══════════════════════════════════════════════════════════════════════
-- 📤 تنفيذ الأوامر (تشغيل) - الأوامر القديمة
-- ═══════════════════════════════════════════════════════════════════════

ExecuteBtn.MouseButton1Click:Connect(function()
    if not SelectedPlayer then
        StatusLabel.Text = "❌ اختر لاعب أولاً"
        return
    end

    local name = SelectedPlayer.Name
    local allCmds = {
        AdminPrefix .. "cmdbar " .. name,
        AdminPrefix .. "logs " .. name,
        AdminPrefix .. "nv " .. name,
        AdminPrefix .. "tp " .. name,
        AdminPrefix .. "res " .. name,
        AdminPrefix .. "fling " .. name,
        AdminPrefix .. "jail " .. name,
        AdminPrefix .. "name " .. name,
        AdminPrefix .. "ice " .. name,
        AdminPrefix .. "Char miri " .. name,
        AdminPrefix .. "dog " .. name,
        AdminPrefix .. "ping " .. name
    }

    local clipboardText = table.concat(allCmds, "\n")
    pcall(function() setclipboard(clipboardText) end)

    StatusLabel.Text = "✅ تم نسخ جميع الأوامر"

    for _, cmd in ipairs(allCmds) do
        SendVirtualMessage(cmd)
        task.wait(0.15)
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    if SpamActive then
        SpamActive = false
    end
    StatusLabel.Text = "⏹️ تم الإيقاف"
end)

SpamLabelBtn.MouseButton1Click:Connect(function()
    if not SelectedPlayer then
        StatusLabel.Text = "❌ اختر لاعب أولاً"
        return
    end
    local name = SelectedPlayer.Name
    local cmds = {
        AdminPrefix .. "explode " .. name,
        AdminPrefix .. "volume " .. name,
        AdminPrefix .. "cmdbar " .. name,
        AdminPrefix .. "logs " .. name,
        AdminPrefix .. "nv " .. name,
        AdminPrefix .. "res " .. name,
        AdminPrefix .. "fling " .. name,
        AdminPrefix .. "jail " .. name,
        AdminPrefix .. "name " .. name,
        AdminPrefix .. "ice " .. name,
        AdminPrefix .. "Char miri " .. name,
        AdminPrefix .. "dog " .. name,
        AdminPrefix .. "ping " .. name
    }
    for _, cmd in ipairs(cmds) do
        SendVirtualMessage(cmd)
        task.wait(0.15)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- ✅ إنهاء
-- ═══════════════════════════════════════════════════════════════════════

print("✅ A_A Panel جاهز! | سبام عادي مفعل")
