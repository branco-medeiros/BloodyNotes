--[[


]]


-- TODO: Create Notes Window
-- TODO: Create Dropdown for Categories (with Add New... entry)
-- TODO: Create Dropdown for Notes (with Add New... entry)
-- TODO: Create Popup menu for Categories: Delete, Rename
-- TODO: Create Popup menu for Note: Delete, Rename, Category, Duplicate, Edit
-- TODO: Create dialog for creating/renaming note
-- TODO: Create dialog for creating/renaming category
-- TODO: Create Edit window

-- TODO: Create ShowNotes floating button
-- TODO: Create animation to show Notes Window and hide ShowNotes button

-- DONE: Create slash command to show main window
-- DONE: Create slash command to show notes window
-- TODO: Resolve issue: Edit window closes when opened from the addons page and the parent frame closes

local ADDON_NAME = "BloodyNotes"
local ADDON_DB = ADDON_NAME .. "DB"
local DISPLAY_NAME = "Bloody Notes"
local ADDON_CMD = ADDON_NAME:lower()
local ADDON_CMD2 = "bn"
local ADDON_CMD3 = "bloody"
local ADDON_GLOBAL_WINDOW = "BloodyNotes_Window"

local ADDON_VERSION = "0.1"
local bn = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local gui = LibStub("AceGUI-3.0");
local config = LibStub("AceConfig-3.0")
local configDlg = LibStub("AceConfigDialog-3.0")
local configCmd = LibStub("AceConfigCmd-3.0")

local MAX_LINES = 200

BLOODY = bn


local function SetBorder(this, size, r, g, b, alpha)
  r = r or 0
  g = g or 0
  b = b or 0
  alpha = alpha or 1
  if not size or size == 0 then
    this:SetBackdrop({edgeFile = nil, edgeSize = 0})
  else
    this.edge = [[Interface\Buttons\WHITE8X8]]
    this:SetBackdrop({edgeFile= this.edge, edgeSize=size})
    this:SetBackdropBorderColor(r, g, b, alpha)
  end --if
  return this

end

local function OnCommand(text)
  return bn:OnCommand(text)
end

-- db structure 
--[[ 
  Options = {
    -- don't know what options we will need
  }
  Notes = {
    {id, value, text, icon, children = {
      {id, value, text, icon}*
    }}*
  }
]]
function bn:OnInitialize()
  self.Status = {NotesWindow = {}, EditWindow = {}, MiniButton = {}}

  local name = self:GetName()
  self.db = LibStub("AceDB-3.0"):New(ADDON_DB, {global={}})

  self:InitNotesWindow()
  self:InitMiniButton()
  self:InitEditWindow()
  self:InitChatCommands()
  self:InitOptions()
  self:LoadNotes()
end

function bn:InitChatCommands()
  local function OnCommand(...)
    bn:OnChatCommand(...)
  end

  self:RegisterChatCommand(ADDON_CMD, OnCommand)
  self:RegisterChatCommand(ADDON_CMD2, OnCommand)
  self:RegisterChatCommand(ADDON_CMD3, OnCommand)
end

function bn:InitOptions()
  local options = {
    name = DISPLAY_NAME .. " " ..ADDON_VERSION,
    handler = self,
    type = "group",
    args = {
      show = {
        type = "execute",
        order = 1,
        name = "Show Notes",
        func = function() bn:ShowNotesWindow() end
      },
      mini = {
        type = "execute",
        order = 2,
        hidden = true,
        cmdHidden = false,
        name = "Show Mini Button",
        func = function() bn:ShowMiniButton() end
      },
      edit = {
        type = "execute",
        order = 3,
        hidden = true,
        cmdHidden = false,
        name = "Edit",
        desc = "Edit the current Note",
        func = function() bn:EditCurrentNote() end
      },
      hide = {
        type = "execute",
        order = 4,
        name = "Hide all",
        desc = "Hides both the Notes window and the Mini Button",
        func = function() bn:HideAll() end
      },
      help = {
        type = "execute",
        order = 99,
        name = "Help",
        hidden = true,
        func = function()
          configCmd.HandleCommand(bn, ADDON_CMD, ADDON_NAME, "")
        end
      }
    }
  }

  config:RegisterOptionsTable(ADDON_NAME, options)
  self.OptionsPanel = configDlg:AddToBlizOptions(ADDON_NAME, DISPLAY_NAME)
  
end

