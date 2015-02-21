
hook.Add("EntityFireBullets", "WorldPortals_Bullets", function(ent,data)
	for k,v in pairs(ents.FindByClass("linked_portal_door")) do
		local hit,norm,fraction=util.IntersectRayWithOBB(data.Src, data.Dir*16000, v:GetPos(), v:GetAngles(), v:GetCollisionBounds())
		if hit then
			v:SetNotSolid(false)
			local tr=util.QuickTrace(data.Src,data.Dir*16000,{ent})
			v:SetNotSolid(true)
			if (tr.Entity==v or v:GetParent()==tr.Entity) and hook.Call("wp-bullet", GAMEMODE, v)~=false then
				data.Src=wp.TransformPortalPos( tr.HitPos, v, v:GetExit() )
				data.Dir=wp.TransformPortalVector( data.Dir, v, v:GetExit() )
				return true
			end
		end
	end
end)