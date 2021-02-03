
-- Checks if an object's position is behind a plane
function wp.IsBehind( object_pos, plane_pos, plane_forward )

	local vec = object_pos - plane_pos

	if plane_forward:Dot( vec ) < 0 then 
		return true
	end

	return false
end

-- Returns the distance to a plane
function wp.DistanceToPlane( object_pos, plane_pos, plane_forward )

	plane_forward:Normalize()
	local vec = object_pos - plane_pos

	return plane_forward:Dot( vec )
end

-- Transforms a position from one portal to another
function wp.TransformPortalPos( vec, portal, exit_portal )

	local l_vec = portal:WorldToLocal( vec )
	l_vec:Rotate( Angle(0, 180, 0) )
	local w_vec = exit_portal:LocalToWorld( l_vec )

	return w_vec

end

-- Transforms a vector from one portal to another
function wp.TransformPortalVector( vec, portal, exit_portal )

	local rotate_ang = exit_portal:GetAngles() - portal:GetAngles()
	rotate_ang = rotate_ang + Angle( 0, 180, 0 )
	vec:Rotate( rotate_ang )

	return vec

end

--Transforms an angle from one portal to another
function wp.TransformPortalAngle( angle, portal, exit_portal )

	local l_angle = portal:WorldToLocalAngles( angle )
	l_angle:RotateAroundAxis( Vector(0, 0, 1), 180)
	local w_angle = exit_portal:LocalToWorldAngles( l_angle )

	return w_angle

end

--Returns the first portal hit starting from a source position and given the direction of the vector
function wp.GetFirstPortalHit(source, direction)
	local portal = {
		Entity = nil,
		Distance = 0,
		HitPos = Vector(0,0,0)
	}
	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		if not IsValid(v:GetExit()) then continue end
		local hitPos = util.IntersectRayWithPlane(source, direction, v:GetPos(), v:GetForward())

		if isvector(hitPos) and direction:Dot( v:GetForward() ) < 0 then
			local dist = source:Distance(v:GetPos())

			if portal.Distance == 0 then
				portal.Distance = dist
			end

			if dist <= portal.Distance then
				portal.Entity = v
				portal.Distance = dist
				portal.HitPos = hitPos
			end
		end
	end

	return portal
end
