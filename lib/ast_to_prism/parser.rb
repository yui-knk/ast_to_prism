# frozen_string_literal: true

module AstToPrism
  class Parser
    module IntegerBaseFlags
      BINARY      = 1 << 0
      DECIMAL     = 1 << 1
      OCTAL       = 1 << 2
      HEXADECIMAL = 1 << 3
    end

    module RangeFlags
      EXCLUDE_END = 1 << 0
    end

    def initialize(source)
      @source = source
    end

    def parse
      ast = RubyVM::AbstractSyntaxTree.parse(@source, keep_script_lines: true)
      @script_lines = ast.script_lines
      convert(ast)
    end

    private

    def _location(start_offset, length)
      Prism::Location.new(source, start_offset, length)
    end

    def location(node)
      first_offset = line_to_offset[node.first_lineno - 1] + node.first_column
      last_offset  = line_to_offset[node.last_lineno - 1] + node.last_column

      _location(first_offset, last_offset - first_offset)
    end

    def null_location
      _location(0, 0)
    end

    def _source(start_line, offsets)
      Prism::Source.new(@source, start_line, offsets)
    end

    def source
      _source(1, line_to_offset)
    end

    def line_to_offset
      @line_to_offset ||= begin
        offset = 0
        ary = []

        @script_lines.each.with_index.each do |line, i|
          ary[i] = offset
          offset += line.length
        end

        ary
      end
    end

    def convert(node)
      if node.type != :SCOPE
        raise "SCOPE NODE is expected but it's #{node.type} node."
      end

      locals, args, body = node.children
      # (source, locals, statements, location)
      Prism::ProgramNode.new(source, locals, convert_stmts(body), location(node))
    end

    # TODO: Remove this branch once original node keeps BLOCK node for single statement
    def convert_stmts(node, range = 0..-1)
      return nil if node.nil?

      if node.type == :BLOCK
        body = node.children[range].map do |n|
          convert_node(n)
        end

        # (source, body, location)
        Prism::StatementsNode.new(source, body, location(node))
      else
        # (source, body, location)
        Prism::StatementsNode.new(source, [convert_node(node)], location(node))
      end
    end

    def convert_arguments(args)
      return nil if args.nil?

      # TODO: node.children should not include last nil
      arguments = args.children[0...-1].map do |node|
        convert_node(node)
      end

      # TODO: Implement flags

      # (source, flags, arguments, location)
      Prism::ArgumentsNode.new(source, 0, arguments, location(args))
    end

    def convert_block_parameters(nd_args)
      return nil if nd_args.nil?
    end

    def convert_stts(node)
      return nil if node.nil?

      if node.type == :LIST
        # TODO: node.children should not include last nil
        arguments = node.children[0...-1].map do |node|
          convert_node(node)
        end
      else
        arguments = [convert_node(node)]
      end

      # TODO: Implement flags

      # (source, flags, arguments, location)
      Prism::ArgumentsNode.new(source, 0, arguments, location(node))
    end

    def convert_parameters(nd_tbl, nd_args)
      return nil if nd_args.nil?
    end

    # * NODE_WHEN
    #   * NODE_WHEN (nd_next)
    #     * ...
    #     * NODE? (nd_next) for else
    #
    # =>
    #
    # [WhenNode ...], ElseNode
    def convert_case_body(node)
      conditions = []
      consequent = nil

      while node do
        nd_head, nd_body, nd_next = node.children

        cond = nd_head.children[0...-1].map do |n|
          convert_node(n)
        end

        # (source, keyword_loc, conditions, then_keyword_loc, statements, location)
        conditions << Prism::WhenNode.new(source, null_location, cond, null_location, convert_stmts(nd_body), location(node))

        if nd_next&.type == :WHEN
          node = nd_next
        else
          # NOTE: end_keyword_loc of ElseNode seems to be redundant
          # (source, else_keyword_loc, statements, end_keyword_loc, location)
          consequent = Prism::ElseNode.new(source, null_location, convert_stmts(nd_next), null_location, location(node))
          node = nil
        end
      end

      return conditions, consequent
    end


    def convert_block(node)
      return nil if node.nil?

      if node.type != :SCOPE
        raise "SCOPE NODE is expected but it's #{node.type} node."
      end

      locals, args, body = node.children

      Prism::BlockNode.new(
        source,                         # source
        locals,                         # locals
        convert_block_parameters(args), # parameters
        convert_stmts(body),            # body
        null_location,                  # opening_loc
        null_location,                  # closing_loc
        location(node)                  # location
      )
    end

    def get_nd_tbl(node)
      if node.type != :SCOPE
        raise "SCOPE NODE is expected but it's #{node.type} node."
      end

      locals, args, body = node.children

      return locals
    end

    def get_class_node_name(node)
      case node.type
      when :COLON2
        nd_head, nd_mid = node.children
        nd_mid
      when :COLON3
        nd_mid, = node.children
        nd_mid
      else
        not_supported(node)
      end
    end

    def errinfo_assign?(node)
      # if node.type != :BLOCK
      #   raise "BLOCK NODE is expected but it's #{node.type} node."
      # end

      return false if node.type != :BLOCK

      case (n = node.children[0]).type
      when :LASGN, :DASGN, :IASGN, :CVASGN, :GASGN, :CDECL
        n.children[1].type == :ERRINFO
      else
        false
      end
    end

    def convert_errinfo_assignment(node)
      # value (RHS) is ERRINFO NODE

      case node.type
      when :LASGN
        vid, _ = node.children

        # (source, name, depth, location)
        Prism::LocalVariableTargetNode.new(
          source,
          vid,
          0,
          location(node)
        )
      when :DASGN
        vid, _ = node.children

        # TODO: Implement depth

        # (source, name, depth, location)
        Prism::LocalVariableTargetNode.new(
          source,
          vid,
          0,
          location(node)
        )
      when :IASGN
        vid, _ = node.children

        # (source, name, location)
        Prism::InstanceVariableTargetNode.new(
          source,
          vid,
          location(node)
        )
      when :CVASGN
        vid, _ = node.children

        # (source, name, location)
        Prism::ClassVariableTargetNode.new(
          source,
          vid,
          location(node)
        )
      when :GASGN
        vid, _ = node.children

        # (source, name, location)
        Prism::GlobalVariableTargetNode.new(
          source,
          vid,
          location(node)
        )
      when :CDECL
        vid, _ = node.children

        # (source, name, location)
        Prism::ConstantTargetNode.new(
          source,
          vid,
          location(node)
        )
      else
        not_supported(node)
      end
    end

    def convert_node(node, block: nil)
      return nil if node.nil?

      case node.type
      when :BLOCK
        body = node.children.map do |n|
          convert_node(n)
        end

        # (source, body, location)
        Prism::StatementsNode.new(source, body, location(node))
      when :IF
        nd_cond, nd_body, nd_else = node.children

        # (source, if_keyword_loc, predicate, then_keyword_loc, statements, consequent, end_keyword_loc, location)
        #
        # NOTE: predicate is not always StatementsNode.
        Prism::IfNode.new(source,
                          null_location, convert_node(nd_cond),
                          null_location, convert_stmts(nd_body), convert_node(nd_else),
                          null_location, location(node))
      when :UNLESS
        nd_cond, nd_body, nd_else = node.children

        # (source, keyword_loc, predicate, then_keyword_loc, statements, consequent, end_keyword_loc, location)
        Prism::UnlessNode.new(source,
                          null_location, convert_node(nd_cond),
                          null_location, convert_stmts(nd_body), convert_node(nd_else),
                          null_location, location(node))
      when :CASE
        nd_head, nd_body = node.children
        conditions, consequent = convert_case_body(nd_body)

        # (source, predicate, conditions, consequent, case_keyword_loc, end_keyword_loc, location)
        Prism::CaseNode.new(source, convert_node(nd_head), conditions, consequent,
                            null_location, null_location, location(node))
      when :CASE2
        not_supported(node)
      when :CASE3
        not_supported(node)
      when :WHEN
        not_supported(node)
      when :IN
        not_supported(node)
      when :WHILE
        not_supported(node)
      when :UNTIL
        not_supported(node)
      when :ITER
        # example: 3.times { foo }

        # Need to pass `nd_body` (NODE_SCOPE) to `convert_node`

        # * NODE_ITER
        #   * NODE_CALL (nd_iter)
        #   * NODE_SCOPE (nd_body)
        #
        # =>
        #
        # * CallNode
        #   * BlockNode (block)
        #
        nd_iter, nd_body = node.children
        block = convert_block(nd_body)
        iter = convert_node(nd_iter, block: block)
      when :FOR
        not_supported(node)
      when :FOR_MASGN
        not_supported(node)
      when :BREAK
        nd_stts, = node.children

        Prism::BreakNode.new(
          source,                # source
          convert_stts(nd_stts), # arguments
          location(node),        # keyword_loc
          location(node)         # location
        )
      when :NEXT
        not_supported(node)
      when :RETURN
        not_supported(node)
      when :REDO
        not_supported(node)
      when :RETRY
        not_supported(node)
      when :BEGIN
        # example: begin; 1; end

        # Structure:
        #
        # * (NODE_ENSURE)
        #   * (NODE_RESCUE)
        #     * nd_head: NODE_BEGIN
        #     * nd_resq: NODE_RESBODY
        #     * nd_else:

        nd_body, = node.children

        Prism::BeginNode.new(
          source,                 # source
          null_location,          # begin_keyword_loc
          convert_stmts(nd_body), # statements
          nil,                    # rescue_clause
          nil,                    # else_clause
          nil,                    # ensure_clause
          null_location,          # end_keyword_loc
          location(node)          # location
        )
      when :RESCUE
        nd_head, nd_resq, nd_else  = node.children

        if nd_else
          else_clause = Prism::ElseNode.new(
            source,                 # source
            null_location,          # else_keyword_loc
            convert_stmts(nd_else), # statements
            null_location,          # end_keyword_loc
            location(nd_else)       # location
          )
        else
          else_clause = nil
        end

        Prism::BeginNode.new(
          source,                 # source
          null_location,          # begin_keyword_loc
          convert_stmts(nd_head), # statements
          convert_node(nd_resq),  # rescue_clause
          else_clause,            # else_clause
          nil,                    # ensure_clause
          null_location,          # end_keyword_loc
          location(node)          # location
        )
      when :RESBODY
        nd_args, nd_body, nd_next  = node.children

        if nd_args
          exceptions = nd_args.children[0...-1].map do |n|
            convert_node(n)
          end
        else
          exceptions = []
        end

        # TODO: 
        if errinfo_assign?(nd_body) # `rescue Err => e` or not
          reference = convert_errinfo_assignment(nd_body.children[0])
          statements = convert_stmts(nd_body, 1..-1)
        else
          reference = nil
          statements = convert_stmts(nd_body)
        end

        Prism::RescueNode.new(
          source,                # source
          null_location,         # keyword_loc
          exceptions,            # exceptions
          null_location,         # operator_loc
          reference,             # reference
          statements,            # statements
          convert_node(nd_next), # consequent
          location(node)         # location
        )
      when :ENSURE
        nd_head, nd_ensr = node.children

        # TODO: Change original NODE strucutre
        if nd_head.type == :RESCUE
          res_nd_head, res_nd_resq, res_nd_else = nd_head.children

          statements = convert_stmts(res_nd_head)
          rescue_clause = convert_node(res_nd_resq)
          else_clause = convert_stmts(res_nd_else)
        else
          statements = convert_stmts(nd_head)
          rescue_clause = nil
          else_clause = nil
        end

        Prism::BeginNode.new(
          source,                 # source
          null_location,          # begin_keyword_loc
          statements,             # statements
          rescue_clause,          # rescue_clause
          else_clause,            # else_clause
          convert_stmts(nd_ensr), # ensure_clause
          null_location,          # end_keyword_loc
          location(node)          # location
        )
      when :AND
        nd_1st, nd_2nd = node.children

        # (source, left, right, operator_loc, location)
        Prism::AndNode.new(
          source,
          convert_node(nd_1st),
          convert_node(nd_2nd),
          null_location,
          location(node)
        )
      when :OR
        nd_1st, nd_2nd = node.children

        # (source, left, right, operator_loc, location)
        Prism::OrNode.new(
          source,
          convert_node(nd_1st),
          convert_node(nd_2nd),
          null_location,
          location(node)
        )
      when :MASGN
        not_supported(node)
      when :LASGN
        vid, value = node.children

        # TODO: Implement depth
        # NOTE: These codes have different depth
        #       `tap { foo = 1 }`, `foo = 0; tap { foo = 1 }`, `tap { foo = 1; tap { tap { foo = 2 } } }`
        Prism::LocalVariableWriteNode.new(
          source,              # source
          vid,                 # name
          0,                   # depth
          null_location,       # name_loc
          convert_node(value), # value
          null_location,       # operator_loc
          location(node)       # location
        )
      when :DASGN
        vid, value = node.children

        # TODO: Implement depth
        Prism::LocalVariableWriteNode.new(
          source,              # source
          vid,                 # name
          0,                   # depth
          null_location,       # name_loc
          convert_node(value), # value
          null_location,       # operator_loc
          location(node)       # location
        )
      when :IASGN
        vid, value = node.children
        # (source, name, name_loc, value, operator_loc, location)
        Prism::InstanceVariableWriteNode.new(source, vid, null_location, convert_node(value), null_location, location(node))
      when :CVASGN
        vid, value = node.children
        # (source, name, name_loc, value, operator_loc, location)
        Prism::ClassVariableWriteNode.new(source, vid, null_location, convert_node(value), null_location, location(node))
      when :GASGN
        vid, value = node.children
        # (source, name, name_loc, value, operator_loc, location)
        Prism::GlobalVariableWriteNode.new(source, vid, null_location, convert_node(value), null_location, location(node))
      when :CDECL
        not_supported(node)
      when :OP_ASGN1
        not_supported(node)
      when :OP_ASGN2
        not_supported(node)
      when :OP_ASGN_AND
        not_supported(node)
      when :OP_ASGN_OR
        not_supported(node)
      when :OP_CDECL
        not_supported(node)
      when :CALL
        # example: obj.foo(1)
        nd_recv, nd_mid, nd_args = node.children

        Prism::CallNode.new(
          source,                     # source
          0,                          # flags
          convert_node(nd_recv),      # receiver
          nil,                        # call_operator_loc
          nd_mid,                     # name
          nil,                        # message_loc
          nil,                        # opening_loc
          convert_arguments(nd_args), # arguments
          nil,                        # closing_loc
          block,                      # block
          location(node)              # location
        )
      when :OPCALL
        # example: foo + bar
        nd_recv, nd_mid, nd_args = node.children

        Prism::CallNode.new(
          source,                     # source
          0,                          # flags
          convert_node(nd_recv),      # receiver
          nil,                        # call_operator_loc
          nd_mid,                     # name
          nil,                        # message_loc
          nil,                        # opening_loc
          convert_arguments(nd_args), # arguments
          nil,                        # closing_loc
          block,                      # block
          location(node)              # location
        )
      when :QCALL
        # safe method invocation
        # example: obj&.foo(1)
        nd_recv, nd_mid, nd_args = node.children
        flags = Prism::CallNodeFlags::SAFE_NAVIGATION

        Prism::CallNode.new(
          source,                     # source
          flags,                      # flags
          convert_node(nd_recv),      # receiver
          nil,                        # call_operator_loc
          nd_mid,                     # name
          nil,                        # message_loc
          nil,                        # opening_loc
          convert_arguments(nd_args), # arguments
          nil,                        # closing_loc
          block,                      # block
          location(node)              # location
        )
      when :FCALL
        # function call
        # example: foo(1)
        nd_mid, nd_args = node.children
        flags = Prism::CallNodeFlags::IGNORE_VISIBILITY

        Prism::CallNode.new(
          source,                     # source
          flags,                      # flags
          nil,                        # receiver
          nil,                        # call_operator_loc
          nd_mid,                     # name
          nil,                        # message_loc
          nil,                        # opening_loc
          convert_arguments(nd_args), # arguments
          nil,                        # closing_loc
          block,                      # block
          location(node)              # location
        )
      when :VCALL
        # function call with no argument
        # example: foo
        flags = Prism::CallNodeFlags::VARIABLE_CALL | Prism::CallNodeFlags::IGNORE_VISIBILITY

        Prism::CallNode.new(
          source,           # source
          flags,            # flags
          nil,              # receiver
          nil,              # call_operator_loc
          node.children[0], # name
          location(node),   # message_loc
          nil,              # opening_loc
          nil,              # arguments
          nil,              # closing_loc
          block,            # block
          location(node)    # location
        )
      when :SUPER
        # TODO: Need to take care of block like `super(1) {}`

        # (source, keyword_loc, lparen_loc, arguments, rparen_loc, block, location)
        Prism::SuperNode.new(source, null_location, null_location, convert_arguments(node.children[0]), null_location, nil, location(node))
      when :ZSUPER
        # TODO: Need to take care of block like `super {}`

        # (source, block, location)
        Prism::ForwardingSuperNode.new(source, nil, location(node))
      when :LIST
        # TODO: node.children should not include last nil
        ary = node.children[0...-1].map do |n|
          convert_node(n)
        end
        # (source, flags, elements, opening_loc, closing_loc, location)
        Prism::ArrayNode.new(source, 0, ary, null_location, null_location, location(node))
      when :ZLIST
        # (source, flags, elements, opening_loc, closing_loc, location)
        Prism::ArrayNode.new(source, 0, [], null_location, null_location, location(node))
      when :HASH
        not_supported(node)
      when :YIELD
        not_supported(node)
      when :LVAR
        nd_vid, = node.children

        # TODO: Implement depth

        # (source, name, depth, location)
        Prism::LocalVariableReadNode.new(source, nd_vid, 0, location(node))
      when :DVAR
        nd_vid, = node.children

        # TODO: Implement depth
        
        # (source, name, depth, location)
        Prism::LocalVariableReadNode.new(source, nd_vid, 0, location(node))
      when :IVAR
        nd_vid, = node.children

        # (source, name, location)
        Prism::InstanceVariableReadNode.new(source, nd_vid, location(node))
      when :CONST
        nd_vid, = node.children

        # # (source, name, location)
        Prism::ConstantReadNode.new(source, nd_vid, location(node))
      when :CVAR
        nd_vid, = node.children

        # (source, name, location)
        Prism::ClassVariableReadNode.new(source, nd_vid, location(node))
      when :GVAR
        nd_vid, = node.children

        # (source, name, location)
        Prism::GlobalVariableReadNode.new(source, nd_vid, location(node))
      when :NTH_REF
        not_supported(node)
      when :BACK_REF
        not_supported(node)
      when :MATCH
        not_supported(node)
      when :MATCH2
        not_supported(node)
      when :MATCH3
        not_supported(node)
      when :STR
        not_supported(node)
      when :XSTR
        not_supported(node)
      when :INTEGER
        # TODO: Need to expose `base` for flags
        # (source, flags, value, location)
        Prism::IntegerNode.new(source, IntegerBaseFlags::DECIMAL, node.children[0], location(node))
      when :FLOAT
        # (source, value, location)
        Prism::FloatNode.new(source, node.children[0], location(node))
      when :RATIONAL
        # (source, flags, numerator, denominator, location)
        not_supported(node)
      when :IMAGINARY
        # (source, numeric, location)
        not_supported(node)
      when :REGX
        not_supported(node)
      when :ONCE
        not_supported(node)
      when :DSTR
        not_supported(node)
      when :DXSTR
        not_supported(node)
      when :DREGX
        not_supported(node)
      when :DSYM
        not_supported(node)
      when :SYM
        # TODO: Implement flags

        # (source, flags, opening_loc, value_loc, closing_loc, unescaped, location)
        Prism::SymbolNode.new(source, 0, null_location, null_location, null_location, node.children[0], location(node))
      when :EVSTR
        not_supported(node)
      when :ARGSCAT
        not_supported(node)
      when :ARGSPUSH
        not_supported(node)
      when :SPLAT
        not_supported(node)
      when :BLOCK_PASS
        not_supported(node)
      when :DEFN
        nd_mid, nd_defn = node.children
        nd_tbl, nd_args, nd_body = nd_defn.children

        Prism::DefNode.new(
          source,                              # source
          nd_mid,                              # name
          null_location,                       # name_loc
          nil,                                 # receiver
          convert_parameters(nd_tbl, nd_args), # parameters
          convert_stmts(nd_body),              # body
          nd_tbl,                              # locals
          null_location,                       # def_keyword_loc
          null_location,                       # operator_loc
          null_location,                       # lparen_loc
          null_location,                       # rparen_loc
          null_location,                       # equal_loc
          null_location,                       # end_keyword_loc
          location(node)                       # location
        )
      when :DEFS
        nd_recv, nd_mid, nd_defn = node.children
        nd_tbl, nd_args, nd_body = nd_defn.children

        Prism::DefNode.new(
          source,                              # source
          nd_mid,                              # name
          null_location,                       # name_loc
          convert_node(nd_recv),               # receiver
          convert_parameters(nd_tbl, nd_args), # parameters
          convert_stmts(nd_body),              # body
          nd_tbl,                              # locals
          null_location,                       # def_keyword_loc
          null_location,                       # operator_loc
          null_location,                       # lparen_loc
          null_location,                       # rparen_loc
          null_location,                       # equal_loc
          null_location,                       # end_keyword_loc
          location(node)                       # location
        )
      when :ALIAS
        nd_1st, nd_2nd = node.children

        # (source, new_name, old_name, keyword_loc, location)
        Prism::AliasMethodNode.new(
          source,
          convert_node(nd_1st),
          convert_node(nd_2nd),
          null_location,
          location(node)
        )
      when :VALIAS
        nd_alias, nd_orig = node.children

        # (source, new_name, old_name, keyword_loc, location)
        Prism::AliasGlobalVariableNode.new(
          source,
          Prism::GlobalVariableReadNode.new(source, nd_alias, null_location),
          Prism::GlobalVariableReadNode.new(source, nd_orig, null_location),
          null_location,
          location(node)
        )
      when :UNDEF
        # TODO: 

        nd_undef, = node.children
        sym = Prism::SymbolNode.new(source, 0, null_location, null_location, null_location, node.children[0], location(node))
        names = [sym]

        Prism::UndefNode.new(
          source,         # source
          names,          # names
          null_location,  # keyword_loc
          location(node), # location
        )
      when :CLASS
        # NOTE: In Prism ClassNode has locals but I think locals is a member of CLASS body stmts.

        nd_cpath, nd_super, nd_body = node.children

        if nd_body.type != :SCOPE
          raise "SCOPE NODE is expected but it's #{node.type} node."
        end

        locals = get_nd_tbl(nd_body)
        _, _, scope_nd_body = nd_body.children
        name = get_class_node_name(nd_cpath)

        Prism::ClassNode.new(
          source,                       # source
          locals,                       # locals
          null_location,                # class_keyword_loc
          convert_node(nd_cpath),       # constant_path
          null_location,                # inheritance_operator_loc
          convert_node(nd_super),       # superclass
          convert_stmts(scope_nd_body), # body
          null_location,                # end_keyword_loc
          name,                         # name
          location(node)                # location
        )
      when :MODULE
        not_supported(node)
      when :SCLASS
        not_supported(node)
      when :COLON2
        nd_head, nd_mid = node.children

        Prism::ConstantPathNode.new(
          source,                # source
          convert_node(nd_head), # parent
          nd_mid,                # name
          null_location,         # delimiter_loc
          null_location,         # name_loc
          location(node)         # location
        )
      when :COLON3
        nd_mid, = node.children

        Prism::ConstantPathNode.new(
          source,                # source
          nil,                   # parent
          nd_mid,                # name
          null_location,         # delimiter_loc
          null_location,         # name_loc
          location(node)         # location
        )
      when :DOT2
        nd_beg, nd_end = node.children

        # (source, flags, left, right, operator_loc, location)
        Prism::RangeNode.new(source, 0, convert_node(nd_beg), convert_node(nd_end), null_location, location(node))
      when :DOT3
        nd_beg, nd_end = node.children

        # (source, flags, left, right, operator_loc, location)
        Prism::RangeNode.new(source, RangeFlags::EXCLUDE_END, convert_node(nd_beg), convert_node(nd_end), null_location, location(node))
      when :FLIP2
        not_supported(node)
      when :FLIP3
        not_supported(node)
      when :SELF
        # (source, location)
        Prism::SelfNode.new(source, location(node))
      when :NIL
        # (source, location)
        Prism::NilNode.new(source, location(node))
      when :TRUE
        # (source, location)
        Prism::TrueNode.new(source, location(node))
      when :FALSE
        # (source, location)
        Prism::FalseNode.new(source, location(node))
      when :ERRINFO
        not_supported(node)
      when :DEFINED
        not_supported(node)
      when :POSTEXE
        not_supported(node)
      when :ATTRASGN
        not_supported(node)
      when :LAMBDA
        not_supported(node)
      when :OPT_ARG
        not_supported(node)
      when :KW_ARG
        not_supported(node)
      when :POSTARG
        not_supported(node)
      when :ARGS
        not_supported(node)
      when :SCOPE
        not_supported(node)
      when :ARYPTN
        not_supported(node)
      when :FNDPTN
        not_supported(node)
      when :HSHPTN
        not_supported(node)
      when :LINE
        # (source, location)
        Prism::SourceLineNode.new(source, location(node))
      when :FILE
        # TODO: What's flags
        # (source, flags, filepath, location)
        Prism::SourceFileNode.new(source, 0, node.children[0], location(node))
      when :ENCODING
        # (source, location)
        Prism::SourceEncodingNode.new(source, location(node))
      when :ERROR
        not_supported(node)
      # when :ARGS_AUX
      #   not_supported(node)
      # when :LAST
      #   not_supported(node)
      else
        not_supported(node)
      end
    end

    def not_supported(node)
      raise "Node #{node.type} is not supported."
    end
  end
end
