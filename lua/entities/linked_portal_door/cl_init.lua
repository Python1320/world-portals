
include( "shared.lua" )

AccessorFunc( ENT, "texture", "Texture" )

-- Draw world portals
function ENT:Draw()
	local shouldrender,drawblack=wp.shouldrender(self)
	if not (shouldrender or drawblack) then return end

	local exitPortal = self:GetExit()
	if not IsValid(exitPortal) then return end
	hook.Call("wp-predraw", GAMEMODE, self, exitPortal)
	if shouldrender then
		wp.matView:SetTexture( "$basetexture", self:GetTexture() )
		render.SetMaterial( wp.matView )
	else
		render.SetMaterial( wp.matDummy )
	end
	render.DrawQuadEasy( self:GetPos() -( self:GetForward() * 5 ), self:GetForward(), self:GetWidth(), self:GetHeight(), Color(0,0,0), self:GetAngles().roll )
	hook.Call("wp-postdraw", GAMEMODE, self, exitPortal)
end
