#!/usr/bin/ruby

bodystats = Hash.new

#Get stats and save in hash
print "Enter your weight in pounds: "
bodystats ["weight"] = gets.chomp.to_f

print "Enter your height in inches: "
bodystats ["height"] = gets.chomp.to_f

print "Enter your waist line circumference (at naval) in inches: "
bodystats ["waist"] = gets.chomp.to_f

print "Are you cutting, bulking, or maintaining: "
status = gets.chomp.to_s.downcase

puts "How many hours a week do you excercise?"
puts "a: 1 to 3 hours a week"
puts "b: 4 to 6 hours per week"
puts "c: 6 or more hours per week"
puts "Select a, b, or c: "
tdee = gets.chomp.to_s.downcase

bodystats ["leanBodyMass"] = bodystats["weight"] * 1.082 + 94.42 - bodystats["waist"] * 4.15
bodystats ["bodyFatPercentage"] = (bodystats["weight"] - bodystats["leanBodyMass"]) * 100 / bodystats["weight"]
bodystats ["bodyMassIndex"] = (bodystats["weight"] * 0.45) / ((bodystats["height"] * 0.025)**2)
bodystats ["bmr"] = 370 + (21.6 * (bodystats["leanBodyMass"] / 2.2))

case status
  when "cutting"
    if bodystats["bodyFatPercentage"] < 25 
      bodystats ["protien"] = 1.2 * bodystats["weight"]
      bodystats ["carbs"] = 1 * bodystats["weight"]
      bodystats ["fat"] = 0.2 * bodystats["weight"]
      bodystats ["dailyCalories"] = (bodystats["protien"] * 4) + (bodystats["carbs"] * 4) + (bodystats["fat"] * 9)
    elsif bodystats["bodyFatPercentage"] > 25 and bodystats["bodyFatPercentage"] < 30
      bodystats ["protien"] = 0.8 * bodystats["weight"]
      bodystats ["carbs"] = 0.6 * bodystats["weight"]
      bodystats ["fat"] = 0.3 * bodystats["weight"]
      bodystats ["dailyCalories"] = (bodystats["protien"] * 4) + (bodystats["carbs"] * 4) + (bodystats["fat"] * 9)
    elsif bodystats["bodyFatPercentage"] > 30
      bodystats ["dailyCalories"] = bodystats["bmr"] * 1.2
      bodystats ["protien"] = (bodystats["dailyCalories"] * 0.4) / 4
      bodystats ["carbs"] = (bodystats["dailyCalories"] * 0.4) / 4
      bodystats ["fat"] = (bodystats["dailyCalories"] * 0.3) / 9
    end
  when "bulking"
    bodystats ["protien"] = 1 * bodystats["weight"]
    bodystats ["carbs"] = 2 * bodystats["weight"]
    bodystats ["fat"] = 0.4 * bodystats["weight"]
  when "maintaining"
    bodystats ["protien"] = 1 * bodystats["weight"]
    bodystats ["carbs"] = 1.6 * bodystats["weight"]
    bodystats ["fat"] = 0.35 * bodystats["weight"]
  else
    puts "please spellout correctly cutting, bulking, or maintaining"
    exit
end

case tdee
  when "a"
    bodystats ["tdee"] = bodystats["bmr"] * 1.2
  when "b"
    bodystats ["tdee"] = bodystats["bmr"] * 1.35
  when "c"
    bodystats ["tdee"] = bodystats["bmr"] * 1.5
  else
    puts "Please select a, b, or c when answering how many excercises per week!"
    exit
end

puts "Here are the details of your recommended food intake:"
puts ""
puts "Basal Metabolic Rate: #{bodystats["bmr"]} calories burned every 24 hours with no effort."
puts "Total Daily Energy Expenditure: #{bodystats["tdee"]} calories burned every 24 hours with activity included."
puts "Lean Body Mass: #{bodystats["leanBodyMass"]}"
puts "Body Fat Percentage: #{bodystats["bodyFatPercentage"]}"
puts "Body Mass Index: #{bodystats["bodyMassIndex"]}"
puts "Total Daily Calores: #{bodystats["dailyCalories"]} calories"
puts "Amount of protien to eat in grams per day: #{bodystats["protien"]}"
puts "Amount of carbohydrates to eat in grams per day: #{bodystats["carbs"]}"
puts "Amount of fat to eat in grams per day: #{bodystats["fat"]}"



