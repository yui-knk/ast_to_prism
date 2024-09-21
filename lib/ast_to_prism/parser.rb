# frozen_string_literal: true

module AstToPrism
  class Parser
    def initialize(source)
      @source = source
    end

    def parse
      ast = RubyVM::AbstractSyntaxTree.parse(@source, keep_script_lines: true)
      @script_lines = ast.script_lines
      convert(ast)
    end

    private

    def check_node_type(node, *types)
      if !types.include?(node.type)
        raise "#{types.join(", ")} is/are expected but it's #{node.type} node."
      end
    end

    def _location(start_offset, length)
      Prism::Location.new(source, start_offset, length)
    end

    def location(node)
      return nil if !node
      # TODO: In some cases, e.g. terms, location has 0 range.
      #       Return nil for the case.
      return nil if (node.first_lineno == node.last_lineno && node.first_column == node.last_column)

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
      check_node_type(node, :SCOPE)

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

    def _convert_arguments(nd_args)
      arguments = []
      block_node = nil

      if nd_args.nil?
        return arguments, block_node
      end

      case nd_args.type
      when :LIST
        # TODO: node.children should not include last nil
        nd_args.children[0...-1].each do |node|
           arguments << convert_node(node)
        end
      when :ARGSCAT
        nd_head, nd_body = nd_args.children

        case nd_head.type
        when :LIST, :ARGSPUSH
          # E.g. `obj.foo(a1, ..., *ary1)`

          arguments1, block_node1 = _convert_arguments(nd_head)
          arguments += arguments1

          arguments << Prism::SplatNode.new(
            source,                # source
            null_location,         # operator_loc
            convert_node(nd_body), # expression
            location(nd_body)      # location
          )
        else
          # E.g. `obj.foo(*ary1, a1, a2)`
          arguments1, block_node1 = _convert_arguments(nd_head)
          arguments2, block_node2 = _convert_arguments(nd_body)

          arguments += arguments1
          arguments += arguments2
        end
      when :ARGSPUSH
        nd_head, nd_body = nd_args.children
        arguments1, block_node1 = _convert_arguments(nd_head)
        arguments += arguments1
        arguments << convert_node(nd_body)
      when :SPLAT
        nd_head, = nd_args.children

        arguments << Prism::SplatNode.new(
          source,                # source
          null_location,         # operator_loc
          convert_node(nd_head), # expression
          location(nd_head)      # location
        )
      when :BLOCK_PASS
        nd_head, nd_body = nd_args.children
        arguments1, block_node1 = _convert_arguments(nd_head)
        expression = convert_node(nd_body)

        arguments += arguments1

        block_node = Prism::BlockArgumentNode.new(
          source,           # source
          expression,       # expression
          null_location,    # operator_loc
          location(nd_args) # location
        )
      else
        raise "#{nd_args.type} is not expected. #{nd_args.children}"
      end

      return arguments, block_node
    end

    def convert_arguments(nd_args)
      return nil if nd_args.nil?

      arguments, block_node = _convert_arguments(nd_args)

      if arguments.empty?
        arguments_node = nil
      else
        # TODO: Implement flags
        arguments_node = Prism::ArgumentsNode.new(
          source,           # source
          0,                # flags
          arguments,        # arguments
          location(nd_args) # location
        )
      end

      return arguments_node, block_node
    end

    def convert_assoc(node)
      return [] if node.nil?

      # TODO: node.children should not include last nil
      node.children[0...-1].each_slice(2).map do |k, v|
        if k
          # TODO: location should include both k & v ranges.

          Prism::AssocNode.new(
            source,          # source
            convert_node(k), # key
            convert_node(v), # value
            null_location,   # operator_loc
            location(k)      # location
          )
        else
          Prism::AssocSplatNode.new(
            source,          # source
            convert_node(v), # value
            null_location,   # operator_loc
            location(v)      # location
          )
        end
      end
    end

    # For block_parameters
    def convert_multiple_assignment(node)
      check_node_type(node, :MASGN)

      nd_value, nd_head, nd_args = node.children
      lefts = []
      rest = nil
      rights = []

      if nd_head
        check_node_type(nd_head, :LIST)

        # TODO: node.children should not include last nil
        lefts = nd_head.children[0...-1].map do |node|
          check_node_type(node, :DASGN)

          nd_vid, nd_value = node.children

          Prism::RequiredParameterNode.new(
            source,       # source
            0,            # flags
            nd_vid,       # name
            null_location # location
          )
        end
      end

      if nd_args
        if nd_args == :NODE_SPECIAL_NO_NAME_REST
          expression = nil

          rest = Prism::SplatNode.new(
            source,        # source
            null_location, # operator_loc
            expression,    # expression
            null_location  # location
          )
        else
          # NODE
          case nd_args.type
          when :DASGN
            nd_vid, nd_value = nd_args.children

            expression = Prism::RequiredParameterNode.new(
              source,       # source
              0,            # flags
              nd_vid,       # name
              null_location # location
            )

            # NOTE: Is this actually expression?
            #       I guess SplatNode represents both parameters and arguments.
            rest = Prism::SplatNode.new(
              source,        # source
              null_location, # operator_loc
              expression,    # expression
              null_location  # location
            )
          when :POSTARG
            nd_1st, nd_2nd = nd_args.children

            if nd_1st == :NODE_SPECIAL_NO_NAME_REST
              expression = nil

              rest = Prism::SplatNode.new(
                source,        # source
                null_location, # operator_loc
                expression,    # expression
                null_location  # location
              )
            else
              check_node_type(nd_1st, :DASGN)

              nd_vid, nd_value = nd_1st.children

              expression = Prism::RequiredParameterNode.new(
                source,       # source
                0,            # flags
                nd_vid,       # name
                null_location # location
              )

              rest = Prism::SplatNode.new(
                source,        # source
                null_location, # operator_loc
                expression,    # expression
                null_location  # location
              )
            end

            # TODO: Share the logic with lefts.
            check_node_type(nd_2nd, :LIST)

            # TODO: node.children should not include last nil
            rights = nd_2nd.children[0...-1].map do |node|
              check_node_type(node, :DASGN)

              nd_vid, nd_value = node.children

              Prism::RequiredParameterNode.new(
                source,       # source
                0,            # flags
                nd_vid,       # name
                null_location # location
              )
            end
          else
            raise "DASGN or POSTARG nodes are expected but it's #{nd_args.type} node."
          end
        end
      end

      result = Prism::MultiTargetNode.new(
        source,        # source
        lefts,         # lefts
        rest,          # rest
        rights,        # rights
        null_location, # lparen_loc
        null_location, # rparen_loc
        location(node) # location
      )

      count = lefts.count + (rest ? 1 : 0) + rights.count

      return result, count
    end

    def convert_block_parameters(locals, nd_args)
      parameters, local_nodes = convert_parameters(locals, nd_args)

      return nil if parameters.nil?

      Prism::BlockParametersNode.new(
        source,           # source
        parameters,       # parameters
        local_nodes,      # locals
        null_location,    # opening_loc
        null_location,    # closing_loc
        location(nd_args) # location
      )
    end

    def convert_parameters(locals, nd_args)
      return nil if nd_args.nil?
      check_node_type(nd_args, :ARGS)

      pre_num, pre_init, opt, first_post, post_num, post_init, rest, kw, kwrest, block = nd_args.children

      requireds = []
      optionals = []
      rest_node = nil
      posts = []
      keywords = []
      keyword_rest = nil
      block_node = nil
      local_nodes = []
      index = 0

      if [pre_num, pre_init, opt, first_post, post_num, post_init, rest, kw, kwrest, block] == [0, nil, nil, nil, 0, nil, nil, nil, nil, nil]
        return nil, local_nodes
      end

      pre_num.times do |i|
        # TODO: Remove "internal variable" from original nodes.
        #       E.g. `3.times do |(*i)| end`.
        #       nd_tbl and pre_init include "internal variable" which is
        #       represented as `nil`.
        if locals[i]
          requireds << Prism::RequiredParameterNode.new(
            source,       # source
            0,            # flags
            locals[i],    # name
            null_location # location
          )
        end

        index += 1
      end

      if pre_init
        result, count = convert_multiple_assignment(pre_init)
        requireds << result
        index += count
      end

      opt_arg = opt
      while opt_arg do
        nd_body, nd_next = opt_arg.children

        check_node_type(nd_body, :DASGN)

        nd_vid, nd_value = nd_body.children

        optionals << Prism::OptionalParameterNode.new(
          source,                 # source
          0,                      # flags
          nd_vid,                 # name
          null_location,          # name_loc
          null_location,          # operator_loc
          convert_node(nd_value), # value
          null_location           # location
        )

        index += 1
        opt_arg = nd_next
      end

      if rest
        if rest == :NODE_SPECIAL_EXCESSIVE_COMMA
          rest_node = Prism::ImplicitRestNode.new(
            source,        # source
            null_location  # location
          )
        else
          rest_node = Prism::RestParameterNode.new(
            source,        # source
            0,             # flags
            rest,          # name
            null_location, # name_loc
            null_location, # operator_loc
            null_location  # location
          )
        end

        index += 1
      end

      post_num.times do |i|
        # TODO: Remove "internal variable" from original nodes.
        #       E.g. `3.times do |(*i)| end`.
        #       nd_tbl and pre_init include "internal variable" which is
        #       represented as `nil`.
        if locals[index]
          posts << Prism::RequiredParameterNode.new(
            source,        # source
            0,             # flags
            locals[index], # name
            null_location  # location
          )
        end

        index += 1
      end

      if post_init
        result, count = convert_multiple_assignment(post_init)
        posts << result
        index += count
      end

      if kw
        kw_arg = kw
        while kw_arg do
          nd_body, nd_next = kw_arg.children

          check_node_type(nd_body, :DASGN)

          nd_vid, nd_value = nd_body.children

          if nd_value == :NODE_SPECIAL_REQUIRED_KEYWORD
            keywords << Prism::RequiredKeywordParameterNode.new(
              source,                 # source
              0,                      # flags
              nd_vid,                 # name
              null_location,          # name_loc
              null_location           # location
            )
          else
            keywords << Prism::OptionalKeywordParameterNode.new(
              source,                 # source
              0,                      # flags
              nd_vid,                 # name
              null_location,          # name_loc
              convert_node(nd_value), # value
              null_location           # location
            )
          end

          index += 1
          kw_arg = nd_next
        end
      end

      # Skip "internal variable" for kw
      #
      # TODO: Remove this logic
      if locals[index].nil?
        index += 1
      end

      if kwrest
        check_node_type(kwrest, :DVAR)

        nd_vid, = kwrest.children

        if nd_vid
          keyword_rest = Prism::KeywordRestParameterNode.new(
            source,        # source
            0,             # flags
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            null_location  # location
          )

          index += 1
        end
      end

      if block
        block_node = Prism::BlockParameterNode.new(
          source,        # source
          0,             # flags
          block,         # name
          null_location, # name_loc
          null_location, # operator_loc
          null_location  # location
        )

        index += 1
      end

      parameters = Prism::ParametersNode.new(
        source,           # source
        requireds,        # requireds
        optionals,        # optionals
        rest_node,        # rest
        posts,            # posts
        keywords,         # keywords
        keyword_rest,     # keyword_rest
        block_node,       # block
        location(nd_args) # location
      )

      if index < locals.count
        local_nodes = locals[index..].map do |local|
          Prism::BlockLocalVariableNode.new(
            source,        # source
            0,             # flags
            local,         # name
            null_location, # location
          )
        end
      end

      return parameters, local_nodes
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

      Prism::ArgumentsNode.new(
        source,        # source
        0,             # flags
        arguments,     # arguments
        location(node) # location
      )
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
        loc, keyword_loc, then_keyword_loc = node.locations

        cond = nd_head.children[0...-1].map do |n|
          convert_node(n)
        end

        conditions << Prism::WhenNode.new(
          source,                           # source
          location(keyword_loc),            # keyword_loc
          cond,                             # conditions
          location(then_keyword_loc),       # then_keyword_loc
          convert_case_statements(nd_body), # statements
          location(loc)                     # location
        )

        if nd_next&.type == :WHEN
          node = nd_next
        else
          if nd_next
            # NOTE: end_keyword_loc of ElseNode seems to be redundant
            consequent = Prism::ElseNode.new(
              source,                           # source
              null_location,                    # else_keyword_loc
              convert_case_statements(nd_next), # statements
              null_location,                    # end_keyword_loc
              location(node)                    # location
            )
          end

          node = nil
        end
      end

      return conditions, consequent
    end

    def convert_block_body(node, range = 0..-1)
      return nil if node.nil?

      if node.type == :BEGIN && node.children == [nil]
        nil
      else
        convert_stmts(node, range)
      end
    end

    alias :convert_case_statements :convert_block_body
    alias :convert_begin_statements :convert_block_body

    def convert_block(node)
      return nil if node.nil?

      check_node_type(node, :SCOPE)

      locals, args, body = node.children

      # TODO: `locals.compact` is needed to remove "internal variable"
      #       E.g. `3.times do |(*i)| end`.
      Prism::BlockNode.new(
        source,                                 # source
        locals.compact,                         # locals
        convert_block_parameters(locals, args), # parameters
        convert_block_body(body),               # body
        null_location,                          # opening_loc
        null_location,                          # closing_loc
        location(node)                          # location
      )
    end

    def get_nd_tbl(node)
      check_node_type(node, :SCOPE)

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
        not_expected(node)
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

        Prism::LocalVariableTargetNode.new(
          source,        # source
          vid,           # name
          0,             # depth
          location(node) # location
        )
      when :DASGN
        vid, _ = node.children

        # TODO: Implement depth
        Prism::LocalVariableTargetNode.new(
          source,        # source
          vid,           # name
          0,             # depth
          location(node) # location
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
        not_expected(node)
      end
    end

    def convert_for_args(node)
      check_node_type(node, :ARGS)

      pre_num, pre_init, opt, first_post, post_num, post_init, rest, kw, kwrest, block = node.children

      case [pre_num, opt, first_post, post_num, post_init, rest, kw, kwrest, block]
      when [1, nil, nil, 0, nil, nil, nil, nil, nil]
        check_node_type(pre_init, :LASGN)

        vid, value = pre_init.children

        Prism::LocalVariableTargetNode.new(
          source,            # source
          vid,               # name
          0,                 # depth
          location(pre_init) # location
        )
      when [0, nil, nil, 0, nil, nil, nil, nil, nil]
        check_node_type(pre_init, :MASGN)

        nd_value, nd_head, nd_args = pre_init.children
        lefts = []
        rest = nil
        rights = []

        if nd_head
          check_node_type(nd_head, :LIST)

          # TODO: node.children should not include last nil
          lefts = nd_head.children[0...-1].map do |node|
            check_node_type(node, :LASGN)

            nd_vid, nd_value = node.children

            Prism::LocalVariableTargetNode.new(
              source,        # source
              nd_vid,        # name
              0,             # depth
              location(node) # location
            )
          end
        end

        Prism::MultiTargetNode.new(
          source,        # source
          lefts,         # lefts
          rest,          # rest
          rights,        # rights
          null_location, # lparen_loc
          null_location, # rparen_loc
          location(node) # location
        )
      else
        raise "#{nd_args} has not expected format."
      end
    end

    def convert_dynamic_literal(node)
      check_node_type(node, :DSTR, :DSYM, :DXSTR, :DREGX)

      string, nd_head, nd_next = node.children
      flags = 0
      parts = []

      parts << Prism::StringNode.new(
        source,         # source
        flags,          # flags
        null_location,  # opening_loc
        null_location,  # content_loc
        null_location,  # closing_loc
        string,         # unescaped
        null_location   # location
      )

      parts << convert_node(nd_head)

      if nd_next
        check_node_type(nd_next, :LIST)
        # TODO: node.children should not include last nil
        nd_next.children[0...-1].map do |n|
          parts << convert_node(n)
        end
      end

      return parts
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
        # NODE: We might need ElsifNode node otherwise both outer and inner IfNode(s)
        #       has end_keyword_loc for the same "end" token
        nd_cond, nd_body, nd_else = node.children
        consequent = nil

        if nd_else
          if nd_else.type == :IF
            consequent = convert_node(nd_else)
          else
            consequent = Prism::ElseNode.new(
              source,                 # source
              null_location,          # else_keyword_loc
              convert_stmts(nd_else), # statements
              null_location,          # end_keyword_loc
              location(nd_else)       # location
            )
          end
        end

        # NOTE: predicate is not always StatementsNode.
        Prism::IfNode.new(
          source,                 # source
          null_location,          # if_keyword_loc
          convert_node(nd_cond),  # predicate
          null_location,          # then_keyword_loc
          convert_stmts(nd_body), # statements
          consequent,             # consequent
          null_location,          # end_keyword_loc
          location(node)          # location
        )
      when :UNLESS
        nd_cond, nd_body, nd_else = node.children
        loc, keyword_loc, then_keyword_loc, end_keyword_loc = node.locations
        consequent = nil

        if nd_else
          # No elsif for "unless"
          consequent = Prism::ElseNode.new(
            source,                 # source
            null_location,          # else_keyword_loc
            convert_stmts(nd_else), # statements
            null_location,          # end_keyword_loc
            location(nd_else)       # location
          )
        end

        Prism::UnlessNode.new(
          source,                     # source
          location(keyword_loc),      # keyword_loc
          convert_node(nd_cond),      # predicate
          location(then_keyword_loc), # then_keyword_loc
          convert_stmts(nd_body),     # statements
          consequent,                 # consequent
          location(end_keyword_loc),  # end_keyword_loc
          location(loc)               # location
        )
      when :CASE
        nd_head, nd_body = node.children
        conditions, consequent = convert_case_body(nd_body)

        Prism::CaseNode.new(
          source,                # source
          convert_node(nd_head), # predicate
          conditions,            # conditions
          consequent,            # consequent
          null_location,         # case_keyword_loc
          null_location,         # end_keyword_loc
          location(node)         # location
        )
      when :CASE2
        nd_head, nd_body = node.children
        conditions, consequent = convert_case_body(nd_body)

        Prism::CaseNode.new(
          source,                # source
          convert_node(nd_head), # predicate
          conditions,            # conditions
          consequent,            # consequent
          null_location,         # case_keyword_loc
          null_location,         # end_keyword_loc
          location(node)         # location
        )
      when :CASE3
        not_supported(node)
      when :WHEN
        not_expected(node)
      when :IN
        not_supported(node)
      when :WHILE
        nd_cond, nd_body, nd_state = node.children

        if nd_state
          flags = 0
        else
          flags = Prism::LoopFlags::BEGIN_MODIFIER
        end

        Prism::WhileNode.new(
          source,                 # source
          flags,                  # flags
          null_location,          # keyword_loc
          null_location,          # closing_loc
          convert_node(nd_cond),  # predicate
          convert_stmts(nd_body), # statements
          location(node)          # location
        )
      when :UNTIL
        nd_cond, nd_body, nd_state = node.children

        if nd_state
          flags = 0
        else
          flags = Prism::LoopFlags::BEGIN_MODIFIER
        end

        Prism::UntilNode.new(
          source,                 # source
          flags,                  # flags
          null_location,          # keyword_loc
          null_location,          # closing_loc
          convert_node(nd_cond),  # predicate
          convert_stmts(nd_body), # statements
          location(node)          # location
        )
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
        nd_iter, nd_body = node.children

        check_node_type(nd_body, :SCOPE)
        nd_tbl, nd_args, nd_body2 = nd_body.children
        index = convert_for_args(nd_args)

        Prism::ForNode.new(
          source,                  # source
          index,                   # index
          convert_node(nd_iter),   # collection
          convert_stmts(nd_body2), # statements
          null_location,           # for_keyword_loc
          null_location,           # in_keyword_loc
          null_location,           # do_keyword_loc
          null_location,           # end_keyword_loc
          location(node)           # location
        )
      when :FOR_MASGN
        not_expected(node)
      when :BREAK
        nd_stts, = node.children

        Prism::BreakNode.new(
          source,                # source
          convert_stts(nd_stts), # arguments
          location(node),        # keyword_loc
          location(node)         # location
        )
      when :NEXT
        nd_stts, = node.children

        Prism::NextNode.new(
          source,                # source
          convert_stts(nd_stts), # arguments
          null_location,         # keyword_loc
          location(node)         # location
        )
      when :RETURN
        nd_stts, = node.children
        flags = 0

        Prism::ReturnNode.new(
          source,                # source
          flags,                 # flags
          null_location,         # keyword_loc
          convert_stts(nd_stts), # arguments
          location(node)         # location
        )
      when :REDO
        Prism::RedoNode.new(
          source,        # source
          location(node) # location
        )
      when :RETRY
        Prism::RetryNode.new(
          source,        # source
          location(node) # location
        )
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
          source,                            # source
          null_location,                     # begin_keyword_loc
          convert_begin_statements(nd_body), # statements
          nil,                               # rescue_clause
          nil,                               # else_clause
          nil,                               # ensure_clause
          null_location,                     # end_keyword_loc
          location(node)                     # location
        )
      when :RESCUE
        nd_head, nd_resq, nd_else  = node.children

        if nd_else
          else_clause = Prism::ElseNode.new(
            source,                            # source
            null_location,                     # else_keyword_loc
            convert_begin_statements(nd_else), # statements
            null_location,                     # end_keyword_loc
            location(nd_else)                  # location
          )
        else
          else_clause = nil
        end

        Prism::BeginNode.new(
          source,                            # source
          null_location,                     # begin_keyword_loc
          convert_begin_statements(nd_head), # statements
          convert_node(nd_resq),             # rescue_clause
          else_clause,                       # else_clause
          nil,                               # ensure_clause
          null_location,                     # end_keyword_loc
          location(node)                     # location
        )
      when :RESBODY
        nd_args, nd_exc_var, nd_body, nd_next = node.children

        if nd_args
          exceptions = nd_args.children[0...-1].map do |n|
            convert_node(n)
          end
        else
          exceptions = []
        end

        if nd_exc_var # `rescue Err => e` or not
          reference = convert_errinfo_assignment(nd_exc_var)
        else
          reference = nil
        end

        statements = convert_begin_statements(nd_body)

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

        # TODO: Change original NODE structure
        if nd_head.type == :RESCUE
          res_nd_head, res_nd_resq, res_nd_else = nd_head.children

          statements = convert_begin_statements(res_nd_head)
          rescue_clause = convert_node(res_nd_resq)
          else_clause = Prism::ElseNode.new(
            source,                                # source
            null_location,                         # else_keyword_loc
            convert_begin_statements(res_nd_else), # statements
            null_location,                         # end_keyword_loc
            location(res_nd_else)                  # location
          )

        else
          statements = convert_begin_statements(nd_head)
          rescue_clause = nil
          else_clause = nil
        end

        ensure_clause = Prism::EnsureNode.new(
          source,                            # source
          null_location,                     # ensure_keyword_loc
          convert_begin_statements(nd_ensr), # statements
          null_location,                     # end_keyword_loc
          location(nd_ensr)                  # location
        )

        Prism::BeginNode.new(
          source,        # source
          null_location, # begin_keyword_loc
          statements,    # statements
          rescue_clause, # rescue_clause
          else_clause,   # else_clause
          ensure_clause, # ensure_clause
          null_location, # end_keyword_loc
          location(node) # location
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
        nd_recv, nd_mid, nd_index, nd_rvalue = node.children
        receiver = convert_node(nd_recv)
        arguments, _ = convert_arguments(nd_index)
        # NOTE: Can block not be nil?
        block = nil
        binary_operator = nd_mid
        value = convert_node(nd_rvalue)

        Prism::IndexOperatorWriteNode.new(
          source,          # source
          0,               # flags
          receiver,        # receiver
          null_location,   # call_operator_loc
          null_location,   # opening_loc
          arguments,       # arguments
          null_location,   # closing_loc
          block,           # block
          binary_operator, # binary_operator
          null_location,   # binary_operator_loc
          value,           # value
          location(node)   # location
        )
      when :OP_ASGN2
        nd_recv, nd_aid, nd_vid, nd_mid, nd_value = node.children
        receiver = convert_node(nd_recv)
        read_name = nd_vid
        # NOTE: Why write_name is needed?
        write_name = "#{nd_vid}=".to_sym
        binary_operator = nd_mid
        value = convert_node(nd_value)

        Prism::CallOperatorWriteNode.new(
          source,          # source
          0,               # flags
          receiver,        # receiver
          null_location,   # call_operator_loc
          null_location,   # message_loc
          read_name,       # read_name
          write_name,      # write_name
          binary_operator, # binary_operator
          null_location,   # binary_operator_loc
          value,           # value
          location(node)   # location
        )
      when :OP_ASGN_AND
        nd_head, op, nd_value = node.children

        check_node_type(nd_value, :LASGN, :DASGN, :IASGN, :CVASGN, :GASGN, :CDECL)
        _, nd_value2 = nd_value.children
        if nd_value.type == :CDECL
          if nd_value.children.count != 2
            raise "CDECL should have 2 elements. #{nd_value}"
          end
        end
        value = convert_node(nd_value2)

        case nd_head.type
        when :LVAR
          nd_vid, = nd_head.children

          Prism::LocalVariableAndWriteNode.new(
            source,        # source
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            nd_vid,        # name
            0,             # depth
            location(node) # location
          )
        when :DVAR
          nd_vid, = nd_head.children

          # TODO: Need to take care of depth
          Prism::LocalVariableAndWriteNode.new(
            source,        # source
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            nd_vid,        # name
            0,             # depth
            location(node) # location
          )
        when :IVAR
          nd_vid, = nd_head.children

          Prism::InstanceVariableAndWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :CVAR
          nd_vid, = nd_head.children

          Prism::ClassVariableAndWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :GVAR
          nd_vid, = nd_head.children

          Prism::GlobalVariableAndWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :CONST
          nd_vid, = nd_head.children

          Prism::ConstantAndWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        else
          not_expected(nd_head)
        end
      when :OP_ASGN_OR
        nd_head, op, nd_value = node.children

        check_node_type(nd_value, :LASGN, :DASGN, :IASGN, :CVASGN, :GASGN, :CDECL)
        _, nd_value2 = nd_value.children
        if nd_value.type == :CDECL
          if nd_value.children.count != 2
            raise "CDECL should have 2 elements. #{nd_value}"
          end
        end
        value = convert_node(nd_value2)

        case nd_head.type
        when :LVAR
          nd_vid, = nd_head.children

          Prism::LocalVariableOrWriteNode.new(
            source,        # source
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            nd_vid,        # name
            0,             # depth
            location(node) # location
          )
        when :DVAR
          nd_vid, = nd_head.children

          # TODO: Need to take care of depth
          Prism::LocalVariableOrWriteNode.new(
            source,        # source
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            nd_vid,        # name
            0,             # depth
            location(node) # location
          )
        when :IVAR
          nd_vid, = nd_head.children

          Prism::InstanceVariableOrWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :CVAR
          nd_vid, = nd_head.children

          Prism::ClassVariableOrWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :GVAR
          nd_vid, = nd_head.children

          Prism::GlobalVariableOrWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :CONST
          nd_vid, = nd_head.children

          Prism::ConstantOrWriteNode.new(
            source,        # source
            nd_vid,        # name
            null_location, # name_loc
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        else
          not_expected(nd_head)
        end
      when :OP_CDECL
        nd_head, nd_aid, nd_value = node.children
        target = convert_node(nd_head)
        value = convert_node(nd_value)

        case nd_aid
        when :"&&"
          Prism::ConstantPathAndWriteNode.new(
            source,        # source
            target,        # target
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        when :"||"
          Prism::ConstantPathOrWriteNode.new(
            source,        # source
            target,        # target
            null_location, # operator_loc
            value,         # value
            location(node) # location
          )
        else
          raise "#{nd_aid} is not expected. #{node}"
        end
      when :CALL
        # example: obj.foo(1)
        nd_recv, nd_mid, nd_args = node.children
        arguments, block_node = convert_arguments(nd_args)

        Prism::CallNode.new(
          source,                # source
          0,                     # flags
          convert_node(nd_recv), # receiver
          nil,                   # call_operator_loc
          nd_mid,                # name
          nil,                   # message_loc
          nil,                   # opening_loc
          arguments,             # arguments
          nil,                   # closing_loc
          block || block_node,   # block
          location(node)         # location
        )
      when :OPCALL
        # example: foo + bar
        nd_recv, nd_mid, nd_args = node.children
        arguments, block_node = convert_arguments(nd_args)

        Prism::CallNode.new(
          source,                # source
          0,                     # flags
          convert_node(nd_recv), # receiver
          nil,                   # call_operator_loc
          nd_mid,                # name
          nil,                   # message_loc
          nil,                   # opening_loc
          arguments,             # arguments
          nil,                   # closing_loc
          block || block_node,   # block
          location(node)         # location
        )
      when :QCALL
        # safe method invocation
        # example: obj&.foo(1)
        nd_recv, nd_mid, nd_args = node.children
        flags = Prism::CallNodeFlags::SAFE_NAVIGATION
        arguments, block_node = convert_arguments(nd_args)

        Prism::CallNode.new(
          source,                # source
          flags,                 # flags
          convert_node(nd_recv), # receiver
          nil,                   # call_operator_loc
          nd_mid,                # name
          nil,                   # message_loc
          nil,                   # opening_loc
          arguments,             # arguments
          nil,                   # closing_loc
          block || block_node,   # block
          location(node)         # location
        )
      when :FCALL
        # function call
        # example: foo(1)
        nd_mid, nd_args = node.children
        flags = Prism::CallNodeFlags::IGNORE_VISIBILITY
        arguments, block_node = convert_arguments(nd_args)

        Prism::CallNode.new(
          source,              # source
          flags,               # flags
          nil,                 # receiver
          nil,                 # call_operator_loc
          nd_mid,              # name
          nil,                 # message_loc
          nil,                 # opening_loc
          arguments,           # arguments
          nil,                 # closing_loc
          block || block_node, # block
          location(node)       # location
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
        nd_args, _ = node.children
        arguments, block_node = convert_arguments(nd_args)

        Prism::SuperNode.new(
          source,              # source
          null_location,       # keyword_loc
          null_location,       # lparen_loc
          arguments,           # arguments
          null_location,       # rparen_loc
          block || block_node, # block
          location(node)       # location
        )
      when :ZSUPER
        Prism::ForwardingSuperNode.new(
          source,        # source
          block,         # block
          location(node) # location
        )
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
        nd_head, = node.children
        elements = convert_assoc(nd_head)

        Prism::HashNode.new(
          source,        # source
          null_location, # opening_loc
          elements,      # elements
          null_location, # closing_loc
          location(node) # location
        )
      when :YIELD
        nd_head, = node.children
        arguments, _ = convert_arguments(nd_head)

        Prism::YieldNode.new(
          source,        # source
          null_location, # keyword_loc
          null_location, # lparen_loc
          arguments,     # arguments
          null_location, # rparen_loc
          location(node) # location
        )
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
        nd_nth, = node.children
        number = Integer(nd_nth[1..])

        Prism::NumberedReferenceReadNode.new(
          source,        # source
          number,        # number
          location(node) # location
        )
      when :BACK_REF
        nd_nth, = node.children

        Prism::BackReferenceReadNode.new(
          source,        # source
          nd_nth,        # name
          location(node) # location
        )
      when :MATCH
        reg, = node.children
        # TODO: Implement flags
        # NOTE: Flag, e.g. forced_us_ascii_encoding for `/foo/`, is correct?
        #       because `/foo/` does not enforce encoding.
        flags = 0

        Prism::MatchLastLineNode.new(
          source,        # source
          flags,         # flags
          null_location, # opening_loc
          null_location, # content_loc
          null_location, # closing_loc
          reg.source,    # unescaped
          location(node) # location
        )
      when :MATCH2
        case node.children.count
        when 2
          nd_recv, nd_value = node.children

          arguments = Prism::ArgumentsNode.new(
            source,                   # source
            0,                        # flags
            [convert_node(nd_value)], # arguments
            location(nd_value)        # location
          )

          Prism::CallNode.new(
            source,                # source
            0,                     # flags
            convert_node(nd_recv), # receiver
            nil,                   # call_operator_loc
            :=~,                   # name
            nil,                   # message_loc
            nil,                   # opening_loc
            arguments,             # arguments
            nil,                   # closing_loc
            nil,                   # block
            location(node)         # location
          )
        when 3
          # Named capture. E.g. `/(?<var>foo)/ =~ 'bar'`
          nd_recv, nd_value, nd_args = node.children
          check_node_type(nd_args, :BLOCK)

          arguments = Prism::ArgumentsNode.new(
            source,                   # source
            0,                        # flags
            [convert_node(nd_value)], # arguments
            location(nd_value)        # location
          )

          call = Prism::CallNode.new(
            source,                # source
            0,                     # flags
            convert_node(nd_recv), # receiver
            nil,                   # call_operator_loc
            :=~,                   # name
            nil,                   # message_loc
            nil,                   # opening_loc
            arguments,             # arguments
            nil,                   # closing_loc
            nil,                   # block
            location(node)         # location
          )

          targets = nd_args.children.map do |node|
            check_node_type(node, :LASGN)

            vid, value = node.children

            Prism::LocalVariableTargetNode.new(
              source,        # source
              vid,           # name
              0,             # depth
              location(node) # location
            )
          end

          Prism::MatchWriteNode.new(
            source,        # source
            call,          # call
            targets,       # targets
            location(node) # location
          )
        else
          raise "MATCH2 should have 2 or 3 elements. #{node}"
        end
      when :MATCH3
        # NOTE: MATCH3 nd_recv, nd_value is inverse.

        nd_recv, nd_value = node.children

        arguments = Prism::ArgumentsNode.new(
          source,                  # source
          0,                       # flags
          [convert_node(nd_recv)], # arguments
          location(nd_recv)        # location
        )

        Prism::CallNode.new(
          source,                 # source
          0,                      # flags
          convert_node(nd_value), # receiver
          nil,                    # call_operator_loc
          :=~,                    # name
          nil,                    # message_loc
          nil,                    # opening_loc
          arguments,              # arguments
          nil,                    # closing_loc
          nil,                    # block
          location(node)          # location
        )
      when :STR
        string, = node.children
        flags = 0

        Prism::StringNode.new(
          source,         # source
          flags,          # flags
          null_location,  # opening_loc
          null_location,  # content_loc
          null_location,  # closing_loc
          string,         # unescaped
          location(node)  # location
        )
      when :XSTR
        string, = node.children
        flags = 0

        Prism::XStringNode.new(
          source,         # source
          flags,          # flags
          null_location,  # opening_loc
          null_location,  # content_loc
          null_location,  # closing_loc
          string,         # unescaped
          location(node), # location
        )
      when :INTEGER
        val, = node.children
        # TODO: Need to expose `base` for flags
        flags = Prism::IntegerBaseFlags::DECIMAL

        Prism::IntegerNode.new(
          source,        # source
          flags,         # flags
          val,           # value
          location(node) # location
        )
      when :FLOAT
        val, = node.children

        Prism::FloatNode.new(
          source,        # source
          val,           # value
          location(node) # location
        )
      when :RATIONAL
        val, = node.children
        # TODO: Need to expose `base` for flags
        flags = Prism::IntegerBaseFlags::DECIMAL

        Prism::RationalNode.new(
          source,          # source
          flags,           # flags
          val.numerator,   # numerator
          val.denominator, # denominator
          location(node)   # location
        )
      when :IMAGINARY
        # TODO: Original Node should have val as Node because it needs to take care of flags.

        val, = node.children
        img = val.imaginary

        case img
        when Integer
          # TODO: Need to expose `base` for flags
          flags = Prism::IntegerBaseFlags::DECIMAL

          numeric = Prism::IntegerNode.new(
            source,        # source
            flags,         # flags
            img,           # value
            location(node) # location
          )
        when Float
          numeric = Prism::FloatNode.new(
            source,        # source
            img,           # value
            location(node) # location
          )
        when Rational
        # TODO: Need to expose `base` for flags
        flags = Prism::IntegerBaseFlags::DECIMAL

        numeric = Prism::RationalNode.new(
          source,          # source
          flags,           # flags
          img.numerator,   # numerator
          img.denominator, # denominator
          location(node)   # location
        )
        else
          raise "#{img.class} is not supported for IMAGINARY Node val."
        end

        Prism::ImaginaryNode.new(
          source,        # source
          numeric,       # numeric
          location(node) # location
        )
      when :REGX
        regx, = node.children
        # TODO: RubyVM::AST needs to export `options`
        flags = 0

        Prism::RegularExpressionNode.new(
          source,        # source
          flags,         # flags
          null_location, # opening_loc
          null_location, # content_loc
          null_location, # closing_loc
          regx.source,   # unescaped
          location(node) # location
        )
      when :ONCE
        not_expected(node)
      when :DSTR
        flags = 0
        parts = convert_dynamic_literal(node)

        Prism::InterpolatedStringNode.new(
          source,        # source
          flags,         # flags
          null_location, # opening_loc
          parts,         # parts
          null_location, # closing_loc
          location(node) # location
        )
      when :DXSTR
        parts = convert_dynamic_literal(node)

        Prism::InterpolatedXStringNode.new(
          source,        # source
          null_location, # opening_loc
          parts,         # parts
          null_location, # closing_loc
          location(node) # location
        )
      when :DREGX
        flags = 0
        parts = convert_dynamic_literal(node)

        Prism::InterpolatedRegularExpressionNode.new(
          source,        # source
          flags,         # flags
          null_location, # opening_loc
          parts,         # parts
          null_location, # closing_loc
          location(node) # location
        )
      when :DSYM
        parts = convert_dynamic_literal(node)

        Prism::InterpolatedSymbolNode.new(
          source,        # source
          null_location, # opening_loc
          parts,         # parts
          null_location, # closing_loc
          location(node) # location
        )
      when :SYM
        string, = node.children[0]
        # TODO: Implement flags
        flags = 0

        Prism::SymbolNode.new(
          source,        # source
          flags,         # flags
          null_location, # opening_loc
          null_location, # value_loc
          null_location, # closing_loc
          string.to_s,   # unescaped
          location(node) # location
        )
      when :EVSTR
        nd_body, = node.children
        statements = convert_stmts(nd_body)

        Prism::EmbeddedStatementsNode.new(
          source,        # source
          null_location, # opening_loc
          statements,    # statements
          null_location, # closing_loc
          location(node) # location
        )
      when :ARGSCAT
        not_expected(node)
      when :ARGSPUSH
        not_expected(node)
      when :SPLAT
        not_expected(node)
      when :BLOCK_PASS
        not_expected(node)
      when :DEFN
        nd_mid, nd_defn = node.children
        nd_tbl, nd_args, nd_body = nd_defn.children
        parameters, local_nodes = convert_parameters(nd_tbl, nd_args)

        Prism::DefNode.new(
          source,                 # source
          nd_mid,                 # name
          null_location,          # name_loc
          nil,                    # receiver
          parameters,             # parameters
          convert_stmts(nd_body), # body
          nd_tbl,                 # locals
          null_location,          # def_keyword_loc
          null_location,          # operator_loc
          null_location,          # lparen_loc
          null_location,          # rparen_loc
          null_location,          # equal_loc
          null_location,          # end_keyword_loc
          location(node)          # location
        )
      when :DEFS
        nd_recv, nd_mid, nd_defn = node.children
        nd_tbl, nd_args, nd_body = nd_defn.children
        parameters, local_nodes = convert_parameters(nd_tbl, nd_args)

        Prism::DefNode.new(
          source,                 # source
          nd_mid,                 # name
          null_location,          # name_loc
          convert_node(nd_recv),  # receiver
          parameters,             # parameters
          convert_stmts(nd_body), # body
          nd_tbl,                 # locals
          null_location,          # def_keyword_loc
          null_location,          # operator_loc
          null_location,          # lparen_loc
          null_location,          # rparen_loc
          null_location,          # equal_loc
          null_location,          # end_keyword_loc
          location(node)          # location
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
        # TODO: Change original node structures

        nd_undefs, = node.children
        names = nd_undefs.map do |node|
          string, = node.children[0]
          # TODO: Implement flags
          flags = 0

          Prism::SymbolNode.new(
            source,        # source
            flags,         # flags
            null_location, # opening_loc
            null_location, # value_loc
            null_location, # closing_loc
            string.to_s,   # unescaped
            location(node) # location
          )
        end

        Prism::UndefNode.new(
          source,         # source
          names,          # names
          null_location,  # keyword_loc
          location(node), # location
        )
      when :CLASS
        # NOTE: In Prism ClassNode has locals but I think locals is a member of CLASS body stmts.

        nd_cpath, nd_super, nd_body = node.children

        check_node_type(nd_body, :SCOPE)

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
        Prism::RangeNode.new(source, Prism::RangeFlags::EXCLUDE_END, convert_node(nd_beg), convert_node(nd_end), null_location, location(node))
      when :FLIP2
        nd_beg, nd_end = node.children

        Prism::FlipFlopNode.new(
          source,               # source
          0,                    # flags
          convert_node(nd_beg), # left
          convert_node(nd_end), # right
          null_location,        # operator_loc
          location(node)        # location
        )
      when :FLIP3
        nd_beg, nd_end = node.children
        flags = Prism::RangeFlags::EXCLUDE_END

        Prism::FlipFlopNode.new(
          source,               # source
          flags,                # flags
          convert_node(nd_beg), # left
          convert_node(nd_end), # right
          null_location,        # operator_loc
          location(node)        # location
        )
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
        not_expected(node)
      when :DEFINED
        not_supported(node)
      when :POSTEXE
        nd_body, = node.children
        check_node_type(nd_body, :SCOPE)
        nd_tbl, nd_args, nd_body2 = nd_body.children
        statements = convert_begin_statements(nd_body2)

        Prism::PostExecutionNode.new(
          source,        # source
          statements,    # statements
          null_location, # keyword_loc
          null_location, # opening_loc
          null_location, # closing_loc
          location(node) # location
        )
      when :ATTRASGN
        nd_recv, nd_mid, nd_args = node.children
        arguments, _ = convert_arguments(nd_args)

        Prism::CallNode.new(
          source,                # source
          0,                     # flags
          convert_node(nd_recv), # receiver
          nil,                   # call_operator_loc
          nd_mid,                # name
          nil,                   # message_loc
          nil,                   # opening_loc
          arguments,             # arguments
          nil,                   # closing_loc
          nil,                   # block
          location(node)         # location
        )
      when :LAMBDA
        nd_body, = node.children
        check_node_type(nd_body, :SCOPE)
        nd_tbl, nd_args, nd_body2 = nd_body.children
        parameters = convert_block_parameters(nd_tbl, nd_args)

        Prism::LambdaNode.new(
          source,                  # source
          nd_tbl.compact,          # locals
          null_location,           # operator_loc
          null_location,           # opening_loc
          null_location,           # closing_loc
          parameters,              # parameters
          convert_stmts(nd_body2), # body
          location(node)           # location
        )
      when :OPT_ARG
        not_supported(node)
      when :KW_ARG
        not_supported(node)
      when :POSTARG
        not_expected(node)
      when :ARGS
        not_expected(node)
      when :SCOPE
        # TODO: not_expected ?
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
      when :ARGS_AUX
        not_expected(node)
      when :LAST
        not_expected(node)
      else
        not_expected(node)
      end
    end

    # Raise error because the node is still not supported
    def not_supported(node)
      raise "Node #{node.type} is not supported."
    end

    # Raise error because the node is not expected
    def not_expected(node)
      raise "Node #{node.type} is not expected here."
    end
  end
end
