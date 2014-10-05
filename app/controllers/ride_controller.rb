class RideController < ApplicationController
	include RideHelper

	def show
	end

	def new_ride
		@new_user = User.create(phone_number: params[:phone_number], start_location: params[:start_location], end_location: params[:end_location])

		drivers = []
		#for all drivers check how far away they are, remember only those closer than radius
		Driver.all.each do |d|
			if distance(d.current_location, @new_user.start_location) < RADIUS
				drivers.push(d)
			end
		end

		#define local variables for costs
		costs_newuser = {}
		costs_infoaboutcab = {}

		#for every driver calculate cost of transportation for user 1
		drivers.each do |d|
			if d.users.count == 0 #if the driver is not driving anyone
				cost = distance(@new_user.start_location, @new_user.end_location) * RATES[0]
				costs_newuser[d.id] = [cost + FLAT_RATE]

			#for cabs with 1 user, check what is the cheapest route, prioritize the guy on the cab
			#when it comes to leaving the cab.
			elsif d.users.count == 1
				
				#if we can improve the cost for both users splitting the costs
			  if change_route?(d, d.users[0], @new_user)[0] 
			  	#remember the cost for new user
			  	costs_newuser[d.id] = change_route?(d, d.users[0], @new_user)[1]
			  	#and remember who gets off first, what is the cost for the old user
			  	#[user1_lowerNewCost, whoGetsOffFirst, whoGetsOffSecond]
			  	costs_infoaboutcab[d.id] = change_route?(d, d.users[0], @new_user)[2..4]
			  else
			  	costs_newuser[d.id] = change_route?(d, d.users[0], @new_user)[1]
			  end	

		  else

			end
		end
		@estimated_price = costs_newuser.values.min[0]
		@saved_cost = costs_newuser.values.max[0] - @estimated_price
		#if we save anything (this means that we share the cab)
		if @save_cost > 0
			#if the driver has not yet picked up the guy you share with, set route
			if(driver.route.length > 1)
			  driver.route = [d.users[0].start_location, @new_user.start_location, costs_infoaboutcab[1].end_location, costs_infoaboutcab[2].end_location]
			 #if the driver has already picked up the guy we share with
		  elsif (driver.route.length == 1)
        driver.route = [@new_user.start_location, costs_infoaboutcab[1].end_location, costs_infoaboutcab[2].end_location]
      end
    #if we are not sharing
		else
			driver.route = [@new_user.start_location, @new_user.end_location]
		end
		#update costs for both users and add the new user to driver
		d.users[0].cost = costs_infoaboutcab[0]
		@new_user.cost = @estimated_price
		driver.user << @new_user

		redirect_to "ride#show"
		end
	end

