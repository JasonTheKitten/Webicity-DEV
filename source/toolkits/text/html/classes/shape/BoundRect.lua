local BoundRect = {}
function BoundRect:__call(window, x, y, l, h)
    class.Rect.__call(self, x, y, l, h)
    
    self.window = window
    
    return self
end
function BoundRect:__add(aclass)
    return class.Rect.__add(self, aclass)
end

return BoundRect, function()
    BoundRect.cparents = {class.Rect}
end