# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FluentdPluginConfigParamDefaultTime, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using string for default value' do
    expect_offense(<<~RUBY)
      config_param :interval, :time, :default => "1h"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginConfigParamDefaultTime: The value of :interval must be `integer` or `float` for default time value.
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
