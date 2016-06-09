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
local _G = _G
local voids    = {
    area       = true,
    base       = true,
    br         = true,
    col        = true,
    command    = true,
    embed      = true,
    hr         = true,
    img        = true,
    input      = true,
    keygen     = true,
    link       = true,
    meta       = true,
    param      = true,
    source     = true,
    track      = true,
    wbr        = true
}
local elements = {
    a          = true,
    abbr       = true,
    address    = true,
    area       = true,
    article    = true,
    aside      = true,
    audio      = true,
    b          = true,
    base       = true,
    bdi        = true,
    bdo        = true,
    blockquote = true,
    body       = true,
    br         = true,
    button     = true,
    canvas     = true,
    caption    = true,
    cite       = true,
    code       = true,
    col        = true,
    colgroup   = true,
    command    = true,
    data       = true,
    datalist   = true,
    dd         = true,
    del        = true,
    details    = true,
    dfn        = true,
    div        = true,
    dl         = true,
    dt         = true,
    em         = true,
    embed      = true,
    fieldset   = true,
    figcaption = true,
    figure     = true,
    footer     = true,
    form       = true,
    h1         = true,
    h2         = true,
    h3         = true,
    h4         = true,
    h5         = true,
    h6         = true,
    head       = true,
    header     = true,
    hgroup     = true,
    hr         = true,
    html       = true,
    i          = true,
    iframe     = true,
    img        = true,
    input      = true,
    ins        = true,
    kbd        = true,
    keygen     = true,
    label      = true,
    legend     = true,
    li         = true,
    link       = true,
    main       = true,
    map        = true,
    mark       = true,
    menu       = true,
    meta       = true,
    meter      = true,
    nav        = true,
    noscript   = true,
    object     = true,
    ol         = true,
    optgroup   = true,
    option     = true,
    output     = true,
    p          = true,
    param      = true,
    pre        = true,
    progress   = true,
    q          = true,
    rb         = true,
    rp         = true,
    rt         = true,
    rtc        = true,
    ruby       = true,
    s          = true,
    samp       = true,
    script     = true,
    section    = true,
    select     = true,
    small      = true,
    source     = true,
    span       = true,
    strong     = true,
    style      = true,
    sub        = true,
    summary    = true,
    sup        = true,
    table      = true,
    tbody      = true,
    td         = true,
    template   = true,
    textarea   = true,
    tfoot      = true,
    th         = true,
    thead      = true,
    time       = true,
    title      = true,
    tr         = true,
    track      = true,
    u          = true,
    ul         = true,
    var        = true,
    video      = true,
    wbr        = true,
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
local function copyarray(s)
    local n = #s
    local d = {}
    for i=1, n do
        d[i] = s[i]
    end
    return d
end
local tag = {}
function tag.new(opts)
    return setmetatable(opts, tag)
end
function tag:__tostring()
    if #self.childs == 0 then
        if (voids[self.name]) then
            return concat{ "<", self.name, self.attributes or "", ">" }
        end
        return concat{ "<", self.name, self.attributes or "", "></", self.name, ">" }
    end
    return concat{ "<", self.name, self.attributes or "", ">", concat(self.childs), "</", self.name, ">" }
end
function tag:__call(...)
    local argc = select("#", ...)
    local childs, attributes = self.copy and {} or self.childs, self.attributes
    local c = #childs
    for i=1, argc do
        local argv = select(i, ...)
        if type(argv) == "table" then
            if getmetatable(argv) == tag then
                childs[c+i] = tostring(argv)
            elseif c == 0 and argc == 1 and not attributes then
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
                childs[c+i] = html(argv)
            end
        else
            childs[c+i] = html(argv)
        end
    end
    if self.copy then
        return tag.new{
            name       = self.name,
            childs     = copyarray(childs),
            attributes = attributes
        }
    end
    self.attributes = attributes
    return self
end
local mt = {}
function mt:__index(k)
    -- TODO: should we have special handling for table and select (the built-in Lua functions)?
    if elements[k] then
        return tag.new{
            name   = k,
            childs = {}
        }
    elseif _G[k] then
        return _G[k]
    else
        return tag.new{
            name   = k,
            childs = {}
        }
    end
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
            r[i] = tag.new{
                name   = v,
                childs = {},
                copy   = true
            }
        end
    end
    return unpack(r)
end