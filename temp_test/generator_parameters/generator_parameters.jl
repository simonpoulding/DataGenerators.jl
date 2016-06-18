using GodelTest

@generator BoolGen begin
	start() = choose(Bool)
end

@generator IntGen begin
	start() = choose(Int,5,9)
end

# ex = macroexpand( :(
@generator MainGen() begin
	start() = map(i->7, 1:10)
end
# ) )
# println(ex)


# @generator MainGen(boolGen, intGen) begin
# 	start() = map(i->boolGen(), 1:intGen())
# end
# boolgn = BoolGen()
# intgn = IntGen()

gn = MainGen()

println("$(gen(gn))")