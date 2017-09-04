-- Creates a pit to the Underworld under the target
-- Based on script by IndigoFenix, @ https://gist.github.com/IndigoFenix/8776696
local help = [====[

hfs-pit
=======
Creates a pit to the underworld at the cursor, taking three numbers as
arguments.  Usage:  ``hfs-pit <size> <walls> <stairs>``

The first argument is size of the (square) pit in all directions.  The second
is ``1`` to wall off the sides of the pit on all layers except the underworld,
or anything else to leave them open.  The third parameter is 1 to add stairs.
Stairs are buggy; they will not reveal the bottom until you dig somewhere,
but underworld creatures will path in.

Examples::

    hfs-pit 1 0 0
        A single-tile wide pit with no walls or stairs.
        This is the default if no numbers are given.

    hfs-pit 4 0 1
        A four-across pit with no stairs but adding walls.

    hfs-pit 2 1 0
        A two-across pit with stairs but no walls.

]====]

args={...}

if args[1] == '?' or args[1] == 'help' then
    print(help)
    return
end

pos = copyall(df.global.cursor)
size = tonumber(args[1])
if size == nil or size < 1 then size = 1 end

wallOff = tonumber(args[2])
stairs = tonumber(args[3])

--Get the layer of the underworld
for index,value in ipairs(df.global.world.features.map_features) do
    local featureType=value:getType()
    if featureType==9 then --Underworld
        underworldLayer = value.layer
    end
end

if pos.x==-30000 then
    qerror("Select a location by placing the cursor")
end
local x = 0
local y = 0
for x=pos.x-size,pos.x+size,1 do
    for y=pos.y-size,pos.y+size,1 do
        z=1
        local hitAir = false
        local hitCeiling = false
        while z <= pos.z do
            local block = dfhack.maps.ensureTileBlock(x,y,z)
            if block then
                if block.tiletype[x%16][y%16] ~= 335 then
                    hitAir = true
                end
                if hitAir == true then
                    if not hitCeiling then
                        if block.global_feature ~= underworldLayer or z > 10 then hitCeiling = true end
                        if stairs == 1 and x == pos.x and y == pos.y then
                            if block.tiletype[x%16][y%16] == 32 then
                                if z == pos.z then
                                    block.tiletype[x%16][y%16] = 56
                                else
                                    block.tiletype[x%16][y%16] = 55
                                end
                            else
                                block.tiletype[x%16][y%16] = 57
                            end
                        end
                    end
                    if hitCeiling == true then
                        if block.designation[x%16][y%16].flow_size > 0 or wallOff == 1 then needsWall = true else needsWall = false end
                        if (x == pos.x-size or x == pos.x+size or y == pos.y-size or y == pos.y+size) and z==pos.z then
                            --Do nothing, this is the lip of the hole
                        elseif x == pos.x-size and y == pos.y-size then if needsWall == true then block.tiletype[x%16][y%16]=320 end
                            elseif x == pos.x-size and y == pos.y+size then if needsWall == true then block.tiletype[x%16][y%16]=321 end
                            elseif x == pos.x+size and y == pos.y+size then if needsWall == true then block.tiletype[x%16][y%16]=322 end
                            elseif x == pos.x+size and y == pos.y-size then if needsWall == true then block.tiletype[x%16][y%16]=323 end
                            elseif x == pos.x-size or x == pos.x+size then if needsWall == true then block.tiletype[x%16][y%16]=324 end
                            elseif y == pos.y-size or y == pos.y+size then if needsWall == true then block.tiletype[x%16][y%16]=325 end
                            elseif stairs == 1 and x == pos.x and y == pos.y then
                                if z == pos.z then block.tiletype[x%16][y%16]=56
                                else block.tiletype[x%16][y%16]=55 end
                            else block.tiletype[x%16][y%16]=32
                        end
                        block.designation[x%16][y%16].hidden = false
                        --block.designation[x%16][y%16].liquid_type = true -- if true, magma.  if false, water.
                        block.designation[x%16][y%16].flow_size = 0
                        dfhack.maps.enableBlockUpdates(block)
                        block.designation[x%16][y%16].flow_forbid = false
                    end
                end
                block.designation[x%16][y%16].hidden = false
            end
            z = z+1
        end
    end
end