class RideController < ApplicationController
	include RideHelper

	def home
	end

	def show
		@driver = Driver.find(params[:id])
	end

	def dropoff
		Driver.find(params[:driver_id]).users = []
		Driver.find(params[:driver_id]).save!
	end

	def new_ride
		@new_user = User.create(phone_number: params[:phone_number], start_location: params[:start_location], end_location: params[:end_location])

		Note.create(tag: "User" + @new_user.id.to_s, message: "Asks for a ride.")
        Note.create(tag: "UBER", message: "Receives request. Checks for availability of cars arond User" + @new_user.id.to_s + ".")

		drivers = []
		#for all drivers check how far away they are, remember only those closer than radius
		Driver.all.each do |d|
			if distance(d.current_location, @new_user.start_location) < RADIUS
				drivers.push(d)
			end
		end

		Note.create(tag: "UBER", message: "Calculating the cheapest ride...")

		#define local variables for costs
		costs_newuser = {}
		costs_infoaboutcab = {}
		#for every driver calculate cost of transportation for user 1
		drivers.each do |d|
			Note.create(tag: "UBER", message: "Checking whether Driver" + d.id.to_s + " has passengers...")

			if d.users.count == 0 #if the driver is not driving anyone
				cost = distance(@new_user.start_location, @new_user.end_location) * RATES[0] + FLAT_RATE
				costs_newuser[d.id] = [cost]
				Note.create(tag: "UBER", message: "Driver" + d.id.to_s + " has no passengers. Estimated cost is " + cost.to_s + ".")

			#for cabs with 1 user, check what is the cheapest route, prioritize the guy on the cab
			#when it comes to leaving the cab.
			elsif d.users.count == 1
				#if we can improve the cost for both users splitting the costs	
				Note.create(tag: "UBER", message: "Driver" + d.id.to_s + " has 1 passenger.")	
			  if (a = change_route?(d, d.users[0], @new_user))[0]
			  	#remember the cost for new user
			  	#We want an array not a float!
			  	costs_newuser[d.id] = [a[1]]
			  	#and remember who gets off first, what is the cost for the old user
			  	#[user1_lowerNewCost, whoGetsOffFirst, whoGetsOffSecond]
			  	costs_infoaboutcab[d.id] = a[2..4]
			  else
			  	#array not float
			  	costs_newuser[d.id] = [change_route?(d, d.users[0], @new_user)[1]]
			  end	
			end
		end

		Note.create(tag: "UBER", message: "Choosing the most economical path and driver.")
		@estimated_price = costs_newuser.values.min[0]
		@saved_cost = costs_newuser.values.max[0] - @estimated_price

		costs_newuser.each{|key, value|
			if value == costs_newuser.values.min 
				@driver = Driver.find(key)
			end
		}

		#if we save anything (this means that we share the cab)
		if @saved_cost > 0
			#if the driver has not yet picked up the guy you share with, set route
		  if(!@driver.route.nil? and @driver.route.length > 1)
		     @driver.route = [d.users[0].start_location, @new_user.start_location, costs_infoaboutcab[@driver.id][1].end_location, costs_infoaboutcab[@driver.id][2].end_location].to_s
			 @driver.users[0].cost = costs_infoaboutcab[0]
			 Note.create(tag: "UBER", message: "Found User" + @new_user.id.to_s + " a beneficial ride to share. Rerouting the driver to pick up the other passenger. Stop points: " + @driver.route)

			 #if the driver has already picked up the guy we share with
		  else
           @driver.route = [@new_user.start_location, costs_infoaboutcab[@driver.id][1].end_location, costs_infoaboutcab[@driver.id][2].end_location].to_s
           @driver.users[0].cost = costs_infoaboutcab[0]
           Note.create(tag: "UBER", message: "Found User" + @new_user.id.to_s + " a beneficial ride to join. Rerouting the driver to pick up User" + @new_user.id.to_s + ". Stop points: " + @driver.route + ".")
          end
        #if we are not sharing
		else
			@driver.route = [@new_user.start_location, @new_user.end_location].to_s
		Note.create(tag: "UBER", message: "Cannot find User" + @new_user.id.to_s + " a beneficial ride to share. Sending a separate ride. Stop points: " + @driver.route + ".")
		end

		#update costs for both users and add the new user to driver
		@new_user.cost = @estimated_price
		@driver.users << @new_user
    	@driver.save!
    	@new_user.save!
		redirect_to :controller => 'ride', :action => 'show', :id => @driver.id, :saved_cost => @saved_cost
	end
end
