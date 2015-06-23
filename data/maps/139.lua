local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World M6 (Three Eye Rock) --
---------------------------------------

function ocarina_wind_to_F5:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1511") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1511", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1510") then
      game:start_dialog("warp.to_F5", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(56, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end