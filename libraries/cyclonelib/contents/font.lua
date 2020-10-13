-- CycloneLib - contents/font.lua

-- Dependencies:
---- Nothing

local font = {}

-- Returns whether or not a given font is monospace. Optionally prints where it isn't if not.
font.checkMono = function(font, output)
	local is_monospace = true
	local sample_length = graphics.textWidth(" ", font)
	local char_length = 0
	for i=1,127 do
		char_length = graphics.textWidth(string.format("%c", i), font)
		if (char_length ~= sample_length) and (char_length ~= 0) then
			if output then
				print(
					"Inconsistency at character code "
					..tostring(i)
					.." which has the length "
					..tostring(char_length)
				)
			end
			is_monospace = false
		end
	end
	return is_monospace
end


--#########--
-- Exports --
--#########--

export("CycloneLib.font", font)