local map = ...
local game = map:get_game()

----------------------------------------------------------------
-- Outside World E7 (Kakariko City) - Houses, Bomb Shop, etc. --
----------------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_ildus)

  -- Opening doors
  local entrance_names = { "house_1", "house_3", "house_4" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() and game:get_time_of_day() == "day" then
        tile:set_enabled(false)
        sol.audio.play_sound("door_open")
      elseif hero:get_direction() == 3 then
        -- Special case on this map to play kakariko music when coming out of
        -- house so house music doesn't continue. Map doesn't specify music.
        sol.audio.play_music("town_kakariko")
      end
    end
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  -- Shop is closed at night after Strap's bottle is stolen.
  if game:get_value("b1812") and game:get_time_of_day() == "night" then
    shop_door:set_enabled(true)
    night_shop_door:set_enabled(false)
  end
end

npc_ildus:register_event("on_interaction", function()
  if game:get_value("b1117") then
    game:start_dialog("ildus.1.outside")
  else
    game:start_dialog("ildus.0.outside")
  end
end)

function sensor_music:on_activated()
  if hero:get_direction() == 3 then sol.audio.play_music("town_kakariko") end
end
function sensor_music_2:on_activated()
  if hero:get_direction() == 3 then sol.audio.play_music("town_kakariko") end
end
function sensor_music_3:on_activated()
  if hero:get_direction() == 3 then sol.audio.play_music("town_kakariko") end
end

function sensor_enter_kakariko:on_activated()
  sol.audio.play_music("town_kakariko")
  sensor_enter_field:set_enabled(false)
  sol.timer.start(sensor_enter_kakariko,2000,function()
    sensor_enter_field:set_enabled(true)
  end)
end
function sensor_enter_field:on_activated()
  sol.audio.play_music("field")
  sensor_enter_kakariko:set_enabled(false)
  sol.timer.start(sensor_enter_field,2000,function()
    sensor_enter_kakariko:set_enabled(true)
  end)
end