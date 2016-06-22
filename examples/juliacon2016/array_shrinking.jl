#
# 1. Function under test: myrev
# (Contrived example with strange (seeded) bug)
#
macro smallrandpos()
    :($(rand(3:7)))
end

function myrev(l)
    if length(l) < @smallrandpos() || any(e->isa(e, Array), l)
        l
    else
        reverse(l)
    end
end


#
# 2. Property-based (random) testing with two properties being tested
#
prop_rev_rev(l) = myrev(myrev(l)) == l
prop_array_changes(l) = length(unique(l)) < 2 || myrev(l) != l
props_myrev(l) = prop_rev_rev(l) && prop_array_changes(l)


#
# 2b. Basic random testing with a recursive array generator
#
using DataGenerators
@generator ArrayOfMixedElements begin
    start() = [element() for i in 1:rand(1:4)]
    element() = rand(0:9)
    element() = (rand() < 0.30) ? start() : []
end
arraygen = ArrayOfMixedElements()
ary = first(filter(a -> !props_myrev(a), Any[choose(arraygen) for i in 1:100]))

println("Property fails for\n  ary        = $ary\n  myrev(ary) = $(myrev(ary))")


#
# 3. Shrink the failing test datum
#
a = DataMutators.shrink(ary, props_myrev)

println("Property fails for\n  a        = $a\n  myrev(a) = $(myrev(a))")
println("Property fails for\n  ary        = $ary\n  myrev(ary) = $(myrev(ary))")
