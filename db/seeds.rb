# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

driver1 = Driver.create(current_location: "-5,0")
driver2 = Driver.create(current_location: "-3,2")
driver3 = Driver.create(current_location: "-4.5,2")
driver4 = Driver.create(current_location: "-4,-2")
driver5 = Driver.create(current_location: "-3,-3")
driverA = Driver.create(current_location: "0,0")

a = User.create(start_location: "0,1", end_location: "2,2")
driverA.users << a
driverA.route = "[\"0,1\",\"2,2\"]"