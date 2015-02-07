-- DISCLAIMER: not all the parameter checks are spot-on


local blockGrid_obj
local blockGrid_mt




blockGrid = {
   --- Creates a new block-grid of a specified size and block type
   -- @param w  Whole Number. Initial width of new block grid
   -- @param h  Whole Number. Initial height of new block grid
   -- @param bID  Integer. Block ID/type. The block-grid's default block ID
   --   will also be set to this (see blockGrid.setDefBID). 1 by default
   -- @return  Block-grid object
   new = function(w, h, bID)
      if (not w or w < 1) or (not h or h < 1) or (bID and bID < 0) then
	 -- Invalid size parameter(s)
	 return
      end
      
      if not bID then
	 -- Default block ID to that of a wall block
	 bID = 1
      end
      
      local newGrid = {
	 def_bID = bID
      }
      
      -- Initialize an empty grid
      for x = 1, w do
	 newGrid[x] = {}
	 for y = 1, h do
	    -- ID of an empty block
	    newGrid[x][y] = bID
	 end
      end
      
      setmetatable(newGrid, blockGrid_mt)
      
      return newGrid
   end  
}




blockGrid_obj = {
   --- Sets the default block ID/type
   -- This will be used when a block must be added and no block ID/type is
   -- specified. E.g., when extending the map
   setDefBID = function(self, bID)
      if (not bID or bID < 0) then
	 -- Invalid parameter
	 return
      end
      self.def_bID = bID
   end,
   
   --- Gets the width of a block-grid
   -- @param self  Block-grid object
   -- @return  Integer. Width of block-grid
   width = function(self)
      return #self
   end,
   
   --- Gets the height of a block-grid
   -- @param self  Block-grid object
   -- @return  Integer. Height of block-grid
   height = function(self)
      return #self[1]
   end,
   
   --- Changes the size of a block-grid
   -- @param self  Block-grid object
   -- @param new_w  Whole number. New width of 
   chngSize = function(self, new_w, new_h)
      if (not self) or (not new_w or new_w < 1) or (not new_h or new_h < 1) then
	 -- Invalid parameter(s)
	 return
      end
      
      local grid_w = self:width()
      local grid_h = self:height()
      
      if new_h > grid_h then
	 for x = 1, math.min(grid_w, new_w) do
	    for y = grid_h + 1, new_h do
	       self[x][y] = self.def_bID
	    end
	 end
	 grid_h = new_h
      elseif new_h < grid_h then
	 for x = 1, math.min(grid_w, new_w) do
	    for y = grid_h, new_h + 1 do
	       self[x][y] = nil
	    end
	 end
	 grid_h = new_h
      end
      
      if new_w > grid_w then
	 for x = grid_w + 1, new_w do
	    self[x] = {}
	    for y = 1, grid_h do
	       self[x][y] = self.def_bID
	    end
	 end
      elseif new_w < grid_w then
	 for x = new_w + 1, grid_w do
	    self[x] = nil
	 end
      end
   end,
   
   --- Inserts a rectangle of a specific block type into a block-grid
   -- This rectangle will overlap any block 
   -- @param self  Block-grid object
   -- @param w  Whole Number. Initial width of new block grid
   -- @param h  Whole Number. Initial height of new block grid
   -- @param bID  Integer. Block ID/type. 0 by default
   insertRect = function(self, x, y, w, h, bID)
      if type(x) ~= "number" or type(y) ~= "number"
	 or type(w) ~= "number" or type(h) ~= "number"
      then
	 -- Invalid parameter(s)
	 return
      end
      x = math.floor(x)
      y = math.floor(y)
      w = math.floor(w)
      h = math.floor(h)
      if (not self)
      or (x < 1) or (y < 1)
      or (w < 1) or (h < 1)
      or (bID and bID < 0) then
	 -- Invalid parameter(s)
	 return
      end
      
      if not bID then
	 -- Default block ID to that of an empty block
	 bID = 0
      end
      
      local grid_w = self:width()
      local grid_h = self:height()
      
      self:chngSize(math.max(grid_w, x + w - 1), math.max(grid_h, y + h - 1))
      
      -- Add rectangle
      for x = x, x + w - 1 do
	 for y = y, y + h - 1 do
	    self[x][y] = bID
	 end
      end
   end,
   
   --- Inserts a block-grid into another block-grid
   -- WORK-IN-PROGRESS; use at your own risk
   -- @param self  Block-grid object. Will be added to
   -- @param inWorld  Block grid-object. Will be inserted
   -- @param x  Whole Number. X-coordinate of inWorld x=1 relative to self
   -- @param y  Whole Number. Y-coordinate of inWorld y=1 relative to self
   -- @param ...  
   insertGrid = function(self, inWorld, x, y, ...)
      if (not self) or (not inWorld)
	 or (not x or x < 1) or (not y and y < 1)
      then
	 -- Invalid parameter(s)
	 return
      end
      
      local grid1_w = self:width()
      local grid1_h = self:height()
      local grid2_w = inWorld:width()
      local grid2_h = inWorld:height()
      
      self:chngSize(math.max(grid1_w, grid2_h), math.max(grid1_h, grid2_h))
      
      --DOIT: this function may or may not be needed; work-in-progress atm
   end,
   
   --- Displays a given block-grid
   -- @param self  Block-grid object
   display = function(self)
      local roomW = self:width()
      local roomH = self:height()
      
      local x_coords = "+  "
      for x = 1, roomW do
	 x_coords = x_coords .. " " .. (x - math.floor(x / 10) * 10)
      end
      x_coords = x_coords .. "\n  +"
      for x = 1, roomW do
	 x_coords = x_coords .. "--"
      end
      print(x_coords)
      
      for y = 1, roomH do
	 local row = (y - math.floor(y / 10) * 10) .. " |"
	 for x = 1, roomW do
	    local blockID = self[x][y]
	    local add
	    if blockID == 0 then
	       add = " -"
	    elseif blockID == 1 then
	       add = " #"
	    else
	       add = " ?"
	    end
	    row = row .. add
	 end
	 print(row)
      end
   end
}




blockGrid_mt = {
   __index = blockGrid_obj
}




setmetatable(blockGrid, blockGrid_mt)
