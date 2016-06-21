using DataGenerators

@generator MainGen() begin
	start() = "Hello, World!"
end

gn = MainGen()

gnclone = deepcopy(gn)

datum = gen(gnclone)

println(datum)