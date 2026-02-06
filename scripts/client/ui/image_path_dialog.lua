local Constants = require("scripts/shared/constants")

local ImagePathDialog = {}
ImagePathDialog.__index = ImagePathDialog

function ImagePathDialog.new(client)
  return setmetatable({
    client = client,
    panel = nil,
    activePos = nil
  }, ImagePathDialog)
end

function ImagePathDialog:open(payload)
  self.activePos = {
    x = payload.x,
    y = payload.y,
    z = payload.z
  }

  if self.panel then
    self.panel:destroy()
  end

  local ui = self.client:ui()
  self.panel = ui:createPanel({
    title = "Set Painting Image",
    width = 560,
    height = 170
  })

  self.panel:addLabel({
    x = 16,
    y = 24,
    text = "Enter an image path accessible to clients (e.g. assets/textures/custom/my_image.png):"
  })

  local input = self.panel:addTextInput({
    x = 16,
    y = 56,
    width = 528,
    text = payload.currentPath or ""
  })

  self.panel:addButton({
    x = 16,
    y = 108,
    text = "Save",
    onClick = function()
      self.client:sendToServer(Constants.NET_CHANNEL, Constants.NET_SET_IMAGE, {
        position = self.activePos,
        path = input:value()
      })
      self.panel:destroy()
      self.panel = nil
    end
  })

  self.panel:addButton({
    x = 120,
    y = 108,
    text = "Clear",
    onClick = function()
      self.client:sendToServer(Constants.NET_CHANNEL, Constants.NET_SET_IMAGE, {
        position = self.activePos,
        path = ""
      })
      self.panel:destroy()
      self.panel = nil
    end
  })

  self.panel:addButton({
    x = 224,
    y = 108,
    text = "Cancel",
    onClick = function()
      self.panel:destroy()
      self.panel = nil
    end
  })

  self.panel:show()
end

return ImagePathDialog
