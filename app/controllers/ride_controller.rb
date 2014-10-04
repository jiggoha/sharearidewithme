class RideController < ApplicationController
	def show
	end

	def new_ride
		new_user = User.new(start_location: "1,1", end_location: "3,1")

		drivers = []
		Drivers.all.each do |d|
			if distance(driver.current_location, new_user.start_location) < RADIUS
				drivers.push(d)
			end
		end

		costs = {}
		driver.each do |d|
			if d.users.count == 0 #if the driver is not driving anyone
				cost = distance(new_user.start_location, new_user.end_location) * RATES[0]
				costs[driver.id] = cost + FLAT_RATE
			else #if the driver is already driving someone
				
			if change_route?(d, d.users[0], new_user)[0] 
				costs[driver.id] = cost 
			end	

			end
		end

		@estimated_price = costs.values.min
		@saved_cost = costs.values.max - @estimated_price
	end
end
