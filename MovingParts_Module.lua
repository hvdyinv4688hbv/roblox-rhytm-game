-- ================================================
-- MovingParts Module (ModuleScript)
-- Place this ModuleScript anywhere (recommended: ServerScriptService > MovingParts)
-- ================================================

local MovingParts = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- ====================== CONFIG ======================
MovingParts.Settings = {
	MOVE_TIME = 3,                    -- How long it takes to go one way (seconds)
	EASING_STYLE = Enum.EasingStyle.Linear,
	EASING_DIRECTION = Enum.EasingDirection.InOut,
	-- You can override these per-part later if you want (future-proofing)
}

-- ====================== CORE FUNCTION ======================
function MovingParts.CreateInfiniteMover(part: BasePart)
	if not part:IsA("BasePart") then
		return
	end

	local startPosition = part.Position
	local targetPosition = part:GetAttribute("targetPosition")

	if typeof(targetPosition) ~= "Vector3" then
		warn(`[MovingParts] Part "{part.Name}" has 'moving' = true but no valid 'targetPosition' Vector3 attribute!`)
		return
	end

	local tweenInfo = TweenInfo.new(
		MovingParts.Settings.MOVE_TIME,
		MovingParts.Settings.EASING_STYLE,
		MovingParts.Settings.EASING_DIRECTION,
		-1,   -- Repeat forever
		true, -- Reverse (back-and-forth)
		0     -- No delay
	)

	local tween = TweenService:Create(part, tweenInfo, { Position = targetPosition })
	tween:Play()

	-- Store the tween on the part so you can stop/resume it later if needed
	part:SetAttribute("MovingTween", tween)

	-- Optional: Clean up when the part is destroyed
	local connection
	connection = part.Destroying:Connect(function()
		if tween then tween:Cancel() end
		connection:Disconnect()
	end)
end

-- ====================== AUTO-START ======================
function MovingParts.Start()
	-- 1. Find every part that already exists with the 'moving' attribute
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("moving") == true then
			MovingParts.CreateInfiniteMover(descendant)
		end
	end

	-- 2. Listen for any new parts added while the game runs
	Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") and descendant:GetAttribute("moving") == true then
			MovingParts.CreateInfiniteMover(descendant)
		end
	end)

	print("[MovingParts] Module initialized! All parts with 'moving' = true (and a 'targetPosition' attribute) will now loop forever.")
end

-- Return the module so scripts can require it
return MovingParts
