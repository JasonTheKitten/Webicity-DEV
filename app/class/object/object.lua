local ribbon = require()

local class = ribbon.require "class"

local object = ...

--
local Property = {} --TODO: Write property constructors
object.Property = Property

Property.cparents = {class.Class}
function Property:__call() end
--

--
local DataProperty = {}
object.DataProperty = DataProperty

DataProperty.cparents = {Property}
function DataProperty:__call() end
--

--
local AccessorProperty = {}
object.AccessorProperty = AccessorProperty

AccessorProperty.cparents = {Property}
function AccessorProperty:__call() end
--

--
local PropertyDescriptor = {}
object.PropertyDescriptor = PropertyDescriptor

PropertyDescriptor.cparents = {class.Class}
function PropertyDescriptor:__call() end
--


local Object = {}
object.Object = Object

local null = {}

local methods = {}
function methods.IsExtensible(O)
	return O:IsExtensible()
end
function methods.SameValue(x, y)
	return x==y --TODO
end
function methods.Call(F, V, argumentsList)
	argumentsList = argumentsList or {} --TODO: List
	if methods.IsCallable(F) == false then error("TypeError") end --TODO: Throw
	return F:Call(V, argumentsList)
end
function methods.IsCallable(argument)
	if not class.isA(argument, Object) return false end
	return argument.Call ~= nil
end
function methods.CreateDataProperty(O, P, V)
	local newDesc = class.new(PropertyDescriptor, V, true, true, true)
	return O:DefineOwnProperty(P, newDesc)
end
function methods.Get(O, P)
	return O:Get(P, O)
end
function methods.GetFunctionRealm(obj)
	if obj.Realm then return obj.Realm end
	--TODO
	
end


Object.cparents = {class.Class}
function Object:__call()
	self.properties = {}
end	

function Object:GetPrototypeOf()
	return methods.OrdinaryGetPrototypeOf(self)n 
end
function methods.OrdinaryGetPrototypeOf(O)
	return O.Prototype
end
function methods.IsAccessorDescriptor(Desc)
	if Desc == nil then return false end
	return not (Desc.Get == nil and Desc.set == nil)
end
function methods.IsDataDescriptor(Desc)
	if Desc == nil then return false end
	return not (Desc.Value == nil and Desc.Writable == nil)
end
function methods.IsGenericDescriptor(Desc)
	if Desc == nil then return false end
	return not (methods.IsAccessorDescriptor(Desc) or methods.IsDataDescriptor(Desc))
end

function Object:SetPrototypeOf(V)
	return methods.OrdinarySetPrototypeOf(self, V)
end
function methods.OrdinarySetPrototypeOf(O, V)
	if V==O.prototype then return true end
	if not O.Extensible then return false end
	local p, done = V, false
	while done==false do
		if p==null then
			done = true
		elseif p==O then
			return false
		else
			if  p.GetPrototypeOf~=Object.GetPrototypeOf then --TODO: ?
				done = true
			else
				p = p.Prototype
			end
		end
	end
	O.Prototype = v
	return true
end


function Object:IsExtensible()
	return methods.OrdinaryIsExtensible(self)
end
function methods.OrdinaryIsExtensible(O)
	return O.Extensible
end

function Object:PreventExtensions()
	return methods.OrdinaryPreventExtensions(self)
end
function methods.OrdinaryPreventExtensions(O)
	O.Extensible = false
	return true
end

function Object:GetOwnProperty(P)
	return methods.OrdinaryGetOwnProperty(self, P)
end
function methods.OrdinaryGetOwnProperty(O, P)
	if not O.properties[P] return nil end
	local D = class.new(PropertyDescriptor)
	local X = o.properties[P]
	if X:isA(DataProperty) then
		D.Value = X.Value
		D.Writable = X.Writable
	else
		D.Get = X.Get
		D.Set = X.Set
	end
	D.Enumerable = X.Enumerable
	D.Configurable = X.Configurable
	return D
