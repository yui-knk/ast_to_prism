# frozen_string_literal: true

require "prism"

RSpec.describe "basic test cases return same nodes with prism" do
  include Module.new {
    def test_code(code)
      node = AstToPrism::Parser.new(code)
      actual = node.parse
      expected = Prism.parse(code).value

      expect(actual).to eq expected
    end
  }

  describe "nil" do
    it "tests" do
      test_code("nil")
    end
  end

  describe "true" do
    it "tests" do
      test_code("true")
    end
  end

  describe "false" do
    it "tests" do
      test_code("false")
    end
  end

  describe "self" do
    it "tests" do
      test_code("self")
    end
  end

  describe "integer" do
    it "tests" do
      test_code("1")
    end

    it "tests" do
      test_code("-1")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0b1")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("01")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0o1")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0x1")
    end
  end

  describe "float" do
    it "tests" do
      test_code("1.2")
    end

    it "tests" do
      test_code("-1.2")
    end
  end

  describe "rational" do
    it "tests" do
      test_code("1r")
    end

    it "tests" do
      test_code("-1r")
    end

    it "tests" do
      test_code("1.0r")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0b1r")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("01r")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0o1r")
    end

    it "tests" do
      pending "Need to expose `base` for flags"

      test_code("0x1r")
    end

    it "tests" do
      test_code("1.2r")
    end
  end

  describe "imaginary" do
    it "tests" do
      test_code("1i")
    end

    it "tests" do
      test_code("-1i")
    end

    it "tests" do
      test_code("1.0i")
    end

    it "tests" do
      test_code("1ri")
    end

    it "tests" do
      test_code("1.0ri")
    end
  end

  describe "symbol" do
    it "tests" do
      test_code(":sym")
    end
  end

  describe "string" do
    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code(<<~CODE)
        "str"
      CODE
    end

    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code(<<~CODE)
        'str'
      CODE
    end

    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code("?a")
    end

    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code(<<~CODE)
        # frozen_string_literal: true
        'str'
      CODE
    end
  end

  describe "xstring" do
    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code("`xstr`")
    end

    it "tests" do
      pending "opening_loc, content_loc and closing_loc are not supported"

      test_code(<<~CODE)
        # frozen_string_literal: true
        `xstr`
      CODE
    end
  end

  describe "array" do
    it "tests" do
      test_code("[]")
      test_code("[1, 2]")
    end
  end

  describe "hash" do
    it "tests" do
      test_code("{a: 1}")
    end
  end

  describe "range" do
    it "tests" do
      test_code("1..5")
      test_code("1...5")
    end
  end

  describe "local variable" do
    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        foo = 0
      CODE
    end

    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        foo = 0
        foo
      CODE
    end
  end

  describe "dynamic local variable" do
    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        1.times do
          x = 1
        end
      CODE
    end

    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        1.times do
          x = 1
          x
        end
      CODE
    end

    it "tests" do
      pending "name_loc, operator_loc and depth are not supported"

      test_code(<<~CODE)
        foo = 0
        tap {
          foo = 1
        }
      CODE
    end

    it "tests" do
      pending "name_loc, operator_loc and depth are not supported"

      test_code(<<~CODE)
        tap {
          foo = 1
          tap {
            tap {
              foo = 2
            }
          }
        }
      CODE
    end
  end

  describe "instance variable" do
    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        @foo = 0
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        @foo
      CODE
    end
  end

  describe "class variable" do
    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        @@foo = 0
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        @@foo
      CODE
    end
  end

  describe "global variable" do
    it "tests" do
      pending "name_loc and operator_loc are not supported"

      test_code(<<~CODE)
        $foo = 0
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        $foo
      CODE
    end
  end

  describe "constant (CONST node)" do
    it "tests" do
      test_code(<<~CODE)
        A
      CODE
    end
  end

  describe "constant (COLON2 node)" do
    it "tests" do
      pending "delimiter_loc and name_loc are not supported"

      test_code(<<~CODE)
        A::B
      CODE
    end
  end

  describe "constant (COLON3 node)" do
    it "tests" do
      pending "delimiter_loc and name_loc are not supported"

      test_code(<<~CODE)
        ::A
      CODE
    end

    it "tests" do
      pending "delimiter_loc and name_loc are not supported"

      test_code(<<~CODE)
        ::A::B
      CODE
    end
  end

  describe "constant with expr" do
    it "tests" do
      test_code(<<~CODE)
      pending "delimiter_loc and name_loc are not supported"

        expr::A
      CODE
    end
  end

  describe "super" do
    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super 1")
    end

    it "tests" do
      test_code("super(1)")
    end

    it "tests" do
      test_code("super 1 do end")
    end

    it "tests" do
      test_code("super 1 do 2 end")
    end

    it "tests" do
      test_code("super(1) {}")
    end

    it "tests" do
      test_code("super(1) { 2 }")
    end
  end

  describe "zsuper" do
    it "tests" do
      test_code("super")
    end

    it "tests" do
      test_code("super {  }")
    end

    it "tests" do
      test_code("super { 1 }")
    end
  end

  describe "__LINE__" do
    it "tests" do
      test_code("__LINE__")
    end
  end

  describe "__FILE__" do
    it "tests" do
      test_code("__FILE__")
    end
  end

  describe "__ENCODING__" do
    it "tests" do
      test_code("__ENCODING__")
    end
  end

  describe "and" do
    it "tests" do
      pending "operator_loc is not supported"

      test_code("1 && 2")
    end

    it "tests" do
      pending "operator_loc is not supported"

      test_code("1 and 2")
    end
  end

  describe "or" do
    it "tests" do
      pending "operator_loc is not supported"

      test_code("1 || 2")
    end

    it "tests" do
      pending "operator_loc is not supported"

      test_code("1 or 2")
    end
  end

  describe "call" do
    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj.foo(1, 2)")
    end

    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj.foo 1, 2")
    end

    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj.foo(1) { 3 }")
    end
  end

  describe "opcall" do
    it "tests" do
      pending "message_loc is not supported"

      test_code("foo + bar")
    end
  end

  describe "qcall" do
    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj&.foo(1, 2)")
    end

    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj&.foo 1, 2")
    end

    it "tests" do
      pending "call_operator_loc, message_loc, opening_loc and closing_loc are not supported"

      test_code("obj&.foo(1, 2) { 3 }")
    end
  end

  describe "fcall" do
    it "tests" do
      pending "message_loc, opening_loc and closing_loc are not supported"

      test_code("foo(1, 2)")
    end

    it "tests" do
      pending "message_loc, opening_loc and closing_loc are not supported"

      test_code("foo(1, 2) { 3 }")
    end
  end

  describe "vcall" do
    it "tests" do
      test_code("foo")
    end
  end

  describe "iter" do
    it "tests" do
      pending "opening_loc and closing_loc are not supported"

      test_code("3.times { foo = 1; foo }")
    end

    it "tests" do
      pending "opening_loc and closing_loc are not supported"

      test_code(<<~CODE)
        3.times do
          foo = 1
          foo
        end
      CODE
    end

    it "tests" do
      test_code("3.times {  }")
    end

    it "tests" do
      test_code(<<~CODE)
        3.times do
        end
      CODE
    end


    it "tests" do
      test_code("3.times { |i| foo = 1; foo }")
    end

    it "tests" do
      test_code(<<~CODE)
        3.times do |i|
          foo = 1
          foo
        end
      CODE
    end
  end

  describe "class" do
    it "tests" do
      test_code(<<~CODE)
        class A
          a = 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        class A < B
          a = 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        class A::B < C::D
          a = 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        class ::A < ::B
          a = 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        class ::A::B < ::C::D
          a = 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        class expr1::B < expr2::D
          a = 1
        end
      CODE
    end
  end

  describe "sclass" do
    it "tests" do
      test_code(<<~CODE)
        class << obj
          a = 1
        end
      CODE
    end
  end

  describe "module" do
    it "tests" do
      test_code(<<~CODE)
        module C
          a = 1
        end
      CODE
    end
  end

  describe "defn" do
    it "tests" do
      test_code(<<~CODE)
        def m
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m(a, b)
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m a, b
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m = 1
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m(a, b) = a + b
      CODE
    end
  end

  describe "defs" do
  end

  describe "args" do
    it "tests" do
      test_code(<<~CODE)
        def foo(a, b, opt1=1, opt2=2, *rest, y, z, kw: 1, **kwrest, &blk)
        end
      CODE
    end
  end

  describe "if" do
    it "tests" do
      test_code("if true then 1 else 2 end")
    end
  end

  describe "elsif" do
    it "tests" do
      test_code("if true then 1 elsif 2 then 3 end")
    end
  end

  describe "modifier if" do
    it "tests" do
      pending "if_keyword_loc, then_keyword_loc and end_keyword_loc are not supported"

      test_code("1 if true")
    end
  end

  describe "unless" do
    it "tests" do
      test_code("unless true then 1 else 2 end")
    end
  end

  describe "modifier unless" do
    it "tests" do
      pending "if_keyword_loc, then_keyword_loc and end_keyword_loc are not supported"

      test_code("1 unless true")
    end
  end

  describe "while" do
    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code(<<~CODE)
        while x == 1 do
          foo
        end
      CODE
    end

    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code(<<~CODE)
        while x == 1
          foo
        end
      CODE
    end
  end

  describe "modifier while" do
    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code("foo while true")
    end

    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code("begin foo end while true")
    end
  end

  describe "until" do
    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code(<<~CODE)
        until x == 1 do
          foo
        end
      CODE
    end

    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code(<<~CODE)
        until x == 1
          foo
        end
      CODE
    end
  end

  describe "modifier until" do
    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code("foo until true")
    end

    it "tests" do
      pending "keyword_loc and closing_loc are not supported"

      test_code("begin foo end until true")
    end
  end

  describe "flip-flap" do
    it "tests" do
      pending "IfNode and StringNode need to support locations"

      test_code("if 'a'..'z'; foo; end")
    end

    it "tests" do
      pending "IfNode and StringNode need to support locations"

      test_code("if 'a'...'z'; foo; end")
    end

    it "tests for integer range" do
      pending "Need to remove special treatment for IntegerNode flip-flap. See: range_op"

      test_code("if 1..5; foo; end")
    end

    it "tests for integer range" do
      pending "Need to remove special treatment for IntegerNode flip-flap. See: range_op"

      test_code("if 1...5; foo; end")
    end
  end

  describe "alias" do
    it "tests" do
      test_code("alias bar foo")
    end

    it "tests" do
      test_code("alias :bar :foo")
    end
  end

  describe "valias" do
    it "tests" do
      test_code("alias $y $x")
    end
  end

  describe "undef" do
    it "tests" do
      test_code("undef foo")
    end

    it "tests" do
      test_code("undef foo :bar")
    end
  end

  describe "break" do
    it "tests" do
      test_code(<<~CODE)
        10.times do |i|
          break
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        10.times do |i|
          break 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        10.times do |i|
          break 1, 2
        end
      CODE
    end
  end

  describe "return" do
    it "tests" do
      pending "Need to keep RETURN NODE"

      test_code(<<~CODE)
        def m
          return
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m
          return 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m
          return 1, 2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m
          if a
            en
          return 1, 2
        end
      CODE
    end
  end

  describe "begin, rescue, else, ensure" do
    it "tests" do
      pending "begin_keyword_loc and end_keyword_loc are not supported"

      test_code(<<~CODE)
        begin
        end
      CODE
    end

    it "tests" do
      pending "Need to keep BEGIN node"

      test_code(<<~CODE)
        begin
          1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
        rescue
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue
          2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue StandardError
          2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue => e
          2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue StandardError => e
          2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue ArgumentError => e
          2
        rescue ArgumentError => @e
          3
        rescue ArgumentError => @@e
          4
        rescue ArgumentError => $e
          5
        rescue ArgumentError => E
          6
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        e = 0

        1.times do
          begin
            1
          rescue NoMethodError => e
            2
          end
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue NoMethodError, ArgumentError => e
          2
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
        rescue
        else
        ensure
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        begin
          1
        rescue
          2
        else
          3
        ensure
          4
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        def m
          1
        rescue
          2
        else
          3
        ensure
          4
        end
      CODE
    end
  end

  describe "case with head" do
    it "tests" do
      test_code(<<~CODE)
        case x
        when 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        case x
        when 1 then
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        case x
        when 1
          :a
        when 2, 3
          :b
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        case x
        when 1
          :a
        when 2, 3
          :b
        else
          :c
        end
      CODE
    end
  end

  describe "case with no head" do
    it "tests" do
      test_code(<<~CODE)
        case
        when 1
          :a
        when 2, 3
          :b
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        case
        when 1
        end
      CODE
    end

    it "tests" do
      test_code(<<~CODE)
        case
        when 1
          :a
        when 2, 3
          :b
        else
          :c
        end
      CODE
    end
  end

  describe "parentheses" do
    it "tests" do
      pending "Need to introduce ParenthesesNode"

      test_code("()")
    end

    it "tests" do
      pending "Need to introduce ParenthesesNode"

      test_code("(1)")
    end

    it "tests" do
      pending "Need to introduce ParenthesesNode"

      test_code("((1))")
    end
  end

  describe "statements" do
    it "tests" do
      test_code(<<~CODE)
        true
        false
      CODE
    end
  end
end
