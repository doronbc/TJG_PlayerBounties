-- TJG_PlayerBounties by ThatJoshGuy a.k.a. TJGMan

init = function()
	SQL:Execute( "create table if not exists playerBounties (id INTEGER PRIMARY KEY, player VARCHAR, target VARCHAR, bounty INTEGER)" )
end


doChat = function(args)
	local msg = args.text
	local player = args.player
	
	-- only care about commands
	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmd_args = args.text:split( " " )
	local i = 0
	for n in string.gmatch(msg, "%S+") do
		i = i+1 
	end

	if cmd_args[1] == "/setbounty" then
		if i >= 3 then
			local bounty = tonumber(cmd_args[2])
			if bounty == nil then
				Chat:Send(player, "[BOUNTY] Invalid bounty amount!  /setbounty amount name", Color(200, 50, 200))
				return true
			end
			
			if bounty > player:GetMoney() then
				Chat:Send(player, "[BOUNTY] You cannot afford that bounty!.", Color(200, 50, 200))
				return true
			end

			local name = msg:gsub(cmd_args[1].." "..cmd_args[2].." ", "")
			
			if player:GetName():lower() == name:lower() then
				Chat:Send(player, "[BOUNTY] You cannot set a bounty on yourself!", Color(200, 50, 200))
				return true
			end	

			local qry = SQL:Query( "select id from playerBounties where player = (?) and target = (?)" )
			qry:Bind( 1, player:GetSteamId().id )
			qry:Bind( 2, name:lower() )
			local result = qry:Execute()

			if #result > 0 then
				Chat:Send(player, "[BOUNTY] You already set a bounty for "..name, Color(200, 50, 200))
				return true
			end	

			local found = false
			for p in Server:GetPlayers() do
				if p:GetName():lower() == name:lower() then
					local cmd = SQL:Command("insert or replace into playerBounties (player, bounty, target) values (?, ?, ?)" )
					cmd:Bind( 1, player:GetSteamId().id )
					cmd:Bind( 2, bounty )
					cmd:Bind( 3, p:GetName():lower() )
					cmd:Execute()
					player:SetMoney(player:GetMoney()-bounty)
					Chat:Broadcast("[BOUNTY] WANTED: "..p:GetName().." - REWARD $"..bounty, Color(200, 50, 200))
					Chat:Send(player, "You have set a $"..bounty.." bounty for "..p:GetName(), Color(200, 50, 200))
					found = true
				end
			end
			if not found then
				Chat:Send(player, "[BOUNTY] Target must be online to set bounty", Color(200, 50, 200)) 
			end
		else
			Chat:Send(player, "[BOUNTY] Invalid argument count!  /setbounty amount name", Color(200, 50, 200))
			return true
		end
	end

	if cmd_args[1] == "/delbounty" then
		if i < 2 then
			Chat:Send(player, "[BOUNTY] Invalid argument count!  /delbounty name", Color(200, 50, 200))
			return true
		end
		local name = msg:gsub(cmd_args[1].." ", "")
		local qry = SQL:Query( "select id, bounty from playerBounties where target = (?)" )
		qry:Bind( 1, name:lower() )
		local result = qry:Execute()

		if #result > 0 then
			local rowid = result[1].id
			local reward = result[1].bounty
			local cmd = SQL:Command("DELETE FROM playerBounties WHERE id=(?)" )
			cmd:Bind( 1, rowid  )
			cmd:Execute()
			Chat:Send(player, "[BOUNTY] You have removed your bounty for "..name, Color(200, 50, 200))
			player:SetMoney(player:GetMoney()+reward)
		else
			Chat:Send(player, "[BOUNTY] you do not have a bounty for "..name, Color(200, 50, 200))
		end
	end
end


doDeath = function(args)
	local qry = SQL:Query( "select id, bounty from playerBounties where target = (?)" )
	qry:Bind( 1, args.player:GetName():lower() )
	local result = qry:Execute()

	if #result > 0 then
		if args.killer ~= nil then
			local killer = args.killer
			local target = args.player
			for row in pairs(result) do
				local rowid = result[row].id
				local reward = tonumber(result[row].bounty)
				local cmd = SQL:Command("DELETE FROM playerBounties WHERE id=(?)" )
				cmd:Bind( 1, rowid  )
				cmd:Execute()
				Chat:Broadcast("[BOUNTY] "..killer:GetName().." has killed "..target:GetName().." for a bounty of $"..reward.."!", Color(200, 50, 200))
				killer:SetMoney(killer:GetMoney()+reward)
			end
		else
			return true
		end
	else
		return true
	end
end


Events:Subscribe("PlayerChat", doChat)
Events:Subscribe("PlayerDeath", doDeath)
init()