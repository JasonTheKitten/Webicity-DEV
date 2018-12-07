local URL = "http://google.com/"

local loc = fs.combine(shell.getRunningProgram(), "../../source")
local l, h = term.getSize()

if not fs.getBackgroundColor then _G._ENV = _G end
local Browser, new = loadfile(
    fs.combine(loc, "browser.lua"), _G)()

local browser = new(Browser)("Webicity", loc)
local browserFrame = browser:CreateFrame(
    term, URL, l, h)