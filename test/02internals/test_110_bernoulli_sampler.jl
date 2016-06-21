include("sampler_test_utils.jl")

@testset "Bernoulli Sampler" begin

cc = dummyChoiceContext()

@testset "default construction" begin
		
    s = GodelTest.BernoulliSampler()

    @testset "numparams and paramranges" begin
        @test GodelTest.numparams(s) == 1
        prs = GodelTest.paramranges(s)
        @test typeof(prs) <: Vector{Tuple{Float64,Float64}} 
        @test prs == [(0.0,1.0)]
    end
	
    @testset "default params" begin
        @test GodelTest.getparams(s) == [0.5]
        @test isconsistentbernoulli(s, GodelTest.getparams(s))
    end

    @testset repeats=NumReps "default sampling" begin
        x, trace = GodelTest.sample(s, (0,1), cc)
        @test typeof(x) <: Int
        @mcheck_values_are x [0,1]
    end
		
end
	
@testset "non-default construction" begin

    s = GodelTest.BernoulliSampler([0.3])

    @testset "constructor with params" begin
        @test GodelTest.getparams(s) == [0.3]
        @test isconsistentbernoulli(s, GodelTest.getparams(s))
    end

end

@testset "parameter setting" begin

    s = GodelTest.BernoulliSampler()
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
            @test isconsistentbernoulli(s, params)
            params[pidx] = prevfloat(pr[1])
            #@test_throws ArgumentError GodelTest.setparams(s, params)
            @test_throws ErrorException GodelTest.setparams(s, params)
            params[pidx] = pr[2] 
            GodelTest.setparams(s, params)
            @test isconsistentbernoulli(s, params)
            params[pidx] = nextfloat(pr[2])
            #@test_throws ArgumentError GodelTest.setparams(s, params)
            @test_throws ErrorException GodelTest.setparams(s, params)
        end
    end

    @testset "setparams with random parameters" for i in 1:NumReps 
        params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
        # convulated expression involving middle to avoid overflow to Inf
        GodelTest.setparams(s, params)
        @test isconsistentbernoulli(s, params)
    end

end

@testset "estimate parameters" begin

    s = GodelTest.BernoulliSampler()
    prs = GodelTest.paramranges(s)
    otherparams = [0.5]

    @testset "lower bound" begin
        params = [0.0]
        s1 = GodelTest.BernoulliSampler(params)
        s2 = GodelTest.BernoulliSampler(otherparams)	
        traces = map(1:100) do i
            x, trace = GodelTest.sample(s1, (0,1), cc)
            trace
        end
        estimateparams(s2, traces)
        @test isconsistentbernoulli(s2, params)
    end

    @testset "upper bound" begin
        params = [1.0]
        s1 = GodelTest.BernoulliSampler(params)
        s2 = GodelTest.BernoulliSampler(otherparams)	
        traces = map(1:100) do i
            x, trace = GodelTest.sample(s1, (0,1), cc)
            trace
        end
        estimateparams(s2, traces)
        @test isconsistentbernoulli(s2, params)
    end

    @testset "random params" begin
        params = map(pr->robustmidpoint(pr[1],pr[2])+(2.0*rand()-1.0)*(pr[2]-robustmidpoint(pr[1],pr[2])), prs)
        # convulated expression involving middle to avoid overflow to Inf
        s1 = GodelTest.BernoulliSampler(params)
        s2 = GodelTest.BernoulliSampler(otherparams)	
        traces = map(1:100) do i
            x, trace = GodelTest.sample(s1, (0,1), cc)
            trace
        end
        estimateparams(s2, traces)
        @test isconsistentbernoulli(s2, params)
    end

    @testset "too few traces" begin
        params = [0.2]
        s1 = GodelTest.BernoulliSampler(params)
        s2 = GodelTest.BernoulliSampler(otherparams)	
        traces = map(1:0) do i
            x, trace = GodelTest.sample(s1, (0,1), cc)
            trace
        end
        @test isconsistentbernoulli(s2, otherparams)
    end

end

end
