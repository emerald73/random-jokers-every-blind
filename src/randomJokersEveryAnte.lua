local patched = false
local roundsPlayed = 0

resetRoundsOnRestart = function()
  roundsPlayed = 0
end

advanceRound = function()
  roundsPlayed = roundsPlayed + 1
end

rollJoker = function()
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

destroyJokers = function()
  for _, joker in ipairs(G.jokers.cards) do
    joker:start_dissolve(nil, (k ~= 1))
  end
end

local randomJokersEveryAnte = {
  mod_id = "randomJokersEveryAnte",
  name = "Random Jokers Every Ante",
  version = "1.0",
  author = "gdemerald",
  description = {
    "On each Ante, destroy all jokers and roll 5 new ones"
  },
  enabled = true,
  on_enable = function()

    local patch = [[
      if not reset then
        bossBlinds = {
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

        for i, blindName in ipairs(bossBlinds) do
          if self.name == blindName then
            destroyJokers()
          end
        end
      end
    ]]
    injectTail("blind.lua", "Blind:defeat", patch)
    
    local startPatch = [[
      if not reset then
        advanceBlinds = {
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
        for i, blind in ipairs(advanceBlinds) do
          if self.name == blind then
            advanceRound()
          end
        end
        if self.name == "Small Blind" then
          destroyJokers()
          rollJoker()
        end
      end
    ]]
    injectTail('blind.lua', "Blind:set_blind", startPatch)
    
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

table.insert(mods, randomJokersEveryAnte)