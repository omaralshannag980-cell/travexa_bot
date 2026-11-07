-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI
local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
Gui.Name = "M1Tracker"
Gui.ResetOnSpawn = false

-- زرار فتح القائمة
local Button = Instance.new("TextButton", Gui)
Button.Size = UDim2.new(0,140,0,45)
Button.Position = UDim2.new(1,-160,0,20)
Button.BackgroundColor3 = Color3.fromRGB(25,25,25)
Button.Text = "📋 فتح القائمة"
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.GothamBold
Button.TextScaled = true
Instance.new("UICorner", Button).CornerRadius = UDim.new(0,12)

-- السحب للزرار
local dragging, dragInput, dragStart, startPos
Button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Button.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
Button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		Button.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	end
end)

-- الإطار الرئيسي
local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0,360,0,280)
Frame.Position = UDim2.new(0.5,-180,0.38,0)
Frame.BackgroundColor3 = Color3.fromRGB(18,18,25)
Frame.Visible = false
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

-- ظل
local Shadow = Instance.new("ImageLabel", Frame)
Shadow.ZIndex = -1
Shadow.Size = UDim2.new(1,30,1,30)
Shadow.Position = UDim2.new(0,-15,0,-15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageTransparency = 0.4

-- عنوان
local key=123
local function xorCrypt(str,key)
	local res={}
	for i=1,#str do
		res[i] = string.char(bit32.bxor(string.byte(str,i),key))
	end
	return table.concat(res)
end

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(28,28,34)
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(0,200,255)
Title.Text = xorCrypt(xorCrypt("📊 صنع نووي",key),key)
Title.TextScaled = true
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,12)

-- بيانات
local AllPlayersStats={}
local PlayersData={}
local playerFrameHeight=110
local spacing=10

-- تنسيق الوقت
local function formatTime(t)
	local h = math.floor(t/3600)
	local m = math.floor((t%3600)/60)
	local s = math.floor(t%60)
	return string.format("%02d:%02d:%02d",h,m,s)
end

