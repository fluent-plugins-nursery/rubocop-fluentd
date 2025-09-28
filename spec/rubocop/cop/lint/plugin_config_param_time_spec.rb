# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FluentdPluginConfigParamDefaultTime, :config do

  WARN_MESSAGE = "#{'^' * 47} The value of :interval must be `integer` or `float` for default time value."

  it 'registers an offense when using 1s for default value' do
    expect_offense(<<~RUBY)
      config_param :interval, :time, :default => "1s"
      #{WARN_MESSAGE}
    RUBY

    expect_correction(<<~RUBY)
      config_param :interval, :time, :default => 1
    RUBY
  end

  it 'registers an offense when using 1m for default value' do
    expect_offense(<<~RUBY)
      config_param :interval, :time, :default => "1m"
      #{WARN_MESSAGE}
    RUBY

    expect_correction(<<~RUBY)
      config_param :interval, :time, :default => 60
    RUBY
  end

  it 'registers an offense when using 1h for default value' do
    expect_offense(<<~RUBY)
      config_param :interval, :time, :default => "1h"
      #{WARN_MESSAGE}
    RUBY

    expect_correction(<<~RUBY)
      config_param :interval, :time, :default => 3600
    RUBY
  end

  it 'registers an offense when using 1d for default value' do
    expect_offense(<<~RUBY)
      config_param :interval, :time, :default => "1d"
      #{WARN_MESSAGE}
    RUBY

    expect_correction(<<~RUBY)
      config_param :interval, :time, :default => 86400
    RUBY
  end

  it 'does not register an offense when using integer' do
    expect_no_offenses(<<~RUBY)
      config_param :interval, :time, :default => 3600
    RUBY
  end

  it 'does not register an offense when using float' do
    expect_no_offenses(<<~RUBY)
      config_param :interval, :time, :default => 3600.0
    RUBY
  end
end
