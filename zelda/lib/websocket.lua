--[[
websocket client pure lua implement for love2d
by flaribbit

usage:
    local client = require("websocket").new("127.0.0.1", 5000)
    function client:onmessage(s) print(s) end
    function client:onopen() self:send("hello from love2d") end
    function client:onclose() print("closed") end

    function love.update()
        client:update()
    end
]]

local floor = math.floor

local MOD = 2^32
local MODM = MOD-1

local function memoize(f)
  local mt = {}
  local t = setmetatable({}, mt)
  function mt:__index(k)
    local v = f(k); t[k] = v
    return v
  end
  return t
end

local function make_bitop_uncached(t, m)
  local function bitop(a, b)
    local res,p = 0,1
    while a ~= 0 and b ~= 0 do
      local am, bm = a%m, b%m
      res = res + t[am][bm]*p
      a = (a - am) / m
      b = (b - bm) / m
      p = p*m
    end
    res = res + (a+b)*p
    return res
  end
  return bitop
end

local function make_bitop(t)
  local op1 = make_bitop_uncached(t,2^1)
  local op2 = memoize(function(a)
    return memoize(function(b)
      return op1(a, b)
    end)
  end)
  return make_bitop_uncached(op2, 2^(t.n or 1))
end

Mbxor = make_bitop {[0]={[0]=0,[1]=1},[1]={[0]=1,[1]=0}, n=4}
local bxor = Mbxor


function Mband(a,b) return ((a+b) - bxor(a,b))/2 end
local band = Mband

function Mbor(a,b)  return MODM - band(MODM - a, MODM - b) end
local bor = Mbor

local lshift, rshift -- forward declare

function Mrshift(a,disp) -- Lua5.2 insipred
  if disp < 0 then return lshift(a,-disp) end
  return floor(a % 2^32 / 2^disp)
end
rshift = Mrshift

function Mlshift(a,disp) -- Lua5.2 inspired
  if disp < 0 then return rshift(a,-disp) end 
  return (a * 2^disp) % 2^32
end
lshift = Mlshift



local socket = require "socket"
local band, bor, bxor = band, bor, bxor
local shl, shr = lshift, rshift

local OPCODE = {
    CONTINUE = 0,
    TEXT     = 1,
    BINARY   = 2,
    CLOSE    = 8,
    PING     = 9,
    PONG     = 10,
}

local STATUS = {
    CONNECTING = 0,
    OPEN       = 1,
    CLOSING    = 2,
    CLOSED     = 3,
    TCPOPENING = 4,
}

local _M = {
    OPCODE = OPCODE,
    STATUS = STATUS,
}
_M.__index = _M
function _M:onopen() end
function _M:onmessage(message) end
function _M:onerror(error) end
function _M:onclose(code, reason) end

function _M.new(host, port, path)
    local m = {
        url = {
            host = host,
            port = port,
            path = path or "/",
        },
        head = 0,
        _buffer = "",
        _remain = 0,
        _frame = "",
        status = STATUS.TCPOPENING,
        socket = socket.tcp(),
    }
    m.socket:settimeout(0)
    m.socket:connect(host, port)
    setmetatable(m, _M)
    return m
end

local mask_key = {1, 14, 5, 14}
local function send(sock, opcode, message)
    -- message type
    sock:send(string.char(bor(0x80, opcode)))

    -- empty message
    if not message then
        sock:send(string.char(0x80, unpack(mask_key)))
        return 0
    end

    -- message length
    local length = #message
    if length>65535 then
        sock:send(string.char(bor(127, 0x80),
            0, 0, 0, 0,
            band(shr(length, 24), 0xff),
            band(shr(length, 16), 0xff),
            band(shr(length, 8), 0xff),
            band(length, 0xff)))
    elseif length>125 then
        sock:send(string.char(bor(126, 0x80),
            band(shr(length, 8), 0xff),
            band(length, 0xff)))
    else
        sock:send(string.char(bor(length, 0x80)))
    end

    -- message
    sock:send(string.char(unpack(mask_key)))
    local msgbyte = {message:byte(1, length)}
    for i = 1, length do
        msgbyte[i] = bxor(msgbyte[i], mask_key[(i-1)%4+1])
    end
    --return sock:send(message)
    return sock:send(string.char(unpack(msgbyte)))
end

