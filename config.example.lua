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
]]-
config.server="asdf.asdf.asdf"
config.port=6697
config.servername="asdf"
config.nickname="AsdfBot"
config.username=config.nickname
config.realname="I'm a bot named "..config.nickname
config.autorun={
	"ns identify asdfasdfasdf asdfasdfasdf",
	":::SLEEP:::10:::", -- Sleeps for 10 seconds.
	"DO SHIT HERE"
}
config.channels={
	"#something",
}
config.cmdchar="<"
