-- DONE: Create Main Window
-- TODO: Create Tree for categories and pages in Main Window
-- TODO: Create Editor frame in Main Window
-- TODO: Create buttons to add pages and catategories
-- TODO: Create popup menu in Main Window Tree for categories and pages to rename/delete/change category
-- TODO: Create button to save current text being edited
-- TODO: Create Handler to page click
-- TODO: Create Handler to page delete
-- TODO: Create Handler to page rename
-- TODO: Create Handler to page change category
-- TODO: Create Handler to category delete
-- TODO: Create Handler to category rename

-- TODO: Create Notes Window 
-- TODO: Create category dropdown in Notes Window
-- TODO: Creeate page dropdown in Notes Window
-- TODO: Create "hide" button in Notes Window
-- TODO: Create "edit" button in Notes Window
-- TODO: Create animation to hide Notes Windown and show ShowNotes button

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
local ADDON_GLOBAL_WINDOW = "BloodyNotes_Edit_Window"

local ADDON_VERSION = "0.0.1"
local bn = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local gui = LibStub("AceGUI-3.0");
local config = LibStub("AceConfig-3.0")
local configDlg = LibStub("AceConfigDialog-3.0")
local configCmd = LibStub("AceConfigCmd-3.0")


BLOODY = bn

local function OnCommand(text)
  return bn:OnCommand(text)
end

-- db structure 
--[[ 
  Options = {
    -- don't know what options we will need
  }
  Tree = {
    {id, value, text, icon, children}*
  }
]]
function bn:OnInitialize()
  self.Status = {Display = {}, EditWindow = {}, CategoryTree = {}, Editor = {}, ShowNotes = {}}

  local name = self:GetName()
  self.db = LibStub("AceDB-3.0"):New(ADDON_DB, {global={}})

  self:InitUI()
  self:InitChatCommands()
  self:InitOptions()

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
      edit = {
        type = "execute",
        order = 1,
        name = "Toggle Editor",
        desc = "Show/hide the Edit window",
        func = function() bn:OnToggleEditWindow() end
      },
      show = {
        type = "execute",
        order = 88,
        hidden = true,
        cmdHidden = false,
        name = "Show Editor",
        desc = "Show the Edit window",
        func = function() bn.EditWindow:Show() end
      },
      hide = {
        type = "execute",
        order = 87,
        hidden = true,
        cmdHidden = false,
        name = "Hide Editor",
        desc = "Hide the Edit window",
        func = function() bn.EditWindow:Hide() end
      },
      notes = {
        type = "execute",
        order = 2,
        name = "Toggle Notes",
        desc = "Show/hide the bloody Bloody Notes notes",
        func = function() bn:OnToggleNotesWindow() end
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

function bn:InitUI()
	local window = gui:Create("Window")
	window:SetTitle(DISPLAY_NAME)
	window:SetLayout("Flow")
  window:SetStatusTable(self.Status.EditWindow)
  window:SetWidth(600)
  window:SetHeight(400)
	window:Hide()
	self.EditWindow = window

  window.frame:SetMinResize(600, 400)
	window.frame:SetFrameStrata("HIGH")
  window.frame:SetFrameLevel(1)
  
  local tree = gui:Create("TreeGroup")
  tree:SetFullWidth(true)
  tree:SetFullHeight(true)
  tree:SetStatusTable(self.Status.CategoryTree)
  window:AddChild(tree)
  self.CategoryTree = tree

  tree:SetLayout("Flow")

  local pageName = gui:Create("EditBox")
  pageName:SetLabel("Title")
  pageName:SetFullWidth(true)
  pageName:DisableButton(true)
  tree:AddChild(pageName)

  local pageText = gui:Create("MultiLineEditBox")
  pageText:SetLabel("Bloody Note")
  pageText:SetFullWidth(true)
  pageText:DisableButton(true)
  pageText:SetNumLines(15)
  tree:AddChild(pageText)

  local buttons = gui:Create("SimpleGroup")
  buttons:SetLayout("Flow")
  buttons:SetFullWidth(true)
  buttons:SetHeight(38)
  tree:AddChild(buttons)


  local newCategory = gui:Create("Button")
  newCategory:SetText("Add Category")
  newCategory:SetRelativeWidth(0.35)
  newCategory:SetHeight(30)
  buttons:AddChild(newCategory)

  local newNote = gui:Create("Button")
  newNote:SetText("Add Note")
  newNote:SetRelativeWidth(0.25)
  newNote:SetHeight(30)
  buttons:AddChild(newNote)

  local spacer = gui:Create("Label")
  spacer:SetRelativeWidth(0.15)
  buttons:AddChild(spacer)

  local saveNote = gui:Create("Button")
  saveNote:SetText("Save Note")
  saveNote:SetRelativeWidth(0.25)
  saveNote:SetHeight(30)
  buttons:AddChild(saveNote)
  





  --self:MakeSpecialFrame(window.frame, ADDON_GLOBAL_WINDOW)

  return self
end -- bn:InitUI

function bn:MakeSpecialFrame(frame, name)
  --makes window closeable with ESC
  -- 1) create a global "name" for the window
  _G[name] = frame
  -- 2) add the name to UISpecialFrames
  tinsert(UISpecialFrames, name)
end


function bn:InitNotesFrame()
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

end -- bn:InitNotesFrame

function bn:OnGroupSelected(widget, event, value)
  self:Print("OnGroupSelected", widget)
  return self
end

function bn:OnCategoryTreeClick(...)
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


function bn:OnToggleEditWindow()
  if self.EditWindow:IsShown() then
    self.EditWindow:Hide()
  else
    self.EditWindow:Show()
  end
end

function bn:OnToggleNotesWindow()
  if self.NotesWindow:IsShown() then
    self.NotesWindow:Hide()
  else
    self.NotesWindow:Show()
  end
end


local function HandleMouseDown()

end

local function HandleShow()

end

local function HandleHide()

end

local function HandleMouseUp()

end

local function HandleMovingOrSizing()

end





