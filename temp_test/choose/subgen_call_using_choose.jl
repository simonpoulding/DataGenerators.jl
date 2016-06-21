using DataGenerators

@generator BoolGen begin
	start() = choose(Bool)
end

@generator IntGen begin
	start() = choose(Int,5,9)
end


@generator MainGen(boolGen, intGen) begin
	start() = map(i->choose(boolGen), 1:choose(intGen))
end

boolgn = BoolGen()
intgn = IntGen()

gn = MainGen(boolgn, intgn)

datum = gen(gn)
println("$(datum)")