local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "off",
  num_workers = "1",

  usernames = {
    url = "https://us.ernam.es/"
  },

  tecnosfera = {
    name = "Tecnosfera",
    url = "https://tecnosfera.io"
    medias = {
        txt = true,
        pdf = true,
        jpg = true,
        jpeg = true,
        png = true,
        gif = true,
        bmp = true,
        zip = true,
        rar = true
    }
  }
})