function bn:InitNotesWindow()
	local window = gui:Create("Window")
	window:SetTitle(DISPLAY_NAME)
	window:SetLayout("List")
  window:SetStatusTable(self.Status.NotesWindow)
  window:SetWidth(250)
  window:SetHeight(400)
	--window:Hide()
	self.NotesWindow = window

  window.frame:SetMinResize(250, 400)
	window.frame:SetFrameStrata("HIGH")
  window.frame:SetFrameLevel(1)
  
  local cats = gui:Create("Dropdown");
  cats:SetFullWidth(true)
  window:AddChild(cats);
  self.CategoryDropdown = cats

  local notes = gui:Create("Dropdown")
  notes:SetFullWidth(true)
  window:AddChild(notes)
  self.NotesDropdown = notes

  --[[
  local grp = CreateFrame("Frame", nil, window.frame)
  local pos = window.frame:GetTop() - notes.frame:GetBottom() + 8
  grp:SetPoint("TOPLEFT", 12, -pos)
  grp:SetPoint("BOTTOMRIGHT", -12, 12)
  self:Print("ScrollFrame.top:", grp:GetTop())
  grp:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
  grp:SetBackdropColor( 0.616, 0.149, 0.114, 0.9)
  self.ScrollContainer = grp


  -- the message frame
  local MAX_LINES = 500

  local msg = CreateFrame("ScrollingMessageFrame", nil, grp)
  msg:SetPoint("TOPLEFT", 8, 0)
  msg:SetPoint("BOTTOMRIGHT", -24, 8)
  msg:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
  msg:SetMaxLines(MAX_LINES)
  msg:SetFading(false)
  msg:SetIndentedWordWrap(true)
  msg:SetFontObject(ChatFontNormal)
  msg:SetJustifyH("LEFT")
  
  
  -- the scroll bar
  local scroll = CreateFrame("ScrollFrame", nil, grp, "FauxScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 8, 0)
  scroll:SetPoint("BOTTOMRIGHT", -24, 8)

  function scroll:OnUpdate()
    local offset = FauxScrollFrame_GetOffset(self)
    msg:SetScrollOffset(offset)
    FauxScrollFrame_Update(self, MAX_LINES, 25, 12 )
  end

  function scroll:OnVerticalScroll(offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, 12, scroll.OnUpdate)
  end

  scroll:SetScript("OnVerticalScroll", scroll.OnVerticalScroll) 


  self.MessageFrame = msg
  self.ScrollFrame = scroll
  ]]

  --[[
  local html = CreateFrame("SimpleHtml", nil, window.frame)
  local pos = window.frame:GetTop() - notes.frame:GetBottom() + 8
  html:SetPoint("TOPLEFT", 12, -pos)
  --SimpleHtml needs a width to properly wrap text
  html:SetWidth(window.frame:GetWidth()-24) --, window.frame:GetHeight() - pos - 12)
  --html:SetPoint("BOTTOMRIGHT", -12, 12)
  html:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
  html:SetBackdropColor( 0.616, 0.149, 0.114, 0.9)

  local f, s = GameFontNormal:GetFont()
  html:SetFont(f, s)
  html:SetIndentedWordWrap("P", true)
  html:SetJustifyH("p", "LEFT")

  html:SetFont("h1", f, s*1.6)
  html:SetJustifyH("h1", "CENTER")

  html:SetFont("h2", f, s*1.4)
  html:SetJustifyH("h2", "LEFT")

  html:SetFont("h3", f, s*1.2)
  html:SetJustifyH("h2", "LEFT")


  self:Print("Html size:", html:GetWidth(), html:GetHeight())
  self.Html = html
--]]

---[[
  local grp = CreateFrame("Frame", nil, window.frame) 
  local pos = window.frame:GetTop() - notes.frame:GetBottom() + 8
  grp:SetPoint("TOPLEFT", 12, -pos)
  grp:SetPoint("BOTTOMRIGHT", -12, 12)
  --SetBorder(grp, 1, 1, 1, 0.5)
  --grp:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
  --grp:SetBackdropColor( 0.616, 0.149, 0.114, 0.9)

--scrollframe 
  scroll = CreateFrame("ScrollFrame", nil, grp) 
  scroll:SetPoint("TOPLEFT", 2, -2) 
  scroll:SetPoint("BOTTOMRIGHT", -18, 2) 
  SetBorder(scroll, 1, 0.5, 0.5, 0.5, 1)
  self.ScrollFrame = scroll 

  --scrollbar 
  scrollbar = CreateFrame("Slider", nil, scroll, "UIPanelScrollBarTemplate") 
  scrollbar:SetPoint("TOPRIGHT", grp, 0, -16) 
  scrollbar:SetPoint("BOTTOMRIGHT", grp, 0, 16) 
  scrollbar:SetMinMaxValues(1, MAX_LINES) 
  scrollbar:SetValueStep(1) 
  scrollbar.scrollStep = 1 
  scrollbar:SetValue(0) 
  scrollbar:SetWidth(16) 
  scrollbar:SetScript("OnValueChanged", function(f, value) scroll:SetVerticalScroll(value) end)
  scrollbar:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
  scrollbar:SetBackdropColor( 0.5, 0.5, 0.5, 0.5)
  scroll.Scrollbar = scrollbar 

  --content frame 
  
  local msg = CreateFrame("ScrollingMessageFrame", nil, scroll)
  msg:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM)
  msg:SetMaxLines(MAX_LINES)
  msg:SetFading(false)
  msg:SetIndentedWordWrap(true)
  msg:SetFontObject(ChatFontNormal)
  msg:SetJustifyH("LEFT")
  self.MessageFrame = msg
  msg:SetOnDisplayRefreshedCallback(
    function()
      bn:ResizeMessageFrame()
    end
  )
  msg:SetSize(scroll:GetWidth(), 0)
  scroll:SetScrollChild(msg)

  self:ClearMessageFrame()

--]]
  --self:MakeSpecialFrame(window.frame, ADDON_GLOBAL_WINDOW)

  return self
