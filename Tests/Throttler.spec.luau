--- Throttler.spec: Test file for the throttler class
--- The Buildverse Group | 18 of March 2024
--- Authored by omwot

return function ()
	local Throttler = require(script.Parent.Parent)

	local TestThrottler = nil

	beforeEach(function()
		TestThrottler = Throttler.new()

		-- 5 requests per second
		TestThrottler.MaxRequests = 5
		TestThrottler.Interval = 0.5
	end)

	afterEach(function()
		TestThrottler:Destroy()
	end)
	
	describe('Constructor Throttler.new()', function()

		it('Should create a new throttler', function()
			expect(Throttler.new()).to.be.ok()
		end)

	end)

	describe('Throttler:GetQuota()', function()
		
		it('Should return a number', function()
			expect(TestThrottler:GetQuota('TestKey')).to.be.a('number')
		end)

		it('Should be equal to the quota if no requests were performed', function()
			expect(TestThrottler:GetQuota('TestKey')).to.equal(TestThrottler.MaxRequests)
		end)

	end)

	describe('Throttler:SetQuota()', function()
		
		it('Should set the quota', function()
			TestThrottler:SetQuota('TestKey', 2)
			expect(TestThrottler:GetQuota('TestKey')).to.equal(2)
		end)

	end)

	describe('Throttler:UseQuota()', function()
		
		it('Should use up the quota', function()
			expect(TestThrottler:UseQuota('TestKey')).to.equal(true)
			expect(TestThrottler:GetQuota('TestKey')).to.equal(TestThrottler.MaxRequests - 1)
		end)

		it('Should return false if the quota was exhausted', function()
			TestThrottler:SetQuota('TestKey', 0)
			expect(TestThrottler:UseQuota('TestKey')).to.equal(false)
		end)
	end)

	describe('Property Throttler.Interval', function()

		it('Should not refresh quota before interval', function()

			-- Simulate 2 requests
			TestThrottler:UseQuota('TestKey', 2)
			task.wait(TestThrottler.Interval / 2)
			expect(TestThrottler:GetQuota('TestKey')).to.equal(TestThrottler.MaxRequests - 2)

		end)

		it('Should refresh uota after interval', function()

			TestThrottler:UseQuota('TestKey', 2)
			task.wait(TestThrottler.Interval)
			expect(TestThrottler:GetQuota('TestKey')).to.equal(TestThrottler.MaxRequests)

		end)
	end)

	describe('Property Throttler.MaxRequests', function()

		it('Should be the amount of requests that can be performed each interval', function()
			TestThrottler:UseQuota('TestKey', TestThrottler.MaxRequests)
			expect(TestThrottler:GetQuota('TestKey')).to.equal(0)
		end)

		it('Should be updatable', function()

			local PreMaxRequests = TestThrottler.MaxRequests
			TestThrottler:UseQuota('TestKey', PreMaxRequests)
			TestThrottler.MaxRequests = PreMaxRequests + 5
			expect(TestThrottler:GetQuota('TestKey')).to.equal(5)
		end)
	end)

	describe('Destructor Throttler:Destroy()', function()

		it('Should be able to clean up resources', function()
			TestThrottler:Destroy()
		end)
	end)
end