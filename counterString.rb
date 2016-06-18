#!/usr/bin/ruby

#
# This class generates a counterstring
#
class CounterString
	attr_reader :length

	def initialize(length, pip = "*")
		@length = length
		@pip = pip
	end

	# This is the same algorithm used in perlclip. Despite the frequent reverse 
	# operations, this has good performance because it builds the reversed 
	# string by appending to it.
	def text
		pipRev = @pip.reverse  # might be more than one character
		pos = @length
		text = ""
		while true
			remaining = @length - text.length
			if remaining - pos.to_s.length - pipRev.length < 0
				# last pip, if needed
				text << pipRev[0, remaining]
				break
			end
			# add the pip and counter (when reversed, the pip will follow the counter)
			text << pipRev << pos.to_s.reverse
			pos -= pos.to_s.length + pipRev.length
			redo
		end
		return text.reverse
	end

	# This algorithm is easier to understand than the text method, but the prepend 
	# is much slower on very large strings.
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