end -- bn:InitNotesWindow

function bn:InitMiniButton()

end

function bn:InitEditWindow()

end

function bn:GetMessageFrameHeight()
  local height = 0
  local msg = self.MessageFrame
  local lc = 0
  local height = 0
  for n, v in pairs(msg.visibleLines) do
    if v:IsShown() then
      height = height + v:GetHeight()
      lc = lc + 1  
    end
  end
  height = ceil(height)
  self:Print("height", height, "lc", lc)
  return height, lc
end

function bn:ClearMessageFrame()
  local msg = self.MessageFrame
  msg:Clear()
  local f, s = msg:GetFont()
  msg:SetHeight(MAX_LINES * s)

  local sb = self.ScrollFrame.Scrollbar
  sb:SetMinMaxValues(1, 1) 
  sb:SetValue(0) 
end

function bn:ResizeMessageFrame()
  local msg = self.MessageFrame
  local prev = msg.PrevHeight
  local height, lc = self:GetMessageFrameHeight()
  if height ~= prev then
    msg.PrevHeight = height
    msg:SetHeight(height)
  end
 
  local sb = self.ScrollFrame.Scrollbar
  sb:SetMinMaxValues(1, max(1, lc)) 
  sb:SetValue(0) 
  
end



function bn:MakeSpecialFrame(frame, name)
  --makes window closeable with ESC
  -- 1) create a global "name" for the window
  _G[name] = frame
  -- 2) add the name to UISpecialFrames
  tinsert(UISpecialFrames, name)
end


function bn:TestScrollableWindow1()
    local backdrop = {
      bgFile = "Interface/BUTTONS/WHITE8X8",
      edgeFile = "Interface/GLUES/Common/Glue-Tooltip-Border",
      tile = true,
      edgeSize = 8,
      tileSize = 8,
      insets = {
          left = 5,
          right = 5,
          top = 5,
          bottom = 5,
      },
  }

  local listLen = 500

  local function ScrollList(self)
      local offset = FauxScrollFrame_GetOffset(self)
      self:GetParent().Messages:SetScrollOffset(offset)
      FauxScrollFrame_Update(self, listLen, 25, 12 )
  end

  local f = CreateFrame("Frame", "MyScrollMessageTextFrame", UIParent)
  f:SetSize(500, 400)
  f:SetPoint("CENTER")
  f:SetFrameStrata("BACKGROUND")
  f:SetBackdrop(backdrop)
  f:SetBackdropColor(0, 0, 0)

  f.Close = CreateFrame("Button", "$parentClose", f)
  f.Close:SetSize(24, 24)
  f.Close:SetPoint("TOPRIGHT")
  f.Close:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
  f.Close:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
  f.Close:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight", "ADD")
  f.Close:SetScript("OnClick", function(self)
      self:GetParent():Hide()
  end)

  f.Messages = CreateFrame("ScrollingMessageFrame", "$parentMessages", f)
  f.Messages:SetPoint("TOPLEFT", 15, -25)
  f.Messages:SetPoint("BOTTOMRIGHT", -30, 15)
  f.Messages:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
  f.Messages:SetMaxLines(listLen)
  f.Messages:SetFading(false)
  f.Messages:SetIndentedWordWrap(true)
  f.Messages:SetFontObject(ChatFontNormal)
  f.Messages:SetJustifyH("LEFT")

  f.Scroll = CreateFrame("ScrollFrame", "$parentScroll", f, "FauxScrollFrameTemplate")
  f.Scroll:SetPoint("TOPLEFT", 15, -25)
  f.Scroll:SetPoint("BOTTOMRIGHT", -30, 15)
  f.Scroll:SetScript("OnVerticalScroll",    function(self, offset)
      FauxScrollFrame_OnVerticalScroll(self, offset, 12, ScrollList)
  end)

  for i=1, listLen do
      local table = {
          "bfs fasjdf dsaf adsj fasjkf bsafjsaf bjs fasjkf bjsf basf badsjkf dsakfbhaskf asjkf asjkf skaf sak fsk fdsaf ",
          "kkl l fjds rewpwfrjpo foewf jjfwe fpwfevzv mcvn  qo fnaw[ffgngnerf we foiweffgorenfg[f fewfn sdskfn asdf sp ff",
          "q[ofkgbhp    i regp nIF N 'OFGRE  NG;G KG IGN ;EFPIREG REG  ZG;  ergregp esg gg-ero  rdf45540 4y   q8wffn ",
      }
      f.Messages:AddMessage(i.. " - "..table[random(1, 3)])
      FauxScrollFrame_Update(f.Scroll, i, 30, 12 )
  end

