using DataGenerators

@generator MainGen() begin
	start() = map(i->7, 1:10)
end

gn = MainGen()

datum = gen(gn)

println(datum)