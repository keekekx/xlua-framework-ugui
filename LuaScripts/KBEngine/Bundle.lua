-----------------------------------------------------------------------------------------
--												bundle
-----------------------------------------------------------------------------------------*/
KBEngineLua.Bundle = {}

function KBEngineLua.Bundle:New()
    local me = {};
    setmetatable(me, self);
    self.__index = self;

    me.streamList = {};
    me.stream = MemoryStream();
    me.numMessage = 0;
    me.messageLength = 0;
    me.msgtype = nil;
    me._curMsgStreamIndex = 0;

    return me;
end

---------------------------------------------------------------------------------
function KBEngineLua.Bundle:newMessage(mt)
    self:fini(false);

    self.msgtype = mt;
    self.numMessage = self.numMessage + 1;
    print(">>>>msgtype.id:" .. type(self.msgtype))
    if self.msgtype == nil then LogError(">>>>>>>not found the msgtype") return end
    self:writeUint16(self.msgtype.id);

    if (self.msgtype.msglen == -1) then
        self:writeUint16(0);
        self.messageLength = 0;
    end

    self._curMsgStreamIndex = 0;
end

---------------------------------------------------------------------------------
function KBEngineLua.Bundle:writeMsgLength()

    if self.msgtype == nil or (self.msgtype.msglen ~= -1) then
        return ;
    end

    local stream = self.stream;
    if (self._curMsgStreamIndex > 0) then
        stream = self.streamList[#self.streamList - self._curMsgStreamIndex];
    end

    local tempByte1 = self.messageLength & 0xff
    local tempByte2 = (self.messageLength >> 8) & 0xff

    stream:SetDataWithIndex(2, tempByte1)
    stream:SetDataWithIndex(3, tempByte2)

    LogInfo("..>>>>>>" .. KBELuaUtil.GetByteFromBytes(stream.data, 2))

    -- log(">>>undle:writeMsgLength:.."..string.len( stream.data ) )

end

---------------------------------------------------------------------------------
function KBEngineLua.Bundle:fini(issend)
    if (self.numMessage > 0) then
        self:writeMsgLength();
        table.insert(self.streamList, self.stream);
        self.stream = MemoryStream();
    end

    if issend then
        self.numMessage = 0;
        self.msgtype = nil;
    end

    self._curMsgStreamIndex = 0;
end

function KBEngineLua.Bundle:send()
    local networkInterface = KBEngineLua._networkInterface;

    self:fini(true);

    if (networkInterface:valid()) then
        for i = 1, #self.streamList, 1 do
            self.stream = self.streamList[i];
            networkInterface:send(self.stream);
        end
    else
        LogInfo("Bundle::send: networkInterface invalid!");
    end

    self.streamList = {};
    self.stream:clear();
end

function KBEngineLua.Bundle:checkStream(v)
    if (v > self.stream:space()) then
        table.insert(self.streamList, self.stream);
        self.stream = MemoryStream();
        self._curMsgStreamIndex = self._curMsgStreamIndex + 1;
    end
    self.messageLength = self.messageLength + v;
end

---------------------------------------------------------------------------------
function KBEngineLua.Bundle:writeInt8(v)
    self:checkStream(1);
    self.stream:writeInt8(v);
end

function KBEngineLua.Bundle:writeInt16(v)
    self:checkStream(2);
    self.stream:writeInt16(v);
end

function KBEngineLua.Bundle:writeInt32(v)
    self:checkStream(4);
    self.stream:writeInt32(v);
end

function KBEngineLua.Bundle:writeInt64(v)
    self:checkStream(8);
    self.stream:writeInt64(v);
end

function KBEngineLua.Bundle:writeUint8(v)
    self:checkStream(1);
    self.stream:writeUint8(v);
end

function KBEngineLua.Bundle:writeUint16(v)
    self:checkStream(2);
    self.stream:writeUint16(v);
end

function KBEngineLua.Bundle:writeUint32(v)
    self:checkStream(4);
    self.stream:writeUint32(v);
end

function KBEngineLua.Bundle:writeUint64(v)
    self:checkStream(8);
    self.stream:writeUint64(v);
end

function KBEngineLua.Bundle:writeFloat(v)
    self:checkStream(4);
    self.stream:writeFloat(v);
end

function KBEngineLua.Bundle:writeDouble(v)
    self:checkStream(8);
    self.stream:writeDouble(v);
end

function KBEngineLua.Bundle:writeString(v)
    self:checkStream(string.len(v) + 1);
    self.stream:writeString(v);
end

function KBEngineLua.Bundle:writeBlob(v)
    self:checkStream(string.len(v) + 4);
    self.stream:writeBlob(v);
end