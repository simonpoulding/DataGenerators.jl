using Base.Test
include("MultiTest.jl")
using MultiTest
using Distributions

@testset "mtest" begin

	@mtestset "@mtestset block PASS" begin
		@mtest_values_vary rand(1:6)
	end

	@mtestset "@mtestset for a=$(a) b=$(b) PASS exc FAIL when a=b" for a in 3:-1:1, b in a:3
		x = rand(a:b)
		@test a <= x <= b
		@mtest_values_vary x
	end

	@mtestset "@mtestset block reps=1 FAIL" reps=1 begin
		@mtest_values_vary rand(1:6)
	end

	@testset "@mtestset with no description PASS" begin
		@mtestset begin
			@mtest_values_vary rand(1:6)
		end
	end

	@testset MultiTestSet "@testset MultiSet disables automatic repetitions FAIL" begin
		@mtest_values_vary rand(1:100)
	end

	@testset MultiTestSet "values_vary PASS" begin
		for x in [1,2,1]
			@mtest_values_vary x
		end
	end

	@testset MultiTestSet "values_vary FAIL" begin
		for x in [1,1,1]
			@mtest_values_vary x
		end
	end

	@testset MultiTestSet "values_are FAIL" begin
		for x in [:b,:a,:d]
			@mtest_values_are x [:a,:c,:b]
		end
	end

	@testset MultiTestSet "values_include PASS" begin
		for x in ["i","j","k"]
			@mtest_values_include x ["k","i"]
		end
	end

	@testset MultiTestSet "values_include FAIL" begin
		for x in ["i","j","k"]
			@mtest_values_include x ["k","q"]
		end
	end

	@testset MultiTestSet "that_sometimes PASS" begin
		for x in 1:5
			@mtest_that_sometimes x % 2 == 0
		end
	end

	@testset MultiTestSet "that_sometimes FAIL" begin
		for x in [1,3,5]
			@mtest_that_sometimes x % 2 == 0
		end
	end

	@testset MultiTestSet "multiple (m)tests PASS" begin
		for x in 1:5
			@mtest_values_include x [3,2,1]
			@mtest_that_sometimes x % 2 == 0
			@test x > 0
			@mtest_values_vary x
			@mtest_values_are x [4,5,3,2,1]
		end
	end

	@testset MultiTestSet "evaluand (sometimes) raises an exception PASS & ERRORS" begin
		for x in [-4.0,-1.0,1.0,4.0,9.0]
			@mtest_values_include sqrt(x) [2.0,3.0]
		end
	end

	@testset MultiTestSet "distributed_as PASS" begin
		for x in 0:30
			@mtest_distributed_as x DiscreteUniform(0,30) 0.01
		end
	end

	@testset MultiTestSet "distributed_as FAIL" begin
		for x in 0:30
			@mtest_distributed_as x Binomial(30, 0.9) 0.01
		end
	end

	@testset MultiTestSet "distributed_as against range PASS" begin
		for x in 0:30
			@mtest_distributed_as x 0:30 0.01
		end
	end

	@mtestset "distributed_as uses correct scope (success prob, p=$p; sig level: $alpha) FAIL exc PASS when p=0.5" reps=20 for p in [0.1, 0.5, 0.9], alpha in [0.01, 0.05, 0.1, 0.5]
		@mtest_distributed_as rand(DiscreteUniform(0,30)) Binomial(30, p) alpha
	end

end