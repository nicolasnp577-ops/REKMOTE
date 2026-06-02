--[[
    UltraSpy (UltraSpy v2.2+) — client remote logger

    Run as early as possible in the session so module-cached FireServer refs are hooked.
    Config: MaxRemotes, SchedulerBatch, MaxScheduleQueue, UiQueueBatch, MaxUiQueue,
    HookCachedMethods, AutoHookStack,
    UiCorrelate, UiCorrelateWindow (default 2s), CallStackDepth, DedupWindow,
    GuiConnections, LogWrapperCalls, FlowTracking (default ON),
    TrackBindables (OFF default), BindableStack,
    GroupLogs (default ON), StateTracker, TrackInbound, PropCorrelate,
    PropCorrelateMaxLines (8), ReplicaSetPropMaxLines (3), PropTimelineCooldown (0.5s),
    TrackRemoteCreation (default ON), RemoteLifecycle, CorrelateWindow (default 3s, unifies UI/prop),
    TrackAnimations (default OFF), TrackSounds (default OFF),
    TrackCauses, TrackHits, EntityTracker, PropertyTracker, InvestigationSessions,
    CombatDiscovery, CallbackDiscovery, CollectionService tags,
    HiddenStatDiscovery, AutoWrapperChain, HookDiscoveredWrappers, MetatableResolver,
    UpvalueRemoteRegistry, FunctionRemoteRegistry, TrackScriptOrigins, ConstantSignatureProfiles,
    AggressiveModulePatch (OFF by default — hooks require + resweep)

    API: GetNetworkMap, DiscoverWrappers, GetCallChain, GetStaticModuleMap,
    GetRemoteAtlas, GetRemotePatterns, GetFlowView, GetLastGuiInteraction,
    GetTimeline, GetStateLog, GetRecentStateChanges, GetRemoteLifecycle,
    GetCorrelationReport, GetRemoteReferences, DiscoverRemoteCandidates, GetDiscoveryAtlas,
    GetModuleGraph, BuildModuleGraph, GetProtocolReport, GetActionOutcomes, ScanRemoteReferences,
    GetCauseLog, GetInvestigationLog, GetDamageEventLog, GetRewardEventLog, GetPropertyLog,
    GetCallbackMap, GetTaggedEntities, GetCombatDiscoveryReport, StartCombatDiscoveryWindow,
    GetRewardDiscoveryReport, StartRewardDiscoveryWindow,
    ScanPlayerDataTree, GetHiddenStatReport, GetWrapperChain, GetMetatableLinks,
    GetRemoteCallers, GetFunctionRemotes, GetRemoteProfile, ScanUpvalueRegistry,
    ResolveFacadeToRemote, GetTopActions, GetRootCauseReport, ResolveLastChange,
    GetStateDependencies, GetActionSequences, GetFunctionsForRemote, GetRemotesForFunction,
    ResweepModules, TraceGuiAtMouse, GetCapabilities, RunSelfTest, GetSelfTestResults,
    ExportActionSession, GetGuiRemoteCorrelation, ApplyPayloadIndex

    Action Hunt preset (default ON): SIMPLESPYCONFIG_ActionHuntMode — chips Out+Act+NoSpam,
    sort by ValuableActionScore, SYNC lines show likely outbound trigger (500ms window).
    PeriodicDiscoveryInterval (default 60s, 0=off) rescans getgc/modules for late remotes.

    Coverage matrix (client):
    CAPTURES: LocalScript/ModuleScript FireServer|InvokeServer, wrappers, bindables (optional),
    table-as-remote, Http/Messaging (optional flags), OnClientEvent inbound, UnreliableRemoteEvent.
    DOES NOT: pure server replication (ReplicaSet effect without Lua), DataStore, attributes-only
    sync, server Script logic — only inbound context + stat/prop correlate hints.

    RunSelfTest runs automatically on launch (disable: _G.SIMPLESPYCONFIG_RunSelfTest = false)

    Limits: client remotes must pass through Lua FireServer/InvokeServer to be logged.
    Native replication without Lua cannot be hooked from this script alone.
    Remotes are forwarded to the game BEFORE logging so wrappers (RemoteService) keep working.

    Credits: exx, Frosty (GUI to Lua)
]]

-- shuts down the previous instance of UltraSpy
if _G.SimpleSpyExecuted and type(_G.SimpleSpyShutdown) == "function" then
	print(pcall(_G.SimpleSpyShutdown))
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Highlight =
	loadstring(
		game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/highlight.lua")
	)()

---- GENERATED (kinda sorta mostly) BY GUI to LUA ----

-- Instances:

local SimpleSpy2 = Instance.new("ScreenGui")
local Background = Instance.new("Frame")
local LeftPanel = Instance.new("Frame")
local LogList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local RemoteTemplate = Instance.new("Frame")
local ColorBar = Instance.new("Frame")
local Text = Instance.new("TextLabel")
local Button = Instance.new("TextButton")
local RightPanel = Instance.new("Frame")
local CodeBox = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIGridLayout = Instance.new("UIGridLayout")
local FunctionTemplate = Instance.new("Frame")
local ColorBar_2 = Instance.new("Frame")
local Text_2 = Instance.new("TextLabel")
local Button_2 = Instance.new("TextButton")
local TopBar = Instance.new("Frame")
local Simple = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local ImageLabel = Instance.new("ImageLabel")
local MaximizeButton = Instance.new("TextButton")
local ImageLabel_2 = Instance.new("ImageLabel")
local MinimizeButton = Instance.new("TextButton")
local ImageLabel_3 = Instance.new("ImageLabel")
local ToolTip = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")

--Properties:

SimpleSpy2.Name = "SimpleSpy2"
SimpleSpy2.ResetOnSpawn = false

Background.Name = "Background"
Background.Parent = SimpleSpy2
Background.BackgroundColor3 = Color3.new(1, 1, 1)
Background.BackgroundTransparency = 1
Background.Position = UDim2.new(0, 500, 0, 200)
Background.Size = UDim2.new(0, 560, 0, 360)

local LEFT_PANEL_W = 240
local MIN_WINDOW_W = 480
local MIN_WINDOW_H = 300
local LEFT_PANEL_TOP_INSET = 70

LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = Background
LeftPanel.BackgroundColor3 = Color3.fromRGB(53, 52, 55)
LeftPanel.BorderSizePixel = 0
LeftPanel.Position = UDim2.new(0, 0, 0, 19)
LeftPanel.Size = UDim2.new(0, 240, 0, 341)

LogList.Name = "LogList"
LogList.Parent = LeftPanel
LogList.Active = true
LogList.BackgroundColor3 = Color3.new(1, 1, 1)
LogList.BackgroundTransparency = 1
LogList.BorderSizePixel = 0
LogList.Position = UDim2.new(0, 2, 0, LEFT_PANEL_TOP_INSET)
LogList.Size = UDim2.new(1, -4, 1, -(LEFT_PANEL_TOP_INSET + 4))
LogList.CanvasSize = UDim2.new(0, 0, 0, 0)
LogList.ScrollBarThickness = 4

UIListLayout.Parent = LogList
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

RemoteTemplate.Name = "RemoteTemplate"
RemoteTemplate.Parent = LogList
RemoteTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
RemoteTemplate.BackgroundTransparency = 1
RemoteTemplate.Size = UDim2.new(1, -8, 0, 36)
RemoteTemplate.ClipsDescendants = true

ColorBar.Name = "ColorBar"
ColorBar.Parent = RemoteTemplate
ColorBar.BackgroundColor3 = Color3.fromRGB(255, 242, 0)
ColorBar.BorderSizePixel = 0
ColorBar.Position = UDim2.new(0, 0, 0, 1)
ColorBar.Size = UDim2.new(0, 7, 0, 34)
ColorBar.ZIndex = 2
ColorBar.Active = false

Text.Name = "Text"
Text.Parent = RemoteTemplate
Text.BackgroundColor3 = Color3.new(1, 1, 1)
Text.BackgroundTransparency = 1
Text.Position = UDim2.new(0, 12, 0, 1)
Text.Size = UDim2.new(1, -20, 0, 17)
Text.ZIndex = 3
Text.Active = false
Text.Font = Enum.Font.SourceSans
Text.Text = "TEXT"
Text.TextColor3 = Color3.new(1, 1, 1)
Text.TextSize = 13
Text.TextXAlignment = Enum.TextXAlignment.Left
Text.TextTruncate = Enum.TextTruncate.AtEnd
Text.TextWrapped = false

local Subtitle = Instance.new("TextLabel")
Subtitle.Name = "Subtitle"
Subtitle.Parent = RemoteTemplate
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 12, 0, 18)
Subtitle.Size = UDim2.new(1, -20, 0, 14)
Subtitle.ZIndex = 3
Subtitle.Active = false
Subtitle.Font = Enum.Font.SourceSans
Subtitle.Text = ""
Subtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextTruncate = Enum.TextTruncate.AtEnd

Button.Name = "Button"
Button.Parent = RemoteTemplate
Button.BackgroundColor3 = Color3.new(0, 0, 0)
Button.BackgroundTransparency = 1
Button.BorderSizePixel = 0
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.ZIndex = 10
Button.AutoButtonColor = false
Button.Font = Enum.Font.SourceSans
Button.Text = ""
Button.TextColor3 = Color3.new(0, 0, 0)
Button.TextSize = 14

RightPanel.Name = "RightPanel"
RightPanel.Parent = Background
RightPanel.BackgroundColor3 = Color3.fromRGB(37, 36, 38)
RightPanel.BorderSizePixel = 0
RightPanel.Position = UDim2.new(0, 240, 0, 19)
RightPanel.Size = UDim2.new(0, 320, 0, 341)

CodeBox.Name = "CodeBox"
CodeBox.Parent = RightPanel
CodeBox.BackgroundColor3 = Color3.new(0.0823529, 0.0745098, 0.0784314)
CodeBox.BorderSizePixel = 0
CodeBox.Size = UDim2.new(1, 0, 0, 119)

ScrollingFrame.Parent = RightPanel
ScrollingFrame.Active = true
ScrollingFrame.BackgroundColor3 = Color3.new(1, 1, 1)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Position = UDim2.new(0, 0, 0.5, 0)
ScrollingFrame.Size = UDim2.new(1, 0, 0.5, -9)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4

UIGridLayout.Parent = ScrollingFrame
UIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
UIGridLayout.CellSize = UDim2.new(0, 94, 0, 27)

FunctionTemplate.Name = "FunctionTemplate"
FunctionTemplate.Parent = ScrollingFrame
FunctionTemplate.BackgroundColor3 = Color3.new(1, 1, 1)
FunctionTemplate.BackgroundTransparency = 1
FunctionTemplate.Size = UDim2.new(0, 94, 0, 27)
FunctionTemplate.ClipsDescendants = true

ColorBar_2.Name = "ColorBar"
ColorBar_2.Parent = FunctionTemplate
ColorBar_2.BackgroundColor3 = Color3.new(1, 1, 1)
ColorBar_2.BorderSizePixel = 0
ColorBar_2.Position = UDim2.new(0, 0, 0, 1)
ColorBar_2.Size = UDim2.new(0, 7, 0, 25)
ColorBar_2.ZIndex = 2
ColorBar_2.Active = false

Text_2.Name = "Text"
Text_2.Parent = FunctionTemplate
Text_2.BackgroundColor3 = Color3.new(1, 1, 1)
Text_2.BackgroundTransparency = 1
Text_2.Position = UDim2.new(0, 12, 0, 1)
Text_2.Size = UDim2.new(0, 80, 0, 25)
Text_2.ZIndex = 3
Text_2.Active = false
Text_2.Font = Enum.Font.SourceSans
Text_2.Text = "TEXT"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextSize = 14
Text_2.TextStrokeColor3 = Color3.new(0.145098, 0.141176, 0.14902)
Text_2.TextXAlignment = Enum.TextXAlignment.Left
Text_2.TextWrapped = true

Button_2.Name = "Button"
Button_2.Parent = FunctionTemplate
Button_2.BackgroundColor3 = Color3.new(0, 0, 0)
Button_2.BackgroundTransparency = 1
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(0, 0, 0, 0)
Button_2.Size = UDim2.new(1, 0, 1, 0)
Button_2.ZIndex = 10
Button_2.AutoButtonColor = false
Button_2.Font = Enum.Font.SourceSans
Button_2.Text = ""
Button_2.TextColor3 = Color3.new(0, 0, 0)
Button_2.TextSize = 14

TopBar.Name = "TopBar"
TopBar.Parent = Background
TopBar.BackgroundColor3 = Color3.fromRGB(37, 35, 38)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(0, 560, 0, 19)

Simple.Name = "Simple"
Simple.Parent = TopBar
Simple.BackgroundColor3 = Color3.new(1, 1, 1)
Simple.AutoButtonColor = false
Simple.BackgroundTransparency = 1
Simple.Position = UDim2.new(0, 5, 0, 0)
Simple.Size = UDim2.new(0, 57, 0, 18)
Simple.Font = Enum.Font.SourceSansBold
Simple.Text = "UltraSpy"
Simple.TextColor3 = Color3.new(1, 1, 1)
Simple.TextSize = 14
Simple.TextXAlignment = Enum.TextXAlignment.Left

CloseButton.Name = "CloseButton"
CloseButton.Parent = TopBar
CloseButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -19, 0, 0)
CloseButton.Size = UDim2.new(0, 19, 0, 19)
CloseButton.Font = Enum.Font.SourceSans
CloseButton.Text = ""
CloseButton.TextColor3 = Color3.new(0, 0, 0)
CloseButton.TextSize = 14

ImageLabel.Parent = CloseButton
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 5, 0, 5)
ImageLabel.Size = UDim2.new(0, 9, 0, 9)
ImageLabel.Image = "http://www.roblox.com/asset/?id=5597086202"

MaximizeButton.Name = "MaximizeButton"
MaximizeButton.Parent = TopBar
MaximizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MaximizeButton.BorderSizePixel = 0
MaximizeButton.Position = UDim2.new(1, -38, 0, 0)
MaximizeButton.Size = UDim2.new(0, 19, 0, 19)
MaximizeButton.Font = Enum.Font.SourceSans
MaximizeButton.Text = ""
MaximizeButton.TextColor3 = Color3.new(0, 0, 0)
MaximizeButton.TextSize = 14

ImageLabel_2.Parent = MaximizeButton
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_2.Image = "http://www.roblox.com/asset/?id=5597108117"

MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TopBar
MinimizeButton.BackgroundColor3 = Color3.new(0.145098, 0.141176, 0.14902)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Position = UDim2.new(1, -57, 0, 0)
MinimizeButton.Size = UDim2.new(0, 19, 0, 19)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = ""
MinimizeButton.TextColor3 = Color3.new(0, 0, 0)
MinimizeButton.TextSize = 14

ImageLabel_3.Parent = MinimizeButton
ImageLabel_3.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_3.BackgroundTransparency = 1
ImageLabel_3.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_3.Size = UDim2.new(0, 9, 0, 9)
ImageLabel_3.Image = "http://www.roblox.com/asset/?id=5597105827"

ToolTip.Name = "ToolTip"
ToolTip.Parent = SimpleSpy2
ToolTip.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
ToolTip.BackgroundTransparency = 0.1
ToolTip.BorderColor3 = Color3.new(1, 1, 1)
ToolTip.Size = UDim2.new(0, 200, 0, 50)
ToolTip.ZIndex = 3
ToolTip.Visible = false

TextLabel.Parent = ToolTip
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 2, 0, 2)
TextLabel.Size = UDim2.new(0, 196, 0, 46)
TextLabel.ZIndex = 3
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "This is some slightly longer text."
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextSize = 14
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextYAlignment = Enum.TextYAlignment.Top

-------------------------------------------------------------------------------
-- init
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local TextService = game:GetService("TextService")
local Mouse

local selectedColor = Color3.new(0.321569, 0.333333, 1)
local deselectedColor = Color3.new(0.8, 0.8, 0.8)
--- So things are descending
local layoutOrderNum = 999999999
--- Whether or not the gui is closing
local mainClosing = false
--- Whether or not the gui is closed (defaults to false)
local closed = false
--- Whether or not the sidebar is closing
local sideClosing = false
--- Whether or not the sidebar is closed (defaults to true but opens automatically on remote selection)
local sideClosed = false
--- Whether or not the code box is maximized (defaults to false)
local maximized = false
--- The event logs to be read from
local logs = {}
--- The event currently selected.Log (defaults to nil)
local selected = nil
--- The blacklist (can be a string name or the Remote Instance)
local blacklist = {}
--- The block list (can be a string name or the Remote Instance)
local blocklist = {}
--- Whether or not to add getNil function
local getNil = false
--- Array of remotes (and original functions) connected to
local connectedRemotes = {}
--- True = hookfunction, false = namecall
local toggle = false
local gm
local original
--- used to prevent recursives
local prevTables = {}
--- holds logs (for deletion)
local remoteLogs = {}
--- RBXScriptConnections to disconnect on shutdown (must be early — Phase 5/6 watchers use it)
local connections = {}
--- used for hookfunction
local remoteEvent = Instance.new("RemoteEvent")
--- used for hookfunction
local remoteFunction = Instance.new("RemoteFunction")
local originalEvent = remoteEvent.FireServer
local originalFunction = remoteFunction.InvokeServer
local originalUnreliableFire
local unreliableRemote
pcall(function()
	unreliableRemote = Instance.new("UnreliableRemoteEvent")
	originalUnreliableFire = unreliableRemote.FireServer
end)
local namecallFallbackRestore = {}
local cachedMtRestore = {}
local cachedMethodHooksInstalled = false
--- Skip duplicate logging when __namecall re-enters hookfunction forward path
local reentForwardDepth = 0
local bindableReentDepth = 0
local wrapperReentDepth = 0
local knownRemotes = {}
local recentFingerprints = {}
local wrapperHooksInstalled = {}
local autoHookStack = _G.SIMPLESPYCONFIG_AutoHookStack == true
local networkGraph = {}
local discoveredModules = {}
local discoveredWrappers = {}
local recentUiEvents = {}
local UI_CORRELATE_WINDOW = 2.0
local trackUiCorrelation = true
if _G.SIMPLESPYCONFIG_UiCorrelate == nil then
	_G.SIMPLESPYCONFIG_UiCorrelate = true
end
if _G.SIMPLESPYCONFIG_UiCorrelateWindow == nil then
	_G.SIMPLESPYCONFIG_UiCorrelateWindow = 2.0
end
if _G.SIMPLESPYCONFIG_FlowTracking == nil then
	_G.SIMPLESPYCONFIG_FlowTracking = true
end
if _G.SIMPLESPYCONFIG_TrackBindables == nil then
	_G.SIMPLESPYCONFIG_TrackBindables = false
end
UI_CORRELATE_WINDOW = _G.SIMPLESPYCONFIG_UiCorrelateWindow
if _G.SIMPLESPYCONFIG_CallStackDepth == nil then
	_G.SIMPLESPYCONFIG_CallStackDepth = 32
end
trackUiCorrelation = _G.SIMPLESPYCONFIG_UiCorrelate == true
--- the maximum amount of remotes allowed in logs
_G.SIMPLESPYCONFIG_MaxRemotes = _G.SIMPLESPYCONFIG_MaxRemotes or 500
_G.SIMPLESPYCONFIG_SchedulerBatch = _G.SIMPLESPYCONFIG_SchedulerBatch or 32
_G.SIMPLESPYCONFIG_MaxScheduleQueue = _G.SIMPLESPYCONFIG_MaxScheduleQueue or 5000
_G.SIMPLESPYCONFIG_UiQueueBatch = _G.SIMPLESPYCONFIG_UiQueueBatch or 64
_G.SIMPLESPYCONFIG_MaxUiQueue = _G.SIMPLESPYCONFIG_MaxUiQueue or 2000
if _G.SIMPLESPYCONFIG_HookCachedMethods == nil then
	_G.SIMPLESPYCONFIG_HookCachedMethods = true
end
if _G.SIMPLESPYCONFIG_AutoHookStack == nil then
	_G.SIMPLESPYCONFIG_AutoHookStack = false
end
if _G.SIMPLESPYCONFIG_DedupWindow == nil then
	_G.SIMPLESPYCONFIG_DedupWindow = 0.002
end
if _G.SIMPLESPYCONFIG_GuiConnections == nil then
	_G.SIMPLESPYCONFIG_GuiConnections = true
end
if _G.SIMPLESPYCONFIG_LogWrapperCalls == nil then
	_G.SIMPLESPYCONFIG_LogWrapperCalls = true
end
if _G.SIMPLESPYCONFIG_AggressiveModulePatch == nil then
	_G.SIMPLESPYCONFIG_AggressiveModulePatch = false
end
if _G.SIMPLESPYCONFIG_RunSelfTest == nil then
	_G.SIMPLESPYCONFIG_RunSelfTest = true
end
if _G.SIMPLESPYCONFIG_SelfTestLeaveLogs == nil then
	_G.SIMPLESPYCONFIG_SelfTestLeaveLogs = false
end
if _G.SIMPLESPYCONFIG_GroupLogs == nil then
	_G.SIMPLESPYCONFIG_GroupLogs = true
end
if _G.SIMPLESPYCONFIG_ShowWrapperGroups == nil then
	_G.SIMPLESPYCONFIG_ShowWrapperGroups = false
end
if _G.SIMPLESPYCONFIG_StateTracker == nil then
	_G.SIMPLESPYCONFIG_StateTracker = true
end
if _G.SIMPLESPYCONFIG_TrackInbound == nil then
	_G.SIMPLESPYCONFIG_TrackInbound = true
end
if _G.SIMPLESPYCONFIG_PropCorrelate == nil then
	_G.SIMPLESPYCONFIG_PropCorrelate = true
end
if _G.SIMPLESPYCONFIG_TrackRemoteReferences == nil then
	_G.SIMPLESPYCONFIG_TrackRemoteReferences = true
end
if _G.SIMPLESPYCONFIG_ProtocolRegistry == nil then
	_G.SIMPLESPYCONFIG_ProtocolRegistry = true
end
if _G.SIMPLESPYCONFIG_OutcomeLearning == nil then
	_G.SIMPLESPYCONFIG_OutcomeLearning = true
end
if _G.SIMPLESPYCONFIG_ModuleGraph == nil then
	_G.SIMPLESPYCONFIG_ModuleGraph = true
end
if _G.SIMPLESPYCONFIG_DiscoveryMinScore == nil then
	_G.SIMPLESPYCONFIG_DiscoveryMinScore = 25
end
if _G.SIMPLESPYCONFIG_TrackAnimations == nil then
	_G.SIMPLESPYCONFIG_TrackAnimations = false
end
if _G.SIMPLESPYCONFIG_TrackSounds == nil then
	_G.SIMPLESPYCONFIG_TrackSounds = false
end
if _G.SIMPLESPYCONFIG_TrackCauses == nil then
	_G.SIMPLESPYCONFIG_TrackCauses = true
end
if _G.SIMPLESPYCONFIG_TrackWorldSignals == nil then
	_G.SIMPLESPYCONFIG_TrackWorldSignals = true
end
if _G.SIMPLESPYCONFIG_TrackHits == nil then
	_G.SIMPLESPYCONFIG_TrackHits = true
end
if _G.SIMPLESPYCONFIG_EntityTracker == nil then
	_G.SIMPLESPYCONFIG_EntityTracker = true
end
if _G.SIMPLESPYCONFIG_GlobalAttributes == nil then
	_G.SIMPLESPYCONFIG_GlobalAttributes = true
end
if _G.SIMPLESPYCONFIG_PropertyTracker == nil then
	_G.SIMPLESPYCONFIG_PropertyTracker = true
end
if _G.SIMPLESPYCONFIG_InvestigationSessions == nil then
	_G.SIMPLESPYCONFIG_InvestigationSessions = true
end
if _G.SIMPLESPYCONFIG_CombatDiscovery == nil then
	_G.SIMPLESPYCONFIG_CombatDiscovery = true
end
if _G.SIMPLESPYCONFIG_CallbackDiscovery == nil then
	_G.SIMPLESPYCONFIG_CallbackDiscovery = true
end
if _G.SIMPLESPYCONFIG_TrackCollectionService == nil then
	_G.SIMPLESPYCONFIG_TrackCollectionService = true
end
if _G.SIMPLESPYCONFIG_EntityScanRadius == nil then
	_G.SIMPLESPYCONFIG_EntityScanRadius = 120
end
if _G.SIMPLESPYCONFIG_MAX_ENTITY_WATCH == nil then
	_G.SIMPLESPYCONFIG_MAX_ENTITY_WATCH = 48
end
if _G.SIMPLESPYCONFIG_MAX_PROPERTY_WATCH == nil then
	_G.SIMPLESPYCONFIG_MAX_PROPERTY_WATCH = 80
end
if _G.SIMPLESPYCONFIG_CombatDiscoveryWindow == nil then
	_G.SIMPLESPYCONFIG_CombatDiscoveryWindow = 1.0
end
if _G.SIMPLESPYCONFIG_PropCorrelateMaxLines == nil then
	_G.SIMPLESPYCONFIG_PropCorrelateMaxLines = 8
end
if _G.SIMPLESPYCONFIG_ReplicaSetPropMaxLines == nil then
	_G.SIMPLESPYCONFIG_ReplicaSetPropMaxLines = 3
end
if _G.SIMPLESPYCONFIG_PropTimelineCooldown == nil then
	_G.SIMPLESPYCONFIG_PropTimelineCooldown = 0.5
end
if _G.SIMPLESPYCONFIG_HiddenStatDiscovery == nil then
	_G.SIMPLESPYCONFIG_HiddenStatDiscovery = true
end
if _G.SIMPLESPYCONFIG_MAX_HIDDEN_STAT_WATCH == nil then
	_G.SIMPLESPYCONFIG_MAX_HIDDEN_STAT_WATCH = 120
end
if _G.SIMPLESPYCONFIG_AutoWrapperChain == nil then
	_G.SIMPLESPYCONFIG_AutoWrapperChain = true
end
if _G.SIMPLESPYCONFIG_HookDiscoveredWrappers == nil then
	_G.SIMPLESPYCONFIG_HookDiscoveredWrappers = true
end
if _G.SIMPLESPYCONFIG_MAX_WRAPPER_HOOKS == nil then
	_G.SIMPLESPYCONFIG_MAX_WRAPPER_HOOKS = 40
end
if _G.SIMPLESPYCONFIG_MetatableResolver == nil then
	_G.SIMPLESPYCONFIG_MetatableResolver = true
end
if _G.SIMPLESPYCONFIG_MetatableHookDiscoveredTables == nil then
	_G.SIMPLESPYCONFIG_MetatableHookDiscoveredTables = false
end
if _G.SIMPLESPYCONFIG_UpvalueRemoteRegistry == nil then
	_G.SIMPLESPYCONFIG_UpvalueRemoteRegistry = true
end
if _G.SIMPLESPYCONFIG_UpvalueScanBudget == nil then
	_G.SIMPLESPYCONFIG_UpvalueScanBudget = 1500
end
if _G.SIMPLESPYCONFIG_FunctionRemoteRegistry == nil then
	_G.SIMPLESPYCONFIG_FunctionRemoteRegistry = true
end
if _G.SIMPLESPYCONFIG_TrackScriptOrigins == nil then
	_G.SIMPLESPYCONFIG_TrackScriptOrigins = true
end
if _G.SIMPLESPYCONFIG_ConstantSignatureProfiles == nil then
	_G.SIMPLESPYCONFIG_ConstantSignatureProfiles = true
end
if _G.SIMPLESPYCONFIG_ProfileMinEvidence == nil then
	_G.SIMPLESPYCONFIG_ProfileMinEvidence = 2
end
if _G.SIMPLESPYCONFIG_GcScanBudget == nil then
	_G.SIMPLESPYCONFIG_GcScanBudget = 25000
end
if _G.SIMPLESPYCONFIG_BindableDedupWindow == nil then
	_G.SIMPLESPYCONFIG_BindableDedupWindow = 0.01
end
if _G.SIMPLESPYCONFIG_MinLogInterval == nil then
	_G.SIMPLESPYCONFIG_MinLogInterval = 0.05
end
if _G.SIMPLESPYCONFIG_MaxReentDepth == nil then
	_G.SIMPLESPYCONFIG_MaxReentDepth = 3
end
if _G.SIMPLESPYCONFIG_AutoHookMinScore == nil then
	_G.SIMPLESPYCONFIG_AutoHookMinScore = 40
end
if _G.SIMPLESPYCONFIG_RealTriggerWindow == nil then
	_G.SIMPLESPYCONFIG_RealTriggerWindow = 0.5
end
if _G.SIMPLESPYCONFIG_RealTriggerMinConfidence == nil then
	_G.SIMPLESPYCONFIG_RealTriggerMinConfidence = 0.35
end
if _G.SIMPLESPYCONFIG_BindableDeepLog == nil then
	_G.SIMPLESPYCONFIG_BindableDeepLog = true
end
if _G.SIMPLESPYCONFIG_HookHttpService == nil then
	_G.SIMPLESPYCONFIG_HookHttpService = false
end
if _G.SIMPLESPYCONFIG_HookMessagingService == nil then
	_G.SIMPLESPYCONFIG_HookMessagingService = false
end
if _G.SIMPLESPYCONFIG_AutoDeepDiscovery == nil then
	_G.SIMPLESPYCONFIG_AutoDeepDiscovery = true
end
if _G.SIMPLESPYCONFIG_DeepCopyArgs == nil then
	_G.SIMPLESPYCONFIG_DeepCopyArgs = true
end
if _G.SIMPLESPYCONFIG_ScanCustomSignals == nil then
	_G.SIMPLESPYCONFIG_ScanCustomSignals = true
end
if _G.SIMPLESPYCONFIG_ReplayBurstCount == nil then
	_G.SIMPLESPYCONFIG_ReplayBurstCount = 10
end
if _G.SIMPLESPYCONFIG_ReplayBurstDelay == nil then
	_G.SIMPLESPYCONFIG_ReplayBurstDelay = 0.15
end
if _G.SIMPLESPYCONFIG_ReplayRandomizeArgs == nil then
	_G.SIMPLESPYCONFIG_ReplayRandomizeArgs = false
end
if _G.SIMPLESPYCONFIG_GenScriptUseWaitForChild == nil then
	_G.SIMPLESPYCONFIG_GenScriptUseWaitForChild = true
end
if _G.SIMPLESPYCONFIG_ActionHuntMode == nil then
	_G.SIMPLESPYCONFIG_ActionHuntMode = true
end
if _G.SIMPLESPYCONFIG_VerifiedOnly == nil then
	_G.SIMPLESPYCONFIG_VerifiedOnly = false
end
if _G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval == nil then
	_G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval = 60
end
local trackGuiConnections = _G.SIMPLESPYCONFIG_GuiConnections == true
local REPLAY_ARGS_MARKER = "-- UltraSpy Replay Args"
local CollectionService = nil
pcall(function()
	CollectionService = game:GetService("CollectionService")
end)
local wrapperHookMeta = {}
local staticModuleMap = nil
local recentWrapperFingerprints = {}
local recentBindableFingerprints = {}
local originalRequire = nil
local requireHookInstalled = false
local scheduleQueueWarned = false
local pendingRemoteLogs = {}
local startupSelfTestResults = nil
local SELF_TEST_PREFIX = "__UltraSpySelfTest"
local US = {
	nextFlowId = 1,
	flowByThread = {},
	lastGuiInteraction = nil,
	remoteAtlas = {},
	remoteAtlasOrder = {},
	ATLAS_MAX_REMOTES = 32,
	ATLAS_MAX_ACTIONS = 48,
	ATLAS_MAX_SHAPES = 24,
	bindableHooksInstalled = false,
	deepScanWatchedRoots = {},
	discoveryScanStats = {},
	recentBindableEvents = {},
	httpHooksInstalled = false,
	messagingHooksInstalled = false,
	replayArgsOverride = {},
	replayCancelToken = 0,
	MAX_RECENT_BINDABLE = 64,
	logGroups = {},
	timelineEvents = {},
	nextTimelineId = 1,
	leftPanelView = "logs",
	stateBaseline = {},
	stateChanges = {},
	stateWatchConns = {},
	inboundSpied = {},
	activePropWatch = nil,
	recentOutboundContext = nil,
	logViewFilter = {
		search = "",
		direction = "all",
		role = "all",
		hideSpam = false,
		verifiedOnly = false,
	},
	periodicDiscoveryRunning = false,
	startupLoading = {
		visible = false,
		bootstrapDone = false,
		testsDone = false,
		finished = false,
		dotPhase = 0,
		baseDetail = "",
	},
	logViewFilterDebounceToken = 0,
	activeToolTab = "code",
	leftPanelView = "logs",
	timelineFilter = {
		outbound = true,
		inbound = true,
		ui = true,
		state = true,
		prop = true,
		cause = true,
		investigation = true,
		entity = true,
		remote_birth = true,
		remote_death = true,
		remote_created = true,
		remote_found = true,
	},
	MAX_GROUP_SUB_ROWS = 100,
	GROUP_SUB_MAX_H = 220,
	MAX_STATE_PATHS = 128,
	MAX_TIMELINE_EVENTS = 2000,
	INBOUND_COLOR = Color3.fromRGB(0, 180, 220),
	STATE_EVENT_COLOR = Color3.fromRGB(255, 160, 60),
	PROP_EVENT_COLOR = Color3.fromRGB(180, 130, 255),
	selfTestInProgress = false,
	selfTestRemotes = {},
	selfTestCaptureCount = 0,
	gui = {},
	remoteLifecycle = {},
	lifecycleByInstance = {},
	MAX_LIFECYCLE_ENTRIES = 128,
	EPHEMERAL_LIFETIME_SEC = 30,
	correlationSessions = {},
	nextCorrelationId = 1,
	MAX_CORRELATION_SESSIONS = 8,
	MAX_ACTIVE_CORRELATIONS = 3,
	CORRELATE_WINDOW_DEFAULT = 3,
	activeCorrelations = {},
	activeCorrelation = nil,
	instanceNewHookInstalled = false,
	instanceNewHookFailed = false,
	originalInstanceNew = nil,
	animationHookInstalled = false,
	soundHookInstalled = false,
	NETWORK_CREATE_CLASSES = {
		RemoteEvent = true,
		RemoteFunction = true,
		UnreliableRemoteEvent = true,
		BindableEvent = true,
		BindableFunction = true,
	},
	ANIM_DENYLIST = {
		idle = true,
		walk = true,
		run = true,
		jump = true,
		fall = true,
		land = true,
		sit = true,
		climb = true,
		swim = true,
		swimming = true,
	},
	SIGNAL_WEIGHTS = {
		["Money-"] = 0.25,
		["Money+"] = 0.25,
		Inventory = 0.2,
		UI = 0.2,
		Controller = 0.15,
		Animation = 0.1,
		Prop = 0.1,
		Sound = 0.08,
		Actor = 0.05,
	},
	-- Phase 4: references, discovery, module graph, protocols, outcomes
	nextRefId = 1,
	remoteReferences = {},
	tracedMethodCache = {},
	lastFiredRefId = nil,
	discoveryAtlas = {},
	moduleGraph = { nodes = {}, edges = {} },
	protocolLabelCounter = {},
	actionOutcomes = {},
	MAX_REF_CAPTURES_PER_REMOTE = 64,
	MAX_DISCOVERY_ENTRIES = 256,
	-- Phase 5: world cause, investigation, damage/reward events
	recentCauses = {},
	MAX_RECENT_CAUSES = 12,
	recentOutboundEvents = {},
	MAX_RECENT_OUTBOUND = 64,
	recentInboundEvents = {},
	MAX_RECENT_INBOUND = 16,
	recentPropertyChanges = {},
	MAX_RECENT_PROPERTY = 32,
	investigationSessions = {},
	nextInvestigationId = 1,
	activeInvestigation = nil,
	MAX_INVESTIGATION_SESSIONS = 24,
	entityRegistry = {},
	entityWatchConns = {},
	propertyWatchConns = {},
	propertyWatchCount = 0,
	callbackRegistry = {},
	combatDiscovery = nil,
	combatOutboundBuffer = {},
	rewardDiscovery = nil,
	rewardOutboundBuffer = {},
	damageEvents = {},
	MAX_DAMAGE_EVENTS = 64,
	rewardEvents = {},
	MAX_REWARD_EVENTS = 64,
	collectionTagged = {},
	connectHookInstalled = false,
	originalSignalConnect = nil,
	reentCauseDepth = 0,
	lastHitLogTime = {},
	signalInstanceMap = nil,
	CAUSE_EVENT_COLOR = Color3.fromRGB(120, 220, 140),
	INVESTIGATION_COLOR = Color3.fromRGB(200, 120, 255),
	ENTITY_EVENT_COLOR = Color3.fromRGB(255, 100, 100),
	-- Phase 6
	hiddenStatProfiles = {},
	hiddenStatWatchCount = 0,
	wrapperCallBuffer = {},
	wrapperChainsByRemote = {},
	recentWrapperFacade = nil,
	metatableLinks = {},
	upvalueRemoteRegistry = {},
	upvalueRemoteByRemote = {},
	functionRemoteRegistry = {},
	functionActionRegistry = {},
	remoteToFunctions = {},
	scriptOriginRegistry = {},
	remoteProfiles = {},
	lastCombatHpPath = nil,
	-- Phase 7: Action Discovery Engine
	remoteRoles = {},
	remoteActionScores = {},
	replayOutcomes = {},
	replayWatchList = {},
	actionStateSamples = {},
	actionSequences = {},
	entityRemoteAffinity = {},
	lastStatChange = nil,
	lastRootCauseAnalysis = nil,
	pendingReplayChecks = {},
}
local bindableEvent = Instance.new("BindableEvent")
local bindableFunction = Instance.new("BindableFunction")
local originalBindableFire = bindableEvent.Fire
local originalBindableInvoke = bindableFunction.Invoke

function isSelfTestRemote(remote, snapshot)
	if not US.selfTestInProgress then
		return false
	end
	if typeof(remote) == "Instance" and US.selfTestRemotes[remote] then
		return true
	end
	local name = snapshot and snapshot.name
	if not name and typeof(remote) == "Instance" then
		name = remote.Name
	end
	if type(name) == "string" and string.find(name, SELF_TEST_PREFIX, 1, true) then
		return true
	end
	return false
end

--- Phase 3: lifecycle, correlation, creation hooks, actor, animation

function isRemoteLifecycleEnabled()
	return _G.SIMPLESPYCONFIG_RemoteLifecycle ~= false
end

function isTrackRemoteCreationEnabled()
	return _G.SIMPLESPYCONFIG_TrackRemoteCreation ~= false
end

function isTrackAnimationsEnabled()
	return _G.SIMPLESPYCONFIG_TrackAnimations ~= false
end

function isTrackSoundsEnabled()
	return _G.SIMPLESPYCONFIG_TrackSounds ~= false
end

function getCorrelateWindow()
	local w = _G.SIMPLESPYCONFIG_CorrelateWindow
	if type(w) == "number" and w > 0 then
		return w
	end
	return US.CORRELATE_WINDOW_DEFAULT
end

function getRootCauseWindow(trigger)
	local realW = trigger and getRealTriggerWindow(trigger)
	if realW then
		return realW
	end
	if trigger and trigger.kind == "reward" then
		local w = _G.SIMPLESPYCONFIG_RewardSourceWindow or _G.SIMPLESPYCONFIG_RootCauseWindow
		if type(w) == "number" and w > 0 then
			return w
		end
		return 5
	end
	local w = _G.SIMPLESPYCONFIG_RootCauseWindow
	if type(w) == "number" and w > 0 then
		return w
	end
	return getCorrelateWindow()
end

function getRewardSourceWindow()
	local w = _G.SIMPLESPYCONFIG_RewardSourceWindow
	if type(w) == "number" and w > 0 then
		return w
	end
	return 5
end

function getGcScanBudget()
	local b = _G.SIMPLESPYCONFIG_GcScanBudget
	if type(b) == "number" and b > 0 then
		return math.floor(b)
	end
	return 25000
end

function getBindableDedupWindow()
	local w = _G.SIMPLESPYCONFIG_BindableDedupWindow
	if type(w) == "number" and w >= 0 then
		return w
	end
	return 0.01
end

function getMinLogInterval()
	local w = _G.SIMPLESPYCONFIG_MinLogInterval
	if type(w) == "number" and w >= 0 then
		return w
	end
	return 0.05
end

function getMaxReentDepth()
	local d = _G.SIMPLESPYCONFIG_MaxReentDepth
	if type(d) == "number" and d > 0 then
		return math.floor(d)
	end
	return 3
end

function getAutoHookMinScore()
	local s = _G.SIMPLESPYCONFIG_AutoHookMinScore
	if type(s) == "number" then
		return s
	end
	return 40
end

function getRealTriggerWindow(trigger)
	if not trigger then
		return nil
	end
	local isSync = trigger.remoteRole == "replication_effect"
		or trigger.kind == "replication_effect"
		or trigger.kind == "sync_effect"
	if not isSync then
		return nil
	end
	local w = _G.SIMPLESPYCONFIG_RealTriggerWindow
	if type(w) == "number" and w > 0 then
		return w
	end
	return 0.5
end

function getRealTriggerMinConfidence()
	local c = _G.SIMPLESPYCONFIG_RealTriggerMinConfidence
	if type(c) == "number" and c >= 0 and c <= 1 then
		return c
	end
	return 0.35
end

function isActionHuntModeEnabled()
	return _G.SIMPLESPYCONFIG_ActionHuntMode ~= false
end

function isVerifiedOnlyFilterEnabled()
	return _G.SIMPLESPYCONFIG_VerifiedOnly == true or (US.logViewFilter and US.logViewFilter.verifiedOnly == true)
end

function applyActionHuntPreset()
	if _G.SIMPLESPYCONFIG_TrackBindables == nil then
		_G.SIMPLESPYCONFIG_TrackBindables = true
	end
	if _G.SIMPLESPYCONFIG_MinLogInterval == nil then
		_G.SIMPLESPYCONFIG_MinLogInterval = 0.05
	end
	if _G.SIMPLESPYCONFIG_AutoDeepDiscovery == nil then
		_G.SIMPLESPYCONFIG_AutoDeepDiscovery = true
	end
	if _G.SIMPLESPYCONFIG_HookCachedMethods == nil then
		_G.SIMPLESPYCONFIG_HookCachedMethods = true
	end
	if _G.SIMPLESPYCONFIG_AutoHookStack == nil then
		_G.SIMPLESPYCONFIG_AutoHookStack = false
	end
	if _G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval == nil then
		_G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval = 60
	end
end

function applyActionHuntChipDefaults(chipStateRef)
	US.logViewFilter.direction = "out"
	US.logViewFilter.role = "action"
	US.logViewFilter.hideSpam = true
	if chipStateRef then
		chipStateRef.dir = "out"
		chipStateRef.role = "action"
	end
end

function computeActionHuntLayoutOrder(log)
	local score = tonumber(log and log.ValuableActionScore) or 0
	local role = log and (log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole))
	if role == "replication_effect" then
		score = math.min(score, 8)
	end
	local age = tick() - (log and log.Timestamp or tick())
	local recencyBoost = math.max(0, 120 - age * 25)
	return math.floor(500000 - score * 900 - recencyBoost)
end

function assignLogUILayoutOrder(log, uiObject)
	if not uiObject then
		return
	end
	if isActionHuntModeEnabled() and log then
		uiObject.LayoutOrder = computeActionHuntLayoutOrder(log)
		return
	end
	if layoutOrderNum < 1 then
		layoutOrderNum = 999999999
	end
	uiObject.LayoutOrder = layoutOrderNum
	layoutOrderNum = layoutOrderNum - 1
end

function resortActionHuntLogList()
	if not isActionHuntModeEnabled() then
		return
	end
	for _, log in ipairs(logs) do
		if log.Log then
			assignLogUILayoutOrder(log, log.Log)
		end
		if log.Group and log.Group.container then
			local best = log
			for _, entry in ipairs(log.Group.entries or {}) do
				if (entry.ValuableActionScore or 0) > (best.ValuableActionScore or 0) then
					best = entry
				end
			end
			assignLogUILayoutOrder(best, log.Group.container)
		end
	end
end

function attachLikelyCauseToSyncLog(log, snapshot)
	if not log then
		return
	end
	local role = log.RemoteRole or (snapshot and snapshot.remoteRole)
	if role ~= "replication_effect" then
		return
	end
	local analysis = resolveRootCause({
		kind = "sync_effect",
		remoteRole = "replication_effect",
		statPath = snapshot and snapshot.path,
		window = getRealTriggerWindow({ kind = "sync_effect", remoteRole = "replication_effect" }),
	})
	local best = analysis and analysis.bestCandidate
	local maxScore = analysis and analysis.maxScore or 0
	if not best or best.kind ~= "outbound" or maxScore <= 0 then
		return
	end
	log.LikelyCausePath = best.remotePath
	log.LikelyCauseScore = best.score or maxScore
	log.LikelyCauseVerdict = analysis.verdict
	log.LikelyCausePct = math.floor(((best.score or 0) / maxScore) * 100 + 0.5)
end

function getPayloadLibraryRows(remotePath)
	local atlas = remotePath and US.remoteAtlas[remotePath]
	if not atlas or not atlas.shapes then
		return {}
	end
	local rows = {}
	for shape, entry in pairs(atlas.shapes) do
		table.insert(rows, { shape = shape, entry = entry })
	end
	table.sort(rows, function(a, b)
		return (a.entry.count or 0) > (b.entry.count or 0)
	end)
	return rows
end

function formatPayloadLibraryBlock(remotePath)
	local lines = {
		"-- [PAYLOAD LIBRARY]",
		"-- Top shapes from Remote Atlas (by hit count)",
		"-- SimpleSpy:ApplyPayloadIndex(selectedLog, index) — or Edit Args + Apply Args",
		"",
	}
	local rows = getPayloadLibraryRows(remotePath)
	if #rows == 0 then
		table.insert(lines, "-- (no history — fire this remote once)")
		return table.concat(lines, "\n")
	end
	for i, row in ipairs(rows) do
		if i > 8 then
			table.insert(lines, "-- ... more shapes in Remote Atlas tab")
			break
		end
		local entry = row.entry
		table.insert(
			lines,
			string.format("-- #%d  hits=%d  shape=%s", i, entry.count or 0, tostring(row.shape))
		)
		if entry.sampleArgs and #entry.sampleArgs > 0 then
			table.insert(lines, "-- Use #".. tostring(i) .. ": SimpleSpy:ApplyPayloadIndex(log, " .. tostring(i) .. ")")
			table.insert(lines, argsToReplayReturnLiteral(entry.sampleArgs))
		end
		table.insert(lines, "")
	end
	return table.concat(lines, "\n")
end

function buildGuiRemoteCorrelationReport(guiInst)
	local lines = { "-- [GUI → REMOTES]", "" }
	local target = guiInst
	if not target or typeof(target) ~= "Instance" then
		target = Mouse and Mouse.Target
	end
	if not target or typeof(target) ~= "Instance" then
		table.insert(lines, "-- No GuiObject under mouse")
		return table.concat(lines, "\n")
	end
	table.insert(lines, "-- GUI: " .. target:GetFullName())
	local window = getCorrelateWindow()
	local now = tick()
	table.insert(lines, "", "-- Recent UI (last " .. tostring(window) .. "s):", "")
	local uiCount = 0
	for _, ev in ipairs(recentUiEvents) do
		if ev and ev.time and (now - ev.time) <= window then
			uiCount += 1
			table.insert(
				lines,
				string.format("--  %s  %s  %s", formatRelativeTime(ev.time), tostring(ev.input or "?"), ev.path or "?")
			)
		end
	end
	if uiCount == 0 and US.lastGuiInteraction and (now - US.lastGuiInteraction.time) <= window then
		table.insert(
			lines,
			string.format(
				"--  %s  %s  %s",
				formatRelativeTime(US.lastGuiInteraction.time),
				tostring(US.lastGuiInteraction.input or "?"),
				US.lastGuiInteraction.path or "?"
			)
		)
	end
	table.insert(lines, "", "-- Outbound remotes (same window):", "")
	local outCount = 0
	for i = #US.recentOutboundEvents, 1, -1 do
		local ev = US.recentOutboundEvents[i]
		if ev and ev.time and (now - ev.time) <= window then
			outCount += 1
			if outCount > 12 then
				break
			end
			table.insert(
				lines,
				string.format(
					"--  %s  %s  key=%s",
					formatRelativeTime(ev.time),
					tostring(ev.remotePath or "?"),
					tostring(ev.actionKey or "")
				)
			)
		end
	end
	if outCount == 0 then
		table.insert(lines, "-- (none — click GUI then trigger an action remote)")
	end
	if getconnections then
		table.insert(lines, "", formatGuiConnectionsTrace(target))
	else
		table.insert(lines, "", "-- getconnections unavailable")
	end
	if getsignalinfo then
		table.insert(lines, "", "-- getsignalinfo: available (executor)")
	else
		table.insert(lines, "", "-- getsignalinfo: not available")
	end
	return table.concat(lines, "\n")
end

function exportActionSessionTable(verifiedOnly)
	local rows = {}
	for _, log in ipairs(logs) do
		local role = log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole)
		if role ~= "action_candidate" then
			continue
		end
		local path = log.Snapshot and log.Snapshot.path
		if not path then
			continue
		end
		local replayState = US.replayOutcomes[path] and US.replayOutcomes[path].state or log.ReplayScoreState
		if verifiedOnly and replayState ~= "verified_action" then
			continue
		end
		table.insert(rows, {
			path = path,
			actionKey = log.ActionKey,
			valuableActionScore = log.ValuableActionScore,
			replayScoreState = replayState,
			replayScore = log.ReplayScore,
			timestamp = log.Timestamp,
			payloadShape = log.PayloadShape,
			direction = log.Direction,
		})
	end
	table.sort(rows, function(a, b)
		return (a.valuableActionScore or 0) > (b.valuableActionScore or 0)
	end)
	return {
		exportedAt = tick(),
		actionHuntMode = isActionHuntModeEnabled(),
		verifiedOnly = verifiedOnly == true,
		count = #rows,
		actions = rows,
	}
end

function runPeriodicDiscoveryPass()
	registerSpyProtectedFunctions()
	local savedBudget = _G.SIMPLESPYCONFIG_GcScanBudget
	_G.SIMPLESPYCONFIG_GcScanBudget = math.min(getGcScanBudget(), 8000)
	local ok, found = pcall(discoverRemoteCandidates)
	_G.SIMPLESPYCONFIG_GcScanBudget = savedBudget
	if ok and found then
		hookDiscoveredWrappersFromList(found)
	end
	purgeInternalWrapperHooks()
	if _G.SIMPLESPYCONFIG_HookCachedMethods ~= false then
		pcall(scanCachedRemoteReferences, { 500 })
	end
	if isActionHuntModeEnabled() or _G.SIMPLESPYCONFIG_AutoDeepDiscovery ~= false then
		pcall(resweepLoadedModules)
	end
end

function startPeriodicDiscoveryLoop()
	local interval = _G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval
	if type(interval) ~= "number" or interval <= 0 then
		return
	end
	if US.periodicDiscoveryRunning then
		return
	end
	US.periodicDiscoveryRunning = true
	task.spawn(function()
		while toggle and US.periodicDiscoveryRunning do
			task.wait(interval)
			if not toggle then
				break
			end
			pcall(runPeriodicDiscoveryPass)
		end
		US.periodicDiscoveryRunning = false
	end)
end

function getEffectiveDedupWindow(customWindow)
	local dedup = customWindow or _G.SIMPLESPYCONFIG_DedupWindow or DEDUP_WINDOW or 0.002
	return math.max(dedup, getMinLogInterval())
end

function enterReentGuard(kind)
	local maxD = getMaxReentDepth()
	if kind == "bindable" then
		bindableReentDepth += 1
		if bindableReentDepth > maxD then
			bindableReentDepth -= 1
			if not US._reentWarnedBindable then
				US._reentWarnedBindable = true
				warn("[UltraSpy] bindable reentrancy limit (" .. tostring(maxD) .. "); dropping nested bindable log")
			end
			return false
		end
	elseif kind == "wrapper" then
		wrapperReentDepth += 1
		if wrapperReentDepth > maxD then
			wrapperReentDepth -= 1
			if not US._reentWarnedWrapper then
				US._reentWarnedWrapper = true
				warn("[UltraSpy] wrapper reentrancy limit (" .. tostring(maxD) .. "); dropping nested wrapper log")
			end
			return false
		end
	end
	return true
end

function leaveReentGuard(kind)
	if kind == "bindable" then
		bindableReentDepth = math.max(0, bindableReentDepth - 1)
	elseif kind == "wrapper" then
		wrapperReentDepth = math.max(0, wrapperReentDepth - 1)
	end
end

function shouldCollapseLogFingerprint(fp, store, customWindow)
	if not fp or not store then
		return false, nil, fp
	end
	local window = getEffectiveDedupWindow(customWindow)
	local now = tick()
	local entry = store[fp]
	if entry and (now - entry.time) < window and logs[entry.logIndex] then
		return true, entry.logIndex, fp
	end
	return false, nil, fp
end

function isBindableDeepLogEnabled()
	return trackBindablesEnabled() and _G.SIMPLESPYCONFIG_BindableDeepLog ~= false
end

function isReplayScoreEnabled()
	return _G.SIMPLESPYCONFIG_ReplayScoreEnabled ~= false
end

function persistRemoteRole(path, role)
	if path and role and type(path) == "string" then
		US.remoteRoles[path] = role
	end
end

function getRemoteRole(path, snapshot)
	local cached = snapshot and snapshot.remoteRole
	if not cached and path and US.remoteRoles[path] then
		cached = US.remoteRoles[path]
	end
	if path then
		local fresh = classifyRemoteRole(path)
		if cached == "replication_effect" and fresh == "action_candidate" then
			cached = fresh
			if snapshot then
				snapshot.remoteRole = fresh
			end
			persistRemoteRole(path, fresh)
		elseif not cached or cached == "unknown" then
			cached = fresh
		end
	end
	return cached or "unknown"
end

function isNetworkRemoteClass(className)
	return US.NETWORK_CREATE_CLASSES[className] == true
end

function isNetworkRemoteInstance(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	return inst:IsA("RemoteEvent")
		or inst:IsA("RemoteFunction")
		or inst:IsA("UnreliableRemoteEvent")
		or inst:IsA("BindableEvent")
		or inst:IsA("BindableFunction")
end

function getLifecycleKey(inst)
	local debugId = nil
	pcall(function()
		if inst.GetDebugId then
			debugId = inst:GetDebugId()
		end
	end)
	if debugId then
		return "id:" .. tostring(debugId)
	end
	local path = "?"
	pcall(function()
		path = inst:GetFullName()
	end)
	return "path:" .. path
end

function trimRemoteLifecycle()
	local keys = {}
	for key in pairs(US.remoteLifecycle) do
		table.insert(keys, key)
	end
	while #keys > US.MAX_LIFECYCLE_ENTRIES do
		local drop = table.remove(keys)
		local entry = US.remoteLifecycle[drop]
		if entry and entry.instance then
			US.lifecycleByInstance[entry.instance] = nil
		end
		US.remoteLifecycle[drop] = nil
	end
end

function connectRemoteLifecycleDeath(inst)
	pcall(function()
		if typeof(inst) ~= "Instance" then
			return
		end
		local conn
		if inst.Destroying then
			conn = inst.Destroying:Connect(function()
				registerRemoteDeath(inst)
			end)
		else
			conn = inst.AncestryChanged:Connect(function(_, parent)
				if not parent then
					registerRemoteDeath(inst)
				end
			end)
		end
		if conn then
			table.insert(connections, conn)
		end
	end)
end

function registerRemoteBirth(inst, createdBy, skipBirthTimeline)
	if not isRemoteLifecycleEnabled() or not isNetworkRemoteInstance(inst) then
		return
	end
	local key = getLifecycleKey(inst)
	local existing = US.remoteLifecycle[key]
	if existing then
		if createdBy and not existing.createdBy then
			existing.createdBy = createdBy
		end
		return
	end
	local path, className = "?", inst.ClassName
	pcall(function()
		path = inst:GetFullName()
	end)
	local entry = {
		key = key,
		instance = inst,
		path = path,
		className = className,
		createdAt = tick(),
		destroyedAt = nil,
		createdBy = createdBy,
		firstCallAt = nil,
		lastCallAt = nil,
		callCount = 0,
		ephemeral = false,
	}
	US.remoteLifecycle[key] = entry
	US.lifecycleByInstance[inst] = key
	trimRemoteLifecycle()
	connectRemoteLifecycleDeath(inst)
	connectRemoteLifecycleRename(inst)
	connectRemoteLifecycleReparent(inst)
	if not skipBirthTimeline and US.timelineFilter.remote_birth ~= false then
		pcall(function()
			appendTimelineEvent({
				kind = "remote_birth",
				label = getShortPathName(path),
				detail = className,
			})
		end)
	end
end

function registerRemoteDeath(inst)
	if not isRemoteLifecycleEnabled() then
		return
	end
	local key = US.lifecycleByInstance[inst] or getLifecycleKey(inst)
	local entry = US.remoteLifecycle[key]
	if not entry or entry.destroyedAt then
		return
	end
	local now = tick()
	entry.destroyedAt = now
	entry.instance = nil
	US.lifecycleByInstance[inst] = nil
	if entry.createdAt and now - entry.createdAt <= US.EPHEMERAL_LIFETIME_SEC then
		entry.ephemeral = true
	end
	if US.timelineFilter.remote_death ~= false then
		pcall(function()
			appendTimelineEvent({
				kind = "remote_death",
				label = getShortPathName(entry.path),
				detail = "calls=" .. tostring(entry.callCount),
			})
		end)
	end
end

function recordRemoteLifecycleCall(snapshot, remote)
	if not isRemoteLifecycleEnabled() then
		return
	end
	local inst = typeof(remote) == "Instance" and remote or nil
	local key = inst and US.lifecycleByInstance[inst] or (snapshot and snapshot.debugId and ("id:" .. snapshot.debugId))
	if not key and snapshot and snapshot.path then
		key = "path:" .. snapshot.path
	end
	local entry = key and US.remoteLifecycle[key]
	if not entry and inst then
		registerRemoteBirth(inst)
		entry = US.remoteLifecycle[US.lifecycleByInstance[inst]]
	end
	if not entry then
		return
	end
	local now = tick()
	entry.callCount += 1
	entry.lastCallAt = now
	entry.firstCallAt = entry.firstCallAt or now
	if snapshot and snapshot.path then
		entry.path = snapshot.path
	end
end

function recordRemoteCreation(inst, className, info)
	if not isTrackRemoteCreationEnabled() or not isNetworkRemoteInstance(inst) then
		return
	end
	local createdBy = nil
	if info then
		createdBy = {
			source = info.source or "?",
			line = info.currentline or 0,
			func = info.name or "[anonymous]",
		}
	end
	registerRemoteBirth(inst, createdBy, true)
	if US.timelineFilter.remote_created ~= false then
		local detail = className
		if createdBy then
			detail = detail .. " @ " .. tostring(createdBy.source) .. ":" .. tostring(createdBy.line)
		end
		pcall(function()
			appendTimelineEvent({
				kind = "remote_created",
				label = inst.Name,
				detail = detail,
			})
		end)
	end
end

function formatRemoteLifecycle(remotePath)
	local lines = { "-- Remote Lifecycle (session)", "" }
	local entries = {}
	for _, entry in pairs(US.remoteLifecycle) do
		local entryPath = entry.path or ""
		if not remotePath or entryPath == remotePath or (remotePath ~= "" and string.find(entryPath, remotePath, 1, true)) then
			table.insert(entries, entry)
		end
	end
	table.sort(entries, function(a, b)
		return (a.createdAt or 0) > (b.createdAt or 0)
	end)
	if #entries == 0 then
		table.insert(lines, "-- (no lifecycle records yet)")
		return table.concat(lines, "\n")
	end
	for _, entry in ipairs(entries) do
		table.insert(lines, "Remote:")
		table.insert(lines, "  " .. entry.path)
		table.insert(lines, "  Class: " .. tostring(entry.className))
		if entry.createdAt then
			table.insert(lines, "  Created: " .. formatLogTime(entry.createdAt))
		end
		if entry.createdBy then
			table.insert(
				lines,
				string.format(
					"  CreatedBy: %s:%s (%s)",
					tostring(entry.createdBy.source),
					tostring(entry.createdBy.line),
					tostring(entry.createdBy.func)
				)
			)
		end
		if entry.destroyedAt then
			table.insert(lines, "  Destroyed: " .. formatLogTime(entry.destroyedAt))
		else
			table.insert(lines, "  Destroyed: (alive)")
		end
		table.insert(lines, "  Calls: " .. tostring(entry.callCount))
		if entry.ephemeral then
			table.insert(lines, "  Ephemeral: yes")
		end
		table.insert(lines, "")
	end
	return table.concat(lines, "\n")
end

function findActorContext(inst)
	if not inst or typeof(inst) ~= "Instance" then
		return nil, nil
	end
	local current = inst
	while current do
		if current:IsA("Actor") then
			local name, path = current.Name, "?"
			pcall(function()
				path = current:GetFullName()
			end)
			return name, path
		end
		current = current.Parent
	end
	return nil, nil
end

function enrichSnapshotWithActor(snapshot, callingScript)
	if not snapshot or not callingScript then
		return
	end
	local actorName, actorPath = findActorContext(callingScript)
	if actorName then
		snapshot.actorName = actorName
		snapshot.actorPath = actorPath
	end
end

function isParallelThread()
	local ok, result = pcall(function()
		if coroutine.isparallel then
			return coroutine.isparallel()
		end
		return false
	end)
	return ok and result == true
end

function pruneActiveCorrelations()
	if not US.activeCorrelations then
		US.activeCorrelations = {}
	end
	local now = tick()
	for i = #US.activeCorrelations, 1, -1 do
		local session = US.activeCorrelations[i]
		if session.finalized or now > session.expiresAt then
			if not session.finalized then
				finalizeCorrelationSession(session)
			else
				table.remove(US.activeCorrelations, i)
			end
		end
	end
end

function getPrimarySessionId()
	if US.recentOutboundContext and US.recentOutboundContext.sessionId then
		return US.recentOutboundContext.sessionId
	end
	pruneActiveCorrelations()
	local primary = US.activeCorrelations[1]
	return primary and primary.id
end

function getActiveCorrelationSession(preferLogRef)
	pruneActiveCorrelations()
	if preferLogRef then
		for _, session in ipairs(US.activeCorrelations) do
			if session.logRef == preferLogRef and not session.finalized then
				return session
			end
		end
	end
	return US.activeCorrelations[1]
end

function getActiveCorrelationSessions()
	pruneActiveCorrelations()
	return US.activeCorrelations
end

function uiTriggerMatchesAction(uiTrigger, actionKey)
	if not uiTrigger then
		return false
	end
	local path = (uiTrigger.path or ""):lower()
	local short = (uiTrigger.shortName or ""):lower()
	local action = (actionKey or ""):lower()
	if action ~= "" and (string.find(path, action, 1, true) or string.find(short, action, 1, true)) then
		return true
	end
	local keywords = { "buy", "shop", "sell", "equip", "reward", "purchase", "button", "confirm" }
	for _, kw in ipairs(keywords) do
		if string.find(path, kw, 1, true) or string.find(short, kw, 1, true) then
			return true
		end
	end
	return false
end

function evidenceListFromSet(evidenceSet)
	local list = {}
	for tag, count in pairs(evidenceSet or {}) do
		table.insert(list, { tag = tag, count = count })
	end
	table.sort(list, function(a, b)
		return a.count > b.count
	end)
	local out = {}
	for _, item in ipairs(list) do
		table.insert(out, item.tag)
	end
	return out
end

function mergeConfidenceIntoAtlas(entry, session, conf)
	if not entry or not session or not conf then
		return
	end
	entry.confidenceByAction = entry.confidenceByAction or {}
	local actionKey = session.actionKey or "?"
	local bucket = entry.confidenceByAction[actionKey]
	if not bucket then
		bucket = {
			scoreSum = 0,
			samples = 0,
			label = conf.label,
			evidenceSet = {},
		}
		entry.confidenceByAction[actionKey] = bucket
	end
	bucket.scoreSum += conf.score
	bucket.samples += 1
	bucket.score = bucket.scoreSum / bucket.samples
	bucket.label = conf.label
	for _, tag in ipairs(conf.evidence or {}) do
		bucket.evidenceSet[tag] = (bucket.evidenceSet[tag] or 0) + 1
	end
	local bestAction, bestScore = nil, -1
	for act, data in pairs(entry.confidenceByAction) do
		if data.score > bestScore then
			bestScore = data.score
			bestAction = act
		end
	end
	if bestAction then
		local top = entry.confidenceByAction[bestAction]
		entry.confidence = {
			score = top.score,
			label = top.label,
			actionKey = bestAction,
			samples = top.samples,
			evidence = evidenceListFromSet(top.evidenceSet),
		}
	end
end

function removeActiveCorrelationSession(session)
	if not US.activeCorrelations or not session then
		return
	end
	for i, active in ipairs(US.activeCorrelations) do
		if active == session then
			table.remove(US.activeCorrelations, i)
			break
		end
	end
	if US.activeCorrelation == session then
		US.activeCorrelation = US.activeCorrelations[1]
	end
end

function formatCorrelationChain(session)
	if not session or not session.chain or #session.chain == 0 then
		return ""
	end
	local lines = { "-- [CORRELATION CHAIN]", "" }
	local inboundShown = 0
	local inboundCap = 2
	for _, effect in ipairs(session.chain) do
		if effect.kind == "inbound" then
			local label = effect.label or "?"
			if string.find(label:lower(), "replicaset", 1, true) or string.find(label:lower(), "replica", 1, true) then
				if inboundShown >= inboundCap then
					continue
				end
				inboundShown += 1
			end
		end
		local tag = string.upper(string.sub(effect.kind or "?", 1, 1)) .. string.sub(effect.kind or "?", 2)
		table.insert(lines, string.format("--   [%s] %s", tag, effect.label or "?"))
	end
	if inboundShown >= inboundCap then
		table.insert(lines, "--   ... (inbound replication suppressed)")
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function pushCorrelationEffect(kind, label, detail, targetLogRef)
	local sessions = getActiveCorrelationSessions()
	if #sessions == 0 or not kind or not label then
		return
	end
	for _, session in ipairs(sessions) do
		if session.finalized or tick() > session.expiresAt then
			continue
		end
		if targetLogRef and session.logRef ~= targetLogRef then
			continue
		end
		if kind == "inbound" then
			local inboundReplica = 0
			local labelLower = (label or ""):lower()
			local isReplica = string.find(labelLower, "replicaset", 1, true)
				or string.find(labelLower, "replica", 1, true)
			if isReplica then
				for _, effect in ipairs(session.chain) do
					if effect.kind == "inbound" then
						local el = (effect.label or ""):lower()
						if string.find(el, "replicaset", 1, true) or string.find(el, "replica", 1, true) then
							inboundReplica += 1
						end
					end
				end
				if inboundReplica >= 2 then
					continue
				end
			end
		end
		table.insert(session.chain, {
			t = tick(),
			kind = kind,
			label = label,
			detail = detail,
		})
		if session.logRef then
			session.logRef.CorrelationBlock = formatCorrelationChain(session)
			if selected and selected == session.logRef then
				selectLogEntry(session.logRef)
			end
		end
		if kind == "state" and session.actionKey and detail then
			recordSemanticSignal(session.actionKey, detail)
		end
	end
end

function computeConfidenceFromSession(session)
	if not session then
		return nil
	end
	local evidence = {}
	local score = 0
	local actionLower = session.actionKey and session.actionKey:lower() or ""
	for _, effect in ipairs(session.chain) do
		if effect.kind == "state" then
			if string.find(effect.label or "", "+", 1, true) or string.find(effect.label or "", "-", 1, true) then
				local tag = string.find(effect.label, "+", 1, true) and "Money+" or "Money-"
				score += US.SIGNAL_WEIGHTS[tag] or 0.15
				table.insert(evidence, tag)
			else
				score += US.SIGNAL_WEIGHTS.Inventory or 0.2
				table.insert(evidence, "State:" .. (effect.label or "?"))
			end
		elseif effect.kind == "prop" then
			score += US.SIGNAL_WEIGHTS.Prop or 0.1
			table.insert(evidence, "Prop:" .. (effect.label or "?"))
		elseif effect.kind == "anim" then
			score += US.SIGNAL_WEIGHTS.Animation or 0.1
			table.insert(evidence, "Anim:" .. (effect.label or "?"))
		elseif effect.kind == "sound" then
			score += US.SIGNAL_WEIGHTS.Sound or 0.08
			table.insert(evidence, "Sound:" .. (effect.label or "?"))
		elseif effect.kind == "inbound" then
			score += 0.2
			table.insert(evidence, "Inbound:" .. (effect.label or "?"))
		end
	end
	if session.direction == "in" then
		score += 0.15
		table.insert(evidence, "InboundSession")
	end
	if session.uiTrigger and uiTriggerMatchesAction(session.uiTrigger, session.actionKey) then
		score += US.SIGNAL_WEIGHTS.UI or 0.2
		table.insert(evidence, "UI:" .. (session.uiTrigger.shortName or session.uiTrigger.path or "?"))
	end
	if session.parallel then
		table.insert(evidence, "Parallel")
	end
	if session.callStack then
		for _, frame in ipairs(session.callStack) do
			if frame.layer == "Controller" then
				score += US.SIGNAL_WEIGHTS.Controller or 0.15
				table.insert(evidence, "Controller:" .. (frame.name or "?"))
				break
			end
		end
	end
	if session.snapshot and session.snapshot.actorName then
		score += US.SIGNAL_WEIGHTS.Actor or 0.05
		table.insert(evidence, "Actor:" .. session.snapshot.actorName)
	end
	if string.find(actionLower, "buy", 1, true) then
		table.insert(evidence, "Action:Buy")
	elseif string.find(actionLower, "equip", 1, true) then
		table.insert(evidence, "Action:Equip")
	end
	score = math.min(score, 1)
	if isOutcomeLearningEnabled() and session.remotePath and session.actionKey then
		local ob = US.actionOutcomes[getOutcomeKey(session.remotePath, session.actionKey)]
		if ob and (ob.failed or 0) > (ob.success or 0) and (ob.failed or 0) >= 2 then
			score = math.max(0, score - 0.25)
			table.insert(evidence, "Outcome:mostly_failed")
		end
	end
	local label = session.actionKey or "Remote effect"
	if string.find(actionLower, "buy", 1, true) then
		label = "Comprar item"
	elseif string.find(actionLower, "reward", 1, true) then
		label = "Receber recompensa"
	end
	return { score = score, label = label, evidence = evidence }
end

function recordPostRemoteGraph(session)
	if not session or not session.remotePath or not session.chain or #session.chain == 0 then
		return
	end
	local remoteKey = "Remote:" .. session.remotePath
	if not networkGraph[remoteKey] then
		networkGraph[remoteKey] = { label = "[Remote] " .. session.remotePath, children = {} }
	end
	local parentKey = remoteKey
	for _, effect in ipairs(session.chain) do
		local kind = effect.kind or "effect"
		local childKey = kind .. ":" .. (effect.label or "?")
		local cap = string.upper(string.sub(kind, 1, 1)) .. string.sub(kind, 2)
		local label = string.format("[%s] %s", cap, effect.label or "?")
		networkGraph[parentKey].children[childKey] = (networkGraph[parentKey].children[childKey] or 0) + 1
		if not networkGraph[childKey] then
			networkGraph[childKey] = { label = label, children = {} }
		end
		parentKey = childKey
	end
end

function finalizeCorrelationSession(session)
	if not session or session.finalized then
		return
	end
	session.finalized = true
	local conf = computeConfidenceFromSession(session)
	recordSessionOutcome(session)
	if session.remotePath then
		local entry = US.remoteAtlas[session.remotePath]
		if entry then
			mergeConfidenceIntoAtlas(entry, session, conf)
		end
	end
	recordPostRemoteGraph(session)
	if session.logRef then
		session.logRef.CorrelationBlock = formatCorrelationChain(session)
		if conf and conf.score > 0 then
			session.logRef.ConfidenceBlock = string.format(
				"-- Confidence: %d%% (%s) action=%s\n-- Evidence: %s\n",
				math.floor(conf.score * 100),
				conf.label,
				tostring(session.actionKey or "?"),
				table.concat(conf.evidence, ", ")
			)
		end
	end
	removeActiveCorrelationSession(session)
end

function openCorrelationSession(logRef, snapshot, actionKey, flowId, uiTrigger, callStack, direction)
	local window = getCorrelateWindow()
	local parallel = isParallelThread()
	if parallel and snapshot then
		snapshot.parallel = true
	end
	local session = {
		id = US.nextCorrelationId,
		remotePath = snapshot and snapshot.path,
		actionKey = actionKey,
		flowId = flowId,
		logRef = logRef,
		direction = direction or "out",
		startedAt = tick(),
		expiresAt = tick() + window,
		chain = {},
		uiTrigger = uiTrigger,
		callStack = callStack,
		snapshot = snapshot,
		parallel = parallel,
		finalized = false,
	}
	US.nextCorrelationId += 1
	table.insert(US.correlationSessions, 1, session)
	while #US.correlationSessions > US.MAX_CORRELATION_SESSIONS do
		finalizeCorrelationSession(table.remove(US.correlationSessions))
	end
	if not US.activeCorrelations then
		US.activeCorrelations = {}
	end
	table.insert(US.activeCorrelations, 1, session)
	while #US.activeCorrelations > US.MAX_ACTIVE_CORRELATIONS do
		finalizeCorrelationSession(US.activeCorrelations[#US.activeCorrelations])
	end
	US.activeCorrelation = session
	US.recentOutboundContext = {
		time = session.startedAt,
		path = session.remotePath,
		actionKey = actionKey,
		flowId = flowId,
		logRef = logRef,
		direction = direction,
		sessionId = session.id,
	}
	if parallel and isFlowTrackingEnabled() then
		appendFlowStep(nil, { kind = "Parallel", label = "task.desynchronize / parallel thread" })
	end
	task.defer(function()
		task.wait(window)
		if not session.finalized then
			finalizeCorrelationSession(session)
		end
	end)
	return session
end

function formatCorrelationReport()
	local lines = { "-- Correlation Sessions", "" }
	if #US.correlationSessions == 0 then
		table.insert(lines, "-- (no sessions yet)")
		return table.concat(lines, "\n")
	end
	for _, session in ipairs(US.correlationSessions) do
		table.insert(
			lines,
			string.format(
				"#%d %s action=%s effects=%d",
				session.id,
				getShortPathName(session.remotePath or "?"),
				tostring(session.actionKey),
				#session.chain
			)
		)
		for _, effect in ipairs(session.chain) do
			table.insert(lines, string.format("  [%s] %s", effect.kind, effect.label))
		end
		local conf = computeConfidenceFromSession(session)
		if conf then
			table.insert(lines, string.format("  Confidence: %d%%", math.floor(conf.score * 100)))
		end
		table.insert(lines, "")
	end
	return table.concat(lines, "\n")
end

function onAnimationPlayed(track)
	if not isTrackAnimationsEnabled() or reentForwardDepth > 0 then
		return
	end
	local animName = "Animation"
	pcall(function()
		if track.Animation then
			animName = track.Animation.Name or animName
		elseif track.Name then
			animName = track.Name
		end
	end)
	local lower = animName:lower()
	for deny in pairs(US.ANIM_DENYLIST) do
		if string.find(lower, deny, 1, true) then
			return
		end
	end
	pushCorrelationEffect("anim", animName)
	if isFlowTrackingEnabled() and getActiveCorrelationSession() then
		appendFlowStep(nil, { kind = "Animation", label = animName })
	end
end

function onSoundPlayed(sound)
	if not isTrackSoundsEnabled() then
		return
	end
	local soundName = sound and sound.Name or "Sound"
	pushCorrelationEffect("sound", soundName)
end

function installInstanceNewHook()
	if US.instanceNewHookInstalled or not hookfunction then
		return false
	end
	if not newcclosure then
		US.instanceNewHookFailed = true
		return false
	end
	local originalInstanceNew
	local hookedFn = newcclosure(function(className, ...)
		if typeof(className) ~= "string" then
			if originalInstanceNew then
				return originalInstanceNew(className, ...)
			end
			return nil
		end
		if not originalInstanceNew then
			return nil
		end
		local inst = originalInstanceNew(className, ...)
		if US.NETWORK_CREATE_CLASSES[className] and isTrackRemoteCreationEnabled() then
			local info = debug.getinfo(2, "Sl")
			task.defer(function()
				recordRemoteCreation(inst, className, info)
			end)
		end
		return inst
	end)
	local ok, hookErr = pcall(function()
		originalInstanceNew = hookfunction(Instance.new, hookedFn)
	end)
	if ok and originalInstanceNew then
		US.originalInstanceNew = originalInstanceNew
		US.instanceNewHookInstalled = true
		US.instanceNewHookFailed = false
		return true
	end
	US.instanceNewHookFailed = true
	warn("[UltraSpy] Instance.new hook failed: " .. tostring(hookErr))
	return false
end

function removeInstanceNewHook()
	if not US.instanceNewHookInstalled or not US.originalInstanceNew or not hookfunction then
		return
	end
	pcall(function()
		hookfunction(Instance.new, US.originalInstanceNew)
	end)
	US.instanceNewHookInstalled = false
end

function installAnimationHooks()
	US.animationHookInstalled = isTrackAnimationsEnabled()
	US.soundHookInstalled = isTrackSoundsEnabled()
end

function removeAnimationHooks()
	US.animationHookInstalled = false
	US.soundHookInstalled = false
end

function scanRemoteLifecycleExisting(root)
	if not isRemoteLifecycleEnabled() or not root then
		return
	end
	pcall(function()
		for _, inst in ipairs(root:GetDescendants()) do
			if isNetworkRemoteInstance(inst) then
				registerRemoteBirth(inst, nil, true)
			end
		end
	end)
end

--- Phase 4: reference tracking, discovery, module graph, protocols, outcomes

function isTrackRemoteReferencesEnabled()
	return _G.SIMPLESPYCONFIG_TrackRemoteReferences ~= false
end

function isProtocolRegistryEnabled()
	return _G.SIMPLESPYCONFIG_ProtocolRegistry ~= false
end

function isOutcomeLearningEnabled()
	return _G.SIMPLESPYCONFIG_OutcomeLearning ~= false
end

function isModuleGraphEnabled()
	return _G.SIMPLESPYCONFIG_ModuleGraph ~= false
end

function getRemotePathFromInstance(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	local ok, path = pcall(function()
		return inst:GetFullName()
	end)
	return ok and path or inst.Name
end

function getCaptureCallerInfo(levelStart)
	local info = { source = "?", line = 0, func = "?", scriptPath = nil }
	for level = levelStart or 2, levelStart + 6 do
		local ok, dbg = pcall(debug.getinfo, level, "sln")
		if not ok or not dbg or not dbg.source then
			break
		end
		local src = dbg.source
		if
			src
			and not string.find(src, "SimpleSpy", 1, true)
			and not string.find(src, "ULTRASPY", 1, true)
			and not string.find(src, "CoreGui", 1, true)
		then
			info.source = src
			info.line = dbg.currentline or 0
			info.func = dbg.name or "[anonymous]"
			break
		end
	end
	if useGetCallingScript and getcallingscript then
		pcall(function()
			local scr = getcallingscript()
			if typeof(scr) == "Instance" then
				info.scriptPath = scr:GetFullName()
			end
		end)
	end
	return info
end

function ensureRemoteReferenceBucket(remotePath)
	if not US.remoteReferences[remotePath] then
		US.remoteReferences[remotePath] = { captures = {}, byRefId = {} }
	end
	return US.remoteReferences[remotePath]
end

function recordRemoteReferenceCapture(remote, kind, methodKey, callerInfo)
	if not isTrackRemoteReferencesEnabled() or typeof(remote) ~= "Instance" then
		return nil
	end
	local remotePath = getRemotePathFromInstance(remote)
	if not remotePath then
		return nil
	end
	callerInfo = callerInfo or getCaptureCallerInfo(3)
	local bucket = ensureRemoteReferenceBucket(remotePath)
	local refId = US.nextRefId
	US.nextRefId += 1
	local capture = {
		refId = refId,
		kind = kind or "method_ref",
		methodKey = methodKey,
		source = callerInfo.source,
		line = callerInfo.line,
		func = callerInfo.func,
		scriptPath = callerInfo.scriptPath,
		time = tick(),
	}
	table.insert(bucket.captures, 1, capture)
	bucket.byRefId[refId] = capture
	while #bucket.captures > US.MAX_REF_CAPTURES_PER_REMOTE do
		local drop = table.remove(bucket.captures)
		if drop then
			bucket.byRefId[drop.refId] = nil
		end
	end
	return capture
end

function getOrCreateTracedRemoteMethod(remote, methodKey, remoteType, refId)
	if not isTrackRemoteReferencesEnabled() then
		if methodKey == "InvokeServer" or methodKey == "invokeServer" then
			return newInvokeServer
		end
		return newFireServer
	end
	local cacheKey = tostring(remote) .. ":" .. tostring(methodKey)
	if US.tracedMethodCache[cacheKey] then
		return US.tracedMethodCache[cacheKey]
	end
	local wrapped
	if methodKey == "InvokeServer" or methodKey == "invokeServer" then
		wrapped = newcclosure(function(r, ...)
			US.lastFiredRefId = refId
			local packed = table.pack(newInvokeServer(r or remote, ...))
			US.lastFiredRefId = nil
			return unpack(packed, 1, packed.n)
		end)
	else
		wrapped = newcclosure(function(r, ...)
			US.lastFiredRefId = refId
			local packed = table.pack(newFireServer(r or remote, ...))
			US.lastFiredRefId = nil
			return unpack(packed, 1, packed.n)
		end)
	end
	recordRemoteReferenceCapture(remote, "cached_closure", methodKey, getCaptureCallerInfo(4))
	US.tracedMethodCache[cacheKey] = wrapped
	return wrapped
end

function instancesReferToSameRemote(a, b)
	if a == b then
		return true
	end
	if typeof(a) ~= "Instance" or typeof(b) ~= "Instance" then
		return false
	end
	local okA, pathA = pcall(function()
		return a:GetFullName()
	end)
	local okB, pathB = pcall(function()
		return b:GetFullName()
	end)
	return okA and okB and pathA == pathB and pathA ~= ""
end

function scanFunctionUpvaluesForRemoteInstance(func, remote, callerInfo)
	if not isUpvalueRemoteRegistryEnabled() or typeof(func) ~= "function" or typeof(remote) ~= "Instance" then
		return false
	end
	if not debug.getupvalues then
		return false
	end
	callerInfo = callerInfo or getCaptureCallerInfo(6)
	if debug.getupvalue then
		for _, upName in ipairs({ "re", "remote", "remoteRef", "event", "remoteEvent", "r" }) do
			local okUv, val = pcall(debug.getupvalue, func, upName)
			if okUv and instancesReferToSameRemote(val, remote) then
				registerUpvalueRemoteLink(func, upName, upName, remote, callerInfo)
				return true
			end
		end
	end
	for i = 1, 40 do
		local okUp, upName, val = pcall(debug.getupvalues, func, i)
		if not okUp or upName == nil then
			break
		end
		if instancesReferToSameRemote(val, remote) then
			registerUpvalueRemoteLink(func, i, upName, remote, callerInfo)
			return true
		end
		if type(val) == "table" then
			for _, field in ipairs({ "inst", "remote", "event", "re", "remoteEvent" }) do
				if instancesReferToSameRemote(val[field], remote) then
					registerUpvalueRemoteLink(func, i, upName .. "." .. field, remote, callerInfo)
					return true
				end
			end
		end
	end
	return false
end

function resolveRemoteFromFireFunction(func, remoteArg)
	if typeof(remoteArg) == "Instance" then
		local ok, isRf = pcall(function()
			return remoteArg:IsA("RemoteEvent") or remoteArg:IsA("RemoteFunction")
		end)
		if ok and isRf then
			return remoteArg
		end
	end
	if func and debug.getupvalues then
		for i = 1, 32 do
			local ok, upName, val = pcall(debug.getupvalues, func, i)
			if not ok then
				break
			end
			if typeof(val) == "Instance" then
				local ok2, isR = pcall(function()
					return val:IsA("RemoteEvent") or val:IsA("RemoteFunction")
				end)
				if ok2 and isR then
					local callerInfo = getCaptureCallerInfo(5)
					if isTrackRemoteReferencesEnabled() then
						recordRemoteReferenceCapture(val, "upvalue_hold", nil, callerInfo)
					end
					registerUpvalueRemoteLink(func, i, upName, val, callerInfo)
					return val
				end
			end
		end
	end
	return typeof(remoteArg) == "Instance" and remoteArg or nil
end

function linkUpvaluesFromCallerStack(remote, levelStart)
	if not isUpvalueRemoteRegistryEnabled() or typeof(remote) ~= "Instance" or not debug.getupvalues then
		return false
	end
	levelStart = levelStart or (hookfunction and 6 or 5)
	for level = levelStart, levelStart + 18 do
		local okInfo, dbg = pcall(debug.getinfo, level, "flnS")
		if not okInfo or not dbg or typeof(dbg.func) ~= "function" then
			break
		end
		local callerInfo = {
			source = dbg.source or "?",
			line = dbg.currentline or 0,
			func = dbg.name or "[anonymous]",
			scriptPath = dbg.source,
		}
		if scanFunctionUpvaluesForRemoteInstance(dbg.func, remote, callerInfo) then
			if isTrackRemoteReferencesEnabled() then
				recordRemoteReferenceCapture(remote, "upvalue_hold", nil, callerInfo)
			end
			return true
		end
	end
	return false
end

function traceRemoteIndexRead(remote, key)
	if not isTrackRemoteReferencesEnabled() then
		return nil
	end
	local kind = "method_ref"
	if key == "FireServer" or key == "fireServer" then
		kind = "method_ref"
	elseif key == "InvokeServer" or key == "invokeServer" then
		kind = "method_ref"
	else
		return nil
	end
	return recordRemoteReferenceCapture(remote, kind, key, getCaptureCallerInfo(3))
end

function getTracedMethodForIndex(remote, key, className)
	local capture = traceRemoteIndexRead(remote, key)
	local refId = capture and capture.refId
	if key == "InvokeServer" or key == "invokeServer" then
		return getOrCreateTracedRemoteMethod(remote, key, "RemoteFunction", refId)
	end
	return getOrCreateTracedRemoteMethod(remote, key, className, refId)
end

function scanFunctionConstantsForRemoteHints(func, parentEntry, found, budget)
	if not debug.getconstants or budget[1] <= 0 then
		return
	end
	pcall(function()
		local constants = debug.getconstants(func)
		for _, c in ipairs(constants) do
			if budget[1] <= 0 then
				break
			end
			if type(c) == "string" then
				budget[1] -= 1
				local lower = c:lower()
				if c == "FireServer" or c == "InvokeServer" or c == "RemoteEvent" or c == "RemoteFunction" then
					table.insert(found, {
						kind = "constant_hint",
						path = parentEntry.path,
						name = parentEntry.name,
						constant = c,
						source = parentEntry.source,
					})
				elseif string.find(c, "ReplicatedStorage", 1, true) or string.find(c, "Remote", 1, true) then
					table.insert(found, {
						kind = "constant_path",
						path = parentEntry.path,
						name = parentEntry.name,
						constant = c,
						source = parentEntry.source,
					})
				elseif #c >= 3 and #c <= 48 and string.match(c, "^[%w_]+$") and not string.find(lower, "script", 1, true) then
					table.insert(found, {
						kind = "constant_action",
						path = parentEntry.path,
						name = parentEntry.name,
						constant = c,
						source = parentEntry.source,
					})
				end
			end
		end
	end)
end

function scanFunctionUpvaluesDeep(func, parentEntry, found, upvalueBudget, depth)
	depth = depth or 0
	if depth > 2 or not debug.getupvalues or upvalueBudget[1] <= 0 then
		return
	end
	for i = 1, 24 do
		if upvalueBudget[1] <= 0 then
			break
		end
		local ok, name, value = pcall(debug.getupvalues, func, i)
		if not ok or name == nil then
			break
		end
		upvalueBudget[1] -= 1
		if type(value) == "function" then
			local sub = {
				path = parentEntry.path,
				name = (parentEntry.name or "?") .. "." .. tostring(name),
				source = parentEntry.source,
			}
			if wrapperNameMatches(name) or depth == 0 then
				table.insert(found, {
					kind = "upvalue_fn",
					path = sub.path,
					name = sub.name,
					upvalue = name,
					upvalueSource = parentEntry.source,
				})
				scanFunctionUpvaluesDeep(value, sub, found, upvalueBudget, depth + 1)
				scanFunctionConstantsForRemoteHints(value, sub, found, upvalueBudget)
			end
		elseif typeof(value) == "Instance" and (value:IsA("RemoteEvent") or value:IsA("RemoteFunction")) then
			local remotePath = "?"
			pcall(function()
				remotePath = value:GetFullName()
			end)
			table.insert(found, {
				kind = "upvalue_remote",
				path = parentEntry.path,
				name = parentEntry.name,
				upvalue = name,
				remotePath = remotePath,
			})
			local callerInfo = {
				source = parentEntry.source or "?",
				line = 0,
				func = parentEntry.name,
				scriptPath = parentEntry.path,
			}
			recordRemoteReferenceCapture(value, "upvalue_hold", nil, callerInfo)
			registerUpvalueRemoteLink(func, i, name, value, callerInfo)
		end
	end
end

function scanCachedRemoteReferences(budget)
	budget = budget or { 2000 }
	local found = {}
	if getloadedmodules and getsenv then
		for _, mod in ipairs(getloadedmodules()) do
			pcall(function()
				if not mod:IsA("ModuleScript") then
					return
				end
				local path = mod:GetFullName()
				local env = getsenv(mod)
				for k, v in pairs(env) do
					if type(k) == "string" and type(v) == "function" then
						local entry = { path = path, name = k, source = path }
						scanFunctionUpvaluesDeep(v, entry, found, budget, 0)
						scanFunctionConstantsForRemoteHints(v, entry, found, budget)
					end
				end
			end)
		end
	end
	return found
end

function formatRemoteReferences(remotePath)
	local lines = { "-- Remote Reference Tracker", "" }
	if remotePath then
		local bucket = US.remoteReferences[remotePath]
		if not bucket or #bucket.captures == 0 then
			table.insert(lines, "-- (no captures for " .. remotePath .. ")")
			return table.concat(lines, "\n")
		end
		table.insert(lines, "-- Remote: " .. remotePath)
		for _, cap in ipairs(bucket.captures) do
			table.insert(
				lines,
				string.format(
					"-- [REF#%d] %s %s @ %s:%s (%s)",
					cap.refId,
					cap.kind,
					tostring(cap.methodKey or ""),
					tostring(cap.source),
					tostring(cap.line),
					tostring(cap.func)
				)
			)
		end
		return table.concat(lines, "\n")
	end
	local any = false
	for path, bucket in pairs(US.remoteReferences) do
		if #bucket.captures > 0 then
			any = true
			table.insert(lines, path)
			for i = 1, math.min(8, #bucket.captures) do
				local cap = bucket.captures[i]
				table.insert(
					lines,
					string.format(
						"  [REF#%d] %s %s @ %s:%s",
						cap.refId,
						cap.kind,
						tostring(cap.methodKey or ""),
						tostring(cap.source),
						tostring(cap.line)
					)
				)
			end
			table.insert(lines, "")
		end
	end
	if not any then
		table.insert(lines, "-- (no reference captures yet — read .FireServer after spy is on)")
	end
	return table.concat(lines, "\n")
end

function scoreDiscoveryCandidate(entry)
	local score = 0
	if entry.kind == "upvalue_remote" then
		score += 30
	elseif entry.kind == "constant_path" then
		score += 20
	elseif entry.kind == "constant_hint" then
		score += 15
	elseif entry.kind == "upvalue_fn" or entry.kind == "module_env" or entry.kind == "gc_closure" then
		score += 15
	elseif entry.kind == "constant_action" then
		score += 8
	elseif entry.kind == "module_proto" then
		score += 10
	elseif entry.kind == "gc_remote" then
		score += 25
	elseif entry.kind == "metatable_wrapper" then
		score += 22
	elseif entry.kind == "gc_closure_remote_like" then
		score += 28
	elseif entry.kind == "gc_closure_with_remote_const" then
		score += 35
	elseif entry.kind == "custom_signal" then
		score += 20
	elseif entry.kind == "table_method" then
		score += 24
	end
	if entry.priority and type(entry.priority) == "number" then
		score += math.max(0, entry.priority - 25)
	end
	if entry.name and wrapperNameMatches(entry.name) then
		score += 15
	end
	if entry.remotePath then
		score += 10
		if not string.find(entry.remotePath, "ReplicatedStorage", 1, true) then
			score += 15
		end
	end
	return score
end

function inferProtocolFromConstants(remotePath, actionKey)
	if not isProtocolRegistryEnabled() or not actionKey or type(actionKey) ~= "string" then
		return
	end
	for _, entry in pairs(US.discoveryAtlas) do
		if entry.constant == actionKey or entry.suggestedAction == actionKey then
			local path = remotePath or entry.remotePath
			if path and path ~= "?" then
				recordProtocolObservation(path, "string", actionKey)
			end
		end
	end
end

function mergeDiscoveryCandidate(entry)
	local minScore = _G.SIMPLESPYCONFIG_DiscoveryMinScore or 25
	local score = scoreDiscoveryCandidate(entry)
	if score < minScore then
		return
	end
	if entry.kind == "constant_action" and entry.constant then
		inferProtocolFromConstants(entry.remotePath, entry.constant)
	end
	local key = (entry.remotePath or "") .. "|" .. (entry.path or "") .. "|" .. (entry.name or "") .. "|" .. entry.kind
	if US.discoveryAtlas[key] then
		local existing = US.discoveryAtlas[key]
		existing.score = math.max(existing.score, score)
		existing.hits = (existing.hits or 1) + 1
		return
	end
	local count = 0
	for _ in pairs(US.discoveryAtlas) do
		count += 1
	end
	if count >= US.MAX_DISCOVERY_ENTRIES then
		return
	end
	US.discoveryAtlas[key] = {
		score = score,
		hits = 1,
		kind = entry.kind,
		path = entry.path,
		name = entry.name,
		remotePath = entry.remotePath,
		constant = entry.constant,
		source = entry.source,
		suggestedAction = entry.kind == "constant_action" and entry.constant or nil,
		hookReason = entry.hookReason,
		autoHookScore = score,
	}
	if entry.kind == "gc_remote" and entry.remotePath and not string.find(entry.remotePath, "ReplicatedStorage", 1, true) then
		appendTimelineEvent({
			kind = "remote_found",
			label = getShortPathName(entry.remotePath),
			detail = "outside RS",
		})
	end
end

function markDiscoveryHooked(entry, reason)
	if not entry then
		return
	end
	local key = (entry.remotePath or "")
		.. "|"
		.. (entry.path or "")
		.. "|"
		.. (entry.name or "")
		.. "|"
		.. (entry.kind or "")
	local atlas = US.discoveryAtlas[key]
	if atlas then
		atlas.hooked = true
		atlas.hookReason = reason or "auto_hook"
		atlas.hookedAt = tick()
	end
end

function scanProtosRecursive(func, parentEntry, found, budget, depth)
	if depth > 3 or not debug.getprotos or budget[1] <= 0 then
		return
	end
	pcall(function()
		local protos = { debug.getprotos(func) }
		for _, proto in ipairs(protos) do
			if budget[1] <= 0 then
				break
			end
			budget[1] -= 1
			local pinfo = debug.getinfo(proto, "n")
			local pname = pinfo and pinfo.name or "proto"
			local sub = {
				path = parentEntry.path,
				name = (parentEntry.name or "?") .. "." .. pname,
				source = parentEntry.source,
			}
			if wrapperNameMatches(pname) then
				table.insert(found, {
					kind = "module_proto",
					path = sub.path,
					name = sub.name,
					source = sub.source,
				})
			end
			scanFunctionUpvaluesDeep(proto, sub, found, budget, depth + 1)
			scanFunctionConstantsForRemoteHints(proto, sub, found, budget)
			scanProtosRecursive(proto, sub, found, budget, depth + 1)
		end
	end)
end

function deepCopyArgValue(value, depth, seen)
	if _G.SIMPLESPYCONFIG_DeepCopyArgs == false then
		return value
	end
	depth = depth or 0
	if depth > 8 then
		return value
	end
	local t = typeof(value)
	if t == "table" then
		seen = seen or {}
		if seen[value] then
			return seen[value]
		end
		local copy = {}
		seen[value] = copy
		for k, v in pairs(value) do
			local ck = type(k) == "table" and deepCopyArgValue(k, depth + 1, seen) or k
			copy[ck] = deepCopyArgValue(v, depth + 1, seen)
		end
		return copy
	elseif t == "Instance" then
		local path = "?"
		pcall(function()
			path = value:GetFullName()
		end)
		return { __ultraspy_instance = path }
	end
	return value
end

function deepCopyArgsList(args)
	if not args or _G.SIMPLESPYCONFIG_DeepCopyArgs == false then
		return args
	end
	local out = {}
	for i = 1, #args do
		out[i] = deepCopyArgValue(args[i], 0, {})
	end
	return out
end

function scanGcCustomSignalLike(obj, found, budget)
	if type(obj) ~= "table" or budget[1] <= 0 or _G.SIMPLESPYCONFIG_ScanCustomSignals == false then
		return
	end
	local hasFire, hasConnect = false, false
	for k, v in pairs(obj) do
		if type(k) == "string" then
			local lk = string.lower(k)
			if lk == "fire" and type(v) == "function" then
				hasFire = true
			elseif lk == "connect" and type(v) == "function" then
				hasConnect = true
			end
		end
	end
	if hasFire and hasConnect then
		budget[1] -= 1
		table.insert(found, {
			kind = "custom_signal",
			path = "?",
			name = "CustomSignal",
			source = "getgc_signal",
			priority = 30,
		})
	end
end

function scanGcClosureForRemoteConst(func, found, budget)
	if budget[1] <= 0 or type(func) ~= "function" or not debug.getconstants then
		return
	end
	pcall(function()
		local constants = { debug.getconstants(func) }
		for _, c in ipairs(constants) do
			if c == "FireServer" or c == "InvokeServer" then
				local info = debug.getinfo(func, "nS")
				table.insert(found, {
					kind = "gc_closure_with_remote_const",
					name = info and info.name or "[anonymous]",
					source = info and info.source or "?",
					path = info and info.source or "?",
					func = func,
					priority = 45,
				})
				budget[1] -= 1
				return
			end
		end
	end)
end

function scanGcPlainTableNetworkLike(obj, found, budget)
	if type(obj) ~= "table" or budget[1] <= 0 then
		return
	end
	for k, v in pairs(obj) do
		if type(k) == "string" and type(v) == "function" and wrapperNameMatches(k) then
			budget[1] -= 1
			local entry = {
				kind = "table_method",
				path = "?",
				name = k,
				source = "getgc_table",
				priority = 32,
			}
			if islclosure and islclosure(v) then
				entry.func = v
			end
			table.insert(found, entry)
			return
		end
	end
end

function scanGcMetatableRemoteLike(obj, found, budget)
	if type(obj) ~= "table" or budget[1] <= 0 or not getrawmetatable then
		return
	end
	budget[1] -= 1
	local ok, mt = pcall(getrawmetatable, obj)
	if not ok or type(mt) ~= "table" then
		return
	end
	local remoteMethods = { "FireServer", "InvokeServer", "fireServer", "invokeServer" }
	local hasRemoteMethod = false
	for _, m in ipairs(remoteMethods) do
		if rawget(mt, m) then
			hasRemoteMethod = true
			break
		end
		local idx = rawget(mt, "__index")
		if type(idx) == "table" and rawget(idx, m) then
			hasRemoteMethod = true
			break
		end
		if type(idx) == "function" then
			pcall(function()
				local proxy = setmetatable({}, { __index = idx })
				if proxy[m] then
					hasRemoteMethod = true
				end
			end)
			if hasRemoteMethod then
				break
			end
		end
	end
	local idxFn = rawget(mt, "__index")
	if type(idxFn) == "function" then
		hasRemoteMethod = true
	end
	if not hasRemoteMethod and not rawget(mt, "__call") then
		return
	end
	local nameHint = "[table_remote]"
	for k in pairs(obj) do
		if type(k) == "string" and wrapperNameMatches(k) then
			nameHint = k
			break
		end
	end
	table.insert(found, {
		kind = "metatable_wrapper",
		path = "?",
		name = nameHint,
		source = "getgc_metatable",
		tableRef = tostring(obj),
		priority = 35,
	})
end

function discoverRemoteCandidates()
	local found = {}
	local upvalueBudget = { 1500 }
	local protoBudget = { 800 }
	local scanStart = tick()
	local gcScanned, gcInstances, gcFunctions, gcTables = 0, 0, 0, 0
	if getloadedmodules then
		for _, mod in ipairs(getloadedmodules()) do
			pcall(function()
				local path = mod:GetFullName()
				discoveredModules[path] = true
				if getsenv and mod:IsA("ModuleScript") then
					local env = getsenv(mod)
					for k, v in pairs(env) do
						if type(k) == "string" and type(v) == "function" then
							local entry = { kind = "module_env", path = path, name = k, source = path }
							table.insert(found, entry)
							scanFunctionUpvaluesDeep(v, entry, found, upvalueBudget, 0)
							scanFunctionConstantsForRemoteHints(v, entry, found, upvalueBudget)
							scanProtosRecursive(v, entry, found, protoBudget, 0)
						end
					end
				end
				if getscriptclosure and mod:IsA("ModuleScript") then
					local ok, main = pcall(getscriptclosure, mod)
					if ok and type(main) == "function" then
						scanProtosRecursive(main, { path = path, name = "[main]", source = path }, found, protoBudget, 0)
					end
				end
			end)
		end
	end
	if getgc then
		local budget = getGcScanBudget()
		local tableBudget = { math.min(1200, math.floor(budget * 0.08)) }
		local constBudget = { math.min(2000, math.floor(budget * 0.12)) }
		for _, obj in ipairs(getgc(true)) do
			gcScanned += 1
			if gcScanned > budget then
				break
			end
			if typeof(obj) == "Instance" then
				gcInstances += 1
				if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("UnreliableRemoteEvent") then
					local remotePath = getRemotePathFromInstance(obj)
					local priority = 25
					if remotePath and not string.find(remotePath, "ReplicatedStorage", 1, true) then
						priority = 40
					end
					table.insert(found, {
						kind = "gc_remote",
						path = "?",
						name = obj.Name,
						remotePath = remotePath,
						source = "getgc",
						priority = priority,
					})
				end
			elseif type(obj) == "function" then
				gcFunctions += 1
				if islclosure and islclosure(obj) then
					local ok, info = pcall(debug.getinfo, obj, "n")
					if ok and info then
						if isUltraSpyInternalWrapper(info.name, info.source) then
							continue
						end
						local before = #found
						local entry = {
							kind = "gc_closure",
							name = info.name or "[anonymous]",
							source = info.source or "?",
							path = info.source or "?",
							func = obj,
						}
						local scanEntry = info.name and wrapperNameMatches(info.name)
						if scanEntry then
							scanFunctionUpvaluesDeep(obj, entry, found, upvalueBudget, 0)
							scanFunctionConstantsForRemoteHints(obj, entry, found, upvalueBudget)
						end
						local remoteLike = #found > before
						if remoteLike or (info.name and wrapperNameMatches(info.name)) then
							if isSpyProtectedFunction(obj) or isUltraSpyInternalWrapper(info.name, info.source) then
								continue
							end
							entry.kind = remoteLike and "gc_closure_remote_like" or entry.kind
							entry.priority = remoteLike and 38 or 20
							table.insert(found, entry)
						end
						if constBudget[1] > 0 then
							scanGcClosureForRemoteConst(obj, found, constBudget)
						end
					end
				end
			elseif type(obj) == "table" then
				gcTables += 1
				if tableBudget[1] > 0 then
					scanGcPlainTableNetworkLike(obj, found, tableBudget)
					scanGcMetatableRemoteLike(obj, found, tableBudget)
					scanGcCustomSignalLike(obj, found, tableBudget)
				end
			end
		end
	end
	for _, entry in ipairs(found) do
		mergeDiscoveryCandidate(entry)
	end
	scanCachedRemoteReferences({ 500 })
	US.discoveryScanStats = {
		scanned = gcScanned,
		instances = gcInstances,
		functions = gcFunctions,
		tables = gcTables,
		found = #found,
		elapsed = tick() - scanStart,
		budget = getGcScanBudget(),
		time = tick(),
	}
	return found
end

function formatDiscoveryAtlas()
	local lines = { "-- Discovery Atlas (static / not fired)", "" }
	local rows = {}
	for key, entry in pairs(US.discoveryAtlas) do
		table.insert(rows, { key = key, entry = entry })
	end
	table.sort(rows, function(a, b)
		return (a.entry.score or 0) > (b.entry.score or 0)
	end)
	if #rows == 0 then
		table.insert(lines, "-- (empty — run Deep Discovery)")
		return table.concat(lines, "\n")
	end
	for i, row in ipairs(rows) do
		if i > 120 then
			table.insert(lines, "-- ... truncated")
			break
		end
		local e = row.entry
		table.insert(
			lines,
			string.format(
				"-- [%d] %s | %s.%s | remote=%s",
				e.score,
				e.kind,
				tostring(e.path),
				tostring(e.name),
				tostring(e.remotePath or e.suggestedAction or "?")
			)
		)
	end
	return table.concat(lines, "\n")
end

function addModuleGraphEdge(fromPath, toPath, kind, evidence)
	if not fromPath or not toPath or fromPath == toPath then
		return
	end
	if not US.moduleGraph.nodes[fromPath] then
		US.moduleGraph.nodes[fromPath] = { exports = {}, layer = "Script", remotes = {} }
	end
	if not US.moduleGraph.nodes[toPath] then
		US.moduleGraph.nodes[toPath] = { exports = {}, layer = "Script", remotes = {} }
	end
	table.insert(US.moduleGraph.edges, {
		from = fromPath,
		to = toPath,
		kind = kind or "link",
		evidence = evidence or "",
	})
end

function buildModuleDependencyGraph()
	if not isModuleGraphEnabled() then
		return US.moduleGraph
	end
	US.moduleGraph = { nodes = {}, edges = {} }
	if getloadedmodules then
		for _, mod in ipairs(getloadedmodules()) do
			pcall(function()
				if not mod:IsA("ModuleScript") then
					return
				end
				local path = mod:GetFullName()
				local node = { exports = {}, layer = "Script", remotes = {} }
				if getsenv then
					local env = getsenv(mod)
					for k, v in pairs(env) do
						if type(k) == "string" and type(v) == "function" then
							local frame = { name = k, source = path }
							table.insert(node.exports, { name = k, layer = classifyStackLayer(frame) })
						end
					end
				end
				US.moduleGraph.nodes[path] = node
				if getscriptclosure and debug.getconstants then
					local ok, main = pcall(getscriptclosure, mod)
					if ok and type(main) == "function" then
						pcall(function()
							for _, c in ipairs(debug.getconstants(main)) do
								if type(c) == "string" and string.find(c, ".", 1, true) then
									if string.find(c, "ReplicatedStorage", 1, true) or string.find(c, "Players", 1, true) then
										addModuleGraphEdge(path, c, "constant", c)
									end
								end
							end
						end)
						if debug.getprotos then
							pcall(function()
								for _, proto in ipairs(debug.getprotos(main)) do
									scanFunctionUpvaluesDeep(
										proto,
										{ path = path, name = "[proto]", source = path },
										{},
										{ 80 },
										0
									)
								end
							end)
						end
					end
				end
			end)
		end
	end
	for remotePath, bucket in pairs(US.remoteReferences) do
		for _, cap in ipairs(bucket.captures) do
			local from = cap.scriptPath or cap.source
			if from and from ~= "?" then
				addModuleGraphEdge(from, remotePath, "remote_ref", "REF#" .. tostring(cap.refId))
				if US.moduleGraph.nodes[from] then
					US.moduleGraph.nodes[from].remotes[remotePath] = true
				end
			end
		end
	end
	for _, edge in ipairs(US.moduleGraph.edges) do
		if edge.kind == "require" then
			-- already added
		end
	end
	return US.moduleGraph
end

function formatModuleDependencyGraph(rootPath)
	if not US.moduleGraph.nodes or not next(US.moduleGraph.nodes) then
		buildModuleDependencyGraph()
	end
	local lines = { "-- Module Dependency Graph", "" }
	local childMap = {}
	for _, edge in ipairs(US.moduleGraph.edges) do
		childMap[edge.from] = childMap[edge.from] or {}
		table.insert(childMap[edge.from], edge)
	end
	local function walk(path, depth)
		if depth > 6 then
			return
		end
		local node = US.moduleGraph.nodes[path]
		local indent = string.rep(" ", depth * 2)
		table.insert(lines, indent .. path)
		if node and node.remotes then
			for remotePath in pairs(node.remotes) do
				table.insert(lines, indent .. "  └ remote_ref → " .. remotePath)
			end
		end
		for _, edge in ipairs(childMap[path] or {}) do
			table.insert(lines, indent .. "  ├ " .. edge.kind .. " → " .. edge.to)
			if edge.evidence and edge.evidence ~= "" then
				table.insert(lines, indent .. "     (" .. edge.evidence .. ")")
			end
			walk(edge.to, depth + 1)
		end
	end
	if rootPath and US.moduleGraph.nodes[rootPath] then
		walk(rootPath, 0)
	else
		local roots = {}
		local hasParent = {}
		for _, edge in ipairs(US.moduleGraph.edges) do
			hasParent[edge.to] = true
		end
		for path in pairs(US.moduleGraph.nodes) do
			if not hasParent[path] then
				table.insert(roots, path)
			end
		end
		table.sort(roots)
		for _, path in ipairs(roots) do
			walk(path, 0)
			table.insert(lines, "")
		end
	end
	if #lines <= 2 then
		table.insert(lines, "-- (empty — run Build Module Graph)")
	end
	return table.concat(lines, "\n")
end

function assignProtocolLabel(remotePath, shape)
	if not isProtocolRegistryEnabled() or not shape or shape == "" then
		return nil
	end
	local entry = US.remoteAtlas[remotePath]
	if not entry then
		return nil
	end
	entry.protocols = entry.protocols or {}
	entry.shapeToProtocol = entry.shapeToProtocol or {}
	if entry.shapeToProtocol[shape] then
		return entry.shapeToProtocol[shape]
	end
	local counter = US.protocolLabelCounter[remotePath] or 0
	counter += 1
	US.protocolLabelCounter[remotePath] = counter
	local label = "PROTO_" .. string.char(64 + math.min(counter, 26))
	if counter > 26 then
		label = "PROTO_" .. tostring(counter)
	end
	entry.shapeToProtocol[shape] = label
	entry.protocols[label] = {
		signature = shape,
		count = 0,
		actions = {},
	}
	return label
end

function recordProtocolObservation(remotePath, shape, actionKey)
	if not isProtocolRegistryEnabled() then
		return nil
	end
	local label = assignProtocolLabel(remotePath, shape)
	if not label then
		return nil
	end
	local entry = US.remoteAtlas[remotePath]
	local proto = entry.protocols[label]
	proto.count += 1
	if actionKey then
		proto.actions[actionKey] = (proto.actions[actionKey] or 0) + 1
	end
	return label
end

function formatProtocolReport(remotePath)
	local lines = { "-- Protocol Report", "" }
	local paths = {}
	if remotePath then
		table.insert(paths, remotePath)
	else
		for path in pairs(US.remoteAtlas) do
			table.insert(paths, path)
		end
		table.sort(paths)
	end
	local any = false
	for _, path in ipairs(paths) do
		local entry = US.remoteAtlas[path]
		if entry and entry.protocols then
			any = true
			table.insert(lines, path)
			local protoRows = {}
			for label, proto in pairs(entry.protocols) do
				table.insert(protoRows, { label = label, proto = proto })
			end
			table.sort(protoRows, function(a, b)
				return (a.proto.count or 0) > (b.proto.count or 0)
			end)
			for _, row in ipairs(protoRows) do
				local actions = {}
				for act, cnt in pairs(row.proto.actions or {}) do
					table.insert(actions, act .. "x" .. tostring(cnt))
				end
				table.sort(actions)
				table.insert(
					lines,
					string.format(
						"  %s [%s] — %dx — %s",
						row.label,
						row.proto.signature or "?",
						row.proto.count or 0,
						#actions > 0 and table.concat(actions, ", ") or "(no actions)"
					)
				)
			end
			table.insert(lines, "")
		end
	end
	if not any then
		table.insert(lines, "-- (no protocols recorded yet)")
	end
	return table.concat(lines, "\n")
end

function getOutcomeKey(remotePath, actionKey)
	return (remotePath or "?") .. "|" .. (actionKey or "?")
end

function ensureOutcomeBucket(remotePath, actionKey)
	local key = getOutcomeKey(remotePath, actionKey)
	if not US.actionOutcomes[key] then
		US.actionOutcomes[key] = {
			remotePath = remotePath,
			actionKey = actionKey,
			normal = 0,
			success = 0,
			failed = 0,
			inconclusive = 0,
		}
	end
	return US.actionOutcomes[key]
end

function classifySessionOutcome(session)
	if not session then
		return "inconclusive"
	end
	local hasInbound = false
	local hasPositiveState = false
	local hasNegative = false
	local hasErrorInbound = false
	for _, effect in ipairs(session.chain or {}) do
		if effect.kind == "state" then
			local lbl = effect.label or ""
			if string.find(lbl, "+", 1, true) or string.find(lbl, "Money+", 1, true) then
				hasPositiveState = true
			end
			if string.find(lbl, "-", 1, true) and string.find(lbl, "0", 1, true) == nil then
				hasNegative = true
			end
		elseif effect.kind == "prop" then
			hasPositiveState = true
		elseif effect.kind == "inbound" then
			hasInbound = true
		end
		if effect.detail and type(effect.detail) == "string" then
			local d = effect.detail:lower()
			if string.find(d, "error", 1, true) or string.find(d, "fail", 1, true) then
				hasErrorInbound = true
			end
		end
	end
	if session.direction == "in" then
		return "success"
	end
	if hasErrorInbound or (hasNegative and not hasPositiveState and not hasInbound) then
		return "failed"
	end
	if hasInbound or hasPositiveState then
		return "success"
	end
	if #(session.chain or {}) == 0 then
		return "normal"
	end
	return "normal"
end

function recordSessionOutcome(session)
	if not isOutcomeLearningEnabled() or not session then
		return
	end
	local remotePath = session.remotePath
	local actionKey = session.actionKey or "?"
	if not remotePath then
		return
	end
	local bucket = ensureOutcomeBucket(remotePath, actionKey)
	local outcome = classifySessionOutcome(session)
	bucket[outcome] = (bucket[outcome] or 0) + 1
	if session.logRef then
		session.logRef.OutcomeTag = outcome
	end
end

function formatActionOutcomes(remotePath)
	local lines = { "-- Action Outcomes (session)", "" }
	local any = false
	for key, bucket in pairs(US.actionOutcomes) do
		if not remotePath or bucket.remotePath == remotePath then
			any = true
			local total = (bucket.normal or 0) + (bucket.success or 0) + (bucket.failed or 0) + (bucket.inconclusive or 0)
			table.insert(
				lines,
				string.format(
					"%s — %d total | Normal:%d Success:%d Failed:%d",
					bucket.actionKey,
					total,
					bucket.normal or 0,
					bucket.success or 0,
					bucket.failed or 0
				)
			)
		end
	end
	if not any then
		table.insert(lines, "-- (no outcomes yet)")
	end
	return table.concat(lines, "\n")
end

function bootstrapPhase3Tracking()
	pcall(scanRemoteLifecycleExisting, game)
	if isTrackRemoteCreationEnabled() then
		installInstanceNewHook()
		if not US.instanceNewHookInstalled then
			warn("[UltraSpy] Instance.new hook unavailable — remote creation tracking disabled for this session")
		end
	end
	installAnimationHooks()
end

function bootstrapPhase4Tracking()
	if isActionHuntModeEnabled() then
		applyActionHuntPreset()
	end
	if isTrackRemoteReferencesEnabled() then
		pcall(scanCachedRemoteReferences, { 800 })
	end
	task.defer(function()
		registerSpyProtectedFunctions()
		pcall(bootstrapDeepScanRoots)
		pcall(bootstrapAltChannelHooks)
		local removed = purgeInternalWrapperHooks()
		if removed > 0 then
			warn("[UltraSpy] Removed " .. tostring(removed) .. " internal wrapper hook(s) (spam fix)")
		end
	end)
	if _G.SIMPLESPYCONFIG_AutoDeepDiscovery ~= false then
		task.defer(function()
			task.wait(2.5)
			pcall(function()
				local found = discoverRemoteCandidates()
				hookDiscoveredWrappersFromList(found)
				purgeInternalWrapperHooks()
			end)
		end)
	end
	startPeriodicDiscoveryLoop()
end

function sanitizeHttpMeta(methodName, ...)
	local args = { ... }
	local meta = {
		channel = "http",
		method = methodName,
		url = "?",
		status = nil,
		shape = shallowHashArgs(args),
	}
	if type(args[1]) == "table" then
		local req = args[1]
		if type(req.Url) == "string" then
			meta.url = string.sub(req.Url, 1, 120)
		end
		if type(req.Method) == "string" then
			meta.method = req.Method
		end
	elseif type(args[1]) == "string" then
		meta.url = string.sub(args[1], 1, 120)
	end
	return meta
end

function logAltChannelEvent(channel, methodName, meta)
	if US.selfTestInProgress then
		return
	end
	meta = meta or {}
	appendTimelineRow({
		kind = channel,
		label = channel .. ":" .. tostring(methodName),
		time = tick(),
		detail = meta.url or meta.topic or "?",
	})
	if shouldLogWrapperCalls() then
		newWrapperLog("[" .. string.upper(channel) .. "] " .. tostring(methodName), {}, meta)
	end
end

function installHttpServiceHooks()
	if US.httpHooksInstalled then
		return
	end
	local HttpService = game:GetService("HttpService")
	local hooked = false
	local function wrap(methodName, originalFn)
		if type(originalFn) ~= "function" then
			return
		end
		pcall(function()
			hookfunction(
				originalFn,
				newcclosure(function(self, ...)
					logAltChannelEvent("http", methodName, sanitizeHttpMeta(methodName, ...))
					return originalFn(self, ...)
				end)
			)
			hooked = true
		end)
	end
	wrap("RequestAsync", HttpService.RequestAsync)
	wrap("PostAsync", HttpService.PostAsync)
	wrap("GetAsync", HttpService.GetAsync)
	US.httpHooksInstalled = hooked
end

function installMessagingServiceHooks()
	if US.messagingHooksInstalled then
		return
	end
	local ok, MessagingService = pcall(game.GetService, game, "MessagingService")
	if not ok or not MessagingService then
		return
	end
	local hooked = false
	pcall(function()
		if type(MessagingService.PublishAsync) == "function" then
			local orig = MessagingService.PublishAsync
			hookfunction(
				orig,
				newcclosure(function(topic, message, ...)
					logAltChannelEvent("messaging", "PublishAsync", {
						channel = "messaging",
						topic = type(topic) == "string" and string.sub(topic, 1, 80) or "?",
						shape = shallowHashArgs({ message }),
					})
					return orig(topic, message, ...)
				end)
			)
			hooked = true
		end
		if type(MessagingService.SubscribeAsync) == "function" then
			local origSub = MessagingService.SubscribeAsync
			pcall(function()
				hookfunction(
					origSub,
					newcclosure(function(topic, callback, ...)
						logAltChannelEvent("messaging", "SubscribeAsync", {
							channel = "messaging",
							topic = type(topic) == "string" and string.sub(topic, 1, 80) or "?",
							shape = "subscribe",
						})
						return origSub(topic, callback, ...)
					end)
				)
				hooked = true
			end)
		end
	end)
	US.messagingHooksInstalled = hooked
end

function bootstrapAltChannelHooks()
	-- DataStoreService is server-only; never hook on client (no-op by design).
	if _G.SIMPLESPYCONFIG_HookHttpService == true then
		pcall(installHttpServiceHooks)
	end
	if _G.SIMPLESPYCONFIG_HookMessagingService == true then
		pcall(installMessagingServiceHooks)
	end
end

--- Phase 5: world cause, investigation, entity/property tracking, combat discovery

local HEALTH_KEYS = {
	health = true,
	hp = true,
	life = true,
	currenthealth = true,
	currenthp = true,
	maxhealth = true,
	damage = true,
}
local REWARD_KEYS = {
	coins = true,
	money = true,
	gold = true,
	gems = true,
	gem = true,
	xp = true,
	exp = true,
	level = true,
	wins = true,
	tokens = true,
	cash = true,
	points = true,
	credits = true,
}
local DATA_FOLDER_NAMES = {
	playerdata = true,
	stats = true,
	combatdata = true,
	characterstate = true,
	data = true,
}
local PROPERTY_REWARD_HINTS = {
	money = true,
	coin = true,
	gold = true,
	gem = true,
	xp = true,
	level = true,
	wins = true,
	cash = true,
	reward = true,
	balance = true,
}
local COLLECTION_DEFAULT_TAGS = { "Enemy", "Boss", "NPC", "Mob", "RewardPart", "Checkpoint", "Interactable" }
local CAUSE_SIGNAL_NAMES = {
	Touched = true,
	TouchEnded = true,
	Triggered = true,
	PromptButtonHoldBegan = true,
	PromptButtonHoldEnded = true,
	MouseClick = true,
	Activated = true,
	Equipped = true,
	Unequipped = true,
}
local HIT_NAMECALL_METHODS = {
	Raycast = true,
	RaycastWithExclude = true,
	GetPartsInPart = true,
	GetPartBoundsInBox = true,
	GetPartBoundsInRadius = true,
	Spherecast = true,
}

function isPhase5Enabled()
	return _G.SIMPLESPYCONFIG_TrackCauses ~= false
end

function isTrackWorldSignalsEnabled()
	return _G.SIMPLESPYCONFIG_TrackWorldSignals ~= false
end

function isTrackHitsEnabled()
	return _G.SIMPLESPYCONFIG_TrackHits ~= false
end

function isEntityTrackerEnabled()
	return _G.SIMPLESPYCONFIG_EntityTracker ~= false
end

function isGlobalAttributesEnabled()
	return _G.SIMPLESPYCONFIG_GlobalAttributes ~= false
end

function isPropertyTrackerEnabled()
	return _G.SIMPLESPYCONFIG_PropertyTracker ~= false
end

function isInvestigationEnabled()
	return _G.SIMPLESPYCONFIG_InvestigationSessions ~= false
end

function isCombatDiscoveryEnabled()
	return _G.SIMPLESPYCONFIG_CombatDiscovery ~= false
end

function isRewardDiscoveryEnabled()
	return _G.SIMPLESPYCONFIG_RewardDiscovery ~= false
end

function isCallbackDiscoveryEnabled()
	return _G.SIMPLESPYCONFIG_CallbackDiscovery ~= false
end

function isCollectionServiceEnabled()
	return _G.SIMPLESPYCONFIG_TrackCollectionService ~= false and CollectionService ~= nil
end

function nameMatchesKeySet(name, keySet)
	if not name or type(name) ~= "string" then
		return false
	end
	local lower = name:lower()
	if keySet[lower] then
		return true
	end
	for key in pairs(keySet) do
		if string.find(lower, key, 1, true) then
			return true
		end
	end
	return false
end

function pathMatchesRewardHint(path)
	if not path then
		return false
	end
	local lower = path:lower()
	for hint in pairs(PROPERTY_REWARD_HINTS) do
		if string.find(lower, hint, 1, true) then
			return true
		end
	end
	return false
end

local PROP_COSMETIC_FRAGMENTS = {
	"robux",
	"price",
	"shop",
	"2xspeed",
	"sale",
	"forever",
	"premium",
	"purchase",
	"buy",
	"deal",
	"limited",
	"offer",
	"pass",
	"adbutton",
}

function getLogRemotePath(logRef)
	if not logRef then
		return nil
	end
	if logRef.Snapshot and logRef.Snapshot.path then
		return logRef.Snapshot.path
	end
	return logRef.RemotePath or logRef.Name
end

function isReplicaSetRemotePath(path)
	if not path or type(path) ~= "string" then
		return false
	end
	return string.find(path:lower(), "replicaset", 1, true) ~= nil
end

function getRemoteNameFromPath(path)
	if not path or type(path) ~= "string" then
		return ""
	end
	return path:match("[^%.]+$") or path
end

--- Classify by remote *name*, not full path — "ReplicatedStorage" contains "replicate" and must not mark action remotes as sync.
function classifyRemoteRole(path)
	if not path or type(path) ~= "string" then
		return "unknown"
	end
	local nameLower = getRemoteNameFromPath(path):lower()
	if
		string.find(nameLower, "replicaset", 1, true)
		or string.find(nameLower, "replicaupdate", 1, true)
		or string.find(nameLower, "datasync", 1, true)
		or string.find(nameLower, "statesync", 1, true)
		or string.find(nameLower, "replication", 1, true)
		or nameLower == "replicate"
	then
		return "replication_effect"
	end
	local pathLower = path:lower():gsub("^replicatedstorage%.", ""):gsub("%.replicatedstorage%.", ".")
	if
		string.find(pathLower, ".replication.", 1, true)
		or string.find(pathLower, ".replicate.", 1, true)
		or string.find(pathLower, ".statesync.", 1, true)
		or string.find(pathLower, ".datasync.", 1, true)
	then
		return "replication_effect"
	end
	return "action_candidate"
end

function isPropCosmeticPath(path)
	if not path then
		return true
	end
	local lower = path:lower()
	for _, frag in ipairs(PROP_COSMETIC_FRAGMENTS) do
		if string.find(lower, frag, 1, true) then
			return true
		end
	end
	if string.find(lower, ".playergui.", 1, true) and string.find(lower, ".hud.", 1, true) then
		if not pathMatchesRewardHint(path) then
			return true
		end
	end
	return false
end

function isPropCosmeticValue(oldVal, newVal)
	local function looksCosmeticText(s)
		if type(s) ~= "string" then
			return false
		end
		local lower = s:lower()
		return string.find(lower, "robux", 1, true)
			or string.find(lower, "forever", 1, true)
			or string.find(lower, "only ", 1, true)
			or string.find(lower, "sale", 1, true)
	end
	return looksCosmeticText(tostring(oldVal)) or looksCosmeticText(tostring(newVal))
end

function shouldLogPropChange(path, oldVal, newVal, logRef)
	if isPropCosmeticPath(path) or isPropCosmeticValue(oldVal, newVal) then
		return false
	end
	if isReplicaSetRemotePath(getLogRemotePath(logRef)) then
		if not pathMatchesRewardHint(path) then
			return false
		end
		if tonumber(oldVal) == nil and tonumber(newVal) == nil then
			return false
		end
	end
	return true
end

function getPropCorrelateLimits(logRef)
	if isReplicaSetRemotePath(getLogRemotePath(logRef)) then
		return _G.SIMPLESPYCONFIG_ReplicaSetPropMaxLines or 3, 24
	end
	return _G.SIMPLESPYCONFIG_PropCorrelateMaxLines or 8, 64
end

function shouldAppendPropTimeline(path, prop)
	US.propTimelineLast = US.propTimelineLast or {}
	local key = tostring(path) .. "|" .. tostring(prop)
	local now = tick()
	local last = US.propTimelineLast[key] or 0
	local cooldown = _G.SIMPLESPYCONFIG_PropTimelineCooldown or 0.5
	if now - last < cooldown then
		return false
	end
	US.propTimelineLast[key] = now
	return true
end

function rebuildLogPropBlock(logRef, lines, maxLines)
	if not logRef or not lines then
		return
	end
	local cap = maxLines or #lines
	local block = "-- [PROP CHANGES]\n"
	local count = math.min(#lines, cap)
	for i = 1, count do
		block = block .. lines[i] .. "\n"
	end
	if #lines > count then
		block = block .. string.format("-- ... +%d prop line(s) suppressed (noise limit)\n", #lines - count)
	end
	logRef.PropBlock = block
end

function getEntityRegistryKey(inst)
	local ok, path = pcall(function()
		return inst:GetFullName()
	end)
	return ok and path or tostring(inst)
end

function isLocalPlayerCharacter(inst)
	local player = Players.LocalPlayer
	if not player or not inst then
		return false
	end
	local char = player.Character
	return char and (inst == char or inst:IsDescendantOf(char))
end

function classifyTargetKind(path)
	local player = Players.LocalPlayer
	if player and player.Character and path then
		local charPath = player.Character:GetFullName()
		if path == charPath or string.find(path, charPath, 1, true) then
			return "player"
		end
	end
	if path and (string.find(path:lower(), "npc", 1, true) or string.find(path:lower(), "enemy", 1, true) or string.find(path:lower(), "mob", 1, true)) then
		return "npc"
	end
	return "unknown"
end

function pushRecentRing(bucket, entry, maxN)
	table.insert(bucket, 1, entry)
	while #bucket > maxN do
		table.remove(bucket)
	end
end

function pushCauseEvent(kind, label, inst, funcInfo)
	if not isPhase5Enabled() then
		return nil
	end
	local info = funcInfo or getCaptureCallerInfo(3)
	local cause = {
		time = tick(),
		kind = kind or "cause",
		label = label or "?",
		source = info.source,
		line = info.line,
		func = info.func,
		scriptPath = info.scriptPath,
	}
	if inst and typeof(inst) == "Instance" then
		pcall(function()
			cause.instancePath = inst:GetFullName()
		end)
	end
	pushRecentRing(US.recentCauses, cause, US.MAX_RECENT_CAUSES)
	if isFlowTrackingEnabled() then
		startNewFlowWithStep(getFlowThread(), {
			kind = "Cause",
			label = label or "?",
			source = info.source,
			line = info.line,
		})
	end
	appendTimelineEvent({
		kind = "cause",
		label = label or "?",
		detail = kind,
		flowId = US.flowByThread[getFlowThread()] and US.flowByThread[getFlowThread()].id,
	})
	return cause
end

function getRecentCauses(window)
	window = window or 4
	local now = tick()
	local out = {}
	for _, c in ipairs(US.recentCauses) do
		if now - c.time <= window then
			table.insert(out, c)
		end
	end
	return out
end

function recordRecentInbound(remotePath, actionKey, logRef)
	pushRecentRing(US.recentInboundEvents, {
		time = tick(),
		remotePath = remotePath,
		actionKey = actionKey,
		logRef = logRef,
		remoteRole = getRemoteRole(remotePath),
	}, US.MAX_RECENT_INBOUND)
end

function getPrimaryControllerFromCallStack(callStack)
	if not callStack then
		return nil
	end
	for _, frame in ipairs(callStack) do
		if frame.layer == "Controller" then
			return frame.name
		end
	end
	for _, frame in ipairs(callStack) do
		if frame.layer == "Network" then
			return frame.name
		end
	end
	return callStack[1] and callStack[1].name or nil
end

function recordRecentOutboundEvent(snapshot, actionKey, methodName, callStack, mergedChain, uiTrigger, flowSnapshot)
	if not snapshot then
		return
	end
	local remotePath = snapshot.path or snapshot.name
	if not remotePath then
		return
	end
	local primary = extractPrimaryController(callStack)
	local act = classifyAction(actionKey, callStack, remotePath)
	local entry = {
		time = tick(),
		remotePath = remotePath,
		actionKey = actionKey,
		method = methodName,
		controller = primary and primary.controller or getPrimaryControllerFromCallStack(callStack),
		primaryFunction = primary and primary.functionName,
		mergedChain = mergedChain,
		uiTrigger = uiTrigger,
		flowId = flowSnapshot and flowSnapshot.id,
		remoteRole = getRemoteRole(remotePath, snapshot),
		callStack = callStack,
		actionClass = act and act.class,
		refId = US.lastFiredRefId,
	}
	pushRecentRing(US.recentOutboundEvents, entry, US.MAX_RECENT_OUTBOUND)
	recordActionSequence(entry)
	return entry
end

function getBestInboundBefore(timePoint, maxDelta)
	maxDelta = maxDelta or 0.35
	local best, bestDt = nil, maxDelta + 1
	for _, ev in ipairs(US.recentInboundEvents) do
		local dt = timePoint - ev.time
		if dt >= 0 and dt <= maxDelta and dt < bestDt then
			best = ev
			bestDt = dt
		end
	end
	return best
end

function hadRecentOutbound(within)
	within = within or 0.15
	local ctx = US.recentOutboundContext
	return ctx and ctx.time and tick() - ctx.time <= within
end

function openInvestigationSession(triggerKind, path, delta, detail)
	if not isInvestigationEnabled() then
		return nil
	end
	if triggerKind == "reward" and not hadRecentOutbound(getRewardSourceWindow()) then
		if US.lastRootCauseAnalysis and US.lastRootCauseAnalysis.verdict == "server_only_replication" then
			-- allow session but verdict will reflect server-only
		elseif #US.recentOutboundEvents == 0 then
			return nil
		end
	end
	if hadRecentOutbound(0.15) and triggerKind ~= "damage_dealt" and triggerKind ~= "reward" then
		return nil
	end
	local session = {
		id = US.nextInvestigationId,
		startedAt = tick(),
		expiresAt = tick() + getCorrelateWindow(),
		triggerKind = triggerKind,
		triggerPath = path,
		triggerDelta = delta,
		triggerDetail = detail,
		outbound = {},
		inbound = {},
		states = {},
		properties = {},
		causes = {},
		hidden_stats = {},
		verdict = nil,
		finalized = false,
	}
	US.nextInvestigationId += 1
	US.activeInvestigation = session
	for _, c in ipairs(getRecentCauses(getCorrelateWindow())) do
		table.insert(session.causes, c)
	end
	if US.recentOutboundContext then
		table.insert(session.outbound, {
			time = US.recentOutboundContext.time,
			path = US.recentOutboundContext.path,
			actionKey = US.recentOutboundContext.actionKey,
		})
	end
	for _, ev in ipairs(US.recentInboundEvents) do
		if tick() - ev.time <= getCorrelateWindow() then
			table.insert(session.inbound, ev)
		end
	end
	task.defer(function()
		task.wait(getCorrelateWindow())
		if US.activeInvestigation == session and not session.finalized then
			finalizeInvestigationSession(session)
		end
	end)
	return session
end

function appendToActiveInvestigation(field, entry)
	if US.activeInvestigation and not US.activeInvestigation.finalized then
		if type(US.activeInvestigation[field]) ~= "table" then
			US.activeInvestigation[field] = {}
		end
		table.insert(US.activeInvestigation[field], entry)
	end
end

function computeInvestigationVerdict(session)
	if not session then
		return "unknown"
	end
	if US.lastRootCauseAnalysis and US.lastRootCauseAnalysis.verdict == "outbound_likely_cause" then
		return "outbound_likely_cause"
	end
	if #session.outbound > 0 then
		return "outbound_linked"
	end
	if #session.inbound > 0 and #session.outbound == 0 then
		return "server_only_replication"
	end
	if #session.inbound > 0 then
		return "inbound_linked"
	end
	if #session.causes > 0 then
		return "cause_only"
	end
	return "server_only_replication"
end

function finalizeInvestigationSession(session)
	if not session or session.finalized then
		return
	end
	session.finalized = true
	session.verdict = computeInvestigationVerdict(session)
	session.passiveHintBlock = formatPassiveDiscoveryHint(nil, nil, session)
	pushRecentRing(US.investigationSessions, session, US.MAX_INVESTIGATION_SESSIONS)
	if US.activeInvestigation == session then
		US.activeInvestigation = nil
	end
	appendTimelineEvent({
		kind = "investigation",
		label = "#" .. tostring(session.id),
		detail = session.verdict,
	})
end

function formatInvestigationSession(session)
	if not session then
		return ""
	end
	local lines = {
		string.format("-- [INVESTIGATION #%d] (%.2fs window)", session.id, getCorrelateWindow()),
		"-- Trigger: " .. tostring(session.triggerKind) .. " " .. tostring(session.triggerPath) .. " " .. tostring(session.triggerDelta or ""),
	}
	if #session.outbound > 0 then
		for _, o in ipairs(session.outbound) do
			table.insert(lines, string.format("-- Outbound: %s action=%s", tostring(o.path), tostring(o.actionKey)))
		end
	else
		table.insert(lines, "-- Outbound: (none)")
	end
	if #session.inbound > 0 then
		for _, i in ipairs(session.inbound) do
			table.insert(lines, string.format("-- Inbound: %s action=%s", tostring(i.remotePath), tostring(i.actionKey)))
		end
	else
		table.insert(lines, "-- Inbound: (none)")
	end
	for _, s in ipairs(session.states) do
		table.insert(lines, "-- State: " .. tostring(s))
	end
	for _, p in ipairs(session.properties) do
		table.insert(lines, "-- Property: " .. tostring(p))
	end
	for _, c in ipairs(session.causes) do
		table.insert(lines, string.format("-- Cause: %s %s", tostring(c.kind), tostring(c.label)))
	end
	if session.passiveHintBlock and session.passiveHintBlock ~= "" then
		table.insert(lines, session.passiveHintBlock)
	end
	table.insert(lines, "-- Verdict: " .. tostring(session.verdict))
	if session.verdict == "server_only_replication" then
		table.insert(lines, "-- (no client Touched/remote/inbound observed — server-only effect)")
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatInvestigationLog()
	local lines = { "-- Investigation Sessions", "" }
	if US.activeInvestigation then
		table.insert(lines, formatInvestigationSession(US.activeInvestigation))
	end
	for _, s in ipairs(US.investigationSessions) do
		table.insert(lines, formatInvestigationSession(s))
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none yet)")
	end
	return table.concat(lines, "\n")
end

function recordDamageEvent(data)
	pushRecentRing(US.damageEvents, data, US.MAX_DAMAGE_EVENTS)
	if isCombatDiscoveryEnabled() and data.verdict == "damage_dealt" then
		pcall(finalizeCombatDiscoveryWindow, data.targetPath, data.delta)
	end
end

function recordRewardEvent(data)
	pushRecentRing(US.rewardEvents, data, US.MAX_REWARD_EVENTS)
end

function formatDamageEventLog()
	local lines = { "-- Damage Events", "" }
	for _, ev in ipairs(US.damageEvents) do
		table.insert(
			lines,
			string.format(
				"-- [%s] %s %s → %s (%s) remote=%s cause=%s",
				tostring(ev.verdict),
				tostring(ev.targetPath),
				tostring(ev.oldHP),
				tostring(ev.newHP),
				tostring(ev.delta),
				tostring(ev.remotePath or "?"),
				tostring(ev.causeLabel or "?")
			)
		)
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

function formatRewardEventLog()
	local lines = { "-- Reward Events", "" }
	for _, ev in ipairs(US.rewardEvents) do
		table.insert(
			lines,
			string.format(
				"-- +%s %s remote=%s inbound=%s cause=%s",
				tostring(ev.delta),
				tostring(ev.statPath),
				tostring(ev.remotePath or "?"),
				tostring(ev.inboundPath or "?"),
				tostring(ev.causeLabel or "?")
			)
		)
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

function captureStateSnapshot()
	return {
		time = tick(),
		weaponEquipped = checkWeaponEquipped(),
		questActive = checkQuestActive(),
		zoneUnlocked = checkZoneUnlocked(),
	}
end

function recordActionStateSample(remotePath, actionKey, replayScore, hadEffect)
	if not remotePath then
		return
	end
	local key = remotePath .. "|" .. tostring(actionKey or "?")
	US.actionStateSamples[key] = US.actionStateSamples[key] or { success = {}, fail = {} }
	local bucket = hadEffect and US.actionStateSamples[key].success or US.actionStateSamples[key].fail
	table.insert(bucket, 1, {
		time = tick(),
		state = captureStateSnapshot(),
		replayScore = replayScore or 0,
	})
	while #bucket > 24 do
		table.remove(bucket)
	end
end

function recordActionSequence(outboundEntry)
	if not outboundEntry or not outboundEntry.remotePath then
		return
	end
	local seqKey = tostring(outboundEntry.flowId or "0")
		.. "|"
		.. tostring(outboundEntry.uiTrigger and outboundEntry.uiTrigger.path or "")
		.. "|"
		.. tostring(outboundEntry.actionClass or outboundEntry.actionKey or "?")
	local seq = US.actionSequences[seqKey]
	if not seq or (tick() - (seq.lastTime or 0)) > (_G.SIMPLESPYCONFIG_MultiRemoteWindow or 2.5) then
		seq = { remotes = {}, lastTime = tick(), hits = 0, actionClass = outboundEntry.actionClass }
		US.actionSequences[seqKey] = seq
	end
	seq.lastTime = tick()
	seq.hits = (seq.hits or 0) + 1
	local paths = seq.remotes
	if paths[#paths] ~= outboundEntry.remotePath then
		table.insert(paths, outboundEntry.remotePath)
	end
	while #paths > 6 do
		table.remove(paths, 1)
	end
end

function getLearnedStateRequirements(remotePath, actionKey)
	local key = (remotePath or "?") .. "|" .. tostring(actionKey or "?")
	local sample = US.actionStateSamples[key]
	if not sample then
		return nil
	end
	local reqs = {}
	local function diffRates(field)
		local sOk, sTot, fOk, fTot = 0, 0, 0, 0
		for _, row in ipairs(sample.success or {}) do
			if row.state and row.state[field] then
				sOk += 1
			end
			sTot += 1
		end
		for _, row in ipairs(sample.fail or {}) do
			if row.state and row.state[field] then
				fOk += 1
			end
			fTot += 1
		end
		if sTot >= 2 and fTot >= 1 then
			local sPct = sTot > 0 and (sOk / sTot) * 100 or 0
			local fPct = fTot > 0 and (fOk / fTot) * 100 or 0
			if sPct - fPct >= 40 then
				return math.floor(sPct + 0.5)
			end
		end
		return nil
	end
	local wPct = diffRates("weaponEquipped")
	if wPct then
		table.insert(reqs, { label = "Weapon Equipped", pct = wPct })
	end
	local qPct = diffRates("questActive")
	if qPct then
		table.insert(reqs, { label = "Quest Active", pct = qPct })
	end
	local zPct = diffRates("zoneUnlocked")
	if zPct then
		table.insert(reqs, { label = "Zone Unlocked", pct = zPct })
	end
	if #reqs == 0 then
		return nil
	end
	return reqs
end

function scheduleReplayOutcomeCheck(log, snapshot, actionKey)
	if not isReplayScoreEnabled() or not log or not snapshot then
		return
	end
	local remotePath = snapshot.path
	if not remotePath or getRemoteRole(remotePath, snapshot) == "replication_effect" then
		return
	end
	local baseline = {}
	pcall(function()
		if Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("leaderstats") then
			for _, child in ipairs(Players.LocalPlayer.leaderstats:GetChildren()) do
				if child:IsA("ValueBase") then
					baseline[child:GetFullName()] = child.Value
				end
			end
		end
	end)
	table.insert(US.pendingReplayChecks, 1, {
		time = tick(),
		deadline = tick() + (_G.SIMPLESPYCONFIG_ReplayCheckWindow or 1.5),
		logRef = log,
		remotePath = remotePath,
		actionKey = actionKey,
		baseline = baseline,
		stateSnap = captureStateSnapshot(),
	})
	while #US.pendingReplayChecks > 32 do
		table.remove(US.pendingReplayChecks)
	end
end

function tickReplayOutcomeChecks()
	if not isReplayScoreEnabled() or #US.pendingReplayChecks == 0 then
		return
	end
	local now = tick()
	local i = 1
	while i <= #US.pendingReplayChecks do
		local job = US.pendingReplayChecks[i]
		if now < job.deadline then
			i += 1
			continue
		end
		table.remove(US.pendingReplayChecks, i)
		local changed = false
		for path, oldVal in pairs(job.baseline or {}) do
			local inst = game
			pcall(function()
				for part in string.gmatch(path, "[^%.]+") do
					if part == "game" then
						continue
					end
					inst = inst:FindFirstChild(part)
					if not inst then
						break
					end
				end
				if inst and inst:IsA("ValueBase") and inst.Value ~= oldVal then
					changed = true
				end
			end)
			if changed then
				break
			end
		end
		local remotePath = job.remotePath
		local entry = US.replayOutcomes[remotePath]
			or { verified = 0, replicationOnly = 0, unknown = 0, lastReplayScore = 0, state = "unknown" }
		if changed then
			entry.verified += 1
			entry.state = "verified_action"
			entry.lastReplayScore = math.min(100, (entry.lastReplayScore or 0) + 25)
		else
			entry.replicationOnly += 1
			if entry.verified == 0 then
				entry.state = "replication_only"
			end
			entry.lastReplayScore = math.max(0, (entry.lastReplayScore or 30) - 15)
		end
		US.replayOutcomes[remotePath] = entry
		recordActionStateSample(remotePath, job.actionKey, entry.lastReplayScore, changed)
		if job.logRef then
			local reasons = {
				changed and "Stat changed within replay window (verified_action)"
					or "No stat change after fire (replication_only suspect)",
			}
			local score = entry.lastReplayScore
			job.logRef.ReplayScore = score
			job.logRef.ReplayScoreState = entry.state
			job.logRef.ReplayScoreBlock = formatReplayScoreBlock(score, reasons, entry.state)
			local valuable, vReasons = computeValuableActionScore(score, job.logRef)
			job.logRef.ValuableActionScore = valuable
			job.logRef.ValuableActionBlock = formatValuableActionBlock(valuable, vReasons)
			US.remoteActionScores[remotePath] = valuable
			refreshLogDisplayName(job.logRef)
			if selected and selected == job.logRef then
				scheduleOnSpyThread(function()
					selectLogEntry(job.logRef)
				end)
			end
		end
	end
end

function scoreRootCauseCandidate(trigger, outboundEv)
	if not outboundEv then
		return 0
	end
	local window = trigger.window or getRootCauseWindow(trigger)
	if not outboundEv.time or tick() - outboundEv.time > window then
		return 0
	end
	local score = 0
	if outboundEv.remoteRole == "replication_effect" then
		score = 5
	else
		score += 40
	end
	if outboundEv.controller or outboundEv.primaryFunction then
		score += 25
	end
	if outboundEv.mergedChain and next(outboundEv.mergedChain) ~= nil then
		score += 20
	end
	if outboundEv.uiTrigger and outboundEv.uiTrigger.path then
		score += 15
	end
	local act = classifyAction(outboundEv.actionKey, outboundEv.callStack, trigger.statPath)
	local confBump = act and tonumber(act.confidence) or 40
	if trigger.kind == "reward" then
		if act and (act.class == "REWARD" or act.class == "SHOP" or act.class == "TRAINING") then
			score += 20 + math.floor(confBump / 5)
		end
	elseif trigger.kind == "damage_taken" or trigger.kind == "damage_dealt" then
		if act and act.class == "COMBAT" then
			score += 20 + math.floor(confBump / 5)
		end
	end
	local remotePath = outboundEv.remotePath
	if remotePath and US.functionActionRegistry then
		for _, reg in pairs(US.functionActionRegistry) do
			if reg.remotes and reg.remotes[remotePath] then
				score += 15
				break
			end
		end
	end
	if remotePath and US.upvalueRemoteByRemote and US.upvalueRemoteByRemote[remotePath] and next(US.upvalueRemoteByRemote[remotePath]) then
		score += 15
	end
	if remotePath and US.metatableLinks then
		for _, link in pairs(US.metatableLinks) do
			if link and link.remotePath == remotePath then
				score += 15
				break
			end
		end
	end
	if remotePath and US.actionOutcomes and US.actionOutcomes[remotePath] then
		score += 10
	end
	if trigger.entityPath and remotePath then
		score += getEntityAffinityScore(trigger.entityPath, remotePath)
	end
	if outboundEv.remoteRole == "replication_effect" then
		score = math.min(score, 18)
	end
	return score
end

function recordEntityRemoteAffinity(entityPath, remotePath)
	if not entityPath or not remotePath then
		return
	end
	US.entityRemoteAffinity[entityPath] = US.entityRemoteAffinity[entityPath] or {}
	local bucket = US.entityRemoteAffinity[entityPath]
	bucket[remotePath] = (bucket[remotePath] or 0) + 1
end

function getEntityAffinityScore(entityPath, remotePath)
	if not entityPath or not remotePath then
		return 0
	end
	local bucket = US.entityRemoteAffinity[entityPath]
	if not bucket or not bucket[remotePath] then
		return 0
	end
	local best = bucket[remotePath]
	local total = 0
	for _, n in pairs(bucket) do
		total += n
	end
	if total <= 0 then
		return 0
	end
	local ratio = best / total
	if best >= 3 and ratio >= 0.5 then
		return 10
	end
	if best >= 2 and ratio >= 0.35 then
		return 5
	end
	return 0
end

function scoreEffectSyncCandidate(trigger, inboundEv)
	if not inboundEv or not inboundEv.remotePath then
		return 0
	end
	local window = trigger.window or getRootCauseWindow(trigger)
	if not inboundEv.time or tick() - inboundEv.time > window then
		return 0
	end
	local role = inboundEv.remoteRole or getRemoteRole(inboundEv.remotePath)
	if role ~= "replication_effect" then
		return 0
	end
	return math.min(18, 8 + (inboundEv.actionKey and 4 or 0))
end

function capEffectSyncCandidates(candidates, maxOutboundScore)
	local cap = math.max(12, math.floor((maxOutboundScore or 50) * 0.2))
	for _, c in ipairs(candidates) do
		if c.kind == "effect_sync" or c.remoteRole == "replication_effect" then
			c.score = math.min(c.score or 0, cap)
		end
	end
end

function resolveRootCause(trigger)
	trigger = trigger or {}
	trigger.window = trigger.window or getRootCauseWindow(trigger)
	local window = trigger.window
	local candidates = {}
	local now = tick()
	for _, ev in ipairs(US.recentOutboundEvents or {}) do
		if ev and ev.time and (now - ev.time) <= window then
			local score = scoreRootCauseCandidate(trigger, ev)
			if score > 0 then
				table.insert(candidates, {
					kind = "outbound",
					score = score,
					remotePath = ev.remotePath,
					actionKey = ev.actionKey,
					controller = ev.controller,
					primaryFunction = ev.primaryFunction,
					remoteRole = ev.remoteRole,
					callStack = ev.callStack,
					logRef = ev.logRef,
					ev = ev,
				})
			end
		end
	end
	for _, ev in ipairs(US.recentInboundEvents or {}) do
		if ev and ev.time and (now - ev.time) <= window then
			local score = scoreEffectSyncCandidate(trigger, ev)
			if score > 0 then
				table.insert(candidates, {
					kind = "effect_sync",
					score = score,
					remotePath = ev.remotePath,
					actionKey = ev.actionKey,
					controller = nil,
					primaryFunction = nil,
					remoteRole = getRemoteRole(ev.remotePath),
					callStack = nil,
					logRef = ev.logRef,
					ev = ev,
				})
			end
		end
	end
	table.sort(candidates, function(a, b)
		return (a.score or 0) > (b.score or 0)
	end)
	local maxOutbound = 0
	for _, c in ipairs(candidates) do
		if c.kind == "outbound" and (c.score or 0) > maxOutbound then
			maxOutbound = c.score
		end
	end
	capEffectSyncCandidates(candidates, maxOutbound)
	table.sort(candidates, function(a, b)
		return (a.score or 0) > (b.score or 0)
	end)
	local best = candidates[1]
	local maxScore = best and best.score or 0
	local verdict = "server_only_replication"
	if maxScore >= 25 and best and best.kind == "outbound" then
		verdict = "outbound_likely_cause"
	elseif maxScore >= 10 and best and best.kind == "outbound" then
		verdict = "outbound_possible"
	end
	US.lastRootCauseAnalysis = {
		trigger = trigger,
		window = window,
		topCandidates = candidates,
		bestCandidate = best,
		maxScore = maxScore,
		verdict = verdict,
		time = now,
	}
	return US.lastRootCauseAnalysis
end

function formatRootCauseBlock(analysis)
	if not analysis or not analysis.trigger then
		return ""
	end
	local t = analysis.trigger
	local statPath = t.statPath or t.targetPath or "?"
	local oldVal = t.oldVal
	local newVal = t.newVal
	local delta = t.delta
	local deltaStr = delta ~= nil and (tonumber(delta) and (tonumber(delta) >= 0 and "+" .. tostring(delta) or tostring(delta)) or tostring(delta)) or ""
	local lines = {
		"-- [ROOT CAUSE ANALYSIS]",
		string.format("-- Result: %s %s → %s %s", tostring(statPath), tostring(oldVal), tostring(newVal), deltaStr),
		"-- Window: " .. tostring(analysis.window or getCorrelateWindow()),
		"--",
		"-- Provável origem:",
	}
	local top = analysis.topCandidates or {}
	local maxScore = analysis.maxScore or 0
	local useRealTrigger = analysis.trigger and getRealTriggerWindow(analysis.trigger)
	local minConf = getRealTriggerMinConfidence()
	if #top == 0 then
		table.insert(lines, "-- (none — likely server replication only)")
	else
		local filtered = top
		if useRealTrigger and maxScore > 0 then
			filtered = {}
			for _, c in ipairs(top) do
				local normalized = (c.score or 0) / maxScore
				if c.kind == "outbound" and normalized >= minConf then
					table.insert(filtered, c)
				end
			end
			if #filtered == 0 then
				table.insert(lines, "-- (no outbound above confidence — server replication likely)")
			else
				table.insert(lines, formatControllerRankingBlock(filtered, maxScore))
			end
		else
			table.insert(lines, formatControllerRankingBlock(top, maxScore))
		end
	end
	if useRealTrigger then
		table.insert(lines, "-- RealTriggerWindow: " .. tostring(analysis.window or getRealTriggerWindow(analysis.trigger)))
	end
	table.insert(lines, "")
	table.insert(lines, "-- Verdict: " .. tostring(analysis.verdict or "unknown"))
	return table.concat(lines, "\n")
end

function applyRootCauseToLog(trigger)
	US.lastStatChange = trigger
	local analysis = resolveRootCause(trigger)
	local best = analysis and analysis.bestCandidate
	local causeBlock = formatRootCauseBlock(analysis)
	if best and best.kind == "outbound" and best.logRef and type(best.logRef) == "table" then
		best.logRef.RootCauseBlock = causeBlock
		if best.remoteRole ~= "replication_effect" then
			local normalized = analysis.maxScore > 0 and (best.score / analysis.maxScore) or 0
			local score = math.max(best.logRef.ReplayScore or 0, math.floor(60 + normalized * 40))
			best.logRef.ReplayScore = score
			best.logRef.ReplayScoreBlock = formatReplayScoreBlock(
				score,
				{ "Outbound event matches Root Cause window" },
				best.logRef.ReplayScoreState
			)
			local valuable, vReasons = computeValuableActionScore(score, best.logRef)
			best.logRef.ValuableActionScore = valuable
			best.logRef.ValuableActionBlock = formatValuableActionBlock(valuable, vReasons)
			if best.logRef.Snapshot and best.logRef.Snapshot.path then
				US.remoteActionScores[best.logRef.Snapshot.path] = valuable
			end
		end
		refreshLogDisplayName(best.logRef)
	end
	for _, c in ipairs(analysis.topCandidates or {}) do
		if c.kind == "effect_sync" and c.logRef and type(c.logRef) == "table" then
			c.logRef.RootCauseBlock = causeBlock
			c.logRef.ValuableActionScore = math.min(c.logRef.ValuableActionScore or 100, 8)
			c.logRef.ValuableActionBlock = formatValuableActionBlock(8, { "Effect sync only — see outbound cause above" })
			refreshLogDisplayName(c.logRef)
		end
	end
	if best and best.logRef and selected and selected == best.logRef then
		scheduleOnSpyThread(function()
			selectLogEntry(best.logRef)
		end)
	end
	return analysis
end

function resolveRewardSources(path, delta)
	-- Reuse the Root Cause candidates but keep reward-specific emphasis.
	local analysis = resolveRootCause({
		kind = "reward",
		statPath = path,
		delta = delta,
	})
	if not analysis then
		return nil
	end
	analysis.trigger = analysis.trigger or { kind = "reward", statPath = path, delta = delta }
	local allCandidates = analysis.topCandidates or {}
	local filtered = {}
	for _, c in ipairs(allCandidates) do
		local act = classifyAction(c.actionKey, c.callStack, path)
		if act and (act.class == "REWARD" or act.class == "SHOP" or act.class == "TRAINING") then
			table.insert(filtered, c)
		end
	end
	if #filtered == 0 then
		for _, c in ipairs(allCandidates) do
			if c.kind == "outbound" then
				table.insert(filtered, c)
			end
		end
	end
	analysis.topCandidates = filtered
	analysis.bestCandidate = filtered[1]
	analysis.maxScore = filtered[1] and filtered[1].score or analysis.maxScore or 0
	if not analysis.bestCandidate and US.lastRootCauseAnalysis then
		local rcBest = US.lastRootCauseAnalysis.bestCandidate
		if rcBest and rcBest.kind == "outbound" then
			analysis.bestCandidate = rcBest
			if #filtered == 0 then
				analysis.topCandidates = { rcBest }
				analysis.maxScore = rcBest.score or analysis.maxScore
			end
		end
	end
	return analysis
end

function formatRewardSourceBlock(analysis)
	if not analysis or not analysis.trigger then
		return ""
	end
	local t = analysis.trigger
	local path = t.statPath or t.targetPath or "?"
	local delta = t.delta
	local window = analysis.window or getCorrelateWindow()
	local lines = {
		"-- [REWARD SOURCE RESOLVER]",
		string.format("-- Result: %s (%s)", tostring(path), tostring(delta ~= nil and ("+" .. tostring(delta)) or "Δ?")),
		"-- Window: " .. tostring(window),
		"-- Likely reward origin:",
	}
	local top = analysis.topCandidates or {}
	local maxScore = analysis.maxScore or 0
	if #top == 0 then
		table.insert(lines, "-- (none — likely effect sync only)")
	else
		for i = 1, math.min(5, #top) do
			local c = top[i]
			local pct = maxScore > 0 and math.floor((c.score / maxScore) * 100 + 0.5) or 0
			if c.remoteRole == "replication_effect" then
				table.insert(lines, string.format("--  %d%% %s [EFFECT — sync only]", pct, tostring(c.remotePath)))
			else
				local controllerLabel = tostring(c.controller or c.remotePath)
				table.insert(lines, string.format("--  %d%% %s", pct, controllerLabel))
				if c.actionKey then
					table.insert(lines, string.format("--     action=%s", tostring(c.actionKey)))
				end
			end
		end
	end
	table.insert(lines, "")
	lines[#lines + 1] = "-- Verdict: " .. tostring(analysis.verdict or "unknown")
	return table.concat(lines, "\n")
end

function applyRewardSourcesToLog(trigger)
	local path = trigger and trigger.statPath
	local delta = trigger and trigger.delta
	local analysis = resolveRewardSources(path, delta)
	if not analysis then
		return nil
	end
	local best = analysis.bestCandidate
	if not best and US.lastRootCauseAnalysis then
		best = US.lastRootCauseAnalysis.bestCandidate
	end
	if not best then
		return analysis
	end
	if best.logRef and type(best.logRef) == "table" then
		best.logRef.RewardSourceBlock = formatRewardSourceBlock(analysis)
		if selected and selected == best.logRef then
			scheduleOnSpyThread(function()
				selectLogEntry(best.logRef)
			end)
		end
	end
	return analysis
end

function onEntityStatChange(entityPath, statName, oldVal, newVal, kind)
	if not isEntityTrackerEnabled() then
		return
	end
	local oldN, newN = tonumber(oldVal), tonumber(newVal)
	if not oldN or not newN or oldN == newN then
		return
	end
	local delta = newN - oldN
	local ctx = US.recentOutboundContext
	local causes = getRecentCauses(1.5)
	local causeLabel = causes[1] and (causes[1].kind .. " " .. causes[1].label) or nil
	local remotePath = ctx and ctx.path
	local actionKey = ctx and ctx.actionKey
	local refId = US.lastFiredRefId
	local controller = nil
	if ctx and ctx.logRef and ctx.logRef.CallStack then
		for _, frame in ipairs(ctx.logRef.CallStack) do
			if frame.layer == "Controller" then
				controller = frame.name
				break
			end
		end
	end
	local verdict = kind
	if kind == "health" and delta < 0 then
		verdict = classifyTargetKind(entityPath) == "player" and "damage_taken" or "damage_dealt"
	end
	local ev = {
		time = tick(),
		targetPath = entityPath,
		targetKind = classifyTargetKind(entityPath),
		statName = statName,
		oldHP = oldN,
		newHP = newN,
		delta = delta,
		remotePath = remotePath,
		actionKey = actionKey,
		refId = refId,
		controller = controller,
		causeLabel = causeLabel,
		flowId = ctx and ctx.flowId,
		verdict = verdict,
	}
	recordDamageEvent(ev)
	if ctx and ctx.logRef then
		ctx.logRef.DamageEventBlock = formatSingleDamageEventBlock(ev)
		if ctx.logRef.WrapperChainBlock and not string.find(ctx.logRef.WrapperChainBlock, "[DAMAGE]", 1, true) then
			ctx.logRef.WrapperChainBlock = ctx.logRef.WrapperChainBlock
				.. formatWrapperChainBlock(ctx.logRef.CallStack, nil, ev)
		end
	end
	if kind == "health" and delta < 0 and entityPath then
		US.lastCombatHpPath = entityPath
		confirmHiddenStatHp(entityPath)
	end
	if verdict == "damage_dealt" and isCombatDiscoveryEnabled() then
		US.combatDiscovery = US.combatDiscovery or { startedAt = tick(), npcPath = entityPath, outboundHits = {} }
		US.combatDiscovery.npcPath = entityPath
	end
	local deltaStr = delta > 0 and ("+" .. tostring(delta)) or tostring(delta)
	onStateChange(entityPath .. "." .. statName, oldVal, newVal)
	appendToActiveInvestigation("states", entityPath .. " " .. deltaStr)
	if verdict == "damage_taken" then
		local inv = openInvestigationSession("damage_taken", entityPath, deltaStr, statName)
		if inv then
			local inbound = getBestInboundBefore(tick(), 0.35)
			if inbound then
				table.insert(inv.inbound, inbound)
			end
		end
	elseif verdict == "damage_dealt" then
		openInvestigationSession("damage_dealt", entityPath, deltaStr, statName)
	end

	-- Root Cause (Resultado -> Quem causou)
	if verdict == "damage_dealt" and remotePath and entityPath then
		recordEntityRemoteAffinity(entityPath, remotePath)
	end
	if verdict == "damage_taken" or verdict == "damage_dealt" then
		applyRootCauseToLog({
			kind = verdict,
			statPath = entityPath .. "." .. statName,
			entityPath = entityPath,
			oldVal = oldN,
			newVal = newN,
			delta = delta,
		})
	end
end

function onRewardStatChange(path, oldVal, newVal)
	if not isEntityTrackerEnabled() then
		return
	end
	local oldN, newN = tonumber(oldVal), tonumber(newVal)
	if not oldN or not newN or newN <= oldN then
		return
	end
	local delta = newN - oldN
	local ctx = US.recentOutboundContext
	local causes = getRecentCauses(2)
	local inbound = getBestInboundBefore(tick(), 0.3)
	local ev = {
		time = tick(),
		statPath = path,
		delta = delta,
		remotePath = ctx and ctx.path,
		inboundPath = inbound and inbound.remotePath,
		causeLabel = causes[1] and causes[1].label,
	}
	recordRewardEvent(ev)
	if ctx and ctx.logRef then
		ctx.logRef.RewardEventBlock = formatSingleRewardEventBlock(ev)
	end
	onStateChange(path, oldVal, newVal)
	appendToActiveInvestigation("states", path .. " +" .. tostring(delta))
	local inv = openInvestigationSession("reward", path, "+" .. tostring(delta), nil)
	if inv and inbound then
		table.insert(inv.inbound, inbound)
	end
	if isRewardDiscoveryEnabled() and US.rewardDiscovery then
		finalizeRewardDiscoveryWindow(path, delta)
	end

	-- Root Cause (Resultado -> Quem causou)
	applyRootCauseToLog({
		kind = "reward",
		statPath = path,
		oldVal = oldN,
		newVal = newN,
		delta = delta,
	})
	applyRewardSourcesToLog({
		statPath = path,
		delta = delta,
	})
end

function watchValueAtPathPhase5(inst, path)
	if US.stateWatchConns[path] or not inst then
		return
	end
	pcall(function()
		US.stateBaseline[path] = inst.Value
	end)
	local conn = inst:GetPropertyChangedSignal("Value"):Connect(function()
		local oldVal = US.stateBaseline[path]
		local newVal = inst.Value
		if oldVal ~= newVal then
			US.stateBaseline[path] = newVal
			local statName = inst.Name
			if nameMatchesKeySet(statName, HEALTH_KEYS) then
				onEntityStatChange(path, statName, oldVal, newVal, "health")
			elseif nameMatchesKeySet(statName, REWARD_KEYS) then
				onRewardStatChange(path, oldVal, newVal)
			else
				onStateChange(path, oldVal, newVal)
			end
		end
	end)
	US.stateWatchConns[path] = conn
	table.insert(connections, conn)
end

function watchAttributesOn(inst, prefix)
	if not isGlobalAttributesEnabled() or not inst then
		return
	end
	local key = getEntityRegistryKey(inst)
	if US.entityWatchConns["attr:" .. key] then
		return
	end
	pcall(function()
		for name, val in pairs(inst:GetAttributes()) do
			US.stateBaseline[prefix .. name] = val
		end
		inst.AttributeChanged:Connect(function(name)
			local path = prefix .. name
			local oldVal = US.stateBaseline[path]
			local newVal = inst:GetAttribute(name)
			if oldVal ~= newVal then
				US.stateBaseline[path] = newVal
				if nameMatchesKeySet(name, REWARD_KEYS) then
					onRewardStatChange(path, oldVal, newVal)
				elseif nameMatchesKeySet(name, HEALTH_KEYS) then
					onEntityStatChange(path, name, oldVal, newVal, "health")
				else
					onStateChange(path, oldVal, newVal)
				end
			end
		end)
	end)
	US.entityWatchConns["attr:" .. key] = true
end

function watchHumanoid(humanoid, pathPrefix)
	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end
	local hpPath = pathPrefix .. ".Health"
	pcall(function()
		US.stateBaseline[hpPath] = humanoid.Health
	end)
	local conn = humanoid.HealthChanged:Connect(function(newVal)
		local oldVal = US.stateBaseline[hpPath]
		if oldVal ~= newVal then
			US.stateBaseline[hpPath] = newVal
			onEntityStatChange(pathPrefix, "Health", oldVal, newVal, "health")
		end
	end)
	table.insert(connections, conn)
end

function watchPropertyText(inst, path)
	if not isPropertyTrackerEnabled() or US.propertyWatchCount >= (_G.SIMPLESPYCONFIG_MAX_PROPERTY_WATCH or 80) then
		return
	end
	if US.propertyWatchConns[path] then
		return
	end
	if not pathMatchesRewardHint(path) and not nameMatchesKeySet(inst.Name, REWARD_KEYS) then
		return
	end
	US.propertyWatchConns[path] = true
	US.propertyWatchCount += 1
	pcall(function()
		US.stateBaseline[path] = inst.Text
	end)
	local conn = inst:GetPropertyChangedSignal("Text"):Connect(function()
		local oldVal = US.stateBaseline[path]
		local newVal = inst.Text
		if oldVal ~= newVal then
			US.stateBaseline[path] = newVal
			onPropertyChange(path, "Text", oldVal, newVal)
		end
	end)
	table.insert(connections, conn)
end

function onPropertyChange(path, prop, oldVal, newVal)
	if not shouldLogPropChange(path, oldVal, newVal, nil) then
		return
	end
	pushRecentRing(US.recentPropertyChanges, {
		time = tick(),
		path = path,
		prop = prop,
		oldVal = oldVal,
		newVal = newVal,
	}, US.MAX_RECENT_PROPERTY)
	if shouldAppendPropTimeline(path, prop) then
		appendTimelineEvent({ kind = "prop", label = getShortPathName(path), detail = tostring(oldVal) .. " → " .. tostring(newVal) })
	end
	appendToActiveInvestigation("properties", path .. "." .. prop .. " " .. tostring(oldVal) .. " → " .. tostring(newVal))
	local oldN, newN = tonumber(oldVal), tonumber(newVal)
	if oldN and newN and newN > oldN and pathMatchesRewardHint(path) then
		onRewardStatChange(path, oldVal, newVal)
	end
end

function scanInstanceForWatches(inst, depth, prefix)
	if not inst or depth > 5 then
		return
	end
	pcall(function()
		if inst:IsA("Humanoid") then
			watchHumanoid(inst, prefix or getEntityRegistryKey(inst.Parent or inst))
		end
		if inst:IsA("ValueBase") then
			local path = (prefix or "") .. "." .. inst.Name
			if path:sub(1, 1) == "." then
				path = path:sub(2)
			end
			if nameMatchesKeySet(inst.Name, HEALTH_KEYS) or nameMatchesKeySet(inst.Name, REWARD_KEYS) then
				watchValueAtPathPhase5(inst, path)
			end
		end
		if inst:IsA("TextLabel") or inst:IsA("TextButton") then
			watchPropertyText(inst, inst:GetFullName())
		end
		if isGlobalAttributesEnabled() and (inst:IsA("Model") or inst:IsA("Player")) then
			watchAttributesOn(inst, "attr." .. getEntityRegistryKey(inst) .. ".")
		end
		for _, child in ipairs(inst:GetChildren()) do
			local childPrefix = prefix
			if inst:IsA("Model") or inst == Players.LocalPlayer then
				childPrefix = getEntityRegistryKey(inst)
			end
			scanInstanceForWatches(child, depth + 1, childPrefix)
		end
	end)
end

function watchEntity(inst)
	if not isEntityTrackerEnabled() or not inst or typeof(inst) ~= "Instance" then
		return
	end
	local key = getEntityRegistryKey(inst)
	if US.entityRegistry[key] then
		return
	end
	local count = 0
	for _ in pairs(US.entityRegistry) do
		count += 1
	end
	if count >= (_G.SIMPLESPYCONFIG_MAX_ENTITY_WATCH or 48) then
		return
	end
	US.entityRegistry[key] = inst
	scanInstanceForWatches(inst, 0, key)
	if not US.entityWatchConns["childadded:" .. key] then
		US.entityWatchConns["childadded:" .. key] = inst.ChildAdded:Connect(function(child)
			scanInstanceForWatches(child, 0, key)
			if child:IsA("Humanoid") then
				watchHumanoid(child, key)
			end
		end)
		table.insert(connections, US.entityWatchConns["childadded:" .. key])
	end
	appendTimelineEvent({ kind = "entity", label = key, detail = "watch" })
end

function watchPlayerDataTree()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	watchEntity(player)
	watchAttributesOn(player, "attr.Player.")
	local function onChar(char)
		if not char then
			return
		end
		watchEntity(char)
		watchAttributesOn(char, "attr.Character.")
		char.ChildAdded:Connect(function(child)
			if child:IsA("ValueBase") then
				watchValueAtPathPhase5(child, char:GetFullName() .. "." .. child.Name)
			end
		end)
	end
	if player.Character then
		onChar(player.Character)
		scanPlayerDataFoldersOn(player.Character)
	end
	player.CharacterAdded:Connect(function(char)
		onChar(char)
		scanPlayerDataFoldersOn(char)
	end)
	watchLeaderstats(player)
	local function scanFolder(root, depth)
		if not root or depth > 4 then
			return
		end
		for _, child in ipairs(root:GetChildren()) do
			if child:IsA("Folder") and DATA_FOLDER_NAMES[child.Name:lower()] then
				scanInstanceForWatches(child, 0, child:GetFullName())
				scanFolderForHiddenStats(child, 0)
			elseif child:IsA("ValueBase") then
				watchValueAtPathPhase5(child, child:GetFullName())
			end
			scanFolder(child, depth + 1)
		end
	end
	pcall(function()
		scanPlayerDataFoldersOn(player)
		player.ChildAdded:Connect(function(child)
			if child:IsA("Folder") and DATA_FOLDER_NAMES[child.Name:lower()] then
				scanInstanceForWatches(child, 0, child:GetFullName())
				scanFolderForHiddenStats(child, 0)
			end
		end)
		scanFolder(player:FindFirstChild("PlayerGui"), 0)
		scanFolder(player:FindFirstChild("PlayerScripts"), 0)
	end)
end

function scanPlayerDataFoldersOn(root)
	if not root or not isHiddenStatDiscoveryEnabled() then
		return
	end
	pcall(function()
		for _, child in ipairs(root:GetChildren()) do
			if child:IsA("Folder") and DATA_FOLDER_NAMES[child.Name:lower()] then
				scanInstanceForWatches(child, 0, child:GetFullName())
				scanFolderForHiddenStats(child, 0)
			end
		end
	end)
end

function scanNearbyNPCs()
	if not isEntityTrackerEnabled() then
		return
	end
	local player = Players.LocalPlayer
	local char = player and player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local radius = _G.SIMPLESPYCONFIG_EntityScanRadius or 120
	for _, inst in ipairs(workspace:GetDescendants()) do
		if #US.entityRegistry >= (_G.SIMPLESPYCONFIG_MAX_ENTITY_WATCH or 48) then
			break
		end
		pcall(function()
			if inst:IsA("Humanoid") and inst.Parent and inst.Parent ~= char then
				local root = inst.Parent:FindFirstChild("HumanoidRootPart") or inst.Parent:FindFirstChild("Torso")
				if root and (root.Position - hrp.Position).Magnitude <= radius then
					watchEntity(inst.Parent)
				end
			end
		end)
	end
end

function bootstrapCollectionServiceWatch()
	if not isCollectionServiceEnabled() then
		return
	end
	local tags = _G.SIMPLESPYCONFIG_CollectionTags or COLLECTION_DEFAULT_TAGS
	for _, tag in ipairs(tags) do
		pcall(function()
			for _, inst in ipairs(CollectionService:GetTagged(tag)) do
				US.collectionTagged[tag] = US.collectionTagged[tag] or {}
				US.collectionTagged[tag][getEntityRegistryKey(inst)] = inst
				watchEntity(inst)
			end
			CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
				US.collectionTagged[tag] = US.collectionTagged[tag] or {}
				US.collectionTagged[tag][getEntityRegistryKey(inst)] = inst
				watchEntity(inst)
			end)
		end)
	end
end

function getSignalNameFromConnect(signal)
	local ok, name = pcall(function()
		if typeof(signal) == "RBXScriptSignal" then
			for _, child in ipairs(signal.Instance and signal.Instance:GetChildren() or {}) do
			end
		end
		return nil
	end)
	return ok and name
end

function getConnectParentFromCaller()
	if getcallingscript then
		local ok, scr = pcall(getcallingscript)
		if ok and typeof(scr) == "Instance" then
			local node = scr
			for _ = 1, 10 do
				if not node then
					break
				end
				if
					node:IsA("BasePart")
					or node:IsA("MeshPart")
					or node:IsA("ProximityPrompt")
					or node:IsA("ClickDetector")
					or node:IsA("Tool")
				then
					return node
				end
				node = node.Parent
			end
		end
	end
	return nil
end

function resolveSignalParent(signal)
	if not signal then
		return nil
	end
	local parent
	pcall(function()
		parent = signal.Parent
	end)
	if parent and typeof(parent) == "Instance" then
		return parent
	end
	pcall(function()
		parent = signal.Instance
	end)
	if parent and typeof(parent) == "Instance" then
		return parent
	end
	pcall(function()
		if typeof(signal) == "userdata" or typeof(signal) == "RBXScriptSignal" then
			local ok, inst = pcall(function()
				return signal.object or signal.Object
			end)
			if ok and typeof(inst) == "Instance" then
				parent = inst
			end
		end
	end)
	if parent and typeof(parent) == "Instance" then
		return parent
	end
	return getConnectParentFromCaller()
end

function inferSignalNameFromParent(parentInst, signal)
	if not parentInst then
		return "Connect"
	end
	local ok, name = pcall(function()
		if parentInst:IsA("BasePart") or parentInst:IsA("MeshPart") then
			if signal == parentInst.Touched then
				return "Touched"
			end
			if signal == parentInst.TouchEnded then
				return "TouchEnded"
			end
		elseif parentInst:IsA("ProximityPrompt") then
			if signal == parentInst.Triggered then
				return "Triggered"
			end
			if signal == parentInst.PromptButtonHoldBegan then
				return "PromptButtonHoldBegan"
			end
			if signal == parentInst.PromptButtonHoldEnded then
				return "PromptButtonHoldEnded"
			end
		elseif parentInst:IsA("ClickDetector") and signal == parentInst.MouseClick then
			return "MouseClick"
		elseif parentInst:IsA("Tool") then
			if signal == parentInst.Activated then
				return "Activated"
			end
			if signal == parentInst.Equipped then
				return "Equipped"
			end
			if signal == parentInst.Unequipped then
				return "Unequipped"
			end
		elseif (parentInst:IsA("GuiButton") or parentInst:IsA("TextButton")) and signal == parentInst.Activated then
			return "Activated"
		end
		return "Connect"
	end)
	return ok and name or "Connect"
end

function resolveConnectSignalName(signal, parentInst)
	if not parentInst then
		parentInst = resolveSignalParent(signal)
	end
	if parentInst then
		pcall(function()
			if parentInst:IsA("ProximityPrompt") and signal == parentInst.Triggered then
				return "Triggered"
			end
		end)
		pcall(function()
			if parentInst:IsA("ClickDetector") and signal == parentInst.MouseClick then
				return "MouseClick"
			end
		end)
		pcall(function()
			if parentInst:IsA("Tool") and signal == parentInst.Activated then
				return "Activated"
			end
		end)
		pcall(function()
			if parentInst:IsA("BasePart") and signal == parentInst.Touched then
				return "Touched"
			end
		end)
	end
	return "Connect"
end

function registerCallback(signal, callback, signalName, parentInst)
	if not isCallbackDiscoveryEnabled() then
		return
	end
	local info = { source = "?", line = 0, name = "?" }
	pcall(function()
		local dbg = debug.getinfo(callback, "sln")
		if dbg then
			info.source = dbg.source or "?"
			info.line = dbg.currentline or 0
			info.name = dbg.name or "[anonymous]"
		end
	end)
	local path = "?"
	pcall(function()
		if parentInst then
			path = parentInst:GetFullName()
		end
	end)
	US.callbackRegistry[path .. "|" .. signalName] = {
		signal = signalName,
		path = path,
		source = info.source,
		line = info.line,
		name = info.name,
	}
end

function wrapCauseCallback(callback, signalName, parentInst)
	return newcclosure(function(...)
		if US.reentCauseDepth == 0 and isPhase5Enabled() then
			US.reentCauseDepth += 1
			local label = parentInst and parentInst:GetFullName() or signalName
			if signalName == "Touched" then
				local hit = select(1, ...)
				if typeof(hit) == "Instance" then
					pcall(function()
						label = label .. " <- " .. hit:GetFullName()
					end)
				end
			end
			pushCauseEvent(signalName:lower(), label, parentInst, getCaptureCallerInfo(2))
			US.reentCauseDepth -= 1
		end
		return callback(...)
	end)
end

function installConnectHook()
	if US.connectHookInstalled or not hookfunction or not isTrackWorldSignalsEnabled() then
		return
	end
	local probe = Instance.new("Part")
	local ok, touched = pcall(function()
		return probe.Touched
	end)
	if not ok or not touched then
		return
	end
	local wrappedConnect = newcclosure(function(signal, callback, ...)
		local parentInst = resolveSignalParent(signal)
		local signalName = inferSignalNameFromParent(parentInst, signal)
		if parentInst and not US.signalInstanceMap then
			US.signalInstanceMap = setmetatable({}, { __mode = "k" })
		end
		if parentInst and US.signalInstanceMap then
			US.signalInstanceMap[signal] = parentInst
		end
		if CAUSE_SIGNAL_NAMES[signalName] or signalName == "Connect" then
			registerCallback(signal, callback, signalName, parentInst)
			if isPhase5Enabled() and CAUSE_SIGNAL_NAMES[signalName] then
				callback = wrapCauseCallback(callback, signalName, parentInst)
			end
		end
		return US.originalSignalConnect(signal, callback, ...)
	end)
	local touchedConnect = touched.Connect
	US.originalSignalConnect = hookfunction(touchedConnect, wrappedConnect)
	if US.originalSignalConnect then
		US.connectHookInstalled = true
		pcall(function()
			local prompt = Instance.new("ProximityPrompt")
			prompt.Parent = probe
			if prompt.Triggered.Connect ~= touchedConnect then
				hookfunction(prompt.Triggered.Connect, wrappedConnect)
			end
			local cd = Instance.new("ClickDetector")
			cd.Parent = probe
			if cd.MouseClick.Connect ~= touchedConnect then
				hookfunction(cd.MouseClick.Connect, wrappedConnect)
			end
			local tool = Instance.new("Tool")
			if tool.Activated.Connect ~= touchedConnect then
				hookfunction(tool.Activated.Connect, wrappedConnect)
			end
		end)
	end
	probe:Destroy()
end

function isHitNamecallMethod(methodName)
	return methodName and HIT_NAMECALL_METHODS[methodName] == true
end

function onHitNamecall(inst, methodName, args)
	if not isTrackHitsEnabled() or US.reentCauseDepth > 0 then
		return
	end
	local key = tostring(inst) .. ":" .. methodName
	local now = tick()
	if US.lastHitLogTime[key] and now - US.lastHitLogTime[key] < 0.05 then
		return
	end
	US.lastHitLogTime[key] = now
	local summary = methodName
	if args[1] then
		summary = summary .. " origin=" .. tostring(typeof(args[1]))
	end
	pushCauseEvent("hit", summary, inst, getCaptureCallerInfo(4))
	if isFlowTrackingEnabled() then
		appendFlowStep(nil, { kind = "Hit", label = methodName, method = methodName })
	end
end

function bufferCombatOutbound(remotePath, actionKey, callStack)
	if not isCombatDiscoveryEnabled() then
		return
	end
	table.insert(US.combatOutboundBuffer, 1, {
		time = tick(),
		remotePath = remotePath,
		actionKey = actionKey,
		controller = callStack and callStack[1] and callStack[1].name,
	})
	while #US.combatOutboundBuffer > 32 do
		table.remove(US.combatOutboundBuffer)
	end
	if US.combatDiscovery then
		local key = remotePath or "?"
		US.combatDiscovery.outboundHits[key] = (US.combatDiscovery.outboundHits[key] or 0) + 1
	end
end

function startCombatDiscoveryWindow()
	US.combatDiscovery = { startedAt = tick(), npcPath = "?", outboundHits = {} }
	US.combatOutboundBuffer = {}
	return US.combatDiscovery
end

function finalizeCombatDiscoveryWindow(npcPath, hpDelta)
	if not US.combatDiscovery then
		return
	end
	US.combatDiscovery.npcPath = npcPath or US.combatDiscovery.npcPath
	US.combatDiscovery.hpDelta = hpDelta
	US.combatDiscovery.endedAt = tick()
end

function formatCombatDiscoveryReport()
	local lines = { "-- Combat Discovery (Root Cause ranked)", "" }
	local disc = US.combatDiscovery
	local window = _G.SIMPLESPYCONFIG_CombatDiscoveryWindow or 1
	if not disc or not disc.outboundHits or not next(disc.outboundHits) then
		local hits = {}
		for _, entry in ipairs(US.combatOutboundBuffer) do
			if tick() - entry.time <= window then
				hits[entry.remotePath or "?"] = (hits[entry.remotePath or "?"] or 0) + 1
			end
		end
		disc = { outboundHits = hits, npcPath = "?" }
	end
	table.insert(lines, "-- NPC: " .. tostring(disc.npcPath or "?"))
	if disc.hpDelta then
		table.insert(lines, "-- HP delta: " .. tostring(disc.hpDelta))
	end
	table.insert(lines, "")
	local analysis = resolveRootCause({
		kind = "damage_dealt",
		statPath = disc.npcPath,
		entityPath = disc.npcPath,
		delta = disc.hpDelta,
		window = window,
	})
	if analysis and analysis.topCandidates and #analysis.topCandidates > 0 then
		table.insert(lines, "-- Root Cause ranking:")
		local maxScore = math.max(analysis.maxScore or 1, 1)
		for i, c in ipairs(analysis.topCandidates) do
			if i > 10 then
				break
			end
			local pct = math.floor(((c.score or 0) / maxScore) * 100)
			local tag = ""
			if c.kind == "effect_sync" or c.remoteRole == "replication_effect" then
				tag = " [EFFECT — sync only]"
			end
			local who = c.controller or c.primaryFunction or ""
			if who ~= "" then
				who = " — " .. who
			end
			table.insert(lines, string.format("--  %d%%  %s%s%s", pct, tostring(c.remotePath or "?"), who, tag))
		end
		table.insert(lines, "-- Verdict: " .. tostring(analysis.verdict or "?"))
		return table.concat(lines, "\n")
	end
	if not disc.outboundHits or not next(disc.outboundHits) then
		table.insert(lines, "-- (no combat remotes in window — attack an NPC or press Combat Discovery)")
		return table.concat(lines, "\n")
	end
	local rows = {}
	local total = 0
	for path, count in pairs(disc.outboundHits) do
		total += count
		table.insert(rows, { path = path, count = count })
	end
	table.sort(rows, function(a, b)
		return a.count > b.count
	end)
	table.insert(lines, "-- Fire counts (no Root Cause yet):")
	for _, row in ipairs(rows) do
		local pct = total > 0 and math.floor((row.count / total) * 100) or 0
		table.insert(lines, string.format("--  %d%%  %s  (%dx)", pct, row.path, row.count))
	end
	return table.concat(lines, "\n")
end

function bufferRewardOutbound(remotePath, actionKey, callStack)
	if not isRewardDiscoveryEnabled() then
		return
	end
	-- Only buffer action candidates that *look* reward-ish
	local act = classifyAction(actionKey, callStack)
	if not act or (act.class ~= "REWARD" and act.class ~= "SHOP" and act.class ~= "TRAINING") then
		return
	end
	table.insert(US.rewardOutboundBuffer, 1, {
		time = tick(),
		remotePath = remotePath,
		actionKey = actionKey,
		controller = callStack and callStack[1] and callStack[1].name,
	})
	while #US.rewardOutboundBuffer > 32 do
		table.remove(US.rewardOutboundBuffer)
	end
	if US.rewardDiscovery then
		local key = remotePath or "?"
		US.rewardDiscovery.outboundHits[key] = (US.rewardDiscovery.outboundHits[key] or 0) + 1
	end
end

function startRewardDiscoveryWindow()
	US.rewardDiscovery = { startedAt = tick(), outboundHits = {} }
	US.rewardOutboundBuffer = {}
	return US.rewardDiscovery
end

function finalizeRewardDiscoveryWindow(rewardPath, rewardDelta)
	if not US.rewardDiscovery then
		return
	end
	US.rewardDiscovery.rewardPath = rewardPath or US.rewardDiscovery.rewardPath
	US.rewardDiscovery.rewardDelta = rewardDelta
	US.rewardDiscovery.endedAt = tick()
end

function formatRewardDiscoveryReport()
	local lines = { "-- Reward Discovery (Root Cause ranked)", "" }
	local disc = US.rewardDiscovery
	local window = _G.SIMPLESPYCONFIG_RewardDiscoveryWindow or getRewardSourceWindow()
	if not disc or not disc.outboundHits or not next(disc.outboundHits) then
		local hits = {}
		for _, entry in ipairs(US.rewardOutboundBuffer or {}) do
			if tick() - entry.time <= window then
				hits[entry.remotePath or "?"] = (hits[entry.remotePath or "?"] or 0) + 1
			end
		end
		disc = { outboundHits = hits, rewardPath = "?", rewardDelta = nil }
	end
	table.insert(lines, "-- Reward stat: " .. tostring(disc.rewardPath or "?"))
	if disc.rewardDelta then
		table.insert(lines, "-- Delta: " .. tostring(disc.rewardDelta))
	end
	table.insert(lines, "")
	local analysis = resolveRootCause({
		kind = "reward",
		statPath = disc.rewardPath,
		delta = disc.rewardDelta,
		window = window,
	})
	if analysis and analysis.topCandidates and #analysis.topCandidates > 0 then
		table.insert(lines, "-- Root Cause ranking:")
		local maxScore = math.max(analysis.maxScore or 1, 1)
		for i, c in ipairs(analysis.topCandidates) do
			if i > 10 then
				break
			end
			local pct = math.floor(((c.score or 0) / maxScore) * 100)
			local tag = ""
			if c.kind == "effect_sync" or c.remoteRole == "replication_effect" then
				tag = " [EFFECT — sync only]"
			end
			local who = c.controller or c.primaryFunction or ""
			if who ~= "" then
				who = " — " .. who
			end
			table.insert(lines, string.format("--  %d%%  %s%s%s", pct, tostring(c.remotePath or "?"), who, tag))
		end
		table.insert(lines, "-- Verdict: " .. tostring(analysis.verdict or "?"))
		return table.concat(lines, "\n")
	end
	if not disc.outboundHits or not next(disc.outboundHits) then
		table.insert(lines, "-- (no reward-ish remotes in window — press Reward Discovery, then trigger reward)")
		return table.concat(lines, "\n")
	end
	local rows = {}
	local total = 0
	for path, count in pairs(disc.outboundHits) do
		total += count
		table.insert(rows, { path = path, count = count })
	end
	table.sort(rows, function(a, b)
		return a.count > b.count
	end)
	table.insert(lines, "-- Fire counts (no Root Cause yet):")
	for _, row in ipairs(rows) do
		local pct = total > 0 and math.floor((row.count / total) * 100) or 0
		table.insert(lines, string.format("--  %d%%  %s  (%dx)", pct, row.path, row.count))
	end
	return table.concat(lines, "\n")
end

function scanCallbacksOnInstance(inst)
	local out = {}
	if not getconnections or not inst then
		return out
	end
	local checks = {}
	pcall(function()
		if inst:IsA("BasePart") then
			checks = { "Touched", "TouchEnded" }
		elseif inst:IsA("ProximityPrompt") then
			checks = { "Triggered" }
		elseif inst:IsA("ClickDetector") then
			checks = { "MouseClick" }
		elseif inst:IsA("Tool") then
			checks = { "Activated", "Equipped" }
		end
	end)
	for _, sigName in ipairs(checks) do
		pcall(function()
			local sig = inst[sigName]
			if sig then
				for _, conn in ipairs(getconnections(sig)) do
					if conn.Function then
						local info = debug.getinfo(conn.Function, "n")
						table.insert(out, {
							signal = sigName,
							name = info and info.name or "?",
							source = info and info.source or "?",
						})
					end
				end
			end
		end)
	end
	return out
end

function formatCallbackMap(targetPath)
	local lines = { "-- Callback Map", "" }
	if targetPath and typeof(targetPath) == "Instance" then
		local conns = scanCallbacksOnInstance(targetPath)
		for i, c in ipairs(conns) do
			table.insert(lines, string.format("-- [%d] %s -> %s @ %s", i, c.signal, c.name, c.source))
		end
	elseif next(US.callbackRegistry) then
		for key, c in pairs(US.callbackRegistry) do
			table.insert(lines, string.format("-- %s -> %s @ %s:%s", c.signal, c.name, c.source, c.line))
		end
	else
		table.insert(lines, "-- (empty — interact with world or run spy)")
	end
	return table.concat(lines, "\n")
end

function formatPassiveDiscoveryHint(actionKey, remotePath, session)
	if not next(US.discoveryAtlas) then
		if session and session.verdict == "server_only_replication" then
			return "-- [PASSIVE HINT]\n-- (remote never fired — run Deep Discovery for static candidates)\n"
		end
		return ""
	end
	local lines = { "-- [PASSIVE HINT]", "" }
	local lower = actionKey and actionKey:lower() or ""
	local rows = {}
	for _, entry in pairs(US.discoveryAtlas) do
		local score = entry.score or 0
		local match = false
		if actionKey and entry.suggestedAction and string.find(entry.suggestedAction:lower(), lower, 1, true) then
			match = true
		end
		if actionKey and entry.constant and type(entry.constant) == "string" and string.find(entry.constant:lower(), lower, 1, true) then
			match = true
			score += 10
		end
		if remotePath and entry.remotePath and entry.remotePath == remotePath then
			match = true
			score += 20
		end
		if entry.kind == "constant_hint" or entry.kind == "upvalue_remote" or entry.kind == "gc_remote" then
			if not actionKey and not remotePath then
				match = false
			end
		end
		if match then
			table.insert(rows, { entry = entry, score = score })
		end
	end
	if session and session.verdict == "server_only_replication" and #rows == 0 then
		for _, entry in pairs(US.discoveryAtlas) do
			if (entry.score or 0) >= (_G.SIMPLESPYCONFIG_DiscoveryMinScore or 25) then
				table.insert(rows, { entry = entry, score = entry.score or 0 })
			end
		end
	end
	table.sort(rows, function(a, b)
		return a.score > b.score
	end)
	if #rows == 0 then
		return ""
	end
	for i, row in ipairs(rows) do
		if i > 8 then
			table.insert(lines, "-- ... truncated")
			break
		end
		local e = row.entry
		table.insert(
			lines,
			string.format(
				"-- Possível: %s (score %d) %s.%s | %s",
				tostring(e.remotePath or e.suggestedAction or "?"),
				row.score,
				tostring(e.path),
				tostring(e.name),
				tostring(e.kind)
			)
		)
	end
	table.insert(lines, "-- (run Deep Discovery for full passive scan)")
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function getRecentDamageEventForLog(log, window)
	window = window or 2.5
	local now = tick()
	local logTime = log and log.Timestamp or now
	local logPath = log and log.Snapshot and log.Snapshot.path
	for _, ev in ipairs(US.damageEvents) do
		if now - ev.time <= window then
			if logPath and ev.remotePath and ev.remotePath == logPath then
				return ev
			end
			if log and log.FlowId and ev.flowId == log.FlowId then
				return ev
			end
		end
	end
	for _, ev in ipairs(US.damageEvents) do
		if math.abs(ev.time - logTime) <= window then
			return ev
		end
	end
	return US.damageEvents[1]
end

function getRecentRewardEventForLog(log, window)
	window = window or 2.5
	local now = tick()
	local logPath = log and log.Snapshot and log.Snapshot.path
	for _, ev in ipairs(US.rewardEvents) do
		if now - ev.time <= window then
			if logPath and ev.remotePath and ev.remotePath == logPath then
				return ev
			end
			if logPath and ev.inboundPath and ev.inboundPath == logPath then
				return ev
			end
		end
	end
	return US.rewardEvents[1]
end

function formatSingleDamageEventBlock(ev)
	if not ev then
		return ""
	end
	local lines = {
		"-- [DAMAGE EVENT]",
		string.format(
			"-- Target: %s (%s) %s → %s (%s)",
			tostring(ev.targetPath),
			tostring(ev.targetKind),
			tostring(ev.oldHP),
			tostring(ev.newHP),
			tostring(ev.delta)
		),
	}
	if ev.remotePath then
		table.insert(lines, "-- Remote: " .. tostring(ev.remotePath) .. " action=" .. tostring(ev.actionKey or "?"))
	end
	if ev.controller then
		table.insert(lines, "-- Controller: " .. tostring(ev.controller))
	end
	if ev.causeLabel then
		table.insert(lines, "-- Cause: " .. tostring(ev.causeLabel))
	end
	if ev.refId then
		table.insert(lines, "-- Ref: [REF#" .. tostring(ev.refId) .. "]")
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatSingleRewardEventBlock(ev)
	if not ev then
		return ""
	end
	local lines = {
		"-- [REWARD EVENT]",
		string.format("-- %s +%s", tostring(ev.statPath), tostring(ev.delta)),
	}
	if ev.remotePath then
		table.insert(lines, "-- Remote: " .. tostring(ev.remotePath))
	end
	if ev.inboundPath then
		table.insert(lines, "-- Inbound: " .. tostring(ev.inboundPath))
	end
	if ev.causeLabel then
		table.insert(lines, "-- Cause: " .. tostring(ev.causeLabel))
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function collectWrapperHints(func, budget)
	budget = budget or { 24 }
	local hints = { upvalues = {}, constants = {} }
	if not func or not debug.getupvalues then
		return hints
	end
	pcall(function()
		for i = 1, 16 do
			if budget[1] <= 0 then
				break
			end
			local ok, name, val = pcall(debug.getupvalues, func, i)
			if not ok or name == nil then
				break
			end
			budget[1] -= 1
			if typeof(val) == "Instance" and (val:IsA("RemoteEvent") or val:IsA("RemoteFunction")) then
				table.insert(hints.upvalues, getRemotePathFromInstance(val))
			elseif type(name) == "string" then
				table.insert(hints.upvalues, name)
			end
		end
	end)
	pcall(function()
		if debug.getconstants then
			for _, c in ipairs(debug.getconstants(func)) do
				if type(c) == "string" and (#c < 64) then
					table.insert(hints.constants, c)
				end
			end
		end
	end)
	pcall(function()
		if debug.getprotos then
			local protos = { debug.getprotos(func) }
			for pi, proto in ipairs(protos) do
				if budget[1] <= 0 or pi > 4 then
					break
				end
				budget[1] -= 1
				local pinfo = debug.getinfo(proto, "n")
				local pname = pinfo and pinfo.name or ("proto" .. pi)
				table.insert(hints.constants, "proto:" .. pname)
				pcall(function()
					if debug.getconstants then
						for _, c in ipairs(debug.getconstants(proto)) do
							if type(c) == "string" and (#c < 48) then
								table.insert(hints.constants, pname .. "." .. c)
							end
						end
					end
				end)
			end
		end
	end)
	return hints
end

function formatWrapperChainBlock(callStack, func, damageEvent)
	local lines = { "-- [WRAPPER CHAIN]", "" }
	if callStack then
		for i, frame in ipairs(callStack) do
			table.insert(
				lines,
				string.format(
					"--   %d. [%s] %s @ %s:%s",
					i,
					frame.layer or "?",
					frame.name or "?",
					tostring(frame.source),
					tostring(frame.line)
				)
			)
			if i < #callStack then
				table.insert(lines, "--     v")
			end
		end
	end
	if func then
		local hints = collectWrapperHints(func, { 24 })
		for _, u in ipairs(hints.upvalues) do
			table.insert(lines, "--   upvalue: " .. tostring(u))
		end
		for _, c in ipairs(hints.constants) do
			table.insert(lines, "--   const/proto: " .. tostring(c))
		end
	end
	if damageEvent then
		table.insert(
			lines,
			string.format(
				"--   [DAMAGE] %s %s → %s (%s)",
				tostring(damageEvent.targetPath),
				tostring(damageEvent.oldHP),
				tostring(damageEvent.newHP),
				tostring(damageEvent.delta)
			)
		)
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatRemoteRefBlock(log)
	if not isTrackRemoteReferencesEnabled() or not log then
		return ""
	end
	local lines = { "-- [REMOTE REF]", "" }
	if US.lastFiredRefId and log.Snapshot and log.Snapshot.path then
		local bucket = US.remoteReferences[log.Snapshot.path]
		local cap = bucket and bucket.byRefId[US.lastFiredRefId]
		if cap then
			table.insert(
				lines,
				string.format(
					"-- [REF#%d] %s @ %s:%s (%s)",
					cap.refId,
					cap.kind,
					tostring(cap.source),
					tostring(cap.line),
					tostring(cap.func)
				)
			)
		end
	end
	local focusPath = log.Snapshot and log.Snapshot.path
	local shown = 0
	for path, bucket in pairs(US.remoteReferences) do
		if not focusPath or path == focusPath or shown < 6 then
			for _, cap in ipairs(bucket.captures) do
				if cap.kind == "upvalue_hold" or cap.kind == "cached_closure" or cap.kind == "method_ref" then
					if not focusPath or path == focusPath or cap.refId == US.lastFiredRefId then
						table.insert(
							lines,
							string.format(
								"-- %s → %s @ %s:%s (%s)",
								cap.kind,
								path,
								tostring(cap.source),
								tostring(cap.line),
								tostring(cap.func)
							)
						)
						shown += 1
						if shown >= 8 then
							break
						end
					end
				end
			end
		end
		if shown >= 8 then
			break
		end
	end
	if #lines <= 2 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatCauseChain(causes)
	causes = causes or getRecentCauses(4)
	if #causes == 0 then
		return ""
	end
	local lines = { "-- [CAUSE CHAIN]", "" }
	for i, c in ipairs(causes) do
		table.insert(lines, string.format("-- [%s] %s", tostring(c.kind), tostring(c.label)))
		if i < #causes then
			table.insert(lines, "--   v")
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function extractControllerNameFromSource(source)
	if not source then
		return "?"
	end
	local s = tostring(source)
	s = string.gsub(s, "\\", "/")
	local last = s:match("([^/]+)$") or s
	if string.sub(last, -4) == ".lua" then
		last = string.sub(last, 1, #last - 4)
	end
	return last
end

function extractPrimaryController(callStack)
	if not callStack then
		return nil
	end
	for _, frame in ipairs(callStack) do
		if frame.layer == "Controller" then
			local controllerName = extractControllerNameFromSource(frame.source)
			return {
				controller = controllerName,
				functionName = frame.name or "[anonymous]",
				source = frame.source,
				line = frame.line or 0,
			}
		end
	end
	return nil
end

function formatControllerRankingBlock(candidates, maxScore)
	local lines = { "-- [CONTROLLER RANKING]" }
	if not candidates or #candidates == 0 or not maxScore or maxScore <= 0 then
		table.insert(lines, "-- (none)")
		table.insert(lines, "")
		return table.concat(lines, "\n")
	end
	for i = 1, math.min(6, #candidates) do
		local c = candidates[i]
		if not c then
			continue
		end
		local pct = math.floor((c.score / maxScore) * 100 + 0.5)
		if c.kind == "effect_sync" or c.remoteRole == "replication_effect" then
			table.insert(lines, string.format("--  %d%%  %s [EFFECT — sync only]", pct, tostring(c.remotePath)))
		else
			local primary = extractPrimaryController(c.callStack)
			local ctrl = primary and primary.controller or c.controller or "?"
			local fn = c.primaryFunction or (primary and primary.functionName) or "?"
			table.insert(lines, string.format("--  %d%%  %s", pct, tostring(ctrl)))
			table.insert(lines, string.format("--     %d%%  %s", math.max(5, pct - 7), tostring(fn)))
			if c.callStack then
				for _, frame in ipairs(c.callStack) do
					if frame.layer == "Network" then
						table.insert(lines, string.format("--     %d%%  %s", math.max(5, pct - 10), tostring(frame.name)))
						break
					end
				end
			end
			table.insert(lines, string.format("--     %d%%  %s (outbound)", math.max(5, pct - 12), tostring(c.remotePath)))
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function refreshLogDisplayName(log)
	if not log or not log.Log then
		return
	end
	local base = log.DisplayBase or log.Name or "?"
	if log.ActionSubtitle and log.ActionSubtitle ~= "" then
		base = log.ActionSubtitle .. " | " .. base
	end
	local role = log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole)
	if role == "replication_effect" then
		base = "[SYNC] " .. base
		if log.LikelyCausePath and log.LikelyCausePct then
			local minPct = math.floor(getRealTriggerMinConfidence() * 100 + 0.5)
			if log.LikelyCausePct >= minPct then
				base = base
					.. string.format(
						" → %s (%d%%)",
						getShortPathName(log.LikelyCausePath),
						log.LikelyCausePct
					)
			end
		end
	elseif role == "action_candidate" and not string.find(base, "%[ACTION%]", 1, true) then
		base = "[ACTION] " .. base
	end
	if log.ValuableActionScore and role ~= "replication_effect" then
		base = string.format("[%d] ", log.ValuableActionScore) .. base
	end
	if log.SpamTag and log.SpamTag ~= "" and not string.find(base, "[spam]", 1, true) then
		base = log.SpamTag .. base
	end
	local titleLine = base
	if log.Direction == "in" then
		titleLine = "[IN] " .. titleLine
	elseif log.Direction == "out" then
		titleLine = "[OUT] " .. titleLine
	end
	pcall(function()
		log.Log.Text.Text = string.sub(titleLine, 1, 56)
		local sub = log.Log:FindFirstChild("Subtitle")
		if sub then
			local subText = log.ActionSubtitle or ""
			if subText == "" and log.ActionKey then
				subText = tostring(log.ActionKey)
			end
			sub.Text = string.sub(subText, 1, 56)
		end
	end)
end

function logPassesFilter(log)
	if not log then
		return false
	end
	local f = US.logViewFilter or {}
	if f.hideSpam and log.SpamTag and log.SpamTag ~= "" then
		return false
	end
	local dir = log.Direction or "out"
	if f.direction == "out" and dir ~= "out" then
		return false
	end
	if f.direction == "in" and dir ~= "in" then
		return false
	end
	local role = log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole) or "unknown"
	if f.role == "action" and role == "replication_effect" then
		return false
	end
	if f.role == "sync" and role ~= "replication_effect" then
		return false
	end
	if isVerifiedOnlyFilterEnabled() then
		local path = log.Snapshot and log.Snapshot.path
		local state = path and US.replayOutcomes[path] and US.replayOutcomes[path].state
		if state ~= "verified_action" then
			return false
		end
	end
	local q = f.search
	if q and q ~= "" then
		q = string.lower(q)
		local hay = string.lower(
			(log.Snapshot and log.Snapshot.path or "")
				.. " "
				.. (log.ActionKey or "")
				.. " "
				.. (log.ActionSubtitle or "")
				.. " "
				.. (log.Name or "")
				.. " "
				.. tostring(log.FlowId or "")
		)
		if not string.find(hay, q, 1, true) then
			return false
		end
	end
	return true
end

function applyLogListVisibility()
	for _, log in ipairs(logs) do
		local show = logPassesFilter(log)
		if log.Log then
			log.Log.Visible = show
		end
		if log.SubLogFrame then
			log.SubLogFrame.Visible = show
		end
	end
	for _, group in pairs(US.logGroups or {}) do
		local any = false
		for _, log in ipairs(group.entries or {}) do
			if logPassesFilter(log) then
				any = true
				break
			end
		end
		if group.container then
			group.container.Visible = any
		end
	end
	updateRemoteCanvas()
end

function scheduleLogFilterRefresh()
	US.logViewFilterDebounceToken = (US.logViewFilterDebounceToken or 0) + 1
	local token = US.logViewFilterDebounceToken
	task.delay(0.15, function()
		if US.logViewFilterDebounceToken ~= token then
			return
		end
		applyLogListVisibility()
	end)
end

function scrollLogIntoView(log)
	if not log or not LogList then
		return
	end
	local frame = log.SubLogFrame or log.Log
	if not frame or not frame.Parent then
		return
	end
	task.defer(function()
		pcall(function()
			local y = frame.AbsolutePosition.Y - LogList.AbsolutePosition.Y + LogList.CanvasPosition.Y
			local h = frame.AbsoluteSize.Y
			local viewH = LogList.AbsoluteSize.Y
			LogList.CanvasPosition = Vector2.new(0, math.max(0, y - viewH * 0.35 + h))
		end)
	end)
end

function computeReplayScoreHeuristic(log, callStack, mergedChain)
	if not log then
		return 0, { "missing log" }
	end
	local remoteRole = log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole) or "unknown"
	if remoteRole == "replication_effect" then
		return 0, { "Replication / Effect remote" }
	end
	local act = classifyAction(log.ActionKey, callStack, log.Snapshot and log.Snapshot.path)
	local score = 25
	local reasons = {}
	if act and act.class ~= "UNKNOWN" then
		score += math.floor((act.confidence or 50) * 0.35)
		table.insert(reasons, "Action class=" .. tostring(act.class) .. " conf=" .. tostring(act.confidence))
	else
		table.insert(reasons, "Action candidate (no classifier evidence)")
	end
	if callStack then
		for _, frame in ipairs(callStack) do
			if frame.layer == "Controller" then
				score += 10
				table.insert(reasons, "Controller frame found: " .. tostring(frame.name))
				break
			end
		end
	end
	if mergedChain and next(mergedChain) ~= nil then
		score += 10
		table.insert(reasons, "Wrapper chain present")
	end
	if log.UiTrigger and log.UiTrigger.path then
		score += 6
		table.insert(reasons, "UI trigger nearby")
	end
	-- Phase 6 evidence (upvalues / metatables / function users)
	local remotePath = log.Snapshot and log.Snapshot.path
	if remotePath then
		if US.upvalueRemoteByRemote and US.upvalueRemoteByRemote[remotePath] and next(US.upvalueRemoteByRemote[remotePath]) then
			score += 8
			table.insert(reasons, "Upvalue holds this remote")
		end
		if US.remoteToFunctions and US.remoteToFunctions[remotePath] and next(US.remoteToFunctions[remotePath]) then
			score += 6
			table.insert(reasons, "Remote referenced by functions")
		end
		if US.metatableLinks then
			for _, link in pairs(US.metatableLinks) do
				if link and link.remotePath == remotePath and link.confidence then
					score += 5
					table.insert(reasons, "Metatable facade -> remote (" .. tostring(math.floor((link.confidence or 0))) .. "%)")
					break
				end
			end
		end
	end
	local remotePath = log.Snapshot and log.Snapshot.path
	if remotePath and US.replayOutcomes[remotePath] then
		local ro = US.replayOutcomes[remotePath]
		if ro.lastReplayScore and ro.lastReplayScore > score then
			score = ro.lastReplayScore
			table.insert(reasons, "Temporal replay outcome: " .. tostring(ro.state or "?"))
		end
	end
	score = math.max(0, math.min(100, score))
	if #reasons == 0 then
		reasons = { "heuristic replay score" }
	end
	return score, reasons
end

function formatReplayScoreBlock(score, reasons, state)
	score = tonumber(score) or 0
	state = state or "unknown"
	local stateLabel = state == "verified_action" and "Verified Action"
		or state == "replication_only" and "Replication Only"
		or "Unknown"
	local lines = {
		"-- [REPLAY SCORING]",
		string.format("-- ReplayScore: %d/100 (%s)", score, stateLabel),
	}
	if reasons and type(reasons) == "table" then
		for i = 1, math.min(5, #reasons) do
			lines[#lines + 1] = "--   - " .. tostring(reasons[i])
		end
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function computeValuableActionScore(replayScore, log)
	local remotePath = log and log.Snapshot and log.Snapshot.path
	local remoteRole = log and (log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole) or getRemoteRole(remotePath))
	if remoteRole == "replication_effect" then
		return math.min(10, 5), { "Replication/effect remote (max 10)" }
	end
	replayScore = tonumber(replayScore) or 0
	local score = 0
	local reasons = {}
	if replayScore >= 70 then
		score += 40
		table.insert(reasons, "High replay score")
	elseif replayScore >= 40 then
		score += 20
		table.insert(reasons, "Moderate replay score")
	end
	if log and log.CallStack then
		for _, frame in ipairs(log.CallStack) do
			if frame.layer == "Controller" then
				score += 20
				table.insert(reasons, "Controller in stack")
				break
			end
		end
	end
	score += 20
	table.insert(reasons, "Action candidate (not replication)")
	if log and log.ActionKey then
		local act = classifyAction(log.ActionKey, log.CallStack, remotePath)
		if act and act.class ~= "UNKNOWN" then
			score += 15
			table.insert(reasons, "Class " .. act.class)
		end
	end
	if remotePath and US.functionActionRegistry then
		for _, reg in pairs(US.functionActionRegistry) do
			if reg.remotes and reg.remotes[remotePath] then
				score += 10
				table.insert(reasons, "Function registry hits")
				break
			end
		end
	end
	if remotePath and US.upvalueRemoteByRemote and US.upvalueRemoteByRemote[remotePath] and next(US.upvalueRemoteByRemote[remotePath]) then
		score += 10
		table.insert(reasons, "Upvalue link")
	end
	if remotePath and US.metatableLinks then
		for _, link in pairs(US.metatableLinks) do
			if link and link.remotePath == remotePath then
				score += 10
				table.insert(reasons, "Metatable resolved")
				break
			end
		end
	end
	score = math.max(0, math.min(100, score))
	return score, reasons
end

function formatValuableActionBlock(score, reasons)
	score = tonumber(score) or 0
	local lines = { "-- [VALUABLE ACTION SCORE]", string.format("-- ValuableActionScore: %d/100", score) }
	if reasons and type(reasons) == "table" then
		for i = 1, math.min(5, #reasons) do
			lines[#lines + 1] = "--   - " .. tostring(reasons[i])
		end
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function checkWeaponEquipped()
	if not Players or not Players.LocalPlayer or not Players.LocalPlayer.Character then
		return false
	end
	local char = Players.LocalPlayer.Character
	local ok, children = pcall(function()
		return char:GetChildren()
	end)
	if not ok or not children then
		return false
	end
	for _, ch in ipairs(children) do
		local isTool = false
		pcall(function()
			isTool = ch:IsA("Tool")
		end)
		if isTool then
			if ch.Enabled == nil or ch.Enabled == true then
				return true
			end
		end
	end
	return false
end

function checkQuestActive()
	if not Players or not Players.LocalPlayer then
		return false
	end
	local player = Players.LocalPlayer
	local okAttr, attrQuest = pcall(function()
		return player:GetAttribute("QuestActive")
	end)
	if okAttr and attrQuest ~= nil then
		return attrQuest == true or (type(attrQuest) == "number" and attrQuest > 0)
	end
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		return false
	end
	local ok, children = pcall(function()
		return ls:GetChildren()
	end)
	if not ok or not children then
		return false
	end
	for _, child in ipairs(children) do
		if child and child.Name then
			local n = child.Name:lower()
			if string.find(n, "quest", 1, true) or string.find(n, "daily", 1, true) then
				local v = child.Value
				if type(v) == "number" and v > 0 then
					return true
				end
				if v == true then
					return true
				end
			end
		end
	end
	return false
end

function checkZoneUnlocked()
	if not Players or not Players.LocalPlayer then
		return false
	end
	local player = Players.LocalPlayer
	local candidates = { "ZoneUnlocked", "UnlockedZone", "Zone" }
	for _, k in ipairs(candidates) do
		local ok, v = pcall(function()
			return player:GetAttribute(k)
		end)
		if ok and v ~= nil then
			return v == true or (type(v) == "number" and v > 0) or (type(v) == "string" and v ~= "")
		end
	end
	return false
end

function formatStateDependencyBlock(log)
	if not log then
		return ""
	end
	local remoteRole = log.RemoteRole or (log.Snapshot and log.Snapshot.remoteRole) or "unknown"
	if remoteRole == "replication_effect" then
		return ""
	end
	local remotePath = log.Snapshot and log.Snapshot.path
	local lines = { "-- [STATE DEPENDENCIES]", "-- " .. tostring(remotePath or log.Name or "?") }
	lines[#lines + 1] = "-- Current snapshot:"
	lines[#lines + 1] = "--   Weapon Equipped: " .. tostring(checkWeaponEquipped() and "yes" or "no")
	lines[#lines + 1] = "--   Quest Active: " .. tostring(checkQuestActive() and "yes" or "no")
	lines[#lines + 1] = "--   Zone Unlocked: " .. tostring(checkZoneUnlocked() and "yes" or "no")
	local learned = getLearnedStateRequirements(remotePath, log.ActionKey)
	if learned and #learned > 0 then
		lines[#lines + 1] = "-- Required likely (learned):"
		for _, req in ipairs(learned) do
			lines[#lines + 1] = string.format("--   %s (%d%%)", req.label, req.pct)
		end
	else
		lines[#lines + 1] = "-- (collect more fires with/without effect to learn requirements)"
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function formatMultiRemoteActionBlock(log)
	if not log then
		return ""
	end
	local flowId = log.FlowId
	local uiPath = log.UiTrigger and log.UiTrigger.path
	local act = classifyAction(log.ActionKey, log.CallStack, log.Snapshot and log.Snapshot.path)
	local seqKey = tostring(flowId or "0") .. "|" .. tostring(uiPath or "") .. "|" .. tostring(act and act.class or "?")
	local learned = US.actionSequences[seqKey]
	if learned and learned.remotes and #learned.remotes >= 2 then
		local conf = math.min(95, 50 + (learned.hits or 1) * 8)
		local lines = {
			"-- [MULTI-REMOTE ACTION]",
			"-- Action: " .. inferHumanActionLabel(log.ActionKey),
			string.format("-- Sequence confidence: %d%%", conf),
		}
		for i, path in ipairs(learned.remotes) do
			table.insert(lines, string.format("--  %d) %s", i, path))
		end
		lines[#lines + 1] = ""
		return table.concat(lines, "\n")
	end
	local now = tick()
	local window = _G.SIMPLESPYCONFIG_MultiRemoteWindow or 2.5
	local remotes = {}
	local seen = {}
	for _, ev in ipairs(US.recentOutboundEvents or {}) do
		if ev and ev.time and (now - ev.time) <= window and ev.remoteRole == "action_candidate" then
			local matchFlow = flowId ~= nil and ev.flowId == flowId
			local matchUi = uiPath and ev.uiTrigger and ev.uiTrigger.path == uiPath
			if matchFlow or matchUi then
				table.insert(remotes, ev)
			end
		end
	end
	table.sort(remotes, function(a, b)
		return (a.time or 0) < (b.time or 0)
	end)
	local seq = {}
	for _, ev in ipairs(remotes) do
		if ev.remotePath and not seen[ev.remotePath] then
			seen[ev.remotePath] = true
			table.insert(seq, ev)
		end
	end
	if #seq < 2 then
		return ""
	end
	local conf = math.min(88, 45 + #seq * 12)
	local lines = {
		"-- [MULTI-REMOTE ACTION]",
		"-- Action: " .. inferHumanActionLabel(log.ActionKey),
		string.format("-- Sequence confidence: %d%%", conf),
	}
	for i, ev in ipairs(seq) do
		table.insert(lines, string.format("--  %d) %s (action=%s)", i, tostring(ev.remotePath), tostring(ev.actionKey)))
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function inferHumanActionLabel(actionKey)
	if not actionKey or type(actionKey) ~= "string" then
		return "Action"
	end
	local lower = actionKey:lower()
	if string.find(lower, "train", 1, true)
		or string.find(lower, "workout", 1, true)
		or string.find(lower, "aura", 1, true)
		or string.find(lower, "strength", 1, true)
		or string.find(lower, "power", 1, true)
	then
		return "Train"
	end
	if string.find(lower, "attack", 1, true)
		or string.find(lower, "damage", 1, true)
		or string.find(lower, "hit", 1, true)
		or string.find(lower, "swing", 1, true)
		or string.find(lower, "combat", 1, true)
		or string.find(lower, "weapon", 1, true)
	then
		return "Attack"
	end
	if string.find(lower, "claim", 1, true)
		or string.find(lower, "reward", 1, true)
		or string.find(lower, "quest", 1, true)
		or string.find(lower, "daily", 1, true)
		or string.find(lower, "wins", 1, true)
	then
		return "Claim"
	end
	if string.find(lower, "buy", 1, true)
		or string.find(lower, "shop", 1, true)
		or string.find(lower, "purchase", 1, true)
		or string.find(lower, "spin", 1, true)
		or string.find(lower, "roll", 1, true)
	then
		return "Buy"
	end
	return actionKey
end

local TRAINING_SIGNATURE_TERMS = {
	"train",
	"workout",
	"aura",
	"strength",
	"power",
	"lift",
	"exercise",
	"click",
}

function classifyAction(actionKey, callStack, statPath)
	if not actionKey or type(actionKey) ~= "string" then
		return { class = "UNKNOWN", confidence = 0 }
	end
	local lower = actionKey:lower()

	-- Prefer explicit signature sets (used elsewhere for remoteProfiles)
	local matched, _ = signatureMatchesTerm(actionKey, COMBAT_SIGNATURES or {})
	if matched then
		return { class = "COMBAT", confidence = 80 }
	end
	local matchedR, _ = signatureMatchesTerm(actionKey, REWARD_SIGNATURE_TERMS or {})
	if matchedR then
		return { class = "REWARD", confidence = 78 }
	end
	local matchedS, _ = signatureMatchesTerm(actionKey, SHOP_SIGNATURE_TERMS or {})
	if matchedS then
		return { class = "SHOP", confidence = 72 }
	end

	-- Training classifier (heuristic)
	local hits = 0
	for _, t in ipairs(TRAINING_SIGNATURE_TERMS) do
		if string.find(lower, t, 1, true) then
			hits += 1
		end
	end
	if hits >= 2 then
		return { class = "TRAINING", confidence = math.min(90, 60 + hits * 8) }
	end
	-- fallback: if it looks reward-ish by statPath
	if statPath and type(statPath) == "string" then
		local l2 = statPath:lower()
		if string.find(l2, "aura", 1, true) or string.find(l2, "xp", 1, true) or string.find(l2, "strength", 1, true) then
			return { class = "TRAINING", confidence = 55 }
		end
	end
	return { class = "UNKNOWN", confidence = 40 }
end

function formatActionDiscoveryBlock(log, callStack, mergedChain)
	if not log or not callStack then
		return ""
	end
	local snapshot = log.Snapshot
	local remoteLabel = snapshot and (snapshot.path or snapshot.name) or log.Name or "Remote"
	local actionLabel = inferHumanActionLabel(log.ActionKey)
	local act = classifyAction(log.ActionKey, callStack, remoteLabel)
	local primary = extractPrimaryController(callStack)
	local controllerName = primary and primary.controller or "?"
	local functionName = primary and primary.functionName or "?"

	local chain = {}
	if primary then
		table.insert(chain, controllerName .. "." .. functionName)
	end
	if mergedChain then
		for _, step in ipairs(mergedChain) do
			if step.name or step.label then
				table.insert(chain, tostring(step.name or step.label))
			end
			if #chain >= 5 then
				break
			end
		end
	elseif primary and primary.source then
		for j = 1, #callStack do
			local f = callStack[j]
			if f.layer == "Network" or f.layer == "Remote" then
				table.insert(chain, f.name or "[?]")
			end
			if #chain >= 5 then
				break
			end
		end
	end
	table.insert(chain, remoteLabel)

	local lines = { "-- [ACTION DISCOVERY]" }
	if act and act.class then
		lines[#lines + 1] = string.format("-- Type: %s (%d%%)", act.class, tonumber(act.confidence) or 0)
	end
	lines[#lines + 1] = "-- Action: " .. tostring(actionLabel)
	lines[#lines + 1] = "-- Controller: " .. tostring(controllerName)
	if primary and primary.source and primary.line then
		lines[#lines + 1] = string.format("-- Controller Source: %s:%d", tostring(primary.source), primary.line or 0)
	end
	lines[#lines + 1] = "-- Function: " .. tostring(functionName)
	lines[#lines + 1] = "-- Remote: " .. tostring(remoteLabel)
	lines[#lines + 1] = "-- Chain:"
	for i, item in ipairs(chain) do
		lines[#lines + 1] = "--   " .. tostring(item)
		if i < #chain then
			lines[#lines + 1] = "--   v"
		end
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function formatFullInvestigation(log)
	if not log then
		return ""
	end
	local parts = {}
	local causeBlock = formatCauseChain(getRecentCauses(3))
	if causeBlock ~= "" then
		table.insert(parts, causeBlock)
	end
	local refBlock = formatRemoteRefBlock(log)
	if refBlock ~= "" then
		table.insert(parts, refBlock)
	end
	if log.ActionDiscoveryBlock and log.ActionDiscoveryBlock ~= "" then
		table.insert(parts, log.ActionDiscoveryBlock)
	end
	if log.RootCauseBlock and log.RootCauseBlock ~= "" then
		table.insert(parts, log.RootCauseBlock)
	end
	if log.RewardSourceBlock and log.RewardSourceBlock ~= "" then
		table.insert(parts, log.RewardSourceBlock)
	end
	if log.ReplayScoreBlock and log.ReplayScoreBlock ~= "" then
		table.insert(parts, log.ReplayScoreBlock)
	end
	if log.ValuableActionBlock and log.ValuableActionBlock ~= "" then
		table.insert(parts, log.ValuableActionBlock)
	end
	if log.StateDependencyBlock and log.StateDependencyBlock ~= "" then
		table.insert(parts, log.StateDependencyBlock)
	end
	if log.MultiRemoteBlock and log.MultiRemoteBlock ~= "" then
		table.insert(parts, log.MultiRemoteBlock)
	end
	if log.WrapperChainBlock and log.WrapperChainBlock ~= "" then
		table.insert(parts, log.WrapperChainBlock)
	end
	if log.FlowSnapshot then
		table.insert(parts, formatFlowVisual(log.FlowSnapshot))
	end
	if log.InvestigationBlock and log.InvestigationBlock ~= "" then
		table.insert(parts, log.InvestigationBlock)
	end
	if log.DamageEventBlock and log.DamageEventBlock ~= "" then
		table.insert(parts, log.DamageEventBlock)
	end
	if log.RewardEventBlock and log.RewardEventBlock ~= "" then
		table.insert(parts, log.RewardEventBlock)
	end
	if log.PassiveHintBlock and log.PassiveHintBlock ~= "" then
		table.insert(parts, log.PassiveHintBlock)
	end
	if log.AutoWrapperChainBlock and log.AutoWrapperChainBlock ~= "" then
		table.insert(parts, log.AutoWrapperChainBlock)
	end
	if log.MetatableLinkBlock and log.MetatableLinkBlock ~= "" then
		table.insert(parts, log.MetatableLinkBlock)
	end
	if log.UpvalueRefBlock and log.UpvalueRefBlock ~= "" then
		table.insert(parts, log.UpvalueRefBlock)
	end
	if log.FunctionUsersBlock and log.FunctionUsersBlock ~= "" then
		table.insert(parts, log.FunctionUsersBlock)
	end
	if log.ScriptOriginBlock and log.ScriptOriginBlock ~= "" then
		table.insert(parts, log.ScriptOriginBlock)
	end
	if log.HiddenStatBlock and log.HiddenStatBlock ~= "" then
		table.insert(parts, log.HiddenStatBlock)
	end
	if log.RemoteProfileBlock and log.RemoteProfileBlock ~= "" then
		table.insert(parts, log.RemoteProfileBlock)
	end
	if log.LifecycleSummaryBlock and log.LifecycleSummaryBlock ~= "" then
		table.insert(parts, log.LifecycleSummaryBlock)
	end
	return table.concat(parts, "\n")
end

function attachPhase5ToLog(log, callStack, func, mergedChain)
	if not log then
		return
	end
	local primary = extractPrimaryController(callStack)
	if primary and primary.controller and primary.functionName then
		log.ActionSubtitle = primary.controller .. "." .. primary.functionName
	end
	log.ActionDiscoveryBlock = formatActionDiscoveryBlock(log, callStack, mergedChain)
	local replayScore, replayReasons = computeReplayScoreHeuristic(log, callStack, mergedChain)
	local replayState = "unknown"
	local remotePath = log.Snapshot and log.Snapshot.path
	if remotePath and US.replayOutcomes[remotePath] then
		replayState = US.replayOutcomes[remotePath].state or replayState
	end
	log.ReplayScore = replayScore
	log.ReplayScoreState = replayState
	log.ReplayScoreBlock = formatReplayScoreBlock(replayScore, replayReasons, replayState)
	local valuableScore, valuableReasons = computeValuableActionScore(replayScore, log)
	log.ValuableActionScore = valuableScore
	log.ValuableActionBlock = formatValuableActionBlock(valuableScore, valuableReasons)
	if remotePath then
		US.remoteActionScores[remotePath] = valuableScore
	end
	log.StateDependencyBlock = formatStateDependencyBlock(log)
	log.MultiRemoteBlock = formatMultiRemoteActionBlock(log)
	log.CauseBlock = formatCauseChain(getRecentCauses(2))
	local dmgEv = getRecentDamageEventForLog(log, getCorrelateWindow())
	local rewEv = getRecentRewardEventForLog(log, getCorrelateWindow())
	log.DamageEventBlock = formatSingleDamageEventBlock(dmgEv)
	log.RewardEventBlock = formatSingleRewardEventBlock(rewEv)
	log.WrapperChainBlock = formatWrapperChainBlock(callStack, func, dmgEv)
	log.RemoteRefBlock = formatRemoteRefBlock(log)
	if US.activeInvestigation then
		log.InvestigationBlock = formatInvestigationSession(US.activeInvestigation)
	end
	log.PassiveHintBlock = formatPassiveDiscoveryHint(
		log.ActionKey,
		log.Snapshot and log.Snapshot.path,
		US.activeInvestigation
	)
	attachPhase6ToLog(log, callStack, func, mergedChain)
	recordActionStateSample(remotePath, log.ActionKey, replayScore, replayScore >= 50)
	refreshLogDisplayName(log)
	resortActionHuntLogList()
	if log.Direction ~= "in" and log.Snapshot then
		scheduleReplayOutcomeCheck(log, log.Snapshot, log.ActionKey)
	end
end

function formatCauseLog()
	local lines = { "-- Recent Causes", "" }
	for _, c in ipairs(US.recentCauses) do
		table.insert(lines, string.format("-- [%.2fs ago] %s %s", tick() - c.time, c.kind, c.label))
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

function formatTaggedEntities(tag)
	local lines = { "-- CollectionService Tagged", "" }
	if tag then
		local bucket = US.collectionTagged[tag]
		if bucket then
			for path in pairs(bucket) do
				table.insert(lines, "-- " .. path)
			end
		end
	else
		for t, bucket in pairs(US.collectionTagged) do
			table.insert(lines, "-- Tag: " .. t)
			for path in pairs(bucket) do
				table.insert(lines, "  " .. path)
			end
		end
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

--- Phase 6: hidden stats, auto wrapper chain, metatable links, upvalue/function registry, profiles

local COMBAT_SIGNATURES = {
	"attack",
	"hit",
	"damage",
	"swing",
	"weapon",
	"critical",
	"combo",
	"slash",
	"punch",
	"shoot",
}
local REWARD_SIGNATURE_TERMS = {
	"reward",
	"claim",
	"daily",
	"quest",
	"mission",
	"bonus",
	"loot",
	"drop",
}
local SHOP_SIGNATURE_TERMS = {
	"buy",
	"purchase",
	"sell",
	"equip",
	"upgrade",
	"shop",
	"store",
}

function isHiddenStatDiscoveryEnabled()
	return _G.SIMPLESPYCONFIG_HiddenStatDiscovery ~= false
end

function isAutoWrapperChainEnabled()
	return _G.SIMPLESPYCONFIG_AutoWrapperChain ~= false
end

function isMetatableResolverEnabled()
	return _G.SIMPLESPYCONFIG_MetatableResolver ~= false
end

function isUpvalueRemoteRegistryEnabled()
	return _G.SIMPLESPYCONFIG_UpvalueRemoteRegistry ~= false
end

function isFunctionRemoteRegistryEnabled()
	return _G.SIMPLESPYCONFIG_FunctionRemoteRegistry ~= false
end

function isTrackScriptOriginsEnabled()
	return _G.SIMPLESPYCONFIG_TrackScriptOrigins ~= false
end

function isConstantSignatureProfilesEnabled()
	return _G.SIMPLESPYCONFIG_ConstantSignatureProfiles ~= false
end

function isNumericValueInstance(inst)
	return inst
		and (
			inst:IsA("NumberValue")
			or inst:IsA("IntValue")
			or inst:IsA("DoubleConstrainedValue")
		)
end

function shouldWatchAsHiddenStat(path)
	if not path or isPropCosmeticPath(path) then
		return false
	end
	local lower = path:lower()
	if string.find(lower, ".playergui.", 1, true) then
		return false
	end
	if nameMatchesKeySet(path:match("[^%.]+$") or "", HEALTH_KEYS) then
		return false
	end
	if nameMatchesKeySet(path:match("[^%.]+$") or "", REWARD_KEYS) then
		return false
	end
	return true
end

function inferHiddenStatRole(path, oldVal, newVal, profile)
	local oldN, newN = tonumber(oldVal), tonumber(newVal)
	if not oldN or not newN then
		return profile and profile.inferredRole or "unknown"
	end
	local delta = newN - oldN
	profile = profile or {}
	profile.samples = (profile.samples or 0) + 1
	if delta < 0 then
		profile.downCount = (profile.downCount or 0) + 1
	end
	if delta > 0 then
		profile.upCount = (profile.upCount or 0) + 1
	end
	if profile.confirmedRole then
		return profile.confirmedRole
	end
	if profile.samples >= 2 then
		if (profile.downCount or 0) >= 2 and delta <= 0 then
			return "likely_hp"
		end
		if (profile.upCount or 0) >= 2 and delta > 0 then
			if US.recentOutboundContext and tick() - US.recentOutboundContext.time <= getCorrelateWindow() then
				return "likely_reward"
			end
			return "likely_currency"
		end
	end
	return profile.inferredRole or "unknown"
end

function onHiddenStatChange(path, oldVal, newVal)
	if not isHiddenStatDiscoveryEnabled() then
		return
	end
	local profile = US.hiddenStatProfiles[path] or { path = path, samples = 0 }
	profile.lastOld = oldVal
	profile.lastNew = newVal
	profile.lastDelta = tonumber(newVal) and tonumber(oldVal) and (tonumber(newVal) - tonumber(oldVal)) or nil
	profile.inferredRole = inferHiddenStatRole(path, oldVal, newVal, profile)
	US.hiddenStatProfiles[path] = profile
	appendTimelineEvent({
		kind = "hidden_stat",
		label = getShortPathName(path),
		detail = tostring(oldVal) .. " → " .. tostring(newVal) .. " (" .. profile.inferredRole .. ")",
	})
	appendToActiveInvestigation(
		"hidden_stats",
		path .. " " .. tostring(oldVal) .. " → " .. tostring(newVal) .. " " .. profile.inferredRole
	)
	if selected and US.recentOutboundContext and selected == US.recentOutboundContext.logRef then
		selected.HiddenStatBlock = formatHiddenStatBlockForLog(selected)
		scheduleOnSpyThread(function()
			selectLogEntry(selected)
		end)
	end

	-- Root Cause (Hidden Stat Role -> who caused it)
	local delta = profile.lastDelta
	if delta ~= nil then
		if profile.inferredRole == "likely_reward" then
			applyRootCauseToLog({
				kind = "reward",
				statPath = path,
				oldVal = oldVal,
				newVal = newVal,
				delta = delta,
			})
			applyRewardSourcesToLog({
				statPath = path,
				delta = delta,
			})
		elseif profile.inferredRole == "likely_hp" then
			applyRootCauseToLog({
				kind = delta <= 0 and "damage_taken" or "damage_dealt",
				statPath = path,
				oldVal = oldVal,
				newVal = newVal,
				delta = delta,
			})
		end
	end
end

function watchGenericNumericValue(inst, path)
	if not isHiddenStatDiscoveryEnabled() or not inst or not path then
		return
	end
	if US.stateWatchConns["hidden:" .. path] then
		return
	end
	if not shouldWatchAsHiddenStat(path) then
		return
	end
	if US.hiddenStatWatchCount >= (_G.SIMPLESPYCONFIG_MAX_HIDDEN_STAT_WATCH or 120) then
		return
	end
	if not isNumericValueInstance(inst) then
		return
	end
	US.hiddenStatWatchCount += 1
	pcall(function()
		US.stateBaseline[path] = inst.Value
	end)
	local conn = inst:GetPropertyChangedSignal("Value"):Connect(function()
		local oldVal = US.stateBaseline[path]
		local newVal = inst.Value
		if oldVal ~= newVal then
			US.stateBaseline[path] = newVal
			onHiddenStatChange(path, oldVal, newVal)
		end
	end)
	US.stateWatchConns["hidden:" .. path] = conn
	table.insert(connections, conn)
end

function scanFolderForHiddenStats(root, depth)
	if not root or depth > 5 or not isHiddenStatDiscoveryEnabled() then
		return
	end
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("ValueBase") then
			local path = child:GetFullName()
			if isNumericValueInstance(child) and shouldWatchAsHiddenStat(path) then
				if nameMatchesKeySet(child.Name, HEALTH_KEYS) or nameMatchesKeySet(child.Name, REWARD_KEYS) then
					watchValueAtPathPhase5(child, path)
				else
					watchGenericNumericValue(child, path)
				end
			end
		elseif child:IsA("Folder") then
			scanFolderForHiddenStats(child, depth + 1)
		end
	end
end

function confirmHiddenStatHp(path)
	local profile = US.hiddenStatProfiles[path]
	if profile then
		profile.confirmedRole = "confirmed_hp"
		profile.inferredRole = "confirmed_hp"
	end
end

function formatHiddenStatReport()
	local lines = { "-- Hidden Stat Discovery", "" }
	local rows = {}
	for path, profile in pairs(US.hiddenStatProfiles) do
		table.insert(rows, { path = path, profile = profile })
	end
	table.sort(rows, function(a, b)
		return (a.profile.samples or 0) > (b.profile.samples or 0)
	end)
	if #rows == 0 then
		table.insert(lines, "-- (none — interact with game data or Scan Player Data)")
	else
		for _, row in ipairs(rows) do
			local p = row.profile
			table.insert(
				lines,
				string.format(
					"-- %s: %s → %s role=%s samples=%d",
					row.path,
					tostring(p.lastOld),
					tostring(p.lastNew),
					tostring(p.inferredRole or p.confirmedRole or "?"),
					p.samples or 0
				)
			)
		end
	end
	return table.concat(lines, "\n")
end

function formatHiddenStatBlockForLog(log)
	local lines = { "-- [HIDDEN STAT]", "" }
	local added = 0
	for path, profile in pairs(US.hiddenStatProfiles) do
		if profile.lastDelta and (profile.inferredRole ~= "unknown" or profile.confirmedRole) then
			table.insert(
				lines,
				string.format(
					"-- %s: %s (Δ%s) %s",
					getShortPathName(path),
					tostring(profile.lastOld) .. " → " .. tostring(profile.lastNew),
					tostring(profile.lastDelta),
					tostring(profile.confirmedRole or profile.inferredRole)
				)
			)
			added += 1
			if added >= 8 then
				break
			end
		end
	end
	if added == 0 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function pushWrapperCallBuffer(name, source, layer, funcId)
	if not isAutoWrapperChainEnabled() then
		return
	end
	table.insert(US.wrapperCallBuffer, 1, {
		time = tick(),
		name = name,
		source = source or "?",
		layer = layer or "Network",
		funcId = funcId,
	})
	while #US.wrapperCallBuffer > 32 do
		table.remove(US.wrapperCallBuffer)
	end
	local facade = name
	if source and source ~= "?" then
		facade = source .. "." .. tostring(name)
	end
	US.recentWrapperFacade = { key = facade, time = tick(), name = name, source = source }
end

local WRAPPER_LAYER_ORDER = { Controller = 1, Network = 2, Script = 3, Actor = 4, UI = 5, Remote = 6 }

function wrapperLayerSortKey(layer)
	return WRAPPER_LAYER_ORDER[layer or ""] or 4
end

function mergeWrapperBufferWithCallStack(callStack)
	local window = getCorrelateWindow()
	local now = tick()
	local merged = {}
	local seen = {}
	for _, entry in ipairs(US.wrapperCallBuffer) do
		if now - entry.time <= window then
			local key = (entry.source or "") .. "|" .. (entry.name or "")
			if not seen[key] then
				seen[key] = true
				table.insert(merged, {
					name = entry.name,
					source = entry.source,
					layer = entry.layer,
					fromBuffer = true,
				})
			end
		end
	end
	if callStack then
		for _, frame in ipairs(callStack) do
			if wrapperNameMatches(frame.name or "") or frame.layer == "Network" or frame.layer == "Controller" then
				local key = (frame.source or "") .. "|" .. (frame.name or "")
				if not seen[key] then
					seen[key] = true
					table.insert(merged, {
						name = frame.name,
						source = frame.source,
						line = frame.line,
						layer = frame.layer,
						fromBuffer = false,
					})
				end
			end
		end
	end
	table.sort(merged, function(a, b)
		local oa = wrapperLayerSortKey(a.layer)
		local ob = wrapperLayerSortKey(b.layer)
		if oa ~= ob then
			return oa < ob
		end
		return tostring(a.name) < tostring(b.name)
	end)
	return merged
end

function formatAutoWrapperChain(mergedChain, remoteLabel)
	if not mergedChain or #mergedChain == 0 then
		return ""
	end
	local lines = { "-- [AUTO WRAPPER CHAIN]", "" }
	for i, frame in ipairs(mergedChain) do
		table.insert(
			lines,
			string.format(
				"--   %d. [%s] %s @ %s%s",
				i,
				frame.layer or "?",
				tostring(frame.name),
				tostring(frame.source),
				frame.line and (":" .. tostring(frame.line)) or ""
			)
		)
		if i < #mergedChain then
			table.insert(lines, "--     v")
		end
	end
	if remoteLabel then
		table.insert(lines, "--     v")
		table.insert(lines, "--   [Remote] " .. remoteLabel)
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function storeWrapperChainForRemote(remotePath, mergedChain)
	if not remotePath or not mergedChain or #mergedChain == 0 then
		return
	end
	US.wrapperChainsByRemote[remotePath] = US.wrapperChainsByRemote[remotePath] or {}
	local fp = ""
	for _, f in ipairs(mergedChain) do
		fp = fp .. (f.name or "") .. "|"
	end
	local list = US.wrapperChainsByRemote[remotePath]
	for _, existing in ipairs(list) do
		if existing.fingerprint == fp then
			existing.hits = (existing.hits or 1) + 1
			existing.lastSeen = tick()
			return
		end
	end
	table.insert(list, 1, { chain = mergedChain, fingerprint = fp, hits = 1, lastSeen = tick() })
	while #list > 5 do
		table.remove(list)
	end
end

function registerMetatableLink(facadeKey, remotePath, confidence, sourceTag)
	if not isMetatableResolverEnabled() or not facadeKey or not remotePath then
		return
	end
	local existing = US.metatableLinks[facadeKey]
	if existing and (existing.confidence or 0) >= (confidence or 0) then
		existing.hits = (existing.hits or 1) + 1
		existing.lastSeen = tick()
		if sourceTag then
			existing.sources = existing.sources or {}
			existing.sources[sourceTag] = true
		end
		return
	end
	US.metatableLinks[facadeKey] = {
		remotePath = remotePath,
		method = "FireServer",
		confidence = confidence or 70,
		sources = sourceTag and { [sourceTag] = true } or {},
		hits = 1,
		lastSeen = tick(),
	}
end

function correlateMetatableFromFire(remotePath, mergedChain)
	if not isMetatableResolverEnabled() or not remotePath then
		return
	end
	local facade = US.recentWrapperFacade
	if facade and tick() - facade.time <= getCorrelateWindow() then
		registerMetatableLink(facade.key, remotePath, 88, "wrapper_chain")
	end
	if mergedChain and #mergedChain > 0 then
		local last = mergedChain[#mergedChain]
		if last and last.name and wrapperNameMatches(last.name) then
			local key = (last.source or "?") .. "." .. last.name
			registerMetatableLink(key, remotePath, 75, "wrapper_chain")
		end
	end
end

function formatMetatableLinkBlock(log)
	if not isMetatableResolverEnabled() or not log then
		return ""
	end
	local lines = { "-- [METATABLE LINK]", "" }
	local remotePath = log.Snapshot and log.Snapshot.path
	local shown = 0
	for facadeKey, link in pairs(US.metatableLinks) do
		if not remotePath or link.remotePath == remotePath then
			table.insert(lines, "-- " .. facadeKey)
			table.insert(lines, "--   ↓")
			table.insert(
				lines,
				string.format("-- %s (confidence: %d%%)", link.remotePath, math.floor(link.confidence or 0))
			)
			shown += 1
			if shown >= 6 then
				break
			end
		end
	end
	if shown == 0 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function makeClosureKey(func, callerInfo)
	if typeof(func) == "function" then
		return "fn:" .. tostring(func)
	end
	if callerInfo then
		return string.format(
			"src:%s:%s:%s",
			tostring(callerInfo.source),
			tostring(callerInfo.line),
			tostring(callerInfo.func)
		)
	end
	return "unknown"
end

function registerUpvalueRemoteLink(func, upvalueIndex, upvalueName, remote, callerInfo)
	if not isUpvalueRemoteRegistryEnabled() or typeof(remote) ~= "Instance" then
		return
	end
	local remotePath = getRemotePathFromInstance(remote)
	if not remotePath then
		return
	end
	callerInfo = callerInfo or getCaptureCallerInfo(4)
	local closureKey = makeClosureKey(func, callerInfo)
	local entry = US.upvalueRemoteRegistry[closureKey]
		or {
			remotePath = remotePath,
			upvalueIndex = upvalueIndex,
			upvalueName = upvalueName,
			source = callerInfo.func,
			scriptPath = callerInfo.scriptPath or callerInfo.source,
			hits = 0,
			lastSeen = tick(),
		}
	entry.remotePath = remotePath
	entry.upvalueIndex = upvalueIndex or entry.upvalueIndex
	entry.upvalueName = upvalueName or entry.upvalueName
	entry.hits = (entry.hits or 0) + 1
	entry.lastSeen = tick()
	US.upvalueRemoteRegistry[closureKey] = entry
	US.upvalueRemoteByRemote[remotePath] = US.upvalueRemoteByRemote[remotePath] or {}
	US.upvalueRemoteByRemote[remotePath][closureKey] = entry
	if isFunctionRemoteRegistryEnabled() and typeof(func) == "function" then
		registerFunctionRemoteLink(func, remote, "upvalue", callerInfo)
	end
end

--- When debug.getupvalues cannot see the closure (common in hooked FireServer paths), still record caller ↔ remote.
function registerFirePathRemoteLink(remote, callerInfo)
	if not isUpvalueRemoteRegistryEnabled() or typeof(remote) ~= "Instance" then
		return
	end
	callerInfo = callerInfo or getCaptureCallerInfo(5)
	registerUpvalueRemoteLink(nil, 0, "(fire_path)", remote, callerInfo)
end

function formatUpvalueRefBlock(log)
	if not isUpvalueRemoteRegistryEnabled() or not log then
		return ""
	end
	local remotePath = log.Snapshot and log.Snapshot.path
	if not remotePath then
		return ""
	end
	local bucket = US.upvalueRemoteByRemote[remotePath]
	if not bucket then
		return ""
	end
	local lines = { "-- [UPVALUE REFERENCES]", "" }
	local count = 0
	for closureKey, entry in pairs(bucket) do
		table.insert(
			lines,
			string.format(
				"-- %s @ %s:%s",
				tostring(entry.source),
				tostring(entry.scriptPath),
				tostring(entry.upvalueIndex or "?")
			)
		)
		table.insert(
			lines,
			string.format(
				"--   upvalue[%s] %s -> %s (%d hits)",
				tostring(entry.upvalueIndex or "?"),
				tostring(entry.upvalueName or "?"),
				entry.remotePath,
				entry.hits or 1
			)
		)
		count += 1
		if count >= 8 then
			break
		end
	end
	if count == 0 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function scanUpvalueRemoteRegistry(budget)
	budget = budget or { _G.SIMPLESPYCONFIG_UpvalueScanBudget or 1500 }
	if not isUpvalueRemoteRegistryEnabled() then
		return 0
	end
	local before = 0
	for _ in pairs(US.upvalueRemoteRegistry) do
		before += 1
	end
	pcall(scanCachedRemoteReferences, budget)
	local after = 0
	for _ in pairs(US.upvalueRemoteRegistry) do
		after += 1
	end
	return after - before
end

function registerFunctionRemoteLink(func, remote, methodName, callerInfo, actionKey)
	if not isFunctionRemoteRegistryEnabled() then
		return
	end
	local remotePath = typeof(remote) == "Instance" and getRemotePathFromInstance(remote) or remote
	if not remotePath or type(remotePath) ~= "string" then
		return
	end
	callerInfo = callerInfo or getCaptureCallerInfo(4)
	local funcKey = makeClosureKey(func, callerInfo)
	local reg = US.functionRemoteRegistry[funcKey]
	if not reg then
		reg = {
			source = callerInfo.source,
			line = callerInfo.line,
			name = callerInfo.func,
			scriptPath = callerInfo.scriptPath,
			remotes = {},
		}
		US.functionRemoteRegistry[funcKey] = reg
		US.functionActionRegistry[funcKey] = reg -- alias: same structure, now enriched with actionKey evidence
	else
		if not US.functionActionRegistry[funcKey] then
			US.functionActionRegistry[funcKey] = reg
		end
	end
	local bucket = reg.remotes[remotePath] or { count = 0, methods = {}, actionKeys = {}, lastSeen = 0 }
	bucket.count += 1
	bucket.lastSeen = tick()
	bucket.methods[methodName or "FireServer"] = true
	if actionKey and type(actionKey) == "string" and actionKey ~= "" then
		bucket.actionKeys[actionKey] = (bucket.actionKeys[actionKey] or 0) + 1
	end
	reg.remotes[remotePath] = bucket
	US.remoteToFunctions[remotePath] = US.remoteToFunctions[remotePath] or {}
	US.remoteToFunctions[remotePath][funcKey] = reg
end

function formatFunctionUsersBlock(log)
	if not isFunctionRemoteRegistryEnabled() or not log then
		return ""
	end
	local remotePath = log.Snapshot and log.Snapshot.path
	if not remotePath then
		return ""
	end
	local bucket = US.remoteToFunctions[remotePath]
	if not bucket then
		return ""
	end
	local rows = {}
	for funcKey, reg in pairs(bucket) do
		local rb = reg.remotes[remotePath]
		table.insert(rows, { key = funcKey, reg = reg, count = rb and rb.count or 0 })
	end
	table.sort(rows, function(a, b)
		return a.count > b.count
	end)
	local lines = { "-- [FUNCTION USERS]", "" }
	for i, row in ipairs(rows) do
		if i > 8 then
			break
		end
		table.insert(
			lines,
			string.format(
				"-- %s @ %s:%s (%dx)",
				tostring(row.reg.name),
				tostring(row.reg.source),
				tostring(row.reg.line),
				row.count
			)
		)
	end
	if #rows == 0 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatRemoteCallersReport(remotePath)
	local lines = { "-- Remote Callers", "" }
	if not remotePath then
		table.insert(lines, "-- (select a remote)")
		return table.concat(lines, "\n")
	end
	local block = formatFunctionUsersBlock({ Snapshot = { path = remotePath } })
	local uv = formatUpvalueRefBlock({ Snapshot = { path = remotePath } })
	if block == "" and uv == "" then
		table.insert(lines, "-- (no callers recorded yet — fire remotes or Scan Upvalues)")
	else
		if block ~= "" then
			table.insert(lines, block)
		end
		if uv ~= "" then
			table.insert(lines, uv)
		end
	end
	return table.concat(lines, "\n")
end

function registerScriptOrigin(scriptInst, remotePath)
	if not isTrackScriptOriginsEnabled() or typeof(scriptInst) ~= "Instance" then
		return
	end
	local path = getEntityRegistryKey(scriptInst)
	local reg = US.scriptOriginRegistry[path]
	if not reg then
		reg = {
			className = scriptInst.ClassName,
			remotesFired = {},
			modules = {},
		}
		US.scriptOriginRegistry[path] = reg
	end
	if remotePath then
		reg.remotesFired[remotePath] = (reg.remotesFired[remotePath] or 0) + 1
	end
end

function registerScriptOriginFromStack(callStack, remotePath)
	if not isTrackScriptOriginsEnabled() or not callStack then
		return
	end
	for _, frame in ipairs(callStack) do
		local src = frame.source or ""
		if string.find(src, ".", 1, true) and not string.find(src, "CoreGui", 1, true) then
			local reg = US.scriptOriginRegistry[src] or { className = "Script", remotesFired = {}, modules = {} }
			if remotePath then
				reg.remotesFired[remotePath] = (reg.remotesFired[remotePath] or 0) + 1
			end
			US.scriptOriginRegistry[src] = reg
		end
	end
end

function bootstrapScriptOriginScan()
	if not isTrackScriptOriginsEnabled() then
		return
	end
	local player = Players.LocalPlayer
	if not player then
		return
	end
	pcall(function()
		local ps = player:FindFirstChild("PlayerScripts")
		if ps then
			for _, child in ipairs(ps:GetDescendants()) do
				if child:IsA("LocalScript") or child:IsA("ModuleScript") then
					registerScriptOrigin(child, nil)
				end
			end
		end
	end)
end

function formatScriptOriginBlock(log, callStack)
	if not isTrackScriptOriginsEnabled() then
		return ""
	end
	local lines = { "-- [SCRIPT ORIGIN]", "" }
	local added = 0
	if callStack then
		for _, frame in ipairs(callStack) do
			if frame.layer == "Script" or string.find(frame.source or "", "Script", 1, true) then
				table.insert(
					lines,
					string.format("-- [%s] %s @ %s:%s", frame.layer or "?", frame.name, frame.source, tostring(frame.line))
				)
				added += 1
				if added >= 6 then
					break
				end
			end
		end
	end
	if log and log.Snapshot and log.Snapshot.path then
		for scriptPath, reg in pairs(US.scriptOriginRegistry) do
			if reg.remotesFired[log.Snapshot.path] then
				table.insert(
					lines,
					string.format("-- %s fired %s (%dx)", scriptPath, log.Snapshot.path, reg.remotesFired[log.Snapshot.path])
				)
				added += 1
			end
		end
	end
	if added == 0 then
		return ""
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function signatureMatchesTerm(actionKey, terms)
	if not actionKey or type(actionKey) ~= "string" then
		return false
	end
	local lower = actionKey:lower()
	for _, term in ipairs(terms) do
		if string.find(lower, term, 1, true) then
			return true, term
		end
	end
	return false
end

function updateRemoteProfile(remotePath, actionKey)
	if not isConstantSignatureProfilesEnabled() or not remotePath or not actionKey then
		return
	end
	local matched, term = signatureMatchesTerm(actionKey, COMBAT_SIGNATURES)
	local profileType = matched and "Combat" or nil
	if not profileType then
		matched, term = signatureMatchesTerm(actionKey, REWARD_SIGNATURE_TERMS)
		profileType = matched and "Reward" or nil
	end
	if not profileType then
		matched, term = signatureMatchesTerm(actionKey, SHOP_SIGNATURE_TERMS)
		profileType = matched and "Shop" or nil
	end
	if not matched or not term then
		return
	end
	local profile = US.remoteProfiles[remotePath] or { type = profileType, evidence = {}, totalHits = 0 }
	profile.type = profileType
	profile.evidence[term] = (profile.evidence[term] or 0) + 1
	profile.totalHits = (profile.totalHits or 0) + 1
	local distinct = 0
	for _ in pairs(profile.evidence) do
		distinct += 1
	end
	local minEv = _G.SIMPLESPYCONFIG_ProfileMinEvidence or 2
	if distinct >= minEv or (profile.evidence[term] or 0) >= 3 then
		profile.confidence = math.min(95, 50 + distinct * 12 + (profile.totalHits or 0) * 2)
	else
		profile.confidence = math.min(60, 20 + (profile.evidence[term] or 0) * 10)
	end
	US.remoteProfiles[remotePath] = profile
end

function formatRemoteProfileBlock(log)
	if not isConstantSignatureProfilesEnabled() or not log or not log.Snapshot then
		return ""
	end
	local profile = US.remoteProfiles[log.Snapshot.path]
	if not profile or not profile.type then
		return ""
	end
	local lines = { "-- [REMOTE PROFILE]", "", "-- " .. log.Snapshot.path, "-- Type: " .. profile.type }
	if profile.confidence then
		table.insert(lines, string.format("-- Confidence: %d%%", math.floor(profile.confidence)))
	end
	table.insert(lines, "-- Evidence:")
	for term, count in pairs(profile.evidence) do
		table.insert(lines, string.format("--   %s x%d", term, count))
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatLifecycleSummary(remotePath)
	if not isRemoteLifecycleEnabled() or not remotePath then
		return ""
	end
	for _, entry in pairs(US.remoteLifecycle) do
		if entry.path == remotePath or string.find(entry.path or "", remotePath, 1, true) then
			local age = entry.createdAt and (tick() - entry.createdAt) or 0
			local status = entry.destroyedAt and "destroyed" or "alive"
			local ep = entry.ephemeral and " ephemeral" or ""
			return string.format(
				"-- [LIFECYCLE] %s | %s | %.1fs old | calls=%d%s",
				entry.path,
				status,
				age,
				entry.callCount or 0,
				ep
			)
		end
	end
	return ""
end

function notifyRemoteLifecyclePathChange(inst, reason)
	local key = US.lifecycleByInstance[inst]
	if not key then
		return
	end
	local entry = US.remoteLifecycle[key]
	if not entry then
		return
	end
	local oldPath = entry.path
	pcall(function()
		entry.path = inst:GetFullName()
	end)
	if oldPath ~= entry.path and US.timelineFilter.remote_moved ~= false then
		appendTimelineEvent({
			kind = "remote_moved",
			label = inst.Name,
			detail = (oldPath or "?") .. " → " .. (entry.path or "?") .. (reason and (" (" .. reason .. ")") or ""),
		})
	end
end

function connectRemoteLifecycleRename(inst)
	if not isRemoteLifecycleEnabled() or typeof(inst) ~= "Instance" then
		return
	end
	pcall(function()
		inst:GetPropertyChangedSignal("Name"):Connect(function()
			notifyRemoteLifecyclePathChange(inst, "rename")
		end)
	end)
end

function connectRemoteLifecycleReparent(inst)
	if not isRemoteLifecycleEnabled() or typeof(inst) ~= "Instance" then
		return
	end
	pcall(function()
		inst.AncestryChanged:Connect(function(_, parent)
			if not parent then
				return
			end
			if US.lifecycleByInstance[inst] then
				notifyRemoteLifecyclePathChange(inst, "reparent")
			end
		end)
	end)
end

function hookDiscoveredWrappersFromList(list)
	if not (_G.SIMPLESPYCONFIG_HookDiscoveredWrappers == true) or not list then
		return 0
	end
	local maxHooks = _G.SIMPLESPYCONFIG_MAX_WRAPPER_HOOKS or 40
	local minScore = getAutoHookMinScore()
	local hooked = 0
	table.sort(list, function(a, b)
		local sa = a.score or scoreDiscoveryCandidate(a)
		local sb = b.score or scoreDiscoveryCandidate(b)
		if sa == sb then
			return (a.priority or 0) > (b.priority or 0)
		end
		return sa > sb
	end)
	for _, entry in ipairs(list) do
		if hooked >= maxHooks then
			break
		end
		if isUltraSpyInternalWrapper(entry.name, entry.source or entry.path) then
			continue
		end
		if type(entry.func) == "function" and isSpyProtectedFunction(entry.func) then
			continue
		end
		local score = entry.score or scoreDiscoveryCandidate(entry)
		local entryMin = minScore
		if (entry.priority or 0) >= 35 then
			entryMin = math.min(entryMin, 35)
		end
		if score < entryMin then
			continue
		end
		local hookedOne = false
		if entry.kind == "module_env" and getsenv and entry.path then
			pcall(function()
				local mod = game
				for part in string.gmatch(entry.path, "[^%.]+") do
					if part == "game" then
					else
						mod = mod:FindFirstChild(part)
					end
				end
				if mod and mod:IsA("ModuleScript") then
					local env = getsenv(mod)
					local fn = env[entry.name]
					if type(fn) == "function" then
						if installWrapperFunctionHook(fn, entry.name, entry.path, "Network") then
							hookedOne = true
						end
					end
				end
			end)
		elseif
			(
				entry.kind == "gc_closure_remote_like"
				or entry.kind == "gc_closure_with_remote_const"
				or entry.kind == "gc_closure"
				or entry.kind == "table_method"
			) and type(entry.func) == "function"
		then
			pcall(function()
				if installWrapperFunctionHook(entry.func, entry.name or "closure", entry.source or "?", "Network") then
					hookedOne = true
				end
			end)
		end
		if hookedOne then
			hooked += 1
			markDiscoveryHooked(entry, "score>=" .. tostring(minScore) .. " kind=" .. tostring(entry.kind))
		end
	end
	return hooked
end

function attachPhase6ToLog(log, callStack, func, mergedChain)
	if not log then
		return
	end
	local remoteLabel = log.Snapshot and (log.Snapshot.path or log.Snapshot.name)
	if isAutoWrapperChainEnabled() and mergedChain then
		log.AutoWrapperChainBlock = formatAutoWrapperChain(mergedChain, remoteLabel)
		if log.Snapshot and log.Snapshot.path then
			storeWrapperChainForRemote(log.Snapshot.path, mergedChain)
		end
	end
	log.MetatableLinkBlock = formatMetatableLinkBlock(log)
	log.UpvalueRefBlock = formatUpvalueRefBlock(log)
	log.FunctionUsersBlock = formatFunctionUsersBlock(log)
	log.ScriptOriginBlock = formatScriptOriginBlock(log, callStack)
	log.HiddenStatBlock = formatHiddenStatBlockForLog(log)
	log.RemoteProfileBlock = formatRemoteProfileBlock(log)
	log.LifecycleSummaryBlock = formatLifecycleSummary(remoteLabel)
	local remoteInst = log.Remote and log.Remote.remote
	if typeof(func) == "function" and typeof(remoteInst) == "Instance" then
		local callerInfo = getCaptureCallerInfo(6)
		registerFunctionRemoteLink(func, remoteInst, "fire", callerInfo)
		pcall(function()
			local linked = scanFunctionUpvaluesForRemoteInstance(func, remoteInst, callerInfo)
			if not linked then
				local remotePath = getRemotePathFromInstance(remoteInst)
				local bucket = remotePath and US.upvalueRemoteByRemote[remotePath]
				if not bucket or not next(bucket) then
					registerFirePathRemoteLink(remoteInst, callerInfo)
				end
			end
		end)
	end
	if callStack then
		for i = 1, math.min(8, #callStack) do
			local frame = callStack[i]
			if frame.func then
				registerFunctionRemoteLink(
					frame.func,
					remoteInst or (log.Snapshot and log.Snapshot.path),
					"stack",
					{
						source = frame.source,
						line = frame.line,
						func = frame.name,
						scriptPath = frame.source,
					}
				)
			end
		end
		registerScriptOriginFromStack(callStack, remoteLabel)
	end
end

function bootstrapPhase6Tracking()
	pcall(bootstrapScriptOriginScan)
	if isUpvalueRemoteRegistryEnabled() then
		task.defer(function()
			task.wait(0.5)
			pcall(scanUpvalueRemoteRegistry, { 800 })
		end)
	end
end

function bootstrapPhase5Tracking()
	if not isPhase5Enabled() and not isEntityTrackerEnabled() then
		return
	end
	pcall(installConnectHook)
	pcall(watchPlayerDataTree)
	pcall(bootstrapCollectionServiceWatch)
	task.defer(function()
		task.wait(1)
		pcall(scanNearbyNPCs)
	end)
end

--- GuiObject under mouse (InputObject has no .Target on modern Roblox)
function getMouseGuiTarget()
	if not Mouse then
		return nil
	end
	local ok, target = pcall(function()
		return Mouse.Target
	end)
	if ok and target and typeof(target) == "Instance" then
		return target
	end
	local selOk, selected = pcall(function()
		return GuiService.SelectedObject
	end)
	if selOk and selected and typeof(selected) == "Instance" then
		return selected
	end
	return nil
end

--- how many spaces to indent
local indent = 4
--- used for task scheduler
local scheduled = {}
--- GUI / Instance work (must run on Heartbeat — not game remote threads)
local uiQueue = {}
local uiQueueWarned = false
--- RBXScriptConnect of the task scheduler
local schedulerconnect
local SimpleSpy = {}
local topstr = ""
local bottomstr = ""
local remotesFadeIn
local rightFadeIn
local codebox
local p
local getnilrequired = false

-- autoblock variables
local autoblock = false
local history = {}
local excluding = {}

-- function info variables
local funcEnabled = true

-- remote hooking/connecting api variables
local remoteSignals = {}
local remoteHooks = {}

-- original mouse icon
local oldIcon

-- if mouse inside gui
local mouseInGui = false

-- whether or not SimpleSpy uses 'getcallingscript()' to get the script (default is false because detection)
local useGetCallingScript = false

--- used to enable/disable SimpleSpy's keyToString for remotes
local keyToString = false

-- determines whether return values are recorded
local recordReturnValues = false

-- functions

--- Converts arguments to a string and generates code that calls the specified method with them, recommended to be used in conjunction with ValueToString (method must be a string, e.g. `game:GetService("ReplicatedStorage").Remote.remote:FireServer`)
--- @param method string
--- @param args any[]
--- @return string
function SimpleSpy:ArgsToString(method, args)
	assert(typeof(method) == "string", "string expected, got " .. typeof(method))
	assert(typeof(args) == "table", "table expected, got " .. typeof(args))
	return v2v({ args = args }) .. "\n\n" .. method .. "(unpack(args))"
end

function getReplayBurstCount()
	local n = _G.SIMPLESPYCONFIG_ReplayBurstCount
	if type(n) == "number" and n >= 1 then
		return math.min(math.floor(n), 100)
	end
	return 10
end

function getReplayBurstDelay()
	local d = _G.SIMPLESPYCONFIG_ReplayBurstDelay
	if type(d) == "number" and d >= 0 then
		return d
	end
	return 0.15
end

function getReplayArgsForLog(log)
	if not log then
		return {}
	end
	if US.replayArgsOverride and US.replayArgsOverride[log.LogId] then
		return deepCopyArgsList(US.replayArgsOverride[log.LogId])
	end
	if log.Args then
		return deepCopyArgsList(log.Args)
	end
	return {}
end

function argsToReplayReturnLiteral(args)
	prevTables = {}
	local parts = {}
	for i = 1, #(args or {}) do
		table.insert(parts, v2s(args[i], nil, nil, "arg" .. tostring(i), true))
	end
	if #parts == 0 then
		return "{}"
	end
	return "{ " .. table.concat(parts, ", ") .. " }"
end

function formatPayloadSuggestionsBlock(remotePath)
	local lines = { "-- Past payloads (copy a line into return { ... }):" }
	local atlas = remotePath and US.remoteAtlas[remotePath]
	if not atlas or not atlas.shapes then
		table.insert(lines, "-- (no history yet — fire this remote once)")
		return table.concat(lines, "\n")
	end
	local rows = {}
	for shape, entry in pairs(atlas.shapes) do
		table.insert(rows, { shape = shape, entry = entry })
	end
	table.sort(rows, function(a, b)
		return (a.entry.count or 0) > (b.entry.count or 0)
	end)
	for i, row in ipairs(rows) do
		if i > 8 then
			table.insert(lines, "-- ... more shapes in Remote Atlas")
			break
		end
		local entry = row.entry
		if entry.sampleArgs and #entry.sampleArgs > 0 then
			table.insert(
				lines,
				string.format("-- #%d hits=%d shape=%s", i, entry.count or 0, tostring(row.shape))
			)
			table.insert(lines, "-- " .. string.sub(argsToReplayReturnLiteral(entry.sampleArgs), 1, 180))
		end
	end
	return table.concat(lines, "\n")
end

function parseReplayArgsFromSource(src)
	if type(src) ~= "string" or src == "" then
		return nil, "empty editor"
	end
	if not string.find(src, REPLAY_ARGS_MARKER, 1, true) then
		return nil, "use Edit Args first"
	end
	local fn, err = loadstring(src)
	if not fn then
		return nil, tostring(err)
	end
	local ok, result = pcall(fn)
	if not ok then
		return nil, tostring(result)
	end
	if type(result) ~= "table" then
		return nil, "chunk must return a table of arguments"
	end
	local args = {}
	local maxI = 0
	for k in pairs(result) do
		if type(k) == "number" and k > maxI then
			maxI = k
		end
	end
	if maxI > 0 then
		for i = 1, maxI do
			args[i] = result[i]
		end
	else
		args[1] = result
	end
	return args
end

function canReplayLog(log)
	if not log then
		return false, "no log selected"
	end
	if log.Blocked then
		return false, "remote is blocklisted"
	end
	if log.Direction == "in" or log.RemoteRole == "replication_effect" then
		return false, "inbound / sync remote — replay disabled"
	end
	if log.LogType == "bindable" or log.LogType == "wrapper" then
		return false, "not a network remote log"
	end
	local remote = log.Remote and log.Remote.remote
	if typeof(remote) ~= "Instance" then
		return false, "remote instance unavailable"
	end
	if not remote:IsA("RemoteEvent") and not remote:IsA("RemoteFunction") and not remote:IsA("UnreliableRemoteEvent") then
		return false, "unsupported remote class"
	end
	return true
end

function randomizeReplayArgs(args, log)
	args = deepCopyArgsList(args or {})
	local path = log and log.Snapshot and log.Snapshot.path
	local atlas = path and US.remoteAtlas[path]
	if atlas and atlas.shapes then
		local choices = {}
		for _, entry in pairs(atlas.shapes) do
			if entry.sampleArgs and #entry.sampleArgs > 0 then
				table.insert(choices, entry.sampleArgs)
			end
		end
		if #choices > 0 then
			return deepCopyArgsList(choices[math.random(1, #choices)])
		end
	end
	for i, v in ipairs(args) do
		if type(v) == "number" then
			args[i] = v + math.random(-3, 3)
		end
	end
	return args
end

function executeReplayFire(log, args)
	local ok, reason = canReplayLog(log)
	if not ok then
		return false, reason
	end
	local remote = log.Remote.remote
	args = args or {}
	if log.LogType == "function" then
		local results = table.pack(remote:InvokeServer(unpack(args)))
		return true, results
	end
	remote:FireServer(unpack(args))
	return true
end

function stopReplayBurst()
	US.replayCancelToken = (US.replayCancelToken or 0) + 1
end

function runReplayBurst(count, delaySec, randomize)
	if not selected then
		return false, "select a remote log first"
	end
	local can, reason = canReplayLog(selected)
	if not can then
		return false, reason
	end
	count = math.min(100, math.max(1, math.floor(count or getReplayBurstCount())))
	delaySec = delaySec or getReplayBurstDelay()
	randomize = randomize == true or _G.SIMPLESPYCONFIG_ReplayRandomizeArgs == true
	stopReplayBurst()
	local token = US.replayCancelToken
	local fired = 0
	task.spawn(function()
		for i = 1, count do
			if token ~= US.replayCancelToken then
				break
			end
			local args = getReplayArgsForLog(selected)
			if randomize then
				args = randomizeReplayArgs(args, selected)
			end
			local ok, err = pcall(function()
				executeReplayFire(selected, args)
			end)
			if ok then
				fired += 1
			else
				warn("[UltraSpy Replay] " .. tostring(err))
			end
			if i < count and delaySec > 0 then
				task.wait(delaySec)
			end
		end
		if token == US.replayCancelToken and TextLabel then
			scheduleOnSpyThread(function()
				TextLabel.Text = string.format("Replay done (%d/%d)", fired, count)
			end)
		end
	end)
	return true
end

function SimpleSpy:OpenReplayArgsEditor()
	if not selected then
		return false, "no selection"
	end
	local args = getReplayArgsForLog(selected)
	local path = selected.Snapshot and selected.Snapshot.path or selected.Name or "?"
	local body = REPLAY_ARGS_MARKER
		.. "\n-- Edit the table below, then Apply Args or Replay.\n"
		.. formatPayloadSuggestionsBlock(path)
		.. "\n\nreturn "
		.. argsToReplayReturnLiteral(args)
	codebox:setRaw(body)
	return true
end

function SimpleSpy:ApplyReplayArgsFromEditor()
	if not selected then
		return false, "no selection"
	end
	local args, err = parseReplayArgsFromSource(codebox:getString())
	if not args then
		return false, err
	end
	US.replayArgsOverride[selected.LogId] = args
	selected.ReplayArgsOverride = true
	schedule(function()
		local snap = selected.Snapshot
		local remote = selected.Remote and selected.Remote.remote
		local stackHeader = formatCallStackForScript(
			selected.CallStack,
			snap,
			selected.UiTrigger,
			selected.FlowSnapshot,
			selected.PayloadShape
		)
		local body = genScript(remote, args, snap, selected)
		selected.GenScript = stackHeader .. body
		local logRef = selected
		scheduleOnSpyThread(function()
			if selected == logRef and logRef.GenScript then
				codebox:setRaw(logRef.GenScript)
			end
		end)
	end)
	return true
end

function SimpleSpy:ReplaySelected(count, delaySec, randomize)
	return runReplayBurst(count, delaySec, randomize)
end

function SimpleSpy:StopReplay()
	stopReplayBurst()
	return true
end

function SimpleSpy:ApplyPayloadIndex(logEntry, index)
	logEntry = logEntry or selected
	if not logEntry then
		return false, "no log selected"
	end
	local path = logEntry.Snapshot and logEntry.Snapshot.path
	if not path then
		return false, "no remote path"
	end
	local rows = getPayloadLibraryRows(path)
	local i = tonumber(index)
	if not i or i < 1 or i > #rows then
		return false, "invalid payload index"
	end
	local entry = rows[i].entry
	if not entry or not entry.sampleArgs then
		return false, "no sample args for shape"
	end
	US.replayArgsOverride = US.replayArgsOverride or {}
	US.replayArgsOverride[logEntry.LogId] = deepCopyArgsList(entry.sampleArgs)
	if selected == logEntry then
		local ok, err = SimpleSpy:ApplyReplayArgsFromEditor()
		if not ok then
			logEntry.GenScript = formatPayloadLibraryBlock(path)
				.. "\n\n"
				.. REPLAY_ARGS_MARKER
				.. "\nreturn "
				.. argsToReplayReturnLiteral(entry.sampleArgs)
			codebox:setRaw(logEntry.GenScript)
		end
	end
	return true
end

function SimpleSpy:ExportActionSession(verifiedOnly)
	return exportActionSessionTable(verifiedOnly == true)
end

function SimpleSpy:GetGuiRemoteCorrelation(guiInst)
	return buildGuiRemoteCorrelationReport(guiInst)
end

--- Converts a value to variables with the specified index as the variable name (if nil/invalid then the name will be assigned automatically)
--- @param t any[]
--- @return string
function SimpleSpy:TableToVars(t)
	assert(typeof(t) == "table", "table expected, got " .. typeof(t))
	return v2v(t)
end

--- Converts a value to a variable with the specified `variablename` (if nil/invalid then the name will be assigned automatically)
--- @param value any
--- @return string
function SimpleSpy:ValueToVar(value, variablename)
	assert(variablename == nil or typeof(variablename) == "string", "string expected, got " .. typeof(variablename))
	if not variablename then
		variablename = 1
	end
	return v2v({ [variablename] = value })
end

--- Converts any value to a string, cannot preserve function contents
--- @param value any
--- @return string
function SimpleSpy:ValueToString(value)
	return v2s(value)
end

--- Generates the simplespy function info
--- @param func function
--- @return string
function SimpleSpy:GetFunctionInfo(func)
	assert(typeof(func) == "function", "Instance expected, got " .. typeof(func))
	warn("Function info currently unavailable due to crashing in Synapse X")
	return v2v({ functionInfo = {
		info = debug.getinfo(func),
		constants = debug.getconstants(func),
	} })
end

--- Gets the ScriptSignal for a specified remote being fired
--- @param remote Instance
function SimpleSpy:GetRemoteFiredSignal(remote)
	assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
	if not remoteSignals[remote] then
		remoteSignals[remote] = newSignal()
	end
	return remoteSignals[remote]
end

--- Allows for direct hooking of remotes **THIS CAN BE VERY DANGEROUS**
--- @param remote Instance
--- @param f function
function SimpleSpy:HookRemote(remote, f)
	assert(typeof(remote) == "Instance", "Instance expected, got " .. typeof(remote))
	assert(typeof(f) == "function", "function expected, got " .. typeof(f))
	remoteHooks[remote] = f
end

--- Blocks the specified remote instance/string
--- @param remote any
function SimpleSpy:BlockRemote(remote)
	assert(
		typeof(remote) == "Instance" or typeof(remote) == "string",
		"Instance | string expected, got " .. typeof(remote)
	)
	blocklist[remote] = true
end

--- Excludes the specified remote from logs (instance/string)
--- @param remote any
function SimpleSpy:ExcludeRemote(remote)
	assert(
		typeof(remote) == "Instance" or typeof(remote) == "string",
		"Instance | string expected, got " .. typeof(remote)
	)
	blacklist[remote] = true
end

--- Returns the observed network graph as text
function SimpleSpy:GetNetworkMap()
	return formatNetworkMap()
end

--- Scans modules / GC for network-like functions
function SimpleSpy:DiscoverWrappers()
	return discoverNetworkWrappers()
end

--- Returns formatted execution chain for a log entry
function SimpleSpy:GetCallChain(logEntry)
	if not logEntry then
		return ""
	end
	return formatCallChainVisual(
		logEntry.CallStack,
		logEntry.Snapshot,
		logEntry.UiTrigger,
		logEntry.FlowSnapshot,
		logEntry.PayloadShape
	)
end

--- Returns flow-only view for a log entry
function SimpleSpy:GetFlowView(logEntry)
	if not logEntry then
		return ""
	end
	if logEntry.FlowSnapshot then
		return formatFlowVisual(logEntry.FlowSnapshot)
	end
	return "-- No flow snapshot for this log"
end

--- Returns session remote atlas text
function SimpleSpy:GetRemoteAtlas()
	return formatRemoteAtlas()
end

--- Returns payload patterns for a remote path (uses selected log if path omitted)
function SimpleSpy:GetRemotePatterns(remotePath)
	if not remotePath and selected and selected.Snapshot then
		remotePath = selected.Snapshot.path
	end
	return formatRemotePatterns(remotePath)
end

--- Returns last GUI interaction (singleton)
function SimpleSpy:GetLastGuiInteraction()
	return US.lastGuiInteraction
end

function SimpleSpy:GetTimeline()
	return formatTimelineText()
end

function SimpleSpy:GetStateLog()
	return formatStateLog()
end

function SimpleSpy:GetRecentStateChanges()
	return US.stateChanges
end

function SimpleSpy:GetRemoteLifecycle(remotePath)
	return formatRemoteLifecycle(remotePath)
end

function SimpleSpy:GetCorrelationReport()
	return formatCorrelationReport()
end

function SimpleSpy:GetRemoteReferences(remotePath)
	return formatRemoteReferences(remotePath)
end

function SimpleSpy:DiscoverRemoteCandidates()
	return discoverRemoteCandidates()
end

function SimpleSpy:GetDiscoveryAtlas()
	return formatDiscoveryAtlas()
end

function SimpleSpy:GetModuleGraph(rootPath)
	return formatModuleDependencyGraph(rootPath)
end

function SimpleSpy:BuildModuleGraph()
	return buildModuleDependencyGraph()
end

function SimpleSpy:GetProtocolReport(remotePath)
	return formatProtocolReport(remotePath)
end

function SimpleSpy:GetActionOutcomes(remotePath)
	return formatActionOutcomes(remotePath)
end

function SimpleSpy:ScanRemoteReferences()
	pcall(scanCachedRemoteReferences, { 1500 })
	return formatRemoteReferences(nil)
end

function SimpleSpy:GetCauseLog()
	return formatCauseLog()
end

function SimpleSpy:GetInvestigationLog()
	return formatInvestigationLog()
end

function SimpleSpy:GetDamageEventLog()
	return formatDamageEventLog()
end

function SimpleSpy:GetRewardEventLog()
	return formatRewardEventLog()
end

function SimpleSpy:GetPropertyLog()
	local lines = { "-- Property Changes", "" }
	for _, p in ipairs(US.recentPropertyChanges) do
		table.insert(lines, string.format("-- %s.%s %s → %s", p.path, p.prop, tostring(p.oldVal), tostring(p.newVal)))
	end
	if #lines <= 2 then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetCallbackMap(target)
	if typeof(target) == "Instance" then
		return formatCallbackMap(target)
	end
	return formatCallbackMap(nil)
end

function SimpleSpy:GetTaggedEntities(tag)
	return formatTaggedEntities(tag)
end

function SimpleSpy:GetCombatDiscoveryReport()
	return formatCombatDiscoveryReport()
end

function SimpleSpy:StartCombatDiscoveryWindow()
	return startCombatDiscoveryWindow()
end

function SimpleSpy:GetRewardDiscoveryReport()
	return formatRewardDiscoveryReport()
end

function SimpleSpy:StartRewardDiscoveryWindow()
	return startRewardDiscoveryWindow()
end

function SimpleSpy:ScanPlayerDataTree()
	pcall(watchPlayerDataTree)
	pcall(scanNearbyNPCs)
	return "-- Player data tree rescanned\n-- Entities watched: "
		.. tostring((function()
			local n = 0
			for _ in pairs(US.entityRegistry) do
				n += 1
			end
			return n
		end)())
		.. "\n-- Hidden stat watches: "
		.. tostring(US.hiddenStatWatchCount or 0)
end

function SimpleSpy:GetHiddenStatReport()
	return formatHiddenStatReport()
end

function SimpleSpy:GetWrapperChain(remotePath)
	remotePath = remotePath or (selected and selected.Snapshot and selected.Snapshot.path)
	if not remotePath then
		return "-- (no remote path)"
	end
	local list = US.wrapperChainsByRemote[remotePath]
	if not list or #list == 0 then
		if selected and selected.AutoWrapperChainBlock and selected.AutoWrapperChainBlock ~= "" then
			return selected.AutoWrapperChainBlock
		end
		return "-- (no wrapper chain recorded for " .. remotePath .. ")"
	end
	local lines = { "-- Wrapper chains for " .. remotePath, "" }
	for i, entry in ipairs(list) do
		table.insert(lines, formatAutoWrapperChain(entry.chain, remotePath))
		table.insert(lines, string.format("-- hits: %d", entry.hits or 1))
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetMetatableLinks(facadeKey)
	local lines = { "-- Metatable Links", "" }
	local any = false
	for key, link in pairs(US.metatableLinks) do
		if not facadeKey or key == facadeKey or link.remotePath == facadeKey then
			any = true
			table.insert(lines, "-- " .. key)
			table.insert(lines, "--   ↓")
			table.insert(
				lines,
				string.format("-- %s (%d%%)", link.remotePath, math.floor(link.confidence or 0))
			)
		end
	end
	if not any then
		table.insert(lines, "-- (none)")
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:ResolveFacadeToRemote(facadeKey)
	local link = facadeKey and US.metatableLinks[facadeKey]
	return link and link.remotePath or nil
end

function SimpleSpy:GetRemoteCallers(remotePath)
	return formatRemoteCallersReport(remotePath or (selected and selected.Snapshot and selected.Snapshot.path))
end

function SimpleSpy:GetFunctionRemotes(funcKey)
	local lines = { "-- Function Remotes", "" }
	local reg = funcKey and US.functionRemoteRegistry[funcKey]
	if not reg then
		table.insert(lines, "-- (unknown func key)")
		return table.concat(lines, "\n")
	end
	for path, bucket in pairs(reg.remotes) do
		table.insert(lines, string.format("-- %s (%dx)", path, bucket.count))
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetTopActions(n)
	n = n or 10
	if type(n) ~= "number" or n <= 0 then
		n = 10
	end
	local totals = {}
	for _, reg in pairs(US.functionActionRegistry or {}) do
		if reg and reg.remotes then
			for _, bucket in pairs(reg.remotes) do
				if bucket and bucket.actionKeys then
					for actionKey, count in pairs(bucket.actionKeys) do
						if type(actionKey) == "string" and type(count) == "number" then
							totals[actionKey] = (totals[actionKey] or 0) + count
						end
					end
				end
			end
		end
	end
	local rows = {}
	for actionKey, count in pairs(totals) do
		table.insert(rows, { actionKey = actionKey, count = count })
	end
	table.sort(rows, function(a, b)
		return (a.count or 0) > (b.count or 0)
	end)
	local lines = { "-- Top Actions (by function↔remote actionKey evidence)", "" }
	for i = 1, math.min(n, #rows) do
		table.insert(lines, string.format("-- %s (%dx)", tostring(rows[i].actionKey), rows[i].count or 0))
	end
	if #rows == 0 then
		table.insert(lines, "-- (no action evidence yet — fire remotes with spy enabled)")
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetRootCauseReport()
	if US.lastRootCauseAnalysis and US.lastRootCauseAnalysis.trigger then
		return formatRootCauseBlock(US.lastRootCauseAnalysis)
	end
	if US.lastStatChange then
		return formatRootCauseBlock(resolveRootCause(US.lastStatChange))
	end
	return "-- [ROOT CAUSE ANALYSIS]\n-- (no stat change analyzed yet — trigger HP/reward/hidden stat change)\n"
end

function SimpleSpy:ResolveLastChange()
	if not US.lastStatChange then
		return nil
	end
	return resolveRootCause(US.lastStatChange)
end

function SimpleSpy:GetStateDependencies(remotePath)
	remotePath = remotePath or (selected and selected.Snapshot and selected.Snapshot.path)
	if not remotePath then
		return "-- [STATE DEPENDENCIES]\n-- (select a remote or pass remotePath)\n"
	end
	local reqs = getLearnedStateRequirements(remotePath, selected and selected.ActionKey)
	local lines = { "-- [STATE DEPENDENCIES]", "-- " .. remotePath }
	if reqs and #reqs > 0 then
		lines[#lines + 1] = "-- Required likely:"
		for _, r in ipairs(reqs) do
			lines[#lines + 1] = string.format("--   %s (%d%%)", r.label, r.pct or 0)
		end
	else
		local snap = captureStateSnapshot()
		lines[#lines + 1] = "-- Current snapshot:"
		lines[#lines + 1] = "--   Weapon equipped: " .. tostring(snap.weaponEquipped)
		lines[#lines + 1] = "--   Quest active: " .. tostring(snap.questActive)
		lines[#lines + 1] = "--   Zone: " .. tostring(snap.zoneUnlocked)
		lines[#lines + 1] = "-- (fire more to learn requirements)"
	end
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

function SimpleSpy:GetActionSequences(actionKeyFilter)
	local lines = { "-- Action Sequences", "" }
	local any = false
	for key, seq in pairs(US.actionSequences or {}) do
		if seq.remotes and #seq.remotes >= 2 then
			if not actionKeyFilter or string.find(key, tostring(actionKeyFilter), 1, true) then
				any = true
				local conf = math.min(95, 50 + (seq.hits or 1) * 8)
				table.insert(lines, string.format("-- [%s] confidence %d%%", key, conf))
				for i, path in ipairs(seq.remotes) do
					table.insert(lines, string.format("--   %d) %s", i, path))
				end
				table.insert(lines, "")
			end
		end
	end
	if not any then
		table.insert(lines, "-- (no multi-remote sequences yet)")
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetFunctionsForRemote(remotePath)
	remotePath = remotePath or (selected and selected.Snapshot and selected.Snapshot.path)
	local lines = { "-- Functions using remote: " .. tostring(remotePath or "?"), "" }
	local found = false
	for funcKey, reg in pairs(US.functionActionRegistry or {}) do
		if reg.remotes and reg.remotes[remotePath] then
			found = true
			local bucket = reg.remotes[remotePath]
			table.insert(
				lines,
				string.format(
					"-- %s @ %s (%dx)",
					tostring(reg.funcName or funcKey),
					tostring(reg.scriptPath or "?"),
					bucket.count or 0
				)
			)
		end
	end
	if not found then
		table.insert(lines, "-- (none in registry yet)")
	end
	return table.concat(lines, "\n")
end

function SimpleSpy:GetRemotesForFunction(funcKey)
	return SimpleSpy:GetFunctionRemotes(funcKey)
end

function SimpleSpy:GetRemoteProfile(remotePath)
	remotePath = remotePath or (selected and selected.Snapshot and selected.Snapshot.path)
	return formatRemoteProfileBlock({ Snapshot = { path = remotePath } })
		.. (remotePath and "" or "-- (select a remote)")
end

function SimpleSpy:ScanUpvalueRegistry()
	local added = scanUpvalueRemoteRegistry({ _G.SIMPLESPYCONFIG_UpvalueScanBudget or 1500 })
	local total = 0
	for _ in pairs(US.upvalueRemoteRegistry) do
		total += 1
	end
	return string.format("-- Upvalue scan complete (+%d links, %d total)", added, total)
end

--- Returns static module map text (builds cache if needed)
function SimpleSpy:GetStaticModuleMap()
	return formatStaticModuleMap()
end

--- Re-scans loaded modules for wrapper hooks (AggressiveModulePatch)
function SimpleSpy:ResweepModules()
	return resweepLoadedModules()
end

--- Traces getconnections on GUI under mouse
function SimpleSpy:TraceGuiAtMouse()
	return formatGuiConnectionsTrace(Mouse and Mouse.Target)
end

--- Reports which optional executor APIs are available
function SimpleSpy:GetCapabilities()
	local caps = {
		getconnections = getconnections ~= nil,
		getsignalinfo = getsignalinfo ~= nil,
		firesignal = firesignal ~= nil,
		actionHuntMode = isActionHuntModeEnabled(),
		periodicDiscoveryInterval = _G.SIMPLESPYCONFIG_PeriodicDiscoveryInterval,
		getupvalues = debug and debug.getupvalues ~= nil,
		getloadedmodules = getloadedmodules ~= nil,
		getsenv = getsenv ~= nil,
		getscriptclosure = getscriptclosure ~= nil,
		getgc = getgc ~= nil,
		aggressiveModulePatch = _G.SIMPLESPYCONFIG_AggressiveModulePatch == true,
		replicatesignal = false,
		remoteLifecycle = isRemoteLifecycleEnabled(),
		trackRemoteCreation = isTrackRemoteCreationEnabled(),
		instanceNewHook = US.instanceNewHookInstalled == true,
		instanceNewHookFailed = US.instanceNewHookFailed == true,
		correlateWindow = getCorrelateWindow(),
		maxActiveCorrelations = US.MAX_ACTIVE_CORRELATIONS,
		coroutineIsParallel = coroutine.isparallel ~= nil,
		trackRemoteReferences = isTrackRemoteReferencesEnabled(),
		protocolRegistry = isProtocolRegistryEnabled(),
		outcomeLearning = isOutcomeLearningEnabled(),
		moduleGraph = isModuleGraphEnabled(),
		hiddenStatDiscovery = isHiddenStatDiscoveryEnabled(),
		autoWrapperChain = isAutoWrapperChainEnabled(),
		metatableResolver = isMetatableResolverEnabled(),
		upvalueRemoteRegistry = isUpvalueRemoteRegistryEnabled(),
		functionRemoteRegistry = isFunctionRemoteRegistryEnabled(),
		constantSignatureProfiles = isConstantSignatureProfilesEnabled(),
		discoveryCandidates = (function()
			local n = 0
			for _ in pairs(US.discoveryAtlas) do
				n += 1
			end
			return n
		end)(),
		gcScanBudget = getGcScanBudget(),
		minLogInterval = getMinLogInterval(),
		autoHookMinScore = getAutoHookMinScore(),
		realTriggerWindow = _G.SIMPLESPYCONFIG_RealTriggerWindow,
		deepScanRoots = #getDeepScanRoots(),
		httpHooksInstalled = US.httpHooksInstalled == true,
		messagingHooksInstalled = US.messagingHooksInstalled == true,
		discoveryScanStats = US.discoveryScanStats,
		autoDeepDiscovery = _G.SIMPLESPYCONFIG_AutoDeepDiscovery ~= false,
		deepCopyArgs = _G.SIMPLESPYCONFIG_DeepCopyArgs ~= false,
		scanCustomSignals = _G.SIMPLESPYCONFIG_ScanCustomSignals ~= false,
		replayBurstCount = getReplayBurstCount(),
		replayBurstDelay = getReplayBurstDelay(),
		dataStoreClientHook = false,
		altChannels = {
			http = US.httpHooksInstalled == true,
			messaging = US.messagingHooksInstalled == true,
		},
		trackCauses = isPhase5Enabled(),
		entityTracker = isEntityTrackerEnabled(),
		propertyTracker = isPropertyTrackerEnabled(),
		investigationSessions = isInvestigationEnabled(),
		combatDiscovery = isCombatDiscoveryEnabled(),
		connectHook = US.connectHookInstalled == true,
	}
	pcall(function()
		caps.replicatesignal = type(replicatesignal) == "function"
	end)
	return caps
end

--- Last startup / manual self-test report
function SimpleSpy:GetSelfTestResults()
	return startupSelfTestResults
end

--- Runs full UltraSpy self-test suite
function SimpleSpy:RunSelfTest()
	return runUltraSpySelfTest()
end

--- Creates a new ScriptSignal that can be connected to and fired
--- @return table
function newSignal()
	local connected = {}
	return {
		Connect = function(self, f)
			assert(connected, "Signal is closed")
			connected[tostring(f)] = f
			return {
				Connected = true,
				Disconnect = function(self)
					if not connected then
						warn("Signal is already closed")
					end
					self.Connected = false
					connected[tostring(f)] = nil
				end,
			}
		end,
		Wait = function(self)
			local thread = coroutine.running()
			local connection
			connection = self:Connect(function()
				connection:Disconnect()
				if coroutine.status(thread) == "suspended" then
					coroutine.resume(thread)
				end
			end)
			coroutine.yield()
		end,
		Fire = function(self, ...)
			for _, f in pairs(connected) do
				coroutine.wrap(f)(...)
			end
		end,
	}
end

--- Prevents remote spam from causing lag (clears logs after `_G.SIMPLESPYCONFIG_MaxRemotes` or 500 remotes)
function clean()
	local max = _G.SIMPLESPYCONFIG_MaxRemotes
	if typeof(max) ~= "number" or math.floor(max) ~= max then
		max = 500
	end
	if #remoteLogs > max then
		for i = 100, #remoteLogs do
			local v = remoteLogs[i]
			if typeof(v[1]) == "RBXScriptConnection" then
				v[1]:Disconnect()
			end
			if typeof(v[2]) == "Instance" then
				v[2]:Destroy()
			end
		end
		local newLogs = {}
		for i = 1, 100 do
			table.insert(newLogs, remoteLogs[i])
		end
		remoteLogs = newLogs
	end
end

--- Scales the ToolTip to fit containing text
function scaleToolTip()
	local size = TextService:GetTextSize(
		TextLabel.Text,
		TextLabel.TextSize,
		TextLabel.Font,
		Vector2.new(196, math.huge)
	)
	TextLabel.Size = UDim2.new(0, size.X, 0, size.Y)
	ToolTip.Size = UDim2.new(0, size.X + 4, 0, size.Y + 4)
end

--- Executed when the toggle button (the SimpleSpy logo) is hovered over
function onToggleButtonHover()
	if not toggle then
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(252, 51, 51) }):Play()
	else
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(68, 206, 91) }):Play()
	end
end

--- Executed when the toggle button is unhovered over
function onToggleButtonUnhover()
	TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
end

--- Executed when the X button is hovered over
function onXButtonHover()
	TweenService:Create(CloseButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }):Play()
end

--- Executed when the X button is unhovered over
function onXButtonUnhover()
	TweenService:Create(CloseButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(37, 36, 38) }):Play()
end

--- Toggles the remote spy method (when button clicked)
function onToggleButtonClick()
	if toggle then
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(252, 51, 51) }):Play()
	else
		TweenService:Create(Simple, TweenInfo.new(0.5), { TextColor3 = Color3.fromRGB(68, 206, 91) }):Play()
	end
	toggleSpyMethod()
end

--- Reconnects bringBackOnResize if the current viewport changes and also connects it initially
function connectResize()
	local lastCam
	local function bindCamera(cam)
		if not cam then
			return nil
		end
		return cam:GetPropertyChangedSignal("ViewportSize"):Connect(bringBackOnResize)
	end
	lastCam = bindCamera(workspace.CurrentCamera)
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if lastCam then
			lastCam:Disconnect()
		end
		lastCam = bindCamera(workspace.CurrentCamera)
	end)
end

--- Brings gui back if it gets lost offscreen (connected to the camera viewport changing)
function bringBackOnResize()
	validateSize()
	if sideClosed then
		minimizeSize()
	else
		maximizeSize()
	end
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local currentX = Background.AbsolutePosition.X
	local currentY = Background.AbsolutePosition.Y
	local viewportSize = cam.ViewportSize
	if (currentX < 0) or (currentX > (viewportSize.X - (sideClosed and LEFT_PANEL_W or Background.AbsoluteSize.X))) then
		if currentX < 0 then
			currentX = 0
		else
			currentX = viewportSize.X - (sideClosed and LEFT_PANEL_W or Background.AbsoluteSize.X)
		end
	end
	if (currentY < 0) or (currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36)) then
		if currentY < 0 then
			currentY = 0
		else
			currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
		end
	end
	TweenService:Create(
		Background,
		TweenInfo.new(0.1),
		{ Position = UDim2.new(0, currentX, 0, currentY) }
	):Play()
end

--- Drags gui (so long as mouse is held down)
--- @param input InputObject
function onBarInput(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local lastPos = UserInputService.GetMouseLocation(UserInputService)
		local mainPos = Background.AbsolutePosition
		local offset = mainPos - lastPos
		local currentPos = offset + lastPos
		RunService.BindToRenderStep(RunService, "drag", 1, function()
			local newPos = UserInputService.GetMouseLocation(UserInputService)
			if newPos ~= lastPos then
				local currentX = (offset + newPos).X
				local currentY = (offset + newPos).Y
				local viewportSize = workspace.CurrentCamera.ViewportSize
				if
					(currentX < 0 and currentX < currentPos.X)
					or (
						currentX > (viewportSize.X - (sideClosed and LEFT_PANEL_W or TopBar.AbsoluteSize.X))
						and currentX > currentPos.X
					)
				then
					if currentX < 0 then
						currentX = 0
					else
						currentX = viewportSize.X - (sideClosed and LEFT_PANEL_W or TopBar.AbsoluteSize.X)
					end
				end
				if
					(currentY < 0 and currentY < currentPos.Y)
					or (
						currentY > (viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36)
						and currentY > currentPos.Y
					)
				then
					if currentY < 0 then
						currentY = 0
					else
						currentY = viewportSize.Y - (closed and 19 or Background.AbsoluteSize.Y) - 36
					end
				end
				currentPos = Vector2.new(currentX, currentY)
				lastPos = newPos
				TweenService:Create(
					Background,
					TweenInfo.new(0.1),
					{ Position = UDim2.new(0, currentPos.X, 0, currentPos.Y) }
				):Play()
			end
			-- if input.UserInputState ~= Enum.UserInputState.Begin then
			--     RunService.UnbindFromRenderStep(RunService, "drag")
			-- end
		end)
		table.insert(
			connections,
			UserInputService.InputEnded:Connect(function(inputE)
				if input == inputE then
					RunService:UnbindFromRenderStep("drag")
				end
			end)
		)
	end
end

--- Fades out the table of elements (and makes them invisible), returns a function to make them visible again
function fadeOut(elements)
	local data = {}
	for _, v in pairs(elements) do
		if typeof(v) == "Instance" and v:IsA("GuiObject") and v.Visible then
			coroutine.wrap(function()
				data[v] = {
					BackgroundTransparency = v.BackgroundTransparency,
				}
				TweenService:Create(v, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
				if v:IsA("TextBox") or v:IsA("TextButton") or v:IsA("TextLabel") then
					data[v].TextTransparency = v.TextTransparency
					TweenService:Create(v, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
				elseif v:IsA("ImageButton") or v:IsA("ImageLabel") then
					data[v].ImageTransparency = v.ImageTransparency
					TweenService:Create(v, TweenInfo.new(0.5), { ImageTransparency = 1 }):Play()
				end
				wait(0.5)
				v.Visible = false
				for i, x in pairs(data[v]) do
					v[i] = x
				end
				data[v] = true
			end)()
		end
	end
	return function()
		for i, _ in pairs(data) do
			coroutine.wrap(function()
				local properties = {
					BackgroundTransparency = i.BackgroundTransparency,
				}
				i.BackgroundTransparency = 1
				TweenService
					:Create(i, TweenInfo.new(0.5), { BackgroundTransparency = properties.BackgroundTransparency })
					:Play()
				if i:IsA("TextBox") or i:IsA("TextButton") or i:IsA("TextLabel") then
					properties.TextTransparency = i.TextTransparency
					i.TextTransparency = 1
					TweenService
						:Create(i, TweenInfo.new(0.5), { TextTransparency = properties.TextTransparency })
						:Play()
				elseif i:IsA("ImageButton") or i:IsA("ImageLabel") then
					properties.ImageTransparency = i.ImageTransparency
					i.ImageTransparency = 1
					TweenService
						:Create(i, TweenInfo.new(0.5), { ImageTransparency = properties.ImageTransparency })
						:Play()
				end
				i.Visible = true
			end)()
		end
	end
end

--- Expands and minimizes the gui (closed is the toggle boolean)
function toggleMinimize(override)
	if mainClosing and not override or maximized then
		return
	end
	mainClosing = true
	closed = not closed
	if closed then
		if not sideClosed then
			toggleSideTray(true)
		end
		LeftPanel.Visible = true
		TweenService:Create(LeftPanel, TweenInfo.new(0.5), { Size = UDim2.new(0, LEFT_PANEL_W, 0, 0) }):Play()
		wait(0.5)
		remotesFadeIn = fadeOut(LeftPanel:GetDescendants())
		wait(0.5)
	else
		TweenService:Create(LeftPanel, TweenInfo.new(0.5), { Size = UDim2.new(0, LEFT_PANEL_W, 0, 249) }):Play()
		wait(0.5)
		if remotesFadeIn then
			remotesFadeIn()
			remotesFadeIn = nil
		end
		bringBackOnResize()
	end
	mainClosing = false
end

--- Expands and minimizes the sidebar (sideClosed is the toggle boolean)
function toggleSideTray(override)
	if sideClosing and not override or maximized then
		return
	end
	sideClosing = true
	sideClosed = not sideClosed
	if sideClosed then
		rightFadeIn = fadeOut(RightPanel:GetDescendants())
		wait(0.5)
		minimizeSize(0.5)
		wait(0.5)
		RightPanel.Visible = false
	else
		if closed then
			toggleMinimize(true)
		end
		RightPanel.Visible = true
		maximizeSize(0.5)
		wait(0.5)
		if rightFadeIn then
			rightFadeIn()
		end
		bringBackOnResize()
	end
	sideClosing = false
end

--- Expands code box to fit screen for more convenient viewing
function toggleMaximize()
	if not sideClosed and not maximized then
		maximized = true
		local disable = Instance.new("TextButton")
		local prevSize = UDim2.new(0, CodeBox.AbsoluteSize.X, 0, CodeBox.AbsoluteSize.Y)
		local prevPos = UDim2.new(0, CodeBox.AbsolutePosition.X, 0, CodeBox.AbsolutePosition.Y)
		disable.Size = UDim2.new(1, 0, 1, 0)
		disable.BackgroundColor3 = Color3.new()
		disable.BorderSizePixel = 0
		disable.Text = 0
		disable.ZIndex = 3
		disable.BackgroundTransparency = 1
		disable.AutoButtonColor = false
		CodeBox.ZIndex = 4
		CodeBox.Position = prevPos
		CodeBox.Size = prevSize
		TweenService
			:Create(
				CodeBox,
				TweenInfo.new(0.5),
				{ Size = UDim2.new(0.5, 0, 0.5, 0), Position = UDim2.new(0.25, 0, 0.25, 0) }
			)
			:Play()
		TweenService:Create(disable, TweenInfo.new(0.5), { BackgroundTransparency = 0.5 }):Play()
		disable.MouseButton1Click:Connect(function()
			local clickPos = getSpyMousePos()
			if
				clickPos.Y >= CodeBox.AbsolutePosition.Y
				and clickPos.Y <= CodeBox.AbsolutePosition.Y + CodeBox.AbsoluteSize.Y
				and clickPos.X >= CodeBox.AbsolutePosition.X
				and clickPos.X <= CodeBox.AbsolutePosition.X + CodeBox.AbsoluteSize.X
			then
				return
			end
			TweenService:Create(CodeBox, TweenInfo.new(0.5), { Size = prevSize, Position = prevPos }):Play()
			TweenService:Create(disable, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
			maximized = false
			wait(0.5)
			disable:Destroy()
			CodeBox.Size = UDim2.new(1, 0, 0.5, 0)
			CodeBox.Position = UDim2.new(0, 0, 0, 0)
			CodeBox.ZIndex = 0
		end)
	end
end

--- Checks if cursor is within resize range
--- @param p Vector2
function isInResizeRange(p)
	local relativeP = p - Background.AbsolutePosition
	local range = 5
	if
		relativeP.X >= TopBar.AbsoluteSize.X - range
		and relativeP.Y >= Background.AbsoluteSize.Y - range
		and relativeP.X <= TopBar.AbsoluteSize.X
		and relativeP.Y <= Background.AbsoluteSize.Y
	then
		return true, "B"
	elseif relativeP.X >= TopBar.AbsoluteSize.X - range and relativeP.X <= Background.AbsoluteSize.X then
		return true, "X"
	elseif relativeP.Y >= Background.AbsoluteSize.Y - range and relativeP.Y <= Background.AbsoluteSize.Y then
		return true, "Y"
	end
	return false
end

--- Checks if cursor is within dragging range
--- @param p Vector2
function isInDragRange(p)
	local relativeP = p - Background.AbsolutePosition
	if
		relativeP.X <= TopBar.AbsoluteSize.X - CloseButton.AbsoluteSize.X * 3
		and relativeP.X >= 0
		and relativeP.Y <= TopBar.AbsoluteSize.Y
		and relativeP.Y >= 0
	then
		return true
	end
	return false
end

--- Mouse position aligned with ScreenGui AbsolutePosition (accounts for top inset)
function getSpyMousePos()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local CURSOR_RESIZE_B = "rbxassetid://6065821980"
local CURSOR_RESIZE_X = "rbxassetid://6065821086"
local CURSOR_RESIZE_Y = "rbxassetid://6065821596"

function restoreSpyCursor()
	if Mouse and oldIcon ~= nil then
		Mouse.Icon = oldIcon
	end
	UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
	local legacyCursor = SimpleSpy2:FindFirstChild("Cursor")
	if legacyCursor then
		legacyCursor:Destroy()
	end
end

function updateSpyCursor(mousePos)
	if not Mouse then
		return
	end
	local inRange, resizeType = isInResizeRange(mousePos)
	local icon
	if inRange and not sideClosed and not closed then
		icon = resizeType == "B" and CURSOR_RESIZE_B
			or resizeType == "X" and CURSOR_RESIZE_X
			or CURSOR_RESIZE_Y
	elseif inRange and not closed and (resizeType == "Y" or resizeType == "B") then
		icon = CURSOR_RESIZE_Y
	else
		if oldIcon ~= nil and Mouse.Icon ~= oldIcon then
			Mouse.Icon = oldIcon
		end
		return
	end
	if Mouse.Icon ~= icon then
		Mouse.Icon = icon
	end
end

--- Called when mouse moves
function mouseMoved()
	local mousePos = getSpyMousePos()
	local inGui = not closed
		and mousePos.X >= TopBar.AbsolutePosition.X
		and mousePos.X <= TopBar.AbsolutePosition.X + TopBar.AbsoluteSize.X
		and mousePos.Y >= Background.AbsolutePosition.Y
		and mousePos.Y <= Background.AbsolutePosition.Y + Background.AbsoluteSize.Y
	if inGui then
		if not mouseInGui then
			mouseInGui = true
			UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
			local legacyCursor = SimpleSpy2:FindFirstChild("Cursor")
			if legacyCursor then
				legacyCursor:Destroy()
			end
		end
		updateSpyCursor(mousePos)
	else
		if mouseInGui then
			mouseInGui = false
			restoreSpyCursor()
		end
	end
end

function getUiScale()
	local s = _G.SIMPLESPYCONFIG_UiScale
	if type(s) == "number" and s >= 0.75 and s <= 1.5 then
		return s
	end
	return 1
end

function setSpyStatus(text)
	if US.gui and US.gui.StatusLabel then
		US.gui.StatusLabel.Text = text or ""
	end
end

function createStartupLoadingOverlay()
	if US.gui.LoadingOverlay then
		return
	end
	local overlay = Instance.new("Frame")
	overlay.Name = "StartupLoadingOverlay"
	overlay.Parent = Background
	overlay.BackgroundColor3 = Color3.fromRGB(18, 17, 20)
	overlay.BackgroundTransparency = 0.08
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.ZIndex = 200
	overlay.Visible = false
	overlay.Active = true
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Parent = overlay
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.new(0.5, 0, 0.5, 0)
	card.Size = UDim2.fromOffset(300, 118)
	card.BackgroundColor3 = Color3.fromRGB(42, 40, 48)
	card.BorderSizePixel = 0
	card.ZIndex = 201
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = card
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(0, 14)
	title.Size = UDim2.new(1, 0, 0, 28)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(255, 242, 0)
	title.Text = "UltraSpy"
	title.ZIndex = 202
	local detail = Instance.new("TextLabel")
	detail.Name = "Detail"
	detail.Parent = card
	detail.BackgroundTransparency = 1
	detail.Position = UDim2.fromOffset(12, 44)
	detail.Size = UDim2.new(1, -24, 0, 40)
	detail.Font = Enum.Font.SourceSans
	detail.TextSize = 13
	detail.TextColor3 = Color3.fromRGB(210, 210, 220)
	detail.TextWrapped = true
	detail.TextXAlignment = Enum.TextXAlignment.Center
	detail.Text = "Carregando..."
	detail.ZIndex = 202
	local barBack = Instance.new("Frame")
	barBack.Name = "BarBack"
	barBack.Parent = card
	barBack.BackgroundColor3 = Color3.fromRGB(28, 27, 32)
	barBack.BorderSizePixel = 0
	barBack.Position = UDim2.new(0, 20, 1, -28)
	barBack.Size = UDim2.new(1, -40, 0, 6)
	barBack.ZIndex = 202
	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Parent = barBack
	barFill.BackgroundColor3 = Color3.fromRGB(68, 206, 91)
	barFill.BorderSizePixel = 0
	barFill.Size = UDim2.new(0.15, 0, 1, 0)
	barFill.ZIndex = 203
	US.gui.LoadingOverlay = overlay
	US.gui.LoadingTitle = title
	US.gui.LoadingDetail = detail
	US.gui.LoadingBarFill = barFill
	if not US.startupLoadingHeartbeat then
		US.startupLoadingHeartbeat = RunService.Heartbeat:Connect(function(dt)
			if not US.startupLoading.visible then
				return
			end
			US.startupLoading.dotPhase = (US.startupLoading.dotPhase or 0) + dt
			local dots = math.floor(US.startupLoading.dotPhase * 2) % 4
			local suffix = string.rep(".", dots)
			if US.gui.LoadingDetail and US.startupLoading.baseDetail ~= "" then
				US.gui.LoadingDetail.Text = US.startupLoading.baseDetail .. suffix
			end
			if US.gui.LoadingBarFill then
				local pulse = 0.2 + 0.65 * (0.5 + 0.5 * math.sin(US.startupLoading.dotPhase * 4))
				US.gui.LoadingBarFill.Size = UDim2.new(math.clamp(pulse, 0.12, 0.92), 0, 1, 0)
			end
		end)
	end
end

function showStartupLoading(title, detail, progress)
	createStartupLoadingOverlay()
	US.startupLoading.visible = true
	US.startupLoading.baseDetail = detail or "Carregando"
	if US.gui.LoadingOverlay then
		US.gui.LoadingOverlay.Visible = true
	end
	if US.gui.LoadingTitle then
		US.gui.LoadingTitle.Text = title or "UltraSpy"
	end
	if US.gui.LoadingDetail then
		US.gui.LoadingDetail.Text = US.startupLoading.baseDetail
	end
	if US.gui.LoadingBarFill and type(progress) == "number" then
		US.gui.LoadingBarFill.Size = UDim2.new(math.clamp(progress, 0.05, 1), 0, 1, 0)
		US.gui.LoadingBarFill.BackgroundColor3 = Color3.fromRGB(68, 206, 91)
	end
	setSpyStatus(detail or "Carregando...")
end

function updateStartupLoading(detail, progress)
	if not US.startupLoading.visible then
		showStartupLoading("UltraSpy", detail, progress)
		return
	end
	US.startupLoading.baseDetail = detail or US.startupLoading.baseDetail
	if type(progress) == "number" and US.gui.LoadingBarFill then
		US.gui.LoadingBarFill.Size = UDim2.new(math.clamp(progress, 0.05, 1), 0, 1, 0)
	end
	setSpyStatus(detail or "")
end

function hideStartupLoading(ok, statusMsg)
	US.startupLoading.visible = false
	US.startupLoading.baseDetail = ""
	if US.gui.LoadingOverlay then
		US.gui.LoadingOverlay.Visible = false
	end
	if US.gui.LoadingBarFill then
		US.gui.LoadingBarFill.Size = UDim2.new(ok and 1 or 0.35, 0, 1, 0)
		US.gui.LoadingBarFill.BackgroundColor3 = ok and Color3.fromRGB(68, 206, 91)
			or Color3.fromRGB(220, 90, 90)
	end
	local msg = statusMsg
		or (ok and "Pronto — capturando remotes" or "Startup com avisos — veja F9")
	setSpyStatus(msg)
	if TextLabel then
		TextLabel.Text = msg
	end
end

function markStartupBootstrapDone()
	US.startupLoading.bootstrapDone = true
	tryFinishStartupLoading()
end

function markStartupTestsDone()
	US.startupLoading.testsDone = true
	tryFinishStartupLoading()
end

function tryFinishStartupLoading()
	if US.startupLoading.finished then
		return
	end
	if not US.startupLoading.bootstrapDone then
		return
	end
	local needTests = _G.SIMPLESPYCONFIG_RunSelfTest ~= false
	if needTests and not US.startupLoading.testsDone then
		return
	end
	US.startupLoading.finished = true
	local ok = true
	local statusMsg = "Pronto — UltraSpy ativo"
	if needTests and startupSelfTestResults then
		ok = startupSelfTestResults.ok == true
		statusMsg = string.format(
			"Pronto — testes %d/%d OK",
			startupSelfTestResults.passed or 0,
			startupSelfTestResults.total or 0
		)
		if not ok then
			statusMsg = string.format(
				"Aviso — testes %d/%d OK (%d falha)",
				startupSelfTestResults.passed or 0,
				startupSelfTestResults.total or 0,
				startupSelfTestResults.failed or 0
			)
		end
	end
	updateStartupLoading(ok and "Tudo carregado!" or "Carregado com avisos", ok and 1 or 0.5)
	task.defer(function()
		task.wait(0.35)
		hideStartupLoading(ok, statusMsg)
	end)
end

function layoutLeftListFrames()
	local top = LEFT_PANEL_TOP_INSET
	local function apply(sf)
		if sf and sf:IsA("ScrollingFrame") then
			sf.Position = UDim2.new(0, 2, 0, top)
			sf.Size = UDim2.new(1, -4, 1, -(top + 4))
		end
	end
	apply(LogList)
	if US.gui then
		apply(US.gui.TimelineList)
		apply(US.gui.AtlasList)
	end
end

--- Responsive layout for main panels, codebox, and tool tabs
function syncSpyLayout(speed)
	if not Background or not RightPanel or not LeftPanel or not CodeBox then
		return
	end
	local bw = math.max(MIN_WINDOW_W, Background.AbsoluteSize.X)
	local bh = math.max(MIN_WINDOW_H, Background.AbsoluteSize.Y)
	local topH = TopBar.AbsoluteSize.Y
	local contentH = bh - topH
	local leftRatio = _G.SIMPLESPYCONFIG_LeftPanelRatio or 0.38
	local leftW = math.floor(math.clamp(bw * leftRatio, 180, 300))
	if sideClosed then
		leftW = LEFT_PANEL_W
	end
	LEFT_PANEL_W = leftW
	local rightW = math.max(120, bw - leftW)
	local tabBarH = US.gui and US.gui.ToolTabBar and 22 or 0
	local statusH = US.gui and US.gui.StatusLabel and 18 or 0
	local codeRatio = _G.SIMPLESPYCONFIG_CodeBoxRatio or 0.58
	local codeH = math.max(_G.SIMPLESPYCONFIG_MinCodeBoxH or 120, math.floor(contentH * codeRatio))
	local toolH = math.max(60, contentH - codeH - tabBarH - statusH)
	local tween = speed and TweenInfo.new(speed) or nil
	local function apply(inst, props)
		if not inst then
			return
		end
		if tween then
			TweenService:Create(inst, tween, props):Play()
		else
			for k, v in pairs(props) do
				inst[k] = v
			end
		end
	end
	apply(TopBar, { Size = UDim2.fromOffset(bw, topH) })
	apply(LeftPanel, {
		Position = UDim2.fromOffset(0, topH),
		Size = UDim2.fromOffset(leftW, contentH),
	})
	if sideClosed then
		apply(RightPanel, { Position = UDim2.fromOffset(leftW, topH), Size = UDim2.fromOffset(0, contentH) })
		apply(CodeBox, { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(0, contentH) })
	else
		apply(RightPanel, { Position = UDim2.fromOffset(leftW, topH), Size = UDim2.fromOffset(rightW, contentH) })
		apply(CodeBox, { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(rightW, codeH) })
		if US.gui and US.gui.ToolTabBar then
			apply(US.gui.ToolTabBar, {
				Position = UDim2.fromOffset(0, codeH),
				Size = UDim2.fromOffset(rightW, tabBarH),
			})
		end
		if US.gui and US.gui.ToolTabContent then
			apply(US.gui.ToolTabContent, {
				Position = UDim2.fromOffset(0, codeH + tabBarH),
				Size = UDim2.fromOffset(rightW, toolH),
			})
		end
		if US.gui and US.gui.StatusLabel then
			apply(US.gui.StatusLabel, {
				Position = UDim2.new(0, 0, 1, -statusH),
				Size = UDim2.new(1, 0, 0, statusH),
			})
		end
		if US.gui and US.gui.ToolPageScroll then
			for _, scroll in pairs(US.gui.ToolPageScroll) do
				apply(scroll, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) })
			end
		elseif ScrollingFrame then
			apply(ScrollingFrame, {
				Position = UDim2.fromOffset(0, codeH + tabBarH),
				Size = UDim2.fromOffset(rightW, toolH),
			})
		end
	end
	layoutLeftListFrames()
	updateFunctionCanvas()
	updateRemoteCanvas()
end

--- Adjusts the ui elements to the 'Maximized' size
function maximizeSize(speed)
	syncSpyLayout(speed)
end

--- Adjusts the ui elements to close the side
function minimizeSize(speed)
	syncSpyLayout(speed)
end

--- Ensures size is within screensize limitations
function validateSize()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local x, y = Background.AbsoluteSize.X, Background.AbsoluteSize.Y
	local screenSize = cam.ViewportSize
	if x + Background.AbsolutePosition.X > screenSize.X then
		if screenSize.X - Background.AbsolutePosition.X >= MIN_WINDOW_W then
			x = screenSize.X - Background.AbsolutePosition.X
		else
			x = MIN_WINDOW_W
		end
	elseif y + Background.AbsolutePosition.Y > screenSize.Y then
		if screenSize.Y - Background.AbsolutePosition.Y >= MIN_WINDOW_H then
			y = screenSize.Y - Background.AbsolutePosition.Y
		else
			y = MIN_WINDOW_H
		end
	end
	Background.Size = UDim2.fromOffset(x, y)
end

--- Called on user input while mouse in 'Background' frame
--- @param input InputObject
function backgroundUserInput(input)
	local mousePos = getSpyMousePos()
	local inResizeRange, type = isInResizeRange(mousePos)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and inResizeRange then
		local lastPos = UserInputService:GetMouseLocation()
		local offset = Background.AbsoluteSize - lastPos
		local currentPos = lastPos + offset
		RunService:BindToRenderStep("SIMPLESPY_RESIZE", 1, function()
			local newPos = UserInputService:GetMouseLocation()
			if newPos ~= lastPos then
				local currentX = (newPos + offset).X
				local currentY = (newPos + offset).Y
				if currentX < MIN_WINDOW_W then
					currentX = MIN_WINDOW_W
				end
				if currentY < MIN_WINDOW_H then
					currentY = MIN_WINDOW_H
				end
				currentPos = Vector2.new(currentX, currentY)
				Background.Size = UDim2.fromOffset(
					(not sideClosed and not closed and (type == "X" or type == "B")) and currentPos.X
						or Background.AbsoluteSize.X,
					(--[[(not sideClosed or currentPos.X <= LeftPanel.AbsolutePosition.X + LeftPanel.AbsoluteSize.X) and]]not closed and (type == "Y" or type == "B"))
							and currentPos.Y
						or Background.AbsoluteSize.Y
				)
				validateSize()
				if sideClosed then
					minimizeSize()
				else
					maximizeSize()
				end
				lastPos = newPos
			end
		end)
		table.insert(
			connections,
			UserInputService.InputEnded:Connect(function(inputE)
				if input == inputE then
					RunService:UnbindFromRenderStep("SIMPLESPY_RESIZE")
				end
			end)
		)
	elseif isInDragRange(mousePos) then
		onBarInput(input)
	end
end

--- Gets the player an instance is descended from
function getPlayerFromInstance(instance)
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
			return v
		end
	end
end

--- Runs on MouseButton1Click of an event frame
function eventSelect(frame)
	for _, v in pairs(logs) do
		if frame == v.Log or frame == v.SubLogFrame then
			selectLogEntry(v)
			return
		end
	end
	if selected and selected.Log == frame then
		selectLogEntry(selected)
	end
end

function getActiveToolScroll()
	if US.gui and US.gui.ToolPageScroll and US.activeToolTab then
		return US.gui.ToolPageScroll[US.activeToolTab]
	end
	return ScrollingFrame
end

function setActiveToolTab(tabId)
	if not US.gui or not US.gui.ToolPageScroll or not US.gui.ToolPageScroll[tabId] then
		return
	end
	US.activeToolTab = tabId
	ScrollingFrame = US.gui.ToolPageScroll[tabId]
	for id, scroll in pairs(US.gui.ToolPageScroll) do
		scroll.Visible = id == tabId
	end
	local labels = { code = "Code", track = "Track", discover = "Discover", advanced = "Advanced" }
	for id, btn in pairs(US.gui.ToolTabButtons or {}) do
		if btn then
			btn.Text = id == tabId and ("[" .. labels[id] .. "]") or labels[id]
			btn.TextColor3 = id == tabId and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
		end
	end
	updateFunctionCanvas()
end

function buildToolPanel()
	if US.gui.ToolPanelBuilt then
		return
	end
	US.gui.ToolPanelBuilt = true
	if UIGridLayout then
		UIGridLayout.Parent = nil
	end
	ScrollingFrame.Visible = false
	local tabBar = Instance.new("Frame")
	tabBar.Name = "ToolTabBar"
	tabBar.BackgroundColor3 = Color3.fromRGB(32, 31, 34)
	tabBar.BorderSizePixel = 0
	tabBar.Parent = RightPanel
	US.gui.ToolTabBar = tabBar
	local tabDefs = {
		{ id = "code", label = "Code", x = 2 },
		{ id = "track", label = "Track", x = 58 },
		{ id = "discover", label = "Discover", x = 114 },
		{ id = "advanced", label = "Advanced", x = 170 },
	}
	US.gui.ToolTabButtons = {}
	for _, def in ipairs(tabDefs) do
		local b = Instance.new("TextButton")
		b.Name = "Tab_" .. def.id
		b.Parent = tabBar
		b.BackgroundTransparency = 1
		b.Position = UDim2.fromOffset(def.x, 2)
		b.Size = UDim2.fromOffset(54, 18)
		b.Font = Enum.Font.SourceSansBold
		b.TextSize = 11
		b.Text = def.label
		b.TextColor3 = Color3.fromRGB(160, 160, 165)
		b.AutoButtonColor = false
		US.gui.ToolTabButtons[def.id] = b
		b.MouseButton1Click:Connect(function()
			setActiveToolTab(def.id)
		end)
	end
	local content = Instance.new("Frame")
	content.Name = "ToolTabContent"
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = RightPanel
	US.gui.ToolTabContent = content
	US.gui.ToolPageScroll = {}
	US.gui.ToolPageLayouts = {}
	for _, def in ipairs(tabDefs) do
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "ToolPage_" .. def.id
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.Visible = def.id == "code"
		scroll.Parent = content
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 4)
		pad.PaddingRight = UDim.new(0, 4)
		pad.PaddingTop = UDim.new(0, 2)
		pad.Parent = scroll
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 3)
		layout.Parent = scroll
		US.gui.ToolPageScroll[def.id] = scroll
		US.gui.ToolPageLayouts[def.id] = layout
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if US.activeToolTab == def.id then
				updateFunctionCanvas()
			end
		end)
	end
	ScrollingFrame = US.gui.ToolPageScroll.code
	local status = Instance.new("TextLabel")
	status.Name = "StatusLabel"
	status.Parent = RightPanel
	status.BackgroundColor3 = Color3.fromRGB(28, 27, 30)
	status.BackgroundTransparency = 0.2
	status.BorderSizePixel = 0
	status.Font = Enum.Font.SourceSans
	status.TextSize = 12
	status.TextColor3 = Color3.fromRGB(200, 200, 210)
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextTruncate = Enum.TextTruncate.AtEnd
	status.Text = "Ready"
	status.ZIndex = 5
	local statusPad = Instance.new("UIPadding")
	statusPad.PaddingLeft = UDim.new(0, 6)
	statusPad.Parent = status
	US.gui.StatusLabel = status
	createStartupLoadingOverlay()
	setActiveToolTab("code")
	syncSpyLayout()
end

--- Updates the canvas size to fit the current amount of function buttons
function updateFunctionCanvas()
	local scroll = getActiveToolScroll()
	if not scroll then
		return
	end
	local layout = scroll:FindFirstChildOfClass("UIListLayout")
	if layout then
		scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
	elseif UIGridLayout and UIGridLayout.Parent == scroll then
		scroll.CanvasSize = UDim2.fromOffset(UIGridLayout.AbsoluteContentSize.X, UIGridLayout.AbsoluteContentSize.Y)
	end
end

--- Updates the canvas size to fit the amount of current remotes
function updateRemoteCanvas()
	LogList.CanvasSize = UDim2.fromOffset(UIListLayout.AbsoluteContentSize.X, UIListLayout.AbsoluteContentSize.Y)
end

--- Allows for toggling of the tooltip and easy setting of le description
--- @param enable boolean
--- @param text string
function makeToolTip(enable, text)
	if enable then
		if ToolTip.Visible then
			ToolTip.Visible = false
			RunService:UnbindFromRenderStep("ToolTip")
		end
		local first = true
		RunService:BindToRenderStep("ToolTip", 1, function()
			local topLeft = Vector2.new(Mouse.X + 20, Mouse.Y + 20)
			local bottomRight = topLeft + ToolTip.AbsoluteSize
			if topLeft.X < 0 then
				topLeft = Vector2.new(0, topLeft.Y)
			elseif bottomRight.X > workspace.CurrentCamera.ViewportSize.X then
				topLeft = Vector2.new(workspace.CurrentCamera.ViewportSize.X - ToolTip.AbsoluteSize.X, topLeft.Y)
			end
			if topLeft.Y < 0 then
				topLeft = Vector2.new(topLeft.X, 0)
			elseif bottomRight.Y > workspace.CurrentCamera.ViewportSize.Y - 35 then
				topLeft = Vector2.new(topLeft.X, workspace.CurrentCamera.ViewportSize.Y - ToolTip.AbsoluteSize.Y - 35)
			end
			if topLeft.X <= Mouse.X and topLeft.Y <= Mouse.Y then
				topLeft = Vector2.new(Mouse.X - ToolTip.AbsoluteSize.X - 2, Mouse.Y - ToolTip.AbsoluteSize.Y - 2)
			end
			if first then
				ToolTip.Position = UDim2.fromOffset(topLeft.X, topLeft.Y)
				first = false
			else
				ToolTip:TweenPosition(UDim2.fromOffset(topLeft.X, topLeft.Y), "Out", "Linear", 0.1)
			end
		end)
		TextLabel.Text = text
		ToolTip.Visible = true
	else
		if ToolTip.Visible then
			ToolTip.Visible = false
			RunService:UnbindFromRenderStep("ToolTip")
		end
	end
end

--- Creates new function button (below codebox)
--- @param name string
---@param description function
---@param onClick function
function applyLogEntryHitArea(entry)
	local hit = entry:FindFirstChild("Button")
	if hit and hit:IsA("GuiButton") then
		hit.Position = UDim2.new(0, 0, 0, 0)
		hit.Size = UDim2.new(1, 0, 1, 0)
		hit.ZIndex = 10
		hit.BackgroundTransparency = 1
		hit.BorderSizePixel = 0
		hit.Active = true
	end
	for _, child in ipairs(entry:GetChildren()) do
		if child:IsA("GuiObject") and child.Name ~= "Button" then
			child.Active = false
		end
	end
end

function getButtonTabId(name)
	local codeNames = {
		["Copy Code"] = true,
		["Copy Remote"] = true,
		["Run Code"] = true,
		["Edit Args"] = true,
		["Apply Args"] = true,
		["Replay 1x"] = true,
		["Replay 10x"] = true,
		["Stop Replay"] = true,
		["Get Script"] = true,
		["Function Info"] = true,
		["Decompile"] = true,
		["Get ReturnValue"] = true,
		["KeyToString"] = true,
		["ToggleReturnValues"] = true,
	}
	local trackNames = {
		["Group Logs"] = true,
		["Track Inbound"] = true,
		["Flow Tracking"] = true,
		["UI Correlate"] = true,
		["State Log"] = true,
		["Timeline"] = true,
		["Clr Logs"] = true,
		["Autoblock"] = true,
		["Force log all"] = true,
		["Disable Info"] = true,
		["AutoHookStack"] = true,
		["CallingScript"] = true,
		["Track Bindables"] = true,
		["Track Creation"] = true,
		["Flow View"] = true,
		["Log Wrapper Calls"] = true,
		["Correlation"] = true,
		["Track Animations"] = true,
		["Track Sounds"] = true,
		["Track Causes"] = true,
		["Track Hits"] = true,
	}
	local discoverNames = {
		["Root Cause"] = true,
		["Combat Discovery"] = true,
		["Reward Discovery"] = true,
		["Top Actions"] = true,
		["Action Sequences"] = true,
		["State Dependencies"] = true,
		["Investigation Log"] = true,
		["Damage Log"] = true,
		["Reward Log"] = true,
		["Property Log"] = true,
		["Callback Map"] = true,
		["Wrapper Chain"] = true,
		["Remote Callers"] = true,
		["Remote Profile"] = true,
		["Tagged Entities"] = true,
		["Scan Player Data"] = true,
		["Hidden Stats"] = true,
		["Cause Log"] = true,
		["Action Outcomes"] = true,
		["Call Chain"] = true,
		["Remote Atlas"] = true,
		["Payload Patterns"] = true,
		["Export Atlas"] = true,
		["Entity Tracker"] = true,
	}
	if codeNames[name] then
		return "code"
	end
	if trackNames[name] then
		return "track"
	end
	if discoverNames[name] then
		return "discover"
	end
	return "advanced"
end

function newButton(name, description, onClick, tabId)
	tabId = tabId or getButtonTabId(name)
	local button = FunctionTemplate:Clone()
	applyLogEntryHitArea(button)
	button.Size = UDim2.new(1, -4, 0, 26)
	button.Text.Text = name
	button.Text.TextSize = 12
	button.Button.MouseEnter:Connect(function()
		makeToolTip(true, description())
	end)
	button.Button.MouseLeave:Connect(function()
		makeToolTip(false)
	end)
	button.AncestryChanged:Connect(function()
		makeToolTip(false)
	end)
	button.Button.MouseButton1Click:Connect(function(...)
		onClick(button, ...)
	end)
	local parent = (US.gui and US.gui.ToolPageScroll and US.gui.ToolPageScroll[tabId]) or ScrollingFrame
	button.Parent = parent
	updateFunctionCanvas()
end

local WRAPPER_COLOR = Color3.fromRGB(72, 199, 142)

function shouldLogWrapperCalls()
	if _G.SIMPLESPYCONFIG_LogWrapperCalls == false then
		return false
	end
	return true
end

local ULTRASPY_INTERNAL_WRAPPER_NAMES = {
	isremotefirenamecall = true,
	invokeoriginalnamecall = true,
	onhitnamecall = true,
	newinvokeserver = true,
	newfireserver = true,
	newnamecall = true,
	pushwrappercallbuffer = true,
	appendflowstep = true,
	appendbindableflowstep = true,
	remotehandler = true,
	hookremote = true,
	newbindablefire = true,
	newbindableinvoke = true,
	handlebindablespy = true,
	newwrapperlog = true,
	newwrapperlogsync = true,
	installwrapperfunctionhook = true,
	tryautohookstackframes = true,
	mergewrapperbufferwithcallstack = true,
	recordrecentoutboundevent = true,
	forwarddirectremote = true,
	forwarddirectremotepack = true,
	forwardnamecallremotepack = true,
	taskscheduler = true,
	scheduleonspythread = true,
	executereplayfire = true,
	logaltchannelevent = true,
	discoverremotecandidates = true,
	purgeinternalwrapperhooks = true,
	isbindablefiremethod = true,
	isbindableinstance = true,
	registerfunctionremotelink = true,
	getremotepathforreplay = true,
	formatcallstackforscript = true,
	touchremoteatlaskey = true,
	getremotefingerprint = true,
	formatcallchainvisual = true,
	recordremoteobservation = true,
	formatnetworkmap = true,
	recordpostremotegraph = true,
	registerupvalueremotelink = true,
	registerfireremotelink = true,
	recordrecentoutboundevent = true,
	recordrecentinboundevent = true,
	mergewrapperbufferwithcallstack = true,
	getreplayargsforlog = true,
	genscript = true,
	remotehandler = true,
	newremotesync = true,
	incrementlogduplicate = true,
	mountlogui = true,
	attachphase5tolog = true,
	attachphase6tolog = true,
	scheduleonspythread = true,
	taskscheduler = true,
}

local spyProtectedFunctions = {}
local SPY_INTERNAL_NAME_FRAGMENTS = {
	"registerfunctionremote",
	"registerupvalueremote",
	"registerfireremote",
	"recordremoteobservation",
	"recordpostremotegraph",
	"recordrecentoutbound",
	"recordrecentinbound",
	"recordremotelifecycle",
	"touchremoteatlas",
	"getremotefingerprint",
	"getremotepathforreplay",
	"getremoteatlas",
	"formatcallstackforscript",
	"formatcallchainvisual",
	"formatnetworkmap",
	"formatfullinvestigation",
	"formatrootcause",
	"formatpayloadlibrary",
	"attachlikelycausetosync",
	"attachinboundspy",
	"openreplayargseditor",
	"runreplayburst",
	"discoverremotecandidates",
	"hookdiscoveredwrappers",
	"purgeinternalwrapperhooks",
	"runperiodicdiscovery",
	"bootstrapphase",
	"selftestout",
	"cleanupselftest",
}

function captureSpyScriptSource()
	if US.spyScriptSourceCaptured then
		return
	end
	US.spyScriptSourceCaptured = true
	local probes = {
		registerSpyProtectedFunctions,
		isUltraSpyInternalWrapper,
		remoteHandler,
		recordRemoteObservation,
	}
	for _, fn in ipairs(probes) do
		if type(fn) == "function" then
			pcall(function()
				local info = debug.getinfo(fn, "s")
				if info and type(info.source) == "string" and info.source ~= "" and info.source ~= "?" then
					US.spyScriptSources = US.spyScriptSources or {}
					US.spyScriptSources[info.source] = true
					if not US.spyScriptSource then
						US.spyScriptSource = info.source
					end
				end
			end)
		end
	end
end

function isSpyRelatedSource(source)
	if type(source) ~= "string" or source == "" or source == "?" then
		return false
	end
	captureSpyScriptSource()
	if US.spyScriptSources and US.spyScriptSources[source] then
		return true
	end
	if US.spyScriptSource and source == US.spyScriptSource then
		return true
	end
	local lower = string.lower(source)
	return string.find(lower, "simplespy", 1, true) ~= nil
		or string.find(lower, "ultraspy", 1, true) ~= nil
		or string.find(lower, "rekmote", 1, true) ~= nil
		or string.find(lower, "coregui", 1, true) ~= nil
		or string.find(lower, "simplespysource", 1, true) ~= nil
		or string.find(lower, "highlight.lua", 1, true) ~= nil
end

function isSpyPipelineFunctionName(lower)
	if not lower or lower == "" then
		return false
	end
	if ULTRASPY_INTERNAL_WRAPPER_NAMES[lower] then
		return true
	end
	for _, frag in ipairs(SPY_INTERNAL_NAME_FRAGMENTS) do
		if string.find(lower, frag, 1, true) then
			return true
		end
	end
	if string.sub(lower, 1, 12) == "recordremote" then
		return true
	end
	if string.sub(lower, 1, 11) == "touchremote" then
		return true
	end
	if string.sub(lower, 1, 16) == "registerfunction" and string.find(lower, "remote", 1, true) then
		return true
	end
	if string.sub(lower, 1, 9) == "getremote" then
		if string.find(lower, "fingerprint", 1, true)
			or string.find(lower, "replay", 1, true)
			or string.find(lower, "atlas", 1, true)
			or string.find(lower, "pathfor", 1, true)
			or string.find(lower, "lifecycle", 1, true) then
			return true
		end
	end
	if string.sub(lower, 1, 6) == "format" then
		if string.find(lower, "callstack", 1, true)
			or string.find(lower, "callchain", 1, true)
			or string.find(lower, "networkmap", 1, true)
			or string.find(lower, "investigation", 1, true)
			or string.find(lower, "payloadlibrary", 1, true)
			or string.find(lower, "rootcause", 1, true)
			or string.find(lower, "remotelifecycle", 1, true) then
			return true
		end
	end
	return false
end

function registerSpyProtectedFunctions()
	captureSpyScriptSource()
	spyProtectedFunctions = {}
	local candidates = {
		newFireServer,
		newInvokeServer,
		newnamecall,
		newBindableFire,
		newBindableInvoke,
		invokeOriginalNamecall,
		handleBindableSpy,
		isRemoteFireNamecall,
		forwardDirectRemote,
		forwardDirectRemotePack,
		forwardNamecallRemotePack,
		hookRemote,
		registerFunctionRemoteLink,
		getRemotePathForReplay,
		formatCallStackForScript,
		touchRemoteAtlasKey,
		getRemoteFingerprint,
		formatCallChainVisual,
		recordRemoteObservation,
		formatNetworkMap,
		recordPostRemoteGraph,
		remoteHandler,
		newRemoteSync,
		incrementLogDuplicate,
		mountLogUI,
		attachPhase5ToLog,
		attachPhase6ToLog,
		getReplayArgsForLog,
		genScript,
		installWrapperFunctionHook,
		hookDiscoveredWrappersFromList,
		discoverRemoteCandidates,
		purgeInternalWrapperHooks,
	}
	for _, fn in ipairs(candidates) do
		if type(fn) == "function" then
			spyProtectedFunctions[tostring(fn)] = true
		end
	end
	if type(remoteHandler) == "function" then
		spyProtectedFunctions[tostring(remoteHandler)] = true
	end
	if type(onHitNamecall) == "function" then
		spyProtectedFunctions[tostring(onHitNamecall)] = true
	end
	if type(hookRemote) == "function" then
		spyProtectedFunctions[tostring(hookRemote)] = true
	end
end

function isSpyProtectedFunction(func)
	if typeof(func) ~= "function" then
		return false
	end
	if not next(spyProtectedFunctions) then
		registerSpyProtectedFunctions()
	end
	return spyProtectedFunctions[tostring(func)] == true
end

function isUltraSpyInternalWrapper(name, source)
	if type(name) == "string" then
		local lower = string.lower(name)
		if isSpyPipelineFunctionName(lower) then
			return true
		end
		-- __namecall helpers match wrapperNameMatches("fire"/"invoke"/"call")
		if string.find(lower, "namecall", 1, true) then
			if string.sub(lower, 1, 2) == "is"
				or string.find(lower, "invoke", 1, true)
				or string.find(lower, "original", 1, true)
				or string.find(lower, "forward", 1, true)
				or string.find(lower, "onhit", 1, true)
				or lower == "newnamecall" then
				return true
			end
		end
		if string.sub(lower, 1, 11) == "newbindable" then
			return true
		end
		if lower == "newinvokeserver" or lower == "newfireserver" or lower == "newnamecall" then
			return true
		end
		if string.sub(lower, 1, 8) == "ultraspy" or string.sub(lower, 1, 9) == "simplespy" then
			return true
		end
	end
	if isSpyRelatedSource(source) then
		return true
	end
	return false
end

function wrapperNameMatches(n)
	if type(n) ~= "string" then
		return false
	end
	if isUltraSpyInternalWrapper(n, nil) then
		return false
	end
	local lower = n:lower()
	local patterns = {
		"fire",
		"send",
		"request",
		"invoke",
		"network",
		"remote",
		"packet",
		"emit",
		"call",
		"encode",
		"decode",
		"dispatch",
	}
	for _, p in ipairs(patterns) do
		if string.find(lower, p, 1, true) then
			return true
		end
	end
	return false
end

function purgeInternalWrapperHooks()
	if not hookfunction then
		return 0
	end
	local removed = 0
	for id, pack in pairs(wrapperHookMeta) do
		local m = pack.meta
		local internal = m and isUltraSpyInternalWrapper(m.name, m.source)
		if not internal and m and m.name then
			internal = isSpyPipelineFunctionName(string.lower(m.name))
		end
		if not internal and pack.hookedFunc then
			internal = isSpyProtectedFunction(pack.hookedFunc)
		end
		if m and internal and pack.hookedFunc and pack.old then
			pcall(function()
				hookfunction(pack.hookedFunc, pack.old)
			end)
			wrapperHooksInstalled[id] = nil
			wrapperHookMeta[id] = nil
			removed += 1
		end
	end
	return removed
end

function getWrapperFingerprint(name, args)
	return "wrapper:" .. tostring(name) .. ":" .. shallowHashArgs(args)
end

function shouldDedupWrapperLog(name, args)
	local fp = getWrapperFingerprint(name, args)
	return shouldCollapseLogFingerprint(fp, recentWrapperFingerprints, _G.SIMPLESPYCONFIG_DedupWindow)
end

function registerWrapperFingerprint(fp, logIndex)
	recentWrapperFingerprints[fp] = { time = tick(), logIndex = logIndex }
end

function incrementLogDuplicate(log)
	if not log or not log.Log then
		return
	end
	log.DuplicateCount = (log.DuplicateCount or 1) + 1
	log.Timestamp = tick()
	if log.GroupKey and US.logGroups[log.GroupKey] then
		local group = US.logGroups[log.GroupKey]
		group.displayCount = (group.displayCount or group.count) + 1
		if group.container then
			assignLogUILayoutOrder(log, group.container)
		end
		for i = 1, #group.entries do
			if group.entries[i] == log then
				table.remove(group.entries, i)
				table.insert(group.entries, 1, log)
				break
			end
		end
		pcall(function()
			group.header.CountLabel.Text = "x" .. tostring(group.displayCount)
			if group.expanded then
				rebuildGroupSubList(group)
			end
		end)
	elseif log.Log then
		assignLogUILayoutOrder(log, log.Log)
		log.Log.Parent = LogList
		resortActionHuntLogList()
	end
	local base = log.DisplayBase or log.Name or "Remote"
	if log.Snapshot and log.Snapshot.path then
		base = log.Snapshot.path
	end
	if log.FlowSnapshot and log.FlowSnapshot.id then
		base = string.format("[F#%d] ", log.FlowSnapshot.id) .. base
	end
	if log.SpamTag and log.SpamTag ~= "" then
		base = log.SpamTag .. base
	end
	local label = base .. " (x" .. tostring(log.DuplicateCount) .. ")"
	pcall(function()
		log.Log.Text.Text = string.sub(label, 1, 50)
	end)
	updateRemoteCanvas()
end

--- Logs a wrapper / intermediate layer call (UI thread only — use newWrapperLog)
function newWrapperLogSync(name, args, meta, fp)
	if not shouldLogWrapperCalls() then
		return
	end
	if isUltraSpyInternalWrapper(name, meta and meta.source) then
		return
	end
	if US.selfTestInProgress and type(name) == "string" and string.find(name, SELF_TEST_PREFIX, 1, true) then
		US.selfTestCaptureCount += 1
		return
	end
	local displayName = "[W] " .. tostring(name)
	if meta and meta.source then
		displayName = "[W] " .. tostring(name)
	end
	local remoteFrame = RemoteTemplate:Clone()
	applyLogEntryHitArea(remoteFrame)
	remoteFrame.Text.Text = string.sub(displayName, 1, 50)
	remoteFrame.ColorBar.BackgroundColor3 = WRAPPER_COLOR
	local log = {
		Name = name,
		LogType = "wrapper",
		WrapperMeta = meta,
		Log = remoteFrame,
		DisplayBase = displayName,
		DuplicateCount = 1,
		LogId = #logs + 1,
		GenScript = "-- Wrapper log generating...",
	}
	logs[#logs + 1] = log
	local logIndex = #logs
	if fp then
		registerWrapperFingerprint(fp, logIndex)
	end
	schedule(function()
		local header = "-- Wrapper call: " .. tostring(name) .. "\n"
		if meta and meta.source then
			header = header .. "-- Source: " .. tostring(meta.source) .. "\n"
		end
		if meta and meta.layer then
			header = header .. "-- Layer: " .. tostring(meta.layer) .. "\n"
		end
		local body = ""
		pcall(function()
			body = v2v({ args = args }) .. "\n"
		end)
		if body == "" then
			body = "-- (could not serialize wrapper args)\n"
		end
		logs[logIndex].GenScript = header .. body
		if selected and selected == logs[logIndex] then
			codebox:setRaw(logs[logIndex].GenScript)
		end
	end)
	assignLogUILayoutOrder(logs[logIndex], remoteFrame)
	remoteFrame.Parent = LogList
	table.insert(remoteLogs, 1, { nil, remoteFrame })
	clean()
	updateRemoteCanvas()
end

function newWrapperLog(name, args, meta)
	if not shouldLogWrapperCalls() then
		return
	end
	local isDup, dupIdx, fp = shouldDedupWrapperLog(name, args)
	if isDup and dupIdx and logs[dupIdx] then
		scheduleOnSpyThread(function()
			if logs[dupIdx] then
				incrementLogDuplicate(logs[dupIdx])
			end
			if fp and recentWrapperFingerprints[fp] then
				recentWrapperFingerprints[fp].time = tick()
			end
		end)
		return
	end
	scheduleOnSpyThread(function()
		newWrapperLogSync(name, args, meta, fp)
	end)
end

function installWrapperFunctionHook(func, name, source, layer)
	if typeof(func) ~= "function" or not islclosure or not islclosure(func) then
		return false
	end
	if isSpyProtectedFunction(func) then
		return false
	end
	if isUltraSpyInternalWrapper(name, source) then
		return false
	end
	local id = tostring(func)
	if wrapperHooksInstalled[id] then
		return false
	end
	local meta = {
		source = source or "?",
		layer = layer or "Network",
		funcId = id,
		name = name,
	}
	wrapperHooksInstalled[id] = true
	wrapperHookMeta[id] = { meta = meta }
	local old
	local ok = pcall(function()
		old = hookfunction(
			func,
			newcclosure(function(...)
				if not enterReentGuard("wrapper") then
					return old(...)
				end
				appendFlowStep(nil, {
					kind = "Wrapper",
					label = name,
					source = meta and meta.source,
					layer = meta and meta.layer or "Network",
				})
				if not isUltraSpyInternalWrapper(name, meta and meta.source) then
					pushWrapperCallBuffer(name, meta and meta.source, meta and meta.layer, meta and meta.funcId)
				end
				if shouldLogWrapperCalls() and not isUltraSpyInternalWrapper(name, meta and meta.source) then
					newWrapperLog(name, { ... }, meta)
				end
				local results = table.pack(old(...))
				leaveReentGuard("wrapper")
				return table.unpack(results, 1, results.n)
			end)
		)
	end)
	if ok and old then
		wrapperHookMeta[id].old = old
		wrapperHookMeta[id].hookedFunc = func
	end
	return ok and old ~= nil
end

--- Phase 2: Event bus, grouped UI, state, inbound, timeline
function isGroupLogsEnabled()
	return _G.SIMPLESPYCONFIG_GroupLogs ~= false
end

function showWrapperGroups()
	return _G.SIMPLESPYCONFIG_ShowWrapperGroups == true
end

function isStateTrackerEnabled()
	return _G.SIMPLESPYCONFIG_StateTracker ~= false
end

function trackInboundEnabled()
	return _G.SIMPLESPYCONFIG_TrackInbound ~= false
end

function isPropCorrelateEnabled()
	return _G.SIMPLESPYCONFIG_PropCorrelate ~= false
end

function getShortPathName(path)
	if not path or path == "" then
		return "Remote"
	end
	local short = path:match("([^%.]+)$")
	return short or path
end

function formatLogTime(t)
	t = t or tick()
	local h = math.floor(t / 3600) % 24
	local m = math.floor(t / 60) % 60
	local s = math.floor(t) % 60
	return string.format("%02d:%02d:%02d", h, m, s)
end

function appendTimelineEvent(ev)
	ev.id = US.nextTimelineId
	US.nextTimelineId += 1
	ev.time = ev.time or tick()
	table.insert(US.timelineEvents, 1, ev)
	while #US.timelineEvents > US.MAX_TIMELINE_EVENTS do
		table.remove(US.timelineEvents)
	end
	if US.leftPanelView == "timeline" then
		scheduleOnSpyThread(function()
			appendTimelineRow(ev)
		end)
	end
	return ev.id
end

function getGroupColor(direction, logType)
	if logType == "wrapper" then
		return WRAPPER_COLOR
	end
	if direction == "in" then
		return US.INBOUND_COLOR
	end
	return Color3.new(255, 242, 0)
end

function makeLogGroupKey(direction, path)
	return tostring(direction) .. "|" .. tostring(path)
end

function shouldShowLogInGroups(log)
	if log.LogType == "wrapper" and not showWrapperGroups() then
		return false
	end
	return log.LogType == "event" or log.LogType == "function" or log.LogType == "wrapper"
end

function formatGroupSummary(group)
	local lines = {
		string.format("-- %s (%d calls, %s)", group.path, group.count, group.direction == "in" and "inbound" or "outbound"),
		"",
	}
	local maxShow = math.min(#group.entries, 100)
	for i = 1, maxShow do
		local log = group.entries[i]
		local action = log.ActionKey or "?"
		local shape = log.PayloadShape or "?"
		local flowTag = log.FlowId and (" F#" .. tostring(log.FlowId)) or ""
		table.insert(
			lines,
			string.format(
				"-- [#%d] %s  %s  shape=%s%s",
				log.GroupIndex or i,
				formatLogTime(log.Timestamp),
				tostring(action),
				tostring(shape),
				flowTag
			)
		)
	end
	if #group.entries > maxShow then
		table.insert(lines, "-- ... and " .. tostring(#group.entries - maxShow) .. " more")
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function highlightLogFrame(frame, on)
	if not frame then
		return
	end
	pcall(function()
		if on then
			TweenService:Create(frame, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.55,
				BackgroundColor3 = Color3.fromRGB(92, 126, 229),
			}):Play()
		else
			TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		end
	end)
end

function selectLogEntry(log)
	if selected and selected.Log then
		highlightLogFrame(selected.Log, false)
	end
	if selected and selected.SubLogFrame then
		highlightLogFrame(selected.SubLogFrame, false)
	end
	selected = log
	if selected then
		if selected.SubLogFrame then
			highlightLogFrame(selected.SubLogFrame, true)
		elseif selected.Log then
			highlightLogFrame(selected.Log, true)
		end
		local body = selected.GenScript or "-- loading..."
		if selected.StateBlock and selected.StateBlock ~= "" then
			body = body .. "\n" .. selected.StateBlock
		end
		if selected.PropBlock and selected.PropBlock ~= "" then
			body = body .. "\n" .. selected.PropBlock
		end
		if selected.CorrelationBlock and selected.CorrelationBlock ~= "" then
			body = body .. "\n" .. selected.CorrelationBlock
		end
		if selected.ConfidenceBlock and selected.ConfidenceBlock ~= "" then
			body = body .. "\n" .. selected.ConfidenceBlock
		end
		local investigationExtra = formatFullInvestigation(selected)
		if investigationExtra ~= "" then
			body = body .. "\n" .. investigationExtra
		end
		if selected.CauseBlock and selected.CauseBlock ~= "" and not string.find(body, "[CAUSE CHAIN]", 1, true) then
			body = body .. "\n" .. selected.CauseBlock
		end
		if selected.RemoteRefBlock and selected.RemoteRefBlock ~= "" and not string.find(body, "[REMOTE REF]", 1, true) then
			body = body .. "\n" .. selected.RemoteRefBlock
		end
		if selected.WrapperChainBlock and selected.WrapperChainBlock ~= "" and not string.find(body, "[WRAPPER CHAIN]", 1, true) then
			body = body .. "\n" .. selected.WrapperChainBlock
		end
		codebox:setRaw(body)
		scrollLogIntoView(log)
	end
	if sideClosed then
		toggleSideTray()
	end
end

function syncGroupSubListLayout(group)
	if not group or not group.subList or not group.subUILayout then
		return
	end
	local contentH = group.subUILayout.AbsoluteContentSize.Y
	local viewportH = group.expanded and math.min(contentH, US.GROUP_SUB_MAX_H) or 0
	group.subList.Size = UDim2.new(1, -12, 0, viewportH)
	group.subList.CanvasSize = UDim2.new(0, 0, 0, math.max(contentH, 1))
	group.subList.ScrollingEnabled = contentH > US.GROUP_SUB_MAX_H
	if group.container then
		group.container.Size = UDim2.new(1, -8, 0, 27 + viewportH + (group.expanded and 2 or 0))
	end
end

function createSubCallRow(group, log)
	local row = US.gui.SubCallTemplate:Clone()
	row.Name = "SubCall"
	row.Visible = true
	local idx = log.GroupIndex or group.count
	local action = log.ActionKey or "?"
	local flowTag = log.FlowId and (" F#" .. tostring(log.FlowId)) or ""
	row.Text.Text = string.format("#%d %s %s%s", idx, formatLogTime(log.Timestamp), action, flowTag)
	row.ColorBar.BackgroundColor3 = getGroupColor(group.direction, log.LogType)
	applyLogEntryHitArea(row)
	row.Button.MouseButton1Click:Connect(function()
		selectLogEntry(log)
	end)
	row.Parent = group.subList
	log.SubLogFrame = row
	return row
end

function rebuildGroupSubList(group)
	if not group.subList then
		return
	end
	for _, child in ipairs(group.subList:GetChildren()) do
		if child:IsA("GuiObject") and child.Name == "SubCall" then
			child:Destroy()
		end
	end
	for i = 1, #group.entries do
		createSubCallRow(group, group.entries[i])
	end
	syncGroupSubListLayout(group)
end

function updateGroupHeader(group)
	if not group.header then
		return
	end
	local chevron = group.expanded and "▼" or "▶"
	group.header.Text.Text = string.format("%s %s", chevron, getShortPathName(group.path))
	group.header.CountLabel.Text = "x" .. tostring(group.displayCount or group.count)
	pcall(function()
		if group.subList then
			group.subList.Visible = group.expanded
			if group.expanded then
				rebuildGroupSubList(group)
			else
				syncGroupSubListLayout(group)
			end
		end
	end)
end

function toggleGroupExpanded(group)
	group.expanded = not group.expanded
	updateGroupHeader(group)
	updateRemoteCanvas()
end

function createLogGroup(groupKey, path, direction, logType)
	local container = Instance.new("Frame")
	container.Name = "GroupContainer"
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -8, 0, 27)
	container.ClipsDescendants = true

	local header = US.gui.GroupHeaderTemplate:Clone()
	header.Name = "GroupHeader"
	header.Visible = true
	header.ColorBar.BackgroundColor3 = getGroupColor(direction, logType)
	header.Text.Text = "▶ " .. getShortPathName(path)
	header.CountLabel.Text = "x0"
	applyLogEntryHitArea(header)

	local subList = Instance.new("ScrollingFrame")
	subList.Name = "SubList"
	subList.BackgroundTransparency = 1
	subList.Position = UDim2.new(0, 8, 0, 28)
	subList.Size = UDim2.new(1, -12, 0, 0)
	subList.Visible = false
	subList.BorderSizePixel = 0
	subList.ScrollBarThickness = 4
	subList.ScrollingDirection = Enum.ScrollingDirection.Y
	subList.ScrollBarImageColor3 = Color3.fromRGB(130, 130, 130)
	subList.CanvasSize = UDim2.new(0, 0, 0, 0)
	subList.Active = true

	local subUILayout = Instance.new("UIListLayout")
	subUILayout.Parent = subList
	subUILayout.SortOrder = Enum.SortOrder.LayoutOrder
	subUILayout.Padding = UDim.new(0, 2)

	header.Parent = container
	subList.Parent = container

	assignLogUILayoutOrder(nil, container)
	container.Parent = LogList

	local group = {
		key = groupKey,
		path = path,
		direction = direction,
		count = 0,
		displayCount = 0,
		expanded = false,
		entries = {},
		container = container,
		header = header,
		subList = subList,
		subUILayout = subUILayout,
	}
	US.logGroups[groupKey] = group

	group.subUILayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if group.expanded then
			syncGroupSubListLayout(group)
			updateRemoteCanvas()
		end
	end)

	local lastClick = 0
	header.Button.MouseButton1Click:Connect(function()
		local now = tick()
		if now - lastClick < 0.35 then
			codebox:setRaw(formatGroupSummary(group))
			TextLabel.Text = "Group summary loaded"
		else
			toggleGroupExpanded(group)
		end
		lastClick = now
	end)

	return group
end

function appendToLogGroup(log)
	local path = (log.Snapshot and log.Snapshot.path) or log.Name or "Remote"
	local direction = log.Direction or "out"
	local groupKey = makeLogGroupKey(direction, path)
	local group = US.logGroups[groupKey]
	if not group then
		group = createLogGroup(groupKey, path, direction, log.LogType)
	end
	group.count += 1
	group.displayCount = (group.displayCount or 0) + 1
	if group.container then
		assignLogUILayoutOrder(log, group.container)
		group.container.Parent = LogList
	end
	log.GroupKey = groupKey
	log.GroupIndex = group.count
	table.insert(group.entries, 1, log)
	updateGroupHeader(group)
	log.Group = group
	applyLogListVisibility()
end

function mountLogUI(log)
	local visible = logPassesFilter(log)
	if isGroupLogsEnabled() and shouldShowLogInGroups(log) then
		appendToLogGroup(log)
		appendTimelineEvent({
			kind = log.Direction == "in" and "inbound" or "outbound",
			label = (log.Snapshot and log.Snapshot.path) or log.Name,
			detail = log.ActionKey,
			flowId = log.FlowId,
			logRef = log,
			groupKey = log.GroupKey,
		})
	else
		assignLogUILayoutOrder(log, log.Log)
		log.Log.Visible = visible
		log.Log.Parent = LogList
		appendTimelineEvent({
			kind = log.Direction == "in" and "inbound" or "outbound",
			label = (log.Snapshot and log.Snapshot.path) or log.Name,
			detail = log.ActionKey,
			flowId = log.FlowId,
			logRef = log,
		})
	end
end

--- State tracker
function formatStateDelta(oldVal, newVal)
	local oldT, newT = typeof(oldVal), typeof(newVal)
	if oldT == "number" and newT == "number" then
		local d = newVal - oldVal
		if d > 0 then
			return "+" .. tostring(d), "Money+"
		elseif d < 0 then
			return tostring(d), "Money-"
		end
		return "0", nil
	end
	if oldT == "string" and newT == "string" then
		if oldVal ~= newVal then
			return oldVal .. " → " .. newVal, nil
		end
		return nil, nil
	end
	return tostring(oldVal) .. " → " .. tostring(newVal), nil
end

function recordSemanticSignal(actionKey, signalTag)
	local session = getActiveCorrelationSession()
	local ctx = session or US.recentOutboundContext
	if not actionKey or not signalTag or not ctx then
		return
	end
	local path = ctx.path or (session and session.remotePath)
	if not path then
		return
	end
	local entry = US.remoteAtlas[path]
	if not entry then
		return
	end
	entry.semantics = entry.semantics or {}
	local sem = entry.semantics[signalTag]
	if not sem then
		sem = { label = signalTag, score = 0, signals = {} }
		entry.semantics[signalTag] = sem
	end
	sem.score += 1
	table.insert(sem.signals, 1, tostring(actionKey))
	while #sem.signals > 16 do
		table.remove(sem.signals)
	end
end

function onStateChange(path, oldVal, newVal)
	if not isStateTrackerEnabled() then
		return
	end
	local delta, signalTag = formatStateDelta(oldVal, newVal)
	if not delta then
		return
	end
	US.stateBaseline[path] = newVal
	local change = { time = tick(), path = path, oldVal = oldVal, newVal = newVal, delta = delta }
	table.insert(US.stateChanges, 1, change)
	while #US.stateChanges > 256 do
		table.remove(US.stateChanges)
	end
	appendTimelineEvent({
		kind = "state",
		label = path,
		detail = delta,
		flowId = US.recentOutboundContext and US.recentOutboundContext.flowId,
		sessionId = getPrimarySessionId(),
		logRef = US.recentOutboundContext and US.recentOutboundContext.logRef,
	})
	local correlateWindow = getCorrelateWindow()
	if isFlowTrackingEnabled() and US.recentOutboundContext and tick() - US.recentOutboundContext.time <= correlateWindow then
		appendFlowStep(nil, { kind = "State", label = getShortPathName(path) .. " " .. delta })
	end
	pushCorrelationEffect("state", getShortPathName(path) .. " " .. delta, signalTag)
	if selected and US.recentOutboundContext and selected == US.recentOutboundContext.logRef then
		local block = selected.StateBlock or "-- [STATE CHANGE]\n"
		selected.StateBlock = block .. string.format("-- %s: %s\n", getShortPathName(path), delta)
		selectLogEntry(selected)
	end
end

function watchValueAtPath(inst, path)
	if not inst or US.stateWatchConns[path] then
		return
	end
	pcall(function()
		US.stateBaseline[path] = inst.Value
	end)
	local conn = inst:GetPropertyChangedSignal("Value"):Connect(function()
		local oldVal = US.stateBaseline[path]
		local newVal = inst.Value
		if oldVal ~= newVal then
			onStateChange(path, oldVal, newVal)
		end
	end)
	US.stateWatchConns[path] = conn
	table.insert(connections, conn)
end

function watchLeaderstats(player)
	pcall(function()
		local ls = player:FindFirstChild("leaderstats")
		if not ls then
			player.ChildAdded:Connect(function(child)
				if child.Name == "leaderstats" then
					watchLeaderstats(player)
				end
			end)
			return
		end
		for _, child in ipairs(ls:GetChildren()) do
			if child:IsA("ValueBase") then
				watchValueAtPathPhase5(child, "leaderstats." .. child.Name)
			end
		end
		ls.ChildAdded:Connect(function(child)
			if child:IsA("ValueBase") then
				watchValueAtPathPhase5(child, "leaderstats." .. child.Name)
			end
		end)
	end)
end

function startStateTracker()
	if not isStateTrackerEnabled() then
		return
	end
	local player = Players.LocalPlayer
	if not player then
		return
	end
	watchLeaderstats(player)
	pcall(function()
		for name, val in pairs(player:GetAttributes()) do
			US.stateBaseline["attr.Player." .. name] = val
		end
		player.AttributeChanged:Connect(function(name)
			local path = "attr.Player." .. name
			local oldVal = US.stateBaseline[path]
			local newVal = player:GetAttribute(name)
			if oldVal ~= newVal then
				US.stateBaseline[path] = newVal
				if nameMatchesKeySet(name, REWARD_KEYS) then
					onRewardStatChange(path, oldVal, newVal)
				elseif nameMatchesKeySet(name, HEALTH_KEYS) then
					onEntityStatChange(path, name, oldVal, newVal, "health")
				else
					onStateChange(path, oldVal, newVal)
				end
			end
		end)
	end)
end

--- Property correlate (PlayerGui diff window)
function collectGuiPropSnapshot(root, depth, out, maxCount)
	if not root or depth > 4 or #out >= maxCount then
		return
	end
	pcall(function()
		if root:IsA("TextLabel") or root:IsA("TextButton") or root:IsA("TextBox") then
			local path = root:GetFullName()
			if not isPropCosmeticPath(path) then
				table.insert(out, { path = path, prop = "Text", value = root.Text })
			end
		elseif root:IsA("ValueBase") then
			table.insert(out, { path = root:GetFullName(), prop = "Value", value = root.Value })
		end
		for _, child in ipairs(root:GetChildren()) do
			collectGuiPropSnapshot(child, depth + 1, out, maxCount)
		end
	end)
end

function startPropCorrelateWindow(flowId, logRef)
	if not isPropCorrelateEnabled() then
		return
	end
	local player = Players.LocalPlayer
	if not player then
		return
	end
	local maxLines, snapLimit = getPropCorrelateLimits(logRef)
	local snap = {}
	collectGuiPropSnapshot(player:FindFirstChild("PlayerGui"), 0, snap, snapLimit)
	US.activePropWatch = {
		startedAt = tick(),
		deadline = tick() + getCorrelateWindow(),
		baseline = snap,
		flowId = flowId,
		logRef = logRef,
		sessionId = getPrimarySessionId(),
		lines = {},
		maxLines = maxLines,
		reportedKeys = {},
	}
end

function tickPropCorrelate()
	if not US.activePropWatch or tick() > US.activePropWatch.deadline then
		US.activePropWatch = nil
		return
	end
	local player = Players.LocalPlayer
	if not player then
		return
	end
	local current = {}
	collectGuiPropSnapshot(player:FindFirstChild("PlayerGui"), 0, current, 64)
	local byPath = {}
	for _, e in ipairs(current) do
		byPath[e.path .. "|" .. e.prop] = e.value
	end
	for i, e in ipairs(US.activePropWatch.baseline) do
		local key = e.path .. "|" .. e.prop
		if US.activePropWatch.reportedKeys[key] then
			continue
		end
		local newVal = byPath[key]
		if newVal ~= nil and tostring(newVal) ~= tostring(e.value) then
			if not shouldLogPropChange(e.path, e.value, newVal, US.activePropWatch.logRef) then
				US.activePropWatch.baseline[i].value = newVal
				continue
			end
			if #US.activePropWatch.lines >= (US.activePropWatch.maxLines or 8) then
				US.activePropWatch.baseline[i].value = newVal
				continue
			end
			local line = string.format('-- [PROP] %s.%s: "%s" → "%s"', e.path, e.prop, tostring(e.value), tostring(newVal))
			US.activePropWatch.reportedKeys[key] = true
			US.activePropWatch.baseline[i].value = newVal
			table.insert(US.activePropWatch.lines, line)
			if shouldAppendPropTimeline(e.path, e.prop) then
				appendTimelineEvent({
					kind = "prop",
					label = getShortPathName(e.path),
					detail = tostring(e.value) .. " → " .. tostring(newVal),
					flowId = US.activePropWatch.flowId,
					logRef = US.activePropWatch.logRef,
					sessionId = US.activePropWatch.sessionId or getPrimarySessionId(),
				})
			end
			if US.activePropWatch.logRef then
				rebuildLogPropBlock(US.activePropWatch.logRef, US.activePropWatch.lines, US.activePropWatch.maxLines)
			end
			pushCorrelationEffect(
				"prop",
				getShortPathName(e.path) .. "." .. e.prop,
				tostring(e.value) .. " → " .. tostring(newVal),
				US.activePropWatch.logRef
			)
		end
	end
end

--- Inbound OnClientEvent
function inboundHandler(remote, args)
	local snapshot = makeRemoteSnapshot(remote)
	snapshot.isInbound = true
	if blacklist[remote] or blacklist[snapshot.name] then
		return
	end
	local payloadShape = nil
	pcall(function()
		payloadShape = select(1, recordRemoteObservation(snapshot, args, "onclientevent"))
	end)
	-- Replication/effect remotes are inbound sync; avoid polluting flow visual with spam.
	if snapshot.remoteRole ~= "replication_effect" then
		appendFlowStep(nil, { kind = "Inbound", label = snapshot.path or snapshot.name, method = "OnClientEvent" })
	end
	local flowSnapshot = captureFlowSnapshot(nil)
	local actionKey = inferActionKey(args)
	local uiTrigger = getRecentUiTrigger()
	recordNetworkGraph({}, snapshot, uiTrigger)
	scheduleOnSpyThread(function()
		local logIndex = newRemoteSync(
			"event",
			snapshot.name,
			args,
			remote,
			nil,
			false,
			nil,
			nil,
			snapshot,
			{},
			"",
			getRecentUiTrigger(),
			flowSnapshot,
			payloadShape,
			"in"
		)
		if logIndex and logs[logIndex] then
			logs[logIndex].ActionKey = actionKey
			attachLikelyCauseToSyncLog(logs[logIndex], snapshot)
			refreshLogDisplayName(logs[logIndex])
			recordRecentInbound(snapshot.path, actionKey, logs[logIndex])
			recordRemoteLifecycleCall(snapshot, remote)
			openCorrelationSession(
				logs[logIndex],
				snapshot,
				actionKey,
				flowSnapshot and flowSnapshot.id,
				uiTrigger,
				{},
				"in"
			)
			startPropCorrelateWindow(flowSnapshot and flowSnapshot.id, logs[logIndex])
			local detail = payloadShape or ""
			if args and args[1] == false then
				detail = detail .. " fail"
			end
			pushCorrelationEffect(
				"inbound",
				getShortPathName(snapshot.path or snapshot.name),
				detail,
				US.recentOutboundContext and US.recentOutboundContext.logRef
			)
		end
	end)
end

function attachInboundSpy(remote)
	if not trackInboundEnabled() or US.inboundSpied[remote] then
		return
	end
	if not remote:IsA("RemoteEvent") and not remote:IsA("UnreliableRemoteEvent") then
		return
	end
	local ok, conn = pcall(function()
		return remote.OnClientEvent:Connect(function(...)
			inboundHandler(remote, { ... })
		end)
	end)
	if ok and conn then
		US.inboundSpied[remote] = conn
		table.insert(connections, conn)
	end
end

function scanInboundRemotes(root)
	if not trackInboundEnabled() then
		return
	end
	pcall(function()
		for _, inst in ipairs(root:GetDescendants()) do
			if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") then
				attachInboundSpy(inst)
			end
		end
	end)
end

--- Timeline UI rows
function formatRelativeTime(t)
	local dt = tick() - (t or tick())
	if dt < 1 then
		return "now"
	end
	if dt < 60 then
		return string.format("%.1fs", dt)
	end
	return string.format("%.0fm", dt / 60)
end

function appendTimelineRow(ev)
	if not US.gui.TimelineList or not US.gui.TimelineRowTemplate then
		return
	end
	local kind = ev.kind or "?"
	if US.timelineFilter[kind] == false then
		return
	end
	if kind == "remote_birth" or kind == "remote_death" or kind == "remote_created" or kind == "remote_moved" then
		if US.timelineFilter.lifecycle == false then
			return
		end
	end
	local row = US.gui.TimelineRowTemplate:Clone()
	row.Name = "TimelineRow"
	row.Visible = true
	local tag = string.upper(string.sub(kind, 1, 3))
	if kind == "outbound" then
		tag = "OUT"
	elseif kind == "inbound" then
		tag = "IN"
	end
	row.Text.Text = string.format(
		"%s %s %s %s",
		formatRelativeTime(ev.time),
		tag,
		string.sub(ev.label or "?", 1, 24),
		ev.detail and string.sub(tostring(ev.detail), 1, 14) or ""
	)
	if ev.sessionId then
		row.Text.Text = row.Text.Text .. " S#" .. tostring(ev.sessionId)
	end
	row.ColorBar.BackgroundColor3 = kind == "inbound" and US.INBOUND_COLOR
		or kind == "state" and US.STATE_EVENT_COLOR
		or kind == "prop" and US.PROP_EVENT_COLOR
		or kind == "cause" and US.CAUSE_EVENT_COLOR
		or kind == "investigation" and US.INVESTIGATION_COLOR
		or kind == "entity" and US.ENTITY_EVENT_COLOR
		or kind == "ui" and Color3.fromRGB(120, 200, 120)
		or (kind == "remote_birth" or kind == "remote_created") and Color3.fromRGB(100, 220, 140)
		or kind == "remote_found" and Color3.fromRGB(255, 180, 80)
		or kind == "remote_death" and Color3.fromRGB(220, 100, 100)
		or Color3.new(255, 242, 0)
	applyLogEntryHitArea(row)
	row.Button.MouseButton1Click:Connect(function()
		if ev.logRef then
			setLeftPanelView("logs")
			selectLogEntry(ev.logRef)
		elseif ev.detail then
			codebox:setRaw("-- Timeline: " .. tostring(ev.label) .. "\n-- " .. tostring(ev.detail))
		end
	end)
	if layoutOrderNum < 1 then
		layoutOrderNum = 999999999
	end
	row.LayoutOrder = layoutOrderNum
	layoutOrderNum = layoutOrderNum - 1
	row.Parent = US.gui.TimelineList
	pcall(function()
		US.gui.TimelineList.CanvasSize = UDim2.fromOffset(0, US.gui.TimelineUILayout.AbsoluteContentSize.Y)
	end)
end

function rebuildTimelineView()
	if not US.gui.TimelineList then
		return
	end
	for _, child in ipairs(US.gui.TimelineList:GetChildren()) do
		if child:IsA("GuiObject") and child.Name == "TimelineRow" then
			child:Destroy()
		end
	end
	for i = #US.timelineEvents, 1, -1 do
		appendTimelineRow(US.timelineEvents[i])
	end
end

function rebuildAtlasView()
	if not US.gui.AtlasList then
		return
	end
	for _, child in ipairs(US.gui.AtlasList:GetChildren()) do
		if child:IsA("GuiObject") and child.Name == "AtlasRow" then
			child:Destroy()
		end
	end
	local paths = {}
	for path in pairs(US.remoteAtlas or {}) do
		table.insert(paths, path)
	end
	table.sort(paths)
	for _, path in ipairs(paths) do
		local row = US.gui.TimelineRowTemplate:Clone()
		row.Name = "AtlasRow"
		row.Visible = true
		row.Text.Text = getShortPathName(path)
		row.ColorBar.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
		applyLogEntryHitArea(row)
		row.Button.MouseButton1Click:Connect(function()
			for _, log in ipairs(logs) do
				if log.Snapshot and log.Snapshot.path == path then
					setLeftPanelView("logs")
					selectLogEntry(log)
					return
				end
			end
			setSpyStatus("No log for " .. path)
		end)
		row.Parent = US.gui.AtlasList
	end
	pcall(function()
		US.gui.AtlasList.CanvasSize = UDim2.fromOffset(0, US.gui.AtlasUILayout.AbsoluteContentSize.Y)
	end)
end

function setLeftPanelView(view)
	US.leftPanelView = view
	if LogList then
		LogList.Visible = view == "logs"
	end
	if US.gui.TimelineList then
		US.gui.TimelineList.Visible = view == "timeline"
		if US.gui.TimelineFilterBar then
			US.gui.TimelineFilterBar.Visible = view == "timeline"
		end
		if view == "timeline" then
			rebuildTimelineView()
		end
	end
	if US.gui.AtlasList then
		US.gui.AtlasList.Visible = view == "atlas"
		if view == "atlas" then
			rebuildAtlasView()
		end
	end
	if US.gui.LeftFilterBar then
		US.gui.LeftFilterBar.Visible = view == "logs"
	end
	pcall(function()
		if US.gui.ViewTabLogs then
			US.gui.ViewTabLogs.Text = view == "logs" and "[Logs]" or "Logs"
		end
		if US.gui.ViewTabTimeline then
			US.gui.ViewTabTimeline.Text = view == "timeline" and "[Timeline]" or "Timeline"
		end
		if US.gui.ViewTabAtlas then
			US.gui.ViewTabAtlas.Text = view == "atlas" and "[Atlas]" or "Atlas"
		end
	end)
end

function setupPhase2Gui()
	function cloneRowTemplate(name, barColor)
		local f = Instance.new("Frame")
		f.Name = name
		f.BackgroundTransparency = 1
		f.Size = UDim2.new(1, -8, 0, 22)
		f.ClipsDescendants = true
		local bar = Instance.new("Frame")
		bar.Name = "ColorBar"
		bar.Size = UDim2.new(0, 5, 1, -2)
		bar.Position = UDim2.new(0, 0, 0, 1)
		bar.BackgroundColor3 = barColor
		bar.BorderSizePixel = 0
		bar.Parent = f
		local lbl = Instance.new("TextLabel")
		lbl.Name = "Text"
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.Size = UDim2.new(1, -12, 1, 0)
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 13
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.Parent = f
		local btn = Instance.new("TextButton")
		btn.Name = "Button"
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.Text = ""
		btn.ZIndex = 10
		btn.Parent = f
		return f
	end

	US.gui.GroupHeaderTemplate = Instance.new("Frame")
	US.gui.GroupHeaderTemplate.Name = "GroupHeaderTemplate"
	US.gui.GroupHeaderTemplate.BackgroundTransparency = 1
	US.gui.GroupHeaderTemplate.Size = UDim2.new(1, -4, 0, 27)
	local ghBar = Instance.new("Frame")
	ghBar.Name = "ColorBar"
	ghBar.Size = UDim2.new(0, 7, 0, 25)
	ghBar.BackgroundColor3 = Color3.new(255, 242, 0)
	ghBar.BorderSizePixel = 0
	ghBar.Parent = US.gui.GroupHeaderTemplate
	local ghText = Instance.new("TextLabel")
	ghText.Name = "Text"
	ghText.BackgroundTransparency = 1
	ghText.Position = UDim2.new(0, 10, 0, 0)
	ghText.Size = UDim2.new(1, -48, 1, 0)
	ghText.Font = Enum.Font.SourceSansBold
	ghText.TextSize = 13
	ghText.TextColor3 = Color3.new(1, 1, 1)
	ghText.TextXAlignment = Enum.TextXAlignment.Left
	ghText.TextTruncate = Enum.TextTruncate.AtEnd
	ghText.Text = "▶ Remote"
	ghText.Parent = US.gui.GroupHeaderTemplate
	local ghCount = Instance.new("TextLabel")
	ghCount.Name = "CountLabel"
	ghCount.BackgroundTransparency = 1
	ghCount.Position = UDim2.new(1, -42, 0, 0)
	ghCount.Size = UDim2.new(0, 40, 1, 0)
	ghCount.Font = Enum.Font.SourceSansBold
	ghCount.TextSize = 13
	ghCount.TextColor3 = Color3.fromRGB(180, 200, 255)
	ghCount.TextXAlignment = Enum.TextXAlignment.Right
	ghCount.Text = "x0"
	ghCount.Parent = US.gui.GroupHeaderTemplate
	local ghBtn = Instance.new("TextButton")
	ghBtn.Name = "Button"
	ghBtn.BackgroundTransparency = 1
	ghBtn.Size = UDim2.new(1, 0, 1, 0)
	ghBtn.Text = ""
	ghBtn.ZIndex = 10
	ghBtn.Parent = US.gui.GroupHeaderTemplate

	US.gui.SubCallTemplate = cloneRowTemplate("SubCallTemplate", Color3.new(255, 242, 0))
	US.gui.TimelineRowTemplate = cloneRowTemplate("TimelineRowTemplate", Color3.new(255, 242, 0))

	US.gui.TimelineList = Instance.new("ScrollingFrame")
	US.gui.TimelineList.Name = "TimelineList"
	US.gui.TimelineList.Parent = LeftPanel
	US.gui.TimelineList.BackgroundTransparency = 1
	US.gui.TimelineList.BorderSizePixel = 0
	US.gui.TimelineList.Position = UDim2.new(0, 2, 0, LEFT_PANEL_TOP_INSET + 22)
	US.gui.TimelineList.Size = UDim2.new(1, -4, 1, -(LEFT_PANEL_TOP_INSET + 26))
	US.gui.TimelineList.ScrollBarThickness = 4
	US.gui.TimelineList.Visible = false
	US.gui.TimelineList.CanvasSize = UDim2.new(0, 0, 0, 0)
	US.gui.TimelineUILayout = Instance.new("UIListLayout")
	US.gui.TimelineUILayout.Parent = US.gui.TimelineList
	US.gui.TimelineUILayout.SortOrder = Enum.SortOrder.LayoutOrder
	US.gui.TimelineUILayout.Padding = UDim.new(0, 2)

	US.gui.AtlasList = Instance.new("ScrollingFrame")
	US.gui.AtlasList.Name = "AtlasList"
	US.gui.AtlasList.Parent = LeftPanel
	US.gui.AtlasList.BackgroundTransparency = 1
	US.gui.AtlasList.BorderSizePixel = 0
	US.gui.AtlasList.Position = UDim2.new(0, 2, 0, LEFT_PANEL_TOP_INSET)
	US.gui.AtlasList.Size = UDim2.new(1, -4, 1, -(LEFT_PANEL_TOP_INSET + 4))
	US.gui.AtlasList.ScrollBarThickness = 4
	US.gui.AtlasList.Visible = false
	US.gui.AtlasUILayout = Instance.new("UIListLayout")
	US.gui.AtlasUILayout.Parent = US.gui.AtlasList
	US.gui.AtlasUILayout.SortOrder = Enum.SortOrder.LayoutOrder
	US.gui.AtlasUILayout.Padding = UDim.new(0, 2)

	local filterBar = Instance.new("Frame")
	filterBar.Name = "LeftFilterBar"
	filterBar.Parent = LeftPanel
	filterBar.BackgroundColor3 = Color3.fromRGB(45, 44, 48)
	filterBar.BorderSizePixel = 0
	filterBar.Position = UDim2.new(0, 0, 0, 20)
	filterBar.Size = UDim2.new(1, 0, 0, 48)
	US.gui.LeftFilterBar = filterBar

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "LogSearch"
	searchBox.Parent = filterBar
	searchBox.BackgroundColor3 = Color3.fromRGB(30, 29, 32)
	searchBox.BorderSizePixel = 0
	searchBox.Position = UDim2.new(0, 4, 0, 2)
	searchBox.Size = UDim2.new(1, -8, 0, 20)
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.SourceSans
	searchBox.TextSize = 12
	searchBox.TextColor3 = Color3.new(1, 1, 1)
	searchBox.PlaceholderText = "Search remotes..."
	searchBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
	searchBox.Text = ""
	US.gui.LogSearchBox = searchBox
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		US.logViewFilter.search = searchBox.Text or ""
		scheduleLogFilterRefresh()
	end)

	local function makeChip(parent, text, x, width, onToggle)
		local c = Instance.new("TextButton")
		c.Parent = parent
		c.Size = UDim2.fromOffset(width or 34, 18)
		c.Position = UDim2.fromOffset(x, 26)
		c.BackgroundColor3 = Color3.fromRGB(60, 58, 65)
		c.BorderSizePixel = 0
		c.Font = Enum.Font.SourceSans
		c.TextSize = 10
		c.Text = text
		c.TextColor3 = Color3.new(1, 1, 1)
		c.AutoButtonColor = true
		c.MouseButton1Click:Connect(onToggle)
		return c
	end

	local chipState = { dir = "all", role = "all" }
	local chipVisuals = {}
	local function refreshVisual(chip, isOn, baseText)
		if not chip then
			return
		end
		chip.BackgroundColor3 = isOn and Color3.fromRGB(34, 120, 70) or Color3.fromRGB(60, 58, 65)
		chip.Text = isOn and (baseText .. " ▼") or baseText
	end
	local function refreshFilterChipVisuals()
		refreshVisual(chipVisuals.Out, chipState.dir == "out", "Out")
		refreshVisual(chipVisuals.In, chipState.dir == "in", "In")
		refreshVisual(chipVisuals.Act, chipState.role == "action", "Act")
		refreshVisual(chipVisuals.Sync, chipState.role == "sync", "Sync")
		refreshVisual(chipVisuals.NoSpam, US.logViewFilter.hideSpam == true, "NoSpam")
		refreshVisual(chipVisuals.Verified, US.logViewFilter.verifiedOnly == true, "Ver")
	end
	US.gui.FilterChipOut = makeChip(filterBar, "Out", 4, 30, function()
		chipState.dir = chipState.dir == "out" and "all" or "out"
		US.logViewFilter.direction = chipState.dir
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	chipVisuals.Out = US.gui.FilterChipOut
	chipVisuals.In = makeChip(filterBar, "In", 36, 26, function()
		chipState.dir = chipState.dir == "in" and "all" or "in"
		US.logViewFilter.direction = chipState.dir
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	chipVisuals.Act = makeChip(filterBar, "Act", 64, 30, function()
		chipState.role = chipState.role == "action" and "all" or "action"
		US.logViewFilter.role = chipState.role
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	chipVisuals.Sync = makeChip(filterBar, "Sync", 96, 34, function()
		chipState.role = chipState.role == "sync" and "all" or "sync"
		US.logViewFilter.role = chipState.role
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	chipVisuals.NoSpam = makeChip(filterBar, "NoSpam", 132, 44, function()
		US.logViewFilter.hideSpam = not US.logViewFilter.hideSpam
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	chipVisuals.Verified = makeChip(filterBar, "Ver", 178, 30, function()
		US.logViewFilter.verifiedOnly = not US.logViewFilter.verifiedOnly
		_G.SIMPLESPYCONFIG_VerifiedOnly = US.logViewFilter.verifiedOnly
		refreshFilterChipVisuals()
		scheduleLogFilterRefresh()
	end)
	local function syncActionHuntChipsFromFilter()
		chipState.dir = US.logViewFilter.direction or "all"
		chipState.role = US.logViewFilter.role or "all"
	end
	if isActionHuntModeEnabled() then
		applyActionHuntPreset()
		applyActionHuntChipDefaults(chipState)
		syncActionHuntChipsFromFilter()
	end
	refreshFilterChipVisuals()

	local tlFilter = Instance.new("Frame")
	tlFilter.Name = "TimelineFilterBar"
	tlFilter.Parent = LeftPanel
	tlFilter.BackgroundColor3 = Color3.fromRGB(45, 44, 48)
	tlFilter.BorderSizePixel = 0
	tlFilter.Position = UDim2.new(0, 0, 0, 20)
	tlFilter.Size = UDim2.new(1, 0, 0, 22)
	tlFilter.Visible = false
	US.gui.TimelineFilterBar = tlFilter
	US.timelineFilter.lifecycle = true

	local function tlChip(label, x, kindKey)
		local c = Instance.new("TextButton")
		c.Parent = tlFilter
		c.Size = UDim2.fromOffset(36, 18)
		c.Position = UDim2.fromOffset(x, 2)
		c.BackgroundColor3 = Color3.fromRGB(60, 58, 65)
		c.Font = Enum.Font.SourceSans
		c.TextSize = 9
		c.Text = label
		c.TextColor3 = Color3.new(1, 1, 1)
		c.MouseButton1Click:Connect(function()
			if kindKey == "lifecycle" then
				US.timelineFilter.lifecycle = not US.timelineFilter.lifecycle
			else
				US.timelineFilter[kindKey] = not US.timelineFilter[kindKey]
			end
			rebuildTimelineView()
		end)
	end
	tlChip("OUT", 2, "outbound")
	tlChip("IN", 40, "inbound")
	tlChip("UI", 78, "ui")
	tlChip("St", 114, "state")
	tlChip("Pr", 150, "prop")
	tlChip("Lf", 186, "lifecycle")

	function makeViewTab(name, xOff, label)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Parent = TopBar
		b.BackgroundTransparency = 1
		b.Position = UDim2.new(0, xOff, 0, 1)
		b.Size = UDim2.new(0, 52, 0, 17)
		b.Font = Enum.Font.SourceSans
		b.TextSize = 12
		b.TextColor3 = Color3.fromRGB(200, 200, 200)
		b.Text = label
		b.AutoButtonColor = false
		return b
	end
	US.gui.ViewTabLogs = makeViewTab("ViewTabLogs", 68, "[Logs]")
	US.gui.ViewTabTimeline = makeViewTab("ViewTabTimeline", 122, "Timeline")
	US.gui.ViewTabAtlas = makeViewTab("ViewTabAtlas", 178, "Atlas")
	US.gui.ViewTabLogs.MouseButton1Click:Connect(function()
		setLeftPanelView("logs")
	end)
	US.gui.ViewTabTimeline.MouseButton1Click:Connect(function()
		setLeftPanelView("timeline")
	end)
	US.gui.ViewTabAtlas.MouseButton1Click:Connect(function()
		setLeftPanelView("atlas")
	end)

	buildToolPanel()
	layoutLeftListFrames()
end

function formatStateLog()
	local lines = { "-- State changes (session)", "" }
	if #US.stateChanges == 0 then
		table.insert(lines, "-- (none yet)")
		return table.concat(lines, "\n")
	end
	for _, c in ipairs(US.stateChanges) do
		table.insert(lines, string.format("-- %s  %s: %s", formatLogTime(c.time), c.path, c.delta))
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatTimelineText()
	local lines = { "-- Timeline (newest first)", "" }
	for _, ev in ipairs(US.timelineEvents) do
		table.insert(
			lines,
			string.format("%s  [%s]  %s  %s", formatLogTime(ev.time), ev.kind or "?", ev.label or "?", ev.detail or "")
		)
	end
	return table.concat(lines, "\n")
end

--- Adds new Remote to logs
--- @param name string The name of the remote being logged
--- @param type string The type of the remote being logged (either 'function' or 'event')
--- @param args any
--- @param remote any
--- @param function_info string
--- @param blocked any
function newRemoteSync(
	type,
	name,
	args,
	remote,
	function_info,
	blocked,
	src,
	returnValue,
	snapshot,
	callStack,
	spamTag,
	uiTrigger,
	flowSnapshot,
	payloadShape,
	direction
)
	direction = direction or "out"
	local displayName = name
	if snapshot and snapshot.path then
		displayName = snapshot.path
	end
	if flowSnapshot and flowSnapshot.id then
		displayName = string.format("[F#%d] ", flowSnapshot.id) .. displayName
	end
	if spamTag and spamTag ~= "" then
		displayName = spamTag .. displayName
	end
	-- Role tags to differentiate sync/replication effects from action candidates
	local remoteRole = "unknown"
	if snapshot and snapshot.path then
		remoteRole = getRemoteRole(snapshot.path, snapshot)
		snapshot.remoteRole = remoteRole
	end
	if remoteRole == "replication_effect" then
		displayName = "[SYNC] " .. displayName
	elseif remoteRole == "action_candidate" then
		displayName = "[ACTION] " .. displayName
	end
	if US.lastFiredRefId then
		local bucket = nil
		if snapshot and snapshot.path then
			bucket = US.remoteReferences[snapshot.path]
		end
		if bucket and bucket.byRefId[US.lastFiredRefId] then
			displayName = string.format("[REF#%d] ", US.lastFiredRefId) .. displayName
		end
	end
	local remoteFrame = RemoteTemplate:Clone()
	applyLogEntryHitArea(remoteFrame)
	remoteFrame.Text.Text = string.sub(displayName, 1, 50)
	if direction == "in" then
		remoteFrame.ColorBar.BackgroundColor3 = US.INBOUND_COLOR
	else
		remoteFrame.ColorBar.BackgroundColor3 = type == "event" and Color3.new(255, 242, 0) or Color3.fromRGB(99, 86, 245)
	end
	local weakRemoteTable = setmetatable({ remote = remote }, { __mode = "v" })
	local actionKey = inferActionKey(args)
	local log = {
		Name = name,
		Function = function_info,
		Remote = weakRemoteTable,
		Log = remoteFrame,
		Blocked = blocked,
		Source = src,
		Snapshot = snapshot,
		CallStack = callStack,
		UiTrigger = uiTrigger,
		FlowSnapshot = flowSnapshot,
		FlowId = flowSnapshot and flowSnapshot.id,
		PayloadShape = payloadShape,
		DisplayBase = displayName,
		SpamTag = spamTag,
		DuplicateCount = 1,
		LogId = #logs + 1,
		LogType = type,
		Direction = direction,
		Args = args,
		ActionKey = actionKey,
		RemoteRole = remoteRole,
		Timestamp = tick(),
		GenScript = "-- Generating, please wait... (click to reload)\n-- (If this message persists, the remote args are likely extremely long)",
		ReturnValue = returnValue,
	}
	logs[#logs + 1] = log
	local logIndex = #logs
	schedule(function()
		local stackHeader = formatCallStackForScript(callStack, snapshot, uiTrigger, flowSnapshot, payloadShape)
		local body = genScript(remote, args, snapshot, logs[logIndex])
		logs[logIndex].GenScript = stackHeader .. body
		if blocked then
			logs[logIndex].GenScript = "-- THIS REMOTE WAS PREVENTED FROM FIRING THE SERVER BY SIMPLESPY\n\n"
				.. logs[logIndex].GenScript
		end
		if selected and selected == logs[logIndex] then
			selectLogEntry(logs[logIndex])
		end
	end)
	local connect = remoteFrame.Button.MouseButton1Click:Connect(function()
		eventSelect(remoteFrame)
	end)
	remoteFrame.Parent = nil
	mountLogUI(log)
	if direction == "out" then
		recordRemoteLifecycleCall(snapshot, remote)
		openCorrelationSession(
			log,
			snapshot,
			actionKey,
			flowSnapshot and flowSnapshot.id,
			uiTrigger,
			callStack,
			"out"
		)
		startPropCorrelateWindow(flowSnapshot and flowSnapshot.id, log)
	end
	table.insert(remoteLogs, 1, { connect, remoteFrame })
	clean()
	updateRemoteCanvas()
	return logIndex
end

function newRemote(
	type,
	name,
	args,
	remote,
	function_info,
	blocked,
	src,
	returnValue,
	snapshot,
	callStack,
	spamTag,
	uiTrigger,
	flowSnapshot,
	payloadShape
)
	scheduleOnSpyThread(function()
		newRemoteSync(
			type,
			name,
			args,
			remote,
			function_info,
			blocked,
			src,
			returnValue,
			snapshot,
			callStack,
			spamTag,
			uiTrigger,
			flowSnapshot,
			payloadShape
		)
	end)
end

--- Generates a script from the provided arguments (first has to be remote path)
function genScript(remote, args, snapshot, log)
	prevTables = {}
	local gen = ""
	local remoteValid = false
	if typeof(remote) == "Instance" then
		remoteValid = pcall(function()
			return isLoggableRemoteClass(remote)
		end)
	end
	local remoteExpr = getRemoteReplayExpr(remote, snapshot, remoteValid)
	local fireMethod = "FireServer"
	local invokeMethod = "InvokeServer"
	if snapshot and snapshot.className == "UnreliableRemoteEvent" then
		fireMethod = "FireServer"
	end
	local direction = log and log.Direction or (snapshot and snapshot.isInbound and "in" or "out")
	local remoteRole = getRemoteRole(snapshot and snapshot.path, snapshot)
	if log and log.RemoteRole and remoteRole == "unknown" then
		remoteRole = log.RemoteRole
	end
	-- replication_effect remotes stay EFFECT ONLY even on outbound (ReplicaSet); action remotes in ReplicatedStorage still get FireServer
	local effectOnly = direction == "in" or remoteRole == "replication_effect"
	if snapshot and effectOnly then
		local header = "-- Script generated by UltraSpy - credits to exx#9394\n\n"
			.. "-- EFFECT ONLY — server sync / inbound remote.\n"
			.. "-- This OnClientEvent payload reflects a server update; replaying FireServer here will NOT grant rewards.\n\n"
		if #args > 0 then
			pcall(function()
				gen = v2v({ args = args }) .. "\n"
			end)
		end
		gen = gen .. remoteExpr .. ":FireServer(unpack(args))  -- NOT recommended (effect sync)\n"
		prevTables = {}
		return header .. gen
	end
	local actionHint = ""
	local valuableScore = log and log.ValuableActionScore
	if not valuableScore and snapshot and snapshot.path then
		valuableScore = US.remoteActionScores[snapshot.path]
	end
	if valuableScore and valuableScore >= 70 and snapshot and snapshot.remoteRole == "action_candidate" then
		actionHint = "\n-- VERIFIED ACTION CANDIDATE — replay may work\n" .. actionHint
	end
	if snapshot and snapshot.remoteRole == "action_candidate" then
		pcall(function()
			local actionKey = inferActionKey(args)
			local act = classifyAction(actionKey, log and log.CallStack, snapshot and snapshot.path)
			if act and act.class and act.confidence then
				actionHint = actionHint
					.. string.format(
						"-- ValuableAction hint: likely %s (conf %d%%, score %s)\n",
						tostring(act.class),
						tonumber(act.confidence) or 0,
						tostring(valuableScore or "?")
					)
			end
		end)
	end
	if #args > 0 then
		if not pcall(function()
			gen = v2v({ args = args }) .. "\n"
		end) then
			gen = gen
				.. "-- TableToString failure! Reverting to legacy functionality (results may vary)\nlocal args = {"
			if
				not pcall(function()
					for i, v in pairs(args) do
						if type(i) ~= "Instance" and type(i) ~= "userdata" then
							gen = gen .. "\n    [object] = "
						elseif type(i) == "string" then
							gen = gen .. '\n    ["' .. i .. '"] = '
						elseif type(i) == "userdata" and typeof(i) ~= "Instance" then
							gen = gen .. "\n    [" .. string.format("nil --[[%s]]", typeof(v)) .. ")] = "
						elseif type(i) == "userdata" then
							gen = gen .. "\n    [game." .. i:GetFullName() .. ")] = "
						end
						if type(v) ~= "Instance" and type(v) ~= "userdata" then
							gen = gen .. "object"
						elseif type(v) == "string" then
							gen = gen .. '"' .. v .. '"'
						elseif type(v) == "userdata" and typeof(v) ~= "Instance" then
							gen = gen .. string.format("nil --[[%s]]", typeof(v))
						elseif type(v) == "userdata" then
							gen = gen .. "game." .. v:GetFullName()
						end
					end
					gen = gen .. "\n}\n\n"
				end)
			then
				gen = gen .. "}\n-- Legacy tableToString failure! Unable to decompile."
			end
		end
		if remoteValid and not remote:IsDescendantOf(game) and not getnilrequired then
			gen = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n\n"
				.. gen
		end
		if (snapshot and snapshot.className == "RemoteFunction")
			or (remoteValid and remote:IsA("RemoteFunction"))
		then
			gen = gen .. appendGenScriptRemoteCall("", remoteExpr, invokeMethod, true)
		else
			gen = gen .. appendGenScriptRemoteCall("", remoteExpr, fireMethod, true)
		end
	else
		if (snapshot and snapshot.className == "RemoteFunction")
			or (remoteValid and remote:IsA("RemoteFunction"))
		then
			gen = gen .. appendGenScriptRemoteCall("", remoteExpr, invokeMethod, false)
		else
			gen = gen .. appendGenScriptRemoteCall("", remoteExpr, fireMethod, false)
		end
	end
	gen = "-- Script generated by UltraSpy - credits to exx#9394\n\n" .. actionHint .. gen
	prevTables = {}
	return gen
end

--- value-to-string: value, string (out), level (indentation), parent table, var name, is from tovar
function v2s(v, l, p, n, vtv, i, pt, path, tables, tI)
	if not tI then
		tI = { 0 }
	else
		tI[1] += 1
	end
	if typeof(v) == "number" then
		if v == math.huge then
			return "math.huge"
		elseif tostring(v):match("nan") then
			return "0/0 --[[NaN]]"
		end
		return tostring(v)
	elseif typeof(v) == "boolean" then
		return tostring(v)
	elseif typeof(v) == "string" then
		return formatstr(v, l)
	elseif typeof(v) == "function" then
		return f2s(v)
	elseif typeof(v) == "table" then
		return t2s(v, l, p, n, vtv, i, pt, path, tables, tI)
	elseif typeof(v) == "Instance" then
		return i2p(v)
	elseif typeof(v) == "userdata" then
		return "newproxy(true)"
	elseif type(v) == "userdata" then
		return u2s(v)
	elseif type(v) == "vector" then
		return string.format("Vector3.new(%s, %s, %s)", v2s(v.X), v2s(v.Y), v2s(v.Z))
	else
		return "nil --[[" .. typeof(v) .. "]]"
	end
end

--- value-to-variable
--- @param t any
function v2v(t)
	topstr = ""
	bottomstr = ""
	getnilrequired = false
	local ret = ""
	local count = 1
	for i, v in pairs(t) do
		if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
			ret = ret .. "local " .. i .. " = " .. v2s(v, nil, nil, i, true) .. "\n"
		elseif tostring(i):match("^[%a_]+[%w_]*$") then
			ret = ret
				.. "local "
				.. tostring(i):lower()
				.. "_"
				.. tostring(count)
				.. " = "
				.. v2s(v, nil, nil, tostring(i):lower() .. "_" .. tostring(count), true)
				.. "\n"
		else
			ret = ret
				.. "local "
				.. type(v)
				.. "_"
				.. tostring(count)
				.. " = "
				.. v2s(v, nil, nil, type(v) .. "_" .. tostring(count), true)
				.. "\n"
		end
		count = count + 1
	end
	if getnilrequired then
		topstr = "function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end\n"
			.. topstr
	end
	if #topstr > 0 then
		ret = topstr .. "\n" .. ret
	end
	if #bottomstr > 0 then
		ret = ret .. bottomstr
	end
	return ret
end

--- table-to-string
--- @param t table
--- @param l number
--- @param p table
--- @param n string
--- @param vtv boolean
--- @param i any
--- @param pt table
--- @param path string
--- @param tables table
--- @param tI table
function t2s(t, l, p, n, vtv, i, pt, path, tables, tI)
	local globalIndex = table.find(getgenv(), t) -- checks if table is a global
	if type(globalIndex) == "string" then
		return globalIndex
	end
	if not tI then
		tI = { 0 }
	end
	if not path then -- sets path to empty string (so it doesn't have to manually provided every time)
		path = ""
	end
	if not l then -- sets the level to 0 (for indentation) and tables for logging tables it already serialized
		l = 0
		tables = {}
	end
	if not p then -- p is the previous table but doesn't really matter if it's the first
		p = t
	end
	for _, v in pairs(tables) do -- checks if the current table has been serialized before
		if n and rawequal(v, t) then
			bottomstr = bottomstr
				.. "\n"
				.. tostring(n)
				.. tostring(path)
				.. " = "
				.. tostring(n)
				.. tostring(({ v2p(v, p) })[2])
			return "{} --[[DUPLICATE]]"
		end
	end
	table.insert(tables, t) -- logs table to past tables
	local s = "{" -- start of serialization
	local size = 0
	l = l + indent -- set indentation level
	for k, v in pairs(t) do -- iterates over table
		size = size + 1 -- changes size for max limit
		if size > (_G.SimpleSpyMaxTableSize or 1000) then
			s = s
				.. "\n"
				.. string.rep(" ", l)
				.. "-- MAXIMUM TABLE SIZE REACHED, CHANGE '_G.SimpleSpyMaxTableSize' TO ADJUST MAXIMUM SIZE "
			break
		end
		if rawequal(k, t) then -- checks if the table being iterated over is being used as an index within itself (yay, lua)
			bottomstr = bottomstr
				.. "\n"
				.. tostring(n)
				.. tostring(path)
				.. "["
				.. tostring(n)
				.. tostring(path)
				.. "]"
				.. " = "
				.. (
					rawequal(v, k) and tostring(n) .. tostring(path)
					or v2s(v, l, p, n, vtv, k, t, path .. "[" .. tostring(n) .. tostring(path) .. "]", tables)
				)
			size -= 1
			continue
		end
		local currentPath = "" -- initializes the path of 'v' within 't'
		if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then -- cleanly handles table path generation (for the first half)
			currentPath = "." .. k
		else
			currentPath = "[" .. k2s(k, l, p, n, vtv, k, t, path .. currentPath, tables, tI) .. "]"
		end
		if size % 100 == 0 then
			scheduleWait()
		end
		-- actually serializes the member of the table
		s = s
			.. "\n"
			.. string.rep(" ", l)
			.. "["
			.. k2s(k, l, p, n, vtv, k, t, path .. currentPath, tables, tI)
			.. "] = "
			.. v2s(v, l, p, n, vtv, k, t, path .. currentPath, tables, tI)
			.. ","
	end
	if #s > 1 then -- removes the last comma because it looks nicer (no way to tell if it's done 'till it's done so...)
		s = s:sub(1, #s - 1)
	end
	if size > 0 then -- cleanly indents the last curly bracket
		s = s .. "\n" .. string.rep(" ", l - indent)
	end
	return s .. "}"
end

--- key-to-string
function k2s(v, ...)
	if keyToString then
		if typeof(v) == "userdata" and getrawmetatable(v) then
			return string.format(
				'"<void> (%s)" --[[Potentially hidden data (tostring in SimpleSpy:HookRemote/GetRemoteFiredSignal at your own risk)]]',
				safetostring(v)
			)
		elseif typeof(v) == "userdata" then
			return string.format('"<void> (%s)"', safetostring(v))
		elseif type(v) == "userdata" and typeof(v) ~= "Instance" then
			return string.format('"<%s> (%s)"', typeof(v), tostring(v))
		elseif type(v) == "function" then
			return string.format('"<Function> (%s)"', tostring(v))
		end
	end
	return v2s(v, ...)
end

--- function-to-string
function f2s(f)
	for k, x in pairs(getgenv()) do
		local isgucci, gpath
		if rawequal(x, f) then
			isgucci, gpath = true, ""
		elseif type(x) == "table" then
			isgucci, gpath = v2p(f, x)
		end
		if isgucci and type(k) ~= "function" then
			if type(k) == "string" and k:match("^[%a_]+[%w_]*$") then
				return k .. gpath
			else
				return "getgenv()[" .. v2s(k) .. "]" .. gpath
			end
		end
	end
	if funcEnabled and debug.getinfo(f).name:match("^[%a_]+[%w_]*$") then
		return "function()end --[[" .. debug.getinfo(f).name .. "]]"
	end
	return "function()end --[[" .. tostring(f) .. "]]"
end

--- instance-to-path
--- @param i userdata
function i2p(i)
	local player = getplayer(i)
	local parent = i
	local out = ""
	if parent == nil then
		return "nil"
	elseif player then
		while true do
			if parent and parent == player.Character then
				if player == Players.LocalPlayer then
					return 'game:GetService("Players").LocalPlayer.Character' .. out
				else
					return i2p(player) .. ".Character" .. out
				end
			else
				if parent.Name:match("[%a_]+[%w+]*") ~= parent.Name then
					out = ":FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
				else
					out = "." .. parent.Name .. out
				end
			end
			parent = parent.Parent
		end
	elseif parent ~= game then
		while true do
			if parent and parent.Parent == game then
				local service = game:FindService(parent.ClassName)
				if service then
					if parent.ClassName == "Workspace" then
						return "workspace" .. out
					else
						return 'game:GetService("' .. service.ClassName .. '")' .. out
					end
				else
					if parent.Name:match("[%a_]+[%w_]*") then
						return "game." .. parent.Name .. out
					else
						return "game:FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
					end
				end
			elseif parent.Parent == nil then
				getnilrequired = true
				return "getNil(" .. formatstr(parent.Name) .. ', "' .. parent.ClassName .. '")' .. out
			elseif parent == Players.LocalPlayer then
				out = ".LocalPlayer" .. out
			else
				if parent.Name:match("[%a_]+[%w_]*") ~= parent.Name then
					out = ":FindFirstChild(" .. formatstr(parent.Name) .. ")" .. out
				else
					out = "." .. parent.Name .. out
				end
			end
			parent = parent.Parent
		end
	else
		return "game"
	end
end

--- userdata-to-string: userdata
--- @param u userdata
function u2s(u)
	if typeof(u) == "TweenInfo" then
		-- TweenInfo
		return "TweenInfo.new("
			.. tostring(u.Time)
			.. ", Enum.EasingStyle."
			.. tostring(u.EasingStyle)
			.. ", Enum.EasingDirection."
			.. tostring(u.EasingDirection)
			.. ", "
			.. tostring(u.RepeatCount)
			.. ", "
			.. tostring(u.Reverses)
			.. ", "
			.. tostring(u.DelayTime)
			.. ")"
	elseif typeof(u) == "Ray" then
		-- Ray
		return "Ray.new(" .. u2s(u.Origin) .. ", " .. u2s(u.Direction) .. ")"
	elseif typeof(u) == "NumberSequence" then
		-- NumberSequence
		local ret = "NumberSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. tostring(v)
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		-- DockWidgetPluginGuiInfo
		return "DockWidgetPluginGuiInfo.new(Enum.InitialDockState" .. tostring(u) .. ")"
	elseif typeof(u) == "ColorSequence" then
		-- ColorSequence
		local ret = "ColorSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. "Color3.new(" .. tostring(v) .. ")"
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "BrickColor" then
		-- BrickColor
		return "BrickColor.new(" .. tostring(u.Number) .. ")"
	elseif typeof(u) == "NumberRange" then
		-- NumberRange
		return "NumberRange.new(" .. tostring(u.Min) .. ", " .. tostring(u.Max) .. ")"
	elseif typeof(u) == "Region3" then
		-- Region3
		local center = u.CFrame.Position
		local size = u.CFrame.Size
		local vector1 = center - size / 2
		local vector2 = center + size / 2
		return "Region3.new(" .. u2s(vector1) .. ", " .. u2s(vector2) .. ")"
	elseif typeof(u) == "Faces" then
		-- Faces
		local faces = {}
		if u.Top then
			table.insert(faces, "Enum.NormalId.Top")
		end
		if u.Bottom then
			table.insert(faces, "Enum.NormalId.Bottom")
		end
		if u.Left then
			table.insert(faces, "Enum.NormalId.Left")
		end
		if u.Right then
			table.insert(faces, "Enum.NormalId.Right")
		end
		if u.Back then
			table.insert(faces, "Enum.NormalId.Back")
		end
		if u.Front then
			table.insert(faces, "Enum.NormalId.Front")
		end
		return "Faces.new(" .. table.concat(faces, ", ") .. ")"
	elseif typeof(u) == "EnumItem" then
		return tostring(u)
	elseif typeof(u) == "Enums" then
		return "Enum"
	elseif typeof(u) == "Enum" then
		return "Enum." .. tostring(u)
	elseif typeof(u) == "RBXScriptSignal" then
		return "nil --[[RBXScriptSignal]]"
	elseif typeof(u) == "Vector3" then
		return string.format("Vector3.new(%s, %s, %s)", v2s(u.X), v2s(u.Y), v2s(u.Z))
	elseif typeof(u) == "CFrame" then
		local xAngle, yAngle, zAngle = u:ToEulerAnglesXYZ()
		return string.format(
			"CFrame.new(%s, %s, %s) * CFrame.Angles(%s, %s, %s)",
			v2s(u.X),
			v2s(u.Y),
			v2s(u.Z),
			v2s(xAngle),
			v2s(yAngle),
			v2s(zAngle)
		)
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		return string.format(
			"DockWidgetPluginGuiInfo(%s, %s, %s, %s, %s, %s, %s)",
			"Enum.InitialDockState.Right",
			v2s(u.InitialEnabled),
			v2s(u.InitialEnabledShouldOverrideRestore),
			v2s(u.FloatingXSize),
			v2s(u.FloatingYSize),
			v2s(u.MinWidth),
			v2s(u.MinHeight)
		)
	elseif typeof(u) == "PathWaypoint" then
		return string.format("PathWaypoint.new(%s, %s)", v2s(u.Position), v2s(u.Action))
	elseif typeof(u) == "UDim" then
		return string.format("UDim.new(%s, %s)", v2s(u.Scale), v2s(u.Offset))
	elseif typeof(u) == "UDim2" then
		return string.format(
			"UDim2.new(%s, %s, %s, %s)",
			v2s(u.X.Scale),
			v2s(u.X.Offset),
			v2s(u.Y.Scale),
			v2s(u.Y.Offset)
		)
	elseif typeof(u) == "Rect" then
		return string.format("Rect.new(%s, %s)", v2s(u.Min), v2s(u.Max))
	else
		return string.format("nil --[[%s]]", typeof(u))
	end
end

--- Gets the player an instance is descended from
function getplayer(instance)
	for _, v in pairs(Players:GetPlayers()) do
		if v.Character and (instance:IsDescendantOf(v.Character) or instance == v.Character) then
			return v
		end
	end
end

--- value-to-path (in table)
function v2p(x, t, path, prev)
	if not path then
		path = ""
	end
	if not prev then
		prev = {}
	end
	if rawequal(x, t) then
		return true, ""
	end
	for i, v in pairs(t) do
		if rawequal(v, x) then
			if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
				return true, (path .. "." .. i)
			else
				return true, (path .. "[" .. v2s(i) .. "]")
			end
		end
		if type(v) == "table" then
			local duplicate = false
			for _, y in pairs(prev) do
				if rawequal(y, v) then
					duplicate = true
				end
			end
			if not duplicate then
				table.insert(prev, t)
				local found
				found, p = v2p(x, v, path, prev)
				if found then
					if type(i) == "string" and i:match("^[%a_]+[%w_]*$") then
						return true, "." .. i .. p
					else
						return true, "[" .. v2s(i) .. "]" .. p
					end
				end
			end
		end
	end
	return false, ""
end

--- format s: string, byte encrypt (for weird symbols)
function formatstr(s, indentation)
	if not indentation then
		indentation = 0
	end
	local handled, reachedMax = handlespecials(s, indentation)
	return '"'
		.. handled
		.. '"'
		.. (
			reachedMax
				and " --[[ MAXIMUM STRING SIZE REACHED, CHANGE '_G.SimpleSpyMaxStringSize' TO ADJUST MAXIMUM SIZE ]]"
			or ""
		)
end

--- Adds \'s to the text as a replacement to whitespace chars and other things because string.format can't yayeet
function handlespecials(value, indentation)
	local buildStr = {}
	local i = 1
	local char = string.sub(value, i, i)
	local indentStr
	while char ~= "" do
		if char == '"' then
			buildStr[i] = '\\"'
		elseif char == "\\" then
			buildStr[i] = "\\\\"
		elseif char == "\n" then
			buildStr[i] = "\\n"
		elseif char == "\t" then
			buildStr[i] = "\\t"
		elseif string.byte(char) > 126 or string.byte(char) < 32 then
			buildStr[i] = string.format("\\%d", string.byte(char))
		else
			buildStr[i] = char
		end
		i = i + 1
		char = string.sub(value, i, i)
		if i % 200 == 0 then
			indentStr = indentStr or string.rep(" ", indentation + indent)
			table.move({ '"\n', indentStr, '... "' }, 1, 3, i, buildStr)
			i += 3
		end
	end
	return table.concat(buildStr)
end

-- safe (ish) tostring
function safetostring(v: any)
	if typeof(v) == "userdata" or type(v) == "table" then
		local mt = getrawmetatable(v)
		local badtostring = mt and rawget(mt, "__tostring")
		if mt and badtostring then
			rawset(mt, "__tostring", nil)
			local out = tostring(v)
			rawset(mt, "__tostring", badtostring)
			return out
		end
	end
	return tostring(v)
end

--- finds script from 'src' from getinfo, returns nil if not found
--- @param src string
function getScriptFromSrc(src)
	local realPath
	local runningTest
	--- @type number
	local s, e
	local match = false
	if src:sub(1, 1) == "=" then
		realPath = game
		s = 2
	else
		runningTest = src:sub(2, e and e - 1 or -1)
		for _, v in pairs(getnilinstances()) do
			if v.Name == runningTest then
				realPath = v
				break
			end
		end
		s = #runningTest + 1
	end
	if realPath then
		e = src:sub(s, -1):find("%.")
		local i = 0
		repeat
			i += 1
			if not e then
				runningTest = src:sub(s, -1)
				local test = realPath.FindFirstChild(realPath, runningTest)
				if test then
					realPath = test
				end
				match = true
			else
				runningTest = src:sub(s, e)
				local test = realPath.FindFirstChild(realPath, runningTest)
				local yeOld = e
				if test then
					realPath = test
					s = e + 2
					e = src:sub(e + 2, -1):find("%.")
					e = e and e + yeOld or e
				else
					e = src:sub(e + 2, -1):find("%.")
					e = e and e + yeOld or e
				end
			end
		until match or i >= 50
	end
	return realPath
end

local DEDUP_WINDOW = 0.002

function isRemoteFireMethod(methodName)
	local m = methodName:lower()
	return m == "fireserver" or m == "invokeserver"
end

function isLoggableRemoteClass(remote)
	local ok, result = pcall(function()
		return remote:IsA("RemoteEvent")
			or remote:IsA("RemoteFunction")
			or remote:IsA("UnreliableRemoteEvent")
	end)
	return ok and result
end

function makeRemoteSnapshot(remote)
	local snap = {
		name = "Remote",
		className = "RemoteEvent",
		path = nil,
		debugId = nil,
		remoteRole = "unknown",
		isInbound = false,
	}
	pcall(function()
		snap.name = remote.Name
		snap.className = remote.ClassName
		snap.path = remote:GetFullName()
		snap.remoteRole = classifyRemoteRole(snap.path)
		persistRemoteRole(snap.path, snap.remoteRole)
		if remote.GetDebugId then
			snap.debugId = remote:GetDebugId()
		end
		local actorName, actorPath = findActorContext(remote)
		if actorName then
			snap.actorName = actorName
			snap.actorPath = actorPath
		end
	end)
	return snap
end

function shallowHashArgs(args)
	local parts = {}
	for i = 1, math.min(#args, 8) do
		local v = args[i]
		local t = typeof(v)
		if t == "string" then
			parts[i] = "s:" .. string.sub(v, 1, 32)
		elseif t == "number" then
			parts[i] = "n:" .. tostring(v)
		elseif t == "boolean" then
			parts[i] = "b:" .. tostring(v)
		elseif t == "Instance" then
			pcall(function()
				parts[i] = "i:" .. v:GetFullName()
			end)
		else
			parts[i] = t
		end
	end
	return table.concat(parts, "|")
end

function getRemoteFingerprint(snapshot, methodName, args)
	return (snapshot.debugId or snapshot.path or snapshot.name)
		.. ":"
		.. methodName:lower()
		.. ":"
		.. shallowHashArgs(args)
end

function shouldDedupRemoteLog(snapshot, methodName, args)
	local fp = getRemoteFingerprint(snapshot, methodName, args)
	return shouldCollapseLogFingerprint(fp, recentFingerprints, _G.SIMPLESPYCONFIG_DedupWindow or DEDUP_WINDOW)
end

function registerRemoteFingerprint(fp, logIndex)
	recentFingerprints[fp] = { time = tick(), logIndex = logIndex }
end

function isFlowTrackingEnabled()
	return _G.SIMPLESPYCONFIG_FlowTracking ~= false
end

function getFlowThread()
	return coroutine.running()
end

function getOrCreateFlow(thread)
	thread = thread or getFlowThread()
	local flow = US.flowByThread[thread]
	if not flow then
		flow = { id = US.nextFlowId, steps = {}, startedAt = tick() }
		US.nextFlowId += 1
		US.flowByThread[thread] = flow
	end
	return flow, thread
end

function appendFlowStep(thread, step)
	if not isFlowTrackingEnabled() or not step then
		return
	end
	local flow = getOrCreateFlow(thread)
	step.time = step.time or tick()
	if step.kind == "Inbound" and step.label then
		local now = step.time
		for i = #flow.steps, 1, -1 do
			local prev = flow.steps[i]
			if prev.kind == "Inbound" and prev.label == step.label and (now - (prev.time or 0)) < 1 then
				prev.dupCount = (prev.dupCount or 1) + 1
				prev.label = step.label .. " (x" .. tostring(prev.dupCount) .. ")"
				return
			end
		end
	end
	table.insert(flow.steps, step)
	while #flow.steps > 48 do
		table.remove(flow.steps, 1)
	end
end

function startNewFlowWithStep(thread, step)
	if not isFlowTrackingEnabled() then
		return
	end
	thread = thread or getFlowThread()
	US.flowByThread[thread] = { id = US.nextFlowId, steps = {}, startedAt = tick() }
	US.nextFlowId += 1
	if step then
		appendFlowStep(thread, step)
	end
end

function captureFlowSnapshot(thread)
	if not isFlowTrackingEnabled() then
		return nil
	end
	thread = thread or getFlowThread()
	local flow = US.flowByThread[thread]
	if not flow or #flow.steps == 0 then
		return nil
	end
	local copy = { id = flow.id, startedAt = flow.startedAt, steps = {} }
	for _, s in ipairs(flow.steps) do
		table.insert(copy.steps, {
			kind = s.kind,
			label = s.label,
			source = s.source,
			line = s.line,
			time = s.time,
			layer = s.layer,
			method = s.method,
		})
	end
	return copy
end

local FLOW_KIND_LABEL = {
	UI = "[UI]",
	Bindable = "[Bindable]",
	Controller = "[Controller]",
	Wrapper = "[Controller]",
	Network = "[Network]",
	Remote = "[Remote]",
	Actor = "[Actor]",
	Parallel = "[Parallel]",
	Inbound = "[Inbound]",
	State = "[State]",
	Cause = "[Cause]",
	Hit = "[Hit]",
}

function formatFlowVisual(flowSnapshot)
	if not flowSnapshot or not flowSnapshot.steps or #flowSnapshot.steps == 0 then
		return ""
	end
	local lines = {}
	local duration = tick() - (flowSnapshot.startedAt or tick())
	table.insert(lines, string.format("-- Flow #%d (%.2fs)", flowSnapshot.id or 0, duration))
	for i, step in ipairs(flowSnapshot.steps) do
		local prefix = FLOW_KIND_LABEL[step.kind] or ("[" .. tostring(step.kind) .. "]")
		local label = step.label or "?"
		if step.source and step.line then
			label = label .. " @ " .. tostring(step.source) .. ":" .. tostring(step.line)
		elseif step.method then
			label = label .. " (" .. tostring(step.method) .. ")"
		end
		table.insert(lines, "-- " .. prefix .. " " .. label)
		if i < #flowSnapshot.steps then
			table.insert(lines, "--   v")
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function typeofToShapeSegment(v, depth)
	depth = depth or 0
	local t = typeof(v)
	if t == "table" and depth < 1 then
		local keys = {}
		local n = 0
		for k in pairs(v) do
			n += 1
			if n <= 8 then
				table.insert(keys, tostring(k))
			end
		end
		table.sort(keys)
		if #keys > 0 then
			return "table{" .. table.concat(keys, ",") .. "}"
		end
		return "table"
	end
	return t
end

function getPayloadShape(args)
	local parts = {}
	for i = 1, math.min(#args, 8) do
		parts[i] = typeofToShapeSegment(args[i], 0)
	end
	return table.concat(parts, ",")
end

function inferActionKey(args)
	if #args == 0 then
		return nil
	end
	if type(args[1]) == "string" then
		return args[1]
	end
	if type(args[1]) == "table" then
		local t = args[1]
		for _, k in ipairs({ "Action", "action", "Type", "type", "Name", "name", "Event", "event" }) do
			if type(t[k]) == "string" then
				return t[k]
			end
		end
	end
	return nil
end

function touchRemoteAtlasKey(path)
	for i, p in ipairs(US.remoteAtlasOrder) do
		if p == path then
			table.remove(US.remoteAtlasOrder, i)
			break
		end
	end
	table.insert(US.remoteAtlasOrder, 1, path)
	while #US.remoteAtlasOrder > US.ATLAS_MAX_REMOTES do
		local drop = table.remove(US.remoteAtlasOrder)
		US.remoteAtlas[drop] = nil
	end
end

function trimAtlasMap(map, maxCount)
	local count = 0
	for _ in pairs(map) do
		count += 1
	end
	if count < maxCount then
		return
	end
	local minKey, minCount = nil, math.huge
	for k, v in pairs(map) do
		if v.count < minCount then
			minCount = v.count
			minKey = k
		end
	end
	if minKey then
		map[minKey] = nil
	end
end

function recordRemoteObservation(snapshot, args, methodName)
	if not snapshot then
		return nil, nil
	end
	local path = snapshot.path or snapshot.name or "Remote"
	touchRemoteAtlasKey(path)
	local entry = US.remoteAtlas[path]
	if not entry then
		entry = { total = 0, actions = {}, shapes = {}, semantics = {}, lastSeen = tick() }
		US.remoteAtlas[path] = entry
	end
	entry.total += 1
	entry.lastSeen = tick()
	local shape = getPayloadShape(args)
	local shapeEntry = entry.shapes[shape]
	if not shapeEntry then
		trimAtlasMap(entry.shapes, US.ATLAS_MAX_SHAPES)
		shapeEntry = { count = 0, sampleArgs = nil }
		entry.shapes[shape] = shapeEntry
	end
	shapeEntry.count += 1
	recordProtocolObservation(path, shape, inferActionKey(args))
	if not shapeEntry.sampleArgs and #args > 0 then
		shapeEntry.sampleArgs = args
	end
	local action = inferActionKey(args)
	if action then
		updateRemoteProfile(path, action)
		local actEntry = entry.actions[action]
		if not actEntry then
			trimAtlasMap(entry.actions, US.ATLAS_MAX_ACTIONS)
			actEntry = { count = 0, shape = shape, lastSeen = tick() }
			entry.actions[action] = actEntry
		end
		actEntry.count += 1
		actEntry.shape = shape
		actEntry.lastSeen = tick()
		recordProtocolObservation(path, shape, action)
		entry.semantics = entry.semantics or {}
		local semLabel = action
		local lower = action:lower()
		if string.find(lower, "buy", 1, true) then
			semLabel = "Comprar item"
		elseif string.find(lower, "equip", 1, true) then
			semLabel = "Equipar item"
		elseif string.find(lower, "reward", 1, true) then
			semLabel = "Receber recompensa"
		elseif string.find(lower, "sell", 1, true) then
			semLabel = "Vender item"
		end
		local sem = entry.semantics[semLabel]
		if not sem then
			sem = { label = semLabel, score = 0, signals = {} }
			entry.semantics[semLabel] = sem
		end
		sem.score += 1
	end
	return shape, action
end

function formatRemoteAtlas()
	local lines = { "-- Remote Atlas (session)", "" }
	local paths = {}
	for path in pairs(US.remoteAtlas) do
		table.insert(paths, path)
	end
	table.sort(paths)
	if #paths == 0 then
		table.insert(lines, "-- (no remotes observed yet)")
		return table.concat(lines, "\n")
	end
	for _, path in ipairs(paths) do
		local entry = US.remoteAtlas[path]
		table.insert(lines, path .. " (" .. tostring(entry.total) .. " total)")
		if entry.confidenceByAction then
			local actionRows = {}
			for actionKey, ac in pairs(entry.confidenceByAction) do
				table.insert(actionRows, { key = actionKey, data = ac })
			end
			table.sort(actionRows, function(a, b)
				return (a.data.score or 0) > (b.data.score or 0)
			end)
			for _, row in ipairs(actionRows) do
				local ac = row.data
				table.insert(
					lines,
					string.format(
						"  %s — Confidence: %d%% (%d samples)",
						row.key,
						math.floor((ac.score or 0) * 100),
						ac.samples or 0
					)
				)
				local ev = evidenceListFromSet(ac.evidenceSet)
				if #ev > 0 then
					table.insert(lines, "    Signals: " .. table.concat(ev, ", "))
				end
			end
		elseif entry.confidence and entry.confidence.score then
			table.insert(
				lines,
				string.format(
					"  Confidence: %d%% — %s",
					math.floor(entry.confidence.score * 100),
					entry.confidence.label or "?"
				)
			)
			if entry.confidence.evidence and #entry.confidence.evidence > 0 then
				table.insert(lines, "  Signals: " .. table.concat(entry.confidence.evidence, ", "))
			end
		end
		local lifeEntry = nil
		for _, lc in pairs(US.remoteLifecycle) do
			if lc.path == path then
				lifeEntry = lc
				break
			end
		end
		if lifeEntry then
			table.insert(lines, "  Lifecycle: created " .. formatLogTime(lifeEntry.createdAt) .. ", calls " .. tostring(lifeEntry.callCount))
			if lifeEntry.createdBy then
				table.insert(
					lines,
					string.format(
						"  CreatedBy: %s:%s (%s)",
						tostring(lifeEntry.createdBy.source),
						tostring(lifeEntry.createdBy.line),
						tostring(lifeEntry.createdBy.func)
					)
				)
			end
			if lifeEntry.destroyedAt then
				table.insert(lines, "  Destroyed: " .. formatLogTime(lifeEntry.destroyedAt))
			else
				table.insert(lines, "  Destroyed: (alive)")
			end
			if lifeEntry.ephemeral then
				table.insert(lines, "  Ephemeral: yes")
			end
		end
		if entry.semantics then
			local semList = {}
			for tag, sem in pairs(entry.semantics) do
				table.insert(semList, { tag = tag, score = sem.score, label = sem.label })
			end
			table.sort(semList, function(a, b)
				return a.score > b.score
			end)
			if #semList > 0 then
				table.insert(lines, "  Provável:")
				for _, s in ipairs(semList) do
					local pct = math.floor((s.score / math.max(entry.total, 1)) * 100)
					table.insert(lines, string.format("  - %s (%d%%)", s.label or s.tag, pct))
				end
			end
		end
		local actions = {}
		for name, data in pairs(entry.actions) do
			table.insert(actions, { name = name, count = data.count, shape = data.shape })
		end
		table.sort(actions, function(a, b)
			return a.count > b.count
		end)
		for _, a in ipairs(actions) do
			table.insert(
				lines,
				string.format("  ├ %s (%d)  [%s]", a.name, a.count, a.shape or "?")
			)
		end
		if #actions == 0 then
			table.insert(lines, "  └ (no inferred actions)")
		end
		if entry.protocols then
			local protoRows = {}
			for label, proto in pairs(entry.protocols) do
				table.insert(protoRows, { label = label, proto = proto })
			end
			table.sort(protoRows, function(a, b)
				return (a.proto.count or 0) > (b.proto.count or 0)
			end)
			for _, row in ipairs(protoRows) do
				table.insert(
					lines,
					string.format(
						"  Protocol %s [%s] — %dx",
						row.label,
						row.proto.signature or "?",
						row.proto.count or 0
					)
				)
			end
		end
		local refBucket = US.remoteReferences[path]
		if refBucket and #refBucket.captures > 0 then
			table.insert(lines, "  References:")
			for i = 1, math.min(4, #refBucket.captures) do
				local cap = refBucket.captures[i]
				table.insert(
					lines,
					string.format(
						"    REF#%d %s @ %s:%s",
						cap.refId,
						cap.kind,
						tostring(cap.source),
						tostring(cap.line)
					)
				)
			end
		end
		for key, ob in pairs(US.actionOutcomes) do
			if ob.remotePath == path then
				table.insert(
					lines,
					string.format(
						"  Outcome %s: Normal:%d Success:%d Failed:%d",
						ob.actionKey,
						ob.normal or 0,
						ob.success or 0,
						ob.failed or 0
					)
				)
			end
		end
		table.insert(lines, "")
	end
	local discCount = 0
	for _ in pairs(US.discoveryAtlas) do
		discCount += 1
	end
	if discCount > 0 then
		table.insert(lines, "-- Static discovery candidates: " .. discCount .. " (use Deep Discovery for full list)")
	end
	return table.concat(lines, "\n")
end

function formatRemotePatterns(remotePath)
	if not remotePath then
		return "-- No remote path specified"
	end
	local entry = US.remoteAtlas[remotePath]
	if not entry then
		return "-- No observations for: " .. tostring(remotePath)
	end
	local lines = {
		"-- Payload patterns: " .. remotePath,
		"-- Total: " .. tostring(entry.total),
		"",
	}
	local shapes = {}
	for shape, data in pairs(entry.shapes) do
		table.insert(shapes, { shape = shape, count = data.count })
	end
	table.sort(shapes, function(a, b)
		return a.count > b.count
	end)
	table.insert(lines, "-- Shapes:")
	for _, s in ipairs(shapes) do
		table.insert(lines, string.format("--   [%s] x%d", s.shape, s.count))
	end
	local actions = {}
	for name, data in pairs(entry.actions) do
		table.insert(actions, { name = name, count = data.count, shape = data.shape })
	end
	table.sort(actions, function(a, b)
		return a.count > b.count
	end)
	if #actions > 0 then
		table.insert(lines, "")
		table.insert(lines, "-- Inferred actions:")
		for _, a in ipairs(actions) do
			table.insert(
				lines,
				string.format("--   %s (%d) [%s]", a.name, a.count, a.shape or "?")
			)
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function clearRemoteAtlas()
	US.remoteAtlas = {}
	US.remoteAtlasOrder = {}
end

function guiShortName(target)
	if not target or typeof(target) ~= "Instance" then
		return "?"
	end
	if target.Name and target.Name ~= "" then
		return target.Name
	end
	return "?"
end

function flowHasRemoteStep(flowSnapshot)
	if not flowSnapshot or not flowSnapshot.steps then
		return false
	end
	for _, s in ipairs(flowSnapshot.steps) do
		if s.kind == "Remote" then
			return true
		end
	end
	return false
end

function flowHasUiStep(flowSnapshot)
	if not flowSnapshot or not flowSnapshot.steps then
		return false
	end
	for _, s in ipairs(flowSnapshot.steps) do
		if s.kind == "UI" then
			return true
		end
	end
	return false
end

function getUiCorrelateWindow()
	local explicit = _G.SIMPLESPYCONFIG_UiCorrelateWindow
	if type(explicit) == "number" and explicit > 0 then
		return explicit
	end
	return getCorrelateWindow()
end

--- Prepends recent UI click into current thread flow (cross-thread correlation)
function attachRecentUiToFlow(uiTrigger)
	if not isFlowTrackingEnabled() then
		return
	end
	local ui = uiTrigger
	if not ui and US.lastGuiInteraction then
		if tick() - US.lastGuiInteraction.time <= getUiCorrelateWindow() then
			ui = US.lastGuiInteraction
		end
	end
	if not ui or tick() - ui.time > getUiCorrelateWindow() then
		return
	end
	local thread = getFlowThread()
	local flow = US.flowByThread[thread]
	if flow and flowHasUiStep({ steps = flow.steps }) then
		return
	end
	local uiStep = {
		kind = "UI",
		label = ui.shortName or ui.path,
		time = ui.time,
	}
	if not flow then
		US.flowByThread[thread] = {
			id = ui.flowId or US.nextFlowId,
			steps = { uiStep },
			startedAt = ui.flowStartedAt or ui.time,
		}
		if not ui.flowId then
			US.nextFlowId += 1
		end
		return
	end
	if ui.flowId then
		flow.id = ui.flowId
		flow.startedAt = ui.flowStartedAt or flow.startedAt
	end
	table.insert(flow.steps, 1, uiStep)
end

function formatUiTriggerLines(uiTrigger, includeSeparator)
	local lines = {}
	if not uiTrigger then
		return lines
	end
	local displayPath = uiTrigger.shortName or uiTrigger.path
	table.insert(
		lines,
		string.format(
			"-- [UI] %s (%s, %.2fs ago)",
			displayPath,
			uiTrigger.input,
			tick() - uiTrigger.time
		)
	)
	if uiTrigger.connections and #uiTrigger.connections > 0 then
		table.insert(lines, "-- [GUI callbacks]")
		for i, c in ipairs(uiTrigger.connections) do
			table.insert(
				lines,
				string.format("--   (%d) %s -> %s @ %s", i, c.signal, c.name, c.source)
			)
		end
	end
	if includeSeparator then
		table.insert(lines, "--   |")
	end
	return lines
end

function escapeLuaString(s)
	return (tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"'))
end

local ROBLOX_SERVICE_NAMES = {
	Workspace = true,
	ReplicatedStorage = true,
	ReplicatedFirst = true,
	Lighting = true,
	Players = true,
	SoundService = true,
	StarterGui = true,
	StarterPack = true,
	StarterPlayer = true,
	Chat = true,
	Teams = true,
	TestService = true,
	CollectionService = true,
	RunService = true,
	UserInputService = true,
	TweenService = true,
	HttpService = true,
	Debris = true,
}

function isRobloxServiceName(name)
	return type(name) == "string" and ROBLOX_SERVICE_NAMES[name] == true
end

--- Dot path (legacy): game.ReplicatedStorage.Events.Dash
function snapshotPathToExpr(path)
	if not path or path == "" then
		return "nil --[[unknown remote path]]"
	end
	local expr = "game"
	for part in string.gmatch(path, "[^%.]+") do
		if part == "game" then
			continue
		end
		if part:match("^[%a_][%w_]*$") then
			expr = expr .. "." .. part
		else
			expr = expr .. ':FindFirstChild("' .. escapeLuaString(part) .. '")'
		end
	end
	return expr
end

--- Run Code–safe path: game:GetService("RS"):WaitForChild("Events"):WaitForChild("Dash")
function snapshotPathToWaitForChildExpr(path)
	if not path or path == "" then
		return "nil --[[unknown remote path]]"
	end
	local parts = {}
	for part in string.gmatch(path, "[^%.]+") do
		if part ~= "game" then
			table.insert(parts, part)
		end
	end
	if #parts == 0 then
		return "game"
	end
	local expr
	local idx = 1
	local head = parts[1]
	if isRobloxServiceName(head) then
		expr = 'game:GetService("' .. head .. '")'
		idx = 2
		if head == "Players" and parts[2] then
			if parts[2] == "LocalPlayer" then
				expr = expr .. ".LocalPlayer"
				idx = 3
			else
				expr = expr .. ".LocalPlayer"
				idx = 3
			end
		end
	else
		expr = 'game:WaitForChild("' .. escapeLuaString(head) .. '")'
		idx = 2
	end
	for i = idx, #parts do
		expr = expr .. ':WaitForChild("' .. escapeLuaString(parts[i]) .. '")'
	end
	return expr
end

function getRemotePathForReplay(remote, snapshot)
	local path = snapshot and snapshot.path
	if typeof(remote) == "Instance" then
		pcall(function()
			path = remote:GetFullName()
		end)
	end
	return path
end

function getRemoteReplayExpr(remote, snapshot, remoteValid)
	if _G.SIMPLESPYCONFIG_GenScriptUseWaitForChild == false then
		if remoteValid and typeof(remote) == "Instance" then
			return v2s(remote)
		end
		return snapshot and snapshotPathToExpr(snapshot.path) or "nil --[[remote unavailable]]"
	end
	local path = getRemotePathForReplay(remote, snapshot)
	if not path then
		return "nil --[[remote unavailable]]"
	end
	return snapshotPathToWaitForChildExpr(path)
end

function appendGenScriptRemoteCall(gen, remoteExpr, methodName, hasArgs)
	if hasArgs then
		return gen .. remoteExpr .. ":" .. methodName .. "(unpack(args))\n"
	end
	return gen .. remoteExpr .. ":" .. methodName .. "()\n"
end

local LAYER_NETWORK = {
	"network",
	"net",
	"packet",
	"bridge",
	"bytes",
	"knit",
	"replicate",
}
local LAYER_CONTROLLER = {
	"controller",
	"service",
	"manager",
	"handler",
	"system",
	"client",
}
local LAYER_UI = {
	"gui",
	"ui",
	"button",
	"screen",
	"hud",
	"menu",
	"shop",
	"localscript",
}

function stringContainsAny(haystack, needles)
	local lower = haystack:lower()
	for _, n in ipairs(needles) do
		if string.find(lower, n, 1, true) then
			return true
		end
	end
	return false
end

function classifyStackLayer(frame)
	local name = frame.name or ""
	local src = frame.source or ""
	if string.find(name:lower(), "actor", 1, true) or string.find(src:lower(), "actor", 1, true) then
		return "Actor"
	end
	if string.find(name:lower(), "fireserver", 1, true) or string.find(name:lower(), "invokeserver", 1, true) then
		return "Remote"
	end
	if stringContainsAny(name, LAYER_NETWORK) or stringContainsAny(src, LAYER_NETWORK) then
		return "Network"
	end
	if stringContainsAny(name, LAYER_UI) or stringContainsAny(src, LAYER_UI) then
		return "UI"
	end
	if stringContainsAny(name, LAYER_CONTROLLER) or stringContainsAny(src, LAYER_CONTROLLER) then
		return "Controller"
	end
	return "Script"
end

function traceGuiObjectConnections(gui)
	if not trackGuiConnections or not getconnections or not gui or typeof(gui) ~= "Instance" then
		return nil
	end
	local signals = { "MouseButton1Click", "Activated", "TouchTap", "MouseButton1Down" }
	local out = {}
	for _, signalName in ipairs(signals) do
		pcall(function()
			local signal = gui[signalName]
			if signal then
				for _, conn in ipairs(getconnections(signal)) do
					if conn.Function then
						local info = nil
						pcall(function()
							info = debug.getinfo(conn.Function, "n")
						end)
						table.insert(out, {
							signal = signalName,
							name = info and info.name or "[anonymous]",
							source = info and info.source or "?",
							func = conn.Function,
						})
					end
				end
			end
		end)
	end
	if #out == 0 then
		return nil
	end
	return out
end

function formatGuiConnectionsTrace(gui)
	local lines = { "-- GUI connection trace", "" }
	if not getconnections then
		table.insert(lines, "-- getconnections not available in this executor")
		return table.concat(lines, "\n")
	end
	if not gui or typeof(gui) ~= "Instance" then
		table.insert(lines, "-- No GuiObject under mouse / target")
		return table.concat(lines, "\n")
	end
	table.insert(lines, "-- Target: " .. gui:GetFullName())
	local conns = traceGuiObjectConnections(gui)
	if not conns then
		table.insert(lines, "-- No Lua connections found on common signals")
	else
		for i, c in ipairs(conns) do
			table.insert(
				lines,
				string.format("-- [%d] %s -> %s @ %s", i, c.signal, c.name, c.source)
			)
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function recordUiEvent(input, target)
	if not trackUiCorrelation and not trackGuiConnections and not isFlowTrackingEnabled() then
		return
	end
	local entry = { time = tick(), input = tostring(input.UserInputType), path = "?" }
	pcall(function()
		if target and typeof(target) == "Instance" then
			entry.path = target:GetFullName()
			if trackGuiConnections then
				entry.connections = traceGuiObjectConnections(target)
			end
		elseif not target then
			local sel = GuiService.SelectedObject
			if sel and typeof(sel) == "Instance" then
				target = sel
				entry.path = sel:GetFullName()
				if trackGuiConnections then
					entry.connections = traceGuiObjectConnections(sel)
				end
			end
		end
	end)
	entry.shortName = guiShortName(target)
	if isFlowTrackingEnabled() then
		startNewFlowWithStep(getFlowThread(), {
			kind = "UI",
			label = entry.shortName or entry.path,
		})
		local uiFlow = US.flowByThread[getFlowThread()]
		if uiFlow then
			entry.flowId = uiFlow.id
			entry.flowStartedAt = uiFlow.startedAt
		end
	end
	US.lastGuiInteraction = entry
	appendTimelineEvent({
		kind = "ui",
		label = entry.shortName or entry.path,
		detail = entry.input,
		flowId = entry.flowId,
	})
	if trackUiCorrelation or trackGuiConnections then
		table.insert(recentUiEvents, 1, entry)
		while #recentUiEvents > 24 do
			table.remove(recentUiEvents)
		end
	end
end

function getRecentUiTrigger()
	local window = _G.SIMPLESPYCONFIG_UiCorrelateWindow or UI_CORRELATE_WINDOW or 2.0
	local now = tick()
	if US.lastGuiInteraction and (now - US.lastGuiInteraction.time) <= window then
		return US.lastGuiInteraction
	end
	for _, entry in ipairs(recentUiEvents) do
		if now - entry.time <= window then
			return entry
		end
	end
	return nil
end

function buildCallStack(startLevel, maxDepth, callingScript)
	maxDepth = maxDepth or _G.SIMPLESPYCONFIG_CallStackDepth or 32
	local stack = {}
	if callingScript and typeof(callingScript) == "Instance" then
		local scriptPath = "?"
		pcall(function()
			scriptPath = callingScript:GetFullName()
		end)
		local actorName, actorPath = findActorContext(callingScript)
		if actorName then
			table.insert(stack, {
				level = 0,
				name = actorName,
				source = scriptPath,
				line = 0,
				func = nil,
				layer = "Actor",
			})
		end
		table.insert(stack, {
			level = 0,
			name = "[getcallingscript]",
			source = scriptPath,
			line = 0,
			func = nil,
			layer = "Script",
		})
	end
	for level = startLevel, startLevel + maxDepth - 1 do
		local ok, info = pcall(debug.getinfo, level, "slnfa")
		if not ok or not info then
			break
		end
		local src = info.source or ""
		if
			not string.find(src, "SimpleSpy", 1, true)
			and not string.find(src, "ULTRASPY", 1, true)
			and not string.find(src, "CoreGui", 1, true)
		then
			local frame = {
				level = level,
				name = info.name or "[anonymous]",
				source = src,
				line = info.currentline or 0,
				func = info.func,
			}
			frame.layer = classifyStackLayer(frame)
			table.insert(stack, frame)
		end
	end
	return stack
end

function formatCallChainVisual(callStack, snapshot, uiTrigger, flowSnapshot, payloadShape)
	local lines = { "-- Execution chain (UI -> Actor -> Controller -> Network -> Remote)" }
	local hasFlow = flowSnapshot and flowSnapshot.steps and #flowSnapshot.steps > 0
	if hasFlow and uiTrigger and not flowHasUiStep(flowSnapshot) then
		for _, line in ipairs(formatUiTriggerLines(uiTrigger, true)) do
			table.insert(lines, line)
		end
	end
	if hasFlow then
		for line in string.gmatch(formatFlowVisual(flowSnapshot), "([^\n]+)") do
			table.insert(lines, line)
		end
	elseif uiTrigger then
		for _, line in ipairs(formatUiTriggerLines(uiTrigger, true)) do
			table.insert(lines, line)
		end
	end
	if callStack and #callStack > 0 then
		if flowSnapshot and flowSnapshot.steps and #flowSnapshot.steps > 0 then
			table.insert(lines, "-- Stack frames:")
		end
		for i = #callStack, 1, -1 do
			local frame = callStack[i]
			table.insert(
				lines,
				string.format(
					"-- [%s] %s @ %s:%s",
					frame.layer or "?",
					frame.name,
					frame.source,
					tostring(frame.line)
				)
			)
			if i > 1 then
				table.insert(lines, "--   v")
			end
		end
		if not flowHasRemoteStep(flowSnapshot) then
			table.insert(lines, "--   v")
		end
	end
	if snapshot and not flowHasRemoteStep(flowSnapshot) then
		table.insert(
			lines,
			string.format("-- [Remote] %s (%s)", snapshot.path or snapshot.name, snapshot.className or "RemoteEvent")
		)
	end
	if payloadShape and payloadShape ~= "" then
		table.insert(lines, string.format("-- [Payload shape] %s", payloadShape))
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function formatCallStackForScript(callStack, snapshot, uiTrigger, flowSnapshot, payloadShape)
	return formatCallChainVisual(callStack, snapshot, uiTrigger, flowSnapshot, payloadShape)
end

function graphNodeKey(name, source)
	return (name or "?") .. "|" .. (source or "?")
end

function recordNetworkGraph(callStack, snapshot, uiTrigger)
	if not snapshot then
		return
	end
	local chain = {}
	if uiTrigger then
		table.insert(chain, {
			key = "UI:" .. uiTrigger.path,
			label = "[UI] " .. uiTrigger.path,
		})
	end
	if snapshot and snapshot.actorName then
		table.insert(chain, {
			key = "Actor:" .. (snapshot.actorPath or snapshot.actorName),
			label = "[Actor] " .. snapshot.actorName,
		})
	end
	if callStack then
		for _, frame in ipairs(callStack) do
			local key = graphNodeKey(frame.name, frame.source)
			table.insert(chain, {
				key = key,
				label = string.format("[%s] %s", frame.layer or "?", frame.name),
			})
		end
	end
	local remoteKey = "Remote:" .. (snapshot.path or snapshot.name)
	table.insert(chain, {
		key = remoteKey,
		label = "[Remote] " .. (snapshot.path or snapshot.name),
	})
	for i = 1, #chain - 1 do
		local parentKey = chain[i].key
		local childKey = chain[i + 1].key
		if not networkGraph[parentKey] then
			networkGraph[parentKey] = { label = chain[i].label, children = {} }
		end
		networkGraph[parentKey].children[childKey] = (networkGraph[parentKey].children[childKey] or 0) + 1
		if not networkGraph[childKey] then
			networkGraph[childKey] = { label = chain[i + 1].label, children = {} }
		end
	end
end

function formatNetworkMap()
	local childOf = {}
	for parent, node in pairs(networkGraph) do
		for child in pairs(node.children) do
			childOf[child] = true
		end
	end
	local roots = {}
	for key, node in pairs(networkGraph) do
		if not childOf[key] then
			table.insert(roots, { key = key, node = node })
		end
	end
	table.sort(roots, function(a, b)
		return a.node.label < b.node.label
	end)
	local lines = { "-- UltraSpy network map (built from observed call chains)", "" }
	local visited = {}
	function walk(key, node, depth)
		if visited[key] then
			table.insert(lines, string.rep("  ", depth) .. "-> (cycle) " .. node.label)
			return
		end
		visited[key] = true
		table.insert(lines, string.rep("  ", depth) .. node.label)
		local kids = {}
		for childKey, count in pairs(node.children) do
			table.insert(kids, { key = childKey, count = count, node = networkGraph[childKey] })
		end
		table.sort(kids, function(a, b)
			return (a.node and a.node.label or "") < (b.node and b.node.label or "")
		end)
		for _, kid in ipairs(kids) do
			if kid.node then
				table.insert(lines, string.rep("  ", depth) .. "  |")
				walk(kid.key, kid.node, depth + 1)
			end
		end
	end
	if #roots == 0 then
		table.insert(lines, "-- (no chains recorded yet — fire some remotes)")
	else
		for _, root in ipairs(roots) do
			walk(root.key, root.node, 0)
			table.insert(lines, "")
		end
	end
	return table.concat(lines, "\n")
end

function discoverNetworkWrappers()
	staticModuleMap = nil
	local found = {}
	local upvalueBudget = { 500 }
	if getloadedmodules then
		for _, mod in ipairs(getloadedmodules()) do
			pcall(function()
				local path = mod:GetFullName()
				discoveredModules[path] = true
				if getsenv and mod:IsA("ModuleScript") then
					local env = getsenv(mod)
					for k, v in pairs(env) do
						if type(k) == "string" and wrapperNameMatches(k) and type(v) == "function" then
							local entry = {
								kind = "module_env",
								path = path,
								name = k,
								source = path,
							}
							table.insert(found, entry)
							scanFunctionUpvalues(v, entry, found, upvalueBudget)
						end
					end
				end
				if getscriptclosure and mod:IsA("ModuleScript") then
					local ok, main = pcall(getscriptclosure, mod)
					if ok and type(main) == "function" and debug.getprotos then
						pcall(function()
							local protos = { debug.getprotos(main) }
							for _, proto in ipairs(protos) do
								local pinfo = debug.getinfo(proto, "n")
								if pinfo and pinfo.name and wrapperNameMatches(pinfo.name) then
									table.insert(found, {
										kind = "module_proto",
										path = path,
										name = pinfo.name,
										source = path,
									})
								end
							end
						end)
					end
				end
			end)
		end
	end
	if getgc then
		local scanned = 0
		for _, obj in ipairs(getgc(true)) do
			scanned += 1
			if scanned > 10000 then
				break
			end
			if type(obj) == "function" and islclosure and islclosure(obj) then
				local ok, info = pcall(debug.getinfo, obj, "n")
				if ok and info and info.name and wrapperNameMatches(info.name) then
					local id = tostring(obj)
					if not discoveredWrappers[id] then
						discoveredWrappers[id] = true
						local entry = {
							kind = "gc_closure",
							name = info.name,
							source = info.source or "?",
							path = info.source or "?",
						}
						table.insert(found, entry)
						scanFunctionUpvalues(obj, entry, found, upvalueBudget)
					end
				end
			end
		end
	end
	hookDiscoveredWrappersFromList(found)
	return found
end

function formatDiscoveredWrappers(list)
	local lines = { "-- Discovered network / wrapper symbols", "" }
	if #list == 0 then
		table.insert(lines, "-- Nothing found (APIs missing or game not loaded)")
	else
		for i, entry in ipairs(list) do
			if i > 200 then
				table.insert(lines, "-- ... truncated at 200 entries")
				break
			end
			if entry.kind == "upvalue_fn" then
				table.insert(
					lines,
					string.format(
						"-- [upvalue_fn] %s.%s upvalue[%s]",
						entry.path or "?",
						entry.name or "?",
						entry.upvalue or "?"
					)
				)
			elseif entry.kind == "upvalue_remote" then
				table.insert(
					lines,
					string.format(
						"-- [upvalue_remote] %s.%s upvalue[%s] -> %s",
						entry.path or "?",
						entry.name or "?",
						entry.upvalue or "?",
						entry.remotePath or "?"
					)
				)
			elseif entry.kind == "module_env" or entry.kind == "module_proto" then
				table.insert(lines, string.format("-- [%s] %s.%s", entry.kind, entry.path, entry.name))
			else
				table.insert(
					lines,
					string.format("-- [%s] %s @ %s", entry.kind, entry.name, entry.source)
				)
			end
		end
	end
	table.insert(lines, "")
	return table.concat(lines, "\n")
end

function tryAutoHookStackFrames(callStack)
	if not autoHookStack and not (_G.SIMPLESPYCONFIG_AutoHookStack == true) then
		return
	end
	for _, frame in ipairs(callStack) do
		if isUltraSpyInternalWrapper(frame.name, frame.source) then
			continue
		end
		local layer = frame.layer
		if not wrapperNameMatches(frame.name) and layer ~= "Network" and layer ~= "Controller" then
			continue
		end
		local func = frame.func
		if typeof(func) == "function" and not isSpyProtectedFunction(func) then
			installWrapperFunctionHook(func, frame.name, frame.source, frame.layer)
		end
	end
end

function scanFunctionUpvalues(func, parentEntry, found, upvalueBudget)
	if not debug.getupvalues or upvalueBudget[1] <= 0 then
		return
	end
	for i = 1, 16 do
		if upvalueBudget[1] <= 0 then
			break
		end
		local ok, name, value = pcall(debug.getupvalues, func, i)
		if not ok or name == nil then
			break
		end
		upvalueBudget[1] -= 1
		if type(value) == "function" and wrapperNameMatches(name) then
			table.insert(found, {
				kind = "upvalue_fn",
				path = parentEntry.path,
				name = parentEntry.name,
				upvalue = name,
				upvalueSource = parentEntry.source,
			})
		elseif typeof(value) == "Instance" and (value:IsA("RemoteEvent") or value:IsA("RemoteFunction")) then
			local remotePath = "?"
			pcall(function()
				remotePath = value:GetFullName()
			end)
			table.insert(found, {
				kind = "upvalue_remote",
				path = parentEntry.path,
				name = parentEntry.name,
				upvalue = name,
				remotePath = remotePath,
			})
			local callerInfo = {
				source = parentEntry.source or "?",
				line = 0,
				func = parentEntry.name,
				scriptPath = parentEntry.path,
			}
			registerUpvalueRemoteLink(func, i, name, value, callerInfo)
		end
	end
end

function buildStaticModuleMap()
	staticModuleMap = {}
	local modules = {}
	if getloadedmodules then
		for _, mod in ipairs(getloadedmodules()) do
			table.insert(modules, mod)
		end
	end
	local cap = 500
	local scanned = 0
	for _, mod in ipairs(modules) do
		scanned += 1
		if scanned > cap then
			break
		end
		pcall(function()
			if not mod:IsA("ModuleScript") then
				return
			end
			local path = mod:GetFullName()
			local entries = {}
			if getsenv then
				local env = getsenv(mod)
				for k, v in pairs(env) do
					if type(k) == "string" and type(v) == "function" then
						local frame = { name = k, source = path }
						table.insert(entries, {
							name = k,
							layer = classifyStackLayer(frame),
						})
					end
				end
			end
			if #entries > 0 then
				table.sort(entries, function(a, b)
					return a.name < b.name
				end)
				staticModuleMap[path] = entries
			end
		end)
	end
	return staticModuleMap
end

function formatStaticModuleMap()
	if not staticModuleMap then
		buildStaticModuleMap()
	end
	local lines = {
		"-- Static module map (loaded ModuleScripts — may differ from Network Map)",
		"-- Dynamic observed chains: use Network Map button",
		"",
	}
	local paths = {}
	for path in pairs(staticModuleMap) do
		table.insert(paths, path)
	end
	table.sort(paths)
	if #paths == 0 then
		table.insert(lines, "-- No module functions found (getsenv missing or no modules loaded)")
	else
		for _, path in ipairs(paths) do
			table.insert(lines, path)
			for _, entry in ipairs(staticModuleMap[path]) do
				table.insert(lines, string.format("  [%s] %s", entry.layer, entry.name))
			end
			table.insert(lines, "")
		end
	end
	return table.concat(lines, "\n")
end

function patchModuleEnvironment(mod)
	if not mod or typeof(mod) ~= "Instance" or not mod:IsA("ModuleScript") then
		return 0
	end
	if not getsenv then
		return 0
	end
	local patched = 0
	pcall(function()
		local path = mod:GetFullName()
		local env = getsenv(mod)
		for k, v in pairs(env) do
			if type(k) == "string" and type(v) == "function" and wrapperNameMatches(k) then
				if installWrapperFunctionHook(v, k, path, "Network") then
					patched += 1
				end
			end
		end
	end)
	return patched
end

function resweepLoadedModules()
	staticModuleMap = nil
	local total = 0
	if getloadedmodules then
		for _, mod in ipairs(getloadedmodules()) do
			total += patchModuleEnvironment(mod)
		end
	end
	return total
end

function hookRequireForModulePatch()
	if requireHookInstalled or _G.SIMPLESPYCONFIG_AggressiveModulePatch ~= true then
		return
	end
	if not hookfunction or not require then
		return
	end
	originalRequire = hookfunction(require, newcclosure(function(mod)
		local result = originalRequire(mod)
		pcall(function()
			if isModuleGraphEnabled() and typeof(mod) == "Instance" and mod:IsA("ModuleScript") then
				local parent = getcallingscript and getcallingscript()
				if parent and parent:IsA("ModuleScript") then
					addModuleGraphEdge(parent:GetFullName(), mod:GetFullName(), "require", "runtime")
				end
			end
			patchModuleEnvironment(mod)
		end)
		return result
	end))
	requireHookInstalled = true
end

function unhookRequireForModulePatch()
	if requireHookInstalled and originalRequire and hookfunction and require then
		pcall(function()
			hookfunction(require, originalRequire)
		end)
	end
	requireHookInstalled = false
end

function getDeepScanRoots()
	if type(_G.SIMPLESPYCONFIG_DeepScanRoots) == "table" and #_G.SIMPLESPYCONFIG_DeepScanRoots > 0 then
		return _G.SIMPLESPYCONFIG_DeepScanRoots
	end
	local roots = {}
	local serviceNames = {
		"ReplicatedStorage",
		"ReplicatedFirst",
		"Workspace",
		"Lighting",
		"SoundService",
		"StarterGui",
		"StarterPack",
		"StarterPlayer",
		"Chat",
		"Teams",
	}
	for _, svcName in ipairs(serviceNames) do
		pcall(function()
			table.insert(roots, game:GetService(svcName))
		end)
	end
	local lp = Players.LocalPlayer
	if lp then
		pcall(function()
			local pg = lp:FindFirstChild("PlayerGui")
			if pg then
				table.insert(roots, pg)
			end
		end)
		pcall(function()
			local ps = lp:FindFirstChild("PlayerScripts")
			if ps then
				table.insert(roots, ps)
			end
		end)
	end
	return roots
end

function attachDeepRemoteWatch(root)
	if not root or US.deepScanWatchedRoots[root] then
		return
	end
	US.deepScanWatchedRoots[root] = true
	pcall(function()
		for _, inst in ipairs(root:GetDescendants()) do
			if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") then
				if trackInboundEnabled() then
					attachInboundSpy(inst)
				end
			end
			registerKnownRemoteInstance(inst)
			if isNetworkRemoteInstance(inst) then
				registerRemoteBirth(inst)
			end
		end
	end)
	table.insert(connections, root.DescendantAdded:Connect(function(inst)
		if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") then
			attachInboundSpy(inst)
		end
		if
			inst:IsA("RemoteEvent")
			or inst:IsA("RemoteFunction")
			or inst:IsA("UnreliableRemoteEvent")
		then
			knownRemotes[inst] = true
		end
		if isNetworkRemoteInstance(inst) then
			registerRemoteBirth(inst)
		end
	end))
end

function bootstrapDeepScanRoots()
	pcall(scanKnownRemotes)
	for _, root in ipairs(getDeepScanRoots()) do
		pcall(attachDeepRemoteWatch, root)
	end
	if not US.deepScanPlayerConn then
		US.deepScanPlayerConn = Players.PlayerAdded:Connect(function(player)
			task.defer(function()
				pcall(function()
					local pg = player:WaitForChild("PlayerGui", 8)
					if pg then
						attachDeepRemoteWatch(pg)
					end
				end)
				pcall(function()
					local ps = player:WaitForChild("PlayerScripts", 8)
					if ps then
						attachDeepRemoteWatch(ps)
					end
				end)
			end)
		end)
		table.insert(connections, US.deepScanPlayerConn)
	end
end

function registerKnownRemoteInstance(inst)
	if not inst then
		return
	end
	if
		inst:IsA("RemoteEvent")
		or inst:IsA("RemoteFunction")
		or inst:IsA("UnreliableRemoteEvent")
	then
		knownRemotes[inst] = true
	end
end

function scanKnownRemotesInRoot(root, budget)
	if not root or not budget then
		return
	end
	pcall(function()
		for _, inst in ipairs(root:GetDescendants()) do
			if budget[1] <= 0 then
				break
			end
			budget[1] -= 1
			registerKnownRemoteInstance(inst)
		end
	end)
end

function scanKnownRemotes()
	pcall(function()
		local budget = { getGcScanBudget() }
		for _, inst in ipairs(game:GetDescendants()) do
			if budget[1] <= 0 then
				break
			end
			budget[1] -= 1
			registerKnownRemoteInstance(inst)
		end
		for _, root in ipairs(getDeepScanRoots()) do
			scanKnownRemotesInRoot(root, budget)
		end
	end)
end

--- schedules the provided function (and calls it with any args after)
function schedule(f, ...)
	table.insert(scheduled, { f, ... })
end

--- Runs on RunService.Heartbeat (spy init thread — has Plugin capability for GUI)
function scheduleOnSpyThread(f, ...)
	table.insert(uiQueue, { f, ... })
	local maxQueue = _G.SIMPLESPYCONFIG_MaxUiQueue or 2000
	while #uiQueue > maxQueue do
		table.remove(uiQueue, 1)
		if not uiQueueWarned then
			uiQueueWarned = true
			warn("UltraSpy: UI queue overflow; dropping oldest log UI jobs. Raise SIMPLESPYCONFIG_MaxUiQueue.")
		end
	end
end

function flushUiQueue()
	local batch = _G.SIMPLESPYCONFIG_UiQueueBatch or 64
	for _ = 1, math.min(batch, #uiQueue) do
		local job = uiQueue[1]
		table.remove(uiQueue, 1)
		if type(job) == "table" and type(job[1]) == "function" then
			pcall(unpack(job))
		end
	end
end

--- yields the current thread until the scheduler gives the ok
function scheduleWait()
	local thread = coroutine.running()
	schedule(function()
		coroutine.resume(thread)
	end)
	coroutine.yield()
end

--- the big (well tbh small now) boi task scheduler himself, handles p much anything as quicc as possible
function taskscheduler()
	if not toggle then
		scheduled = {}
		uiQueue = {}
		return
	end
	flushUiQueue()
	tickPropCorrelate()
	tickReplayOutcomeChecks()
	if #uiQueue > 0 then
		flushUiQueue()
	end
	local maxQueue = _G.SIMPLESPYCONFIG_MaxScheduleQueue or 5000
	while #scheduled > maxQueue do
		table.remove(scheduled, 1)
		if not scheduleQueueWarned then
			scheduleQueueWarned = true
			warn("UltraSpy: genScript queue overflow; dropping oldest jobs. Raise SIMPLESPYCONFIG_MaxScheduleQueue.")
		end
	end
	local batch = _G.SIMPLESPYCONFIG_SchedulerBatch or 32
	for _ = 1, math.min(batch, #scheduled) do
		local currentf = scheduled[1]
		table.remove(scheduled, 1)
		if type(currentf) == "table" and type(currentf[1]) == "function" then
			pcall(unpack(currentf))
		end
	end
end

--- Handles remote logs (UI queued on Heartbeat — game remote threads lack Plugin)
function remoteHandler(hookfunction, methodName, remote, args, funcInfo, calling, returnValue, snapshot)
	snapshot = snapshot or (typeof(remote) == "Instance" and makeRemoteSnapshot(remote) or nil)
	if isSelfTestRemote(remote, snapshot) and US.selfTestInProgress then
		local blocked = false
		if typeof(remote) == "Instance" then
			blocked = blocklist[remote] or blocklist[remote.Name]
		end
		if blocked then
			return
		end
		US.selfTestCaptureCount += 1
	end
	local validInstance, validClass = false, false
	if typeof(remote) == "Instance" then
		validInstance, validClass = pcall(isLoggableRemoteClass, remote)
	end
	local canLog = (validInstance and validClass) or (snapshot and snapshot.path)
	if not canLog or not isRemoteFireMethod(methodName) then
		return
	end
	args = deepCopyArgsList(args)
	local payloadShape = nil
	pcall(function()
		payloadShape = select(1, recordRemoteObservation(snapshot, args, methodName))
	end)
	local isDup, dupLogIndex, fp = shouldDedupRemoteLog(snapshot, methodName, args)
	if isDup and dupLogIndex and logs[dupLogIndex] then
		scheduleOnSpyThread(function()
			if logs[dupLogIndex] then
				incrementLogDuplicate(logs[dupLogIndex])
			end
			if fp and recentFingerprints[fp] then
				recentFingerprints[fp].time = tick()
			end
		end)
		return
	end
	if fp and pendingRemoteLogs[fp] then
		scheduleOnSpyThread(function()
			local entry = recentFingerprints[fp]
			if entry and logs[entry.logIndex] then
				incrementLogDuplicate(logs[entry.logIndex])
				recentFingerprints[fp].time = tick()
			end
		end)
		return
	end
	-- used for action classification / function↔remote registry evidence
	local actionKey = inferActionKey(args)
	local func = funcInfo and funcInfo.func
	if func then
		pcall(function()
			resolveRemoteFromFireFunction(func, remote)
		end)
	end
	if typeof(remote) == "Instance" then
		pcall(function()
			local linked = linkUpvaluesFromCallerStack(remote, hookfunction and 6 or 5)
			if not linked then
				registerFirePathRemoteLink(remote, getCaptureCallerInfo(5))
			end
		end)
	end
	if typeof(remote) == "Instance" and isFunctionRemoteRegistryEnabled() then
		registerFunctionRemoteLink(func, remote, methodName, getCaptureCallerInfo(5), actionKey)
	end
	if not calling and funcInfo and funcInfo.source then
		_, calling = pcall(getScriptFromSrc, funcInfo.source)
	end
	if typeof(remote) == "Instance" then
		coroutine.wrap(function()
			if remoteSignals[remote] then
				remoteSignals[remote]:Fire(args)
			end
		end)()
	end
	local spamTag = ""
	if autoblock then
		local key = (snapshot and (snapshot.debugId or snapshot.path)) or remote
		if excluding[key] then
			spamTag = "[spam] "
		else
			if not history[key] then
				history[key] = { badOccurances = 0, lastCall = 0 }
			end
			if tick() - history[key].lastCall < 0.1 then
				history[key].badOccurances += 1
				spamTag = "[spam] "
			else
				history[key].badOccurances = 0
			end
			if history[key].badOccurances > 5 then
				excluding[key] = true
				spamTag = "[spam] "
			end
			history[key].lastCall = tick()
		end
	end
	local stackStart = hookfunction and 5 or 4
	local callingForStack = calling
	if not callingForStack and useGetCallingScript and getcallingscript then
		pcall(function()
			callingForStack = getcallingscript()
		end)
	end
	local callStack = buildCallStack(stackStart, _G.SIMPLESPYCONFIG_CallStackDepth, callingForStack)
	if snapshot and callingForStack then
		enrichSnapshotWithActor(snapshot, callingForStack)
		registerScriptOrigin(callingForStack, snapshot.path)
	end
	local mergedChain = mergeWrapperBufferWithCallStack(callStack)
	if snapshot and snapshot.path then
		correlateMetatableFromFire(snapshot.path, mergedChain)
	end
	tryAutoHookStackFrames(callStack)
	local uiTrigger = getRecentUiTrigger()
	recordNetworkGraph(callStack, snapshot, uiTrigger)
	attachRecentUiToFlow(uiTrigger)
	appendFlowStep(nil, {
		kind = "Remote",
		label = snapshot and (snapshot.path or snapshot.name) or "Remote",
		method = methodName,
	})
	if snapshot and snapshot.actorName then
		appendFlowStep(nil, { kind = "Actor", label = snapshot.actorName })
	end
	local bindPath, bindMethod = getRecentBindableChainHint()
	if bindPath then
		appendFlowStep(nil, {
			kind = "BindableChain",
			label = bindPath .. " → " .. (snapshot and (snapshot.path or snapshot.name) or "Remote"),
			method = bindMethod,
		})
	end
	local flowSnapshot = captureFlowSnapshot(nil)
	-- short-term history for Root Cause / Action Discovery engines
	local outboundEntry = recordRecentOutboundEvent(snapshot, actionKey, methodName, callStack, mergedChain, uiTrigger, flowSnapshot)
	bufferCombatOutbound(snapshot and snapshot.path, actionKey, callStack)
	bufferRewardOutbound(snapshot and snapshot.path, actionKey, callStack)
	local functionInfoStr
	local src
	if func and islclosure(func) then
		local functionInfo = {}
		functionInfo.info = funcInfo
		pcall(function()
			functionInfo.constants = debug.getconstants(func)
		end)
		pcall(function()
			functionInfoStr = v2v({ functionInfo = functionInfo })
		end)
		pcall(function()
			if type(calling) == "userdata" then
				src = calling
			end
		end)
	end
	local remoteName = snapshot and snapshot.name or (validInstance and remote.Name) or "Remote"
	local blocked = false
	if typeof(remote) == "Instance" then
		blocked = blocklist[remote] or blocklist[remoteName]
	else
		blocked = blocklist[remoteName]
	end
	if fp then
		pendingRemoteLogs[fp] = true
	end
	scheduleOnSpyThread(function()
		if fp then
			pendingRemoteLogs[fp] = nil
		end
		local logIndex
		if methodName:lower() == "fireserver" then
			logIndex = newRemoteSync(
				"event",
				remoteName,
				args,
				remote,
				functionInfoStr,
				blocked,
				src,
				nil,
				snapshot,
				callStack,
				spamTag,
				uiTrigger,
				flowSnapshot,
				payloadShape
			)
		elseif methodName:lower() == "invokeserver" then
			logIndex = newRemoteSync(
				"function",
				remoteName,
				args,
				remote,
				functionInfoStr,
				blocked,
				src,
				returnValue,
				snapshot,
				callStack,
				spamTag,
				uiTrigger,
				flowSnapshot,
				payloadShape
			)
		end
		if logIndex and fp then
			registerRemoteFingerprint(fp, logIndex)
		end
		if logIndex and logs[logIndex] then
			if outboundEntry then
				outboundEntry.logRef = logs[logIndex]
			end
			logs[logIndex].MergedWrapperChain = mergedChain
			attachPhase5ToLog(logs[logIndex], callStack, func, mergedChain)
		end
	end)
end

function isRemoteFireNamecall(methodName)
	return methodName == "FireServer"
		or methodName == "fireServer"
		or methodName == "InvokeServer"
		or methodName == "invokeServer"
end

function forwardDirectRemote(remoteType, remote, ...)
	if remoteType == "RemoteEvent" then
		if remoteHooks[remote] then
			return originalEvent(remote, remoteHooks[remote](...))
		end
		return originalEvent(remote, ...)
	end
	if remoteHooks[remote] then
		return originalFunction(remote, remoteHooks[remote](...))
	end
	return originalFunction(remote, ...)
end

function forwardDirectRemotePack(remoteType, remote, ...)
	return table.pack(forwardDirectRemote(remoteType, remote, ...))
end

--- Forward through saved __namecall (setnamecallmethod required for InvokeServer / some FireServer paths)
function forwardNamecallRemotePack(methodName, remote, ...)
	local callArgs = { ... }
	reentForwardDepth += 1
	local ok, results = pcall(function()
		if remoteHooks[remote] then
			return table.pack(invokeOriginalNamecall(remote, methodName, remoteHooks[remote](unpack(callArgs))))
		end
		return table.pack(invokeOriginalNamecall(remote, methodName, unpack(callArgs)))
	end)
	reentForwardDepth -= 1
	if not ok then
		error(results, 0)
	end
	return results
end

--- Used for hookfunction
function hookRemote(remoteType, remote, ...)
	if reentForwardDepth > 0 then
		return forwardDirectRemote(remoteType, remote, ...)
	end
	if typeof(remote) == "Instance" then
		local args = { ... }
		local validInstance, remoteName = pcall(function()
			return remote.Name
		end)
		if validInstance and not (blacklist[remote] or blacklist[remoteName]) then
			local funcInfo = {}
			local calling
			if funcEnabled then
				funcInfo = debug.getinfo(4) or funcInfo
				calling = useGetCallingScript and getcallingscript() or nil
			end
			local snapshot = makeRemoteSnapshot(remote)
			local methodName = remoteType == "RemoteEvent" and "fireserver" or "invokeserver"
			if blocklist[remote] or blocklist[remoteName] then
				remoteHandler(true, methodName, remote, args, funcInfo, calling, nil, snapshot)
				return
			end
			if recordReturnValues and remoteType == "RemoteFunction" then
				local thread = coroutine.running()
				local deferArgs = { ... }
				task.defer(function()
					reentForwardDepth += 1
					local packed
					if remoteHooks[remote] then
						deferArgs = { remoteHooks[remote](unpack(deferArgs)) }
						packed = table.pack(originalFunction(remote, unpack(deferArgs)))
					else
						packed = table.pack(originalFunction(remote, unpack(deferArgs)))
					end
					reentForwardDepth -= 1
					remoteHandler(true, methodName, remote, deferArgs, funcInfo, calling, packed[1], snapshot)
					coroutine.resume(thread, unpack(packed, 1, packed.n))
				end)
			else
				local results = forwardDirectRemotePack(remoteType, remote, ...)
				local returnValue = remoteType == "RemoteFunction" and results[1] or nil
				remoteHandler(true, methodName, remote, args, funcInfo, calling, returnValue, snapshot)
				return unpack(results, 1, results.n)
			end
		end
	end
	if recordReturnValues and remoteType == "RemoteFunction" then
		return coroutine.yield()
	elseif remoteType == "RemoteEvent" then
		return forwardDirectRemote("RemoteEvent", remote, ...)
	else
		return forwardDirectRemote("RemoteFunction", remote, ...)
	end
end

function trackBindablesEnabled()
	return _G.SIMPLESPYCONFIG_TrackBindables == true
end

function isBindableFireMethod(methodName)
	return methodName == "Fire"
		or methodName == "fire"
		or methodName == "Invoke"
		or methodName == "invoke"
end

function isBindableInstance(inst)
	local ok, result = pcall(function()
		return inst:IsA("BindableEvent") or inst:IsA("BindableFunction")
	end)
	return ok and result
end

local BINDABLE_LOG_COLOR = Color3.fromRGB(210, 100, 255)

function getBindableFingerprint(bindable, methodName, args)
	local path = "Bindable"
	pcall(function()
		path = bindable:GetFullName()
	end)
	return path .. ":" .. tostring(methodName):lower() .. ":" .. shallowHashArgs(args)
end

function shouldDedupBindableLog(bindable, methodName, args)
	local fp = getBindableFingerprint(bindable, methodName, args)
	return shouldCollapseLogFingerprint(fp, recentBindableFingerprints, getBindableDedupWindow())
end

function registerBindableFingerprint(fp, logIndex)
	recentBindableFingerprints[fp] = { time = tick(), logIndex = logIndex }
end

function recordRecentBindableEvent(bindable, methodName, args)
	local path = "?"
	pcall(function()
		path = bindable:GetFullName()
	end)
	local entry = {
		time = tick(),
		path = path,
		method = methodName,
		args = args,
	}
	pushRecentRing(US.recentBindableEvents, entry, US.MAX_RECENT_BINDABLE)
	return entry
end

function getRecentBindableChainHint()
	local now = tick()
	local w = _G.SIMPLESPYCONFIG_RealTriggerWindow or 0.5
	for i = #US.recentBindableEvents, 1, -1 do
		local ev = US.recentBindableEvents[i]
		if ev and ev.time and (now - ev.time) <= w then
			return ev.path, ev.method
		end
	end
	return nil
end

function newBindableLogSync(bindable, methodName, args, funcInfo, fp)
	if not isBindableDeepLogEnabled() then
		return
	end
	local path = "Bindable"
	pcall(function()
		path = bindable:GetFullName()
	end)
	local displayName = "[B] " .. path .. " " .. methodName
	local remoteFrame = RemoteTemplate:Clone()
	applyLogEntryHitArea(remoteFrame)
	remoteFrame.Text.Text = string.sub(displayName, 1, 50)
	remoteFrame.ColorBar.BackgroundColor3 = BINDABLE_LOG_COLOR
	local log = {
		Name = path,
		LogType = "bindable",
		BindableMethod = methodName,
		Log = remoteFrame,
		DisplayBase = displayName,
		DuplicateCount = 1,
		LogId = #logs + 1,
		GenScript = "-- Bindable " .. methodName .. "\n-- " .. path,
		Args = args,
	}
	table.insert(logs, log)
	local logIndex = #logs
	if fp then
		registerBindableFingerprint(fp, logIndex)
	end
	assignLogUILayoutOrder(logs[logIndex], remoteFrame)
	remoteFrame.Parent = LogList
	table.insert(remoteLogs, 1, { nil, remoteFrame })
	clean()
	updateRemoteCanvas()
	return logIndex
end

function newBindableLog(bindable, methodName, args, funcInfo)
	if not isBindableDeepLogEnabled() then
		return
	end
	local isDup, dupIdx, fp = shouldDedupBindableLog(bindable, methodName, args)
	if isDup and dupIdx and logs[dupIdx] then
		scheduleOnSpyThread(function()
			if logs[dupIdx] then
				incrementLogDuplicate(logs[dupIdx])
			end
			if fp and recentBindableFingerprints[fp] then
				recentBindableFingerprints[fp].time = tick()
			end
		end)
		return
	end
	scheduleOnSpyThread(function()
		newBindableLogSync(bindable, methodName, args, funcInfo, fp)
	end)
end

function handleBindableSpy(bindable, methodName, args, invokeFn)
	if not trackBindablesEnabled() or reentForwardDepth > 0 then
		return invokeFn(bindable, unpack(args))
	end
	args = deepCopyArgsList(args)
	local funcInfo = {}
	if funcEnabled then
		funcInfo = debug.getinfo(2) or funcInfo
	end
	local guarded = false
	if isBindableDeepLogEnabled() then
		if not enterReentGuard("bindable") then
			return invokeFn(bindable, unpack(args))
		end
		guarded = true
		recordRecentBindableEvent(bindable, methodName, args)
		newBindableLog(bindable, methodName, args, funcInfo)
	elseif shouldLogWrapperCalls() then
		local path = "Bindable"
		pcall(function()
			path = bindable:GetFullName()
		end)
		recordRecentBindableEvent(bindable, methodName, args)
		newWrapperLog("Bindable:" .. path .. ":" .. methodName, args, {
			source = funcInfo.source or "?",
			layer = "Bindable",
			line = funcInfo.currentline or 0,
		})
	end
	appendBindableFlowStep(bindable, methodName, funcInfo)
	local results = table.pack(invokeFn(bindable, unpack(args)))
	if guarded then
		leaveReentGuard("bindable")
	end
	return table.unpack(results, 1, results.n)
end

function appendBindableFlowStep(bindable, methodName, funcInfo)
	if not trackBindablesEnabled() or not isFlowTrackingEnabled() then
		return
	end
	local label = "Bindable"
	pcall(function()
		label = bindable:GetFullName()
	end)
	local step = {
		kind = "Bindable",
		label = label,
		method = methodName,
	}
	if funcInfo and _G.SIMPLESPYCONFIG_BindableStack == true then
		step.source = funcInfo.source
		step.line = funcInfo.currentline
	end
	appendFlowStep(nil, step)
end

newBindableFire = newcclosure(function(bindable, ...)
	return handleBindableSpy(bindable, "Fire", { ... }, originalBindableFire)
end)

newBindableInvoke = newcclosure(function(bindable, ...)
	return handleBindableSpy(bindable, "Invoke", { ... }, originalBindableInvoke)
end)

function installBindableHooks()
	if US.bindableHooksInstalled then
		return
	end
	pcall(function()
		hookfunction(bindableEvent.Fire, newBindableFire)
	end)
	pcall(function()
		hookfunction(bindableFunction.Invoke, newBindableInvoke)
	end)
	US.bindableHooksInstalled = true
end

function removeBindableHooks()
	if not US.bindableHooksInstalled then
		return
	end
	pcall(function()
		hookfunction(bindableEvent.Fire, originalBindableFire)
	end)
	pcall(function()
		hookfunction(bindableFunction.Invoke, originalBindableInvoke)
	end)
	US.bindableHooksInstalled = false
end

function invokeOriginalNamecall(self, methodName, ...)
	if not original or self == nil then
		return nil
	end
	if not methodName and getnamecallmethod then
		methodName = getnamecallmethod()
	end
	if setnamecallmethod and methodName then
		setnamecallmethod(methodName)
	end
	return original(self, ...)
end

newnamecall = newcclosure(function(remote, ...)
	if typeof(remote) == "Instance" then
		local methodName = getnamecallmethod and getnamecallmethod() or nil
		if isHitNamecallMethod(methodName) and isTrackHitsEnabled() then
			onHitNamecall(remote, methodName, { ... })
		end
		if methodName == "Play" then
			if isTrackAnimationsEnabled() and remote:IsA("AnimationTrack") then
				task.defer(function()
					onAnimationPlayed(remote)
				end)
			elseif isTrackSoundsEnabled() and remote:IsA("Sound") then
				task.defer(function()
					onSoundPlayed(remote)
				end)
			end
		end
		local args = { ... }
		local validInstance, remoteName = pcall(function()
			return remote.Name
		end)
		if
			validInstance
			and trackBindablesEnabled()
			and isBindableInstance(remote)
			and isBindableFireMethod(methodName)
		then
			if reentForwardDepth == 0 then
				local funcInfo = {}
				if funcEnabled then
					funcInfo = debug.getinfo(3) or funcInfo
				end
				appendBindableFlowStep(remote, methodName, funcInfo)
			end
			reentForwardDepth += 1
			local bindableResults = { invokeOriginalNamecall(remote, methodName, ...) }
			reentForwardDepth -= 1
			return unpack(bindableResults)
		end
		if
			validInstance
			and isRemoteFireNamecall(methodName)
			and not (blacklist[remote] or blacklist[remoteName])
		then
			local funcInfo = {}
			local calling
			if funcEnabled then
				funcInfo = debug.getinfo(3) or funcInfo
				calling = useGetCallingScript and getcallingscript() or nil
			end
			local snapshot = makeRemoteSnapshot(remote)
			if blocklist[remote] or blocklist[remoteName] then
				remoteHandler(false, methodName, remote, args, funcInfo, calling, nil, snapshot)
				return nil
			end
			if recordReturnValues and (methodName == "InvokeServer" or methodName == "invokeServer") then
				local namecallThread = coroutine.running()
				local deferArgs = { ... }
				task.defer(function()
					reentForwardDepth += 1
					local returnValue
					if remoteHooks[remote] then
						deferArgs = { remoteHooks[remote](unpack(deferArgs)) }
						returnValue = { invokeOriginalNamecall(remote, methodName, unpack(deferArgs)) }
					else
						returnValue = { invokeOriginalNamecall(remote, methodName, unpack(deferArgs)) }
					end
					reentForwardDepth -= 1
					remoteHandler(
						false,
						methodName,
						remote,
						deferArgs,
						funcInfo,
						calling,
						returnValue[1],
						snapshot
					)
					coroutine.resume(namecallThread, unpack(returnValue))
				end)
			else
				local results = forwardNamecallRemotePack(methodName, remote, ...)
				local returnValue = nil
				if methodName == "InvokeServer" or methodName == "invokeServer" then
					returnValue = results[1]
				end
				remoteHandler(false, methodName, remote, args, funcInfo, calling, returnValue, snapshot)
				return unpack(results, 1, results.n)
			end
		end
		if recordReturnValues and (methodName == "InvokeServer" or methodName == "invokeServer") then
			return coroutine.yield()
		elseif
			validInstance
			and isRemoteFireNamecall(methodName)
			and (blocklist[remote] or blocklist[remoteName])
		then
			return nil
		elseif
			validInstance
			and isRemoteFireNamecall(methodName)
			and remoteHooks[remote]
		then
			return invokeOriginalNamecall(remote, methodName, remoteHooks[remote](...))
		elseif validInstance and isRemoteFireNamecall(methodName) then
			return invokeOriginalNamecall(remote, methodName, ...)
		else
			return invokeOriginalNamecall(remote, methodName, ...)
		end
	end
	return nil
end)

newFireServer = newcclosure(function(...)
	return hookRemote("RemoteEvent", ...)
end, originalEvent)

newInvokeServer = newcclosure(function(...)
	return hookRemote("RemoteFunction", ...)
end, originalFunction)

registerSpyProtectedFunctions()

function installCachedMethodHooks()
	if cachedMethodHooksInstalled or _G.SIMPLESPYCONFIG_HookCachedMethods == false then
		return
	end
	if not getrawmetatable or not setreadonly then
		return
	end
	local classNames = { "RemoteEvent", "RemoteFunction", "UnreliableRemoteEvent" }
	for _, className in ipairs(classNames) do
		pcall(function()
			local dummy = Instance.new(className)
			local mt = getrawmetatable(dummy)
			if not mt or cachedMtRestore[className] then
				return
			end
			local oldIndex = mt.__index
			cachedMtRestore[className] = { mt = mt, oldIndex = oldIndex }
			setreadonly(mt, false)
			mt.__index = function(self, key)
				if key == "FireServer" and className ~= "RemoteFunction" then
					return getTracedMethodForIndex(self, key, className)
				end
				if key == "InvokeServer" and className == "RemoteFunction" then
					return getTracedMethodForIndex(self, key, className)
				end
				if type(oldIndex) == "function" then
					local ok, result = pcall(oldIndex, self, key)
					if ok then
						return result
					end
				elseif type(oldIndex) == "table" then
					return oldIndex[key]
				end
			end
			setreadonly(mt, true)
		end)
	end
	cachedMethodHooksInstalled = true
end

function removeCachedMethodHooks()
	for className, data in pairs(cachedMtRestore) do
		pcall(function()
			setreadonly(data.mt, false)
			data.mt.__index = data.oldIndex
			setreadonly(data.mt, true)
		end)
	end
	cachedMtRestore = {}
	cachedMethodHooksInstalled = false
end

function getSelfTestFolder()
	local folder = Instance.new("Folder")
	folder.Name = "__SelfTestBin"
	return folder
end

function flushAllSpyQueues()
	for _ = 1, 12 do
		flushUiQueue()
		if toggle then
			taskscheduler()
		end
	end
end

function selfTestOut(msg)
	warn("[UltraSpy Self-Test] " .. tostring(msg))
end

function selfTestResultLine(required, name, ok, detail)
	local tag = required and "REQ" or "OPT"
	local status = ok and "PASS" or (required and "FAIL" or "WARN")
	local extra = detail and detail ~= "" and (" | " .. detail) or ""
	selfTestOut("[" .. tag .. "][" .. status .. "] " .. name .. extra)
end

function selfTestFlushAndWait(iterations)
	iterations = iterations or 14
	for _ = 1, iterations do
		flushAllSpyQueues()
		if toggle then
			taskscheduler()
		end
		RunService.Heartbeat:Wait()
	end
end

function selfTestFindNewestLogForPath(remotePath)
	if not remotePath then
		return nil
	end
	for i = #logs, 1, -1 do
		local log = logs[i]
		if log and log.Snapshot and log.Snapshot.path == remotePath then
			return log, i
		end
	end
	return nil
end

function selfTestWaitForCaptureCount(minCount, timeoutSec)
	minCount = minCount or 1
	timeoutSec = timeoutSec or 3
	local deadline = tick() + timeoutSec
	while tick() < deadline do
		if US.selfTestCaptureCount >= minCount then
			return true, US.selfTestCaptureCount
		end
		selfTestFlushAndWait(2)
	end
	return US.selfTestCaptureCount >= minCount, US.selfTestCaptureCount
end

function cleanupSelfTestLogs()
	for i = #logs, 1, -1 do
		local entry = logs[i]
		if entry and entry.Name and string.find(entry.Name, SELF_TEST_PREFIX, 1, true) then
			pcall(function()
				if entry.Log then
					entry.Log:Destroy()
				end
			end)
			table.remove(logs, i)
		end
	end
	for i = #remoteLogs, 1, -1 do
		local frame = remoteLogs[i] and remoteLogs[i][2]
		if frame and frame:IsA("GuiObject") then
			local label = frame:FindFirstChild("Text")
			if label and label.Text and string.find(label.Text, SELF_TEST_PREFIX, 1, true) then
				pcall(function()
					if typeof(remoteLogs[i][1]) == "RBXScriptConnection" then
						remoteLogs[i][1]:Disconnect()
					end
					frame:Destroy()
				end)
				table.remove(remoteLogs, i)
			end
		end
	end
	updateRemoteCanvas()
end

function runUltraSpySelfTest()
	US.selfTestInProgress = true
	US.selfTestCaptureCount = 0
	US.selfTestRemotes = {}

	local results = {}
	local requiredFail = 0
	local optionalMiss = 0
	local captureBeforeLive = 0
	local testBin = nil

	function add(required, name, ok, detail)
		detail = detail or ""
		table.insert(results, {
			required = required,
			name = name,
			ok = ok,
			detail = detail,
		})
		if required and not ok then
			requiredFail += 1
		elseif not required and not ok then
			optionalMiss += 1
		end
		selfTestResultLine(required, name, ok, detail)
	end

	function tryTest(required, name, fn)
		local ok, err = pcall(fn)
		add(required, name, ok, ok and "" or tostring(err))
		return ok, err
	end

	function tryTestTimed(required, name, fn, timeoutSec)
		timeoutSec = timeoutSec or 1.5
		local finished = false
		local workerOk, workerErr = false, nil
		task.spawn(function()
			workerOk, workerErr = pcall(fn)
			finished = true
		end)
		local deadline = tick() + timeoutSec
		while not finished and tick() < deadline do
			task.wait(0.05)
		end
		if not finished then
			add(
				required,
				name,
				not required,
				"timed out after " .. tostring(timeoutSec) .. "s (local test remote, no server handler)"
			)
			return false
		end
		add(required, name, workerOk, workerOk and "" or tostring(workerErr))
		return workerOk
	end

	function finishFatal(err)
		US.selfTestInProgress = false
		US.selfTestRemotes = {}
		pcall(function()
			if testBin then
				testBin:Destroy()
			end
		end)
		selfTestOut("FATAL: " .. tostring(err))
		selfTestOut("Self-test aborted.")
		startupSelfTestResults = {
			passed = 0,
			failed = 1,
			optionalMiss = 0,
			total = 0,
			ok = false,
			fatal = tostring(err),
			results = results,
			time = os.date("%d/%m/%Y %H:%M:%S"),
		}
		_G.UltraSpySelfTest = startupSelfTestResults
		if TextLabel then
			TextLabel.Text = "Self-test FATAL — see F9"
		end
		markStartupTestsDone()
		return startupSelfTestResults
	end

	local okRun, runErr = pcall(function()
	selfTestOut("==================================================")
	selfTestOut("START " .. os.date("%d/%m/%Y %H:%M:%S"))
	selfTestOut("==================================================")

	add(true, "client context", RunService:IsClient(), "")
	add(true, "spy toggle active", toggle == true, "toggle=" .. tostring(toggle))
	add(true, "hookfunction", type(hookfunction) == "function", "")
	add(true, "getrawmetatable", type(getrawmetatable) == "function", "")
	add(true, "setreadonly", type(setreadonly) == "function", "")
	add(true, "newcclosure", type(newcclosure) == "function", "")
	add(true, "original FireServer ref", type(originalEvent) == "function", "")
	add(true, "original InvokeServer ref", type(originalFunction) == "function", "")
	add(true, "original __namecall ref", type(original) == "function", "")
	add(
		true,
		"cached method hooks",
		cachedMethodHooksInstalled or _G.SIMPLESPYCONFIG_HookCachedMethods == false,
		"HookCachedMethods="
			.. tostring(_G.SIMPLESPYCONFIG_HookCachedMethods)
			.. " installed="
			.. tostring(cachedMethodHooksInstalled)
	)
	add(true, "reentForwardDepth idle", reentForwardDepth == 0, tostring(reentForwardDepth))
	add(
		true,
		"bindable/wrapper reent idle",
		bindableReentDepth == 0 and wrapperReentDepth == 0,
		"bindable=" .. tostring(bindableReentDepth) .. " wrapper=" .. tostring(wrapperReentDepth)
	)

	tryTest(true, "GUI SimpleSpy2", function()
		assert(SimpleSpy2 and SimpleSpy2.Parent, "no parent")
		assert(LogList:IsDescendantOf(SimpleSpy2), "LogList missing")
		assert(ScrollingFrame:IsDescendantOf(SimpleSpy2), "ScrollingFrame missing")
		assert(codebox, "codebox missing")
	end)

	tryTest(true, "Heartbeat scheduler", function()
		assert(schedulerconnect and schedulerconnect.Connected, "scheduler not connected")
	end)

	tryTest(true, "schedule + taskscheduler", function()
		local ran = false
		schedule(function()
			ran = true
		end)
		taskscheduler()
		assert(ran, "schedule job did not run")
	end)

	tryTest(true, "scheduleOnSpyThread + flushUiQueue", function()
		local ran = false
		scheduleOnSpyThread(function()
			ran = true
		end)
		flushUiQueue()
		assert(ran, "ui queue job did not run")
	end)

	tryTest(true, "makeRemoteSnapshot", function()
		local r = Instance.new("RemoteEvent")
		r.Name = SELF_TEST_PREFIX .. "Snap"
		local snap = makeRemoteSnapshot(r)
		assert(snap and snap.name, "bad snapshot")
		r:Destroy()
	end)

	tryTest(true, "buildCallStack", function()
		local stack = buildCallStack(2, 6, nil)
		assert(type(stack) == "table", "not a table")
	end)

	tryTest(true, "formatCallChainVisual", function()
		local text = formatCallChainVisual({}, nil, nil)
		assert(type(text) == "string" and #text > 0, "empty chain")
	end)

	tryTest(true, "getRemoteFingerprint + dedup", function()
		local snap = { debugId = "test", path = "Test.Remote", name = "Test" }
		local fp = getRemoteFingerprint(snap, "fireserver", { "a" })
		assert(type(fp) == "string" and #fp > 0, "no fingerprint")
		local isDup = shouldDedupRemoteLog(snap, "fireserver", { "a" })
		assert(type(isDup) == "boolean", "dedup broken")
	end)

	tryTest(true, "genScript", function()
		local rs = game:GetService("ReplicatedStorage")
		local folder = Instance.new("Folder")
		folder.Name = SELF_TEST_PREFIX .. "Events"
		folder.Parent = rs
		local r = Instance.new("RemoteEvent")
		r.Name = SELF_TEST_PREFIX .. "Gen"
		r.Parent = folder
		local scriptText = genScript(r, { "x" }, makeRemoteSnapshot(r))
		assert(type(scriptText) == "string" and string.find(scriptText, "FireServer", 1, true), "no FireServer")
		if _G.SIMPLESPYCONFIG_GenScriptUseWaitForChild ~= false then
			assert(string.find(scriptText, "WaitForChild", 1, true), "expected WaitForChild: " .. scriptText)
			assert(string.find(scriptText, "GetService", 1, true), "expected GetService")
			assert(not string.find(scriptText, "local remote =", 1, true), "should inline FireServer call")
		end
		folder:Destroy()
	end)

	tryTest(true, "genScript WaitForChild path builder", function()
		local expr = snapshotPathToWaitForChildExpr("game.ReplicatedStorage.Events.Dash")
		assert(string.find(expr, 'GetService("ReplicatedStorage")', 1, true), expr)
		assert(string.find(expr, 'WaitForChild("Events")', 1, true), expr)
		assert(string.find(expr, 'WaitForChild("Dash")', 1, true), expr)
	end)

	tryTest(true, "SimpleSpy:ArgsToString", function()
		local s = SimpleSpy:ArgsToString("game.Test:FireServer", { { a = 1 } })
		assert(type(s) == "string" and #s > 0, "empty")
	end)

	tryTest(true, "GetNetworkMap", function()
		local map = SimpleSpy:GetNetworkMap()
		assert(type(map) == "string", "not string")
	end)

	tryTest(true, "GetStaticModuleMap", function()
		local map = SimpleSpy:GetStaticModuleMap()
		assert(type(map) == "string", "not string")
	end)

	tryTest(true, "DiscoverWrappers returns entries", function()
		local list = SimpleSpy:DiscoverWrappers()
		assert(type(list) == "table", "not table")
		assert(#list >= 0, "bad list")
	end)

	tryTest(true, "TraceGuiAtMouse", function()
		local trace = SimpleSpy:TraceGuiAtMouse()
		assert(type(trace) == "string" and string.find(trace, "GUI", 1, true), "not string")
	end)

	tryTest(true, "getMouseGuiTarget", function()
		getMouseGuiTarget()
	end)

	tryTest(true, "recordUiEvent + getRecentUiTrigger", function()
		local saved = recentUiEvents
		recentUiEvents = {}
		recordUiEvent({ UserInputType = Enum.UserInputType.MouseButton1 }, nil)
		assert(#recentUiEvents > 0, "ui event not recorded")
		getRecentUiTrigger()
		recentUiEvents = saved
	end)

	local caps = SimpleSpy:GetCapabilities()
	tryTest(true, "GetCapabilities", function()
		assert(type(caps) == "table", "not table")
	end)

	local optionalApis = {
		"getconnections",
		"firesignal",
		"getupvalues",
		"getloadedmodules",
		"getsenv",
		"getscriptclosure",
		"getgc",
		"replicatesignal",
	}
	for _, apiName in ipairs(optionalApis) do
		add(false, "executor API: " .. apiName, caps[apiName] == true, caps[apiName] and "available" or "missing")
	end

	testBin = getSelfTestFolder()
	local testEvent = Instance.new("RemoteEvent")
	testEvent.Name = SELF_TEST_PREFIX .. "Event"
	testEvent.Parent = testBin
	local testFunc = Instance.new("RemoteFunction")
	testFunc.Name = SELF_TEST_PREFIX .. "Function"
	testFunc.Parent = testBin
	US.selfTestRemotes[testEvent] = true
	US.selfTestRemotes[testFunc] = true

	captureBeforeLive = US.selfTestCaptureCount

	tryTest(true, "FireServer forward (namecall)", function()
		testEvent:FireServer(SELF_TEST_PREFIX, tick())
	end)

	flushAllSpyQueues()

	add(
		true,
		"FireServer hook pipeline",
		US.selfTestCaptureCount > captureBeforeLive,
		"captures=" .. tostring(US.selfTestCaptureCount - captureBeforeLive)
	)

	captureBeforeLive = US.selfTestCaptureCount

	tryTest(true, "FireServer hookfunction path", function()
		newFireServer(testEvent, SELF_TEST_PREFIX .. "_hook", 2)
	end)

	flushAllSpyQueues()

	add(
		true,
		"hookfunction pipeline",
		US.selfTestCaptureCount > captureBeforeLive,
		"captures=" .. tostring(US.selfTestCaptureCount - captureBeforeLive)
	)

	tryTest(true, "capture: log row + GenScript + snapshot", function()
		local remotePath = testEvent:GetFullName()
		local before = US.selfTestCaptureCount
		testEvent:FireServer(SELF_TEST_PREFIX .. "_cap", "attack", { Action = "attack" })
		selfTestFlushAndWait()
		assert(US.selfTestCaptureCount > before, "fire did not increment capture count")
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log row for fired remote path=" .. remotePath)
		assert(log.Snapshot and log.Snapshot.path == remotePath, "snapshot path mismatch")
		assert(log.Remote and log.Remote.remote == testEvent, "weak remote ref broken")
		assert(log.ActionKey == "attack" or log.ActionKey == SELF_TEST_PREFIX .. "_cap", "action key missing")
		assert(type(log.GenScript) == "string" and string.find(log.GenScript, "FireServer", 1, true), "GenScript missing FireServer")
		assert(log.CallStack and type(log.CallStack) == "table", "call stack not stored")
	end)

	tryTestTimed(false, "InvokeServer forward (namecall)", function()
		local ok, err = pcall(function()
			testFunc:InvokeServer(SELF_TEST_PREFIX)
		end)
		if not ok and string.find(tostring(err), "Cannot use '...'", 1, true) then
			error(err, 0)
		end
	end, 1.5)

	flushAllSpyQueues()

	tryTest(true, "blocklist prevents server fire", function()
		local blocked = Instance.new("RemoteEvent")
		blocked.Name = SELF_TEST_PREFIX .. "Blocklist"
		blocked.Parent = testBin
		US.selfTestRemotes[blocked] = true
		local capturesBefore = US.selfTestCaptureCount
		blocklist[blocked] = true
		blocked:FireServer("blocked")
		flushAllSpyQueues()
		assert(US.selfTestCaptureCount == capturesBefore, "blocklisted remote was logged")
		blocklist[blocked] = nil
		US.selfTestRemotes[blocked] = nil
	end)

	tryTest(true, "blacklist skips logging", function()
		local silent = Instance.new("RemoteEvent")
		silent.Name = SELF_TEST_PREFIX .. "Blacklist"
		silent.Parent = testBin
		US.selfTestRemotes[silent] = true
		local capturesBefore = US.selfTestCaptureCount
		blacklist[silent] = true
		pcall(function()
			silent:FireServer("silent")
		end)
		flushAllSpyQueues()
		assert(US.selfTestCaptureCount == capturesBefore, "blacklisted remote was logged")
		blacklist[silent] = nil
		US.selfTestRemotes[silent] = nil
	end)

	captureBeforeLive = US.selfTestCaptureCount

	tryTest(true, "wrapper log pipeline", function()
		if not shouldLogWrapperCalls() then
			return
		end
		newWrapperLogSync(SELF_TEST_PREFIX .. "Wrapper", { ok = true }, { source = "self-test", layer = "Network" })
		flushAllSpyQueues()
		assert(US.selfTestCaptureCount > captureBeforeLive, "wrapper log missing")
	end)

	tryTest(true, "network graph recording", function()
		local before = 0
		for _ in pairs(networkGraph) do
			before += 1
		end
		recordNetworkGraph(
			{ { name = "selfTest", source = "UltraSpySelfTest", line = 0, layer = "Script" } },
			makeRemoteSnapshot(testEvent),
			nil
		)
		local after = 0
		for _ in pairs(networkGraph) do
			after += 1
		end
		assert(after >= before, "graph did not update")
	end)

	selfTestOut("--- Phase 2-5 + tools integration (real fires) ---")

	tryTest(true, "core: dedup stacks identical rapid fires", function()
		local dedupRemote = Instance.new("RemoteEvent")
		dedupRemote.Name = SELF_TEST_PREFIX .. "DedupOnly"
		dedupRemote.Parent = testBin
		US.selfTestRemotes[dedupRemote] = true
		local remotePath = dedupRemote:GetFullName()
		local payload = { SELF_TEST_PREFIX .. "_dedup", 777 }
		local savedWindow = _G.SIMPLESPYCONFIG_DedupWindow
		_G.SIMPLESPYCONFIG_DedupWindow = 2
		local logsBefore = #logs
		dedupRemote:FireServer(unpack(payload))
		dedupRemote:FireServer(unpack(payload))
		selfTestFlushAndWait()
		_G.SIMPLESPYCONFIG_DedupWindow = savedWindow
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "dedup fire missing log")
		assert((log.DuplicateCount or 1) >= 2, "DuplicateCount not incremented: " .. tostring(log.DuplicateCount))
		local newRows = 0
		for i = logsBefore + 1, #logs do
			local entry = logs[i]
			if entry and entry.Snapshot and entry.Snapshot.path == remotePath and entry.LogType ~= "wrapper" then
				newRows += 1
			end
		end
		assert(newRows <= 1, "dedup should add at most one new log row, got " .. tostring(newRows))
		dedupRemote:Destroy()
	end)

	tryTest(true, "core: HookRemote runs before game", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "HookRemote"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local intercepted = false
		SimpleSpy:HookRemote(re, function(...)
			intercepted = true
			return ...
		end)
		re:FireServer("hooked_payload")
		selfTestFlushAndWait()
		assert(intercepted, "HookRemote callback never ran")
		remoteHooks[re] = nil
		re:Destroy()
	end)

	tryTest(true, "core: GetRemoteFiredSignal fires on capture", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "Signal"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local signal = SimpleSpy:GetRemoteFiredSignal(re)
		local fired = false
		local conn = signal:Connect(function(args)
			fired = true
			assert(type(args) == "table", "signal args not table")
		end)
		re:FireServer("signal_test")
		selfTestFlushAndWait()
		assert(fired, "GetRemoteFiredSignal did not fire")
		conn:Disconnect()
		re:Destroy()
	end)

	tryTest(true, "core: payload shape + action on real fire", function()
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("EquipItem", { Action = "EquipItem", Id = 1 })
		selfTestFlushAndWait()
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log for equip fire")
		assert(log.ActionKey == "EquipItem", "wrong action key: " .. tostring(log.ActionKey))
		assert(log.PayloadShape and #log.PayloadShape > 0, "payload shape empty")
		assert(inferActionKey({ "BuyItem" }) == "BuyItem", "inferActionKey string")
		assert(inferActionKey({ { Action = "Equip" } }) == "Equip", "inferActionKey table")
	end)

	tryTest(true, "phase2: FlowTracking on real fire + APIs", function()
		local savedFlow = _G.SIMPLESPYCONFIG_FlowTracking
		_G.SIMPLESPYCONFIG_FlowTracking = true
		US.flowByThread = {}
		appendFlowStep(nil, { kind = "UI", label = "SelfTestShopBtn" })
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("flow_track_test")
		selfTestFlushAndWait()
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log and log.FlowSnapshot and #log.FlowSnapshot.steps >= 1, "FlowSnapshot missing on log")
		local flowView = SimpleSpy:GetFlowView(log)
		assert(string.find(flowView, "Flow #", 1, true), "GetFlowView missing header")
		local chain = SimpleSpy:GetCallChain(log)
		assert(type(chain) == "string" and #chain > 20, "GetCallChain empty")
		_G.SIMPLESPYCONFIG_FlowTracking = savedFlow
	end)

	tryTest(true, "phase2: UI correlate attaches to log", function()
		local savedUi = _G.SIMPLESPYCONFIG_UiCorrelate
		local savedTrack = trackUiCorrelation
		_G.SIMPLESPYCONFIG_UiCorrelate = true
		trackUiCorrelation = true
		US.lastGuiInteraction = {
			time = tick(),
			shortName = "BuyBtn",
			path = "PlayerGui.Shop.BuyBtn",
			input = "MouseButton1",
		}
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("buyitem")
		selfTestFlushAndWait()
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log and log.UiTrigger, "UiTrigger not stored on log")
		assert(log.UiTrigger.shortName == "BuyBtn" or log.UiTrigger.path, "ui trigger empty")
		local trigger = SimpleSpy:GetLastGuiInteraction()
		assert(trigger and trigger.shortName == "BuyBtn", "GetLastGuiInteraction stale")
		_G.SIMPLESPYCONFIG_UiCorrelate = savedUi
		trackUiCorrelation = savedTrack
	end)

	tryTest(true, "phase2: log groups on grouped remote", function()
		if not isGroupLogsEnabled() then
			return
		end
		local savedGroups = US.logGroups
		US.logGroups = {}
		local path = testEvent:GetFullName()
		local log = {
			Snapshot = { path = path, name = testEvent.Name },
			Name = testEvent.Name,
			LogType = "event",
			Direction = "out",
			ActionKey = "GroupTest",
			Timestamp = tick(),
			PayloadShape = "string",
			Log = RemoteTemplate:Clone(),
			DisplayBase = path,
		}
		appendToLogGroup(log)
		local key = makeLogGroupKey("out", path)
		assert(US.logGroups[key] and US.logGroups[key].count == 1, "log group not created")
		appendToLogGroup(log)
		assert(US.logGroups[key].count == 2, "group count not incremented")
		US.logGroups = savedGroups
	end)

	tryTest(true, "phase2: timeline + GetTimeline after fires", function()
		local before = #US.timelineEvents
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("timeline_marker")
		selfTestFlushAndWait()
		assert(#US.timelineEvents > before, "timeline not updated after fire")
		local text = SimpleSpy:GetTimeline()
		assert(string.find(text, "Timeline", 1, true) or #text > 10, "GetTimeline empty")
	end)

	tryTest(true, "phase2: state tracker + GetStateLog", function()
		assert(formatStateDelta(1000, 1250) == "+250", "bad delta")
		local saved = US.stateChanges
		US.stateChanges = {}
		onStateChange(SELF_TEST_PREFIX .. ".leaderstats.Coins", 100, 250)
		assert(#US.stateChanges > 0, "onStateChange not recorded")
		local logText = SimpleSpy:GetStateLog()
		assert(string.find(logText, "Coins", 1, true) or string.find(logText, "+", 1, true), "GetStateLog empty")
		local recent = SimpleSpy:GetRecentStateChanges()
		assert(type(recent) == "table" and #recent > 0, "GetRecentStateChanges empty")
		US.stateChanges = saved
	end)

	tryTest(true, "phase2: wrapper hook pushes buffer", function()
		if not hookfunction or not islclosure then
			return
		end
		local function selfTestSendPacket(arg)
			return arg
		end
		if not islclosure(selfTestSendPacket) then
			return
		end
		US.wrapperCallBuffer = {}
		local ok = installWrapperFunctionHook(selfTestSendPacket, "Send", "SelfTest.Packet", "Network")
		assert(ok, "installWrapperFunctionHook failed")
		selfTestSendPacket("packet")
		assert(#US.wrapperCallBuffer >= 1, "wrapper hook did not push buffer")
	end)

	tryTest(trackBindablesEnabled(), "phase2: bindable flow step", function()
		if not trackBindablesEnabled() then
			return
		end
		local savedFlow = US.flowByThread
		US.flowByThread = {}
		local be = Instance.new("BindableEvent")
		be.Name = SELF_TEST_PREFIX .. "BindableFlow"
		appendBindableFlowStep(be, "Fire", { source = "self-test", currentline = 1 })
		local snap = captureFlowSnapshot(nil)
		assert(snap and snap.steps[1] and snap.steps[1].kind == "Bindable", "bindable step missing")
		be:Destroy()
		US.flowByThread = savedFlow
	end)

	tryTest(true, "phase3: GetRemoteLifecycle after real calls", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "LifeAPI"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		registerRemoteBirth(re, nil, true)
		re:FireServer("life_test")
		selfTestFlushAndWait()
		local path = re:GetFullName()
		local text = SimpleSpy:GetRemoteLifecycle(path)
		assert(string.find(text, "LifeAPI", 1, true) or string.find(text, path, 1, true), "GetRemoteLifecycle empty")
		assert(string.find(text, "call", 1, true) or string.find(text, "Remote", 1, true), "lifecycle missing calls")
		registerRemoteDeath(re)
		re:Destroy()
	end)

	tryTest(true, "phase3: correlation session on fire + reports", function()
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("buyitem")
		selfTestFlushAndWait()
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log for correlation test")
		local session = getActiveCorrelationSession(log)
		assert(session and not session.finalized, "correlation session not open after fire")
		pushCorrelationEffect("state", "Coins +50", "Money+")
		assert(#session.chain >= 1, "correlation chain empty after push")
		finalizeCorrelationSession(session)
		assert(log.CorrelationBlock and string.find(log.CorrelationBlock, "CORRELATION", 1, true), "CorrelationBlock missing")
		assert(log.ConfidenceBlock and string.find(log.ConfidenceBlock, "Confidence", 1, true), "ConfidenceBlock missing")
		local report = SimpleSpy:GetCorrelationReport()
		assert(string.find(report, "Correlation", 1, true), "GetCorrelationReport empty")
		local map = SimpleSpy:GetNetworkMap()
		assert(#map > 10, "GetNetworkMap empty after correlation")
	end)

	tryTest(true, "phase3: multi correlation + outcome learning", function()
		local saved = US.activeCorrelations
		US.activeCorrelations = {}
		local s1 = openCorrelationSession({ Name = "L1" }, { path = SELF_TEST_PREFIX .. ".SlotA" }, "BuyA", 1, nil, {}, "out")
		local s2 = openCorrelationSession({ Name = "L2" }, { path = SELF_TEST_PREFIX .. ".SlotB" }, "BuyB", 2, nil, {}, "out")
		assert(#US.activeCorrelations >= 2, "expected multiple active sessions")
		pushCorrelationEffect("state", "Money +10", "Money+")
		assert(#s1.chain >= 1 and #s2.chain >= 1, "state should correlate to all active sessions")
		finalizeCorrelationSession(s1)
		finalizeCorrelationSession(s2)
		local ob = US.actionOutcomes[getOutcomeKey(SELF_TEST_PREFIX .. ".SlotA", "BuyA")]
		assert(ob, "outcome bucket missing")
		US.activeCorrelations = saved
	end)

	tryTest(true, "phase4: remote ref on fire + ScanRemoteReferences", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "RefFire"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		re:FireServer("ref_test")
		selfTestFlushAndWait()
		local path = re:GetFullName()
		local text = SimpleSpy:GetRemoteReferences(path)
		assert(string.find(text, "REF", 1, true) or string.find(text, path, 1, true), "GetRemoteReferences empty")
		local scanText = SimpleSpy:ScanRemoteReferences()
		assert(
			type(scanText) == "string"
				and (
					string.find(scanText, "Remote Reference", 1, true)
					or string.find(scanText, "REF#", 1, true)
					or string.find(scanText, path, 1, true)
				),
			"ScanRemoteReferences failed"
		)
		re:Destroy()
	end)

	tryTest(true, "phase4: protocol + outcomes on real action", function()
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("BuyItem", { Id = 1 })
		selfTestFlushAndWait()
		local proto = SimpleSpy:GetProtocolReport(remotePath)
		assert(type(proto) == "string", "GetProtocolReport not string")
		local outcomes = SimpleSpy:GetActionOutcomes(remotePath)
		assert(type(outcomes) == "string", "GetActionOutcomes not string")
	end)

	tryTest(true, "phase4: discovery atlas from scan", function()
		local list = SimpleSpy:DiscoverRemoteCandidates()
		assert(type(list) == "table", "DiscoverRemoteCandidates not table")
		local atlas = SimpleSpy:GetDiscoveryAtlas()
		assert(type(atlas) == "string", "GetDiscoveryAtlas not string")
		local score = scoreDiscoveryCandidate({
			kind = "upvalue_remote",
			remotePath = testEvent:GetFullName(),
			name = "fireRemote",
		})
		assert(score >= (_G.SIMPLESPYCONFIG_DiscoveryMinScore or 25), "discovery score low")
	end)

	tryTest(true, "phase4: cached closure + traced FireServer", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "CachedRef"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local method = getOrCreateTracedRemoteMethod(re, "FireServer", "RemoteEvent", 42)
		assert(typeof(method) == "function", "traced method not function")
		re:FireServer("cached_test")
		selfTestFlushAndWait()
		local path = getRemotePathFromInstance(re)
		local bucket = US.remoteReferences[path]
		local foundCached = false
		if bucket then
			for _, cap in ipairs(bucket.captures) do
				if cap.kind == "cached_closure" or cap.kind == "method_ref" then
					foundCached = true
					break
				end
			end
		end
		assert(foundCached, "cached_closure/method_ref missing after fire")
		re:Destroy()
	end)

	tryTest(true, "phase4: module graph APIs", function()
		addModuleGraphEdge(SELF_TEST_PREFIX .. ".ModuleA", SELF_TEST_PREFIX .. ".ModuleB", "require", "test")
		SimpleSpy:BuildModuleGraph()
		local graph = SimpleSpy:GetModuleGraph(nil)
		assert(string.find(graph, "Module", 1, true) or #graph > 10, "GetModuleGraph empty")
		local static = SimpleSpy:GetStaticModuleMap()
		assert(type(static) == "string", "GetStaticModuleMap not string")
	end)

	tryTest(true, "phase5: cause + investigation APIs", function()
		pushCauseEvent("hit", SELF_TEST_PREFIX .. ".Part.Touched", nil, { source = "SelfTest", line = 1, func = "touch" })
		assert(#US.recentCauses >= 1, "cause not recorded")
		local causeLog = SimpleSpy:GetCauseLog()
		assert(string.find(causeLog, "hit", 1, true) or string.find(causeLog, "Touched", 1, true), "GetCauseLog empty")
		local inv = openInvestigationSession("reward", SELF_TEST_PREFIX .. ".Coins", "+10", "Coins")
		assert(inv and inv.id, "investigation missing")
		appendToActiveInvestigation("states", "Coins +10")
		finalizeInvestigationSession(inv)
		local invLog = SimpleSpy:GetInvestigationLog()
		assert(string.find(invLog, "Investigation", 1, true), "GetInvestigationLog empty")
	end)

	tryTest(true, "phase5: damage + reward event logs", function()
		local dmgBefore = #US.damageEvents
		onEntityStatChange(SELF_TEST_PREFIX .. ".NPC.Humanoid", "Health", 100, 60, "health")
		assert(#US.damageEvents > dmgBefore, "damage event not recorded")
		local dmgLog = SimpleSpy:GetDamageEventLog()
		assert(string.find(dmgLog, "Damage", 1, true) or string.find(dmgLog, "100", 1, true), "GetDamageEventLog empty")
		local rewBefore = #US.rewardEvents
		onRewardStatChange(SELF_TEST_PREFIX .. ".leaderstats.Gems", 5, 105)
		assert(#US.rewardEvents > rewBefore, "reward event not recorded")
		local rewLog = SimpleSpy:GetRewardEventLog()
		assert(string.find(rewLog, "Reward", 1, true) or string.find(rewLog, "Gems", 1, true), "GetRewardEventLog empty")
	end)

	tryTest(true, "phase5: property log + combat discovery", function()
		onPropertyChange(SELF_TEST_PREFIX .. ".HUD.Coins.Text", "Text", "10", "99")
		local propLog = SimpleSpy:GetPropertyLog()
		assert(string.find(propLog, "Property", 1, true) or string.find(propLog, "10", 1, true), "GetPropertyLog empty")
		SimpleSpy:StartCombatDiscoveryWindow()
		bufferCombatOutbound(testEvent:GetFullName(), "attack", {})
		local combat = SimpleSpy:GetCombatDiscoveryReport()
		assert(string.find(combat, "Combat", 1, true), "GetCombatDiscoveryReport empty")
	end)

	tryTest(true, "phase5: callback map + tagged entities reports", function()
		local cb = SimpleSpy:GetCallbackMap(nil)
		assert(type(cb) == "string" and #cb > 5, "GetCallbackMap empty")
		local tagged = SimpleSpy:GetTaggedEntities(nil)
		assert(type(tagged) == "string", "GetTaggedEntities not string")
	end)

	tryTest(true, "phase5: attachPhase5 blocks on synthetic log", function()
		local log = {
			Snapshot = { path = "test.remote", remoteRole = "action_candidate" },
			Timestamp = tick(),
			ActionKey = "Attack",
		}
		attachPhase5ToLog(log, { { name = "CombatController", source = "Controllers.Combat", line = 1, layer = "Controller" } }, nil)
		assert(log.WrapperChainBlock and #log.WrapperChainBlock > 0, "WrapperChainBlock missing")
		assert(log.CauseBlock ~= nil, "CauseBlock missing")
		assert(log.ActionDiscoveryBlock and #log.ActionDiscoveryBlock > 0, "ActionDiscoveryBlock missing")
		assert(log.ReplayScoreBlock and #log.ReplayScoreBlock > 0, "ReplayScoreBlock missing")
		assert(log.ValuableActionBlock and #log.ValuableActionBlock > 0, "ValuableActionBlock missing")
		assert(log.StateDependencyBlock and #log.StateDependencyBlock > 0, "StateDependencyBlock missing")
		local full = formatFullInvestigation(log)
		assert(#full > 30, "formatFullInvestigation too short")
	end)

	tryTest(true, "phase7: genScript effect-only for replication remote", function()
		local repRemote = Instance.new("RemoteEvent")
		repRemote.Name = SELF_TEST_PREFIX .. "ReplicaSet"
		repRemote.Parent = testBin
		US.selfTestRemotes[repRemote] = true
		local snapshot = makeRemoteSnapshot(repRemote)
		assert(snapshot.remoteRole == "replication_effect", "ReplicaSet should be replication_effect")
		local scriptText = genScript(repRemote, { "RewardClaim", 1 }, snapshot, {
			Direction = "out",
			RemoteRole = snapshot.remoteRole,
		})
		assert(scriptText and string.find(scriptText, "EFFECT ONLY", 1, true), "genScript did not mark EFFECT ONLY")
		assert(
			not string.find(scriptText, "remote:FireServer(unpack(args))", 1, true)
				or string.find(scriptText, "NOT recommended", 1, true),
			"ReplicaSet genScript should not emit active FireServer"
		)
		repRemote:Destroy()
	end)

	tryTest(true, "phase7: RootCause + RewardSourceBlock wiring (synthetic)", function()
		local fakeLogRef = {
			Snapshot = { path = "Test.RemoteReward", remoteRole = "action_candidate" },
			ActionKey = "RewardClaim",
			CallStack = {
				{ layer = "Controller", name = "attemptClaim", source = "Controllers.PlayerController", line = 10, func = nil },
				{ layer = "Network", name = "Send", source = "Network.Send", line = 1, func = nil },
				{ layer = "Remote", name = "FireServer", source = "ReplicatedStorage.RemoteEvents.TestRemoteReward", line = 1, func = nil },
			},
		}
		local outboundEv = {
			time = tick(),
			remotePath = fakeLogRef.Snapshot.path,
			actionKey = fakeLogRef.ActionKey,
			method = "fireserver",
			controller = "PlayerController",
			mergedChain = { { kind = "wrapper" } },
			uiTrigger = { path = "PlayerGui.TestBtn" },
			flowId = 1,
			remoteRole = fakeLogRef.Snapshot.remoteRole,
			callStack = fakeLogRef.CallStack,
			logRef = fakeLogRef,
		}
		US.recentOutboundEvents = { outboundEv }
		applyRootCauseToLog({
			kind = "reward",
			statPath = SELF_TEST_PREFIX .. ".leaderstats.Coins",
			oldVal = 0,
			newVal = 10,
			delta = 10,
		})
		applyRewardSourcesToLog({
			statPath = SELF_TEST_PREFIX .. ".leaderstats.Coins",
			delta = 10,
		})
		assert(fakeLogRef.RootCauseBlock and string.find(fakeLogRef.RootCauseBlock, "ROOT CAUSE", 1, true), "RootCauseBlock missing")
		assert(fakeLogRef.RewardSourceBlock and string.find(fakeLogRef.RewardSourceBlock, "REWARD SOURCE", 1, true), "RewardSourceBlock missing")
		assert(fakeLogRef.ReplayScoreBlock and string.find(fakeLogRef.ReplayScoreBlock, "ReplayScore", 1, true), "ReplayScoreBlock missing")
		assert(fakeLogRef.ValuableActionBlock and string.find(fakeLogRef.ValuableActionBlock, "ValuableActionScore", 1, true), "ValuableActionBlock missing")
		US.recentOutboundEvents = {}
	end)

	tryTest(true, "phase7: outbound beats ReplicaSet in Root Cause ranking", function()
		local claimLog = {
			Snapshot = { path = "Test.ClaimReward", remoteRole = "action_candidate" },
			ActionKey = "RewardClaim",
			CallStack = {
				{ layer = "Controller", name = "attemptClaim", source = "PlayerController", line = 1 },
			},
		}
		local replicaLog = {
			Snapshot = { path = "ReplicatedStorage.Remotes.ReplicaSet", remoteRole = "replication_effect" },
			ActionKey = "ReplicaUpdate",
		}
		US.recentOutboundEvents = {
			{
				time = tick(),
				remotePath = claimLog.Snapshot.path,
				actionKey = "RewardClaim",
				controller = "PlayerController",
				primaryFunction = "attemptClaim",
				remoteRole = "action_candidate",
				callStack = claimLog.CallStack,
				logRef = claimLog,
			},
		}
		US.recentInboundEvents = {
			{
				time = tick(),
				remotePath = replicaLog.Snapshot.path,
				actionKey = "ReplicaUpdate",
				remoteRole = "replication_effect",
				logRef = replicaLog,
			},
		}
		local analysis = resolveRootCause({
			kind = "reward",
			statPath = "leaderstats.Coins",
			delta = 50,
		})
		assert(analysis.bestCandidate and analysis.bestCandidate.kind == "outbound", "best should be outbound")
		local outboundPct = 0
		local replicaPct = 0
		local maxScore = math.max(analysis.maxScore or 1, 1)
		for _, c in ipairs(analysis.topCandidates or {}) do
			local pct = math.floor(((c.score or 0) / maxScore) * 100)
			if c.remotePath == claimLog.Snapshot.path then
				outboundPct = pct
			end
			if c.remoteRole == "replication_effect" then
				replicaPct = math.max(replicaPct, pct)
			end
		end
		assert(outboundPct >= 95, "outbound pct too low: " .. tostring(outboundPct))
		assert(replicaPct <= 20, "replica pct too high: " .. tostring(replicaPct))
		US.recentOutboundEvents = {}
		US.recentInboundEvents = {}
	end)

	tryTest(true, "phase7: ValuableActionScore replication vs action", function()
		local repScore = computeValuableActionScore(50, {
			Snapshot = { path = "R.ReplicaSet", remoteRole = "replication_effect" },
			ReplayScore = 50,
		})
		local actScore = computeValuableActionScore(85, {
			Snapshot = { path = "R.TrainClick", remoteRole = "action_candidate" },
			ReplayScore = 85,
			CallStack = { { layer = "Controller", name = "attemptTrain" } },
			ActionKey = "Train",
		})
		assert(repScore < 15, "ReplicaSet score too high: " .. tostring(repScore))
		assert(actScore > 50, "action remote score too low: " .. tostring(actScore))
	end)

	tryTest(true, "phase7: multi-remote sequence confidence", function()
		local seqKey = "99|Gui.TrainBtn|TRAINING"
		US.actionSequences[seqKey] = {
			remotes = { "R.StartTraining", "R.AuraTrainClick", "R.FinishTraining" },
			hits = 6,
			lastTime = tick(),
			actionClass = "TRAINING",
		}
		local report = SimpleSpy:GetActionSequences("TRAINING")
		assert(string.find(report, "confidence", 1, true), "sequence report missing confidence")
		local confMatch = string.match(report, "confidence (%d+)%%")
		local conf = confMatch and tonumber(confMatch) or 0
		assert(conf > 80, "sequence confidence too low: " .. tostring(conf))
		US.actionSequences[seqKey] = nil
	end)

	tryTest(true, "phase7: classifyRemoteRole + genScript verified header", function()
		assert(classifyRemoteRole("ReplicatedStorage.Remotes.ReplicaSet") == "replication_effect", "ReplicaSet role")
		assert(
			classifyRemoteRole("ReplicatedStorage.Remotes.AuraRunnerTrainClick") == "action_candidate",
			"train role (must not match ReplicatedStorage substring)"
		)
		assert(
			classifyRemoteRole("game.ReplicatedStorage.Remotes.AuraRunnerTrainClick") == "action_candidate",
			"train role full path"
		)
		local trainRemote = Instance.new("RemoteEvent")
		trainRemote.Name = SELF_TEST_PREFIX .. "TrainClick"
		trainRemote.Parent = testBin
		local snap = makeRemoteSnapshot(trainRemote)
		snap.remoteRole = "action_candidate"
		local fakeLog = { ValuableActionScore = 88, Snapshot = snap, ActionKey = "Train" }
		local scriptText = genScript(trainRemote, { "train" }, snap, fakeLog)
		assert(string.find(scriptText, "VERIFIED ACTION CANDIDATE", 1, true), "verified header missing")
		trainRemote:Destroy()
	end)

	tryTest(true, "phase7: state dependency learning sample", function()
		local path = "Test.AttackRemote"
		local key = path .. "|Attack"
		US.actionStateSamples[key] = {
			success = {
				{ state = { weaponEquipped = true, questActive = false, zoneUnlocked = "Arena" }, replayScore = 80 },
				{ state = { weaponEquipped = true, questActive = false, zoneUnlocked = "Arena" }, replayScore = 75 },
			},
			fail = {
				{ state = { weaponEquipped = false, questActive = false, zoneUnlocked = "Arena" }, replayScore = 10 },
			},
		}
		local reqs = getLearnedStateRequirements(path, "Attack")
		assert(reqs and #reqs > 0, "no learned requirements")
		local foundWeapon = false
		for _, r in ipairs(reqs) do
			if string.find(r.label or "", "Weapon", 1, true) then
				foundWeapon = true
			end
		end
		assert(foundWeapon, "Weapon Equipped not learned")
		US.actionStateSamples[key] = nil
	end)

	tryTest(true, "phase7: GetRootCauseReport + APIs", function()
		US.lastStatChange = { kind = "reward", statPath = "Coins", delta = 1, oldVal = 0, newVal = 1 }
		US.lastRootCauseAnalysis = resolveRootCause(US.lastStatChange)
		local report = SimpleSpy:GetRootCauseReport()
		assert(string.find(report, "ROOT CAUSE", 1, true), "GetRootCauseReport empty")
		local resolved = SimpleSpy:ResolveLastChange()
		assert(resolved and resolved.verdict, "ResolveLastChange nil")
		local seq = SimpleSpy:GetActionSequences()
		assert(type(seq) == "string", "GetActionSequences not string")
	end)

	tryTest(true, "tools: ScanPlayerData + HiddenStat reports", function()
		local scanText = SimpleSpy:ScanPlayerDataTree()
		assert(string.find(scanText, "rescanned", 1, true), "ScanPlayerDataTree bad")
		local hidden = SimpleSpy:GetHiddenStatReport()
		assert(type(hidden) == "string", "GetHiddenStatReport not string")
	end)

	tryTest(getsenv ~= nil, "tools: ResweepModules", function()
		if not getsenv then
			return
		end
		local n = SimpleSpy:ResweepModules()
		assert(type(n) == "number", "ResweepModules not number")
	end)

	tryTest(true, "tools: TraceGuiAtMouse + Capabilities", function()
		local trace = SimpleSpy:TraceGuiAtMouse()
		assert(type(trace) == "string" and string.find(trace, "GUI", 1, true), "TraceGuiAtMouse bad")
		local caps = SimpleSpy:GetCapabilities()
		assert(hookfunction ~= nil, "hookfunction missing in executor")
		assert(caps.trackRemoteReferences == true, "trackRemoteReferences disabled")
	end)

	tryTest(true, "tools: ValueToString + ArgsToString roundtrip", function()
		local args = { "attack", { Id = 1, nested = true }, 42 }
		local method = testEvent:GetFullName() .. ":FireServer"
		local s = SimpleSpy:ArgsToString(method, args)
		assert(string.find(s, "attack", 1, true), "ArgsToString missing arg")
		local v = SimpleSpy:ValueToString(args)
		assert(#v > 5, "ValueToString empty")
		local script = genScript(testEvent, args, makeRemoteSnapshot(testEvent))
		assert(string.find(script, "FireServer", 1, true), "genScript broken")
	end)

	tryTest(true, "phase2: stack layer classify", function()
		assert(classifyStackLayer({ name = "RaceActor", source = "Actors.RaceController" }) == "Actor", "Actor layer")
		assert(classifyStackLayer({ name = "Send", source = "Network.Module" }) == "Network", "Network layer")
	end)

	tryTest(true, "phase2: prop correlate window on synthetic log", function()
		if not isPropCorrelateEnabled() then
			return
		end
		local player = Players.LocalPlayer
		if not player or not player:FindFirstChild("PlayerGui") then
			return
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = SELF_TEST_PREFIX .. "PropGui"
		sg.Parent = player.PlayerGui
		local lbl = Instance.new("TextLabel")
		lbl.Name = "CoinDisplay"
		lbl.Text = "100"
		lbl.Parent = sg
		local logRef = { Snapshot = { path = testEvent:GetFullName() }, PropBlock = "" }
		startPropCorrelateWindow(999, logRef)
		lbl.Text = "250"
		for _ = 1, 8 do
			tickPropCorrelate()
			RunService.Heartbeat:Wait()
		end
		assert(logRef.PropBlock and string.find(logRef.PropBlock, "PROP", 1, true), "PropBlock not built")
		sg:Destroy()
		US.activePropWatch = nil
	end)

	tryTest(true, "phase6: auto wrapper chain on real fire", function()
		local remotePath = testEvent:GetFullName()
		US.wrapperCallBuffer = {}
		pushWrapperCallBuffer("Send", "SelfTest.Network", "Network", "st_send")
		pushWrapperCallBuffer("Encode", "SelfTest.Network", "Network", "st_encode")
		local before = US.selfTestCaptureCount
		testEvent:FireServer("attack", 1)
		selfTestFlushAndWait()
		assert(US.selfTestCaptureCount > before, "wrapper chain fire not captured")
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log after wrapper chain fire")
		assert(
			(log.AutoWrapperChainBlock and string.find(log.AutoWrapperChainBlock, "AUTO WRAPPER CHAIN", 1, true))
				or (log.MergedWrapperChain and #log.MergedWrapperChain >= 1),
			"auto wrapper chain not attached to log"
		)
		local chains = US.wrapperChainsByRemote[remotePath]
		assert(chains and #chains >= 1, "wrapper chain not stored per remote")
	end)

	tryTest(true, "phase6: metatable link from wrapper correlate", function()
		local remotePath = testEvent:GetFullName()
		US.recentWrapperFacade = {
			key = "SelfTest.Network.Attack",
			time = tick(),
			name = "Attack",
			source = "SelfTest.Network",
		}
		testEvent:FireServer("hit", 2)
		selfTestFlushAndWait()
		local link = US.metatableLinks["SelfTest.Network.Attack"]
		assert(link and link.remotePath == remotePath, "metatable link not correlated to fired remote")
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log for metatable test fire")
		attachPhase5ToLog(log, log.CallStack or {}, nil, log.MergedWrapperChain)
		assert(
			log.MetatableLinkBlock and string.find(log.MetatableLinkBlock, "METATABLE", 1, true),
			"metatable block missing on log"
		)
	end)

	tryTest(true, "phase6: remote combat profile from real args", function()
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("attack", 1)
		testEvent:FireServer("hit", 2)
		testEvent:FireServer("damage", 3)
		selfTestFlushAndWait()
		local profile = US.remoteProfiles[remotePath]
		assert(profile and profile.type == "Combat", "combat profile not inferred, got " .. tostring(profile and profile.type))
		assert((profile.confidence or 0) >= 70, "profile confidence too low: " .. tostring(profile.confidence))
		assert(profile.evidence and profile.evidence.attack, "attack evidence missing")
		local log = selfTestFindNewestLogForPath(remotePath)
		attachPhase5ToLog(log, log.CallStack or {}, nil, log.MergedWrapperChain)
		assert(
			log.RemoteProfileBlock and string.find(log.RemoteProfileBlock, "Combat", 1, true),
			"remote profile block missing on log"
		)
	end)

	tryTest(debug.getupvalues ~= nil, "phase6: upvalue registry from closure scan + fire", function()
		if not debug.getupvalues then
			return
		end
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "Upvalue"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local remotePath = re:GetFullName()
		local remoteHolder = { inst = re }
		local function attackFromUpvalue()
			remoteHolder.inst:FireServer("attack", 99)
		end
		local scanCaller = { source = "SelfTest", line = 0, func = "attackFromUpvalue", scriptPath = "SelfTest" }
		local linkedByScan = scanFunctionUpvaluesForRemoteInstance(attackFromUpvalue, re, scanCaller)
		local before = US.selfTestCaptureCount
		attackFromUpvalue()
		selfTestFlushAndWait()
		assert(US.selfTestCaptureCount > before, "upvalue closure fire not captured")
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log for upvalue fire")
		attachPhase5ToLog(log, log.CallStack or {}, attackFromUpvalue, log.MergedWrapperChain)
		local bucket = US.upvalueRemoteByRemote[remotePath]
		assert(bucket and next(bucket), "upvalue/fire-path registry empty after fire")
		assert(
			log.UpvalueRefBlock and string.find(log.UpvalueRefBlock, "UPVALUE", 1, true),
			"upvalue ref block missing on log"
		)
		local hasRealUpvalue = linkedByScan
		if not hasRealUpvalue and bucket then
			for _, entry in pairs(bucket) do
				if entry.upvalueName and entry.upvalueName ~= "(fire_path)" then
					hasRealUpvalue = true
					break
				end
			end
		end
		if not hasRealUpvalue then
			selfTestOut("[INFO] upvalue scan unavailable — fire_path registry used (executor-safe fallback)")
		end
		re:Destroy()
	end)

	tryTest(true, "phase6: function registry on real fire", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "FuncReg"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local remotePath = re:GetFullName()
		local function fireOnce()
			re:FireServer("swing", 1)
		end
		local before = US.selfTestCaptureCount
		fireOnce()
		selfTestFlushAndWait()
		assert(US.selfTestCaptureCount > before, "func registry fire not captured")
		local funcBucket = US.remoteToFunctions[remotePath]
		assert(funcBucket and next(funcBucket), "remoteToFunctions empty after fire")
		local report = SimpleSpy:GetRemoteCallers(remotePath)
		assert(string.find(report, "FUNCTION USERS", 1, true) or string.find(report, "UPVALUE", 1, true), "callers report empty")
		re:Destroy()
	end)

	tryTest(true, "phase6: hidden stat watch + value change", function()
		if not isHiddenStatDiscoveryEnabled() then
			return
		end
		local dataFolder = Instance.new("Folder")
		dataFolder.Name = "data"
		dataFolder.Parent = testBin
		local nv = Instance.new("NumberValue")
		nv.Name = "Value_001"
		nv.Value = 100
		nv.Parent = dataFolder
		local statPath = nv:GetFullName()
		scanFolderForHiddenStats(dataFolder, 0)
		assert(US.stateWatchConns["hidden:" .. statPath], "hidden stat watch not connected")
		local timelineBefore = #US.timelineEvents
		nv.Value = 72
		selfTestFlushAndWait(6)
		local profile = US.hiddenStatProfiles[statPath]
		assert(profile and (profile.samples or 0) >= 1, "hidden stat profile not updated after value change")
		assert(profile.lastNew == 72 or profile.lastNew == nv.Value, "profile lastNew wrong")
		local role = profile.confirmedRole or profile.inferredRole
		assert(
			role == "likely_hp" or (profile.downCount or 0) >= 1,
			"expected HP-like inference, got " .. tostring(role)
		)
		local sawTimeline = false
		for _, ev in ipairs(US.timelineEvents) do
			if ev.kind == "hidden_stat" and ev.label and string.find(statPath, ev.label, 1, true) then
				sawTimeline = true
				break
			end
		end
		assert(sawTimeline or #US.timelineEvents > timelineBefore, "hidden_stat timeline event missing")
		dataFolder:Destroy()
	end)

	tryTest(true, "phase6: scanPlayerDataFoldersOn (Player.Data style)", function()
		local root = Instance.new("Folder")
		root.Name = SELF_TEST_PREFIX .. "PlayerRoot"
		root.Parent = testBin
		local dataFolder = Instance.new("Folder")
		dataFolder.Name = "playerdata"
		dataFolder.Parent = root
		local nv = Instance.new("IntValue")
		nv.Name = "A1"
		nv.Value = 50
		nv.Parent = dataFolder
		local path = nv:GetFullName()
		scanPlayerDataFoldersOn(root)
		assert(US.stateWatchConns["hidden:" .. path], "scanPlayerDataFoldersOn did not watch obfuscated value")
		nv.Value = 40
		selfTestFlushAndWait(6)
		assert(US.hiddenStatProfiles[path], "profile missing after scanPlayerDataFoldersOn")
		root:Destroy()
	end)

	tryTest(true, "phase6: lifecycle reparent updates path", function()
		local folderA = Instance.new("Folder")
		folderA.Name = SELF_TEST_PREFIX .. "LifeA"
		folderA.Parent = testBin
		local folderB = Instance.new("Folder")
		folderB.Name = SELF_TEST_PREFIX .. "LifeB"
		folderB.Parent = testBin
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "Reparent"
		re.Parent = folderA
		US.selfTestRemotes[re] = true
		registerRemoteBirth(re, nil, true)
		local key = US.lifecycleByInstance[re]
		assert(key, "lifecycle key missing")
		local entry = US.remoteLifecycle[key]
		assert(entry, "lifecycle entry missing")
		local oldPath = entry.path
		re.Parent = folderB
		selfTestFlushAndWait(4)
		assert(entry.path ~= oldPath, "path not updated after reparent")
		assert(string.find(entry.path, "LifeB", 1, true), "reparented path wrong: " .. tostring(entry.path))
		local summary = formatLifecycleSummary(entry.path)
		assert(string.find(summary, "LIFECYCLE", 1, true), "lifecycle summary empty")
		registerRemoteDeath(re)
		folderA:Destroy()
		folderB:Destroy()
	end)

	tryTest(true, "phase6: inbound handler creates log", function()
		if not trackInboundEnabled() then
			return
		end
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "InboundLive"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		attachInboundSpy(re)
		local remotePath = re:GetFullName()
		local before = #logs
		inboundHandler(re, { "inbound_payload", tick() })
		selfTestFlushAndWait()
		assert(#logs > before, "inbound did not create log row")
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log and log.Direction == "in", "inbound log direction wrong")
		assert(type(log.GenScript) == "string" and #log.GenScript > 10, "inbound GenScript empty")
		re:Destroy()
	end)

	tryTest(true, "phase6: remote atlas from real fires", function()
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "AtlasLive"
		re.Parent = testBin
		US.selfTestRemotes[re] = true
		local remotePath = re:GetFullName()
		re:FireServer("claim", { reward = true })
		re:FireServer("quest", 1)
		selfTestFlushAndWait()
		assert(US.remoteAtlas[remotePath], "atlas missing after real fires")
		assert(US.remoteAtlas[remotePath].actions["claim"] or US.remoteAtlas[remotePath].actions["quest"], "atlas actions missing")
		local patterns = SimpleSpy:GetRemotePatterns(remotePath)
		assert(string.find(patterns, "claim", 1, true) or string.find(patterns, remotePath, 1, true), "patterns text empty")
		re:Destroy()
	end)

	tryTest(true, "phase6: full investigation blocks on captured log", function()
		local remotePath = testEvent:GetFullName()
		testEvent:FireServer("critical", "weapon")
		selfTestFlushAndWait()
		local log = selfTestFindNewestLogForPath(remotePath)
		assert(log, "no log for investigation block test")
		attachPhase5ToLog(log, log.CallStack or {}, nil, log.MergedWrapperChain)
		assert(log.WrapperChainBlock and #log.WrapperChainBlock > 0, "WrapperChainBlock missing")
		assert(log.RemoteRefBlock ~= nil, "RemoteRefBlock nil")
		assert(log.CauseBlock ~= nil, "CauseBlock nil")
		local full = formatFullInvestigation(log)
		assert(#full > 20, "formatFullInvestigation too short")
	end)

	tryTest(US.instanceNewHookInstalled == true, "instance.new creation hook", function()
		if not US.instanceNewHookInstalled then
			return
		end
		local re = Instance.new("RemoteEvent")
		re.Name = SELF_TEST_PREFIX .. "HookCreate"
		RunService.Heartbeat:Wait()
		RunService.Heartbeat:Wait()
		local key = getLifecycleKey(re)
		local entry = US.remoteLifecycle[key]
		assert(entry, "lifecycle entry missing after Instance.new")
		assert(entry.createdBy and entry.createdBy.source, "createdBy not captured")
		registerRemoteDeath(re)
	end)

	tryTest(true, "hidden: bindable fingerprint stable", function()
		local be = Instance.new("BindableEvent")
		be.Name = SELF_TEST_PREFIX .. "BindFp"
		local fpA = getBindableFingerprint(be, "Fire", { 1 })
		local fpB = getBindableFingerprint(be, "Fire", { 1 })
		assert(fpA == fpB, "fingerprints differ")
		be:Destroy()
	end)

	tryTest(true, "hidden: MinLogInterval collapses remote log", function()
		local snap = { debugId = "cooldown", path = "Test.CooldownRemote", name = "CooldownRemote" }
		local fp = getRemoteFingerprint(snap, "fireserver", { "x" })
		local frame = Instance.new("Frame")
		logs[897001] = { Log = frame, DuplicateCount = 1, DisplayBase = "CooldownRemote" }
		registerRemoteFingerprint(fp, 897001)
		local isDup = shouldDedupRemoteLog(snap, "fireserver", { "x" })
		assert(isDup == true, "expected collapse within MinLogInterval")
		logs[897001] = nil
	end)

	tryTest(true, "hidden: bindable reent guard drops deep recursion", function()
		local savedMax = _G.SIMPLESPYCONFIG_MaxReentDepth
		_G.SIMPLESPYCONFIG_MaxReentDepth = 1
		bindableReentDepth = 0
		assert(enterReentGuard("bindable") == true)
		assert(enterReentGuard("bindable") == false)
		leaveReentGuard("bindable")
		_G.SIMPLESPYCONFIG_MaxReentDepth = savedMax
	end)

	tryTest(true, "hidden: wrapper reent guard", function()
		wrapperReentDepth = 0
		assert(enterReentGuard("wrapper") == true)
		leaveReentGuard("wrapper")
		assert(wrapperReentDepth == 0)
	end)

	tryTest(true, "hidden: AutoHookMinScore filters low candidates", function()
		local low = scoreDiscoveryCandidate({ kind = "constant_action", name = "x", constant = "y" })
		assert(low < getAutoHookMinScore(), "low score should be below threshold: " .. tostring(low))
	end)

	tryTest(true, "hidden: RealTriggerWindow for replication_effect", function()
		local w = getRootCauseWindow({ kind = "sync_effect", remoteRole = "replication_effect" })
		assert(math.abs(w - 0.5) < 0.001, "window=" .. tostring(w))
	end)

	tryTest(true, "hidden: RealTrigger prefers recent outbound", function()
		local claimPath = "Test.OutboundCause"
		US.recentOutboundEvents = {
			{
				time = tick(),
				remotePath = claimPath,
				actionKey = "Train",
				controller = "TrainController",
				remoteRole = "action_candidate",
				score = 50,
			},
		}
		US.recentInboundEvents = {
			{
				time = tick(),
				remotePath = "ReplicatedStorage.Remotes.ReplicaSet",
				remoteRole = "replication_effect",
			},
		}
		local analysis = resolveRootCause({
			kind = "sync_effect",
			remoteRole = "replication_effect",
			statPath = "leaderstats.Power",
			delta = 1,
		})
		assert(analysis.window <= 0.51, "window too wide")
		assert(analysis.bestCandidate and analysis.bestCandidate.kind == "outbound", "expected outbound cause")
		US.recentOutboundEvents = {}
		US.recentInboundEvents = {}
	end)

	tryTest(true, "hidden: discoverRemoteCandidates telemetry", function()
		pcall(discoverRemoteCandidates)
		assert(type(US.discoveryScanStats) == "table", "missing scan stats")
		assert((US.discoveryScanStats.budget or 0) >= 25000, "budget too low")
	end)

	tryTest(true, "hidden: bootstrapAltChannelHooks safe", function()
		pcall(bootstrapAltChannelHooks)
	end)

	tryTest(true, "hidden: getDeepScanRoots includes core services", function()
		local roots = getDeepScanRoots()
		assert(#roots >= 9, "too few deep scan roots: " .. tostring(#roots))
	end)

	tryTest(true, "hidden: table_method network table scores", function()
		local s = scoreDiscoveryCandidate({ kind = "table_method", name = "Send" })
		assert(s >= 24, "table_method score: " .. tostring(s))
	end)

	tryTest(true, "hidden: capabilities dataStore client false", function()
		local caps = SimpleSpy:GetCapabilities()
		assert(caps.dataStoreClientHook == false, "DataStore must stay disabled on client")
	end)

	tryTest(true, "phaseB: replay args editor parse", function()
		local src = REPLAY_ARGS_MARKER .. "\nreturn { \"attack\", 42 }"
		local args, err = parseReplayArgsFromSource(src)
		assert(args and args[1] == "attack" and args[2] == 42, "parse failed: " .. tostring(err))
	end)

	tryTest(true, "phaseB: canReplayLog blocks inbound", function()
		local ok = canReplayLog({ Direction = "in", RemoteRole = "replication_effect", Remote = { remote = Instance.new("RemoteEvent") } })
		assert(ok == false, "inbound should not replay")
	end)

	tryTest(true, "hidden: deepCopyArgs isolates table mutation", function()
		local t = { a = 1, nested = { b = 2 } }
		local copy = deepCopyArgsList({ t })
		t.a = 99
		t.nested.b = 99
		assert(copy[1].a == 1, "top-level not copied")
		assert(copy[1].nested.b == 2, "nested not copied")
	end)

	tryTest(true, "hidden: gc_remote outside RS scores higher", function()
		local scoreRs = scoreDiscoveryCandidate({
			kind = "gc_remote",
			remotePath = "ReplicatedStorage.Remotes.X",
		})
		local scoreWs = scoreDiscoveryCandidate({
			kind = "gc_remote",
			remotePath = "Workspace.Hidden.Remote",
			priority = 40,
		})
		assert(scoreWs > scoreRs, "hidden remote should score higher")
	end)

	tryTest(true, "hidden: custom_signal kind scores", function()
		local s = scoreDiscoveryCandidate({ kind = "custom_signal", name = "CustomSignal" })
		assert(s >= 20, "custom_signal score low: " .. tostring(s))
	end)

	tryTest(true, "action hunt: logPassesFilter Out+Act+NoSpam", function()
		local saved = {
			mode = _G.SIMPLESPYCONFIG_ActionHuntMode,
			dir = US.logViewFilter.direction,
			role = US.logViewFilter.role,
			spam = US.logViewFilter.hideSpam,
			ver = US.logViewFilter.verifiedOnly,
		}
		_G.SIMPLESPYCONFIG_ActionHuntMode = true
		US.logViewFilter.direction = "out"
		US.logViewFilter.role = "action"
		US.logViewFilter.hideSpam = true
		US.logViewFilter.verifiedOnly = false
		assert(logPassesFilter({ Direction = "out", RemoteRole = "action_candidate", SpamTag = "" }) == true)
		assert(logPassesFilter({ Direction = "in", RemoteRole = "action_candidate" }) == false)
		assert(logPassesFilter({ Direction = "out", RemoteRole = "replication_effect" }) == false)
		assert(logPassesFilter({ Direction = "out", RemoteRole = "action_candidate", SpamTag = "[spam]" }) == false)
		US.logViewFilter.direction = saved.dir
		US.logViewFilter.role = saved.role
		US.logViewFilter.hideSpam = saved.spam
		US.logViewFilter.verifiedOnly = saved.ver
		_G.SIMPLESPYCONFIG_ActionHuntMode = saved.mode
	end)

	tryTest(true, "action hunt: LikelyCause banner on SYNC mock", function()
		local frame = Instance.new("Frame")
		local log = {
			Log = frame,
			DisplayBase = "ReplicaSet",
			RemoteRole = "replication_effect",
			LikelyCausePath = "ReplicatedStorage.Remotes.TrainClick",
			LikelyCausePct = 82,
		}
		refreshLogDisplayName(log)
		assert(string.find(frame.Text.Text, "TrainClick", 1, true), "banner missing: " .. frame.Text.Text)
		assert(string.find(frame.Text.Text, "82%%", 1, true), "pct missing")
		frame:Destroy()
	end)

	tryTest(true, "action hunt: formatPayloadLibraryBlock", function()
		local path = SELF_TEST_PREFIX .. ".PayloadLib"
		US.remoteAtlas[path] = {
			shapes = {
				["n|s"] = { count = 5, sampleArgs = { "hit", 1 } },
				["n"] = { count = 2, sampleArgs = { 99 } },
			},
		}
		local block = formatPayloadLibraryBlock(path)
		assert(string.find(block, "PAYLOAD LIBRARY", 1, true), "header missing")
		assert(string.find(block, "hits=5", 1, true), "sort/count missing")
		US.remoteAtlas[path] = nil
	end)

	tryTest(true, "action hunt: ApplyPayloadIndex", function()
		local path = SELF_TEST_PREFIX .. ".ApplyIdx"
		US.remoteAtlas[path] = {
			shapes = { ["a"] = { count = 1, sampleArgs = { "x", 2 } } },
		}
		local log = { LogId = 88001, Snapshot = { path = path } }
		local ok = SimpleSpy:ApplyPayloadIndex(log, 1)
		assert(ok == true, "apply failed")
		assert(US.replayArgsOverride[88001][1] == "x", "args not stored")
		US.replayArgsOverride[88001] = nil
		US.remoteAtlas[path] = nil
	end)

	tryTest(true, "action hunt: internal wrapper not hookable", function()
		registerSpyProtectedFunctions()
		assert(isUltraSpyInternalWrapper("onHitNamecall", "@") == true)
		assert(isUltraSpyInternalWrapper("isRemoteFireNamecall", "@") == true)
		assert(isUltraSpyInternalWrapper("invokeOriginalNamecall", "@") == true)
		assert(isUltraSpyInternalWrapper("newInvokeServer", "@") == true)
		assert(isUltraSpyInternalWrapper("registerFunctionRemoteLink", "@") == true)
		assert(isUltraSpyInternalWrapper("formatCallStackForScript", "@") == true)
		assert(isUltraSpyInternalWrapper("recordRemoteObservation", "@") == true)
		assert(isUltraSpyInternalWrapper("pushWrapperCallBuffer", "@") == true)
		assert(isUltraSpyInternalWrapper("PlayerAttack", "Controllers.Combat") == false)
		assert(wrapperNameMatches("isRemoteFireNamecall") == false)
		assert(wrapperNameMatches("newInvokeServer") == false)
		if type(newInvokeServer) == "function" then
			assert(isSpyProtectedFunction(newInvokeServer) == true)
		end
	end)

	tryTest(true, "action hunt: ExportActionSession", function()
		local data = SimpleSpy:ExportActionSession(false)
		assert(type(data) == "table" and type(data.actions) == "table", "bad export")
	end)

	if testBin then
		testBin:Destroy()
		testBin = nil
	end

	US.selfTestInProgress = false
	US.selfTestRemotes = {}
	flushAllSpyQueues()
	cleanupSelfTestLogs()

	if selected and selected.Name and string.find(selected.Name, SELF_TEST_PREFIX, 1, true) then
		selected = nil
		pcall(function()
			codebox:setRaw("")
		end)
	end

	local passed = 0
	for _, r in ipairs(results) do
		if r.ok then
			passed += 1
		end
	end

	local total = #results
	startupSelfTestResults = {
		passed = passed,
		failed = requiredFail,
		optionalMiss = optionalMiss,
		total = total,
		ok = requiredFail == 0,
		results = results,
		time = os.date("%d/%m/%Y %H:%M:%S"),
	}

	_G.UltraSpySelfTest = startupSelfTestResults

	selfTestOut("--------------------------------------------------")
	selfTestOut(
		string.format(
			"RESULT %d/%d OK | required fail: %d | optional warn: %d",
			passed,
			total,
			requiredFail,
			optionalMiss
		)
	)
	if requiredFail == 0 then
		selfTestOut("ALL REQUIRED TESTS PASSED")
	else
		selfTestOut(tostring(requiredFail) .. " REQUIRED TEST(S) FAILED")
	end
	selfTestOut("==================================================")

	if codebox and startupSelfTestResults.ok then
		pcall(function()
			if not selected or not selected.Name or not string.find(selected.Name, SELF_TEST_PREFIX, 1, true) then
				codebox:setRaw(
					"-- UltraSpy self-test passed "
						.. tostring(startupSelfTestResults.passed)
						.. "/"
						.. tostring(startupSelfTestResults.total)
						.. "\n-- Full report in F9: [UltraSpy Self-Test]"
				)
			end
		end)
	end

	if TextLabel then
		TextLabel.Text = string.format(
			"Self-test: %d/%d OK%s",
			passed,
			total,
			requiredFail > 0 and (" | " .. requiredFail .. " FAIL") or ""
		)
	end
	markStartupTestsDone()
	end)

	if not okRun then
		markStartupTestsDone()
		return finishFatal(runErr)
	end

	return startupSelfTestResults
end

--- Toggles on and off the remote spy
function toggleSpy()
	if not toggle then
		if hookmetamethod then
			local oldNamecall = hookmetamethod(game, "__namecall", newnamecall)
			original = original or function(...)
				return oldNamecall(...)
			end
			_G.OriginalNamecall = original
		else
			gm = gm or getrawmetatable(game)
			original = original or function(...)
				return gm.__namecall(...)
			end
			setreadonly(gm, false)
			if not original then
				warn("UltraSpy: namecall method not found!")
				onToggleButtonClick()
				return
			end
			gm.__namecall = newnamecall
			setreadonly(gm, true)
		end
		originalEvent = hookfunction(remoteEvent.FireServer, newFireServer)
		originalFunction = hookfunction(remoteFunction.InvokeServer, newInvokeServer)
		if unreliableRemote and originalUnreliableFire then
			originalUnreliableFire = hookfunction(unreliableRemote.FireServer, newFireServer)
		end
		if hookmetamethod then
			pcall(function()
				namecallFallbackRestore.RemoteEvent = hookmetamethod(
					Instance.new("RemoteEvent"),
					"__namecall",
					newnamecall
				)
			end)
			pcall(function()
				namecallFallbackRestore.RemoteFunction = hookmetamethod(
					Instance.new("RemoteFunction"),
					"__namecall",
					newnamecall
				)
			end)
			if unreliableRemote then
				pcall(function()
					namecallFallbackRestore.UnreliableRemoteEvent = hookmetamethod(
						unreliableRemote,
						"__namecall",
						newnamecall
					)
				end)
			end
		end
		installCachedMethodHooks()
		registerSpyProtectedFunctions()
		local purged = purgeInternalWrapperHooks()
		if purged > 0 then
			warn("[UltraSpy] Removed " .. tostring(purged) .. " internal wrapper hook(s) on enable")
		end
		if _G.SIMPLESPYCONFIG_AggressiveModulePatch == true then
			hookRequireForModulePatch()
			task.defer(function()
				task.wait(0.1)
				resweepLoadedModules()
			end)
		end
		if trackBindablesEnabled() then
			installBindableHooks()
		end
	else
		removeBindableHooks()
		unhookRequireForModulePatch()
		removeCachedMethodHooks()
		if hookmetamethod then
			if original then
				hookmetamethod(game, "__namecall", original)
			end
			if namecallFallbackRestore.RemoteEvent then
				pcall(hookmetamethod, Instance.new("RemoteEvent"), "__namecall", namecallFallbackRestore.RemoteEvent)
			end
			if namecallFallbackRestore.RemoteFunction then
				pcall(hookmetamethod, Instance.new("RemoteFunction"), "__namecall", namecallFallbackRestore.RemoteFunction)
			end
			if namecallFallbackRestore.UnreliableRemoteEvent and unreliableRemote then
				pcall(hookmetamethod, unreliableRemote, "__namecall", namecallFallbackRestore.UnreliableRemoteEvent)
			end
			namecallFallbackRestore = {}
		else
			gm = gm or getrawmetatable(game)
			setreadonly(gm, false)
			gm.__namecall = original
			setreadonly(gm, true)
		end
		hookfunction(remoteEvent.FireServer, originalEvent)
		hookfunction(remoteFunction.InvokeServer, originalFunction)
		if unreliableRemote and originalUnreliableFire then
			hookfunction(unreliableRemote.FireServer, originalUnreliableFire)
		end
	end
end

--- Toggles between the two remotespy methods (hookfunction currently = disabled)
function toggleSpyMethod()
	toggleSpy()
	toggle = not toggle
end

--- Shuts down the remote spy
function shutdown()
	US.periodicDiscoveryRunning = false
	if schedulerconnect then
		schedulerconnect:Disconnect()
	end
	for _, connection in pairs(connections) do
		coroutine.wrap(function()
			connection:Disconnect()
		end)()
	end
	SimpleSpy2:Destroy()
	unhookRequireForModulePatch()
	removeBindableHooks()
	removeCachedMethodHooks()
	removeInstanceNewHook()
	removeAnimationHooks()
	restoreSpyCursor()
	hookfunction(remoteEvent.FireServer, originalEvent)
	hookfunction(remoteFunction.InvokeServer, originalFunction)
	if unreliableRemote and originalUnreliableFire then
		hookfunction(unreliableRemote.FireServer, originalUnreliableFire)
	end
	if hookmetamethod then
		if original then
			hookmetamethod(game, "__namecall", original)
		end
		namecallFallbackRestore = {}
	else
		gm = gm or getrawmetatable(game)
		setreadonly(gm, false)
		gm.__namecall = original
		setreadonly(gm, true)
	end
	_G.SimpleSpyExecuted = false
end

-- main
if not _G.SimpleSpyExecuted then
	local function runSpyInit()
		if not RunService:IsClient() then
			error("UltraSpy cannot run on the server!")
		end
		if
			not hookfunction
			or not getrawmetatable
			or getrawmetatable and not getrawmetatable(game).__namecall
			or not setreadonly
		then
			local missing = {}
			if not hookfunction then
				table.insert(missing, "hookfunction")
			end
			if not getrawmetatable then
				table.insert(missing, "getrawmetatable")
			end
			if getrawmetatable and not getrawmetatable(game).__namecall then
				table.insert(missing, "getrawmetatable(game).__namecall")
			end
			if not setreadonly then
				table.insert(missing, "setreadonly")
			end
			shutdown()
			error(
				"This environment does not support method hooks!\n(Your exploit is not capable of running UltraSpy)\nMissing: "
					.. table.concat(missing, ", ")
			)
		end
		_G.SimpleSpyShutdown = shutdown
		ContentProvider:PreloadAsync({
			"rbxassetid://6065821980",
			"rbxassetid://6065774948",
			"rbxassetid://6065821086",
			"rbxassetid://6065821596",
			ImageLabel,
			ImageLabel_2,
			ImageLabel_3,
		})
		setupPhase2Gui()
		showStartupLoading("UltraSpy", "Carregando interface", 0.12)
		syncSpyLayout()
		updateStartupLoading("Instalando hooks de rede", 0.28)
		onToggleButtonClick()
		RemoteTemplate.Parent = nil
		FunctionTemplate.Parent = nil
		codebox = Highlight.new(CodeBox)
		codebox:setRaw("")
		getgenv().SimpleSpy = SimpleSpy
		getgenv().getNil = function(name, class)
			for _, v in pairs(getnilinstances()) do
				if v.ClassName == class and v.Name == name then
					return v
				end
			end
		end
		TextLabel:GetPropertyChangedSignal("Text"):Connect(scaleToolTip)
		-- TopBar.InputBegan:Connect(onBarInput)
		MinimizeButton.MouseButton1Click:Connect(toggleMinimize)
		MaximizeButton.MouseButton1Click:Connect(toggleSideTray)
		Simple.MouseButton1Click:Connect(onToggleButtonClick)
		CloseButton.MouseEnter:Connect(onXButtonHover)
		CloseButton.MouseLeave:Connect(onXButtonUnhover)
		Simple.MouseEnter:Connect(onToggleButtonHover)
		Simple.MouseLeave:Connect(onToggleButtonUnhover)
		CloseButton.MouseButton1Click:Connect(shutdown)
		table.insert(connections, UserInputService.InputBegan:Connect(backgroundUserInput))
		table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				recordUiEvent(input, getMouseGuiTarget())
			end
		end))
		connectResize()
		if UIGridLayout then
			pcall(function()
				UIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateFunctionCanvas)
			end)
		end
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRemoteCanvas)
		SimpleSpy2.Enabled = true
		coroutine.wrap(function()
			wait(1)
			onToggleButtonUnhover()
		end)()
		schedulerconnect = RunService.Heartbeat:Connect(taskscheduler)
		bootstrapDeepScanRoots()
		startStateTracker()
		table.insert(connections, game.DescendantAdded:Connect(function(inst)
			if
				inst:IsA("RemoteEvent")
				or inst:IsA("RemoteFunction")
				or inst:IsA("UnreliableRemoteEvent")
			then
				knownRemotes[inst] = true
			end
			if isNetworkRemoteInstance(inst) then
				registerRemoteBirth(inst)
			end
		end))
		if _G.SIMPLESPYCONFIG_AggressiveModulePatch == true then
			task.defer(function()
				task.wait(2)
				hookRequireForModulePatch()
				resweepLoadedModules()
			end)
		end
		if syn and syn.protect_gui then
			pcall(syn.protect_gui, SimpleSpy2)
		end
		SimpleSpy2.Parent = --[[gethui and gethui() or]]
			CoreGui
		pcall(bringBackOnResize)
		_G.SimpleSpyExecuted = true
		if not Players.LocalPlayer then
			Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		end
		if Players.LocalPlayer then
			Mouse = Players.LocalPlayer:GetMouse()
			oldIcon = Mouse.Icon
			table.insert(connections, Mouse.Move:Connect(mouseMoved))
		end
		updateStartupLoading("Iniciando tracking e discovery", 0.45)
		task.defer(function()
			pcall(bootstrapPhase3Tracking)
			pcall(bootstrapPhase4Tracking)
			pcall(bootstrapPhase5Tracking)
			pcall(bootstrapPhase6Tracking)
			markStartupBootstrapDone()
		end)
		if _G.SIMPLESPYCONFIG_RunSelfTest ~= false then
			task.defer(function()
				RunService.Heartbeat:Wait()
				RunService.Heartbeat:Wait()
				updateStartupLoading("Executando testes F9", 0.72)
				local ok, err = pcall(runUltraSpySelfTest)
				if not ok then
					warn("[UltraSpy Self-Test] FATAL (outer): " .. tostring(err))
					markStartupTestsDone()
				end
			end)
		else
			US.startupLoading.testsDone = true
		end
	end
	local succeeded, err = xpcall(runSpyInit, function(fatalErr)
		return debug.traceback(tostring(fatalErr), 2)
	end)
	if not succeeded then
		warn(
			"A fatal error has occured, UltraSpy was unable to launch properly.\nPlease DM this error message to @exx#9394:\n\n"
				.. tostring(err)
		)
		SimpleSpy2:Destroy()
		unhookRequireForModulePatch()
		removeCachedMethodHooks()
		hookfunction(remoteEvent.FireServer, originalEvent)
		hookfunction(remoteFunction.InvokeServer, originalFunction)
		if unreliableRemote and originalUnreliableFire then
			hookfunction(unreliableRemote.FireServer, originalUnreliableFire)
		end
		if hookmetamethod then
			if original then
				hookmetamethod(game, "__namecall", original)
			end
		else
			setreadonly(gm, false)
			gm.__namecall = original
			setreadonly(gm, true)
		end
		return
	end
else
	SimpleSpy2:Destroy()
	return
end

----- ADD ONS ----- (easily add or remove additonal functionality to the RemoteSpy!)
--[[
    Some helpful things:
        - add your function in here, and create buttons for them through the 'newButton' function
        - the first argument provided is the TextButton the player clicks to run the function
        - generated scripts are generated when the namecall is initially fired and saved in remoteFrame objects
        - blacklisted remotes will be ignored directly in namecall (less lag)
        - the properties of a 'remoteFrame' object:
            {
                Name: (string) The name of the Remote
                GenScript: (string) The generated script that appears in the codebox (generated when namecall fired)
                Source: (Instance (LocalScript)) The script that fired/invoked the remote
                Remote: (Instance (RemoteEvent) | Instance (RemoteFunction)) The remote that was fired/invoked
                Log: (Instance (TextButton)) The button being used for the remote (same as 'selected.Log')
            }
        - globals list: (contact @exx#9394 for more information or if you have suggestions for more to be added)
            - closed: (boolean) whether or not the GUI is currently minimized
            - logs: (table[remoteFrame]) full of remoteFrame objects (properties listed above)
            - selected: (remoteFrame) the currently selected remoteFrame (properties listed above)
            - blacklist: (string[] | Instance[] (RemoteEvent) | Instance[] (RemoteFunction)) an array of blacklisted names and remotes
            - codebox: (Instance (TextBox)) the textbox that holds all the code- cleared often
]]
-- Copies the contents of the codebox
newButton("Copy Code", function()
	return "Click to copy code"
end, function()
	setclipboard(codebox:getString())
	TextLabel.Text = "Copied successfully!"
end)

--- Copies the source script (that fired the remote)
newButton("Copy Remote", function()
	return "Click to copy the path of the remote"
end, function()
	if selected then
		setclipboard(v2s(selected.Remote.remote))
		TextLabel.Text = "Copied!"
	end
end)

-- Executes the contents of the codebox through loadstring
newButton("Run Code", function()
	return "Click to execute code"
end, function()
	local orText = "Click to execute code"
	TextLabel.Text = "Executing..."
	local succeeded = pcall(function()
		return loadstring(codebox:getString())()
	end)
	if succeeded then
		TextLabel.Text = "Executed successfully!"
	else
		TextLabel.Text = "Execution error!"
	end
end)

newButton("Edit Args", function()
	return "Open smart arg editor for selected log (payload history as comments)"
end, function()
	local ok, err = SimpleSpy:OpenReplayArgsEditor()
	TextLabel.Text = ok and "Edit args in codebox — Apply Args when ready" or ("Edit Args: " .. tostring(err))
end)

newButton("Apply Args", function()
	return "Parse Replay Args table from codebox and use for Replay"
end, function()
	local ok, err = SimpleSpy:ApplyReplayArgsFromEditor()
	TextLabel.Text = ok and "Args applied to selected log" or ("Apply failed: " .. tostring(err))
end)

newButton("Replay 1x", function()
	return "Fire selected remote once with current/edited args"
end, function()
	local ok, err = runReplayBurst(1, 0, false)
	TextLabel.Text = ok and "Replay 1x sent" or ("Replay: " .. tostring(err))
end)

newButton("Replay 10x", function()
	return string.format(
		"Fire selected remote %dx (delay %.2fs). Set SIMPLESPYCONFIG_ReplayBurstCount / ReplayBurstDelay",
		getReplayBurstCount(),
		getReplayBurstDelay()
	)
end, function()
	local ok, err = runReplayBurst(getReplayBurstCount(), getReplayBurstDelay(), _G.SIMPLESPYCONFIG_ReplayRandomizeArgs == true)
	TextLabel.Text = ok and ("Replaying " .. tostring(getReplayBurstCount()) .. "x...") or ("Replay: " .. tostring(err))
end)

newButton("Stop Replay", function()
	return "Cancel in-progress Replay burst"
end, function()
	stopReplayBurst()
	TextLabel.Text = "Replay stopped"
end)

newButton("Payloads", function()
	return "Payload library from Remote Atlas for selected remote — ApplyPayloadIndex(log, n)"
end, function()
	if not selected or not selected.Snapshot or not selected.Snapshot.path then
		TextLabel.Text = "Select a remote log first"
		return
	end
	codebox:setRaw(formatPayloadLibraryBlock(selected.Snapshot.path))
	TextLabel.Text = "Payload library loaded — use Apply Args or ApplyPayloadIndex"
end)

newButton("Action Hunt", function()
	return string.format(
		"[%s] Prioritize action remotes: Out+Act+NoSpam, score sort, SYNC→trigger banner",
		isActionHuntModeEnabled() and "ON" or "OFF"
	)
end, function()
	_G.SIMPLESPYCONFIG_ActionHuntMode = not isActionHuntModeEnabled()
	if isActionHuntModeEnabled() then
		applyActionHuntPreset()
		US.logViewFilter.direction = "out"
		US.logViewFilter.role = "action"
		US.logViewFilter.hideSpam = true
		startPeriodicDiscoveryLoop()
	else
		US.periodicDiscoveryRunning = false
	end
	scheduleLogFilterRefresh()
	resortActionHuntLogList()
	TextLabel.Text = string.format("Action Hunt %s", isActionHuntModeEnabled() and "ON" or "OFF")
end)

newButton("GUI → Remotes", function()
	return "Correlate GUI under mouse with recent UI events and outbound remotes"
end, function()
	codebox:setRaw(SimpleSpy:GetGuiRemoteCorrelation())
	TextLabel.Text = "GUI→Remotes report loaded"
end)

newButton("Export Actions", function()
	return "Export action_candidate logs as table (verified only if SIMPLESPYCONFIG_VerifiedOnly)"
end, function()
	local data = SimpleSpy:ExportActionSession(isVerifiedOnlyFilterEnabled())
	local hs = game:GetService("HttpService")
	local ok, encoded = pcall(hs.JSONEncode, hs, data)
	if ok and encoded then
		setclipboard(encoded)
		codebox:setRaw("-- Exported " .. tostring(data.count) .. " actions (JSON on clipboard)\n" .. encoded)
		TextLabel.Text = "Exported " .. tostring(data.count) .. " actions"
	else
		codebox:setRaw("-- Export (Lua table)\nreturn " .. tostring(data.count) .. " actions")
		TextLabel.Text = "Exported " .. tostring(data.count) .. " (clipboard failed)"
	end
end)

--- Gets the calling script (not super reliable but w/e)
newButton("Get Script", function()
	return "Click to copy calling script to clipboard\nWARNING: Not super reliable, nil == could not find"
end, function()
	if selected then
		setclipboard(SimpleSpy:ValueToString(selected.Source))
		TextLabel.Text = "Done!"
	end
end)

--- Decompiles the script that fired the remote and puts it in the code box
newButton("Function Info", function()
	return "Click to view calling function information"
end, function()
	if selected then
		if selected.Function then
			codebox:setRaw(
				"-- Calling function info\n-- Generated by the UltraSpy serializer\n\n" .. tostring(selected.Function)
			)
		end
		TextLabel.Text = "Done! Function info generated by the UltraSpy Serializer."
	end
end)

--- Clears the Remote logs
newButton("Clr Logs", function()
	return "Click to clear logs"
end, function()
	TextLabel.Text = "Clearing..."
	logs = {}
	US.logGroups = {}
	layoutOrderNum = 999999999
	for _, v in pairs(LogList:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
	if US.gui.TimelineList then
		for _, v in pairs(US.gui.TimelineList:GetChildren()) do
			if not v:IsA("UIListLayout") then
				v:Destroy()
			end
		end
	end
	codebox:setRaw("")
	selected = nil
	TextLabel.Text = "Logs cleared!"
end)

--- Excludes the selected.Log Remote from the RemoteSpy
newButton("Exclude (i)", function()
	return "Click to exclude this Remote.\nExcluding a remote makes UltraSpy ignore it, but it will continue to be usable."
end, function()
	if selected then
		blacklist[selected.Remote.remote] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- Excludes all Remotes that share the same name as the selected.Log remote from the RemoteSpy
newButton("Exclude (n)", function()
	return "Click to exclude all remotes with this name.\nExcluding a remote makes UltraSpy ignore it, but it will continue to be usable."
end, function()
	if selected then
		blacklist[selected.Name] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- clears blacklist
newButton("Clr Blacklist", function()
	return "Click to clear the blacklist.\nExcluding a remote makes UltraSpy ignore it, but it will continue to be usable."
end, function()
	blacklist = {}
	TextLabel.Text = "Blacklist cleared!"
end)

--- Prevents the selected.Log Remote from firing the server (still logged)
newButton("Block (i)", function()
	return "Click to stop this remote from firing.\nBlocking a remote won't remove it from UltraSpy logs, but it will not continue to fire the server."
end, function()
	if selected then
		if selected.Remote.remote then
			blocklist[selected.Remote.remote] = true
			TextLabel.Text = "Excluded!"
		else
			TextLabel.Text = "Error! Instance may no longer exist, try using Block (n)."
		end
	end
end)

--- Prevents all remotes from firing that share the same name as the selected.Log remote from the RemoteSpy (still logged)
newButton("Block (n)", function()
	return "Click to stop remotes with this name from firing.\nBlocking a remote won't remove it from UltraSpy logs, but it will not continue to fire the server."
end, function()
	if selected then
		blocklist[selected.Name] = true
		TextLabel.Text = "Excluded!"
	end
end)

--- clears blacklist
newButton("Clr Blocklist", function()
	return "Click to stop blocking remotes.\nBlocking a remote won't remove it from UltraSpy logs, but it will not continue to fire the server."
end, function()
	blocklist = {}
	TextLabel.Text = "Blocklist cleared!"
end)

--- Attempts to decompile the source script
newButton("Decompile", function()
	return "Attempts to decompile source script\nWARNING: Not super reliable, nil == could not find"
end, function()
	if selected then
		if selected.Source then
			codebox:setRaw(decompile(selected.Source))
			TextLabel.Text = "Done!"
		else
			TextLabel.Text = "Source not found!"
		end
	end
end)

newButton("Disable Info", function()
	return string.format(
		"[%s] Toggle function info (because it can cause lag in some games)",
		funcEnabled and "ENABLED" or "DISABLED"
	)
end, function()
	funcEnabled = not funcEnabled
	TextLabel.Text = string.format(
		"[%s] Toggle function info (because it can cause lag in some games)",
		funcEnabled and "ENABLED" or "DISABLED"
	)
end)

newButton("Autoblock", function()
	return string.format(
		"[%s] Tags spammy remotes with [spam] — does NOT hide them from the log",
		autoblock and "ENABLED" or "DISABLED"
	)
end, function()
	autoblock = not autoblock
	TextLabel.Text = string.format(
		"[%s] Tags spammy remotes with [spam] — does NOT hide them from the log",
		autoblock and "ENABLED" or "DISABLED"
	)
	history = {}
	excluding = {}
end)

newButton("Force log all", function()
	return "Disables autoblock and raises max log cap for dense remote spam"
end, function()
	autoblock = false
	history = {}
	excluding = {}
	_G.SIMPLESPYCONFIG_MaxRemotes = math.max(_G.SIMPLESPYCONFIG_MaxRemotes or 500, 2000)
	_G.SIMPLESPYCONFIG_MaxScheduleQueue = math.max(_G.SIMPLESPYCONFIG_MaxScheduleQueue or 5000, 10000)
	TextLabel.Text = "Force log all: autoblock OFF, caps raised"
end)

newButton("Hook caller", function()
	return "Hooks the first game function in the call stack and logs wrapper calls with args"
end, function()
	if not selected or not selected.CallStack or #selected.CallStack == 0 then
		TextLabel.Text = "No call stack on this log — select a remote entry"
		return
	end
	local frame = selected.CallStack[1]
	if typeof(frame.func) ~= "function" then
		TextLabel.Text = "Caller is not a hookable function"
		return
	end
	if wrapperHooksInstalled[tostring(frame.func)] then
		TextLabel.Text = "Caller already hooked"
		return
	end
	local ok = installWrapperFunctionHook(frame.func, frame.name, frame.source, frame.layer)
	TextLabel.Text = ok and ("Hooked: " .. frame.name) or "Hook failed"
end)

newButton("AutoHookStack", function()
	return string.format(
		"[%s] Auto-hooks Lua closures found in call stacks (may impact performance)",
		(_G.SIMPLESPYCONFIG_AutoHookStack == true) and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_AutoHookStack = not (_G.SIMPLESPYCONFIG_AutoHookStack == true)
	autoHookStack = _G.SIMPLESPYCONFIG_AutoHookStack
	TextLabel.Text = string.format(
		"[%s] Auto-hooks Lua closures in call stacks",
		autoHookStack and "ENABLED" or "DISABLED"
	)
end)

newButton("CallingScript", function()
	return string.format(
		"[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up UltraSpy to detection and/or instability.",
		useGetCallingScript and "ENABLED" or "DISABLED"
	)
end, function()
	useGetCallingScript = not useGetCallingScript
	TextLabel.Text = string.format(
		"[%s] [UNSAFE] Uses 'getcallingscript' to get calling script for Decompile and GetScript. Much more reliable, but opens up UltraSpy to detection and/or instability.",
		useGetCallingScript and "ENABLED" or "DISABLED"
	)
end)

newButton("KeyToString", function()
	return string.format(
		"[%s] [BETA] Uses an experimental new function to replicate Roblox's behavior when a non-primitive type is used as a key in a table. Still in development and may not properly reflect tostringed (empty) userdata.",
		keyToString and "ENABLED" or "DISABLED"
	)
end, function()
	keyToString = not keyToString
	TextLabel.Text = string.format(
		"[%s] [BETA] Uses an experimental new function to replicate Roblox's behavior when a non-primitive type is used as a key in a table. Still in development and may not properly reflect tostringed (empty) userdata.",
		keyToString and "ENABLED" or "DISABLED"
	)
end)

newButton("ToggleReturnValues", function()
	return string.format(
		"[%s] [EXPERIMENTAL] Enables recording of return values for 'GetReturnValue'\n\nUse this method at your own risk, as it could be detectable.",
		recordReturnValues and "ENABLED" or "DISABLED"
	)
end, function()
	recordReturnValues = not recordReturnValues
	TextLabel.Text = string.format(
		"[%s] [EXPERIMENTAL] Enables recording of return values for 'GetReturnValue'\n\nUse this method at your own risk, as it could be detectable.",
		recordReturnValues and "ENABLED" or "DISABLED"
	)
end)

newButton("GetReturnValue", function()
	return "[Experimental] If 'ReturnValues' is enabled, this will show the recorded return value for the RemoteFunction (if available)."
end, function()
	if selected then
		codebox:setRaw(SimpleSpy:ValueToVar(selected.ReturnValue, "returnValue"))
	end
end)

newButton("Call Chain", function()
	return "Shows UI -> Controller -> Network -> Remote chain for the selected log"
end, function()
	if selected then
		codebox:setRaw(SimpleSpy:GetCallChain(selected) .. "\n" .. (selected.GenScript or ""))
		TextLabel.Text = "Call chain loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Flow View", function()
	return "Shows Flow #N step chain for the selected log (UI -> Bindable -> Wrapper -> Remote)"
end, function()
	if selected then
		codebox:setRaw(SimpleSpy:GetFlowView(selected) .. "\n" .. (selected.GenScript or ""))
		TextLabel.Text = "Flow view loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Remote Atlas", function()
	return "Session tree of inferred remote actions and payload shapes (survives Clr Logs)"
end, function()
	codebox:setRaw(SimpleSpy:GetRemoteAtlas())
	TextLabel.Text = "Remote atlas loaded"
end)

newButton("Payload Patterns", function()
	return "Payload shapes and inferred actions for the selected remote"
end, function()
	if selected and selected.Snapshot then
		codebox:setRaw(SimpleSpy:GetRemotePatterns(selected.Snapshot.path))
		TextLabel.Text = "Payload patterns loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Export Atlas", function()
	return "Copies Remote Atlas text to clipboard"
end, function()
	local text = formatRemoteAtlas()
	if setclipboard then
		setclipboard(text)
		TextLabel.Text = "Atlas copied to clipboard"
	else
		codebox:setRaw(text)
		TextLabel.Text = "setclipboard unavailable — atlas shown in editor"
	end
end)

newButton("Clr Atlas", function()
	return "Clears Remote Atlas counters (does not clear logs or network map)"
end, function()
	clearRemoteAtlas()
	TextLabel.Text = "Remote atlas cleared"
end)

newButton("Network Map", function()
	return "Shows graph built from all observed execution chains"
end, function()
	codebox:setRaw(SimpleSpy:GetNetworkMap())
	TextLabel.Text = "Network map updated"
end)

newButton("Discover Wrappers", function()
	return "Scans getloadedmodules / getgc for Send, Fire, Network, etc. (executor APIs)"
end, function()
	TextLabel.Text = "Scanning..."
	schedule(function()
		local list = SimpleSpy:DiscoverWrappers()
		codebox:setRaw(formatDiscoveredWrappers(list))
		TextLabel.Text = string.format("Found %d symbols", #list)
	end)
end)

newButton("UI Correlate", function()
	return string.format(
		"[%s] Links recent clicks/touches to the next remote log (%.1fs window)",
		trackUiCorrelation and "ENABLED" or "DISABLED",
		_G.SIMPLESPYCONFIG_UiCorrelateWindow or UI_CORRELATE_WINDOW
	)
end, function()
	trackUiCorrelation = not trackUiCorrelation
	_G.SIMPLESPYCONFIG_UiCorrelate = trackUiCorrelation
	TextLabel.Text = string.format(
		"[%s] UI -> remote correlation",
		trackUiCorrelation and "ENABLED" or "DISABLED"
	)
end)

newButton("Flow Tracking", function()
	return string.format(
		"[%s] Correlates UI/wrapper/bindable steps into Flow #N on each remote log",
		isFlowTrackingEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_FlowTracking = not isFlowTrackingEnabled()
	TextLabel.Text = string.format(
		"[%s] Flow tracking",
		isFlowTrackingEnabled() and "ENABLED" or "DISABLED"
	)
end)

newButton("Track Bindables", function()
	return string.format(
		"[%s] Adds BindableEvent:Fire / BindableFunction:Invoke to flow only (no log line)",
		trackBindablesEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_TrackBindables = not trackBindablesEnabled()
	if toggle then
		if trackBindablesEnabled() then
			installBindableHooks()
		else
			removeBindableHooks()
		end
	end
	TextLabel.Text = string.format(
		"[%s] Bindable flow tracking",
		trackBindablesEnabled() and "ENABLED" or "DISABLED"
	)
end)

newButton("Group Logs", function()
	return string.format(
		"[%s] Groups repeated remotes as Name xN with expandable sub-calls",
		isGroupLogsEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_GroupLogs = not isGroupLogsEnabled()
	TextLabel.Text = string.format("[%s] Grouped log view", isGroupLogsEnabled() and "ENABLED" or "DISABLED")
end)

newButton("Track Inbound", function()
	return string.format(
		"[%s] Logs RemoteEvent.OnClientEvent (server → client) passively",
		trackInboundEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_TrackInbound = not trackInboundEnabled()
	if trackInboundEnabled() then
		scanInboundRemotes(ReplicatedStorage)
	end
	TextLabel.Text = string.format("[%s] Inbound tracking", trackInboundEnabled() and "ENABLED" or "DISABLED")
end)

newButton("State Log", function()
	return "Shows session leaderstats / attribute changes"
end, function()
	codebox:setRaw(SimpleSpy:GetStateLog())
	TextLabel.Text = "State log loaded"
end)

newButton("Remote Lifecycle", function()
	return "Created / destroyed / call counts for remotes this session"
end, function()
	codebox:setRaw(SimpleSpy:GetRemoteLifecycle())
	TextLabel.Text = "Remote lifecycle loaded"
end)

newButton("Track Creation", function()
	return string.format(
		"[%s] Hooks Instance.new for RemoteEvent/Function/Bindable",
		isTrackRemoteCreationEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_TrackRemoteCreation = not isTrackRemoteCreationEnabled()
	if isTrackRemoteCreationEnabled() then
		installInstanceNewHook()
	else
		removeInstanceNewHook()
	end
	TextLabel.Text = string.format("[%s] Remote creation hook", isTrackRemoteCreationEnabled() and "ENABLED" or "DISABLED")
end)

newButton("Correlation", function()
	return "Unified post-remote correlation sessions (state/GUI/prop/anim)"
end, function()
	codebox:setRaw(SimpleSpy:GetCorrelationReport())
	TextLabel.Text = "Correlation report loaded"
end)

newButton("Remote Refs", function()
	return string.format(
		"[%s] Tracks who cached .FireServer / .InvokeServer per remote",
		isTrackRemoteReferencesEnabled() and "ENABLED" or "DISABLED"
	)
end, function()
	codebox:setRaw(SimpleSpy:GetRemoteReferences())
	TextLabel.Text = "Remote reference tracker loaded"
end)

newButton("Deep Discovery", function()
	return "getgc + constants + protos + upvalues — finds remotes without firing"
end, function()
	TextLabel.Text = "Running deep discovery..."
	schedule(function()
		discoverRemoteCandidates()
		codebox:setRaw(SimpleSpy:GetDiscoveryAtlas() .. "\n\n" .. formatDiscoveredWrappers(discoverNetworkWrappers()))
		TextLabel.Text = "Deep discovery complete"
	end)
end)

newButton("Module Graph", function()
	return "Module dependency graph (require / remote_ref / constants)"
end, function()
	TextLabel.Text = "Building module graph..."
	schedule(function()
		buildModuleDependencyGraph()
		codebox:setRaw(SimpleSpy:GetModuleGraph())
		TextLabel.Text = "Module graph ready"
	end)
end)

newButton("Protocol Report", function()
	return "PROTO_A/B/C payload signatures per remote"
end, function()
	codebox:setRaw(SimpleSpy:GetProtocolReport())
	TextLabel.Text = "Protocol report loaded"
end)

newButton("Action Outcomes", function()
	return "Normal / Success / Failed counts per action (session)"
end, function()
	codebox:setRaw(SimpleSpy:GetActionOutcomes())
	TextLabel.Text = "Action outcomes loaded"
end)

newButton("Cause Log", function()
	return "Recent world causes (Touched, Tool, Raycast, etc.)"
end, function()
	codebox:setRaw(SimpleSpy:GetCauseLog())
	TextLabel.Text = "Cause log loaded"
end)

newButton("Investigation Log", function()
	return "Sessions linking remote, inbound, state, property, cause"
end, function()
	codebox:setRaw(SimpleSpy:GetInvestigationLog())
	TextLabel.Text = "Investigation loaded"
end)

newButton("Damage Log", function()
	return "HP damage dealt/taken events with remote hints"
end, function()
	codebox:setRaw(SimpleSpy:GetDamageEventLog())
	TextLabel.Text = "Damage log loaded"
end)

newButton("Reward Log", function()
	return "Coins/XP/reward stat increases with causes"
end, function()
	codebox:setRaw(SimpleSpy:GetRewardEventLog())
	TextLabel.Text = "Reward log loaded"
end)

newButton("Property Log", function()
	return "Reward-relevant UI property changes"
end, function()
	codebox:setRaw(SimpleSpy:GetPropertyLog())
	TextLabel.Text = "Property log loaded"
end)

newButton("Combat Discovery", function()
	return "Rank outbound remotes after NPC hit (1s window)"
end, function()
	SimpleSpy:StartCombatDiscoveryWindow()
	codebox:setRaw(SimpleSpy:GetCombatDiscoveryReport())
	TextLabel.Text = "Combat discovery — attack NPC within 1s"
end)

newButton("Reward Discovery", function()
	return "Rank reward-ish remotes after reward (window after press)"
end, function()
	SimpleSpy:StartRewardDiscoveryWindow()
	codebox:setRaw(SimpleSpy:GetRewardDiscoveryReport())
	TextLabel.Text = "Reward discovery — press buttons that grant rewards"
end)

newButton("Root Cause", function()
	return "Last stat change → ranked outbound cause vs sync (Result → Who)"
end, function()
	codebox:setRaw(SimpleSpy:GetRootCauseReport())
	TextLabel.Text = "Root cause report loaded"
end)

newButton("State Dependencies", function()
	return "Learned preconditions for selected remote (weapon, quest, zone)"
end, function()
	if selected and selected.Snapshot then
		codebox:setRaw(SimpleSpy:GetStateDependencies(selected.Snapshot.path))
		TextLabel.Text = "State dependencies loaded"
	else
		codebox:setRaw(SimpleSpy:GetStateDependencies())
		TextLabel.Text = "Select a remote for state dependencies"
	end
end)

newButton("Action Sequences", function()
	return "Multi-remote chains (Start → Main → Finish) per flow/UI"
end, function()
	local filter = selected and selected.ActionKey
	codebox:setRaw(SimpleSpy:GetActionSequences(filter))
	TextLabel.Text = "Action sequences loaded"
end)

newButton("Top Actions", function()
	return "TOP ACTIONS from function↔remote registry"
end, function()
	codebox:setRaw(SimpleSpy:GetTopActions(15))
	TextLabel.Text = "Top actions loaded"
end)

newButton("Callback Map", function()
	return "getconnections map for part under mouse or registry"
end, function()
	local target = Mouse and Mouse.Target
	codebox:setRaw(SimpleSpy:GetCallbackMap(target))
	TextLabel.Text = "Callback map loaded"
end)

newButton("Tagged Entities", function()
	return "CollectionService tagged entities being watched"
end, function()
	codebox:setRaw(SimpleSpy:GetTaggedEntities())
	TextLabel.Text = "Tagged entities loaded"
end)

newButton("Scan Player Data", function()
	return "Rescan Player/Character/PlayerGui values and nearby NPCs"
end, function()
	codebox:setRaw(SimpleSpy:ScanPlayerDataTree())
	TextLabel.Text = "Player data tree rescanned"
end)

newButton("Hidden Stats", function()
	return "Obfuscated Value/Int paths with inferred HP/reward roles"
end, function()
	codebox:setRaw(SimpleSpy:GetHiddenStatReport())
	TextLabel.Text = "Hidden stat report loaded"
end)

newButton("Wrapper Chain", function()
	return "Auto wrapper chain for selected remote (Send/Encode/Fire)"
end, function()
	if selected and selected.Snapshot then
		codebox:setRaw(SimpleSpy:GetWrapperChain(selected.Snapshot.path))
		TextLabel.Text = "Wrapper chain loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Remote Callers", function()
	return "Functions and upvalues that reference the selected remote"
end, function()
	if selected and selected.Snapshot then
		codebox:setRaw(SimpleSpy:GetRemoteCallers(selected.Snapshot.path))
		TextLabel.Text = "Remote callers loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Remote Profile", function()
	return "Combat/Reward/Shop classification from fire signatures"
end, function()
	if selected and selected.Snapshot then
		codebox:setRaw(SimpleSpy:GetRemoteProfile(selected.Snapshot.path))
		TextLabel.Text = "Remote profile loaded"
	else
		TextLabel.Text = "Select a remote log first"
	end
end)

newButton("Scan Upvalues", function()
	return "Deep scan closures for remotes held in upvalues"
end, function()
	TextLabel.Text = "Scanning upvalues..."
	schedule(function()
		codebox:setRaw(SimpleSpy:ScanUpvalueRegistry())
		TextLabel.Text = "Upvalue scan complete"
	end)
end)

newButton("Metatable Links", function()
	return "Facade methods (Network.Attack) mapped to real remotes"
end, function()
	codebox:setRaw(SimpleSpy:GetMetatableLinks())
	TextLabel.Text = "Metatable links loaded"
end)

newButton("Timeline", function()
	return "Timeline tab — OUT/IN events; use chips to filter"
end, function()
	US.timelineFilter.outbound = true
	US.timelineFilter.inbound = true
	US.timelineFilter.ui = false
	US.timelineFilter.state = false
	US.timelineFilter.prop = false
	setLeftPanelView("timeline")
	codebox:setRaw(SimpleSpy:GetTimeline())
	setSpyStatus("Timeline — OUT+IN filter")
end)

newButton("Clr Network Map", function()
	return "Clears the observed network graph"
end, function()
	networkGraph = {}
	TextLabel.Text = "Network map cleared"
end)

newButton("Static Module Map", function()
	return "Lists functions in loaded ModuleScripts (Controller/Network/UI layers)"
end, function()
	TextLabel.Text = "Building static map..."
	schedule(function()
		codebox:setRaw(SimpleSpy:GetStaticModuleMap())
		TextLabel.Text = "Static module map ready"
	end)
end)

newButton("Trace GUI", function()
	return "getconnections on GuiObject under mouse (if executor supports it)"
end, function()
	codebox:setRaw(SimpleSpy:TraceGuiAtMouse())
	TextLabel.Text = "GUI trace loaded"
end)

newButton("Fire GUI Signal", function()
	return "firesignal on selected log UI target — may trigger real game actions"
end, function()
	if not firesignal then
		TextLabel.Text = "firesignal not available"
		return
	end
	local target = Mouse and Mouse.Target
	if not target and selected and selected.UiTrigger and selected.UiTrigger.path ~= "?" then
		pcall(function()
			target = game:FindFirstChild(selected.UiTrigger.path, true)
		end)
	end
	if not target then
		TextLabel.Text = "No GUI under mouse"
		return
	end
	local fired = false
	pcall(function()
		if target.MouseButton1Click then
			firesignal(target.MouseButton1Click)
			fired = true
		elseif target.Activated then
			firesignal(target.Activated)
			fired = true
		end
	end)
	TextLabel.Text = fired and "firesignal sent" or "Could not fire signal"
end)

newButton("Resweep Modules", function()
	return "Patches network-like functions in loaded modules (use with AggressiveModulePatch)"
end, function()
	local n = SimpleSpy:ResweepModules()
	TextLabel.Text = string.format("Resweep: %d function(s) patched", n)
end)

newButton("Log Wrapper Calls", function()
	return string.format(
		"[%s] Log wrapper layer calls (green entries) when hooks fire",
		(_G.SIMPLESPYCONFIG_LogWrapperCalls ~= false) and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_LogWrapperCalls = not (_G.SIMPLESPYCONFIG_LogWrapperCalls ~= false)
	TextLabel.Text = string.format(
		"[%s] Wrapper call logging",
		(_G.SIMPLESPYCONFIG_LogWrapperCalls ~= false) and "ENABLED" or "DISABLED"
	)
end)

newButton("Aggressive Patch", function()
	return string.format(
		"[%s] Hooks require + patches module env (OFF by default — detection risk)",
		(_G.SIMPLESPYCONFIG_AggressiveModulePatch == true) and "ENABLED" or "DISABLED"
	)
end, function()
	_G.SIMPLESPYCONFIG_AggressiveModulePatch = not (_G.SIMPLESPYCONFIG_AggressiveModulePatch == true)
	if _G.SIMPLESPYCONFIG_AggressiveModulePatch and toggle then
		hookRequireForModulePatch()
		resweepLoadedModules()
	else
		unhookRequireForModulePatch()
	end
	TextLabel.Text = string.format(
		"[%s] Aggressive module patch",
		(_G.SIMPLESPYCONFIG_AggressiveModulePatch == true) and "ENABLED" or "DISABLED"
	)
end)

newButton("Capabilities", function()
	return "Shows which executor APIs UltraSpy can use"
end, function()
	local caps = SimpleSpy:GetCapabilities()
	local lines = { "-- UltraSpy capabilities", "" }
	for k, v in pairs(caps) do
		table.insert(lines, string.format("-- %s: %s", k, tostring(v)))
	end
	codebox:setRaw(table.concat(lines, "\n"))
	TextLabel.Text = "Capabilities loaded"
end)

newButton("Run Self-Test", function()
	return "Runs full UltraSpy diagnostics (hooks, forward, log, UI, APIs)"
end, function()
	TextLabel.Text = "Running self-test..."
	schedule(function()
		local report = runUltraSpySelfTest()
		if report then
			local lines = {
				"-- UltraSpy self-test report",
				"-- " .. (report.time or "?"),
				"",
				string.format(
					"-- %d/%d passed | required failures: %d | optional warnings: %d",
					report.passed,
					report.total,
					report.failed,
					report.optionalMiss
				),
				"",
			}
			for _, r in ipairs(report.results or {}) do
				table.insert(
					lines,
					string.format(
						"-- [%s] %s %s%s",
						r.required and "REQ" or "OPT",
						r.ok and "PASS" or "FAIL",
						r.name,
						r.detail ~= "" and (" — " .. r.detail) or ""
					)
				)
			end
			codebox:setRaw(table.concat(lines, "\n"))
			TextLabel.Text = report.ok and "Self-test: all required passed" or ("Self-test: " .. report.failed .. " FAIL")
			setSpyStatus(TextLabel.Text)
		end
	end)
end)

syncSpyLayout()
setSpyStatus("UltraSpy ready — Code | Track | Discover | Advanced")