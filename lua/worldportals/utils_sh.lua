
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
