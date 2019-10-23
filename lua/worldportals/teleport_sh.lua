
hook.Add("EntityFireBullets", "WorldPortals_Bullets", function(ent,data)
	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		if not IsValid(v:GetExit()) then continue end

		local hitPos = util.IntersectRayWithPlane(data.Src, data.Dir, v:GetPos(), v:GetForward())

		if isvector(hitPos) then
			local localHitPos = v:WorldToLocal(hitPos)
			local mins, maxs = v:GetCollisionBounds()

			if localHitPos.y > mins.y and localHitPos.y < maxs.y
			and localHitPos.z > mins.z and localHitPos.z < maxs.z
			and hook.Call("wp-bullet", GAMEMODE, v)~=false then
				data.Src=wp.TransformPortalPos( hitPos, v, v:GetExit() )
							
				local angle = wp.TransformPortalAngle( data.Dir:Angle(), v, v:GetExit() )
				data.Dir=angle:Forward()
				
				return true
			end
		end
	end
end)