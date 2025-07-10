# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Fluentd
    # A plugin that integrates rubocop-fluentd with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-fluentd',
          version: VERSION,
          homepage: "https://github.com/fluent-plugins-nursery/rubocop-fluentd",
          description: "Custom Cop for Fluentd plugins"
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
