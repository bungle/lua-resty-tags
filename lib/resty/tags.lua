local type = type
local table = table
local unpack = table.unpack or unpack
local concat = table.concat
local setmetatable = setmetatable
local getmetatable = getmetatable
local tostring = tostring
local setfenv = setfenv
local select = select
local ipairs = ipairs
local pairs = pairs
local gsub = string.gsub
local ngx = ngx
local null = type(ngx) == "table" and ngx.null
local void = {
    area    = true,
    base    = true,
    br      = true,
    col     = true,
    command = true,
    embed   = true,
    hr      = true,
    img     = true,
    input   = true,
    keygen  = true,
    link    = true,
    meta    = true,
    param   = true,
    source  = true,
    track   = true,
    wbr     = true
}

local escape = {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["/"] = "&#47;"
}

local function output(s)
    if s == nil or s == null then return "" end
    return tostring(s)
end

local function html(s)
    if type(s) == "string" then
        return gsub(s, "[\">/<'&]", escape)
    end
    return output(s)
end

local function attr(s)
    if type(s) == "string" then
        return gsub(s, '["><&]', escape)
    end
    return output(s)
end

local tag = {}

function tag.new(opts)
    if type(opts) == "table" then
        return setmetatable(opts, tag)
    else
        return setmetatable({ name = opts, childs = {} }, tag)
    end
end

function tag:__tostring()
    if #self.childs == 0 then
        if (void[self.name]) then
            return concat{ "<", self.name, self.attributes or "", ">" }
        else
            return concat{ "<", self.name, self.attributes or "", "></", self.name, ">" }
        end
    else
        return concat{ "<", self.name, self.attributes or "", ">", concat(self.childs), "</", self.name, ">" }
    end
end

function tag:__call(...)
    local argc = select("#", ...)
    local childs, attributes = {}, self.attributes
    for i=1, argc do
        local argv = select(i, ...)
        if type(argv) == "table" then
            if getmetatable(argv) == tag then
                childs[i] = tostring(argv)
            elseif argc == 1 and not attributes then
                local a = {}
                local i = 1
                for k, v in pairs(argv) do
                    if type(k) ~= "number" then
                        a[i]=" "
                        a[i+1] = k
                        a[i+2] = '="'
                        a[i+3] = attr(v)
                        a[i+4] = '"'
                        i=i+5
                    end
                end
                for _, v in ipairs(argv) do
                    a[i]=" "
                    a[i+1]=attr(v)
                    i=i+2
                end
                attributes = concat(a)
            else
                childs[i] = html(argv)
            end
        else
            childs[i] = html(argv)
        end
    end
    return tag.new{
        name = self.name,
        childs = childs,
        attributes = attributes
    }
end

local mt = {}

function mt:__index(k)
    return tag.new(k)
end

local context = setmetatable({}, mt)

return function(...)
    local argc = select("#", ...)
    local r = {}
    for i=1, argc do
        local v = select(i, ...)
        if type(v) == "function" then
            r[i] = setfenv(v, context)
        else
            r[i] = tag.new(v)
        end
    end
    return unpack(r)
end