# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::FluentdPluginIgnoreStandardError, :config do

  it 'warn if plugin #write ignores StandardError with assignment' do
    message = "Should not rescue StandardError in #write in usually. StandardError should be handled in Fluentd side. Do it if you know what you are doing."
    expect_offense(<<~RUBY, message: message)
      require 'fluent/plugin/output'
      module Fluent::Plugin
        class Ignore < Output
          def write(chunk)
            begin
              p "something"
            rescue StandardError => e
            ^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
              log.error "Unexpected error"
            end
          end
        end
      end
    RUBY
  end

  it 'warn if plugin #write ignores StandardError without assignment' do
    message = "Should not rescue StandardError in #write in usually. StandardError should be handled in Fluentd side. Do it if you know what you are doing."
    expect_offense(<<~RUBY, message: message)
      require 'fluent/plugin/output'
      module Fluent::Plugin
        class Ignore < Output
          def write(chunk)
            begin
              p "something"
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ #{message}
              log.error "Unexpected error"
            end
          end
        end
      end
    RUBY
  end

  it 'warn if plugin #write ignores multiple errors especially StandardError without assignment' do
    message = "Should not rescue StandardError in #write in usually. StandardError should be handled in Fluentd side. Do it if you know what you are doing."
    expect_offense(<<~RUBY, message: message)
      require 'fluent/plugin/output'
      module Fluent::Plugin
        class SomeError < StandardError; end
        class Ignore < Output
          def write(chunk)
            begin
              p "something"
              p "weird"
            rescue SomeError
              p log.error "Unexpected SomeError"
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ #{message}
              log.error "Unexpected error"
            end
          end
        end
      end
    RUBY
  end

  it 'warn if plugin #write ignores multiple errors especially StandardError without assignment (config_param)' do
    message = "Should not rescue StandardError in #write in usually. StandardError should be handled in Fluentd side. Do it if you know what you are doing."
    expect_offense(<<~RUBY, message: message)
      require 'fluent/plugin/output'
      module Fluent::Plugin
        class Ignore < Output
          config_param :someparam, :string, default: nil
          def write(chunk)
            begin
              p "something"
            rescue SomeError
              p log.error "Unexpected SomeError"
            rescue StandardError
            ^^^^^^^^^^^^^^^^^^^^ #{message}
              log.error "Unexpected error"
            end
          end
        end
      end
    RUBY
  end
end
