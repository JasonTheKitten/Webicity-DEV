local Fluid = {}
function Fluid:__call(container, position, l, h, bo)
    self.length, self.height = l or 0, h or 0
    self.container, self.position = container, position
	self.browserObject = bo
    
    return self
end
function Fluid:flow(times)
	local curPos = new(class.Pointer)(self.position)
    local function incPosY()
        if curPos.x>self.browserObject.request.page.rl then
            curPos.x, curPos.y = self.container.x, curPos.y+1
            self.length, self.height = 0, self.height+1
        end
    end
    incPosY()
    for i=0, times-1 do
        curPos.x = curPos.x+1
        self.length = self.length+1
        incPosY() 
        i = i+1
    end
end
function Fluid:reset()
    self.length, self.height = 0, 0
end
function Fluid:__add()
    --return new(Fluid)(self.container, self.position)
end

return Fluid, function()
    Fluid.cparents = {class.Shape}
end