-- Leader ctrl+a
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>l", "client.config.reload")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>ctrl+w", "client.tab.close")
rex.bind("ctrl+a>w", "pane.close")

for i = 1, 9 do
    rex.bind("ctrl+a>" .. i, "client.tab.goto", { index = i })
end

rex.bind("ctrl+a>enter", "pane.copy_mode.enter")
