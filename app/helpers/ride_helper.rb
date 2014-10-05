module RideHelper
	def distance(a,b)
		a = a.split(",")
		b = b.split(",")

		return ((a[0].to_f - b[0].to_f)**2 + (a[1].to_f - b[1].to_f)**2) ** (0.5)
	end

  def change_route?(driver,user1,user2)
    Note.create(tag: "UBER", message: "Calculating prices for all possible routes...")

    user1_currentcost = distance(user1.start_location, user1.end_location) * RATES[0] + FLAT_RATE
    user2_alonecost = distance(user2.start_location, user2.end_location) * RATES[0] + FLAT_RATE

    #user2 gets off before user1 gets off
    user2_newcost_2f = distance(user2.start_location, user2.end_location) * RATES[1] + FLAT_RATE
    
    user1_newcost_2f = distance(driver.current_location, user2.start_location) * RATES[0] + distance(user2.start_location, user2.end_location) * RATES[1] + distance(user1.end_location, user2.end_location) * RATES[0] + FLAT_RATE

    # user1 gets off after user2 gets off
    user2_newcost_1f = distance(user2.start_location, user2.end_location)*RATES[1] + distance(user1.end_location, user2.end_location) * RATES[0] + FLAT_RATE

    user1_newcost_1f = distance(driver.current_location, user2.start_location) * RATES[0] + distance(user2.start_location, user1.end_location) * RATES[1] + distance(user2.start_location, user2.end_location) * RATES[1] + distance(user1.end_location, user2.end_location)

    Note.create(tag: "UBER", message: "Checking whether adding a passenger is more economical for both passengers...")
    
    if user1_newcost_1f >= user1_newcost_2f
      user1_lowerNewCost = user1_newcost_2f
      whoGetsOffFirst = user2
      whoGetsOffSecond = user1
    else
      user1_lowerNewCost = user1_newcost_1f
      whoGetsOffFirst = user1
      whoGetsOffSecond = user2
    end

    if user2_newcost_1f >= user2_newcost_2f
      user2_lowerNewCost = user2_newcost_2f
    else
      user2_lowerNewCost = user2_newcost_1f
    end

    uber_benefit = user2_lowerNewCost - (user1_currentcost - user1_lowerNewCost)

    if ((user1_currentcost > user1_lowerNewCost) and (user2_alonecost > user2_lowerNewCost))
      Note.create(tag: "UBER", message: "Detected benefit; adding a passenger.")
      [true, user2_lowerNewCost, user1_lowerNewCost, uber_benefit, whoGetsOffFirst, whoGetsOffSecond, user1_currentcost - user1_lowerNewCost]
    else
      Note.create(tag: "UBER", message: "Not economical enough to add a passenger.")
      [false, user2_alonecost, user1_currentcost, 0]
    end
  end
end
