local map = ...
local game = map:get_game()
local anouki_talk = 0

-----------------------------------------------
-- Outside World B6 (Snowpeak) - Snow drifts --
-----------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_time_of_day() == "night" then
    npc_poko:remove()
  else
    random_walk(npc_poko)
  end

  -- Bushes are frozen and can only by cut with a more powerful sword.
  if game:get_ability("sword") >= 2 then
    for bush in map:get_entities("bush_") do
      bush:set_can_be_cut(true)
    end
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function npc_poko:on_interaction()
  game:start_dialog("anouki_1."..anouki_talk..".snowpeak")
  if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
end

function sensor_snow_drift_1:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 1)
end

function sensor_snow_drift_2:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 0)
end