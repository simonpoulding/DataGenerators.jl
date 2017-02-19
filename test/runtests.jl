using BaseTestNext
using DataGenerators

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


@testset "DataGenerators test suite" begin
  
  @testset "01core" begin
    include(joinpath("01core","test_010_generator_methods.jl"))
    include(joinpath("01core","test_020_sequence_choice_points.jl"))
    include(joinpath("01core","test_030_rule_choice_points.jl"))
    include(joinpath("01core","test_040_value_choice_points.jl"))
    include(joinpath("01core","test_050_string_value_choice_points.jl"))
    include(joinpath("01core","test_060_subgenerators.jl"))
    include(joinpath("01core","test_070_metadata.jl"))
    include(joinpath("01core","test_080_generate.jl"))
  end

  @testset "02internals" begin
    include(joinpath("02internals","test_010_choice_point_info.jl"))
    include(joinpath("02internals","test_080_using_generators_in_different_scopes.jl"))
    include(joinpath("02internals","test_110_bernoulli_sampler.jl"))
    include(joinpath("02internals","test_120_categorical_sampler.jl"))
    include(joinpath("02internals","test_130_discrete_uniform_sampler.jl"))
    # include(joinpath("02internals","test_140_geometric_sampler.jl"))
    # include(joinpath("02internals","test_150_normal_sampler.jl"))
    # include(joinpath("02internals","test_160_uniform_sampler.jl"))
    # include(joinpath("02internals","test_210_mixture_sampler.jl"))
    # include(joinpath("02internals","test_220_adjust_parameters_to_support_sampler.jl"))
    # include(joinpath("02internals","test_230_align_minimum_support_sampler.jl"))
    # include(joinpath("02internals","test_240_truncate_to_support_sampler.jl"))
    # include(joinpath("02internals","test_250_transform_sampler.jl"))
    # include(joinpath("02internals","test_260_constrain_parameters_sampler.jl"))
    include(joinpath("02internals","test_410_default_choice_model.jl"))
    # include(joinpath("02internals","test_420_sampler_choice_model.jl"))
  end

  @testset "03examples" begin
    include(joinpath("03examples","test_010_simple_arithmetic_expression.jl"))
  end

end
