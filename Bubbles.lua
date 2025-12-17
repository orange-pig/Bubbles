local x, m, r, b 
local f = CreateFrame("Button", "Bubbles", UIParent)

f:ClearAllPoints()
f:SetWidth(100)
f:SetHeight(25)
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
f:SetFrameStrata("HIGH")

f.text = f:CreateFontString("Status", "LOW", "GameFontNormal")
f.text:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
f.text:ClearAllPoints()
f.text:SetAllPoints(f)
f.text:SetPoint("LEFT", 0, 0)
f.text:SetJustifyH("LEFT")
f.text:SetFontObject(GameFontWhite)

local lastUpdate = GetTime()
local lastXP = GetXPExhaustion() or 0
local lastTents = 0
local elapsed = 0
local tents = 0

local remaining = 0
local time = nil

f:SetScript("OnUpdate", function()
  local now = GetTime()
  local delta = now - lastUpdate
  local threshold = 1

  lastUpdate = now
  elapsed = elapsed + delta

  if elapsed >= threshold then
    elapsed = 0

    r = GetXPExhaustion() or 0
    local gained = r - lastXP
    lastXP = r

    m = UnitXPMax("player")
    local rate = (gained / m) * 100
    -- ty to https://github.com/Pizzahawaiii/PizzaWorldBuffs/blob/dbfef375451131c62d26db4c15cee5bae5b41133/src/tents.lua#L69
    tents = math.floor(rate / (0.13 * threshold))

    local p = 0.13 * math.max(tents, 1) / threshold
    remaining = (1 - r / (m * 1.5)) * (100 / p)

    local mins = math.floor(math.floor(remaining) / 60)
    local secs = math.floor(remaining) - (mins * 60)
    
    if secs < 10 then
      time = mins .. ":0" .. secs
    else
      time = mins .. ":" .. secs
    end

    if tents ~= lastTents then
      this = f
      f:GetScript("OnEvent")()
      lastTents = tents
    end
  end
end)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_UPDATE_RESTING")
f:SetScript("OnEvent", function()
  x = UnitXP("player")
  m = UnitXPMax("player")
  r = GetXPExhaustion() or 0

  if -1 == (r or -1) then
    b = 0
  else
    -- ty to https://forum.turtle-wow.org/viewtopic.php?p=65081#p65081
    b = math.floor(20 * r / m + 0.5)
  end

  local text
  if tents > 0 and tents < 10 then
    text = "|cfff58cba" .. b .. "|cffffffff Bubbles / |cfff58cba" .. tents
  else 
    text = "|cfff58cba" .. b .. "|cffffffff Bubbles"
  end
  
  f.text:SetText(text)
  f:SetWidth(f.text:GetStringWidth() + 10)
end)

f:SetMovable(true)
f:EnableMouse(true)
f:SetScript("OnMouseDown", function()
  this:StartMoving()
end)

f:SetScript("OnMouseUp", function()
  this:StopMovingOrSizing()
  this:SetUserPlaced(true)
end)

f:SetScript("OnEnter", function()
  GameTooltip:SetOwner(f, "ANCHOR_NONE")
  GameTooltip:ClearAllPoints()

  GameTooltip:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, (CONTAINER_OFFSET_Y or 0) + 13)
  GameTooltip:SetClampedToScreen(true)

  if -1 == (r or -1) then
    b = 0
  else
    b = math.floor(20 * r / m + 0.5)
  end
  
  GameTooltip:AddLine("|cfff58cbaBubbles (|cffffffff" .. b .. "|cfff58cba)")
  GameTooltip:AddLine("|cffaaaaaa最大双倍经验格数为 30，休息能获得的最多经验是当前等级总经验的 1.5 倍，一个帐篷休息满大约需要 13 分钟，多个帐篷可以叠加加快休息速度。", 0, 0, 0, true)
  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine("|cffffffff已获得的双倍经验", "|cffaaaaaa" .. r .. " XP")
  if r + x > m then
    GameTooltip:AddDoubleLine("|cffffffff累计到下级的双倍经验", "|cffaaaaaa" .. r + x - m .. " XP")
  end
  GameTooltip:AddDoubleLine("|cffffffff升级所需", "|cffaaaaaa" .. m - x .. " XP")
  GameTooltip:AddDoubleLine("|cffffffff当前经验", "|cffaaaaaa" .. math.floor(x / m * 100) .. "%")
  
  GameTooltip:AddDoubleLine("|cffffffff预计休息满时间", "|cfff58cba" .. time .. " |cffaaaaaa分钟")

  if tents > 0 then
    GameTooltip:AddDoubleLine("|cffffffff状态", "|cffaaaaaa从 " .. tents .. " 顶帐篷受益")
  end

  GameTooltip:Show()
end)

f:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

DEFAULT_CHAT_FRAME:AddMessage("|cfff58cbaBubbles |cffffffff1.1 loaded")
