from graphviz_artist as ga
from graphviz_artist.attr as a

g = ga.Graph()

var = g.new(a.Label("var"))

is_tuple = g.new(a.Label("is tuple, length = 3"))

is_vector = g.new(a.Label("is vector, length >= 1"))

elt1 = g.new(a.Label("elt1"))
elt2 = g.new(a.Label("elt2"))
elt3 = g.new(a.Label("elt3"))


hd = g.new(a.Label("hd"))
elt3 = g.new(a.Label("elt3"))









