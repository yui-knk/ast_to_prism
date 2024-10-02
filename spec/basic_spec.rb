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
      pending "flags, opening_loc, value_loc and closing_loc are not supported"

      test_code(":sym")
    end
  end

  describe "symbol literal with interpolation" do
    it "tests" do
      pending "InterpolatedSymbolNode locations are not supported"

      test_code(<<~'CODE')
        :"foo#{ bar }baz"
      CODE
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

  describe "string literal with interpolation" do
    it "tests" do
      pending "InterpolatedStringNode locations are not supported"

      test_code(<<~'CODE')
        "foo#{ bar }baz"
      CODE
    end

    it "tests" do
      pending "InterpolatedStringNode locations are not supported"

      test_code(<<~'CODE')
        # frozen_string_literal: true
        "foo#{ bar }baz"
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

  describe "xstring literal with interpolation" do
    it "tests" do
      pending "InterpolatedXStringNode locations are not supported"

      test_code(<<~'CODE')
        `foo#{ bar }baz`
      CODE
    end

    it "tests" do
      pending "InterpolatedXStringNode locations are not supported"

      test_code(<<~'CODE')
        # frozen_string_literal: true
        `foo#{ bar }baz`
      CODE
    end
  end

  describe "regex" do
    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code("/foo/")
    end

    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code("/foo/o")
    end

    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code("/(?<var>foo)/")
    end

    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code("/(?<var>foo)/o")
    end
  end

  describe "regexp literal with interpolation (DREGX)" do
    it "tests" do
      pending "InterpolatedRegularExpressionNode locations are not supported"

      test_code('/foo#{ bar }baz/')
    end

    it "tests" do
      pending "InterpolatedRegularExpressionNode locations are not supported"

      test_code('/foo#{ bar }baz#{ bar2 }baz2/')
    end
  end

  describe "array" do
    it "tests" do
      test_code("[]")
    end

    it "tests" do
      test_code("[1, 2]")
    end
  end

  describe "hash" do
    it "tests" do
      pending "opening_loc and closing_loc of Hash are not supported"

      test_code("{}")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc and location of AssocNode are not supported"

      test_code("{a: 1}")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc and location of AssocNode are not supported"

      test_code("{:a => 1}")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc of AssocSplatNode are not supported"

      test_code("{ **foo }")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc of AssocSplatNode are not supported"

      test_code("{a: 1, **foo }")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc of AssocSplatNode are not supported"

      test_code("{ **foo, b: 2}")
    end

    it "tests" do
      pending "opening_loc and closing_loc of Hash & operator_loc of AssocSplatNode are not supported"

      test_code("{a: 1, **foo, b: 2}")
    end
  end

  describe "range" do
    it "tests" do
      test_code("1..5")
    end

    it "tests" do
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

  describe "lambda" do
    it "tests" do
      test_code(<<~CODE)
        -> { foo }
      CODE
    end

    it "tests" do
      pending "LambdaNode locations are not supported"

      test_code(<<~CODE)
        -> (a, b) { foo }
      CODE
    end

    it "tests" do
      pending "LambdaNode locations are not supported"

      test_code(<<~CODE)
        -> a, b { foo }
      CODE
    end

    it "tests" do
      pending "LambdaNode locations are not supported"

      test_code(<<~CODE)
        -> (a, b; l1, l2) { foo }
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
      pending "delimiter_loc and name_loc are not supported"

      test_code(<<~CODE)
        expr::A
      CODE
    end
  end

  describe "nth special variable reference (NTH_REF)" do
    it "tests" do
      test_code(<<~CODE)
        $1
      CODE
    end
  end

  describe "back special variable reference (BACK_REF)" do
    it "tests" do
      test_code(<<~CODE)
        $&
      CODE
    end
  end

  describe "match expression (against $_ implicitly) (MATCH)" do
    it "tests" do
      pending "MatchLastLineNode locations are not supported"

      test_code(<<~CODE)
        if /foo/
          bar
        end
      CODE
    end
  end

  describe "match expression (regexp first) (MATCH2)" do
    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code(<<~CODE)
        /foo/ =~ 'bar'
      CODE
    end

    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code(<<~CODE)
        /(?<var>foo)/ =~ 'bar'
      CODE
    end
  end

  describe "match expression (regexp second) (MATCH3)" do
    it "tests" do
      pending "CallNode locations are not supported"

      test_code(<<~'CODE')
        'bar' =~ /foo#{v1}/
      CODE
    end

    it "tests" do
      pending "CallNode locations are not supported"

      test_code(<<~'CODE')
        'bar' =~ /(?<var>foo)#{v1}/
      CODE
    end
  end

  describe "match expression (NODE_CALL)" do
    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code(<<~'CODE')
        'bar' =~ /foo/
      CODE
    end

    it "tests" do
      pending "RegularExpressionNode locations are not supported"

      test_code(<<~'CODE')
        'bar' =~ /(?<var>foo)/
      CODE
    end
  end

  describe "attr assignment (ATTRASGN)" do
    it "tests" do
      pending "CallNode locations are not supported"

      test_code(<<~CODE)
        struct.field = foo
      CODE
    end

    it "tests" do
      pending "CallNode locations are not supported"

      test_code(<<~CODE)
        obj["key"] = bar
      CODE
    end
  end

  describe "array assignment with operator (OP_ASGN1)" do
    it "tests" do
      pending "IndexOperatorWriteNode locations are not supported"

      test_code(<<~CODE)
        ary[1] += foo
      CODE
    end

    it "tests" do
      pending "IndexOperatorWriteNode locations are not supported"

      test_code(<<~CODE)
        ary[1, 2] += foo
      CODE
    end
  end

  describe "attr assignment with operator (OP_ASGN2)" do
    it "tests" do
      pending "CallOperatorWriteNode locations are not supported"

      test_code(<<~CODE)
        struct.field += foo
      CODE
    end
  end

  describe "assignment with && operator (OP_ASGN_AND)" do
    it "tests" do
      pending "LocalVariableAndWriteNode locations are not supported"

      test_code(<<~CODE)
        foo &&= bar
      CODE
    end

    it "tests" do
      pending "LocalVariableAndWriteNode locations and depth are not supported"

      test_code(<<~CODE)
        foo = 0
        1.times do
          foo &&= bar
        end
      CODE
    end

    it "tests" do
      pending "InstanceVariableAndWriteNode locations are not supported"

      test_code(<<~CODE)
        @foo &&= bar
      CODE
    end

    it "tests" do
      pending "ClassVariableAndWriteNode locations are not supported"

      test_code(<<~CODE)
        @@foo &&= bar
      CODE
    end

    it "tests" do
      pending "GlobalVariableAndWriteNode locations are not supported"

      test_code(<<~CODE)
        $foo &&= bar
      CODE
    end

    # NOTE: These are NODE_OP_CDECL
    #
    # * `Foo::Bar &&= bar`
    # * `expr::Bar &&= bar`
    it "tests" do
      pending "ConstantAndWriteNode locations are not supported"

      test_code(<<~CODE)
        Foo &&= bar
      CODE
    end
  end

  describe "assignment with && operator (OP_ASGN_OR)" do
    it "tests" do
      pending "LocalVariableOrWriteNode locations are not supported"

      test_code(<<~CODE)
        foo ||= bar
      CODE
    end

    it "tests" do
      pending "LocalVariableOrWriteNode locations and depth are not supported"

      test_code(<<~CODE)
        foo = 0
        1.times do
          foo ||= bar
        end
      CODE
    end

    it "tests" do
      pending "InstanceVariableOrWriteNode locations are not supported"

      test_code(<<~CODE)
        @foo ||= bar
      CODE
    end

    it "tests" do
      pending "ClassVariableOrWriteNode locations are not supported"

      test_code(<<~CODE)
        @@foo ||= bar
      CODE
    end

    it "tests" do
      pending "GlobalVariableOrWriteNode locations are not supported"

      test_code(<<~CODE)
        $foo ||= bar
      CODE
    end

    # NOTE: These are NODE_OP_CDECL
    #
    # * `Foo::Bar ||= bar`
    # * `expr::Bar ||= bar`
    it "tests" do
      pending "ConstantOrWriteNode locations are not supported"

      test_code(<<~CODE)
        Foo ||= bar
      CODE
    end
  end

  describe "constant declaration with operator (OP_CDECL)" do
    it "tests" do
      pending "ConstantPathAndWriteNode locations are not supported"

      test_code(<<~CODE)
        Foo::Bar &&= bar
      CODE
    end

    it "tests" do
      pending "ConstantPathAndWriteNode locations are not supported"

      test_code(<<~CODE)
        expr::Bar &&= bar
      CODE
    end

    it "tests" do
      pending "ConstantPathOrWriteNode locations are not supported"

      test_code(<<~CODE)
        Foo::Bar ||= bar
      CODE
    end

    it "tests" do
      pending "ConstantPathOrWriteNode locations are not supported"

      test_code(<<~CODE)
        expr::Bar ||= bar
      CODE
    end
  end

  describe "super" do
    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super 1")
    end

    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super(1)")
    end

    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super 1 do end")
    end

    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super 1 do 2 end")
    end

    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

      test_code("super(1) {}")
    end

    it "tests" do
      pending "keyword_loc, lparen_loc and rparen_loc are not supported"

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
      test_code("1 && 2")
    end

    it "tests" do
      test_code("1 and 2")
    end
  end

  describe "or" do
    it "tests" do
      test_code("1 || 2")
    end

    it "tests" do
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
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code("3.times { foo = 1; foo }")
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code(<<~CODE)
        3.times do
          foo = 1
          foo
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code("3.times {  }")
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code(<<~CODE)
        3.times do
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code("3.times { |i| foo = 1; foo }")
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockNode are not supported"

      test_code(<<~CODE)
        3.times do |i|
          foo = 1
          foo
        end
      CODE
    end
  end

  describe "BlockParameters" do
    describe "pre" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i|
          end
        CODE
      end
    end

    describe "pre_init" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(i, j)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(*i)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(*)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(i, *j)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(i, *)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(*i, j)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(*, i)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(i, *j, k)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |(i, *, j)|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |(i, j), k|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i, (j, k)|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |(i, j), k = 0|
          end
        CODE
      end
    end

    describe "opt" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & OptionalParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, j = 0, k = 1|
          end
        CODE
      end
    end

    describe "post" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i, j = 0, k, l|
          end
        CODE
      end
    end

    describe "post_init" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (j, k)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, j, (k, l)|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |i = 0, (j, k), l|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (*j)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (*)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (j, *k)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (j, *)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (*j, k)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (*, j)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (j, *k, l)|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredParameterNode location is not correct"

        test_code(<<~CODE)
          3.times do |i = 0, (j, *, k)|
          end
        CODE
      end
    end

    describe "rest" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |*a|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported"

        test_code(<<~CODE)
          3.times do |i,|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, *a|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, j = 0, *a|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |*a, i|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, *a, j|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, j = 0, *a, k|
          end
        CODE
      end
    end

    describe "kw" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & RequiredKeywordParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i:|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & OptionalKeywordParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i: 1|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & OptionalKeywordParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i: 1, j:|
          end
        CODE
      end
    end

    describe "kwrest" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & KeywordRestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |**h|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & KeywordRestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i:, **h|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & KeywordRestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i: 1, **h|
          end
        CODE
      end

      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & KeywordRestParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i: 1, j:, **h|
          end
        CODE
      end
    end

    describe "block" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & BlockParameterNode locations are not supported"

        test_code(<<~CODE)
          3.times do |&blk|
          end
        CODE
      end
    end

    describe "Combinations" do
      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |i, j, k = 0, *a, n: 1, o:, **h, &blk|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |i, j, k = 0, l, m: 1, n:, **h, &blk|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |i, j, k = 0, (l, m), n: 1, o:, **h, &blk|
          end
        CODE
      end

      it "tests" do
        pending "Remove 'internal variable's from nd_tbl"

        test_code(<<~CODE)
          3.times do |(i, *j, k), l = 0, (m, *n, o)|
          end
        CODE
      end
    end

    describe "With locals" do
      it "tests" do
        pending "opening_loc and closing_loc of BlockParametersNode are not supported & BlockLocalVariableNode locations are not supported"

        test_code(<<~CODE)
          3.times do |i, j; l1, l2, l3|
          end
        CODE
      end

      it "tests" do
        pending "Fix order of locals items"

        test_code(<<~CODE)
          3.times do |i, j, k = 0, *a, n: 1, o:, **h, &blk; l1, l2, l3|
          end
        CODE
      end

      it "tests" do
        pending "Remove 'internal variable's from nd_tbl"

        test_code(<<~CODE)
          3.times do |(i, *j, k), l = 0, (m, *n, o); l1, l2, l3|
          end
        CODE
      end
    end
  end

  describe "class" do
    xit "tests" do
      test_code(<<~CODE)
        class A
          a = 1
        end
      CODE
    end

    xit "tests" do
      test_code(<<~CODE)
        class A < B
          a = 1
        end
      CODE
    end

    xit "tests" do
      test_code(<<~CODE)
        class A::B < C::D
          a = 1
        end
      CODE
    end

    xit "tests" do
      test_code(<<~CODE)
        class ::A < ::B
          a = 1
        end
      CODE
    end

    xit "tests" do
      test_code(<<~CODE)
        class ::A::B < ::C::D
          a = 1
        end
      CODE
    end

    xit "tests" do
      test_code(<<~CODE)
        class expr1::B < expr2::D
          a = 1
        end
      CODE
    end
  end

  describe "sclass" do
    xit "tests" do
      test_code(<<~CODE)
        class << obj
          a = 1
        end
      CODE
    end
  end

  describe "module" do
    xit "tests" do
      test_code(<<~CODE)
        module C
          a = 1
        end
      CODE
    end
  end

  describe "defn" do
    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def m
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def m(a, b)
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def m a, b
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def m = 1
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def m(a, b) = a + b
      CODE
    end
  end

  describe "defs" do
    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def obj.m
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def obj.m(a, b)
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def obj.m a, b
        end
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def obj.m = 1
      CODE
    end

    it "tests" do
      pending "DefNode locations are not supported"

      test_code(<<~CODE)
        def obj.m(a, b) = a + b
      CODE
    end
  end

  describe "args" do
    xit "tests" do
      test_code(<<~CODE)
        def foo(a, b, opt1=1, opt2=2, *rest, y, z, kw: 1, **kwrest, &blk)
        end
      CODE
    end
  end

  describe "arguments" do
    describe "pos" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo a
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a, b)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo a, b
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo()
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo
        CODE
      end
    end

    describe "ARGSCAT" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(*ary1, a1, a2)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a1, *ary1)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a1, a2, *ary1)
        CODE
      end
    end

    describe "ARGSPUSH" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(*ary1, a1)
        CODE
      end
    end

    describe "ARGSCAT & ARGSPUSH" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a1, *ary1, a2, *ary2)
        CODE
      end
    end

    describe "SPLAT" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(*ary)
        CODE
      end
    end

    describe "BLOCK_PASS" do
      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(&blk)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(x, &blk)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(*ary1, a1, a2, &blk)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a1, *ary1, &blk)
        CODE
      end

      it "tests" do
        pending "CallNode locations are not supported"

        test_code(<<~CODE)
          obj.foo(a1, a2, *ary1, &blk)
        CODE
      end
    end
  end

  describe "if" do
    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        if true
          1
        end
      CODE
    end

    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        if true
          1
        else
          2
        end
      CODE
    end

    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        if true then
          1
        else
          2
        end
      CODE
    end

    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        a ? b : c
      CODE
    end
  end

  describe "elsif" do
    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        if true
          1
        elsif false
          2
        else
          3
        end
      CODE
    end

    it "tests" do
      pending "IfNode locations are not supported"

      test_code(<<~CODE)
        if true then
          1
        elsif false then
          2
        else
          3
        end
      CODE
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
      test_code(<<~CODE)
        unless true
          1
        end
      CODE
    end

    it "tests" do
      pending "ElseNode locations are not supported"

      test_code(<<~CODE)
        unless true
          1
        else
          2
        end
      CODE
    end

    it "tests" do
      pending "ElseNode locations are not supported"

      test_code(<<~CODE)
        unless true then
          1
        else
          2
        end
      CODE
    end
  end

  describe "modifier unless" do
    it "tests" do
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

  describe "for" do
    it "tests" do
      pending "ForNode locations are not supported"

      test_code(<<~CODE)
        for i in 1..3 do
          foo
        end
      CODE
    end

    it "tests" do
      pending "ForNode locations are not supported"

      test_code(<<~CODE)
        for x, y in 1..3 do
          foo
        end
      CODE
    end

    it "tests" do
      pending "ForNode locations are not supported"

      test_code(<<~CODE)
        for (x, y) in 1..3 do
          foo
        end
      CODE
    end

    # TODO: Need more test cases for mlhs
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
      pending "SymbolNode locations is not supported"

      test_code("alias bar foo")
    end

    it "tests" do
      pending "SymbolNode locations is not supported"

      test_code("alias :bar :foo")
    end
  end

  describe "valias" do
    it "tests" do
      pending "GlobalVariableReadNode locations are not supported"

      test_code("alias $y $x")
    end
  end

  describe "undef" do
    it "tests" do
      pending "SymbolNode keyword_loc is not supported"

      test_code("undef foo")
    end

    it "tests" do
      pending "SymbolNode keyword_loc is not supported"

      test_code("undef foo, :bar")
    end
  end

  describe "break" do
    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          break
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          break 1
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          break 1, 2
        end
      CODE
    end
  end

  describe "next" do
    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          next
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          next 1
        end
      CODE
    end

    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          next 1, 2
        end
      CODE
    end
  end

  describe "return" do
    it "tests" do
      pending "redundant flags and keyword_loc are not supported"

      test_code(<<~CODE)
        def m
          return
        end
      CODE
    end

    it "tests" do
      pending "redundant flags and keyword_loc are not supported"

      test_code(<<~CODE)
        def m
          return 1
        end
      CODE
    end

    it "tests" do
      pending "redundant flags and keyword_loc are not supported"

      test_code(<<~CODE)
        def m
          return 1, 2
        end
      CODE
    end

    it "tests" do
      pending "keyword_loc is not supported"

      test_code(<<~CODE)
        def m
          return 1, 2 if a
          3
        end
      CODE
    end
  end

  describe "yield" do
    it "tests" do
      pending "YieldNode locations are not supported"

      test_code(<<~CODE)
        def m
          yield
        end
      CODE
    end

    it "tests" do
      pending "YieldNode locations are not supported"

      test_code(<<~CODE)
        def m
          yield()
        end
      CODE
    end

    it "tests" do
      pending "YieldNode locations are not supported"

      test_code(<<~CODE)
        def m
          yield 1, 2
        end
      CODE
    end

    it "tests" do
      pending "YieldNode locations are not supported"

      test_code(<<~CODE)
        def m
          yield(1, 2)
        end
      CODE
    end    
  end

  describe "redo" do
    it "tests" do
      pending "opening_loc and closing_loc of BlockParametersNode are not supported"

      test_code(<<~CODE)
        10.times do |i|
          redo
        end
      CODE
    end
  end

  describe "retry" do
    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
        rescue
          retry
        end
      CODE
    end
  end

  describe "begin, rescue, else, ensure" do
    # begin
    it "tests" do
      pending "BeginNode locations are not supported"

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

    # rescue
    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
        rescue
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
          1
        rescue
          2
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
          1
        rescue StandardError
          2
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
          1
        rescue => e
          2
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
          1
        rescue StandardError => e
          2
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

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
      pending "BeginNode locations are not supported"

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
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
          1
        rescue NoMethodError, ArgumentError => e
          2
        end
      CODE
    end

    # else
    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
        rescue
        else
        end
      CODE
    end

    # ensure
    it "tests" do
      pending "BeginNode locations are not supported"

      test_code(<<~CODE)
        begin
        rescue
        else
        ensure
        end
      CODE
    end

    it "tests" do
      pending "BeginNode locations are not supported"

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

    # In method definition
    xit "tests" do
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
      pending "WhenNode locations are not supported"

      test_code(<<~CODE)
        case x
        when 1
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations are not supported"

      test_code(<<~CODE)
        case x
        when 1 then
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations and ElseNode locations are not supported"

      test_code(<<~CODE)
        case x
        when 1
        else
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations are not supported"

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
      pending "WhenNode locations and ElseNode locations are not supported"

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
      pending "WhenNode locations locations are not supported"

      test_code(<<~CODE)
        case
        when 1
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations locations are not supported"

      test_code(<<~CODE)
        case
        when 1 then
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations and ElseNode locations are not supported"

      test_code(<<~CODE)
        case
        when 1
        else
        end
      CODE
    end

    it "tests" do
      pending "WhenNode locations locations are not supported"

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
      pending "WhenNode locations and ElseNode locations are not supported"

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

  describe "post-execution" do
    it "tests" do
      pending "PostExecutionNode locations are not supported"

      test_code("END {  }")
    end

    it "tests" do
      pending "PostExecutionNode locations are not supported"

      test_code("END { foo }")
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
