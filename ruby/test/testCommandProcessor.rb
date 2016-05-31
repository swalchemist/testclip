#!/usr/bin/env ruby

require_relative '../CommandProcessor.rb'
require 'test/unit'
require 'rr'

class TestCommandProcessor < Test::Unit::TestCase

	def setup
		@c = CommandProcessor.new
		stub(@c).pbcopy { nil }
	end

    def test_cs_no_length
		dont_allow(@c).pbcopy
		assert_raise(RuntimeError) { @c.cs(nil, "*") }
    end

    def test_cs_one
		mock(@c).pbcopy("*")
		@c.cs(1, "*")
    end

    def test_cs_more
		mock(@c).pbcopy("-3-5-7-10-")
		@c.cs(10, "-")
    end

    def test_pass_no_cs
		assert_raise(RuntimeError) { @c.pass() }
    end

    def test_pass
		@c.cs(1, "*")
		@c.pass() 
		assert_equal(@c.getResults, { 1 => "pass" })
    end

    def test_fail_no_cs 
		assert_raise(RuntimeError) { @c.fail() }
    end

    def test_fail
		@c.cs(1, "*")
		@c.fail() 
		assert_equal(@c.getResults, { 1 => "fail" })
    end

    def test_fail_with_arg
		@c.cs(1, "*")
		@c.fail("condition 1") 
		assert_equal(@c.getResults, { 1 => "fail condition 1" })
    end
end
