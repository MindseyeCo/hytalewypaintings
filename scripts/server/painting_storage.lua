local PaintingStorage = {}
PaintingStorage.__index = PaintingStorage

function PaintingStorage.new(world)
  local self = setmetatable({}, PaintingStorage)
  self.world = world
  self.data = world:persistentData("wyvern_paintings:state") or { paintings = {} }
  if not self.data.paintings then
    self.data.paintings = {}
  end
  return self
end

local function keyFromPos(pos)
  return string.format("%d,%d,%d", pos.x, pos.y, pos.z)
end

function PaintingStorage:get(pos)
  return self.data.paintings[keyFromPos(pos)]
end

function PaintingStorage:set(pos, imagePath)
  local key = keyFromPos(pos)
  self.data.paintings[key] = {
    x = pos.x,
    y = pos.y,
    z = pos.z,
    imagePath = imagePath
  }
  self.world:savePersistentData("wyvern_paintings:state", self.data)
end

function PaintingStorage:remove(pos)
  self.data.paintings[keyFromPos(pos)] = nil
  self.world:savePersistentData("wyvern_paintings:state", self.data)
end

function PaintingStorage:list()
  local out = {}
  for _, v in pairs(self.data.paintings) do
    out[#out + 1] = v
  end
  return out
end

return PaintingStorage
