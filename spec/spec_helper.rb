# frozen_string_literal: true

require "prism"

module Prism
  # NOTE: Prism::Node#== is same with BasicObject#==.
  #       Prism::Node#=== is same with Kernel#===.
  #       Prism::Node#=== for each sub class only checks location existence.
  #
  #       E.g. AndNode#=== is like below
  #
  #         other.is_a?(AndNode) &&
  #           (left === other.left) &&
  #           (right === other.right) &&
  #           (operator_loc.nil? == other.operator_loc.nil?)
  #
  class Node
    def ==(other)
      self === other
    end
  end

  class StringNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.content_loc == other.content_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class InterpolatedStringNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class SymbolNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.content_loc == other.content_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class InterpolatedSymbolNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class XStringNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.content_loc == other.content_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class InterpolatedXStringNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class EmbeddedStatementsNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class RegularExpressionNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.content_loc == other.content_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class InterpolatedRegularExpressionNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class IfNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.if_keyword_loc == other.if_keyword_loc &&
        self.then_keyword_loc == other.then_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class UnlessNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.if_keyword_loc == other.if_keyword_loc &&
        self.then_keyword_loc == other.then_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class MatchLastLineNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.content_loc == other.content_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class CaseNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.case_keyword_loc == other.case_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class AndNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class OrNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class AliasMethodNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class AliasGlobalVariableNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class UndefNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class LocalVariableVariableReadNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location
      end
    }
  end

  class LocalVariableWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class InstanceVariableReadNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location
      end
    }
  end

  class InstanceVariableWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ClassVariableReadNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location
      end
    }
  end

  class ClassVariableWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class GlobalVariableReadNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location
      end
    }
  end

  class GlobalVariableWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ConstantReadNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location
      end
    }
  end

  class ConstantPathNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.delimiter_loc == other.delimiter_loc &&
        self.name_loc == other.name_loc
      end
    }
  end

  class IndexOperatorWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.call_operator_loc == other.call_operator_loc &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc &&
        self.binary_operator_loc == other.binary_operator_loc
      end
    }
  end

  class CallOperatorWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.call_operator_loc == other.call_operator_loc &&
        self.message_loc == other.message_loc &&
        self.binary_operator_loc == other.binary_operator_loc
      end
    }
  end

  class LocalVariableAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class InstanceVariableAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ClassVariableAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class GlobalVariableAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ConstantAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ConstantPathAndWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class LocalVariableOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class InstanceVariableOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ClassVariableOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class GlobalVariableOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ConstantOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class ConstantPathOrWriteNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class CallNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.call_operator_loc == other.call_operator_loc &&
        self.message_loc == other.message_loc &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class SplatNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class BeginNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.begin_keyword_loc == other.begin_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class RescueNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class EnsureNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.ensure_keyword_loc == other.ensure_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class HashNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class AssocNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class AssocSplatNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class SuperNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc &&
        self.lparen_loc == other.lparen_loc &&
        self.rparen_loc == other.rparen_loc
      end
    }
  end

  class BlockParametersNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end

  class OptionalParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class RestParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class RequiredKeywordParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc
      end
    }
  end

  class OptionalKeywordParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc
      end
    }
  end

  class KeywordRestParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class BlockParameterNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.name_loc == other.name_loc &&
        self.operator_loc == other.operator_loc
      end
    }
  end

  class WhenNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc &&
        self.then_keyword_loc == other.then_keyword_loc
      end
    }
  end

  class ElseNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.else_keyword_loc == other.else_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class BreakNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class NextNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class ReturnNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc
      end
    }
  end

  class YieldNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc &&
        self.lparen_loc == other.lparen_loc &&
        self.rparen_loc == other.rparen_loc
      end
    }
  end

  class ForNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.for_keyword_loc == other.for_keyword_loc &&
        self.in_keyword_loc == other.in_keyword_loc &&
        self.do_keyword_loc == other.do_keyword_loc &&
        self.end_keyword_loc == other.end_keyword_loc
      end
    }
  end

  class PostExecutionNode
    prepend Module.new {
      def ===(other)
        super(other) &&
        self.location == other.location &&
        self.keyword_loc == other.keyword_loc &&
        self.opening_loc == other.opening_loc &&
        self.closing_loc == other.closing_loc
      end
    }
  end
end

require "simplecov"

SimpleCov.start do
  track_files "lib/**/*.rb"

  add_filter "spec/"

  enable_coverage :branch
end

require "ast_to_prism"

module RSpecHelper
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include(RSpecHelper)

  # Allow to limit the run of the specs
  # NOTE: Please do not commit the filter option.
  # config.filter_run_when_matching :focus
end
