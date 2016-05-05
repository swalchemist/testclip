#!/usr/bin/env ruby

require_relative '../CommandProcessor.rb'
require 'test/unit'
require 'rr'

class TestCommandProcessor < Test::Unit::TestCase

    def stest_cs_no_length
		c = CommandProcessor.new
		stub(c).pbcopy { nil }
		assert_raise() { c.cs() }
    end

    def test_cs_one
		c = CommandProcessor.new
		stub(c).pbcopy { nil }
		c.cs("cs", "1")
		assert_received(c) {|c| c.pbcopy("**") }
    end

end
