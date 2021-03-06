class RideController < ApplicationController
	include RideHelper

	def home
	end

  	def about
  		@note = Note.all
	end	

	def show
		@driver = Driver.find(params[:id])
	end

	def dropoff
		Driver.find(params[:driver_id]).users = []
		Driver.find(params[:driver_id]).save!

		redirect_to root_path
	end

	def new_ride
		@new_user = User.create(phone_number: params[:phone_number], start_location: params[:start_location], end_location: params[:end_location])

		Note.create(tag: "User", message: @new_user.id.to_s + " asks for a ride.")
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
				Note.create(tag: "UBER", message: "Driver" + d.id.to_s + " has no passengers. Estimated cost is $#{'%.02f' % cost}." )
				@uber_profit = 0
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

			  	costs_infoaboutcab[d.id] = a
			  	Note.create(tag: "UBER", message: "Estimated lower shared cost for User" + @new_user.id.to_s + " is $#{'%.02f' % costs_newuser[d.id][0]}" + ".")
			  	Note.create(tag: "UBER", message: "Estimated lower shared cost for User" + d.users[0].id.to_s + " (already in cab) is $#{'%.02f' % costs_infoaboutcab[d.id][2]}" + ".")
			  	@uber_profit = costs_infoaboutcab[d.id][3].to_s
	
			  else
			  	#array not float
			  	costs_newuser[d.id] = [change_route?(d, d.users[0], @new_user)[1]]
			  	Note.create(tag: "UBER", message: "Estimated cost for User" + @new_user.id.to_s + " is $#{'%.02f' % costs_newuser[d.id][0]}" + ".")
			  	@uber_profit = 0
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
		     @driver.route = [@driver.current_location, d.users[0].start_location, @new_user.start_location, costs_infoaboutcab[@driver.id][4].end_location, costs_infoaboutcab[@driver.id][5].end_location].to_s
			 @driver.users[0].cost = costs_infoaboutcab[@driver.id][1]
			 Note.create(tag: "UBER", message: "Found User" + @new_user.id.to_s + " a beneficial ride to share. Rerouting the driver to pick up the other passenger. Stop points: " + @driver.route.to_s)
			 @saved_cost_old_user = costs_infoaboutcab[@driver.id].last
			 #if the driver has already picked up the guy we share with
		  else
           @driver.route = [@driver.current_location, @new_user.start_location, costs_infoaboutcab[@driver.id][4].end_location, costs_infoaboutcab[@driver.id][5].end_location].to_s
           @driver.users[0].cost = costs_infoaboutcab[@driver.id][1]
           Note.create(tag: "UBER", message: "Found User" + @new_user.id.to_s + " a beneficial ride to join. Rerouting the driver to pick up User" + @new_user.id.to_s + ". Stop points: " + @driver.route.to_s + ".")
           @saved_cost_old_user = costs_infoaboutcab[@driver.id].last
          end
        #if we are not sharing
		else
			@driver.route = [@driver.current_location, @new_user.start_location, @new_user.end_location].to_s

		Note.create(tag: "UBER", message: "Cannot find User" + @new_user.id.to_s + " a beneficial ride to share. Sending a separate ride. Stop points: " + @driver.route.to_s + ".")
		@saved_cost_old_user = 0
		@uber_profit = 0
		end

		#update costs for both users and add the new user to driver
		@new_user.cost = @estimated_price
		@driver.users << @new_user
    	@driver.save!
    	@new_user.save!

		redirect_to :controller => 'ride', :action => 'show', :id => @driver.id, :saved_cost_new_user => @saved_cost, :saved_cost_old_user => @saved_cost_old_user, :uber_profit => @uber_profit
	end
end
