--- Throttler: Throttling library for easy creation of rate limiters and debounces
--- The Buildverse Group | 18 of March 2024
--- Authored by omwot

local Throttler = {}
Throttler.__index = Throttler
Throttler.Interval = 60
Throttler.MaxRequests = 60

local function ThrowDestroyedError()
	error('Destroy() has been called on this throtler and it is no longer usable')
end

local function StartRefreshCycle(self)
	while task.wait(self.Interval) do
		table.clear(self._QuotaUsages)
	end
end

--- Creates a new throttler
function Throttler.new()

	-- Create class
	local self = setmetatable({}, Throttler)
	self._QuotaUsages = {}

	self._RefreshCycle = task.spawn(StartRefreshCycle, self)

	return self
end

function Throttler.__newindex(self, Key, Value)
	
	rawset(self, Key, Value)

	-- Handle changes in interval
	if Key == 'Interval' then
		task.cancel(self._RefreshCycle)
		self._RefreshCycle = task.spawn(StartRefreshCycle, self)
	end

end

--- Returns a boolean determining if there is quota left. If there is quota left, then the quota usage will be incremented
function Throttler:UseQuota(Key: Player | any, Amount: number?)
	local Value = self:GetQuota(Key)

	if Value == 0 then
		return false
	else

		-- Use the quota
		self:SetQuota(Key, self:GetQuota(Key) - (Amount or 1))
		return true
	end

end

--- Checks if a key is above the throttling limit
function Throttler:GetQuota(Key: Player | any): number
	return self.MaxRequests - (self._QuotaUsages[Key] or 0)
end

--- Increments the amount of requests done for a key
function Throttler:SetQuota(Key: Player | any, Amount: number)
	self._QuotaUsages[Key] = self.MaxRequests - Amount
end

--- Cleans up the resources used by the throttler
function Throttler:Destroy()
	
	task.cancel(self._RefreshCycle)
	self.IncrementQuotaUsage = ThrowDestroyedError
	self.GetQuota = ThrowDestroyedError
	self.UseQuota = ThrowDestroyedError
	self.Destroy = ThrowDestroyedError

end

export type Throttler = typeof(Throttler)
return {
	new = Throttler.new :: () -> Throttler,
	prototype = Throttler,
}