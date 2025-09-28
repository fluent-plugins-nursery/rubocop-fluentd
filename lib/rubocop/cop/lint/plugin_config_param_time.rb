# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # @example FluentdPluginConfigParamDefaultTime (default)
      #
      #   # bad
      #   config_param :interval, :time, :default => '1h'
      #
      #   # good
      #   config_param :interval, :time, :default => 3600
      #
      #   See https://github.com/fluent/fluent-plugin-opensearch/pull/159
      #
      class FluentdPluginConfigParamDefaultTime < Base
        include IgnoredNode
        extend AutoCorrector

        RESTRICT_ON_SEND = %i[config_param].freeze

        # @!method config_param_default_time?(node)
        def_node_matcher :config_param_default_string_time?, <<~PATTERN
          (send nil? :config_param (sym _) (sym :time) (hash (pair (sym :default) (str _))))
        PATTERN

        def on_send(node)
          return unless config_param_default_string_time?(node)

          parameter = config_param_variable(node)
          default = config_param_default(node)
          message = "The value of :#{parameter} must be `integer` or `float` for default time value."

          expression = config_param_default_string_time?(node)
          add_offense(node, message: message) do |corrector|
            seconds = timestr_to_seconds(default)
            source_code = "config_param :#{parameter}, :time, :default => #{seconds}"
            corrector.replace(node, source_code)
          end
          ignore_node(node)
        end

        def config_param_variable(node)
          symbol = node.children[2]
          symbol.value
        end

        def config_param_default(node)
          pair = node.children[4].children.first
          str = pair.children.last
          str.value
        end

        def timestr_to_seconds(literal)
          value = if literal.end_with?("d")
                    literal.delete("d").to_i * 60 * 60 * 24
                  elsif literal.end_with?("h")
                    literal.delete("h").to_i * 60 * 60
                  elsif literal.end_with?("m")
                    literal.delete("m").to_i * 60
                  elsif literal.end_with?("s")
                    literal.delete("s").to_i
                  else
                    literal.to_i
                  end
          value
        end
      end
    end
  end
end
