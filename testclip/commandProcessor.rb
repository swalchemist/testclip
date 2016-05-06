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

	def help(arguments)
		puts 'cs <n>:  Generate a counterstring of length <n>.'
		puts 'pass: Indicate that a test with the last counterstring passed. Used for bisection.'
		puts 'fail <s>: Indicate that a test with the last counterstring failed - optional <s> string distinguishes different failures. Used for bisection.'
		puts 'bisect <n>: Bisect on the given boundary between two different results (see "status"). <n> is "1" by default.'
		puts 'status: Show pass/fail history in equivalance classes.'
		puts 'reset: Remove all pass/fail information and start fresh.'
		puts 'quit: Quit.'
	end

	# Generate a counterstring of given length
	def cs(length, pip)
		if length.nil?
			raise "error - no length given for the counterstring"
		else
			cs = CounterString.new(length, pip)
			@lastGenerator = cs
			text = cs.text
			pbcopy(text)
			puts "counterstring " << text.length.to_s <<  " characters long loaded on the clipboard"
		end
	end
		
	def pass()
		return passFail("pass")
	end

	def fail(comment = nil)
		return passFail("fail", comment)
	end

	# Optionally record test results. Overwrite a previous report for the same value if necessary.
	def passFail(result, comment = nil)
		if (@lastGenerator == nil)
			raise "No counterstring to mark."
		else
			wholeLine = result
			if (comment != nil && comment.length > 0)
				wholeLine += " " + comment
			end
			if @results.has_key?(@lastGenerator.length)
				puts @lastGenerator.length.to_s << " result changed from " << @results[@lastGenerator.length] << " to " << wholeLine
			else
				puts @lastGenerator.length.to_s << " recorded as " << wholeLine
			end
			@results[@lastGenerator.length] = wholeLine
		end
	end

	def getResults
		return @results
	end

	# Helper. Find a boundary between groups of identical test results. Different boundaries are numbered starting with "1".
	def findBoundary(boundary)
		lower = nil
		upper = nil
		foundBoundary = 0
		if boundary < 1
			raise "boundary number must be 1 or greater"
		end
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
	def bisect(boundary)
		if @results.length < 2
			raise "can't bisect - need two different test results"
		end
		lower, upper, foundBoundary = findBoundary(boundary)
		if boundary > foundBoundary
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

	# Clear previously reported results
	def reset(arguments)
		@results.clear
		puts "pass/fail status is now cleared"
	end

	# Show all test results and the boundaries between group of different results ("pass", "fail", and each "fail <s>")
	def status(arguments)
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
		command = inputArray[0]
		arguments = inputArray[1, inputArray.length - 1]
		case command
		when /^help/i
			help(arguments)
		when /^quit/i
			return 1  # signal the caller to quit
		when /^cs/i
			cs(arguments[0].to_i, arguments[1] || "*")
		when /^pass/i, 
			pass()
		when /^fail/i
			fail(arguments[0])
		when /^bisect/i
			bisect(arguments[0].to_i)
		when /^reset/i
			reset(arguments)
		when /^status/i
			status(arguments)
		else
			puts "Command not recognized."
		end
		return 0
	end
end