-- إنشاء الإطارات
for i=1,4 do
	local row = math.floor((i-1)/2)
	local col = (i%2==0) and 0.52 or 0.02
	local PFrame = Instance.new("Frame", Frame)
	PFrame.Size = UDim2.new(0.46,0,0,playerFrameHeight)
	PFrame.Position = UDim2.new(col,0,0,40 + row*(playerFrameHeight + spacing))
	PFrame.BackgroundTransparency = 1

	local Box = Instance.new("TextBox", PFrame)
	Box.PlaceholderText = "✏️ اسم اللاعب "..i
	Box.Size = UDim2.new(1,0,0,25)
	Box.BackgroundColor3 = Color3.fromRGB(38,38,48)
	Box.TextColor3 = Color3.new(1,1,1)
	Box.Font = Enum.Font.GothamSemibold
	Box.TextScaled = true
	Instance.new("UICorner", Box).CornerRadius = UDim.new(0,6)

	local Image = Instance.new("ImageLabel", PFrame)
	Image.Size = UDim2.new(0,36,0,36)
	Image.Position = UDim2.new(1,-36,0.3,0)
	Image.BackgroundTransparency = 1

	local NameLabel = Instance.new("TextLabel", PFrame)
	NameLabel.Size = UDim2.new(0.6,0,0,18)
	NameLabel.Position = UDim2.new(0,0,0.3,0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextColor3 = Color3.new(1,1,1)
	NameLabel.TextScaled = true

	local JoinLabel = Instance.new("TextLabel", PFrame)
	JoinLabel.Size = UDim2.new(0.6,0,0,16)
	JoinLabel.Position = UDim2.new(0,0,0.5,0)
	JoinLabel.BackgroundTransparency = 1
	JoinLabel.Font = Enum.Font.GothamBold
	JoinLabel.TextColor3 = Color3.fromRGB(0,255,0)
	JoinLabel.Text = "✅ الدخول: 0"
	JoinLabel.TextScaled = true

	local LeaveLabel = Instance.new("TextLabel", PFrame)
	LeaveLabel.Size = UDim2.new(0.6,0,0,16)
	LeaveLabel.Position = UDim2.new(0,0,0.65,0)
	LeaveLabel.BackgroundTransparency = 1
	LeaveLabel.Font = Enum.Font.GothamBold
	LeaveLabel.TextColor3 = Color3.fromRGB(255,0,0)
	LeaveLabel.Text = "❌ الخروج: 0"
	LeaveLabel.TextScaled = true

	local TimeLabel = Instance.new("TextLabel", PFrame)
	TimeLabel.Size = UDim2.new(0.6,0,0,16)
	TimeLabel.Position = UDim2.new(0,0,0.82,0)
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Font = Enum.Font.GothamBold
	TimeLabel.TextColor3 = Color3.new(1,1,1)
	TimeLabel.Text = "⏱️ 00:00:00"
	TimeLabel.TextScaled = true

	PlayersData[i] = {Box=Box,Image=Image,NameLabel=NameLabel,JoinLabel=JoinLabel,LeaveLabel=LeaveLabel,TimeLabel=TimeLabel,Time=0,Running=false,currentPlayer=nil}

	-- البحث
	Box:GetPropertyChangedSignal("Text"):Connect(function()
		local text=Box.Text:lower()
		local foundPlayer=nil
		for _,pl in pairs(Players:GetPlayers()) do
			if pl.Name:lower():find(text) or pl.DisplayName:lower():find(text) then
				foundPlayer=pl
				break
			end
		end
		PlayersData[i].currentPlayer=foundPlayer
		if foundPlayer then
			Image.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..foundPlayer.UserId.."&width=100&height=100&format=png"
			NameLabel.Text="👤 "..foundPlayer.Name
			PlayersData[i].Running=true
			PlayersData[i].Time=AllPlayersStats[foundPlayer.UserId] and AllPlayersStats[foundPlayer.UserId].Time or 0
		else
			Image.Image=""
			NameLabel.Text=""
			PlayersData[i].Running=false
		end
		local stats=foundPlayer and AllPlayersStats[foundPlayer.UserId] or {JoinCount=0,LeaveCount=0,Time=0}
		JoinLabel.Text="✅ الدخول: "..stats.JoinCount
		LeaveLabel.Text="❌ الخروج: "..stats.LeaveCount
		TimeLabel.Text="⏱️ "..formatTime(stats.Time)
	end)
end

-- تحديث العداد
RunService.Heartbeat:Connect(function(deltaTime)
	for i=1,4 do
		local pdata=PlayersData[i]
		if pdata.currentPlayer and pdata.Running then
			pdata.Time+=deltaTime
			pdata.TimeLabel.Text="⏱️ "..formatTime(pdata.Time)
		end
	end
end)

-- عند دخول لاعب
Players.PlayerAdded:Connect(function(pl)
	if not AllPlayersStats[pl.UserId] then
		AllPlayersStats[pl.UserId]={JoinCount=0,LeaveCount=0,Time=0}
	end
	AllPlayersStats[pl.UserId].JoinCount+=1
	for i=1,4 do
		local pdata=PlayersData[i]
		if pdata.currentPlayer and pdata.currentPlayer.UserId==pl.UserId then
			pdata.JoinLabel.Text="✅ الدخول: "..AllPlayersStats[pl.UserId].JoinCount
			pdata.Running=true
			pdata.Time=AllPlayersStats[pl.UserId].Time
		end
	end
end)

-- عند خروج لاعب
Players.PlayerRemoving:Connect(function(pl)
	if not AllPlayersStats[pl.UserId] then
		AllPlayersStats[pl.UserId]={JoinCount=0,LeaveCount=0,Time=0}
	end
	AllPlayersStats[pl.UserId].LeaveCount+=1
	for i=1,4 do
		local pdata=PlayersData[i]
		if pdata.currentPlayer and pdata.currentPlayer.UserId==pl.UserId then
			pdata.LeaveLabel.Text="❌ الخروج: "..AllPlayersStats[pl.UserId].LeaveCount
			pdata.Running=false
			AllPlayersStats[pl.UserId].Time=pdata.Time
		end
	end
end)

-- Animation فتح/غلق القائمة
local function toggleFrame(frame)
	if frame.Visible == false then
		frame.Visible = true
		frame.Size = UDim2.new(0,0,0,0)
		local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,360,0,280)})
		tween:Play()
	else
		local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
		tween:Play()
		tween.Completed:Connect(function()
			frame.Visible = false
			frame.Size = UDim2.new(0,360,0,280)
		end)
	end
