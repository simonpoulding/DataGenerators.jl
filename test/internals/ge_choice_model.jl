@generator GECSimpleGen begin 
    start() = [a() for i in 1:5] 
	a() = choose(Int, 0, 3)
end

@generator GECTypeBoundGen begin 
	start() = (a(), b(), c(), d(), e(), f(), g())
	a() = choose(Int, 4, 9) 
	b() = choose(Int, 1)
	c() = choose(Bool) 
	d() = choose(Float64, 3.7) 
	e() = choose(Float64, 4.2, 9.7)
	f() = choose(Int, typemin(Int), 10.0)
	g() = choose(Int, typemin(Int), typemax(Int))
end

@testset "GE choice model" begin

	@testset "constructors" begin

		cm1 = GEChoiceModel(4)		
	    @test typeof(cm1) == GEChoiceModel
		
		cm2 = GEChoiceModel([1.0, 0.0, 7.0])		
	    @test typeof(cm2) == GEChoiceModel
		
		@test_throws ErrorException cm3 = GEChoiceModel(0)

	end
	

	@testset "set/get parameters and ranges" begin

		cm1 = GEChoiceModel(4)
		params = getparams(cm1)
	    @test typeof(params) <: Vector{Float64}
		@test params == [0.0, 0.0, 0.0, 0.0]
		
		ranges = paramranges(cm1)
	    @test typeof(ranges) <: Vector{Tuple{Float64,Float64}}
		@test ranges == fill((Float64(0),Float64(typemax(UInt32))),4)
		
		setparams!(cm1, [8.0, 9.0, 5.0, 5.0])
		@test getparams(cm1) == [8.0, 9.0, 5.0, 5.0]
		
		@test_throws ErrorException setparams!(cm1, [8.0, 9.0, 5.0])
		@test_throws ErrorException setparams!(cm1, [8.0, 9.0, 5.0, 5.0, 2.0])
		@test_throws ErrorException setparams!(cm1, [8.0, -1.0, 5.0])
		setparams!(cm1, [8.0, 0.0, 5.0, 5.0])

		setparams!(cm1, [1.5, 7.6, 2.7, 5.2])
		@test getparams(cm1) == [2.0, 8.0, 3.0, 5.0]

		cm2 = GEChoiceModel([1.0, 0.0, 7.0])
		@test getparams(cm2) == [1.0, 0.0, 7.0]
		@test paramranges(cm2) == fill((Float64(0),Float64(typemax(UInt32))),3)
		setparams!(cm2, [2.0, 19.0, 27.0])
		@test getparams(cm2) == [2.0, 19.0, 27.0]

	end
	
	@testset "sampling" begin
	
		@testset "samples from genome" begin
			gn = GECSimpleGen()
			setchoicemodel!(gn, GEChoiceModel([1.0, 3.0, 2.0, 0.0, 2.0, 3.0]))
			@test choose(gn) == [1, 3, 2, 0, 2]
		end
		
		@testset "samples modulo from genome" begin
			gn = GECSimpleGen()
			setchoicemodel!(gn, GEChoiceModel([11.0, 14.0, 20.0, 21.0, 89.0, 39.0]))
			@test choose(gn) == [3, 2, 0, 1, 1]
		end
			
		@testset "wraps when sampling genome" begin
			gn = GECSimpleGen()
			setchoicemodel!(gn, GEChoiceModel([11.0, 14.0, 20.0]))
			@test choose(gn) == [3, 2, 0, 3, 2]
		end
	
		@testset "samples according to types and bounded intervals" begin
			gn = GECTypeBoundGen()
			setchoicemodel!(gn, GEChoiceModel([11.0, 14.0, 20.0, 3.0, 9.0, 2.0, 39.0]))
			x = choose(gn)
			@test typeof(x[1]) <: Int
			@test x[1] == 9
			@test typeof(x[2]) <: Int
			@test x[2] == 15
			@test typeof(x[3]) <: Bool
			@test x[3] == false
			@test typeof(x[4]) <: Float64
			@test isapprox(x[4], 6.7)
			@test typeof(x[5]) <: Float64
			@test isapprox(x[5], 7.7)
			@test typeof(x[6]) <: Int
			@test x[6] == 8
			@test typeof(x[7]) <: Int
			@test x[7] == 39
		end
		
	end

end