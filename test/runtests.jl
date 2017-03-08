using DataGenerators
using Base.Test
include(joinpath("multitest","MultiTest.jl"))
using MultiTest
using Distributions


#
# Temporarily stub out BaseTestAuto features
#
NumReps = 1
macro mcheck_values_include(params...)
  quote warn("Skipping mcheck_values_include") end
end
macro mcheck_values_are(params...)
  quote warn("Skipping mcheck_values_are") end
end
macro mcheck_values_vary(params...)
  quote warn("Skipping mcheck_values_are") end
end
# macro mcheck_values_sometimes(params...)
#   quote warn("Skipping mcheck_values_sometimes") end
# end
macro mcheck_that_sometimes(params...)
  quote warn("Skipping mcheck_that_sometimes") end
end
#

# note that owing to bug (?) in option passing to TestSets, this must be explicitly prefixed by module (e.g. Main.REPS) in that context
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
		include(joinpath("internals","default_choice_model.jl"))
		include(joinpath("internals","bernoulli_sampler.jl"))
		include(joinpath("internals","categorical_sampler.jl"))
		include(joinpath("internals","geometric_sampler.jl"))
		include(joinpath("internals","discrete_uniform_sampler.jl"))
		include(joinpath("internals","uniform_sampler.jl"))
		include(joinpath("internals","normal_sampler.jl"))
		include(joinpath("internals","mixture_sampler.jl"))
	    # # include(joinpath("02internals","test_220_adjust_parameters_to_support_sampler.jl"))
	    # # include(joinpath("02internals","test_230_align_minimum_support_sampler.jl"))
	    # # include(joinpath("02internals","test_240_truncate_to_support_sampler.jl"))
	    # # include(joinpath("02internals","test_250_transform_sampler.jl"))
	    # # include(joinpath("02internals","test_260_constrain_parameters_sampler.jl"))		
		include(joinpath("internals","sampler_choice_model.jl"))
	end

	@testset "examples" begin
		include(joinpath("examples","simple_arithmetic_expression.jl"))
	end

end
