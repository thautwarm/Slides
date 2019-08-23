# token
struct Failed end
failed = Failed()

# core
cache(f) = (target, body) ->
    gensym("cache_$target") |> TARGET ->
    Expr(
      :block,
      :($TARGET = $target),
      :($(f(TARGET, body)))
    )

wildcard(target, body) = body

capture(sym::Symbol) = (target, body) ->
  Expr(:let, Expr(:block, :($sym = target)), body)

typed_as(T) = f -> (target, body) ->
   let FN = gensym("type_$target"),
       TARGET = gensym("$target"),
       f1 = Expr(:function, :($FN($TARGET::$T)), :($(f(TARGET, body)))),
       f2 = Expr(:function, :($FN($TARGET)), failed)
       Expr(:block, f1, f2, :($FN($target)))
   end

literal(v) = (target, body) ->
  :($v == $target ? $body : $failed)

recog(recogniser, get_field) = elts -> recogniser(
  function (target, body)
    n = elts |> length
    foldr(n:-1:1, init=body) do i, last
      sub_target = get_field(target, i)
      elts[i](sub_target, last)
    end
  end)

and(p1, p2) = (target, body) ->
	p1(target, p2(target, body))

or(p1, p2) = (target, body) ->
  let e1 = p1(target, body),
      e2 = p2(target, body),
      RET = gensym("or_$target")
      Expr(
        :block,
        :($RET = $e1),
        :($RET === $failed ? $e1 : $RET)
      )
  end


# pervasives

tuple_pat(elts) =
  let recogniser = typed_as(NTuple{elts |> length, Any}),
      get_field(tag, i) = :($tag[$i])
      recog(recogniser, get_field)(elts)
  end

pred_pat(pred) = (target, body) ->
  let cond = :($pred($target))
    :($cond ? $body : $failed)
  end


guard(cond) = (target, body) -> :($cond ? $body : $failed)

array_pat(elts) =
  let recogniser = typed_as(Vector),
      get_field(tag, i) = :($tag[$i])
      recog(recogniser, get_field)(elts)
  end

array_pat2(elts1, star, elts2) = # with ...
  let (n1, n2) = map(length, [elts1, elts2]),
      recogniser = f -> typed_as(Vector)(
          let n = n1 + n2
              check = n > 0 ?
                pred_pat(Expr(:(->), :x, :(x >= $(n1 + n2)))) :
                wildcard
              and(f, check)
          end
      ),
      get_field(tag, i) =
          i <= n1 ?
            :($tag[$i]) :
          i > n1 + 1 ?
            :($tag[end - $(n2 + n1 + 1 - i)]) :
          :($tag[$(n1 + 1):end - $n2])
      recog(recogniser, get_field)([elts1..., star, elts2...])
  end

# test

tuple_pat(
  (
    literal(1),
    wildcard,
    and(capture(:a), guard(:(a > 1)))
  )
)(:a, :res) |> println

array_pat2(
  [literal(1)],
  capture(:a),
  [literal(2)]
)(:a, :res) |> println
