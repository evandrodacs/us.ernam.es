local gsub = string.gsub

local lapis = require("lapis")
local csrf = require("lapis.csrf")
local http = require("lapis.nginx.http")
local util = require("lapis.util")

local config = require("lapis.config").get()

local app = lapis.Application()

local services = require("services")

for index = 1, #services do 
  local service = services[index]
  services[service.name] = service
end

app:enable("etlua")
app.layout = "layout"

app:get("/", function(self)
  self.services = services
  self.csrf_token = csrf.generate_token(self)
  self.config = config
  self.escape = function(_, value)
    return util.escape(value)
  end
  return {
    render = "index"
  }
end)

-- /check?service=name&username=&csrf_token=
app:get("/check", function(self)
  local link = nil
  if csrf.validate_token(self) then 
    if services[self.params.service] then
      local service = services[self.params.service]
      local success = false
      if type(service.test) == "string" then 
        link = gsub(service.test, "%[username%]", ngx.escape_uri(self.params.username, 0))
        local _, status = http.simple(link)
        if status == 200 then
          success = true
        end
      elseif type(service.test) == "function" then 
        local available = false
        link, available = service.test(self.params.username)
        if type(link) == "string" and available then
          link = gsub(link, "%[username%]", ngx.escape_uri(self.params.username, 0))
          success = true
        end
      end
      if success then
        if type(service.link) == "string" then
          link = gsub(service.link, "%[link%]", link)
        end
        return {
          json = {
            service = service.name,
            available = true,
            link = link
          }
        }
      end
    end
  end 
  if type(link) ~= "string" then
    link = nil
  end
  return {
    json = {
      service = self.params.service,
      link = link or ""
    }
  } 
end)

return app