local function read(ws)
    --print("Starting to read...")
    local sock = ws.socket
    local res, err, part
    if ws._remain>0 then
        res, err, part = sock:receive(ws._remain)
        if part then
            -- still some bytes _remaining
            ws._buffer, ws._remain = ws._buffer..part, ws._remain-#part
            return nil, nil, "pending"
        else
            -- all parts recieved
            ws._buffer, ws._remain = ws._buffer..res, 0
            return ws._buffer, ws.head, nil
        end
    end
    -- byte 0-1
    res, err = sock:receive(2)
    if err then return res, nil, err end
    local head = res:sub(1, 1)
    -- Moved to _M:update
    -- local flag_FIN = res:byte()>=0x80
    -- local flag_MASK = res:byte(2)>=0x80
    local byte = res:sub(2, 2)
    --local length = band(byte, 0x7f)
    --if length==126 then
        --res = sock:receive(2)
        --local b1, b2 = res:byte(1, 2)
        --length = shl(b1, 8) + b2
    --elseif length==127 then
        --res = sock:receive(8)
        --local b5, b6, b7, b8 = res:byte(5, 8)
        --length = shl(b5, 24) + shl(b6, 16) + shl(b7, 8) + b8
    --end
    --if length==0 then return "", head, nil end
    --print(head)
    --print(byte)
    if not tonumber(head) then
        head = tonumber(head:byte(1,1)) - 87 
    end
    if not tonumber(byte) then
        byte = tonumber(byte:byte(1,1)) - 87
    end
    length = (tonumber(head) * 16) + tonumber(byte)
    --print(length)
    res, err, part = sock:receive(length+1)
    if part then
        -- incomplete frame
        ws.head = head
        ws._buffer, ws._remain = part, length-#part --length-#part
        return nil, nil, "pending"
    else
        -- complete frame
        return res, head, err
    end
end

function _M:send(message)
    --send(self.socket, OPCODE.TEXT, message)
    self.socket:send(message)
end

function _M:ping(message)
    send(self.socket, OPCODE.PING, message)
end

function _M:pong(message)
    send(self.socket, OPCODE.PONG, message)
end

local seckey = "osT3F7mvlojIvf3/8uIsJQ=="
function _M:update()
    local sock = self.socket
    if self.status==STATUS.TCPOPENING then
        local _, err = sock:connect("", 0)
        if err=="already connected" then
            local url = self.url
            sock:send(
"GET "..url.path.." HTTP/1.1\r\n"..
"Host: "..url.host..":"..url.port.."\r\n"..
"Connection: Upgrade\r\n"..
"Upgrade: websocket\r\n"..
"Sec-WebSocket-Version: 13\r\n"..
"Sec-WebSocket-Key: "..seckey.."\r\n\r\n")
            self.status = STATUS.CONNECTING
        elseif err=="Cannot assign requested address" then
            self:onerror("TCP connection failed.")
            self.status = STATUS.CLOSED
        end
    elseif self.status==STATUS.CONNECTING then
        local res = sock:receive("*l")
        if res then
            repeat res = sock:receive("*l") until res==""
            self:onopen()
            self.status = STATUS.OPEN
        end
    elseif self.status==STATUS.OPEN or self.status==STATUS.CLOSING then
        while true do
	    local res, head, err = read(self)
            if err=="timeout" then
                return
            elseif err=="pending" then
                return
            elseif err=="closed" then
                self.status = STATUS.CLOSED
                return
            end
            local opcode = 0 --band(head, 0x0f)
            local fin = 0 --band(head, 0x80)==0x80
            if opcode==8.1 then --opcode==OPCODE.CLOSE then
                if res~="" then
                    local code = shl(res:byte(1), 8) + res:byte(2)
                    self:onclose(code, res:sub(3))
                else
                    self:onclose(1005, "")
                end
                sock:close()
                self.status = STATUS.CLOSED
            --elseif opcode==OPCODE.PING then self:pong(res)
            elseif opcode==8.1 then --OPCODE.CONTINUE then
		self._frame = self._frame..res
                if fin then self:onmessage(self._frame) end
            else
                --if fin then self:onmessage(res) else self._frame = res end
		self:onmessage(res)
            end
        end
    end
end

function _M:close(code, message)
    if code and message then
        send(self.socket, OPCODE.CLOSE, string.char(shr(code, 8), band(code, 0xff))..message)
    else
        send(self.socket, OPCODE.CLOSE, nil)
    end
    self.status = STATUS.CLOSING
end

return _M
