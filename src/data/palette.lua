-- The game's palette: greys on a near-black background, one amber accent (selection, highlights)
-- and one red (danger). Until there are real assets, shape and text carry the meaning.

local function rgb(r, g, b)
    return { r / 255, g / 255, b / 255 }
end

return {
    void   = rgb(10, 10, 14),
    space  = rgb(22, 22, 28),    -- panels
    dusk   = rgb(58, 58, 68),    -- panel frames
    slate  = rgb(74, 76, 86),
    ink    = rgb(16, 16, 20),    -- text on light surfaces
    grey   = rgb(132, 134, 142),
    silver = rgb(176, 178, 184),
    light  = rgb(218, 218, 214),
    cream  = rgb(236, 233, 224), -- main text
    white  = rgb(255, 255, 255),
    amber  = rgb(236, 182, 64),  -- accent
    red    = rgb(214, 70, 60),   -- danger
}
