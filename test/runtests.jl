using DataGenerators
using Base.Test
using BaseTestMulti
using Distributions

# note that owing to scoping bug (?) in option passing to TestSets, this must be explicitly prefixed by module (e.g. Main.REPS) in that context
const REPS = 30 # number of repetitions in MultiTestSet test sets
const ALPHA = 0.01 # significance level for @mtests based on hypothesis test 

@testset "DataGenerators" begin

	include("test_utils.jl")

	@testset "core" begin
	    include(joinpath("core","generator_methods.jl"))
	    include(joinpath("core","sequence_choice_points.jl"))
	    include(joinpath("core","rule_choice_points.jl"))
	    include(joinpath("core","value_choice_points.jl"))
	    include(joinpath("core","string_value_choice_points.jl"))
	    include(joinpath("core","subgenerators.jl"))
	    include(joinpath("core","metadata.jl"))
	    include(joinpath("core","generate.jl"))
	    include(joinpath("core","generator_scope.jl"))
	end
	
	@testset "internals" begin
		include(joinpath("internals","choice_point_info.jl"))
		include(joinpath("internals","simple_choice_model.jl"))
		include(joinpath("internals","bernoulli_sampler.jl"))
		include(joinpath("internals","categorical_sampler.jl"))
		include(joinpath("internals","geometric_sampler.jl"))
		include(joinpath("internals","discrete_uniform_sampler.jl"))
		include(joinpath("internals","uniform_sampler.jl"))
		include(joinpath("internals","normal_sampler.jl"))
		include(joinpath("internals","mixture_sampler.jl"))
	    include(joinpath("internals","adjust_parameters_to_support_sampler.jl"))
	    include(joinpath("internals","align_minimum_support_sampler.jl"))
		include(joinpath("internals","recursion_depth_sampler.jl"))
			# include(joinpath("internals","_truncate_to_support_sampler.jl"))
			# include(joinpath("internals","_transform_sampler.jl"))
			# include(joinpath("internals","_constrain_parameters_sampler.jl"))
		include(joinpath("internals","sampler_choice_model.jl"))
	end

	@testset "examples" begin
		include(joinpath("examples","simple_arithmetic_expression.jl"))
	end

end
