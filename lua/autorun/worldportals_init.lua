
--because worldportals is too long
wp = {}

-- Load required files
include( "worldportals/utils_sh.lua" )
include( "worldportals/teleport_sh.lua" )

if SERVER then

    include( "worldportals/render_sv.lua" )
    include( "worldportals/teleport_sv.lua" )

    AddCSLuaFile( "worldportals/utils_sh.lua" )
    AddCSLuaFile( "worldportals/render_cl.lua" )
    AddCSLuaFile( "worldportals/teleport_cl.lua" )
    AddCSLuaFile( "worldportals/teleport_sh.lua" )

else

    include( "worldportals/render_cl.lua" )
    include( "worldportals/teleport_cl.lua" )

end
