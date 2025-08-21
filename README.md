# SM_Hidden Game Mode Custom
A Hidden Gamemode plugin for csgo sourcemod that i made for me and my freinds

## How the GameMode works
One (Or More) people are the hidden who are invisible and have a buffed movement speed and health, the hidden can ONLY use there knife and/or util + zeus.   
The people on the other team will be trying to fight this person with there guns and working together to kill the hidden

## Features
- Customisable config in start command [hidden team, hidden health, hidden movement speed, hidden alpha value]
- The Hidden will automatically drop the guns they pickup thats not there knife or util or zeus
- The Hidden can be completly invisible or be slightly visible with the alpha value.

## How to play (Commands)

### To start the game you will want to use the `h_start` command.    
`h_start <Team:[t/ct/auto]> <Health:[200]> <MovementSpeed:[1.5]> <AlphaValue:[15]>`  
The Auto in team will select the team with the least players to become the hidden team.   
The Health is the health the hidden players will be given. 100 is normal health and 200 is double that.   
The Movement speed is a multiplier so 1 would be normal movement speed.   
The Alpha Value ranges from 0 to 255.   

Example : `h_start auto 200 1.5 15`

### Once the h_start command has been entered, For the rest of the match the hidden gamemode will be active.
### At Any point you can enter `sm plugins load HiddenBetter` to stop the hidden gmmode and unhook all hooked functions.
### After the warmup ends you will need to do the hidden start command again.
