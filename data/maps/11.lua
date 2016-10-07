local map = ...
local game = map:get_game()

---------------------------------------------------------------------------
-- Outside World F14 (Ordon Village) - Ranch, Fishing Pond and Maze Race --
---------------------------------------------------------------------------

if game:get_value("i1906")==nil then game:set_value("i1906", 0) end --Tern
if game:get_value("i1911")==nil then game:set_value("i1911", 0) end --Gaira
if game:get_value("i1027")==nil then game:set_value("i1027", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function follow_hero(npc)
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  m:set_speed(40)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function are_all_torches_on()
  return torch_1 ~= nil
    and torch_1:get_sprite():get_animation() == "lit"
    and torch_2:get_sprite():get_animation() == "lit"
    and torch_3:get_sprite():get_animation() == "lit"
end

function map:on_started(destination)
  if game:get_time_of_day() == "day" then
    random_walk(goat_1)
    random_walk(goat_2)
    random_walk(goat_3)
    random_walk(goat_4)
    random_walk(goat_5)
  else
    goat_1:remove(); goat_2:remove(); goat_3:remove(); goat_4:remove(); goat_5:remove()
  end
  -- If the festival isn't over, make sure banners, booths and NPCs are outside.
  if game:get_value("i1027") < 5 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    booth_1:set_enabled(true)
    npc_gaira:remove()
  else
    if game:get_time_of_day() == "day" then
      random_walk(npc_tern)
    else
      npc_tern:remove()
    end
    torch_2:remove(); wall_2:remove()
    torch_3:remove(); wall_3:remove()
  end
  if game:get_value("i1027") < 3 then
    if game:get_value("i1028") < 1 then
      local m = sol.movement.create("straight")
      m:set_ignore_obstacles(true)
      m:set_angle(math.pi / 2)
      m:set_speed(48)
      m:start(npc_francis)
      npc_francis:get_sprite():set_animation("walking")
      local m2 = sol.movement.create("straight")
      m2:set_ignore_obstacles(true)
      m2:set_angle(math.pi / 2)
      m2:set_speed(48)
      m2:start(npc_jarred)
      npc_jarred:get_sprite():set_animation("walking")
      sol.timer.start(1800, function()
        m:stop()
        m2:stop()
      end)
    else
      npc_jarred:set_position(720, 992)
      npc_francis:set_position(656, 992)
      random_walk(npc_jarred)
      random_walk(npc_francis)
    end
  elseif game:get_value("i1027") <= 3 or game:get_value("i1027") > 4 then
    npc_tristan:remove()
    npc_jarred:remove()
    npc_francis:remove()
  elseif game:get_value("i1027") == 4 then
    if not game:has_item("shield") then
      npc_tristan:remove()
    else
      random_walk(npc_tristan)
    end
    npc_jarred:remove()
    npc_francis:remove()
  end
  if game:get_value("i1028") == 3 then
    torch_1:get_sprite():set_animation("lit")
    torch_2:get_sprite():set_animation("lit")
    torch_3:get_sprite():set_animation("lit")
  end
  -- Poisoned trees Deacon-Gaira side quest.
  if game:get_value("i1911") ~= 2 then quest_gaira:remove() end
  if game:get_value("i1602") > 2 then npc_gaira:remove() end

  local on_update_timer = sol.timer.start(map, 100, function()
    -- We do this in place of on_update so we don't break the night overlay.
    if game:get_value("i1028") == 2 and are_all_torches_on() then
      sol.audio.play_sound("chest_appears")
      game:set_value("i1028", 3)
    end
    if game:get_value("i1027") < 3 then
      map:set_entities_enabled("banner_race", true)
      if game:get_value("i1028") > 1 and game:get_value("i1028") < 4 then
        map:set_entities_enabled("sensor_race", true)
        to_F15:set_enabled(false)
        to_F13:set_enabled(false)
        to_E14_2:set_enabled(false)
        to_ranch:set_enabled(false)
      end
    else
      map:set_entities_enabled("banner_race", false)
      map:set_entities_enabled("sensor_race", false)
      to_F15:set_enabled(true)
      to_F13:set_enabled(true)
      to_E14_2:set_enabled(true)
      to_ranch:set_enabled(true)
    end
    return true
  end)

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function sensor_festival_dialog:on_activated()
  if game:get_value("i1027") < 3 and game:get_value("i1028") == 0 and hero:get_direction() == 1 then
    npc_tristan:get_sprite():set_animation("pose1")
    game:start_dialog("tristan.0.festival", game:get_player_name(), function()
      local m = sol.movement.create("jump")
      sol.audio.play_sound("jump")
      m:set_direction8(2) --face up
      m:set_distance(8)
      m:start(npc_francis)
      sol.timer.start(400, function()
        game:set_dialog_position("top")
        game:start_dialog("francis.1.festival", function()
          npc_tristan:get_sprite():set_animation("pose2")
          game:set_dialog_position("bottom")
          game:start_dialog("tristan.0.festival_response", game:get_player_name(), function()
            game:set_dialog_position("top")
            game:start_dialog("francis.1.festival_race", function(answer)
              if answer == 1 then
	       game:set_value("i1028", 1)
                if game:has_item("lamp") then
                  game:set_dialog_position("bottom")
                  game:start_dialog("tristan.0.festival_rules", function()
                    random_walk(npc_jarred)
		  random_walk(npc_francis)
                  end)
                else
                  game:set_dialog_position("bottom")
                  game:start_dialog("tristan.0.festival_lamp")
                end
              else
                game:set_dialog_position("bottom")
                game:start_dialog("tristan.0.festival_no")
              end
            end)
          end)
        end)
      end)
    end)
  elseif game:get_value("i1028") > 1 and game:get_value("i1028") <= 3 then
    game:start_dialog("tristan.0.festival_underway")
  end
end

function sensor_start_race:on_activated()
  if hero:get_direction() == 1 and game:has_item("lamp") and not game.race_timer then
    if (game:get_value("i1028") >= 1 and game:get_value("i1028") <= 3) or game:get_value("i1028") == 4 then
      game:set_value("i1028", 2)
      game.race_timer = sol.timer.start(game, 120000, function()
	sol.audio.play_sound("wrong")
	game:set_value("i1028", 4)
	local map = game:get_map()
	map:get_entity("torch_1"):get_sprite():set_animation("unlit")
	map:get_entity("torch_2"):get_sprite():set_animation("unlit")
	map:get_entity("torch_3"):get_sprite():set_animation("unlit")
	if map:get_entity("torch_4") ~= nil then map:get_entity("torch_4"):get_sprite():set_animation("unlit") end
	if map:get_entity("torch_5") ~= nil then map:get_entity("torch_5"):get_sprite():set_animation("unlit") end
	game.race_timer = nil
      end)
      game.race_timer:set_with_sound(true)
      game.race_timer:set_suspended_with_map(true)
    end
  end
end

function sensor_race:on_activated()
  if game:get_value("i1028") > 1 and game:get_value("i1028") <= 3 then
    if hero:get_direction() == 1 then
      game:start_dialog("tristan.0.festival_underway")
    end
  end
end

function sensor_ordona_speak:on_activated()
  if game:get_value("b1699") and not game:get_value("b1698") then
    -- You've finished everything - Ordona bids you goodbye.
    sol.timer.start(1000, function() torch_1:get_sprite():set_animation("lit") end)
    sol.timer.start(2000, function()
      hero:freeze()
      hero:set_direction(0)
      if game:get_time_of_day() ~= "night" then
        local previous_tone = game:get_map_tone()
        game:set_map_tone(32,64,128,255)
      end
      game:start_dialog("ordona.8.village", game:get_player_name(), function()
        sol.timer.start(500, function()
          if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
        end)
        hero:unfreeze()
        game:set_stamina(game:get_max_stamina())
        torch_1:get_sprite():set_animation("unlit")
        game:set_value("b1698", true)
      end)
    end)
  elseif game:has_item("sword") and game:get_value("i1027") < 6 then
    -- You've finished everything in Ordon - Ordona directs you to Faron.
    sol.timer.start(1000, function() torch_1:get_sprite():set_animation("lit") end)
    sol.timer.start(2000, function()
      hero:freeze()
      hero:set_direction(0)
      if game:get_time_of_day() ~= "night" then
        local previous_tone = game:get_map_tone()
        game:set_map_tone(32,64,128,255)
      end
      game:set_value("i1027", 5)
      game:start_dialog("ordona.1.village", game:get_player_name(), function()
        sol.timer.start(500, function()
          if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
        end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        torch_1:get_sprite():set_animation("unlit")
        game:set_value("i1027", 6)
      end)
    end)
  end
end

function npc_tern:on_interaction()
  if game:get_value("i1027") <= 5 then
    if game:get_value("i1028") > 1 and game:get_value("i1028") <= 3 then
      game:start_dialog("tern.0.festival_race")
    else
      game:start_dialog("tern.0.festival")
    end
  else game:start_dialog("tern.1.ranch") end
end

function npc_tristan:on_interaction()
  if game:get_value("i1028") == 1 then
    if game:has_item("lamp") then
      game:start_dialog("tristan.0.festival_rules")
    else
      game:start_dialog("tristan.0.festival_lantern")
    end
  elseif game:get_value("i1028") > 1 and game:get_value("i1028") <= 3 then
    game:start_dialog("tristan.0.festival_underway")
  elseif game:get_value("i1028") == 4 then
    game:start_dialog("tristan.0.festival_lost")
  elseif game:get_value("i1028") == 5 then
    if game:has_item("shield") then
      game:start_dialog("tristan.0.festival_shield")
    else
      game:start_dialog("tristan.0.festival_won", game:get_player_name())
    end
  else
    game:start_dialog("tristan.0.festival_question", function(answer)
      if answer == 1 then
        if game:has_item("lamp") then
          game:start_dialog("tristan.0.festival_rules", function() game:set_value("i1028", 1) end)
        else
          game:start_dialog("tristan.0.festival_lamp")
        end
      else
        game:start_dialog("tristan.0.festival_no")
      end
    end)
  end
end

function torch_1:on_interaction()
  if torch_1:get_sprite():get_animation() == "unlit" then map:get_game():start_dialog("torch.need_lamp") end
end
function torch_1:on_interaction_item(lamp)
  torch_1:get_sprite():set_animation("lit")
end

function torch_2:on_interaction()
  if torch_2:get_sprite():get_animation() == "unlit" then map:get_game():start_dialog("torch.need_lamp") end
end
function torch_2:on_interaction_item(lamp)
  torch_2:get_sprite():set_animation("lit")
end

function torch_3:on_interaction()
  if torch_3:get_sprite():get_animation() == "unlit" then map:get_game():start_dialog("torch.need_lamp") end
end
function torch_3:on_interaction_item(lamp)
  torch_3:get_sprite():set_animation("lit")
end

function goat_1:on_interaction()
  sol.audio.play_sound("goat")
end
function goat_2:on_interaction()
  sol.audio.play_sound("goat")
end
function goat_3:on_interaction()
  sol.audio.play_sound("goat")
end
function goat_4:on_interaction()
  sol.audio.play_sound("goat")
end
function goat_5:on_interaction()
  sol.audio.play_sound("goat")
end
function scarecrow:on_interaction()
  sol.audio.play_sound("scarecrow")
end

function map:on_draw(dst_surface)
  -- Show remaining timer time on screen
  if game.race_timer ~= nil then
    local timer_icon = sol.sprite.create("hud/clock")
    local timer_time = math.floor(game.race_timer:get_remaining_time() / 1000)
    local timer_text = sol.text_surface.create{
      font = "white_digits",
      horizontal_alignment = "left",
      vertical_alignment = "top",
    }
    timer_icon:set_animation("timer")
    timer_icon:draw(dst_surface, 5, 55)
    timer_text:set_text(timer_time)
    timer_text:draw(dst_surface, 22, 58)
  end
end