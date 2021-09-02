if SERVER then
    util.AddNetworkString("vmatrix_scale_axis")
end

if CLIENT then
    surface.CreateFont("vmatrix_f1", {
        font = "Oswald",
        extended = false,
        size = 40,
        weight = 500,
    })

    surface.CreateFont("vmatrix_f2", {
        font = "Oswald",
        extended = false,
        size = 30,
        weight = 500,
    })
end

TOOL.Category = "VMatrix"
TOOL.Name = "VMatrix Scale Tool"
TOOL.Command = nil
TOOL.ConfigName = nil
TOOL.used = 0
TOOL.ClientConVar["x"] = 1
TOOL.ClientConVar["y"] = 1
TOOL.ClientConVar["z"] = 1

TOOL.Information = {
    {
        name = "left",
        stage = 0
    },
    {
        name = "right",
        stage = 0
    },
}

if SERVER then
    function TOOL:LeftClick()
        print(self:GetOwner():IsAdmin())
        if GetConVar("sv_vmatrix_scale_adminonly"):GetInt() == 0 then
            if self.used > CurTime() then return end
            self.used = CurTime() + 1
            local tracedata = {}
            tracedata.start = self:GetOwner():GetShootPos()
            tracedata.endpos = tracedata.start + (self:GetOwner():GetAimVector() * 15000)
            tracedata.filter = self:GetOwner()
            tracedata.mask = -1
            local trace = util.TraceLine(tracedata)

            if trace.Entity and trace.Entity:IsValid() then
                print(trace.Entity:IsPlayer())
                self:GetOwner():ChatPrint("Hit an Entity [" .. trace.Entity:GetClass() .. "]")
                self.vmatrix_entity = trace.Entity
                self.vmatrix_entity.x = self:GetClientNumber("x", 1)
                self.vmatrix_entity.y = self:GetClientNumber("y", 1)
                self.vmatrix_entity.z = self:GetClientNumber("z", 1)
                VMATRIX_Scale(self)
            else
                self:GetOwner():ChatPrint("Hit non-entity.")
            end

            if trace.Entity:IsVehicle() then
                self:GetOwner():ChatPrint("Hit a Vehicle! Please use this tools for players and props.")
            end

            return true
        elseif GetConVar("sv_vmatrix_scale_adminonly"):GetInt() == 1 then
            if not self:GetOwner():IsAdmin() then
                self:GetOwner():ChatPrint("You can't use this tool!")

                return false
            else
                if self.used > CurTime() then return end
                self.used = CurTime() + 1
                local tracedata = {}
                tracedata.start = self:GetOwner():GetShootPos()
                tracedata.endpos = tracedata.start + (self:GetOwner():GetAimVector() * 15000)
                tracedata.filter = self:GetOwner()
                tracedata.mask = -1
                local trace = util.TraceLine(tracedata)

                if trace.Entity and trace.Entity:IsValid() then
                    print(trace.Entity:IsPlayer())
                    self:GetOwner():ChatPrint("Hit an Entity [" .. trace.Entity:GetClass() .. "]")
                    self.vmatrix_entity = trace.Entity
                    self.vmatrix_entity.x = self:GetClientNumber("x", 1)
                    self.vmatrix_entity.y = self:GetClientNumber("y", 1)
                    self.vmatrix_entity.z = self:GetClientNumber("z", 1)
                    VMATRIX_Scale(self)
                else
                    self:GetOwner():ChatPrint("Hit non-entity.")
                end

                if trace.Entity:IsVehicle() then
                    self:GetOwner():ChatPrint("Hit a Vehicle! Please use this tools for players and props.")
                end

                return true
            end
        end
    end

    function VMATRIX_Scale(tool)
        if tool then
            local convars = {}

            convars[tool.vmatrix_entity:GetClass()] = {
                x = tool.vmatrix_entity.x,
                y = tool.vmatrix_entity.y,
                z = tool.vmatrix_entity.z
            }

            local scale = Vector(convars[tool.vmatrix_entity:GetClass()].x, convars[tool.vmatrix_entity:GetClass()].y, convars[tool.vmatrix_entity:GetClass()].z)
            local mat = Matrix()
            mat:SetScale(scale)
            net.Start("vmatrix_scale_axis")
            net.WriteMatrix(mat)
            net.WriteEntity(tool.vmatrix_entity)
            net.Broadcast()
        end
    end

    function VMATRIX_Refresh_Scale(tool)
        if tool then
            local scale = Vector(1, 1, 1)
            local mat = Matrix()
            mat:SetScale(scale)
            net.Start("vmatrix_scale_axis")
            net.WriteMatrix(mat)
            net.WriteEntity(tool.vmatrix_entity)
            net.Broadcast()
        end
    end

    function TOOL:RightClick(trace)
        if GetConVar("sv_vmatrix_scale_adminonly"):GetInt() == 0 then
            local scale = Vector(1, 1, 1)
            local mat = Matrix()
            mat:SetScale(scale)
            VMATRIX_Refresh_Scale(self)
            self:GetOwner():ChatPrint("Refreshed axises [" .. trace.Entity:GetClass() .. "]")

            return true
        elseif GetConVar("sv_vmatrix_scale_adminonly"):GetInt() == 1 then
            if not self:GetOwner():IsAdmin() then
                self:GetOwner():ChatPrint("You can't use this tool!")

                return false
            else
                local scale = Vector(1, 1, 1)
                local mat = Matrix()
                mat:SetScale(scale)
                VMATRIX_Refresh_Scale(self)
                self:GetOwner():ChatPrint("Refreshed axises [" .. trace.Entity:GetClass() .. "]")

                return true
            end
        end
    end
