local Teams = game:GetService("Teams")
local players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Team_Storage = ServerStorage:FindFirstChild("Team_Storage")

local Group = require(script.Parent.Parent.Parent.Configuration.Groups)

local AUTOTEAM = {}
AUTOTEAM.__index = AUTOTEAM

do
	function AUTOTEAM.new(player: Player)
		return setmetatable({
			plr = player,
			PLAYER_TEAM = nil,
			NEW_PLAYER_TEAM = nil,
			BYPASS = false,
			isOnSpecialTeam = false
		}, AUTOTEAM)
	end

	function AUTOTEAM:UpdateTeamCount(player: Player)
		for teamName, userConfig in pairs(Group.IndividualUser) do
			if table.find(userConfig.Usernames, player.Name) then
				self.PLAYER_TEAM = Team_Storage:FindFirstChild(teamName) or Teams:FindFirstChild(teamName)
				if self.PLAYER_TEAM then
					local PLAYER_COUNT = self.PLAYER_TEAM:GetAttribute("PLAYER_COUNT")
					self.PLAYER_TEAM:SetAttribute("PLAYER_COUNT", PLAYER_COUNT + 1)
				else
					warn("[TRICORE]: // Team \"" .. teamName .. "\" not found in Team_Storage.")
				end
				self.isOnSpecialTeam = true
			end
		end
		
		for teamName, teamConfig in pairs(Group.TeamRoles) do
			for _, roleID in ipairs(teamConfig.Roles) do
				if player:GetRankInGroup(Group.GroupId) == roleID and not self.isOnSpecialTeam then
					self.PLAYER_TEAM = Team_Storage:FindFirstChild(teamName) or Teams:FindFirstChild(teamName)
					if self.PLAYER_TEAM then
						local PLAYER_COUNT = self.PLAYER_TEAM:GetAttribute("PLAYER_COUNT")
						self.PLAYER_TEAM:SetAttribute("PLAYER_COUNT", PLAYER_COUNT + 1)
					else
						warn("[TRICORE]: // Team \"" .. teamName .. "\" not found in Team_Storage.")
					end
				end
			end
		end
		
		for subgroup_team_name, subgroup_id in pairs(Group.SubGroups) do
			if table.find(Group.DefaultTeam, self.PLAYER_TEAM.Name) then
				if player:IsInGroup(subgroup_id) and not self.isOnSpecialTeam then
					self.NEW_PLAYER_TEAM = Team_Storage:FindFirstChild(subgroup_team_name) or Teams:FindFirstChild(subgroup_team_name)
					if self.NEW_PLAYER_TEAM then
						local PLAYER_COUNT = self.PLAYER_TEAM:GetAttribute("PLAYER_COUNT")
						self.PLAYER_TEAM:SetAttribute("PLAYER_COUNT", PLAYER_COUNT - 1)
						local NEW_PLAYER_COUNT = self.NEW_PLAYER_TEAM:GetAttribute("PLAYER_COUNT")
						self.NEW_PLAYER_TEAM:SetAttribute("PLAYER_COUNT", NEW_PLAYER_COUNT + 1)
					else
						warn("[TRICORE]: // Team \"" .. subgroup_team_name .. "\" not found in Team_Storage.")
					end
				end
			end
		end
		
	end

	function AUTOTEAM:AssignPlayer(player: Player)
		for teamName, userConfig in pairs(Group.IndividualUser) do
			if table.find(userConfig.Usernames, player.Name) then
				player.Team = Teams:FindFirstChild(teamName)
				if not player.Team then
					warn("[TRICORE]: // Team \"" .. teamName .. "\" not found in Teams.")
				end
			end
		end
		
		for subgroup_team_name, subgroup_id in pairs(Group.SubGroups) do
			if table.find(Group.DefaultTeam, self.PLAYER_TEAM.Name) then
				if player:IsInGroup(subgroup_id) then
					player.Team = Teams:FindFirstChild(subgroup_team_name)
					if not player.Team then
						warn("[TRICORE]: // Team \"" .. subgroup_team_name .. "\" not found in Teams.")
					end
					self.BYPASS = true
				end
			end
		end
		
		for teamName, teamConfig in pairs(Group.TeamRoles) do
			for _, roleID in ipairs(teamConfig.Roles) do
				if player:GetRankInGroup(Group.GroupId) == roleID and not self.isOnSpecialTeam and not self.BYPASS then
					player.Team = Teams:FindFirstChild(teamName)
					if not player.Team then
						warn("[TRICORE]: // Team \"" .. teamName .. "\" not found in Teams.")
					end
				end
			end
		end
	end

	function AUTOTEAM:Update(isPlayerLeaving: boolean)
		if isPlayerLeaving then
			for _, team_obj in pairs(Teams:GetChildren()) do
				if self.plr.Team == team_obj then
					local PLAYER_COUNT = team_obj:GetAttribute("PLAYER_COUNT")
					team_obj:SetAttribute("PLAYER_COUNT", PLAYER_COUNT - 1)
				end
				local PLAYER_COUNT = team_obj:GetAttribute("PLAYER_COUNT")
				if PLAYER_COUNT <= 0 and not Group.ShowEmptyTeam then
					team_obj.Parent = Team_Storage
				end
			end
		else
			self:UpdateTeamCount(self.plr)
			for _, v in pairs(Team_Storage:GetChildren()) do
				local isTeamExists = Teams:FindFirstChild(v.Name)
				local PLAYER_COUNT = v:GetAttribute("PLAYER_COUNT")
				if isTeamExists == nil and PLAYER_COUNT >= 1 then
					v.Parent = Teams
				end
			end
			task.wait(1)
			self:AssignPlayer(self.plr)
			if Group.RefreshOnSpawn then
				self.plr.CharacterAdded:Wait()
				self.plr:LoadCharacter()
			end
		end
	end
end

return AUTOTEAM
