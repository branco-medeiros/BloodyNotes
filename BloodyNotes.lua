local bn = LibStub("AceAddon-3.0"):NewAddon("BloodyNotes", "AceConsole-3.0")

local function onCommand(text)
  return bn:onCommand(text)
end

-- db structure 
--[[ 
  Options = {
    -- don't know what options we will need
  }
  Books = [
    {Id, Title, Pages[]}
  ]

  Pages = [
    { Id, Title, Text}
  ]
]]
function bn:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("BloodyNotesDB", {global={}})
end

function bn:onCommand(Text)
  self:Print(Text)
end

bn:RegisterChatCommand("bn", onCommand)
bn:RegisterChatCommand("bloodynotes", onCommand)
