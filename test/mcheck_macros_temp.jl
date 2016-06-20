# This is just temp implementations of the old mcheck macros.
# They are not always testing the same thing or, in fact, anything.
# These will be changed when we use latest BaseTestAuto/AutoTest package.

macro mcheck_values_include(expr, expected)
    :(:not_implemented)
end

macro mcheck_values_are(expr, expected)
    :(@test in($expr, $expected)) # Only partially correct
end

macro mcheck_that_sometimes(ex)
    :(:not_implemented)
end

macro mcheck_values_vary(ex)
    :(:not_implemented)
end