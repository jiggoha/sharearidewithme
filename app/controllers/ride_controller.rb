class RideController < ApplicationController
	def show
	end

	def new_ride
		@new_user = User.new(start_location: "1,1", end_location: "3,1")

		drivers = []
		#for all drivers check how far away they are, remember only those closer than radius
		Drivers.all.each do |d|
			if distance(driver.current_location, @new_user.start_location) < RADIUS
				drivers.push(d)
			end
		end

		#define local variables for costs
		costs_newuser = {}
		costs_infoaboutcab = {}

		#for every driver calculate cost of transportation for user 1
		driver.each do |d|
			if d.users.count == 0 #if the driver is not driving anyone
				cost = distance(@new_user.start_location, @new_user.end_location) * RATES[0]
				costs_newuser[driver.id] = [cost + FLAT_RATE]

			#for cabs with 1 user, check what is the cheapest route, prioritize the guy on the cab
			#when it comes to leaving the cab.
			elsif d.users.count == 1
				
				#if we can improve the cost for both users splitting the costs
			  if change_route?(d, d.users[0], @new_user)[0] 
			  	#remember the cost for new user
			  	costs_newuser[driver.id] = change_route?(d, d.users[0], @new_user)[1]
			  	#and remember who gets off first, what is the cost for the old user
			  	#[user1_lowerNewCost, whoGetsOffFirst, whoGetsOffSecond]
			  	costs_infoaboutcab[driver.id] = change_route?(d, d.users[0], @new_user)[2..4]
			  else
			  	costs_newuser[driver.id] = change_route?(d, d.users[0], @new_user)[1]
			  end	

		  else

			end
		end

		@estimated_price = costs.values.min
		@saved_cost = costs.values.max - @estimated_price
		#if we save anything (this means that we share the cab)
		if @save_cost > 0
			#if the driver has not yet picked up the guy you share with, set route
			if(driver.route.length > 1)
			  driver.route = [d.users[0].start_location, @new_user.start_location, costs_infoaboutcab[1].end_location, costs_infoaboutcab[2].end_location]
			 #if the driver has already picked up the guy we share with
		  elsif (driver.route.length == 1)
        driver.route = [@new_user.start_location, costs_infoaboutcab[1].end_location, costs_infoaboutcab[2].end_location]
    #if we are not sharing
		else
			driver.route = [@new_user.start_location, @new_user.end_location]
		end
      
		end
	end
end