end

Button.MouseButton1Click:Connect(function()
	toggleFrame(Frame)
end)


-- =====================================================================
-- الإضافات الجديدة (بدون المساس بالكود الأصلي أو الزر القديم)
-- =====================================================================

-- دالة لسحب أي عنصر (لتستخدم للأزرار والواجهات الجديدة)
local function makeDraggable(obj)
	local dragging, dragInput, dragStart, startPos
	obj.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = obj.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	obj.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			obj.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end)
end

-- 1. إنشاء زرين جديدين
local Btn1 = Instance.new("TextButton", Gui)
Btn1.Size = UDim2.new(0,140,0,45)
Btn1.Position = UDim2.new(1,-160,0,75) -- تحت الزر الأصلي
Btn1.BackgroundColor3 = Color3.fromRGB(45,25,45)
Btn1.Text = "🛠️ تزوير الإحصائيات"
Btn1.TextColor3 = Color3.new(1,1,1)
Btn1.Font = Enum.Font.GothamBold
Btn1.TextScaled = true
Instance.new("UICorner", Btn1).CornerRadius = UDim.new(0,12)
makeDraggable(Btn1)

local Btn2 = Instance.new("TextButton", Gui)
Btn2.Size = UDim2.new(0,140,0,45)
Btn2.Position = UDim2.new(1,-160,0,130)
Btn2.BackgroundColor3 = Color3.fromRGB(25,45,25)
Btn2.Text = "ℹ️ معلومات الإضافة"
Btn2.TextColor3 = Color3.new(1,1,1)
Btn2.Font = Enum.Font.GothamBold
Btn2.TextScaled = true
Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0,12)
makeDraggable(Btn2)

-- 2. إنشاء الواجهات الجديدة
local FakeGuiFrame = Instance.new("Frame", Gui)
FakeGuiFrame.Size = UDim2.new(0,300,0,150)
FakeGuiFrame.Position = UDim2.new(0.5,-150,0.5,-75)
FakeGuiFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FakeGuiFrame.Visible = false
FakeGuiFrame.Active = true
Instance.new("UICorner", FakeGuiFrame).CornerRadius = UDim.new(0,12)
makeDraggable(FakeGuiFrame)

local FakeTitle = Instance.new("TextLabel", FakeGuiFrame)
FakeTitle.Size = UDim2.new(1,0,0,35)
FakeTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
FakeTitle.Text = "اكتب أول 3 أحرف من اسم اللاعب"
FakeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FakeTitle.Font = Enum.Font.GothamBold
FakeTitle.TextScaled = true
FakeTitle.Parent = FakeGuiFrame
Instance.new("UICorner", FakeTitle).CornerRadius = UDim.new(0,12)

local InputBox = Instance.new("TextBox", FakeGuiFrame)
InputBox.Size = UDim2.new(1,-40,0,40)
InputBox.Position = UDim2.new(0,20,0,55)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
InputBox.PlaceholderText = "مثال: BOT أو lai..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.new(1,1,1)
InputBox.Font = Enum.Font.GothamSemibold
InputBox.TextScaled = true
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0,6)

local HintText = Instance.new("TextLabel", FakeGuiFrame)
HintText.Size = UDim2.new(1,-20,0,30)
HintText.Position = UDim2.new(0,10,0,105)
HintText.BackgroundTransparency = 1
HintText.Text = "اضغط Enter بعد كتابة الأحرف"
HintText.TextColor3 = Color3.fromRGB(200, 200, 200)
HintText.Font = Enum.Font.GothamMedium
HintText.TextScaled = true