end

function Object:DefineOwnProperty(P, Desc)
	return methods.OrdinaryDefineOwnProperty(self, P, Desc)
end
function methods.OrdinaryDefineOwnProperty(O, P, Desc)
	local current = O:GetOwnProperty(P)
	local extensible = methods.IsExtensible(O)
	return methods.ValidateAndApplyPropertyDescriptor(O, P, extensible, Desc, current)
end
function methods.IsCompatiblePropertyDescriptor(Extensible, Desc, Current)
	return methods.ValidateAndApplyPropertyDescriptor(nil, nil, Extensible, Desc, Current)
end
function methods.ValidateAndApplyPropertyDescriptor (O, P, extensible, Desc, current)
	if current == nil then
		if extensible==false then return false end
		if methods.IsGenericDescriptor(Desc) or methods.IsDataDescriptor(Desc) then
			if O~=nil then --I could probably merge the two instances of this into one, but whatever
				O.methods[P] = class.new(DataProperty, Desc.Value, Desc.Writable, Desc.Enumerable, Desc.Configurable)
			end
		else
			if O~=nil then --See comment above
				O.methods[P] = class.new(AccessorProperty, Desc.Get, Desc.Set, Desc.Enumerable, Desc.Configurable)
			end
		end
		return true
	end
	if not pairs({})(Desc) then return true end
	if current.Configurable == false then
		if Desc.Configurable then return true end
		if Desc.Enumerable~=nil and methods.SameValue(Desc.Enumerable, current.Enumerable) == false then return false end
	end
	if methods.IsGenericDescriptor(Desc) == true then
	elseif methods.SameValue(methods.IsDataDescriptor(current), methods.IsDataDescriptor(Desc)==false) then
		if current.Configurable == false then return false end
		if methods.IsDataDescriptor(current) == true then
			if O~=nil then --Once again
				local oprop = O.properties[P]
				O.properties[P] = class.new(AccessorProperty, nil, nil, oprop.Configurable, oprop.Enumerable)
			end
		else
			if O~=nil then -- ^
				local oprop = O.properties[P]
				O.properties[P] = class.new(DataProperty, nil, nil, oprop.Configurable, oprop.Enumerable)
			end
		end
	elseif methods.IsDataDescriptor(current) and methods.IsDataDescriptor(Desc) then
		if current.Configurable == false and current.Writable == false then
			if Desc.Writable==true then return false end
			return not (Desc.Value~=nil and methods.SameValue(Desc.Value, current.Value)==false)
		end
	else
		if current.Configurable == false then
			if Desc.Set~=nil and methods.SameValue(Desc.Set, current.Set) then return false end
			return not (Desc.Get~=nil and methods.SameValue(Desc.Get, current.Get)==false)
		end
		if O~=nil then
			for k, v in pairs(Desc) do O.properties[P] = v end
		end
		return true
	end
end

function Object:HasProperty(P)
	return methods.OrdinaryHasProperty(self, P)
end
function methods.OrdinaryHasProperty(O, P)
	local hasOwn = O:GetOwnProperty(p)
	if hasOwn~=nil then return true end
	local parent = O:GetPrototypeOf()
	if parent~=null then
		return parent:HasProperty(P)
	end
	return false
end

function Object:Get(P, Receiver)
	return methods.OrdinaryGet(self, P, receiver)
end
function methods.OrdinaryGet(O, P, Receiver)
	local desc = O:GetOwnProperty(P)
	if desc == nil then
		local parent = O:GetPrototypeOf()
		if parent == null then return nil end
		return parent:Get(P, Receiver)
	end
	if methods.IsDataDescriptor(desc) == true then return desc.Value end
	local getter = desc.Get
	if getter == nil then return nil end
	methods.Call(getter, Receiver)
end

function Object:Set(P, V, Receiver)
	return methods.OrdinarySet
