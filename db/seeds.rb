# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#A
driver0 = Driver.create(current_location: "-3,0")
driver1 = Driver.create(current_location: "-2,5")
driver2 = Driver.create(current_location: "-3,4")
driver3 = Driver.create(current_location: "0,3")
driver4 = Driver.create(current_location: "-1,-4")
driver5 = Driver.create(current_location: "-5,-4")



user0 = User.create(start_location: "-3,0", end_location: "4,2")
user1 = User.create(start_location: "-2,5", end_location: "10,0")
user4 = User.create(start_location: "-1,-4", end_location: "5,-4")
user5 = User.create(start_location: "-5,-4", end_location: "6,0")


driver0.users << user0
driver0.route = "[\"4,2\"]"

driver1.users << user1
driver1.route = "[\"-2,5\",\"10,0\"]"

driver4.users << user4
driver4.route = "[\"-1,-4\",\"5,-4\"]"

driver5.users << user5
driver5.route = "[\"-5,-4\",\"6,0\"]"