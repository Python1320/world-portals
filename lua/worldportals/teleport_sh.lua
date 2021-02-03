
hook.Add("EntityFireBullets", "WorldPortals_Bullets", function(ent,data)
	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		if not IsValid(v:GetExit()) then continue end

		local hitPos = util.IntersectRayWithPlane(data.Src, data.Dir, v:GetPos(), v:GetForward())

		if isvector(hitPos) then
			local localHitPos = v:WorldToLocal(hitPos)
			local mins, maxs = v:GetCollisionBounds()
			if localHitPos.y > mins.y and localHitPos.y < maxs.y
			and localHitPos.z > mins.z and localHitPos.z < maxs.z
			and hook.Call("wp-trace", GAMEMODE, v)~=false then
				data.Src=wp.TransformPortalPos( hitPos, v, v:GetExit() )
							
				local angle = wp.TransformPortalAngle( data.Dir:Angle(), v, v:GetExit() )
				data.Dir=angle:Forward()

				local filter =  hook.Call("wp-tracefilter", GAMEMODE, v)
				if IsValid(filter) then
					data.IgnoreEntity = filter
				end
				
				return true
			end
		end
	end
end)

if not util.RealTraceLine then
	util.RealTraceLine = util.TraceLine
end
function WorldPortals_TraceLine(data)
	local trace = util.RealTraceLine(data)

	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		if not (v.GetExit and IsValid(v:GetExit())) then continue end
		local hitPos = util.IntersectRayWithPlane(trace.StartPos, trace.Normal, v:GetPos(), v:GetForward())

		if isvector(hitPos) then
			local localHitPos = v:WorldToLocal(hitPos)
			local mins, maxs = v:GetCollisionBounds()
			if localHitPos.y > mins.y and localHitPos.y < maxs.y
			and localHitPos.z > mins.z and localHitPos.z < maxs.z
			and trace.Normal:Dot( v:GetForward() ) < 0
			and hook.Call("wp-trace", GAMEMODE, v)~=false then
				local angle = wp.TransformPortalAngle( trace.Normal:Angle(), v, v:GetExit() ):Forward()
				local startPos = wp.TransformPortalPos( hitPos, v, v:GetExit() )

				local length = data.start:Distance(data.endpos)
				local usedLength = trace.StartPos:Distance(trace.HitPos)

				local endPos = angle
				endPos:Mul(length + 32 - usedLength)
				endPos:Add(startPos)
				
				local filter = hook.Call("wp-tracefilter", GAMEMODE, v)
				if IsValid(filter) then
					if trace.filter then
						if type(trace.filter) == "table" then
							table.insert(trace.filter, filter)
						end
					else
						trace.filter = filter
					end
				end
				
				local tr = util.RealTraceLine({
					start = startPos,
					endpos = endPos,
					mask = trace.mask,
					filter = trace.filter
				})
				return tr
			end
		end
	end
	return trace
end

util.TraceLine = WorldPortals_TraceLine
hook.Add("InitPostEntity", "WorldPortals_TraceLine", function()
	util.TraceLine = WorldPortals_TraceLine
end)