local enemy = ...

-- Floria Baba

local in_ground = false

function enemy:on_created()
  self:set_life(3)
  self:set_damage(4)
  self:create_sprite("enemies/baba_floria")
  self:set_size(24, 32)
  self:set_origin(12, 29)
  self:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()
  local hx, hy, hl = hero:get_position()
  local ex, ey, el = self:get_position()
  if hx > ex then
    self:get_sprite():set_direction(0)
  elseif hy < ey then
    self:get_sprite():set_direction(1)
  elseif hx < ex then
    self:get_sprite():set_direction(2)
  else
    self:get_sprite():set_direction(3)
  end
end