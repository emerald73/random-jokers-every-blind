local patched = false
local roundsPlayed = 0

resetRoundsOnRestart = function()
  roundsPlayed = 0
end

rollJoker = function()
  roundsPlayed = roundsPlayed + 1
  if roundsPlayed > 1 then
    for i = 1,5,1
    do
      G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
        play_sound('timpani')
        local card = create_card('Joker', G.jokers)
        card:add_to_deck()
        G.jokers:emplace(card)
        return true end }))
      delay(0.6)
    end
  end
end

rerollJokers = function()
  for _, joker in ipairs(G.jokers.cards) do
    joker:start_dissolve(nil, (k ~= 1))
  end
  rollJoker()
end

local randomJokersMod = {
  mod_id = "randomJokersOnBlindSelect",
  name = "Random Jokers",
  version = "1.0",
  author = "gdemerald",
  description = {
    "On blind select, destroy all jokers and create 5 random ones (first blind excluded)"
  },
  enabled = true,
  on_enable = function()
    sendDebugMessage("Random Jokers enabled!")

    local patch = [[
      if not reset then
        blindsToReroll = {
          'Small Blind',
          'Big Blind',
          'The Hook',
          'The Ox',
          'The House',
          'The Wall',
          'The Wheel',
          'The Arm',
          'The Club',
          'The Fish',
          'The Psychic',
          'The Goad',
          'The Water',
          'The Window',
          'The Manacle',
          'The Eye',
          'The Mouth',
          'The Plant',
          'The Serpent',
          'The Pillar',
          'The Needle',
          'The Head',
          'The Tooth',
          'The Flint',
          'The Mark',
          'Amber Acorn',
          'Verdant Leaf',
          'Violet Vessel',
          'Crimson Heart',
          'Cerulean Bell'
        }

        for i, blindName in ipairs(blindsToReroll) do
          if self.name == blindName then
            rerollJokers()
          end
        end
      end
    ]]
    injectTail("blind.lua", "Blind:set_blind", patch)

    local patch = [[
      resetRoundsOnRestart()
    ]]
    injectTail('game.lua', "Game:start_run", patch)
  end,
  on_post_update = function()
    if not patched then
      init_localization()
      patched = true
    end
  end
}
table.insert(mods, randomJokersMod)