-- Forces an event (caravan, migrants, etc)
-- author Putnam
-- edited by expwnent
local help = [====[

modtools/force
==============
This tool triggers events like megabeasts, caravans, and migrants.

Usage::

    -eventType event
        specify the type of the event to trigger
        examples:
            MegaBeast
            Migrants
            Caravan
            Diplomat
            WildlifeCurious
            WildlifeMischievous
            WildlifeFlier
            NightCreature
    -civ entity
        specify the civ of the event, if applicable
        examples:
            player
            MOUNTAIN
            EVIL
            28

]====]
local utils = require 'utils'

local function findCiv(arg)
 local entities = df.global.world.entities.all
 if tonumber(arg) then return df.historical_entity.find(tonumber(arg)) end
 if arg then
  for eid,entity in ipairs(entities) do
   if entity.entity_raw.code == arg then return entity end
  end
 end
 return nil
end

validArgs = validArgs or utils.invert({
 'eventType',
 'help',
 'civ'
})

local args = utils.processArgs({...}, validArgs)
if next(args) == nil or args.help then
 print(help)
 print('force: -eventType [Megabeast, Migrants, Caravan, Diplomat, WildlifeCurious, WildlifeMischievous, WildlifeFlier, NightCreature] -civ [player,ENTITY_ID]')
 return
end

if not args.eventType then
 error 'Specify an eventType.'
elseif not df.timed_event_type[args.eventType] then
 error('Invalid eventType: ' .. args.eventType)
end

if args.civ == 'player' then
 args.civ = df.historical_entity.find(df.global.ui.civ_id)
elseif args.civ then
 local civ = args.civ
 args.civ = findCiv(args.civ)
 if not args.civ then
  error('Invalid civ: ' .. civ)
 end
elseif args.eventType == 'Caravan' or args.eventType == 'Diplomat' then
 error('Specify civ for this eventType')
end

if args.eventType == 'Migrants' then
 args.civ = df.historical_entity.find(df.global.ui.civ_id)
end

local timedEvent = df.timed_event:new()
timedEvent.type = df.timed_event_type[args.eventType]
timedEvent.season = df.global.cur_season
timedEvent.season_ticks = df.global.cur_season_tick
if args.civ then
 timedEvent.entity = args.civ
end

df.global.timed_events:insert('#', timedEvent)

