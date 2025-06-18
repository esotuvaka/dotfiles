-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "gruvbox",

    hl_override = {
        Comment = {
            -- italic = true,
            fg = "#FFA500", -- Bright orange
        },
        ["@comment"] = {
            -- italic = true,
            fg = "#FFA500", -- Bright orange
        },
    },
}

return M
