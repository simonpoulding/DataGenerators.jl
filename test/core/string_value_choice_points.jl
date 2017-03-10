# tests String value choice points, i.e. using choose(StringDataType, regex) construct

@generator SCWildcardGen begin # prefix SC (for String value Choice points) to avoid type name clashes
    start() = choose(String, ".")
end

@generator SCQuantifiersGen begin
    start() = choose(String, "a?b+c*d{4}e{5,6}f{7,}g{8,8}")
end

@generator SCAlternationGen begin
    start() = choose(String, "foo|bar|baz")
end

@generator SCBracketsGen begin
    start() = choose(String, "a[uvw][x-z0-3]b")
end

@generator SCParenthesesGen begin
    start() = choose(String, "a(bc|de)")
end

@generator SCClassesGen begin
    start() = choose(String, "\\s\\S\\d\\D\\w\\W")
end

@generator SCEscapesGen begin
    start() = choose(String, "\\.\\[\\]\\|\\?\\+\\*\\\\")
end



@testset "string value choice points" begin

	@testset "choose(String) using regex containing wilcard" begin

		gn = SCWildcardGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^.$", td)
		    @mtest_values_vary td
		end
	
	end

	@testset "choose(String) using regex containing quantifiers" begin

		gn = SCQuantifiersGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a?b+c*d{4}e{5,6}f{7,}g{8,8}$", td)
		    @mtest_values_include [0,1] count(x->x=='a',td)
		    @mtest_values_include [1,2,3] count(x->x=='b',td)
		    @mtest_values_include [0,1,2] count(x->x=='c',td)
		    @mtest_values_include [4,] count(x->x=='d',td)
		    @mtest_values_include [5,6] count(x->x=='e',td)
		    @mtest_values_include [7,8,9] count(x->x=='f',td)
		    @mtest_values_are [8] count(x->x=='g',td)
		end
	
	end

	@testset "choose(String) using regex containing alternation" begin

		gn = SCAlternationGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^foo|bar|baz$", td)
		    @mtest_values_are ["foo","bar","baz"] td
		end
	
	end

	@testset "choose(String) using regex containing bracket" begin

		gn = SCBracketsGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a[uvw][x-z0-3]b$", td)
		    @mtest_values_are ['u','v','w'] td[2]
		    @mtest_values_are ['x','y','z','0','1','2','3'] td[3]
		end
	
	end

	@testset "choose(String) using regex containing parentheses" begin

		gn = SCParenthesesGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a(bc+|de+)$", td)
		    @mtest_values_are ['b','d'] td[2]
		    @mtest_values_are ['c','e'] td[3]
		end
	
	end

	@testset "choose(String) using regex containing classes" begin

		gn = SCClassesGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^\s\S\d\D\w\W$", td)
		    @mtest_values_vary td
		end
		
	end

	@testset "choose(String) using regex that escapes metacharacters" begin

		gn = SCEscapesGen()

		@mtestset reps=Main.REPS alpha=Main.ALPHA begin
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^\.\[\]\|\?\+\*\\$", td)
		end
	
	end

end