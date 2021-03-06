local ribbon = require()

local basecomponent = ribbon.require "component/basecomponent"
local class = ribbon.require "class"
local filesystem = ribbon.require "filesystem"
local statics = ribbon.require "statics"
local task = ribbon.require "task"
local util = ribbon.require "util"
local process = ribbon.require "process"
local debugger = ribbon.require("debugger")

local BlockComponent = ribbon.require("component/blockcomponent").BlockComponent
local Button = ribbon.require("component/button").Button
local HSpan = ribbon.require ("component/hspan").HSpan
local Label = ribbon.require("component/label").Label

local BrowserFrame = ribbon.reqpath("${CLASS}/component/browserframe").BrowserFrame
local BrowserInstance = ribbon.reqpath("${CLASS}/browser/browserinstance").BrowserInstance

local HTMLParser = ribbon.reqpath("${DIR}/plugin/content/html/parser").HTMLParser
local Buffer = ribbon.reqpath("${CLASS}/string/buffer").Buffer
local clock = os.clock()
HTMLParser.parse(class.new(Buffer, util.inf(ribbon.resolvePath("${DIR}/../testw.html"))))
debugger.log(os.clock()-clock)
if true then return end

local datapath, data = ribbon.resolvePath("${DATA}"), {}
if datapath~="${DATA}" then
	--if not filesystem.exists(ribbon.resolvePath("${DATA}")) then
	   --filesystem.makeDir(ribbon.resolvePath("${DATA}"))
	--end
	if not filesystem.exists(ribbon.resolvePath("${DATA}/plugins.json")) then
		util.outf(ribbon.resolvePath("${DATA}/plugins.json"), "[{\"plugin\":\"${DIR}/plugin\", \"internal\":true}]")
	end
	if not filesystem.exists(ribbon.resolvePath("${DATA}/settings.json")) then
		util.outf(ribbon.resolvePath("${DATA}/settings.json"), "[{\"newtab\":\"webicity://newtab\"}]")
	end
end

local COLORS = statics.get("colors")

local running = true

local function quit()
	running = false
end
local function quitButton(e)
	if e.button == 1 then quit() end
end

local menubar = class.new(HSpan):attribute(
	"id", menubar
)

local browserInstance = class.new(BrowserInstance)
browserInstance:loadplugins({{
	plugin = "${DIR}/plugin/",
	id = "webicity.web.core",
	name = "Webicity Core"
}})

local baseComponent = class.new(basecomponent.BaseComponent)
local viewport = baseComponent:getDefaultComponent():attribute(
	"id", "viewport",
	"width", {1},
	"height", {1},
	"children", {
		class.new(HSpan):attribute(
			"id", "titlebar",
			"width", {1, 0},
			"background-color", COLORS.BLACK,
			"text-color", COLORS.ORANGE,
			"children", {
				class.new(Button, nil, "="):attribute(
					"selected-text-color", COLORS.RED
				),
				class.new(Label, nil, " "),
				class.new(Label, nil, "Webicity Web Browser"):attribute(
					"id", "title",
					"text-color", COLORS.WHITE,
					"enable-wrap", false
				),
				class.new(Button, nil, "x"):attribute(
					"selected-text-color", COLORS.RED,
					"location", {1, -1, 0, 0},
					"onrelease", quitButton
				)
			}
		),
		class.new(BlockComponent):attribute(
			"id", "content-pane",
			"width", {1}, "height", {1, -1}
		)
	}
)

local contentpane = viewport:getComponentByID("content-pane")

class.new(BrowserFrame, contentpane, browserInstance):attribute(
	"width", {1}, "height", {1},
	"URL", "https://google.com/",
	"ondisplaytitleupdate", function(title)
		viewport:getComponentByID("title"):attribute("text", title)
	end
)

--Main
while running and browserInstance:continue() do
	baseComponent:renderUpdated()
	coroutine.yield()
end

baseComponent.context.clear(COLORS.BLACK)