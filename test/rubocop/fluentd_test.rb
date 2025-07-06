# frozen_string_literal: true

require "test_helper"

class Rubocop::FluentdTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Rubocop::Fluentd.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end
end
