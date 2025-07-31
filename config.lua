--[[
    RCO Animations - Configuration File
    ===================================
    
    This file contains all configurable options for the RCO Animations resource.
    You can modify these values to customize the behavior of the animation tester.
    
    IMPORTANT: After making changes to this file, restart the resource for changes to take effect.
]]

Config = {}

--[[
    PED CONFIGURATION
    =================
    Define which ped models to use for testing animations and scenarios.
]]

-- Male ped model to use for testing (default: U_M_M_ARMGENERALSTOREOWNER_01)
-- You can change this to any valid ped model hash or name
Config.MalePed = 'U_M_M_ARMGENERALSTOREOWNER_01'

-- Female ped model to use for testing (default: U_F_M_TUMGENERALSTOREOWNER_01)  
-- You can change this to any valid ped model hash or name
Config.FemalePed = 'U_F_M_TUMGENERALSTOREOWNER_01'

--[[
    COMMAND CONFIGURATION
    ====================
    Define the command that players will use to open the animation tester UI.
]]

-- Command name to open the animation tester (default: 'animtest')
-- Players will type /animtest in chat to open the interface
Config.Command = 'animtest'

--[[
    ADMIN CONFIGURATION
    ==================
    Define if only admins can use the animation tester (RSG Framework).
]]

-- Restrict usage to admins only (default: false)
-- Set to true if you want only admins to use the animation tester
Config.AdminOnly = true

-- Admin group name for RSG Framework (default: 'admin')
-- The group name that will be checked for admin permissions
Config.AdminGroup = 'admin'


