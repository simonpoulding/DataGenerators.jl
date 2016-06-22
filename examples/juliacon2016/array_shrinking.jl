macro smallrandpos()
    :($(rand(4:7)))
end

function myreverse(l)
    # Contrived example with strange (seeded) bug
    if length(l) < @smallrandpos() || any(e->isa(e, Array), l)
        l
    else
        reverse(l)
    end
end

# Properties being tested
prop1(l) = length(unique(l)) < 2 || myreverse(l) != l
prop2(l) = myreverse(myreverse(l)) == l
prop(l) = prop1(l) && prop2(l)

# Let's use simple random testing
using DataGenerators
@generator ArrayOfMixedElements begin
    start() = [element() for i in 1:rand(1:4)]
    element() = rand(0:9)
    element() = (rand() < 0.30) ? start() : []
end
arygen = ArrayOfMixedElements()

ary = :notfound
for i in 1:100
    ary = choose(arygen)
    if !prop(ary)
        println("Property fails for = $ary")
        break
    end
end

using DataMutators
sf = shrink(ary, prop)
println("Smaller failing example: $sf")