-- Sprite sheets: horizontal strips exported from Libresprite to assets/sprites/<name>.png.
-- w, h = size of ONE frame; frames = how many. Generated from lista-de-assets.xlsx; edit by hand if a sheet changes.
-- border = nine-patch corner size, fps = animation speed when the sheet is an animation.

local defs = {
    -- UI
    ui_panel = { w = 24, h = 24, frames = 2, border = 8 },
    ui_panel_inset = { w = 24, h = 24, frames = 1, border = 8 },
    ui_cursor = { w = 10, h = 10, frames = 2, fps = 3 },
    ui_meter = { w = 12, h = 18, frames = 3 },
    ui_icon_skill = { w = 16, h = 16, frames = 3 },
    ui_icons_meter = { w = 16, h = 16, frames = 2 },
    ui_slot = { w = 12, h = 12, frames = 2 },
    ui_folder = { w = 16, h = 16, frames = 2 },
    ui_file = { w = 12, h = 14, frames = 2 },
    ui_arrows = { w = 8, h = 8, frames = 2 },
    ui_badge_new = { w = 28, h = 12, frames = 1 },
    ui_keys = { w = 16, h = 16, frames = 8 },
    -- Cartas
    card_front = { w = 100, h = 140, frames = 3 },
    card_back = { w = 100, h = 140, frames = 1 },
    card_art_kind = { w = 84, h = 44, frames = 3 },
    card_art_names = { w = 84, h = 44, frames = 18 },
    pack_closed = { w = 64, h = 80, frames = 1 },
    -- Delegados
    -- (alien_<id>_<state>: one animated strip per state, see the loop below)
    alien_icons = { w = 24, h = 24, frames = 3 },
    -- Mapa
    ship = { w = 16, h = 16, frames = 3 }, -- 1 engine off, 2-3 engine burning,
    map_station = { w = 64, h = 64, frames = 1 },
    map_thalassa = { w = 96, h = 96, frames = 1 },
    map_krag = { w = 96, h = 96, frames = 1 },
    map_hexa = { w = 96, h = 96, frames = 1 },
    map_asteroids = { w = 16, h = 16, frames = 4 },
    map_stars = { w = 128, h = 128, frames = 2 },
    map_marker = { w = 12, h = 12, frames = 2, fps = 3 },
    fx_trail = { w = 4, h = 4, frames = 3 },
    fx_bump = { w = 16, h = 16, frames = 3 },
    -- Fondos
    logo = { w = 320, h = 80, frames = 1 },
    bg_menu = { w = 640, h = 400, frames = 1 },
    bg_station = { w = 640, h = 400, frames = 1 },
    bg_court_tides = { w = 640, h = 400, frames = 1 },
    bg_court_blades = { w = 640, h = 400, frames = 1 },
    bg_court_many = { w = 640, h = 400, frames = 1 },
    bg_endings = { w = 640, h = 400, frames = 3 },
    ui_stamps = { w = 160, h = 48, frames = 3 },
    -- Efectos
    fx_play = { w = 32, h = 32, frames = 4 },
    fx_flip = { w = 100, h = 140, frames = 5 },
    -- Marca
    cover = { w = 1280, h = 720, frames = 1 },
    -- UI
    ui_intents = { w = 16, h = 16, frames = 4 },
    ui_rules = { w = 16, h = 16, frames = 4 },
}

-- Delegates: every state is its own animation of 128x128 frames. frames = "auto" means the
-- sheet may have any number of frames (its width / 128), so each animation can be as long as it needs.
local ALIENS = { "kelari", "vorn", "ixili" }
local STATES = {
    -- idle loops, picked by the delegate's mood
    calm = 6, wary = 6, tense = 8, furious = 10,
    -- played once the negotiation is over
    peace = 6, war = 8, walkout = 6, -- value = fps
}
for _, alien in ipairs(ALIENS) do
    for state, fps in pairs(STATES) do
        defs["alien_" .. alien .. "_" .. state] = { w = 128, h = 128, frames = "auto", fps = fps }
    end
end

return defs
