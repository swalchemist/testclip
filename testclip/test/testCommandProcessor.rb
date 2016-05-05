#!/usr/bin/env ruby

require_relative '../CommandProcessor.rb'
require 'test/unit'
require 'rr'

class TestCommandProcessor < Test::Unit::TestCase

    def test_cs_no_length
		c = CommandProcessor.new
		stub(c).pbcopy { nil }
		assert_raise() { c.cs(nil, "*") }
    end

    def test_cs_one
		c = CommandProcessor.new
		stub(c).pbcopy { nil }
		c.cs(1, "*")
		assert_received(c) {|c| c.pbcopy("*") }
    end

    def test_cs_more
		c = CommandProcessor.new
		stub(c).pbcopy { nil }
		c.cs(10, "-")
		assert_received(c) {|c| c.pbcopy("-3-5-7-10-") }
    end

end
