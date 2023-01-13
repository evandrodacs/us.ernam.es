local http = require("lapis.nginx.http")

local get = function(url, body, headers)
    return http.simple({
        url = url,
        method = "GET",
        headers = headers
    })
end

local post = function(url, body, headers)
    return http.simple({
        url = url,
        method = "POST",
        headers = headers,
        body = body
    })
end

return {

    --[[

    [position] = {
        name = "Media name",

        link = "Media url", -- (the favicon from this is user too)

        type = "media", -- default
        type = "domain",

        -- function test
        test = function(username)
            return "https://media.name/[username]", false -- (or nothing) not available
            return "https://media.name/[username]", true -- available (pass the username link)
        end,

        -- string test (if status returns ~ 200 suceeds)
        test = "https://media.name/[username]", -- [username] = path encoded, {username} = query encoded

        href = "[link]?ref=us.ernam.es", -- if have referral link, we can use it to monetize

        icon = "social.png", -- from static/icons/ folder

        --https://www.google.com/s2/favicons?domain=www.google.com

        pass = "telegram", -- an known username thats exists (defaults to media name: [a-Z][a-zA-Z0-9]*)
        fail = "SsFS0DFGFASGSDG", -- an known username thats not exists (defaults to a random string [a-zA-Z][a-zA-Z0-9]{14})
    },

    --]]

    {
        name = "Telegram",
        link = "https://telegram.org",
        type = "media",
        test = "https://t.me/[username]",
    },


}