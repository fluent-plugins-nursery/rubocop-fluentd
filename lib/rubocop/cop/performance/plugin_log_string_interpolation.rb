# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      #
      # @example FluentdPluginLogStringInterpolation: (default)
      #
      #   # bad
      #   log.debug "#{EVALUATE_LONG_MESSAGE}"
      #
      #   # good
      #   log.debug { "#{EVALUATE_LONG_MESSAGE}" }
      #
      class FluentdPluginLogStringInterpolation < Base
        RESTRICT_ON_SEND = %i[trace debug info warn error fatal].freeze

        # @!method log_message_string_interpolation?(node)
        def_node_matcher :log_message_string_interpolation?, <<~PATTERN
          (send (send nil? :log) _ (dstr ...))
        PATTERN

        def on_send(node)
          # match log.debug("#{...}") and so on
          return unless log_message_string_interpolation?(node)

          method = node.children[1].to_s
          msg = %Q(Use log.#{method} { "..." } instead of log.#{method}("..."))
          add_offense(node, message: msg)
          # mark do not match on_send further more
          ignore_node(node)
        end
        alias on_csend on_send
      end
    end
  end
end
