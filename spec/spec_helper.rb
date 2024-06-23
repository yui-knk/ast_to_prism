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

  class CaseNode
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
