# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
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

        RESTRICT_ON_SEND = %i[config_param].freeze

        # @!method config_param_default_time?(node)
        def_node_matcher :config_param_default_string_time?, <<~PATTERN
          (send nil? :config_param (sym _) (sym :time) (hash (pair (sym :default) (str _))))
        PATTERN

        def on_send(node)
          return unless config_param_default_string_time?(node)

          symbol = node.children[2]
          parameter = symbol.value
          message = "The value of :#{parameter} must be `integer` or `float` for default time value."
          add_offense(node, message: message)
          ignore_node(node)
        end
        alias on_csend on_send
      end
    end
  end
end
