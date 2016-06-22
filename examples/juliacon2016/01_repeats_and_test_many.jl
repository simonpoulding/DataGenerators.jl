using BaseTestAuto

@testset repeats=100 "sign takes values in [-1, 0, 1]" begin
    i = rand(-10:10)
    @test_many sign(i) takes_values([-1, 0, 1])
end

@testset repeats=true "sign takes values in [-1, 0, 1]" begin
    i = rand(-10:10)
    @test_many sign(i) takes_values([-1, 0, 1])
end