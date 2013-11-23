--[[
--Options:
--	config.server: IRC server to connect to
--	config.port: Port on the IRC server to connect to
-- 	config.servername: Friendly name for the IRC server.
--	config.nickname: Nickname to use on the IRC server. Must be one word.
--	config.username: Username to use on the IRC server. Must be one word.
--	config.realname: Realname to use on the IRC server. Can be multiple words.
--  config.autorun: *RAW* commands to send to the IRC server before joining channels. If this is :::SLEEP:::(sec)::: then we will wait <sec> seconds before continuing.
--	config.channels: Channel names to join.
--	config.cmdchar: Command character to use
]]
config.networks={
    freenode={
        server="irc.freenode.net",
        port=6667,
        nickname="MitchBot",
        username="MitchBot",
        realname="hi",
        autorun={
            "someshit"
        },
        channels={
        }
    },
    obsidian={
        server="irc.obsidianirc.net",
        port=6667,
        nickname="MitchBot",
        username="MitchBot",
        realname="hi",
        autorun={
					"someshit"
				},
        channels={
        }
   }
}
config.cmdchar="<"
