-- CycloneLib - contents/collision/resources/resources.lua

-- Dependencies:
---- Nothing

local resources = {}
resources.sprites = {}

-- A 2x2 sprite that is empty and transparent
resources.sprites.alpha = restre_spriteLoad("alpha", "alpha.png", 1, 1, 1)
resources.sprites.alpha_standard = restre_spriteLoad("alpha_standard", "alpha.png", 1, 0, 0)

-- A 2x2 sprite with nothing but white
resources.sprites.empty = restre_spriteLoad("empty", "empty.png", 1, 1, 1)
resources.sprites.empty_standard = restre_spriteLoad("empty_standard", "empty.png", 1, 0, 0)

return resources