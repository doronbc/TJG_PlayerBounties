-- TJG_PlayerBounties by ThatJoshGuy a.k.a. TJGMan

ModulesLoad = function()
    Events:FireRegisteredEvent( "HelpAddItem",
        {
            name = "Bounties",
            text = 
                "Player Bounties allow you to set rewards for you enemies.\n \n" ..
                "When someone kills one of your bonties, they get the reward!\n \n" ..
                "Type /setbounty (reward) (name) to set the bounty.\n \n" ..
                "The reward is deducted form your money immediately.\n \n" ..
                "Type /delbounty (name) to cancel the bounty and get your money back.\n \n" ..
		  "You can set multiple bounties, and you can have several bounties on your head!\n \n"..
		  "Bounties are persistant, but a player must be online to set a bounty on them."
        } )
end

ModuleUnload = function()
    Events:FireRegisteredEvent( "HelpRemoveItem",
        {
            name = "Bounties"
        } )
end



Events:Subscribe( "ModuleLoad", ModulesLoad )
Events:Subscribe( "ModulesLoad", ModulesLoad )
Events:Subscribe( "ModuleUnload", ModuleUnload )