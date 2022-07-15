
ENT.Type                = "anim"
ENT.RenderGroup         = RENDERGROUP_BOTH -- fixes translucent stuff rendering behind the portal
ENT.Spawnable           = false
ENT.AdminOnly           = false
ENT.Editable            = false

function ENT:SetupBounds(w, h, t)
    local width = w or self:GetWidth()
    local height = h or self:GetHeight()
    local thickness = t or self:GetThickness()

    self.RenderMin = Vector(-(5 + thickness), -width / 2, -height / 2)
    self.RenderMax = Vector(- 5             ,  width / 2,  height / 2)

    self:SetCollisionBounds( self.RenderMin, self.RenderMax )

    if CLIENT then
        self:SetRenderBounds( self.RenderMin, self.RenderMax )
    end
end

function ENT:Initialize()
    if SERVER then
        self:SetTrigger( true )
    end

    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_OBB )
    self:SetNotSolid( true )
    self:SetCollisionGroup( COLLISION_GROUP_WORLD )

    self:DrawShadow( false )

    self:SetupBounds()
end

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "Exit" )
    self:NetworkVar( "Int", 1, "Width" )
    self:NetworkVar( "Int", 2, "Height" )
    self:NetworkVar( "Int", 3, "DisappearDist" )
    self:NetworkVar( "Int", 4, "Thickness" )
    self:NetworkVar( "String", 0, "CustomLink" )

    self:NetworkVar( "Vector", 0, "ExitPosOffset" )
    self:NetworkVar( "Angle", 0, "ExitAngOffset" )

    self:NetworkVarNotify("Width", function(ent, name, old, new) ent:SetupBounds(new) end)
    self:NetworkVarNotify("Height", function(ent, name, old, new) ent:SetupBounds(nil, new) end)
    self:NetworkVarNotify("Thickness", function(ent, name, old, new) ent:SetupBounds(nil, nil, new) end)
end
