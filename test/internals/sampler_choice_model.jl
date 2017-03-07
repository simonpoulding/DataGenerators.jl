# tests default choice model

@generator SCMGen begin # prefix SCM (for Sampler Choice Model) to avoid type name clashes
    start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
    a() = choose(Int,-2-2,1+1)
    a() = choose(Float64,-2.0-2.0,1.0+1.0)
    a() = choose(Bool)
end

@generator SCMRepsGen begin
    start() = reps(a,1+1,2+2) # non-literal arguments to allow us to pass range to godelnumber during testing
    a() = 'a'
end

@generator SCMChooseBoolGen begin
    start() = choose(Bool) # 
end

@generator SCMChooseIntGen begin
    start() = choose(Int,-2-2,1+1) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator SCMChooseFloat64Gen begin
    start() = choose(Float64,-2.0-2.0,1.0+1.0) # non-literal arguments to allow us to pass range to godelnumber during testing
end

@generator SCMRuleGen begin
    start() = x()
    x() = 'a'
    x() = 'b'
    x() = 'c'
    x() = 'd'
end

# internally will use range of choice points, so convenient for testing choice model when more than one choice point
@generator SCMChooseStringGen begin
    start() = choose(String,"a(b|c)d+ef?")
end

@generator SCMEstimateParamsGen begin
	start() = a()
	a() = choose(Bool)
	a() = mult("x")
end


