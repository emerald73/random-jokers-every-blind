--start of mod

--variable definitions
local patched = false
local roundsPlayed = 0

--reset rounds counter to make sure the first played blind never rolls jokers
resetRoundsOnRestart = function()
  roundsPlayed = 0
end

--called upon blind select, generates 5 new jokers
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

--called upon blind defeat, destroys all jokers in hand
destroyJokers = function()
  for _, joker in ipairs(G.jokers.cards) do
    joker:start_dissolve(nil, (k ~= 1))
  end
end

--define mod settings
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

    --patch Blind:set_blind, in blind.lua to call destroyJokers() and then rollJoker(), blindsToReroll ensures jokers are only rolled upon blind select
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
            destroyJokers()
            rollJoker()
          end
        end
      end
    ]]
    --inject patch to Blind:set_blind in blind.lua
    injectTail("blind.lua", "Blind:set_blind", patch)
    
    --patch Blind:defeat in blind.lua to destroy jokers after round complete
    local defeatPatch = [[
      destroyJokers()
    ]]
    --inject the patch
    injectTail('blind.lua', "Blind:defeat", defeatPatch)
    
    --patch Game:start_run in game.lua to reset rounds played upon restart
    local patch = [[
      resetRoundsOnRestart()
    ]]
    -- inject the patch
    injectTail('game.lua', "Game:start_run", patch)
  end,

  on_post_update = function()
    if not patched then
      init_localization()
      patched = true
    end
  end
}

--insert the mod into the mods table
table.insert(mods, randomJokersMod)

--end of mod