local InfoFrame = Instance.new("Frame", Gui)
InfoFrame.Size = UDim2.new(0,250,0,100)
InfoFrame.Position = UDim2.new(0.5,-125,0.5,-50)
InfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
InfoFrame.Visible = false
InfoFrame.Active = true
Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0,12)
makeDraggable(InfoFrame)

local InfoLabel = Instance.new("TextLabel", InfoFrame)
InfoLabel.Size = UDim2.new(1,-20,1,-20)
InfoLabel.Position = UDim2.new(0,10,0,10)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "هذه الإضافة تقوم بتزوير الإحصائيات (دخول/خروج) بالتناوب للاعبين المسجلين في القائمة الأصلية."
InfoLabel.TextColor3 = Color3.new(1,1,1)
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextScaled = true
InfoLabel.TextWrapped = true

-- 3. منطق فتح وغلق الواجهات
local function toggleGui(frame)
	frame.Visible = not frame.Visible
end

Btn1.MouseButton1Click:Connect(function() toggleGui(FakeGuiFrame) end)
Btn2.MouseButton1Click:Connect(function() toggleGui(InfoFrame) end)

-- 4. منطق التزوير المتناوب عند الضغط على Enter
local ToggleStates = {} -- جدول لحفظ حالة كل لاعب (هل التالي خروج أم دخول؟)

InputBox.FocusLost:Connect(function(enterPressed)
	if not enterPressed then return end

	local searchText = string.lower(InputBox.Text)
	if #searchText == 0 then return end

	local targetPlayer = nil

	-- البحث عن اللاعب بالحروف المكتوبة (سواء بالاسم أو الـ DisplayName)
	for _, pl in pairs(Players:GetPlayers()) do
		if string.sub(string.lower(pl.Name), 1, #searchText) == searchText or 
		   string.sub(string.lower(pl.DisplayName), 1, #searchText) == searchText then
			targetPlayer = pl
			break
		end
	end

	if targetPlayer then
		-- التأكد أن اللاعب موجود في الواجهة الأصلية (مسجل في أحد المربعات الأربعة)
		local isRegistered = false
		local slotIndex = 0
		for i = 1, 4 do
			if PlayersData[i].currentPlayer and PlayersData[i].currentPlayer.UserId == targetPlayer.UserId then
				isRegistered = true
				slotIndex = i
				break
			end
		end

		if isRegistered then
			local userId = targetPlayer.UserId
			
			-- تهيئة الحالة إذا كان اللاعب جديد
			if not ToggleStates[userId] then
				ToggleStates[userId] = 0
				if not AllPlayersStats[userId] then
					AllPlayersStats[userId] = {JoinCount = 0, LeaveCount = 0, Time = 0}
				end
			end

			-- زيادة عداد التبديل
			ToggleStates[userId] = ToggleStates[userId] + 1
			local step = ToggleStates[userId]

			-- الحساب الرياضي للتناوب (خروج 1، دخول 1، خروج 2، دخول 2...)
			local newLeave = math.floor((step + 1) / 2)
			local newJoin = math.floor(step / 2)

			-- تحديث البيانات الفعلية في السكربت
			AllPlayersStats[userId].LeaveCount = newLeave
			AllPlayersStats[userId].JoinCount = newJoin

			-- تحديث الواجهة الأصلية فوراً
			PlayersData[slotIndex].LeaveLabel.Text = "❌ الخروج: " .. newLeave
			PlayersData[slotIndex].JoinLabel.Text = "✅ الدخول: " .. newJoin

			-- تفريغ المربع للاستخدام مرة أخرى
			InputBox.Text = ""
		else
			-- تنبيه إذا لم يكن اللاعب مسجلاً في الواجهة الأصلية
			InputBox.Text = "اللاعب غير مسجل بالقائمة!"
			task.wait(1)
			InputBox.Text = ""
		end
	else
		-- تنبيه إذا لم يتم العثور على اللاعب
		InputBox.Text = "لم يتم العثور على اللاعب!"
		task.wait(1)
		InputBox.Text = ""
	end
end)
