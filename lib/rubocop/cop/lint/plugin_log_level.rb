# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @safety
      #   Delete this section if the cop is not unsafe (`Safe: false` or
      #   `SafeAutoCorrect: false`), or use it to explain how the cop is
      #   unsafe.
      #
      # @example Lint/PluginLogLevel: (default)
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
      # @example Lint/PluginLogLevel: block
      #
      #   # bad
      #   $log.trace("...")
      #   $log.debug("...")
      #
      #   # good
      #   $log.trace { "..." }
      #   $log.debug { "..." }
      #
      class FluentPluginLogLevel < Base
        include IgnoredNode

        MSG = 'Use plugin scope `log` instead of global scope `$log`.'

        # Detect only supported log level
        RESTRICT_ON_SEND = %i[trace debug info warn error fatal].freeze
        RESTRICT_ON_BLOCK = %i[trace debug info warn error fatal].freeze

        # @!method global_log_method?(node)
        def_node_matcher :global_reciever_method?, <<~PATTERN
          (send gvar ...)
        PATTERN

        # @!method global_reciever_block_method?(node)
        def_node_matcher :global_reciever_block_method?, <<~PATTERN
          (block (send gvar ...) ...)
        PATTERN

        # Called on every `send` node (method call) while walking the AST.
        # TODO: remove this method if inspecting `send` nodes is unneeded for your cop.
        # By default, this is aliased to `on_csend` as well to handle method calls
        # with safe navigation, remove the alias if this is unnecessary.
        # If kept, ensure your tests cover safe navigation as well!
        def on_send(node)
          return if part_of_ignored_node?(node)
          return unless global_reciever_method?(node)

          # $log.method(...)
          if send_global_log_node?(node)
            add_offense(node)
          end
        end

        def on_block(node)
          return unless global_reciever_block_method?(node)

          # $log.method { ... }
          send_node = node.children.first
          if send_global_log_node?(send_node)
            add_offense(node)
            # mark do not match on_send further more
            ignore_node(node)
          end
        end

        def send_global_log_node?(node)
          node.class == RuboCop::AST::SendNode and
            global_log_reciever?(node.children.first)
        end

        def global_log_reciever?(node)
          node.name == :$log
        end

        alias on_csend on_send
        alias on_cblock on_block
      end
    end
  end
end
