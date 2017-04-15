local map = ...
local game = map:get_game()
local num_tries = 0
local in_tree = 0
local game_lost = false

---------------------------------------------------------------------------------------
-- Monkey minigame to get Book of Mudora page back (after Abandoned Pyramid is done) --
---------------------------------------------------------------------------------------

function game_won()
  game:start_dialog("monkey.1.game_right", function()
    local book_variant = game:get_item("book_mudora"):get_variant() + 1
    map:get_hero():start_treasure("book_mudora", book_variant) -- Give back Book piece.
    game:set_value("i1068", 9) -- Game won.
    sol.audio.play_music("faron_woods") -- Map music is "same as before", so we have to set it.
    sol.timer.start(map, 1000, function() map:get_hero():teleport("20", "from_game") end)
  end)
end

function map:on_started(destination)
  sol.audio.play_sound("monkey")
  game:start_dialog("monkey.1.faron_yes", function()
    sol.audio.play_sound("monkey")
    map:move_camera(656, 152, 250, function()
      sol.audio.play_sound("monkey")
      in_tree = math.random(7)
      npc_monkey:remove()
    end)
  end)
end

function map:on_update()
  if num_tries == 3 and not game_lost then
    game_lost = true
    game:start_dialog("monkey.2.faron")
    map:get_hero():teleport("20", "from_game")
  end
end

function tree_1:on_interaction()
  if in_tree == 1 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_2:on_interaction()
  if in_tree == 2 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_3:on_interaction()
  if in_tree == 3 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_4:on_interaction()
  if in_tree == 4 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_5:on_interaction()
  if in_tree == 5 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_6:on_interaction()
  if in_tree == 6 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end
function tree_7:on_interaction()
  if in_tree == 7 then game_won() else
    game:start_dialog("monkey.1.game_wrong")
    num_tries = num_tries + 1
  end
end