end

function TOOL:Reload()
end

function TOOL:Think()
end

if CLIENT then
    function TOOL:DrawToolScreen(width, height)
        surface.SetDrawColor(Color(0, 0, 0))
        surface.DrawRect(0, 0, width, height)
        draw.DrawText("VMATRIX SCALE \n TOOL", "vmatrix_f1", width / 2, height / 5, Color(200, 200, 200), 1)
        draw.DrawText("made by Etkin", "vmatrix_f1", width / 1.6, height / 1.2, Color(200, 200, 200), 1)
    end

    function TOOL.BuildCPanel(CPanel)
        local header = CPanel:AddControl("header", {
            description = "    VMATRIX SCALE TOOL"
        })

        header:SetFont("vmatrix_f1")
        header:SetColor(Color(255, 255, 255))

        header.Paint = function(self, w, h)
            surface.SetDrawColor(Color(41, 37, 37))
            surface.DrawRect(0, 0, w, h)
        end

        local info = CPanel:AddControl("label", {
            text = "Hit an entity and scale axises"
        })

        info:SetFont("vmatrix_f2")

        local slider_x = CPanel:AddControl("slider", {
            label = "X",
            command = "vmatrix_scale_x",
            min = 0,
            max = 10
        })

        slider_x:SetValue(1)
        slider_x:SetDecimals(1)

        local slider_y = CPanel:AddControl("slider", {
            label = "Y",
            command = "vmatrix_scale_y",
            min = 0,
            max = 10
        })

        slider_y:SetValue(1)
        slider_y:SetDecimals(1)

        local slider_z = CPanel:AddControl("slider", {
            label = "Z",
            command = "vmatrix_scale_z",
            min = 0,
            max = 10
        })

        slider_z:SetValue(1)
        slider_z:SetDecimals(1)

        local refresh_values = CPanel:AddControl("button", {
            label = "Refresh Values",
        })

        refresh_values.DoClick = function()
            slider_x:SetValue(1)
            slider_y:SetValue(1)
            slider_z:SetValue(1)
        end

        refresh_values:SetColor(Color(255, 255, 255))
        refresh_values:SetFont("vmatrix_f2")
        refresh_values:SetHeight(45)

        refresh_values.Paint = function(self, w, h)
            surface.SetDrawColor(Color(41, 37, 37))
            surface.DrawRect(0, 0, w, h)
        end
    end

    net.Receive("vmatrix_scale_axis", function()
        local mat = net.ReadMatrix()
        local entity = net.ReadEntity()
        entity:EnableMatrix("RenderMultiply", mat)
    end)

    language.Add("tool.vmatrix_scale.name", "VMatrix Scale Tool")
    language.Add("tool.vmatrix_scale.left", "Hit an Entity and scale axis")
    language.Add("tool.vmatrix_scale.right", "Refresh hitted entity axises")
    language.Add("tool.vmatrix_scale.desc", "For scale axises")
end