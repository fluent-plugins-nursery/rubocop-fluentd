# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FluentdPluginLogScope, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `$log` info or more important one without block' do
    %w[info warn error fatal].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        $log.%{keyword}("something")
        ^{keyword}^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use plugin scope `log` instead of global scope `$log`.
      RUBY

      expected = "log.#{keyword} \"something\"\n"
      expect_correction(expected)
    end
  end

  it 'does not register an offense when using `log`' do
    expect_no_offenses(<<~RUBY)
      log.info("something")
    RUBY
  end

  it 'registers an offense when using `$log` trace or debug without block' do
    %w[trace debug].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        $log.%{keyword}("something")
        ^{keyword}^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use plugin scope `log` instead of global scope `$log`.
      RUBY

      expected = "log.#{keyword} { \"something\" }\n"
      expect_correction(expected)
    end
  end

  it 'registers an offense when using log with variable expansion' do
    keyword = "too long"
    %w[trace debug].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        log.#{keyword} "something \#{keyword}"
        ^{keyword}^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use block not to evaluate too long message
      RUBY
      expect_correction(<<~RUBY)
        log.#{keyword} { "something \#{keyword}" }
      RUBY
    end
  end

  it 'registers an offense when using `$log` {...}' do
    %w[trace debug info warn error fatal].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        $log.%{keyword} { "something" }
        ^{keyword}^^^^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use plugin scope `log` instead of global scope `$log`.
      RUBY

      expect_correction(<<~RUBY)
        log.#{keyword} { "something" }
      RUBY
    end
  end

  it 'does not register an offense when using `log` {...}' do
    expect_no_offenses(<<~RUBY)
      log.info { "something" }
    RUBY
  end

  it 'does not register an offense when using `log.info` "\#{keyword}"' do
    %w[info warn error fatal].each do |keyword|
      expect_no_offenses(<<~RUBY, keyword: keyword)
        log.#{keyword} "something \#{keyword}"
      RUBY
    end
  end
end
