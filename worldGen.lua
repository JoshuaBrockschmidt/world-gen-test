--TODO:
-- * add room branching to worldGen

require "blockGrid"

local maxRoomSects = 4
local minRoomSectW = 3
local minRoomSectH = 3
local maxRoomSectW = 6
local maxRoomSectH = 6

-- Maximum distance between two rooms placed in succession
local maxRoomDistX = 4
local maxRoomDistY = 4

-- Global functions --

--- Generates a room
-- @param sectNums  Number or room-sections
-- @return  Returns a block-grid object
genRoom1 = function(sectNums)
   local room = blockGrid.new(1, 1, 1)
   local minW = minRoomSectW
   local minH = minRoomSectH
   local last_startx, last_starty = 1, 1
   local lastW, lastH = 1, 1
   local startx, starty = 1, 1
   for sectNum = 1, sectNums do
      local w = math.max(minW, math.random(maxRoomSectW))
      local h = math.max(minH, math.random(maxRoomSectH))
      -- Ensure new section won't be totally engulfed in last section
      -- It should stick out a little bit
      -- This method only checks for enfulgment by the previous section
      -- If the new section ends up being completely overshadowed by another
      -- section or sections, then... oh well; we're not /that/ picky
      if (startx >= last_startx and startx + w <= last_startx + lastW)
	 and (starty >= last_starty and starty + h <= last_startx + lastH)
      then
	 -- Decide whether or not to adjust the width or height to compensate
	 if math.random(2) == 1 then
	    -- Distance between startx and the right edge of the last room section
	    local dist = ((last_startx + lastW) - startx)
	    -- Width shouldn't have to be adjusted to more than the max room
	    -- section width
	    -- A '1' is added, though, to account for the special case in which
	    -- startx lies on the left edge of a maximum width room section
	    w = dist + math.random((maxRoomSectW + 1) - dist)
	 else
	    local dist = ((last_starty + lastH) - starty)
	    -- Same logic as applied to width adjustment (see above), just for
	    -- the y-axis
	    h = dist + math.random((maxRoomSectH + 1) - dist)
	 end
      end
      
      -- If section pushes height boundaries, then adjust height of all rows
      if room[1] and (#room[1] < starty + h - 1) then
	 local firsty = #room[1] + 1
	 local endy = starty + h - 1
	 for x = 1, startx - 1 do
	    for y = firsty, endy do
	       -- Add in filled space
	       room[x][y] = 1
	    end
	 end
	 for x = startx + w, #room do
	    for y = firsty, endy do
	       -- Add in filled space
	       room[x][y] = 1
	    end
	 end
      end
	 
      -- Add in new room section
      local xLim = startx + w
      local yLim = starty + h
      for x = startx, xLim do
	 -- Add more columns if needed
	 if not room[x] then
	    local newCol = {}
	    -- Formally change occupied spaces to '1's instead of leaving them nil
	    -- Space before
	    for filledy = 1, starty - 1 do
	       newCol[filledy] = 1
	    end
	    -- Space after
	    local roomH = (room[1]) and #room[1] or h
	    for filledy = yLim + 1, roomH do
	       newCol[filledy] = 1
	    end
	    room[x] = newCol
	 end
	 for y = starty, yLim do
	    -- Fill in empty space with '0's
	    room[x][y] = 0
	 end
      end
      
      last_startx = startx
      last_starty = starty
      -- Ensure starting x coordinate is between the left edge of the
      -- room and the edge of the room section just generated
      startx = math.random(startx + w)
      -- Ensure width will be enough to touch last generated section
      minW = (startx < last_startx)
	 and math.max(minRoomSectW, last_startx - startx)
	 or minRoomSectW
      -- Ensure starting y coordinate is between the top edge of the
      -- room and the edge of the room section just generated
      starty = math.random(starty + h)
      -- Ensure height will be enough to touch last generated section
      minH = (starty < last_starty)
	 and math.max(minRoomSectH, last_starty - starty)
	 or minRoomSectH
   end
   
   return room
end


--- Generates a more blocky room
-- @param totalSects  Number or room-sections
-- @return  Returns a block-grid object
genRoom2 = function (totalSects)
   local room_beta = {}
   local room = {}
   local min_x, min_y = 1, 1
   local x_off, y_off
   
   -- Get the shape of the room, represented with rectangles and their size and coordinates
   room_beta[1] = {
      x = 1,
      y = 1,
      w = math.random(minRoomSectW, maxRoomSectW),
      h = math.random(minRoomSectH, maxRoomSectH)
   }
   for sectNum = 2, totalSects do
      local last = room_beta[sectNum - 1]
      local new = {
	 w = math.random(minRoomSectW, maxRoomSectW),
	 h = math.random(minRoomSectH, maxRoomSectH)
      }
      
      -- Determine whether or not to grow section
      -- out from the x-axis or the y-axis
      local xyAxis_bool = math.random(2)
      -- Determine whether to snap new section
      -- to right or left edge of last section
      local ltRt_bool = math.random(2)
      -- Determine whether to snap new section
      -- to top or bottom edge of last section
      local topBtm_bool = math.random(2)
      if xyAxis_bool == 1 then
	 -- Grow off x-axis
	 
	 if ltRt_bool == 1 then
	    -- Snap to left edge
	    new.x = last.x
	 else
	    -- Snap to right edge
	    new.x = last.x + last.w - new.w
	 end
	 
	 if topBtm_bool == 1 then
	    -- Snap to top edge 
	    new.y = last.y - new.h
	 else
	    -- Snap to bottom edge
	    new.y = last.y + last.h
	 end
	 
      else
	 -- Grow off y-axis
	 
	 if ltRt_bool == 1 then
	    -- Snap to left edge
	    new.x = last.x - new.w
	 else
	    -- Snap to right edge
	    new.x = last.x + last.w
	 end
	 
	 if topBtm_bool == 1 then
	    -- Snap to top edge
	    new.y = last.y
	 else
	    -- Snap to bottom edge
	    new.y = last.y + last.h - new.h
	 end
      end
      
      if new.x < min_x then
	 min_x = new.x
      end
      if new.y < min_y then
	 min_y = new.y
      end
      
      room_beta[sectNum] = new
   end
   
   -- Contruct actual room data
   -- Offset all x and y coordinates to fit on a graph
   -- that starts at and only goes out from (1, 1)
   x_off = -min_x + 1
   y_off = -min_y + 1
   room = blockGrid.new(1, 1, 1)
   for sectNum = 1, totalSects do
      sect = room_beta[sectNum]
      room:insertRect(sect.x + x_off, sect.y + y_off, sect.w, sect.h, 0)
   end
   
   return room
end


--- Generates a world with the specified number of rooms
-- @param totalRooms  Whole Number. Number or rooms
-- @param circleRooms  Whole Number. Approximate number of rooms per circle
-- @return  Returns a block-grid object
function genWorld(totalRooms, circleRooms)
   if ((not totalRooms) or totalRooms < 1) or ((not circleRooms) or circleRooms < 1) then
      -- Invalid parameter
      return
   end
   
   local world = {}
   local rooms = {}
   local cur_x, cur_y
   local min_x, min_y
   local off_x, off_y
   
   for rNum = 1, totalRooms do
      rooms[rNum] = {}
      rooms[rNum].w = math.random(minRoomSectW, maxRoomSectW)
      rooms[rNum].h = math.random(minRoomSectH, maxRoomSectH)
   end
   
   -- Make a rough map of room configuration
   -- All rooms represented as rectangles
   -- This is done to makes performing various room
   -- orientation operations less resource intensive
   
   -- Position first room
   cur_x, cur_y = 1, 1
   rooms[1].x, rooms[1].y = cur_x, cur_y
   min_x, min_y = cur_x, cur_y
   
   -- Position other rooms
   for rNum = 2, totalRooms do
      local oldRoom = rooms[rNum - 1]
      local newRoom = rooms[rNum]
      
      local w1, h1 = oldRoom.w, oldRoom.h
      local w2, h2 = newRoom.w, newRoom.h
      
      -- The goal is to ensure that even though the room will be shifted
      -- somewhat randomly, both rooms will retain a size no smaller than what
      -- is specified by the minimum width and height. As well, the next room
      -- need to be shifed in such a way that a straigh hallway can still be
      -- constructed between the two
      
      -- Get cycle with period of circleRooms
      local B = (2 * math.pi) / circleRooms
      -- Get slope
      local my = math.sin(B * rNum)
      local mx = math.cos(B * rNum)
      -- Strength of the slope
      local strg
      local max_strg, min_strg
      local limMin_x, limMin_y
      local limMax_x, limMax_y
      local shift_x, shift_y
      
      -- In special cases, ensure math is still do-able
      if mx == 0 then
	 mx = 1e-20
      end
      if my == 1 then
	 my = 1e-20
      end
      
      -- Get minimum strength
      limMin_x = (mx > 0) and minRoomSectW or -minRoomSectW
      limMin_y = (my > 0) and minRoomSectH or -minRoomSectH
      min_strg = math.min(
	 limMin_x / mx,
	 limMin_y / my
      )
      
      -- Get maximum strength
      limMax_x = (mx > 0) and w1 or -w2
      limMax_y = (my > 0) and h1 or -h2
      max_strg = math.min(
	 limMax_x / mx,
	 limMax_y / my
      )
      
      -- Enlarge number then shrink it back to size to get more decimal varience
      print("min-max:",math.floor(min_strg * 10) + 1, math.floor(max_strg * 10))
      do
	 local newMin = math.floor(min_strg * 10) + 1
	 local newMax = math.floor(max_strg * 10)
	 if newMin >= newMax then
	    strg = newMax / 10
	 else
	    strg = math.random(newMin, newMax) / 10
	 end
      end
      print("strg:",strg)
      
      shift_x = math.floor(mx * strg)
      shift_y = math.floor(my * strg)
      
      -- If corners of rectangles are touching
      if shift_x == limMax_x and shift_y == limMax_x then
	 -- Make sure one edge of the rectangles are touch
	 if math.random(2) == 1 then
	    shift_x = shift_x + ((mx > 0) and -1 or 1)
	 else
	    shift_y = shift_y + ((my > 0) and -1 or 1)
	 end
      end
      
      cur_x = cur_x + shift_x
      cur_y = cur_y + shift_y
	 
      rooms[rNum].x = cur_x
      rooms[rNum].y = cur_y
      
      if cur_x < min_x then
	 min_x = cur_x
      end
      if cur_y < min_y then
	 min_y = cur_y
      end
   end
   
   -- Initialize main world block-grid
   world = blockGrid.new(1, 1, 1)
   
   -- Find coordinate offsets so that no room will precede (1, 1)
   off_x = -min_x + 1
   off_y = -min_y + 1
   
   -- Put rooms on main block-grid
   for _, r in ipairs(rooms) do
      world:insertRect(r.x + off_x, r.y + off_y, r.w, r.h, 0)
   end
   
   return world
end




maxRoomSects = math.floor(maxRoomSects)
minRoomSectW = math.floor(minRoomSectW)
minRoomSectH = math.floor(minRoomSectH)
maxRoomSectW = math.floor(maxRoomSectW)
maxRoomSectH = math.floor(maxRoomSectH)
maxRoomDistX = math.floor(maxRoomDistX)
maxRoomDistY = math.floor(maxRoomDistY)
