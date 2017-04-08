local map = ...
local game = map:get_game()

------------------------------------------------------------
-- Outside World F15 (Ordon Village) - Houses and Shops   --
------------------------------------------------------------

if game:get_value("i1027")==nil then game:set_value("i1027", 0) end --Festival progress
if game:get_value("i1028")==nil then game:set_value("i1028", 0) end --Race progress
if game:get_value("i1902")==nil then game:set_value("i1902", 0) end --Rudy
if game:get_value("i1903")==nil then game:set_value("i1903", 0) end --Julita
if game:get_value("i1904")==nil then game:set_value("i1904", 0) end --Ulo
if game:get_value("i1907")==nil then game:set_value("i1907", 0) end --Quint
if game:get_value("i1908")==nil then game:set_value("i1908", 0) end --Francis
if game:get_value("i1909")==nil then game:set_value("i1909", 0) end --Jarred

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function follow_hero(npc)
 sol.timer.start(npc, 500, function()
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(false)
  m:set_speed(40)
  m:set_smooth(true)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
 end)
end

function map:on_started(destination)
  -- if Link walks out of his house and the festival's going on
  -- then start the initial dialog (if it hasn't been done already).
  if game:get_value("i1027") == 0 and destination == from_house_inside then
    follow_hero(npc_jarred)
    follow_hero(npc_quint)
    follow_hero(npc_francis)
    festival_timer = sol.timer.start(1200, function()
      hero:freeze()
      game:set_value("i1027", 1)
      local m = sol.movement.create("jump")
      sol.audio.play_sound("jump")
      m:set_direction8(6) -- Face down to indicate speaking.
      m:set_distance(8)
      m:set_speed(32)
      m:start(npc_jarred)
      sol.timer.start(400, function()
        game:set_dialog_name("Jarred")
        game:start_dialog("jarred.0.festival", game:get_player_name(), function()
          sol.audio.play_sound("jump")
          m:set_direction8(6) -- Face down to indicate speaking.
          m:set_distance(8)
          m:start(npc_quint)
          sol.timer.start(400, function()
            game:set_dialog_position("top"); game:set_dialog_name("Quint")
            game:start_dialog("quint.0.festival", function()
              sol.audio.play_sound("jump")
              m:set_direction8(6) -- Face down to indicate speaking.
              m:set_distance(8)
              m:start(npc_francis)
              sol.timer.start(400, function()
                game:set_dialog_position("bottom"); game:set_dialog_name("Francis")
                game:start_dialog("francis.0.festival", function()
                  m:set_direction8(4) -- Face hero.
                  m:set_distance(8)
                  m:start(npc_quint)
                  sol.timer.start(400, function()
                    game:set_dialog_position("top"); game:set_dialog_name("Quint")
                    game:start_dialog("quint.0.festival_2", game:get_player_name(), function()
                      m:set_direction8(4) -- Face hero.
                      m:set_distance(8)
                      m:start(npc_francis)
                        sol.timer.start(400, function()
                        game:set_dialog_position("bottom"); game:set_dialog_name("Francis")
                        game:start_dialog("francis.0.festival_2", function()
                          game:set_value("i1027", 2)
                          hero:unfreeze()
                          follow_hero(npc_jarred)
                          follow_hero(npc_quint)
                          follow_hero(npc_francis)
                          game:set_value("i1907", game:get_value("i1907")+1)
                          game:set_value("i1908", game:get_value("i1908")+1)
                          game:set_value("i1909", game:get_value("i1909")+1)
                        end)
                      end)
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
   end)
  elseif game:get_value("i1027") < 2 then  -- Whether or not kids should be walking around.
    follow_hero(npc_jarred)
    follow_hero(npc_quint)
    follow_hero(npc_francis)
  else
    random_walk(npc_jarred)
    random_walk(npc_quint)
    random_walk(npc_francis)
  end

  -- If the festival isn't over, make sure banner, booths and NPCs are outside.
  if game:get_value("i1027") < 5 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    banner_6:set_enabled(true)
    banner_7:set_enabled(true)
    banner_8:set_enabled(true)
    booth_1:set_enabled(true)
    booth_2:set_enabled(true)
    blacksmith_table:set_enabled(true)
    blacksmith_furnace:set_enabled(true)
    random_walk(npc_ulo)
  else  -- If festival is over, then don't have NPCs walking around outside.
    npc_rudy:remove()
    npc_julita:remove()
    npc_ulo:remove()
    npc_bilo:remove()
  end

  -- Show the quest bubble for the "find Crista for Julita" quest only at the appropriate time.
  if game:get_value("i1027") ~= 4 and quest_julita:exists() then quest_julita:remove() end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end

  -- Entrances of houses.
  local entrance_names = { "pim", "ulo", "julita" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    local tile_glow = map:get_entity("night_" .. entrance_name .. "_door")
    tile_glow:set_enabled(false)
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        tile:set_enabled(false)
        if game:get_time_of_day() == "night" then
          tile_glow:set_enabled(true)
        end
        sol.audio.play_sound("door_open")
      end
    end
  end
end

npc_rudy:register_event("on_interaction", function()
  if game:get_value("i1027") >= 3 then
    if not game:has_item("shield") then
      game:start_dialog("rudy.0.festival_reward", function()
        game:set_value("i1902", game:get_value("i1902")+1)
        hero:start_treasure("shield", 1, "b1820", function()
          game:start_dialog("rudy.0.festival_reward_2", function()
            if game:get_value("i1903") < 2 then
	      game:start_dialog("rudy.0.festival_reward_3")
            end
          end)
        end)
      end)
    else game:start_dialog("rudy.1.festival") end
  else
    game:start_dialog("rudy.0.festival")
    if game:get_value("i1902") == 0 then game:set_value("i1902", 1) end
  end
end)

npc_quint:register_event("on_interaction", function()
  if game:get_value("i1907") >= 1 then
    if game:get_value("i1027") >= 6 then
      repeat -- Make sure the same quote is not picked again.
        index = math.random(3)
      until index ~= last_message
      game:start_dialog("quint.2.hint_"..index)
      last_message = index
    elseif game:get_value("i1028") > 1 then game:start_dialog("quint.1.ordon") end
  end
end)

npc_francis:register_event("on_interaction", function()
  if game:get_value("i1908") >= 1 then
    if game:get_value("i1027") >= 6 then
      repeat -- Make sure the same quote is not picked again.
        index = math.random(3)
      until index ~= last_message
      game:start_dialog("francis.2.hint_"..index)
      last_message = index
    elseif game:get_value("i1028") > 1 then game:start_dialog("francis.1.ordon") end
  end
end)

npc_jarred:register_event("on_interaction", function()
  if game:get_value("i1909") >= 1 then
    if game:get_value("i1027") >= 6 then
      repeat -- Make sure the same quote is not picked again.
        index = math.random(3)
      until index ~= last_message
      game:start_dialog("jarred.2.hint_"..index)
      last_message = index
    elseif game:get_value("i1028") > 1 then game:start_dialog("jarred.1.ordon", function() game:add_money(10) end) end
  end
end)

npc_ulo:register_event("on_interaction", function()
  if game:get_value("i1904") >= 1 then
    if game:has_item("lamp") then
      game:start_dialog("ulo.1.festival")
    else
      game:start_dialog("ulo.1.festival_lamp")
    end
  else
    game:set_value("i1904", game:get_value("i1904")+1)
    game:start_dialog("ulo.0.festival", game:get_player_name())
  end
end)