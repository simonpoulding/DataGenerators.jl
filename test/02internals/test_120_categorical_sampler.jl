include("sampler_test_utils.jl")

@testset "Categorical Sampler" begin

@testset "default construction" begin

s = GodelTest.CategoricalSampler(4)

@testset "numparams and paramranges" begin
    @test GodelTest.numparams(s) == 4
    prs = GodelTest.paramranges(s)
    @test typeof(prs) <: Vector{Tuple{Float64,Float64}}
    @test prs == fill((0.0,1.0), GodelTest.numparams(s))
end
	
@testset "default params" begin
    @test GodelTest.getparams(s) == [0.25, 0.25, 0.25, 0.25]
    @test isconsistentcategorical(s, GodelTest.getparams(s))
end
	
@testset repeats=NumReps "default sampling" begin
    x, trace = GodelTest.sample(s, (0,1))
    @test typeof(x) <: Int
    @mcheck_values_are x [1,2,3,4]
end
		
end
		
@testset "non-default construction" begin

s = GodelTest.CategoricalSampler(5, [0.3,0.2,0.1,0.2,0.2])
		
@testset "constructor with params" begin
    @test getparams(s) == [0.3,0.2,0.1,0.2,0.2]
    @test isconsistentcategorical(s, GodelTest.getparams(s))
end

end
	
@testset "parameter setting" begin
	
s = GodelTest.CategoricalSampler(4)
prs = GodelTest.paramranges(s)
midparams = map(pr->robustmidpoint(pr[1],pr[2]), prs)

@testset "setparams with wrong number of parameters" begin
    #@test_throws ArgumentError GodelTest.setparams(s, midparams[1:end-1])
    @test_throws ErrorException GodelTest.setparams(s, midparams[1:end-1])
    #@test_throws ArgumentError GodelTest.setparams(s, [midparams, 0.5])
    @test_throws ErrorException GodelTest.setparams(s, [midparams; 0.5])
end

@testset "setparams boundary values" begin
    for pidx = 1:length(prs)
        pr = prs[pidx]
        params = copy(midparams)
        params[pidx] = pr[1] 
        GodelTest.setparams(s, params)
        @test isconsistentcategorical(s, params)
        params[pidx] = prevfloat(pr[1])
        #@test_throws ArgumentError GodelTest.setparams(s, params)
        @test_throws ErrorException GodelTest.setparams(s, params)
        params[pidx] = pr[2] 
        GodelTest.setparams(s, params)
        @test isconsistentcategorical(s, params)
        params[pidx] = nextfloat(pr[2])
        #@test_throws ArgumentError GodelTest.setparams(s, params)
        @test_throws ErrorException GodelTest.setparams(s, params)
    end
end
	
@testset "setparams normalises weights" begin
    GodelTest.setparams(s, [0.4, 0.6, 0.7, 0.3])
    @test getparams(s) == [0.2, 0.3, 0.35, 0.15]
    @test isconsistentcategorical(s, GodelTest.getparams(s))
end
	
@testset "setparams adjusts when all weights are zero" begin
    GodelTest.setparams(s, [0.0, 0.0, 0.0, 0.0])
    @test getparams(s) == [0.25, 0.25, 0.25, 0.25]
    @test isconsistentcategorical(s, GodelTest.getparams(s))
end

@testset repeats=NumReps "setparams with random parameters" begin
    params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
    # convulated expression involving middle to avoid overflow to Inf
    GodelTest.setparams(s, params)
    @test isconsistentcategorical(s, params)
end
		
end
	
@testset "estimate parameters" begin
		
s = GodelTest.CategoricalSampler(5)
prs = GodelTest.paramranges(s)
otherparams = [0.35, 0.15, 0.1, 0.25, 0.15]
		
@testset "equal bounds" begin
    params = [0.2, 0.2, 0.2, 0.2, 0.2]
    s1 = GodelTest.CategoricalSampler(5, params)
    s2 = GodelTest.CategoricalSampler(5, otherparams)	
    traces = map(1:100) do i
        x, trace = GodelTest.sample(s1, (0,1))
        trace
    end
    estimateparams(s2, traces)
    @test isconsistentcategorical(s2, params)
end

@testset "last category never sampled" begin
    params = [0.3, 0.4, 0.2, 0.1, 0.0]
    s1 = GodelTest.CategoricalSampler(5, params)
    s2 = GodelTest.CategoricalSampler(5, otherparams)	
    traces = map(1:100) do i
        x, trace = GodelTest.sample(s1, (0,1))
        trace
    end
    estimateparams(s2, traces)
    @test isconsistentcategorical(s2, params)
end

@testset "random params" begin
    params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
    # convulated expression involving middle to avoid overflow to Inf
    s1 = GodelTest.CategoricalSampler(5, params)
    s2 = GodelTest.CategoricalSampler(5, otherparams)	
    traces = map(1:100) do i
        x, trace = GodelTest.sample(s1, (0,1))
        trace
    end
    estimateparams(s2, traces)
    @test isconsistentcategorical(s2, params)
end
		
@testset "too few traces" begin
    params = [0.1, 0.2, 0.4, 0.2, 0.1]
    s1 = GodelTest.CategoricalSampler(5, params)
    s2 = GodelTest.CategoricalSampler(5, otherparams)	
    traces = map(1:0) do i
        x, trace = GodelTest.sample(s1, (0,1))
        trace
    end
    @test isconsistentcategorical(s2, otherparams)
end
		
end
		
end
