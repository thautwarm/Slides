using MLStyle
using PrettyPrinting

function jsonlit(ex)
    (∉)  = !isa
    function mk_kv(kv)
        (key, value) = @match kv begin
            :($k : $v) => (string(k), jsonlit(v))
            k          => (string(k), k)
        end
        :($key => $value)
    end

    @match ex begin
        :{ $(kvs...)} =>
            begin
                kvs = (mk_kv(kv) for kv in kvs if kv ∉ LineNumberNode)
                :(Dict($(kvs...)))
            end
        :[$(elts...)] => :[$(map(jsonlit, elts)...)]
        a => a
    end
end

macro jsonlit(ex)
    jsonlit(ex) |> esc
end

key = 1
value = 2
pprint(@jsonlit {
    key   : value,
    "key" :  "value",
    key   : value,
    (key+value),
    value : {
        key,
        value,
        key: {
            value
        }
    }
})


Dict(
    "key" => 2,
    "key + value" => 3,
    "value" => Dict(
                "key" => Dict("value" => 2),
                "value" => 2
               )
)