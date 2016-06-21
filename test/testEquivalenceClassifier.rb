#!/usr/bin/env ruby

require_relative '../equivalanceClassifier.rb'
require 'test/unit'
require 'test/unit/rr'

class TestEquivalanceClassifier < Test::Unit::TestCase

	def setup
		@e = EquivalenceClassifier.new
	end

	def test_findBoundary_bad_boundary
		assert_raise(RuntimeError) { @e.findBoundary(0) }
	end

	def test_findBoundary_nil
		assert_equal([nil, nil, 0 ], @e.findBoundary(1))
	end

	def test_findBoundary_single
		@e.pass(1) 
		assert_equal([1, nil, 0 ], @e.findBoundary(1))
	end

	def test_findBoundary_single_block
		@e.pass(2) 
		@e.pass(3) 
		@e.pass(5) 
		assert_equal([5, nil, 0 ], @e.findBoundary(1))
	end

	def test_findBoundary_1
		@e.pass(1) 
		@e.fail(3) 
		assert_equal([1, 3, 1 ], @e.findBoundary(1))
	end

	def test_findBoundary_2
		@e.pass(1) 
		@e.fail(3, "a") 
		@e.fail(100, "b") 
		assert_equal([3, 100, 2], @e.findBoundary(2))
	end

	def test_bisect_no_result
		assert_raise(RuntimeError) { @e.bisect(1) }
	end

	def test_bisect_one_result
		@e.pass(1)
		assert_raise(RuntimeError) { @e.bisect(1) }
	end

	def test_bisect_boundary_out_of_range
		@e.pass(1)
		@e.fail(3)
		assert_raise(RuntimeError) { @e.bisect(2) }
	end

	def test_bisect_good
		@e.pass(1)
		@e.fail(3)
		assert_equal(2, @e.bisect(1))
	end

	def test_bisect_boundary_found
		@e.pass(1)
		@e.fail(2)
		assert_equal(nil, @e.bisect(1))
	end

end
