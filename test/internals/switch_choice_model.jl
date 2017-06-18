@generator SWCSimpleGen begin 
    start() = mult(a()) 
	a() = choose(Bool) ? "u" : "v"
	a() = choose(Bool) ? "x" : "y"
end

@testset "Switch choice model" begin

	@testset "constructors" begin

		gn = SWCSimpleGen()
		cm1 = GEChoiceModel(4)		
		cm2 = SamplerChoiceModel(choicepointinfo(gn))
		
		cps = sort(collect(keys(choicepointinfo(gn))))

		cm = SwitchChoiceModel([(cps[[2,3]], cm1),], cm2)
		@test typeof(cm) <: SwitchChoiceModel

	end
	

	@testset "set/get parameters and ranges" begin

		gn = SWCSimpleGen()
		cm1 = GEChoiceModel(4)
		cm2 = SamplerChoiceModel(choicepointinfo(gn))
		cm3 = GEChoiceModel([1,2,3])

		cps = sort(collect(keys(choicepointinfo(gn))))
		cm = SwitchChoiceModel([(cps[[1,]], cm1), (cps[[3,4,]], cm3),], cm2)

		@test numparams(cm) == numparams(cm1) + numparams(cm3) + numparams(cm2)
		@test paramranges(cm) == [paramranges(cm1); paramranges(cm3); paramranges(cm2); ]
		@test getparams(cm) == [getparams(cm1); getparams(cm3); getparams(cm2); ]
		setparams!(cm, [5.0, 3.0, 2.0, 1.0, 10.0, 11.0, 12.0, 0.2, 0.7, 0.55, 0.4, 0.6])
		# Assumes choice point ordering of (specifically that categorical cp are tbe last two params of cm2)
	 	# 	Dict{Symbol,Any}(Pair{Symbol,Any}(:datatype,Bool),Pair{Symbol,Any}(:type,:value),Pair{Symbol,Any}(:max,true),Pair{Symbol,Any}(:min,false))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:datatype,Bool),Pair{Symbol,Any}(:type,:value),Pair{Symbol,Any}(:max,true),Pair{Symbol,Any}(:min,false))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:type,:sequence),Pair{Symbol,Any}(:max,9223372036854775807),Pair{Symbol,Any}(:min,0))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:type,:rule),Pair{Symbol,Any}(:rulename,:a),Pair{Symbol,Any}(:max,2),Pair{Symbol,Any}(:min,1))
		@test getparams(cm) == [5.0, 3.0, 2.0, 1.0, 10.0, 11.0, 12.0, 0.2, 0.7, 0.55, 0.4, 0.6]
		
	end

	@testset "sampling" begin

	
		gn = SWCSimpleGen()
		cm1 = GEChoiceModel([3,2,1])
		cm2 = SamplerChoiceModel(choicepointinfo(gn))
		cm3 = GEChoiceModel([8,7,6])

		cps = sort(collect(keys(choicepointinfo(gn))))
		# Assumes choice point ordering of:
	 	# 	Dict{Symbol,Any}(Pair{Symbol,Any}(:datatype,Bool),Pair{Symbol,Any}(:type,:value),Pair{Symbol,Any}(:max,true),Pair{Symbol,Any}(:min,false))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:datatype,Bool),Pair{Symbol,Any}(:type,:value),Pair{Symbol,Any}(:max,true),Pair{Symbol,Any}(:min,false))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:type,:sequence),Pair{Symbol,Any}(:max,9223372036854775807),Pair{Symbol,Any}(:min,0))
	 	#   Dict{Symbol,Any}(Pair{Symbol,Any}(:type,:rule),Pair{Symbol,Any}(:rulename,:a),Pair{Symbol,Any}(:max,2),Pair{Symbol,Any}(:min,1))
		cm = SwitchChoiceModel([(cps[[3,]], cm1), (cps[[2,4,]], cm3),], cm2)
		setchoicemodel!(gn, cm)
		
		@mtestset "check sampling from all choice models and reset" begin
			d = join(choose(gn))
			@test ismatch(r"[u|v]y[u|v]", d) # multi implicitly checks reset
			@mtest_values_vary d # checks that "default" sampler choice model is applied to u/v choice
		end

	end

end