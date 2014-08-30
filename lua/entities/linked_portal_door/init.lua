
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

AccessorFunc( ENT, "partnername", "PartnerName" )

-- Collect properties
function ENT:KeyValue( key, value )

	if ( key == "partnername" ) then
		self:SetPartnerName( value )
		self:SetExit( ents.FindByName( value )[1] )

	elseif ( key == "width" ) then
		self:SetWidth( tonumber(value) *2 )

	elseif ( key == "height" ) then
		self:SetHeight( tonumber(value) *2 )

	elseif ( key == "DisappearDist" ) then
		self:SetDisappearDist( tonumber(value) )

	elseif ( key == "angles" ) then
		local args = value:Split( " " )

		for k, arg in pairs( args ) do
			args[k] = tonumber(arg)
		end

		self:SetAngles( Angle( unpack(args) ) )
	end
end

-- Teleportation
function ENT:Touch( ent )

	local vel_norm = ent:GetVelocity():GetNormalized()

	-- Object is moving towards the portal
	if vel_norm:Dot( self:GetForward() ) < 0 then

		local projected_distance = wp.DistanceToPlane( ent:EyePos() + ent:GetVelocity() * engine.TickInterval(), self:GetPos(), self:GetForward() )

		if projected_distance < 0 and hook.Call("wp-shouldtp",GAMEMODE,self,ent)~=false then

			local new_pos = wp.TransformPortalPos( ent:GetPos() + ent:GetVelocity() * engine.TickInterval(), self, self:GetExit() )
			local old_velocity = ent:GetVelocity()
			local new_velocity = old_velocity + Vector(0,0,0) --stupid pointers
			local new_angle = wp.TransformPortalAngle( ent:GetAngles(), self, self:GetExit() )

			new_velocity = wp.TransformPortalVector( new_velocity, self, self:GetExit() )

			ent:SetPos( new_pos )
			if ent:IsPlayer() then
				ent:SetEyeAngles( Angle(new_angle.p, new_angle.y, 0) ) -- fixes view being rotated, needs cool transition from new_angle.r to 0 like in portal
				ent:SetVelocity( new_velocity -old_velocity )
				wp.AlertPlayerOnTeleport( ent )
			else
				ent:SetAngles( new_angle )

				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then phys:SetVelocity( new_velocity ) end
			end
			
			ent:ForcePlayerDrop()
			
			if self.TPHook then
				self:TPHook(ent)
			end
		end
	end
end