end -- bn:TestScrollableWindow

function bn:TestScrollableWindow2()
  --parent frame 
  local frame = CreateFrame("Frame", "MyFrame", UIParent) 
  frame:SetSize(150, 200) 
  frame:SetPoint("CENTER") 
  local texture = frame:CreateTexture() 
  texture:SetAllPoints() 
  texture:SetTexture(1,1,1,1) 
  frame.background = texture 

  --scrollframe 
  scrollframe = CreateFrame("ScrollFrame", nil, frame) 
  scrollframe:SetPoint("TOPLEFT", 10, -10) 
  scrollframe:SetPoint("BOTTOMRIGHT", -10, 10) 
  local texture = scrollframe:CreateTexture() 
  texture:SetAllPoints() 
  texture:SetTexture(.5,.5,.5,1) 
  frame.scrollframe = scrollframe 

  --scrollbar 
  scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
  scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16) 
  scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16) 
  scrollbar:SetMinMaxValues(1, 200) 
  scrollbar:SetValueStep(1) 
  scrollbar.scrollStep = 1 
  scrollbar:SetValue(0) 
  scrollbar:SetWidth(16) 
  scrollbar:SetScript("OnValueChanged", 
    function (self, value) 
      self:GetParent():SetVerticalScroll(value) 
    end
  ) 
  local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
  scrollbg:SetAllPoints(scrollbar) 
  scrollbg:SetTexture(0, 0, 0, 0.4) 
  frame.scrollbar = scrollbar 

  --content frame 
  local content = CreateFrame("Frame", nil, scrollframe) 
  content:SetSize(128, 128) 
  local texture = content:CreateTexture() 
  texture:SetAllPoints() 
  texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
  content.texture = texture 
  scrollframe.content = content 

  scrollframe:SetScrollChild(content)


end


function bn:CreateDialog(Options)
  local name = Options.Name
  if not StaticPopupDialogs[name] then
    local function OnAccept(ref)
      local Text = ref:GetParent().editBox:GetText()
      if Text ~= "" then Options.OnAccept(Text) end
    end
    StaticPopupDialogs[name] = {
      button1 = OKAY,
      button2 = CANCEL,
      OnAccept = OnAccept,
      EditBoxOnEnterPressed = function(ref)
        OnAccept(ref)
        ref:GetParent():Hide()
      end,
      text = Options.Text,
      hasEditBox = true,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = Options.PreferredIndex
    }
  end
end


function bn:EditCategoryName(Category)
  StaticPopup_Show(ADDON_CATEGORY_DIALOG)
end


function bn:EditNoteTitle()
  self:CreateDialog({Name=ADDON_PAGE_DIALOG })
  StaticPopup_Show(ADDON_PAGE_DIALOG)
end


function bn:OnNoteSelected(widget, event, value)
  self:Print("OnGroupSelected", widget)
  return self
end

function bn:OnCategoySelected(...)
  self:Print("OnCategoryTreeClick")
  return self
end

function bn:OnChatCommand(Text)
  if not Text or Text:trim() == "" then
    InterfaceOptionsFrame_OpenToCategory(self.OptionsPanel)
  else
    configCmd.HandleCommand(self, ADDON_CMD, ADDON_NAME, Text)
  end
end


function bn:ShowNotesWindow()
  self.NotesWindow:Show();
  self.MiniButton:Hide();
end

function bn:ShowMiniButton()
  self.MiniButton:Show();
  self.NotesWindow:Hide();
end

function bn:HideAll()
  self.NotesWindow:Hide()
  self.MiniButton:Hide()
end


function bn:EditCurrentNote()
  -- TODO: get the selectedd note, if any
  -- load it into the edit window
  self.EditWindow:Show()
end


function bn:LoadNotes()
  self.CategoryDropdown:SetList({
    k1 = "Category 1",
    k2 = "Category 2",
    k3 = "Category 3",
    k4 = "Category 4",
    k5 = "Category 5"
  })

  self.NotesDropdown:SetList({
    k1 = "Note 1",
    k2 = "Note 2",
    k3 = "Note 3",
    k4 = "Note 4",
    k5 = "Note 5"
  })

end







