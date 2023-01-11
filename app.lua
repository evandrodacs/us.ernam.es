local lapis = require("lapis")
local app = lapis.Application()

app:get("/", function()
  return "Welcome to us.ernam.es"
end)

return app
