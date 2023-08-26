local AutoTeam = require(script.Parent.Modules.AutoTeam)
local Group = require(script.Parent.Configuration.Groups)

game.Players.PlayerAdded:Connect(function(player)
	local player_joining = AutoTeam.new(player)
	player_joining:Update(false)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local player_leaving = AutoTeam.new(player)
	player_leaving:Update(true)
end)
