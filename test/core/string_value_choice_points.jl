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

	@testset MultiTestSet "choose(String) using regex containing wilcard" begin

		gn = SCWildcardGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^.$", td)
		    @mtest_values_vary td
		end
	
	end

	@testset MultiTestSet "choose(String) using regex containing quantifiers" begin

		gn = SCQuantifiersGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a?b+c*d{4}e{5,6}f{7,}g{8,8}$", td)
		    @mtest_values_include count(x->x=='a',td) [0,1]
		    @mtest_values_include count(x->x=='b',td) [1,2,3]
		    @mtest_values_include count(x->x=='c',td) [0,1,2]
		    @mtest_values_include count(x->x=='d',td) [4,]
		    @mtest_values_include count(x->x=='e',td) [5,6]
		    @mtest_values_include count(x->x=='f',td) [7,8,9]
		    @mtest_values_are count(x->x=='g',td) [8]
		end
	
	end

	@testset MultiTestSet "choose(String) using regex containing alternation" begin

		gn = SCAlternationGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^foo|bar|baz$", td)
		    @mtest_values_are td ["foo","bar","baz"]
		end
	
	end

	@testset MultiTestSet "choose(String) using regex containing bracket" begin

		gn = SCBracketsGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a[uvw][x-z0-3]b$", td)
		    @mtest_values_are td[2] ['u','v','w']
		    @mtest_values_are td[3] ['x','y','z','0','1','2','3']
		end
	
	end

	@testset MultiTestSet "choose(String) using regex containing parentheses" begin

		gn = SCParenthesesGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^a(bc+|de+)$", td)
		    @mtest_values_are td[2] ['b','d']
		    @mtest_values_are td[3] ['c','e']
		end
	
	end

	@testset MultiTestSet "choose(String) using regex containing classes" begin

		gn = SCClassesGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^\s\S\d\D\w\W$", td)
		    @mtest_values_vary td
		end
		
	end

	@testset MultiTestSet "choose(String) using regex that escapes metacharacters" begin

		gn = SCEscapesGen()

		for i in 1:mtest_num_reps
		    td = choose(gn)
		    @test typeof(td) == String
		    @test ismatch(r"^\.\[\]\|\?\+\*\\$", td)
		end
	
	end

end