using Base.Test
include("MultiTest.jl")
using MultiTest
using Distributions

@testset "mtest" begin

	@testset MultiTestSet "values_vary pass" begin
		for x in [1,2,1]
			@mtest_values_vary x
		end
	end

	@testset MultiTestSet "values_vary fail" begin
		for x in [1,1,1]
			@mtest_values_vary x
		end
	end

	@testset MultiTestSet "values_are pass" begin
		for x in [:b,:a,:c]
			@mtest_values_are x [:a,:c,:b]
		end
	end

	@testset MultiTestSet "values_are fail" begin
		for x in [:b,:a,:d]
			@mtest_values_are x [:a,:c,:b]
		end
	end

	@testset MultiTestSet "values_include pass" begin
		for x in ["i","j","k"]
			@mtest_values_include x ["k","i"]
		end
	end

	@testset MultiTestSet "values_include fail" begin
		for x in ["i","j","k"]
			@mtest_values_include x ["k","q"]
		end
	end

	@testset MultiTestSet "that_sometimes pass" begin
		for x in 1:5
			@mtest_that_sometimes x % 2 == 0
		end
	end

	@testset MultiTestSet "that_sometimes fail" begin
		for x in [1,3,5]
			@mtest_that_sometimes x % 2 == 0
		end
	end

	@testset MultiTestSet "multiple (m)tests" begin
		for x in 1:5
			@mtest_values_include x [3,2,1]
			@mtest_that_sometimes x % 2 == 0
			@test x > 0
			@mtest_values_vary x
			@mtest_values_are x [4,5,3,2,1]
		end
	end

	@testset MultiTestSet "evaluand (sometimes) raises an exception" begin
		for x in [-4.0,-1.0,1.0,4.0,9.0]
			@mtest_values_include sqrt(x) [2.0,3.0]
		end
	end

	@testset MultiTestSet "distributed_as pass" begin
		for x in 0:30
			@mtest_distributed_as x DiscreteUniform(0,30) 0.01
		end
	end

	@testset MultiTestSet "distributed_as fail" begin
		for x in 0:30
			@mtest_distributed_as x Binomial(30, 0.9) 0.01
		end
	end

	@testset MultiTestSet "distributed_as against range" begin
		for x in 0:30
			@mtest_distributed_as x 0:30 0.01
		end
	end

	@testset MultiTestSet "distributed_as uses correct scope (success prob: $p; sig level: $alpha)" for p in [0.1, 0.5, 0.9], alpha in [0.01, 0.05, 0.1, 0.5]
		for r in 1:20
			@mtest_distributed_as rand(DiscreteUniform(0,30)) Binomial(30, p) alpha
		end
	end

end