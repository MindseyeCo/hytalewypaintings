local Constants = require("scripts/shared/constants")
local ImagePathDialog = require("scripts/client/ui/image_path_dialog")

local ClientMain = {}

local function posKey(pos)
  return string.format("%d,%d,%d", pos.x, pos.y, pos.z)
end

function ClientMain:onInitialize(client)
  self.client = client
  self.dialog = ImagePathDialog.new(client)
  self.paintings = {}

  client:onNetwork(Constants.NET_CHANNEL, Constants.NET_OPEN_DIALOG, function(payload)
    self.dialog:open(payload)
  end)

  client:onNetwork(Constants.NET_CHANNEL, Constants.NET_SYNC_ONE, function(payload)
    self:applySync(payload)
  end)

  client:onNetwork(Constants.NET_CHANNEL, Constants.NET_SYNC_BATCH, function(payload)
    self:applyBatch(payload)
  end)
end

function ClientMain:applyBatch(payload)
  self.paintings = {}
  for _, painting in ipairs(payload.paintings or {}) do
    self:applySync(painting)
  end
end

function ClientMain:applySync(payload)
  local key = posKey(payload)

  if payload.imagePath == nil then
    self.paintings[key] = nil
    self.client:rendering():clearBlockOverlayTexture({
      x = payload.x,
      y = payload.y,
      z = payload.z
    })
    return
  end

  self.paintings[key] = payload.imagePath
  self.client:rendering():setBlockOverlayTexture({
    x = payload.x,
    y = payload.y,
    z = payload.z
  }, payload.imagePath)
end

return ClientMain
