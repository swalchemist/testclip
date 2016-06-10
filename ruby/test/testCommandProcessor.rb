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

	def test_codeEval_string
		mock(@c).pbcopy("stringvalue")
		@c.codeEval(['"stringvalue"'])
	end

	def test_codeEval_combined_args
		mock(@c).pbcopy("aaa")
		@c.codeEval(['"a" * 3'])
	end

	def test_codeEval_separate_args
		mock(@c).pbcopy("aaaa")
		@c.codeEval(['"a"', '*', '4'])
	end

	def test_codeEval_syntax_error
		assert_raise(SyntaxError) { @c.codeEval(['"']) }
	end

	def test_allchars
		mock(@c).pbcopy(satisfy {|arg| arg.length == 255})
		@c.codeEval(['allchars'])
	end

end
