#!/usr/bin/ruby

#
# This class processes each line of input and retains state between commands.
#
class EquivalenceClassifier

	def initialize
		# Store pass/fail results - key = string size, value = result
		@results = Hash.new
	end

	def getResults
		return @results
	end

	def pass(value)
		return passFail(value, "pass")
	end

	def fail(value, comment = nil)
		return passFail(value, "fail", comment)
	end

	# Record test results. Overwrite a previous report for the same value if necessary.
	def passFail(value, result, comment = nil)
		if (value == nil)
			raise "No counterstring to mark."
		else
			wholeLine = result
			if (comment != nil && comment.length > 0)
				wholeLine += " " + comment
			end
			if @results.has_key?(value)
				puts value.to_s + " result changed from " + @results[value] + " to " + wholeLine
			else
				puts value.to_s + " recorded as " + wholeLine
			end
			@results[value] = wholeLine
		end
	end

	def getResults
		return @results
	end

	# Helper. Find a boundary between groups of identical test results. Different boundaries are numbered starting with "1".
	def findBoundary(boundaryNum)
		lower = nil
		upper = nil
		foundBoundary = 0
		if boundaryNum < 1
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
					if foundBoundary == boundaryNum
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
			raise "Boundary '" + boundary.to_s + "' too high - there are only " + foundBoundary.to_s + " boundaries (see 'status')"
		else
			bisect = lower + ((upper - lower) / 2).to_i
			highLow = "highest value for '" + @results[lower] + "': " + lower.to_s + "\n" +
				"lowest value for '" + @results [upper] + "': " + upper.to_s
			if @results.has_key?(bisect)
				puts "Boundary found!"
				puts highLow
			else
				puts highLow
				return bisect
			end
		end
	end

	# Clear previously reported results
	def reset(arguments)
		@results.clear
		puts "pass/fail status is now cleared"
	end

	# Show all test results and the boundaries between group of different results ("pass", "fail", and each "fail <s>")
	def status
		if @results.empty?
			puts "no status yet"
		else
			lastValue = nil
			boundaries = 0
			@results.keys.sort.each do |key| 
				if (lastValue != nil && @results[key] != lastValue)
					boundaries += 1
					puts "--boundary " + boundaries.to_s
				end
				lastValue = @results[key]
				puts key.to_s + ": " + @results[key]
			end
		end
	end

end

