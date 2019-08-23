struct Failed
end
failed = Failed()

cache(f) = (target, body) ->
    let TARGET = gensym("cache_$target")
      Expr(:block,
        :($TARGET = $target),
        :($(f(TARGET, body)))
      )
    end

wildcard(target, body) = body

typed_as(T) = f -> (target, body) ->
   let FN = gensym("type_$target"),
       TARGET = gensym("$target"),
       f1 = Expr(:function, :($FN($TARGET::$T)), :($(f(TARGET, body)))),
       f2 = Expr(:function, :($FN($TARGET)), failed)
       Expr(:block, f1, f2, :($FN($target)))
   end

literal(v) = (target, body) ->
  :($v == $target ? $body : $failed)

call_pat(recogniser, get_field) = elts -> recogniser(
    function (target, body)
      n = elts |> length
      foldr(n:-1:1, init=body) do i, last
        sub_target = get_field(target, i)
        elts[i](sub_target, last)
      end
    end
  )

tuple_pat(elts) =
    let recogniser = typed_as(NTuple{elts |> length, Any}),
        get_field(tag, i) = :($tag[$i])
        call_pat(recogniser, get_field)(elts)
    end

and_pat(p1, p2) = (target, body) ->
	p1(target, p2(target, body))

or_pat(p1, p2) = (target, body) ->
  let e1 = p1(target, body),
      e2 = p2(target, body),
      RET = gensym("or_$target")
      Expr(
        :block,
        :($RET = $e1)
        :($RET === $failed ? $e1 :$RET)
      )
  end

tuple_pat(
  (
    literal(1),
    wildcard,
    literal(2)
  )
)(:a, :res) |> println
