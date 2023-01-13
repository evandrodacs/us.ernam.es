local gsub = string.gsub
local concat = table.concat

math.randomseed(ngx.time()) -- for unsafe porpuses only

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

app:get("/", function(self)
  self.services = services
  self.csrf_token = csrf.generate_token(self)
  self.config = config.usernames
  self.escape = function(_, value)
    return util.escape(value)
  end
  return {
    render = "index"
  }
end)

-- /check?service=name&username=&csrf_token=
local function check(self)
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
      if success and link then
        if type(service.href) == "string" then
          link = gsub(service.href, "%[link%]", link)
          link = gsub(link, "%[username%]", ngx.escape_uri(self.params.username, 0))
        end
        return {
          json = {
            service = service.name,
            exists = true,
            link = link
          }
        }
      end
    end
  end 
  return {
    json = {
      service = self.params.service,
      link = type(link) == "string" and link or ""
    }
  } 
end
app:get("/check", check)

local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
function string_random(length)
  if length > 0 then
    return string.random(length - 1) .. charset:sub(math.random(1, #charset), 1)
  else
    return ""
  end
end


app:get("/testMode", function(self)
  self.params.csrf_token = csrf.generate_token(self)
  local results = {"<pre>", "Test mode:"}
  for index = 1, #services do
    local service = services[index]
    self.params.service = service.name
    results[#results + 1] = "\t\t\t"
    results[#results + 1] = service.name
    results[#results + 1] = ":<br/>"
    results[#results + 1] = "\t\t\t\t\t\tExisting username ("
    local username = service.pass or gsub(service.name, "[^a-zA-Z0-9]+", "")
    results[#results + 1] = username
    results[#results + 1] = "): "
    self.params.username = username
    local result = check(self)
    if result.json.exists then
      results[#results + 1] = "Test OK"
    else
      results[#results + 1] = "Test Not OK. Please, change the test function to fix it."
    end
    results[#results + 1] = "<br/>"
    results[#results + 1] = "\t\t\t\t\t\tNon-existent username ("
    username = service.fail or gsub(string_random(15), "^%d", "")
    results[#results + 1] = username
    results[#results + 1] = "): "
    result = check(self)
    if not result.json.exists then
      results[#results + 1] = "Test OK"
    else
      results[#results + 1] = "Test Not OK. Please, change the test function to fix it."
    end
    results[#results + 1] = "<br/>"
  end
  results[#results + 1] = "</pre>"
  self.testMode = concat(results, "<br/>")
  return {
    render = "index"
  }
end)

return app
