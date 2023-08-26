local Group = {
	
	GroupId = 00000000, -- MAIN GROUP
	
	RefreshOnSpawn = true,
	ShowEmptyTeam = false,
	
	DefaultTeam = {"Visitors"}, -- e.g. "ARMY PERSONNEL" if player is on the specified team the player will automatically switch to subgroup team

	TeamRoles = {
		["Visitors"] = { -- ["TEAM NAME"] = {ROLE_ID}
			Roles = {0, 1}
		},
		["High Commands"] = {
			Roles = {255, 254}
		}
	},

	SubGroups = {
		["1st Division"] = 00000000 -- ["TEAM NAME"] = GROUP_ID
	},
	
	IndividualUser = {
		["High Commands"] = {
			Usernames = {"Player 1", "Player 3"}
		},
		["Developers"] = {
			Usernames = {"lesterleal", "AvaxDev"}
		},
	}
}

return Group
