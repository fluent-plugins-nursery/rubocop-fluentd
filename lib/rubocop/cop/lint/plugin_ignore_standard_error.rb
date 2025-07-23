# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # @example FluentdPluginIgnoreStandardError (default)
      #
      #   # bad
      #   def write
      #     begin
      #       ...
      #     rescue StandardError => e
      #       log.error "Unexpected error: #{e.message}"
      #     end
      #   end
      #
      #   # bad
      #   def write
      #     begin
      #       ...
      #     rescue => e
      #       log.error "Unexpected error: #{e.message}"
      #     end
      #   end
      #
      #   # good
      #   def write
      #     begin
      #       ...
      #       # Do not shelve StandardError here, let StandardError exception handling by Fluentd
      #       raise "something weird"
      #     rescue OtherError => e
      #       log.error "Unexpected error: #{e.message}"
      #     end
      #   end
      #
      class FluentdPluginIgnoreStandardError < Base
        MSG = 'Should not rescue StandardError in #write in usually. StandardError should be handled in Fluentd side. Do it if you know what you are doing.'

        # @!method fluent_plugin?(node)
        def_node_matcher :fluent_plugin?, <<~PATTERN
          (module (const (const nil? :Fluent) :Plugin) $_)
        PATTERN

        # @!method output_plugin?(node)
        def_node_matcher :output_plugin?, <<~PATTERN
          (class (const nil? $_) (const nil? :Output) $(...))
        PATTERN

        # @!method write_method?(node)
        def_node_matcher :write_method?, <<~PATTERN
          (def :write (args (arg _)) $_)
        PATTERN

        # @!method rescue_ndoe?(node)
        def_node_matcher :rescue_node?, <<~PATTERN
          (kwbegin (rescue $_+))
        PATTERN

        # @!method ignore_standard_error?(node)
        def_node_matcher :ignore_standard_error?, <<~PATTERN
          (resbody (array (const nil? :StandardError)) $_ $(...))
        PATTERN

        def on_module(node)
          plugin_node = fluent_plugin?(node)
          unless plugin_node
            return
          end
          process_descendant_class(plugin_node) do |klass_and_node|
            # [klass_name, function]
            klass_and_node.each do |child|
              next if child.is_a?(Symbol)
              process_descendant_def(child) do |def_node|

                method_body =  write_method?(def_node)
                next unless method_body

                # directly below def
                rescue_body = rescue_node?(method_body)
                next unless rescue_body
                rescue_body.each do |resbody_node|
                  next unless resbody_node.is_a?(RuboCop::AST::ResbodyNode)
                  expression = ignore_standard_error?(resbody_node)
                  next unless expression
                  add_offense(resbody_node)
                end
              end
            end
          end
        end

        def process_descendant_def(node)
          if node.is_a?(RuboCop::AST::DefNode)
            yield node
          else
            node.each_descendant(:def) do |def_node|
              yield def_node
            end
          end
        end

        def process_descendant_class(node)
          # under Fluent::Plugin
          if node.is_a?(RuboCop::AST::ClassNode)
            klass_and_node = output_plugin?(node)
            return unless klass_and_node
            yield klass_and_node
          else
            # multiple class under Fluent::Plugin module
            node.each_descendant(:class) do |klass_node|
              klass_and_node = output_plugin?(klass_node)
              # skip except output plugin
              next unless klass_and_node
              yield klass_and_node
            end
          end
        end
      end
    end
  end
end
