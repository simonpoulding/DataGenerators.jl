using DataGenerators
using DataMutators

srand(123)

# To ensure things are compiled let's define simple generator and use it
@generator SomeData begin
    start() = [element() for i in 1:rand(2:3)]
    element() = choose(ASCIIString, "\\w+\\.\\w+")
    element() = choose(Int, 1, 100)
    element() = start()
end
gen = SomeData();
big = choose(gen);

prop(l) = length(l) < 2

smaller = DataMutators.shrink(big, prop);

