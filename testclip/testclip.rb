#!/usr/bin/ruby

# testclip, by Danny R. Faught and inspired by James Bach's perlclip code
# Copyright 2016 and licensed under GPLv3

# This script generates "counterstrings" - self-documenting test data like 
# "*3*5*7*10*" and "2*4*6*8*11*" that help you test various string lengths. 
# If you report the status of the tests run with the counterstrings, the 
# script will help you use bisection to find exactly what point when 
# increasing the string length that a failure or other behavior change occurs.

# This script is designed for MacOS (small changes to pbcopy can make it portable elsewhere)

require_relative "CommandProcessor.rb" 

#
# Main loop
#
puts 'Ready to generate. Type "help" for help.'
processor = CommandProcessor.new
while true
	puts
	inputArray = STDIN.gets.chomp.split
	begin 
		break if processor.processCommand(*inputArray) == 1
	rescue
		puts "ERROR: ", $!
	end
end

