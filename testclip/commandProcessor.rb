#!/usr/bin/ruby

require_relative "counterString.rb"

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

	# Generate a counterstring of given length
	def cs(*inputArray)
		length = inputArray[1]
		if inputArray[2].nil?
			pip = "*"
		else
			pip = inputArray[2]
		end
		if length.nil?
			raise "error - no length given for the counterstring"
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
		case inputArray[0]
		when /^help/i
			help(*inputArray)
		when /^quit/i
			return 1  # signal the caller to quit
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
		return 0
	end
end

