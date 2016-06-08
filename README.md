# lua-resty-tags

A small DSL for building HTML documents

## Synopsis

```lua
do
    local tags = require "resty.tags"
    local html,   head,   script,   body,   h1,   p,   table,   tr,   th,   img,   br = tags (
         "html", "head", "script", "body", "h1", "p", "table", "tr", "th", "img", "br" )

    print(
        html { lang = "en" } (
            head (
                script { src = "main.js" }
            ),
            body (
                h1 { class = 'title "is" bigger than you think', "selected" } "Hello",
                h1 "perse",
                p (
                    "<Beautiful> & <Strange>",
                    br,
                    { koira = "k" },
                    "Weather"
                ),
                p "koira",
                img { src = "logo.png" },
                table(
                    tr (
                        th "'Headline'",
                        th "Headline 2",
                        th "Headline 3"
                    )
                )
            )
        )
    )
end

print()

do
    local tags = require "resty.tags"
    local html = tags(function()
        return html { lang = "en"} (
            head (
                script { src = "main.js" }
            ),
            body (
                h1 { class = 'title "is" bigger than you think', "selected" } "Hello",
                h1 "perse",
                p (
                    "<Beautiful> & <Strange>",
                    br,
                    { koira = "k" },
                    "Weather"
                ),
                p "koira",
                img { src = "logo.png" },
                table(
                    tr (
                        th "'Headline'",
                        th "Headline 2",
                        th "Headline 3"
                    )
                )
            )
        )
    end)
    print(html())
end
```

## License

`lua-resty-tags` uses two clause BSD license.

```
Copyright (c) 2016, Aapo Talvensaari
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES`
