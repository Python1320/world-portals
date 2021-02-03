
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

--detour traceline to account for portals

local _R = debug.getregistry()
local utilmeta = _R[2].util

local oldTraceLine = utilmeta.TraceLine

function utilmeta.TraceLine(data)
	local trace = oldTraceLine(data)

	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		if not IsValid(v:GetExit()) then continue end
		local hitPos = util.IntersectRayWithPlane(trace.StartPos, trace.Normal, v:GetPos(), v:GetForward())

		if isvector(hitPos) then
			local localHitPos = v:WorldToLocal(hitPos)
			local mins, maxs = v:GetCollisionBounds()
			if localHitPos.y > mins.y and localHitPos.y < maxs.y
				and localHitPos.z > mins.z and localHitPos.z < maxs.z then
				if trace.Normal:Dot( v:GetForward() ) < 0 then
					local angle = wp.TransformPortalAngle( trace.Normal:Angle(), v, v:GetExit() ):Forward()
					local startPos = wp.TransformPortalPos( hitPos, v, v:GetExit() )

					local length = data.start:Distance(data.endpos)
					local usedLength = trace.StartPos:Distance(trace.HitPos)

					local endPos = angle
					endPos:Mul(length + 32 - usedLength)
					endPos:Add(startPos)
					
					local tr = oldTraceLine( {
					   start = startPos,
					   endpos = endPos,
					   mask = trace.mask,
					   filter = trace.filter
					})
					return tr
				end
			end
		end
	end
	return trace
end