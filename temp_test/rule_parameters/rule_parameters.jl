using DataGenerators

@generator MainGen() begin
	start = a(10)
	a(x::Int) = reps(choose(Bool),x,2x)
end

gn = MainGen()

datum = gen(gn)

println(datum)