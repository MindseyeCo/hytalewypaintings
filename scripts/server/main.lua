local Constants = require("scripts/shared/constants")
local PaintingStorage = require("scripts/server/painting_storage")

local ServerMain = {}

local function isWallAttachable(world, pos, facing)
  local supportPos = {
    x = pos.x - facing.x,
    y = pos.y - facing.y,
    z = pos.z - facing.z
  }
  local support = world:getBlock(supportPos)
  return support and support:isSolidFace(facing)
end

function ServerMain:onInitialize(server)
  self.server = server
  self.world = server:world()
  self.storage = PaintingStorage.new(self.world)

  server:registerNetworkChannel(Constants.NET_CHANNEL)

  server:on(Constants.NET_SET_IMAGE, function(player, payload)
    self:onSetImagePath(player, payload)
  end)

  server:on("block_interact", function(player, event)
    self:onBlockInteract(player, event)
  end)

  server:on("block_placed", function(_, event)
    self:onBlockPlaced(event)
  end)

  server:on("block_broken", function(_, event)
    self:onBlockBroken(event)
  end)

  server:on("player_joined", function(player)
    self:syncAllToPlayer(player)
  end)
end

function ServerMain:onBlockPlaced(event)
  if event.blockId ~= Constants.BLOCK_ID then
    return
  end

  if not isWallAttachable(self.world, event.position, event.facing) then
    self.world:breakBlock(event.position, true)
    return
  end

  self.storage:set(event.position, "")
  self.server:sendToAll(Constants.NET_CHANNEL, Constants.NET_SYNC_ONE, {
    x = event.position.x,
    y = event.position.y,
    z = event.position.z,
    imagePath = ""
  })
end

function ServerMain:onBlockBroken(event)
  if event.blockId ~= Constants.BLOCK_ID then
    return
  end

  self.storage:remove(event.position)
  self.server:sendToAll(Constants.NET_CHANNEL, Constants.NET_SYNC_ONE, {
    x = event.position.x,
    y = event.position.y,
    z = event.position.z,
    imagePath = nil
  })
end

function ServerMain:onBlockInteract(player, event)
  if event.blockId ~= Constants.BLOCK_ID then
    return
  end

  self.server:sendToPlayer(player, Constants.NET_CHANNEL, Constants.NET_OPEN_DIALOG, {
    x = event.position.x,
    y = event.position.y,
    z = event.position.z,
    currentPath = (self.storage:get(event.position) or {}).imagePath or ""
  })
end

function ServerMain:onSetImagePath(player, payload)
  if not payload or not payload.position then
    return
  end

  local pos = payload.position
  local block = self.world:getBlock(pos)
  if not block or block:id() ~= Constants.BLOCK_ID then
    return
  end

  local path = tostring(payload.path or "")
  if #path > Constants.IMAGE_PATH_MAX_LENGTH then
    player:sendSystemMessage("Image path is too long.")
    return
  end

  self.storage:set(pos, path)
  self.server:sendToAll(Constants.NET_CHANNEL, Constants.NET_SYNC_ONE, {
    x = pos.x,
    y = pos.y,
    z = pos.z,
    imagePath = path
  })
end

function ServerMain:syncAllToPlayer(player)
  self.server:sendToPlayer(player, Constants.NET_CHANNEL, Constants.NET_SYNC_BATCH, {
    paintings = self.storage:list()
  })
end

return ServerMain
