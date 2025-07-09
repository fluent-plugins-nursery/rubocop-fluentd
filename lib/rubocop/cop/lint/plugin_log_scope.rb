# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
      # @example Lint/FluentdPluginLogLevel: (default)
      #
      #   # bad
      #   $log.trace("...")
      #   $log.debug("...")
      #   $log.info("...")
      #   $log.warn("...")
      #   $log.error("...")
      #   $log.fatal("...")
      #
      #   # good
      #   log.trace("...")
      #   log.debug("...")
      #   log.info("...")
      #   log.warn("...")
      #   log.error("...")
      #   log.fatal("...")
      #
      # @example Lint/FluentdPluginLogLevel: block
      #
      #   # bad
      #   $log.trace("...")
      #   $log.debug("...")
      #
      #   # good
      #   $log.trace { "..." }
      #   $log.debug { "..." }
      #
      class FluentdPluginLogScope < Base
        include IgnoredNode
        extend AutoCorrector

        MSG = 'Use plugin scope `log` instead of global scope `$log`.'

        # Detect only supported log level
        RESTRICT_ON_SEND = %i[trace debug info warn error fatal].freeze
        RESTRICT_ON_BLOCK = %i[trace debug info warn error fatal].freeze

        # @!method global_log_method?(node)
        def_node_matcher :global_reciever_method?, <<~PATTERN
          (send gvar $_ $(...))
        PATTERN

        # @!method global_reciever_block_method?(node)
        def_node_matcher :global_reciever_block_method?, <<~PATTERN
          (block (send gvar $_) _ $(...))
        PATTERN

        def on_send(node)
          return if part_of_ignored_node?(node)
          expression = global_reciever_method?(node)
          return unless expression

          # $log.method(...)
          if send_global_log_node?(node)
            add_offense(node) do |corrector|
              method = expression.first
              literal = expression.last
              source_code = "log.#{method} { #{literal.source} }"
              # $log.xxx => log.xxx
              corrector.replace(node, source_code)
            end
          end
        end

        def on_block(node)
          expression = global_reciever_block_method?(node)
          return unless expression

          # $log.method { ... }
          send_node = node.children.first
          if send_global_log_node?(send_node)
            add_offense(node) do |corrector|
              source_code = "log.#{block_log_level_method(node)}"
              # $log.xxx => log.xxx
              corrector.replace(node.children.first, source_code)
            end
            # mark do not match on_send further more
            ignore_node(node)
          end
        end

        def log_level_method(node)
          node.children[1]
        end

        def block_log_level_method(node)
          send_node = node.children.first
          send_node.children.last
        end

        def send_global_log_node?(node)
          node.class == RuboCop::AST::SendNode and
            global_log_reciever?(node.children.first)
        end

        def global_log_reciever?(node)
          node.name == :$log
        end
      end
    end
  end
end
