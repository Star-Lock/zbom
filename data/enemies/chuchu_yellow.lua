local enemy = ...

-- Yellow ChuChu: a basic overworld enemy that follows the hero.
-- The yellow variety can disappear into the ground and also try to electrocute the hero.

local shocking = false

function enemy:on_created()
  self:set_life(5); self:set_damage(10)
  self:create_sprite("enemies/chuchu_yellow")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_hookshot("immobilized")
end

function enemy:on_restarted()
  local sprite = self:get_sprite()
  if math.random(2) == 1 then
    sprite:set_animation("shocking")
    shocking = true
    sol.timer.start(enemy, math.random(5)*1000, function()
      shocking = false
      sprite:set_animation("walking")
      local m = sol.movement.create("path_finding")
      m:set_speed(32)
      m:start(self)
    end)
  else
    shocking = false
    sprite:set_animation("walking")
    local m = sol.movement.create("path_finding")
    m:set_speed(32)
    m:start(self)
  end
  sol.timer.start(enemy, math.random(5)*1000, function() self:restart() end)
end

function enemy:disappear()
  local sprite = self:get_sprite()
  sprite:set_animation("disappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_enabled(false)
    sol.timer.start(enemy, math.random(5)*5000, function() enemy:reappear() end)
  end
end

function enemy:reappear()
  shocking = false
  local sprite = self:get_sprite()
  sprite:set_animation("reappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_enabled(true)
    enemy:restart()
  end
end

function enemy:on_immobilized()
  shocking = false
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    self:hurt(1)
    enemy:remove_life(1)
  end
end
function enemy:on_attacking_hero(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    hero:start_hurt(3)
  end
end