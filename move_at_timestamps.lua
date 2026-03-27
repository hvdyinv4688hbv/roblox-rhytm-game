-- ================================================
-- Roblox Studio Luau Script - TIMESTAMP VERSION
-- Place this as a Script inside ServerScriptService
--
-- WHAT THIS DOES:
--   • Uses a table of TIMESTAMPS (absolute seconds from when the script starts)
--   • The function schedules a move for the Part at EXACTLY those points in time
--   • Example: move at 2 seconds, then at 5.5 seconds, then at 12 seconds, etc.
--   • Uses TweenService for smooth movement (you can change distance, style, etc.)
-- ================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ================== CONFIGURATION ==================

-- Change these to match your game
local MOVING_PART_NAME = "MovingPart"          -- Name of the Part in Workspace
local MOVE_DISTANCE = Vector3.new(0, 10, 0)    -- How far the part moves each time it is triggered
local TWEEN_TIME = 0.8                         -- How long the smooth movement animation lasts
local TWEEN_STYLE = Enum.EasingStyle.Quad
local TWEEN_DIRECTION = Enum.EasingDirection.Out

-- TABLE OF TIMESTAMPS (seconds from script start)
-- Edit this! The function will make the part move at these exact moments.
local timestamps = {
	2,      -- move at exactly 2 seconds
	5.5,    -- move at exactly 5.5 seconds
	9,      -- move at exactly 9 seconds
	12.3,   -- move at exactly 12.3 seconds
	15      -- move at exactly 15 seconds
}

-- ================================================

-- Get the part
local part = workspace:WaitForChild(MOVING_PART_NAME)
part.Anchored = true  -- Required for TweenService to move it reliably

print("Part movement system ready. Timestamps loaded:", timestamps)

-- ================== THE MAIN FUNCTION ==================
-- This is the function you asked for!
-- It takes a Part and a table of timestamps and moves the part at those exact times.
local function movePartAtTimestamps(targetPart: Part, timestampTable: {number})
	if not targetPart or not timestampTable or #timestampTable == 0 then
		warn("movePartAtTimestamps: Missing part or empty timestamp table!")
		return
	end
	
	print(`Starting timestamp-based movement for {targetPart.Name}...`)
	
	-- Schedule a move for each timestamp using task.delay (fires at exact time from now)
	for index, timestamp in ipairs(timestampTable) do
		if timestamp < 0 then
			warn(`Timestamp {timestamp} is in the past - skipping.`)
			continue
		end
		
		task.delay(timestamp, function()
			-- This code runs exactly at the timestamp
			local currentTime = tick()  -- for logging accuracy
			print(`Timestamp {timestamp}s reached at real time {currentTime:.2f}s - Moving part!`)
			
			-- Calculate new position
			local newPosition = targetPart.Position + MOVE_DISTANCE
			
			-- Create smooth tween
			local tweenInfo = TweenInfo.new(
				TWEEN_TIME,
				TWEEN_STYLE,
				TWEEN_DIRECTION
			)
			
			local tweenGoal = { Position = newPosition }
			local tween = TweenService:Create(targetPart, tweenInfo, tweenGoal)
			
			tween:Play()
			
			-- Optional: wait for tween to finish before logging "done"
			-- (uncomment if you want to know when movement ends)
			-- tween.Completed:Wait()
			print(`Move #{index} (at {timestamp}s) completed!`)
		end)
	end
	
	print("All timestamp moves have been scheduled!")
end

-- ================== RUN THE FUNCTION ==================
-- This starts the entire system when the script runs
movePartAtTimestamps(part, timestamps)

-- HOW TO USE:
-- 1. Put a Part named "MovingPart" (or change MOVING_PART_NAME) in Workspace
-- 2. Insert this Script into ServerScriptService
-- 3. Edit the "timestamps" table with whatever seconds you need
-- 4. Play the game → the part will move exactly at each time you listed!
--
-- ================================================