@testset "sampler choice model" begin

	@testset "constructor" begin

	    gn = SCMGen()
	    cm = SamplerChoiceModel(gn)
	    @test typeof(cm) == SamplerChoiceModel

	end

	@testset "set/get parameters and ranges" begin

		gn = SCMGen()
		cm = SamplerChoiceModel(gn)

		@testset "paramranges" begin
		    ranges = paramranges(cm)
		    @test typeof(ranges) <: Vector{Tuple{Float64,Float64}}
		    @test length(ranges) == 5
		end

		@testset "getparams" begin
		    params = getparams(cm)
		    @test typeof(params) <: Vector{Float64}
		    @test length(params) == 5
		end

		@testset "setparams" begin
		    newparams = [(paramrange[1]+paramrange[2])/2 for paramrange in paramranges(cm)]
		    setparams(cm, newparams)
		    @test length(getparams(cm)) == 5 # can't check equality of params since some adjustment can be made by the cm
		end

	end

	@testset "rule choice point" begin

		gn = SCMRuleGen()
		cm = SamplerChoiceModel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		# type ChoiceContext
		# 	derivationstate::DerivationState
		# 	cptype::Symbol
		# 	cpid::Uint64
		# 	datatype::DataType
		# 	lowerbound::Real
		# 	upperbound::Real
		# end
		cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.RULE_CP, cpids[1], Int, 1, 4)

		@mtestset "valid Godel numbers returned" reps=Main.REPS begin
		    gnum, trace = DataGenerators.godelnumber(cm, cc)
		    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		    @mtest_values_are gnum [1,2,3,4]
		end
		
		@testset "sampler" begin
		
			@testset "uses a Categorical distribution" begin
				@test length(cm.samplers) == 1
				sampler = first(values(cm.samplers))
				@test typeof(sampler) <: DataGenerators.CategoricalSampler
			end

			@testset "get and set parameters" begin
				sampler = first(values(cm.samplers))
				@test getparams(cm) == [0.25,0.25,0.25,0.25,]
				@test paramranges(cm) == [(0.0,1.0),(0.0,1.0),(0.0,1.0),(0.0,1.0),]
				setparams(cm,[0.03,0.03,0.01,0.01])
				@test round(getparams(cm),4) == [0.375,0.375,0.125,0.125,] # round to avoid precision errors
			end
			
		end
		
	end

	@testset "sequence choice point" begin

		gn = SCMRepsGen()
		cm = SamplerChoiceModel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "small finite range" begin 
	
			cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.SEQUENCE_CP, cpids[1], Int, 0, 2)
		
			@mtestset "valid Godel numbers returned" reps=Main.REPS begin
			    gnum, trace = DataGenerators.godelnumber(cm, cc)
			    @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
			    @test 0 <= gnum <= 2 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
			    @mtest_values_are gnum [0,1,2]
			end

		end

		@testset "large finite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.SEQUENCE_CP, cpids[1], Int, 11, 16)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 11 <= gnum <= 16 # default choice model restricts sequence lengths to a maximum of 3 more than minimum
		        @mtest_values_include gnum [11,13] # 16 isn't very likely to occur
		    end
		
		end

		@testset "semi-finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.SEQUENCE_CP, cpids[1], Int, 1, typemax(Int))

		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 1 <= gnum <= typemax(Int64)
		        @mtest_values_vary gnum
		    end

		end
	
		@testset "sampler" begin

			cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.SEQUENCE_CP, cpids[1], Int64, 7, typemax(Int64))

			@mtestset "sampler consistent with a offset geometric distribution" reps=Main.REPS begin
				gnum, trace = DataGenerators.godelnumber(cm, cc)
				@mtest_distributed_as (gnum-7) Geometric(0.5) Main.ALPHA
			end
	
			@testset "get and set parameters" begin
				sampler = first(values(cm.samplers))
				@test getparams(cm) == [0.5,]
				@test paramranges(cm) == [(0.0,1.0),]
				setparams(cm,[0.6])
				@test getparams(cm) == [0.6,]
			end

		end
		
	end

	@testset "Bool value choice point" begin

		gn = SCMChooseBoolGen()
		cm = SamplerChoiceModel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))

		cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Bool, false, true)
	
		@mtestset "valid Godel numbers returned" reps=Main.REPS begin
		    gnum, trace = DataGenerators.godelnumber(cm, cc)
		    @test convert(Bool,gnum) != nothing  # raises exception if value can't be converted
		    @mtest_values_are gnum [false,true]
		end

		@testset "sampler" begin

			@mtestset "sampler consistent with a Bernoulli distribution" reps=Main.REPS begin
				gnum, trace = DataGenerators.godelnumber(cm, cc)
				@mtest_distributed_as gnum Bernoulli(0.5) Main.ALPHA
			end
	
			@testset "get and set parameters" begin
				sampler = first(values(cm.samplers))
				@test getparams(cm) == [0.5,]
				@test paramranges(cm) == [(0.0,1.0),]
				setparams(cm,[0.6])
				@test getparams(cm) == [0.6,]
			end

		end

	end


	@testset "Int value choice point" begin

		gn = SCMChooseIntGen()
		cm = SamplerChoiceModel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "small finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, -1, 2)

		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test -1 <= gnum <= 2
		        @mtest_values_are gnum [-1,0,1,2]
		    end
		
		end

		@testset "large finite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, 11, 16)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 11 <= gnum <= 16
		        @mtest_values_include gnum [11,13,16] # just a selection of possible values including end points
		    end
		
		end

		@testset "semi-finite range (upper)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, 128, typemax(Int))
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test 128 <= gnum <= typemax(Int)
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (lower)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, typemin(Int), 128)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test typemin(Int) <= gnum <= 128
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "infinite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, typemin(Int), typemax(Int))
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Int,gnum) != nothing  # raises exception if value can't be converted
		        @test typemin(Int) <= gnum <= typemax(Int)
		        @mtest_values_vary gnum
		    end
		
		end
		
		@testset "sampler" begin

			cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Int, 29, 301)

			@mtestset "sampler consistent with a discrete uniform distribution" reps=Main.REPS begin
				gnum, trace = DataGenerators.godelnumber(cm, cc)
				@mtest_distributed_as gnum DiscreteUniform(29,301) Main.ALPHA
			end
	
			@testset "get and set parameters" begin
				sampler = first(values(cm.samplers))
				@test getparams(cm) == []
				@test paramranges(cm) == []
			end

		end
	
	end


	@testset "Float64 value choice point" begin

		gn = SCMChooseFloat64Gen()
		cm = SamplerChoiceModel(gn)
		cpi = choicepointinfo(gn)
		cpids = collect(keys(cpi))
	
		@testset "finite range" begin

		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Float64, -42.2, -8.7)

		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test -42.2 <= gnum <= -8.7
		        @mtest_that_sometimes round(gnum) != gnum
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (upper)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Float64, 450001.6, Inf)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test 450001.6 <= gnum
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "semi-finite range (lower)" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Float64, -Inf, 450001.6)
		
		    @mtestset "valid Godel numbers returned" begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @test gnum <= 450001.6
		        @mtest_values_vary gnum
		    end
		
		end

		@testset "infinite range" begin
	
		    cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Float64, -Inf, Inf)
		
		    @mtestset "valid Godel numbers returned" reps=Main.REPS begin
		        gnum, trace = DataGenerators.godelnumber(cm, cc)
		        @test convert(Float64,gnum) != nothing  # raises exception if value can't be converted
		        @mtest_values_vary gnum
		    end
		
		end
		
		@testset "sampler" begin

			cc = DataGenerators.ChoiceContext(DummyDerivationState(), DataGenerators.VALUE_CP, cpids[1], Float64, -180.7, 123.728)

			@mtestset "sampler consistent with a uniform distribution" reps=Main.REPS begin
				gnum, trace = DataGenerators.godelnumber(cm, cc)
				@mtest_distributed_as gnum Uniform(-180.7, 123.728) Main.ALPHA
			end
	
			@testset "get and set parameters" begin
				sampler = first(values(cm.samplers))
				@test getparams(cm) == []
				@test paramranges(cm) == []
			end

		end
	
	end

	@testset "generate for model with multiple choice points" begin

		gn = SCMChooseStringGen()
		cm = SamplerChoiceModel(gn)
	
		@mtestset "full range of values generated using choice model" reps=Main.REPS begin
		    td = choose(gn, choicemodel=cm)
		    @test ismatch(r"^a(b|c)d+ef?$", td)
		    @mtest_values_include count(x->x=='d', td) [1,2,3]
		    @mtest_values_are td[2] ['b','c']
		    @mtest_values_are td[end] ['e','f']
		end

	end
	
	@testset "non-default mapping" begin

		gn = SCMRuleGen()
	
		function nondefaultmapping(info::Dict)
			cptype = info[:type]
			if cptype == DataGenerators.RULE_CP
				sampler = DataGenerators.DiscreteUniformSampler()
			elseif cptype == DataGenerators.SEQUENCE_CP
				sampler = DataGenerators.GeometricSampler()
			elseif cptype == DataGenerators.VALUE_CP
				datatype = info[:datatype]
				if datatype <: Bool
					sampler = DataGenerators.BernoulliSampler()
				elseif datatype <: Integer # order of if clauses matters here since Bool <: Integer
					sampler = DataGenerators.DiscreteUniformSampler()
				else # floating point, but may also be a rational type
					sampler = DataGenerators.UniformSampler()
				end
			else
				error("unrecognised choice point type when creating non-default choice model")
			end
		end

		cm = SamplerChoiceModel(gn, choicepointmapping=nondefaultmapping)
	
		@test length(cm.samplers) == 1
		sampler = first(values(cm.samplers))
		@test typeof(sampler) <: DataGenerators.DiscreteUniformSampler
		
	end

	@testset "estimate parameters" begin
	
		gn = SCMEstimateParamsGen()

		scm1 = SamplerChoiceModel(gn)
		# parameters should be: 1:2 categorical for rule choice; 3: bernoulli for choose(Bool); 4: geometric for mult()
		params = [0.3, 0.7, 0.33, 0.45]
		setparams(scm1, params)

		scm2 = SamplerChoiceModel(gn)
		otherparams = [0.6, 0.4, 0.58, 0.77]
		setparams(scm2, otherparams)
	
		cmtraces = map(1:100) do i
			result, state = generate(gn, choicemodel=scm1)
			state.cmtrace
		end

		estimateparams(scm2, cmtraces)
	
		# to check, we create samplers from the groups of parameters
		# (could also simply 'look inside' the choice model, but this would be less robust to code changes)
		scm2params = getparams(scm2)
		cc = dummyChoiceContext()
		
		cat2 = DataGenerators.CategoricalSampler(2, scm2params[1:2])
	    @mtestset "consistent with categorical" reps=Main.REPS begin
        	x, trace = DataGenerators.sample(cat2, (0,1), cc)
	        @mtest_distributed_as x Categorical(params[1:2]) Main.ALPHA
	    end
		
		bern2 = DataGenerators.BernoulliSampler(scm2params[3:3])
	    @mtestset "consistent with Bernoulli" reps=Main.REPS begin
        	x, trace = DataGenerators.sample(bern2, (0,1), cc)
	        @mtest_distributed_as x Bernoulli(params[3]) Main.ALPHA
	    end

		geom2 = DataGenerators.GeometricSampler(scm2params[4:4])
	    @mtestset "consistent with geometric" reps=Main.REPS begin
        	x, trace = DataGenerators.sample(geom2, (0,1), cc)
	        @mtest_distributed_as x Geometric(params[4]) Main.ALPHA
	    end

	end

end
