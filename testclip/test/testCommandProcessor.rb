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
		assert_raise() { @c.cs(nil, "*") }
    end

    def test_cs_one
		@c.cs(1, "*")
		assert_received(@c) {|c| c.pbcopy("*") }
    end

    def test_cs_more
		@c.cs(10, "-")
		assert_received(@c) {|c| c.pbcopy("-3-5-7-10-") }
    end

    def test_pass_no_cs
		assert_raise { @c.pass() }
    end

    def test_pass
		@c.cs(1, "*")
		@c.pass() 
		assert_equal(@c.getResults, { 1 => "pass" })
    end

    def test_fail_no_cs 
		assert_raise { @c.fail() }
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

	def test_findBoundary_bad_boundary
		assert_raise { @c.findBoundary(0) }
	end

	def test_findBoundary_nil
		assert_equal([nil, nil, 0 ], @c.findBoundary(1))
	end

	def test_findBoundary_single
		@c.cs(1, "*")
		@c.pass() 
		assert_equal([1, nil, 0 ], @c.findBoundary(1))
	end

	def test_findBoundary_single_block
		@c.cs(2, "*")
		@c.pass() 
		@c.cs(3, "*")
		@c.pass() 
		@c.cs(5, "*")
		@c.pass() 
		assert_equal([5, nil, 0 ], @c.findBoundary(1))
	end

	def test_findBoundary_1
		@c.cs(1, "*")
		@c.pass() 
		@c.cs(3, "*")
		@c.fail() 
		assert_equal([1, 3, 1 ], @c.findBoundary(1))
	end

	def test_findBoundary_2
		@c.cs(1, "*")
		@c.pass() 
		@c.cs(3, "*")
		@c.fail("a") 
		@c.cs(100, "*")
		@c.fail("b") 
		assert_equal([3, 100, 2], @c.findBoundary(2))
	end

end
