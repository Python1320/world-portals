
-- Setup variables
wp.matDummy = Material( "wp/black" )
wp.matView = CreateMaterial("WorldPortals", "Core_DX90", {["$basetexture"] = wp.matDummy:GetName(), ["$model"] = "1"})

wp.portals = {}
wp.drawing = true --default portals to not draw

-- Start drawing the portals
-- This prevents the game from crashing when loaded for the first time
hook.Add( "PostRender", "WorldPortals_StartRender", function()
	wp.drawing = false
	hook.Remove( "PostRender", "WorldPortals_StartRender" )
end )

function wp.shouldrender( portal )
	local camOrigin = GetViewEntity():EyePos()
	local exitPortal = portal:GetExit()
	local distance = camOrigin:Distance( portal:GetPos() )
	local disappearDist = portal:GetDisappearDist()
	
	if not IsValid( exitPortal ) then return false end
	
	local override, drawblack = hook.Call( "wp-shouldrender", GAMEMODE, portal, exitPortal )
	if override ~= nil then return override, drawblack end
	
	
	if not (disappearDist <= 0) and distance > disappearDist then return false end
	
	--don't render if the view is behind the portal
	local behind = wp.IsBehind( camOrigin, portal:GetPos(), portal:GetForward() )
	if behind then return false end
	
	return true
end


if not render.RealRenderView then
	render.RealRenderView = render.RenderView
end

function WorldPortals_RenderView(view)
	if not wp.drawing then
		wp.renderportals(view.origin or EyePos(), view.angles or EyeAngles())
	end
	return render.RealRenderView(view)
end

render.RenderView = WorldPortals_RenderView
hook.Add("InitPostEntity", "WorldPortals_RenderView", function()
	render.RenderView = WorldPortals_RenderView
end)

function wp.renderportals( plyOrigin, plyAngle )
	if ( wp.drawing ) then return end
	wp.portals = ents.FindByClass( "linked_portal_door" )
	if ( not wp.portals ) then return end

	-- Disable phys gun glow and beam
	local oldWepColor = LocalPlayer():GetWeaponColor()
	LocalPlayer():SetWeaponColor( Vector( 0, 0, 0 ) )
	
	for _, portal in pairs( wp.portals ) do
		local exitPortal = portal:GetExit()
		if IsValid(exitPortal) and wp.shouldrender(portal) then
			
			hook.Call( "wp-prerender", GAMEMODE, portal, exitPortal, plyOrigin )
			
			render.PushRenderTarget( portal:GetTexture() )
				render.Clear( 0, 0, 0, 255, true, true )

				local oldClip = render.EnableClipping( true )
				render.PushCustomClipPlane( exitPortal:GetForward(), exitPortal:GetForward():Dot( exitPortal:GetPos() - exitPortal:GetForward() * 0.5 ) )

				local camOrigin = wp.TransformPortalPos( plyOrigin, portal, exitPortal )
				local camAngle = wp.TransformPortalAngle( plyAngle, portal, exitPortal )

				wp.drawing = true
				wp.drawingent = portal
					render.RenderView( {
						x = 0,
						y = 0,
						w = ScrW(),
						h = ScrH(),
						origin = camOrigin,
						angles = camAngle,
						dopostprocess = false,
						drawhud = false,
						drawmonitors = false,
						drawviewmodel = false,
						bloomtone = true
						--zfar = 1500
					} )
				wp.drawing = false
				wp.drawingent = nil

				render.PopCustomClipPlane()
				render.EnableClipping( oldClip )
			render.PopRenderTarget()
			
			hook.Call( "wp-postrender", GAMEMODE, portal, exitPortal, plyOrigin )
		end
	end
	LocalPlayer():SetWeaponColor( oldWepColor )
end

hook.Add( "RenderScene", "WorldPortals_Render", function( plyOrigin, plyAngle )
	wp.renderportals(plyOrigin, plyAngle)
end )

--[[ causes player to see themselves in first person sometimes (particularly in multiplayer)
hook.Add( "ShouldDrawLocalPlayer", "WorldPortals_Render", function()
	if wp.drawing then
		return true
	end
end )
]]--
