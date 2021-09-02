if SERVER then
    CreateConVar("sv_vmatrix_scale_adminonly", 0, FCVAR_NONE, "", 0, 1)
end

if CLIENT then
    hook.Add("PopulateToolMenu", "CustomMenuSettings", function()
        spawnmenu.AddToolMenuOption("Utilities", "Admin", "VMatrix Scale Tool", "#VMatrix Scale Tool", "", "", function(panel)
            panel:ClearControls()
            panel:CheckBox("Admin Only", "sv_vmatrix_scale_adminonly")
        end)
    end)
end