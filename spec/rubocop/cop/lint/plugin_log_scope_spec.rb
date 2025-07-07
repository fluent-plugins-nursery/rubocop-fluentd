# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FluentdPluginLogScope, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `$log`' do
    %w[trace debug info warn error fatal].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        $log.%{keyword}("something")
        ^{keyword}^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use plugin scope `log` instead of global scope `$log`.
      RUBY
    end
  end

  it 'does not register an offense when using `log`' do
    expect_no_offenses(<<~RUBY)
      log.info("something")
    RUBY
  end

  it 'registers an offense when using `$log` {...}' do
    %w[trace debug info warn error fatal].each do |keyword|
      expect_offense(<<~RUBY, keyword: keyword)
        $log.%{keyword} { "something" }
        ^{keyword}^^^^^^^^^^^^^^^^^^^^^ Lint/FluentdPluginLogScope: Use plugin scope `log` instead of global scope `$log`.
      RUBY
    end
  end

  it 'does not register an offense when using `log` {...}' do
    expect_no_offenses(<<~RUBY)
      log.info { "something" }
    RUBY
  end
end