end
function methods.OrdinarySet(O, P, V, Receiver)
	local ownDesc = O:GetOwnProperty(P)
	return methods.OrdinarySetWithOwnDescriptor(O, P, V, Receiver, ownDesc)
end
function methods.OrdinarySetWithOwnDescriptor(O, P, V, Receiver, ownDesc)
	if ownDesc == nil then
		local parent = O:GetPrototypeOf()
		if parent ~= null then
			return parent:Set(P, V, Receiver)
		else
			ownDesc = class.new(PropertyDescriptor, nil, true, true, true)
		end
	end
	if methods.IsDataDescriptor(ownDesc) == true then
		if ownDesc.Writable == false then return false end
		if not class.isA(Receiver, Object) then return false end
		local existingDescriptor = Receiver:GetOwnProperty(P)
		if existingDescriptor~=nil then
			if methods.IsAccessorDescriptor(existingDescriptor) == true then return false end
			if existingDescriptor.Writable == false then return false end
			local valueDesc = class.new(PropertyDescriptor, V)
			return Receiver:DefineOwnProperty(P, valueDesc)
		else
			return methods.CreateDataProperty(Receiver, P, V)
		end
		local setter = ownDesc.Set
		if setter == nil then return false end
		methods.Call(setter, Receiver, {V}) --TODO: List?
		return true
	end
end

function Object:Delete(P)
	return methods.OrdinaryDelete(self, P)
end
function methods.OrdinaryDelete(O, P)
	local desc = O:GetOwnProperty(P)
	if desc == nil then return true end
	if desc.Configurable == true then
		O.properties[P] = nil
		return true
	end
	return false
end

function Object:OwnPropertyKeys()
	return methods.OrdinaryOwnPropertyKeys(O)
end
function methods.OrdinaryOwnPropertyKeys(O)
	local keys = {} --List
	--TODO: Very disorganized
	for P in pairs(O.properties) do
		if type(P) == "number" then keys[#keys+1] = P end
	end
	for P in pairs(O.properties) do
		if type(P) == "string" then keys[#keys+1] = P end
	end
	for P in pairs(O.properties) do
		if type(P) == "table" then keys[#keys+1] = P end --TODO: Symbol
	end
	return keys
end

function methods.ObjectCreate(proto, internalSlotsList)
	internalSlotsList = internalSlotsList or {}
	local obj = class.new(Object, internalSlotsList)
	obj.Prototype = proto
	obj.Extensible = true
	return obj
end
function methods.OrdinaryCreateFromConstructor(constructor, intrinisicDefaultProto, internalSlotsList)
	local proto = methods.GetPrototypeFromConstructor(constructor, intrinisicDefaultProto)
	return methods.ObjectCreate(proto, internalSlotsList)
end
function methods.GetPrototypeFromConstructor(constructor, intrinisicDefaultProto)
	local proto = methods.Get(constructor, "prototype")
	if not class.isA(proto, Object) then
		local realm = methods.GetFunctionRealm(constructor)
		proto = realm.Intrinsics[intrinisicDefaultProto]=
	end
	return proto
end
function methods.RequireInternalSlot(O, P)
	if not class.isA(O, Object) then error("TypeError") end --TODO: Proper throw
	if not O[internalSlot] then error("TypeError") end --TODO: ?
end

----
--Function Objects
local FunctionObject = {}
object.FunctionObject = FunctionObject

FunctionObject.cparents = {Object}
function FunctionObject:Call(thisArgument, argumentsList)
	if self.IsClassConstructor == true then error("TypeError") end
	local callerContext = nil --TODO
	local calleeContext = methods.PrepareForOrdinaryCall(self, nil)
	methods.OrdinaryCallBindThis(self, calleeContext, thisArgument)
	local result = methods.OrdinaryCallEvaluateBody(self, argumentsList)
	--TODO
	if result.Type == "return" then return nil end --TODO
	--TODO
end