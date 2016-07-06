# lua-resty-tags

A small DSL for building HTML documents

## Synopsis

##### Here we define some local functions:

```lua
local tags = require "resty.tags"
local html,   head,   script,   body,   h1,   p,   table,   tr,   th,   img,   br = tags(
     "html", "head", "script", "body", "h1", "p", "table", "tr", "th", "img", "br")

print(
    html { lang = "en" } (
        head (
            script { src = "main.js" }
        ),
        body (
            h1 { class = 'title "is" bigger than you think', "selected" } "Hello",
            h1 "Another Headline",
            p (
                "<Beautiful> & <Strange>",
                br,
                { Car = "Was Stolen" },
                "Weather"
            ),
            p "A Dog",
            img { src = "logo.png" },
            table(
                tr (
                    th { class = "selected" } "'Headline'",
                    th "Headline 2",
                    th "Headline 3"
                )
            )
        )
    )
)
```

##### The above will output HTML similar to:

```html
<html lang="en">
    <head>
        <script src="main.js"></script>
    </head>
    <body>
        <h1 class="title &quot;is&quot; bigger than you think" selected>
            Hello
        </h1>
        <h1>
            Another Headline
        </h1>
        <p>
            &lt;Beautiful&gt; &amp; &lt;Strange&gt;
            <br>
            table: 0x0004c370Weather
        </p>
        <p>
            A Dog
        </p>
        <img src="logo.png">
        <table>
            <tr>
                <th class="selected">
                    &#39;Headline&#39;
                </th>
                <th>
                    Headline 2
                </th>
                <th>
                    Headline 3
                </th>
            </tr>
        </table>
    </body>
</html>
```

##### Here we pass in a function:

```lua
local tags = require "resty.tags"
local html = tags(function()
    return html { lang = "en"} (
        head (
            script { src = "main.js" }
        ),
        body (
            h1 { class = 'title "is" bigger than you think', "selected" } "Hello",
            h1 "Another Headline",
            p (
                "<Beautiful> & <Strange>",
                br,
                { Car = "Was Stolen" },
                "Weather"
            ),
            p "A Dog",
            img { src = "logo.png" },
            table(
                tr (
                    th { class = "selected" } "'Headline'",
                    th "Headline 2",
                    th "Headline 3"
                )
            )
        )
    )
end)
print(html())
```

##### And the output is similar:

```html
<html lang="en">
    <head>
        <script src="main.js"></script>
    </head>
    <body>
        <h1 class="title &quot;is&quot; bigger than you think" selected>
            Hello
        </h1>
        <h1>
            Another Headline
        </h1>
        <p>
            &lt;Beautiful&gt; &amp; &lt;Strange&gt;
            <br>
            table: 0x00054ce0Weather
        </p>
        <p>
            A Dog
        </p>
        <img src="logo.png">
        <table>
            <tr>
                <th class="selected">
                    &#39;Headline&#39;
                </th>
                <th>
                    Headline 2
                </th>
                <th>
                    Headline 3
                </th>
            </tr>
        </table>
    </body>
</html>
```

##### In this example we create a table snippet:

```lua
local tags = require "resty.tags"
local table = tags(function(rows)
    local table = table
    for _, row in ipairs(rows) do
        local tr = tr
        for _, col in ipairs(row) do
            tr(td(col))
        end
        table(tr)
    end
    return table
end)

print(table{
    { "A", 1, 1 },
    { "B", 2, 2 },
    { "C", 3, 3 }
})
```

##### And here is the output of it:

```html
<table>
    <tr>
        <td>A</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>B</td>
        <td>2</td>
        <td>2</td>
    </tr>
    <tr>
        <td>C</td>
        <td>3</td>
        <td>3</td>
    </tr>
</table>
```

##### Some special treatment is done to `<script>` and `<style>` tags:

```lua
local tags = require "resty.tags"
local script = tags("script")
print(script[[
    function hello() {
        alert("<strong>Hello World</strong>");
    }
    hello();
]])
```

##### As you can see, we don't HTML encode the output:

```html
<script>
    function hello() {
        alert("<strong>Hello World</strong>");
    }
    hello();
</script>
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
