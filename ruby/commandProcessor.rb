#!/usr/bin/ruby

require_relative "counterString.rb"
require_relative "equivalanceClassifier.rb"
require "clipboard"

module Usercode
	def allchars
		allchars = ""
		for t in 1..255
			# Leave out characters that aren't in the Windows-1252 encoding
			if ([129, 141, 143, 144, 157].include?(t))
				next
			end
			allchars += t.chr
		end
		return allchars
	end

	def isolatedEval(arguments)
		return eval arguments.join(" ")
	end
end

#
# This class processes each line of input and retains state between commands.
#
class CommandProcessor
	include Usercode

	def initialize
		# Store pass/fail results - key = string size, value = result
		@results = Hash.new
		# Remember the last test, so test results can be reported
		@lastValue = nil  
		@currentClassifier = nil
		@csClassifier = EquivalenceClassifier.new
		@intClassifier = EquivalenceClassifier.new
	end

	# Copy data to the clipboard (Mac OS)
	def pbcopy(input)
		#str = input.to_s
		#IO.popen('pbcopy', 'w') { |f| f << str }
		Clipboard.copy(input.to_s)
	end

	def help(arguments)
		puts 'code: Execute arbitrary ruby code and put what it returns on the clipboard. The "allchars" variable has ASCII values 1-255.'
		puts 'cs <n>:  Generate a counterstring of length <n>.'
		puts 'pass: Indicate that a test with the last counterstring passed. Used for bisection.'
		puts 'fail <s>: Indicate that a test with the last counterstring failed - optional <s> string distinguishes different failures. Used for bisection.'
		puts 'bisect <n>: Bisect on the given boundary between two different results (see "status"). <n> is "1" by default.'
		puts 'status: Show pass/fail history in equivalance classes.'
		puts 'reset: Remove all pass/fail information and start fresh.'
		puts 'quit: Quit.'
	end

	def getResults
		validateCurrentClassifier
		return @currentClassifier.getResults
	end

	def codeEval(arguments)
		result = isolatedEval(arguments)
		pbcopy result
		puts "code output " << result.length.to_s << " characters long loaded on the clipboard"
	end 

	# Generate a counterstring of given length
	def cs(length, pip)
		if length.nil?
			raise "error - no length given for the counterstring"
		end
		cs = CounterString.new(length, pip)
		@lastValue = length
		text = cs.text
		pbcopy(text)
		@currentClassifier = @csClassifier
		puts "counterstring " << text.length.to_s <<  " characters long loaded on the clipboard"
	end

	def makeInt(value)
		pbcopy(value)
		@lastValue = value
		@currentClassifier = @intClassifier
		puts "integer " << value.to_s << " loaded on the clipboard"
	end

	def validateCurrentClassifier
		if (@currentClassifier == nil)
			raise "No counterstring or int value generated yet"
		end
	end

	def pass()
		validateCurrentClassifier
		return @currentClassifier.pass(@lastValue)
	end

	def fail(comment = nil)
		validateCurrentClassifier
		return @currentClassifier.fail(@lastValue, comment)
	end

	# For a given boundary where behavior changes, do a bisection between them to zero in on where the transition occurs.
	def bisect(boundary)
		newValue = @currentClassifier.bisect(boundary)
		if newValue == nil
			return  # boundary was already found
		end
		@lastValue = newValue
		forClipboard = nil

		# Counterstring or integer
		if @currentClassifier == @csClassifier
			forClipboard = CounterString.new(newValue, "*").text
		else 
			forClipboard = newValue
		end
		pbcopy(forClipboard)
		puts forClipboard.length.to_s <<  " characters loaded on the clipboard"  # TODO: different message for integer
	end

	# Clear previously reported results
	def reset(arguments)
		validateCurrentClassifier
		@currentClassifier.reset
		puts "pass/fail status is now cleared"
	end

	# Show all test results and the boundaries between group of different results ("pass", "fail", and each "fail <s>")
	def status()
		validateCurrentClassifier
		return @currentClassifier.status
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
			when /^int/i
				makeInt(arguments[0].to_i)
			when /^code/i
				codeEval(arguments)
			when /^pass/i 
				pass()
			when /^fail/i
				fail(arguments[0])
			when /^bisect/i
				bisect(arguments[0].to_i)
			when /^reset/i
				reset(arguments)
			when /^status/i
				status()
			else
				raise "Command not recognized."
		end
		return 0
	end
end

