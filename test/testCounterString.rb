#!/usr/bin/env ruby

require_relative '../counterString.rb'
require 'test/unit'

class TestCounterString < Test::Unit::TestCase

    def test_0
		assert_equal "", CounterString.new(0).text
    end

    def test_1
		assert_equal "*", CounterString.new(1).text
    end

    def test_2
		assert_equal "2*", CounterString.new(2).text
    end

    def test_3
		assert_equal "*3*", CounterString.new(3).text
    end

    def test_pip_simple
		assert_equal "-3-", CounterString.new(3, "-").text
    end

    def test_pip_long
		assert_equal "3{}", CounterString.new(3, "{}").text
    end

    def test_pip_too_long
		assert_equal "}", CounterString.new(1, "{}").text
    end

    def test_double_pip_both_sides
		assert_equal "{}5{}", CounterString.new(5, "{}").text
    end

	def test_1000
		cs = CounterString.new(1000).text
		assert_match(/^[*0-9]{999}\*$/, cs)
		assert_no_match(/\*\*/, cs)
	end

    def test_alt1
		assert_equal CounterString.new(1000).text, CounterString.new(1000).textAltAlgorithm
    end

    def test_alt2
		assert_equal CounterString.new(1001).text, CounterString.new(1001).textAltAlgorithm
    end

end
