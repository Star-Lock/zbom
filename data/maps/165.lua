local map = ...
local game = map:get_game()

-----------------------------------------------
-- Great Fairy Fountain of Wisdom - Snowpeak --
-----------------------------------------------

if game:get_value("i1605")==nil then game:set_value("i1605", 0) end
if game:get_value("i1830")==nil then game:set_value("i1830", 0) end

function map:on_started(destination)
  if game:get_value("i1605") >= 1 and game:get_value("i1605") < 5 then  -- force the initial dialog to be heard
    if game:get_value("i1830") >= 10 then game:set_value("i1605", 2) end
    if game:get_value("i1830") >= 20 then game:set_value("i1605", 3) end
    if game:get_value("i1830") >= 35 then game:set_value("i1605", 4) end
    if game:get_value("i1830") >= 50 then game:set_value("i1605", 5) end
  end
end

function sensor_fairy_speak:on_activated()
  game:set_dialog_style("default")
  if game:get_value("i1605") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1605") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1605") == 3 then
    game:start_dialog("great_fairy.3")
  elseif game:get_value("i1605") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1605") == 5 then
    game:start_dialog("great_fairy.5.snowpeak", function()
      game:set_value("i1605", 6)
      if game:get_item("magic_bar"):get_variant() < 2 then hero:start_treasure("magic_bar", 2) end
    end)
  elseif game:get_value("i1605") == 6 then
    game:start_dialog("great_fairy.6")
  else
    game:start_dialog("great_fairy.0.snowpeak", function()
      game:set_value("i1605", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end