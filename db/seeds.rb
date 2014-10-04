# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

driver = Driver.create(current_location: "0,0")

a = User.create(start_location: "0,1", end_location: "2,2")
b = User.create(start_location: "1,1", end_location: "2,3")