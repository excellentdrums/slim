require 'helper'

class ::MockError < NameError
end

class TestSlimTemplate < MiniTest::Unit::TestCase
  class Scope
  end

  def test_registered_extension
    assert_equal Slim::Template, Tilt['test.slim']
  end

  def test_preparing_and_evaluating
    template = Slim::Template.new { |t| "p Hello World!\n" }
    assert_equal "<p>Hello World!</p>", template.render
  end

  def test_passing_locals
    template = Slim::Template.new { "p = 'Hey ' + name + '!'\n" }
    assert_equal "<p>Hey Joe!</p>", template.render(Object.new, :name => 'Joe')
  end

  def test_evaluating_in_an_object_scope
    template = Slim::Template.new { "p = 'Hey ' + @name + '!'\n" }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "<p>Hey Joe!</p>", template.render(scope)
  end

  def test_passing_a_block_for_yield
    template = Slim::Template.new { "p = 'Hey ' + yield + '!'\n" }
    assert_equal "<p>Hey Joe!</p>", template.render { 'Joe' }
  end

  def test_backtrace_file_and_line_reporting_without_locals
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?h
    template = Slim::Template.new('test.slim', 10) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      assert_equal 'test.slim', line.split(":").first
    end
  end

  def test_backtrace_file_and_line_reporting_with_locals
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?h
    template = Slim::Template.new('test.slim') { data }
    begin
      res = template.render(Object.new, :name => 'Joe', :foo => 'bar')
    rescue => boom
      assert_kind_of MockError, boom
      line = boom.backtrace.first
      assert_equal 'test.slim', line.split(":").first
    end
  end

  def test_compiling_template_source_to_a_method
    template = Slim::Template.new { |t| "Hello World!" }
    template.render(Scope.new)
    method = template.send(:compiled_method, [])
    assert_kind_of UnboundMethod, method
  end
  

  def test_passing_locals
    template = Slim::Template.new { "p = 'Hey ' + name + '!'\n" }
    assert_equal "<p>Hey Joe!</p>", template.render(Scope.new, :name => 'Joe')
  end

  def test_evaluating_in_an_object_scope
    template = Slim::Template.new { "p = 'Hey ' + @name + '!'\n" }
    scope = Scope.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal "<p>Hey Joe!</p>", template.render(scope)
  end

  def test_passing_a_block_for_yield
    template = Slim::Template.new { "p = 'Hey ' + yield + '!'\n" }
    assert_equal "<p>Hey Joe!</p>", template.render(Scope.new) { 'Joe' }
  end

  def backtrace_file_and_line_reporting_without_locals
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?h
    template = Slim::Template.new('test.slim', 10) { data }
    begin
      template.render(Scope.new)
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      assert_equal 'test.slim', line.split(":").first
    end
  end

  def test_backtrace_file_and_line_reporting_with_locals
    data = File.read(__FILE__).split("\n__END__\n").last
    fail unless data[0] == ?h
    template = Slim::Template.new('test.slim') { data }
    begin
      res = template.render(Scope.new, :name => 'Joe', :foo => 'bar')
    rescue => boom
      assert_kind_of MockError, boom
      line = boom.backtrace.first
      assert_equal 'test.slim', line.split(":").first
    end
  end
end

__END__
html
  body
    h1 = "Hey #{name}"

    = raise MockError

    p we never get here
