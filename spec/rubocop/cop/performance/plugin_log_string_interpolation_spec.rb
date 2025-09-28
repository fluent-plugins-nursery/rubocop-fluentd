# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Performance::FluentdPluginLogStringInterpolation, :config do

  it 'registers an offense when using string interpolation for `log` without block' do
    message = "*" * 1024
    %w[trace debug info warn error fatal].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword, message: message)
        log.%{keyword}("\#{message}")
        ^{keyword}^^^^^^^^^^^^^^^^^^ Use log.%{keyword} { "..." } instead of log.%{keyword}("...")
      RUBY
    end
  end

  it 'does not register an offense when no string interpolation for `log`' do
    expect_no_offenses(<<~RUBY)
      log.debug("no string interpolation")
    RUBY
  end

  it 'does not register an offense when using block for `log`' do
    too_long_message = "*" * 1024
    expect_no_offenses(<<~RUBY)
      log.debug { "#{too_long_message}" }
    RUBY
  end
end
