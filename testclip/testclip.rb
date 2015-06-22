#!/usr/bin/ruby

# testclip, by Danny R. Faught and inspired by James Bach's perlclip code
# Copyright 2015 and licensed under GPLv3

# This script generates "counterstrings" - self-documenting test data like "*3*5*7*10*" and "2*4*6*8*11*" that help you test
# various string lengths. If you report the status of the tests run with the counterstrings, the script will help you use
# bisection to find exactly what point when increasing the string length that a failure or other behavior change occurs.

# This script is designed for MacOS (small changes to pbcopy can make it portable elsewhere)

#
# This class generates a counterstring
#
class CounterString
	attr_reader :length

	def initialize(length, pip)
		@length = length
		@pip = pip
	end

	# This is the same algorithm used in perlclip. Despite the frequent reverse operations, this has good performance
	# because it builds the reversed string by appending to it.
	def text
		pos = @length
		target = pos
		text = ""
		while true
			if text.length + pos.to_s.length + 1 > target
				# last pip, if needed
				text << @pip * (target - text.length)
				break
			end
			# add the pip and counter (when reversed, the pip will follow the counter)
			text << @pip << pos.to_s.reverse
			pos -= pos.to_s.length + 1
			redo
		end
		return text.reverse
	end

	# This algorithm is easier to understand than the text method, but the prepend is much slower on very large strings.
	def textAltAlgorithm
		string = ""
		marker = @length
		while (string.length < @length)
			remaining = @length - string.length
			toAdd = remaining.to_s + @pip
			# Add a counter and pip until there's no more room
			if (remaining >= toAdd.length)
				string.prepend(toAdd)
			else
				string.prepend(@pip)
			end
		end
		return string
	end
end

#
# This class processes each line of input and retains state between commands.
#
class CommandProcessor

	def initialize
		# Store pass/fail results - key = string size, value = result
		@results = Hash.new
		# Remember the last test, so test results can be reported
		@lastGenerator = nil  
	end

	# Copy data to the clipboard (Mac OS)
	def pbcopy(input)
		str = input.to_s
		IO.popen('pbcopy', 'w') { |f| f << str }
	end

	def help(*inputArray)
		puts 'cs <n>:  Generate a counterstring of length <n>.'
		puts 'pass: Indicate that a test with the last counterstring passed. Used for bisection.'
		puts 'fail <s>: Indicate that a test with the last counterstring failed - optional <s> string distinguishes different failures. Used for bisection.'
		puts 'bisect <n>: Bisect on the given boundary between two different results (see "status"). <n> is "1" by default.'
		puts 'status: Show pass/fail history in equivalance classes.'
		puts 'reset: Remove all pass/fail information and start fresh.'
		puts 'quit: Quit.'
	end

	# Generate a counterstring of given lenth
	def cs(*inputArray)
		length = inputArray[1]
		if inputArray[2].nil?
			pip = "*"
		else
			pip = inputArray[2]
		end
		if length.nil?
			puts "error - no length given for the counterstring"
		else
			cs = CounterString.new(length.to_i, pip)
			@lastGenerator = cs
			text = cs.text
			pbcopy(text)
			puts "counterstring " << text.length.to_s <<  " characters long loaded on the clipboard"
		end
	end
		
	# Optionally record test results. Overwrite a previous report for the same value if necessary.
	def passFail(*inputArray)
		if (@lastGenerator == nil)
			puts "No counterstring to mark."
		else
			wholeLine = inputArray.join(" ")
			if @results.has_key?(@lastGenerator.length)
				puts @lastGenerator.length.to_s << " result changed from " << @results[@lastGenerator.length] << " to " << wholeLine
			else
				puts @lastGenerator.length.to_s << " recorded as " << wholeLine
			end
			@results[@lastGenerator.length] = wholeLine
		end
	end

	# Helper. Find a boundary between groups of identical test results. Different boundaries are numbered starting with "1".
	def findBoundary(boundary)
		lower = nil
		upper = nil
		foundBoundary = 0
		@results.keys.sort.each do |key|
			if lower == nil
				lower = key
			else
				if @results[key] == @results[lower]
					lower = key
					next
				else
					foundBoundary += 1
					if foundBoundary == boundary
						upper = key
						break
					else
						lower = key
					end
				end
			end
		end
		return lower, upper, foundBoundary
	end

	# For a given boundary where behavior changes, do a bisection between them to zero in on where the transition occurs.
	def bisect(*inputArray)
		if inputArray[1].nil?
			boundary = 1
		else
			boundary = inputArray[1].to_i
		end
		if boundary < 1
			puts "boundary number must be 1 or greater"
		else
			lower, upper, foundBoundary = findBoundary(boundary)
			if foundBoundary < 1
				puts "can't bisect - need two different test results"
			elsif boundary > foundBoundary
				puts "Boundary '" << boundary.to_s << "' too high - there are only " << foundBoundary.to_s << " boundaries (see 'status')"
			else
				bisect = lower + ((upper - lower) / 2).to_i
				highLow = "highest value for '" << @results[lower] << "': " << lower.to_s << "\n" <<
					"lowest value for '" << @results [upper] << "': " << upper.to_s
				if @results.has_key?(bisect)
					puts "Boundary found!"
					puts highLow
				else
					cs = CounterString.new(bisect, "*")
					@lastGenerator = cs
					text = cs.text
					pbcopy(text)
					puts "bisecting on boundary " << boundary.to_s
					puts highLow
					puts text.length.to_s <<  " characters loaded on the clipboard"
				end
			end
		end
	end

	# Clear previously reported results
	def reset(*inputArray)
		@results.clear
		puts "pass/fail status is now cleared"
	end

	# Show all test results and the boundaries between group of different results ("pass", "fail", and each "fail <s>")
	def status(*inputArray)
		if @results.empty?
			puts "no status yet"
		else
			lastValue = nil
			boundaries = 0
			@results.keys.sort.each do |key| 
				if (lastValue != nil && @results[key] != lastValue)
					boundaries += 1
					puts "--boundary " << boundaries.to_s
				end
				lastValue = @results[key]
				puts key.to_s << ": " << @results[key]
			end
		end
	end

	# Command dispatcher
	def processCommand(*inputArray)
		quitFlag = 0  # 1 means it's time to quit
		case inputArray[0]
		when /^help/i
			help(*inputArray)
		when /^quit/i
			quitFlag = 1
		when /^cs/i
			cs(*inputArray)
		when /^pass/i, /^fail/i
			passFail(*inputArray)
		when /^bisect/i
			bisect(*inputArray)
		when /^reset/i
			reset(*inputArray)
		when /^status/i
			status(*inputArray)
		else
			puts "Command not recognized."
		end
		return quitFlag
	end
end

#
# Main loop
#
puts 'Ready to generate. Type "help" for help.'
processor = CommandProcessor.new
while true
	puts
	inputArray = STDIN.gets.chomp.split
	break if processor.processCommand(*inputArray) == 1
end

