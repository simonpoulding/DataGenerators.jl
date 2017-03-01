# Only two functions are exported. One to register generators and one to flexibly match them.
# export register, generator_for

# Generators are registered in a registry. Many registries are possible, this is their base type:
abstract GeneratorRegistry

# The default registry matches generator requests to the :generates tag of the meta info.
type DocStringMatchingRegistry <: GeneratorRegistry
	descriptorstogenerators::Dict

	DocStringMatchingRegistry() = new(Dict{String, Vector{Generator}}())
end

global godelTestGeneratorRegistry = DocStringMatchingRegistry()

function resetregistry(r::GeneratorRegistry = godelTestGeneratorRegistry)
	r.descriptors_to_generators = Dict{String, Vector{Generator}}()
end

# Return an array of meta tags that are in the generates tag.
function metataggenerates(g::Generator)
	tags = meta(g)[:generates]
	if typeof(tags) <: Array
		tags
	elseif typeof(tags) <: AbstractString
		[tags]
	else
		error("Don't know how to return the tags from $(tags)")
	end
end

function register(g::Generator, r::GeneratorRegistry = godelTestGeneratorRegistry)
	for descriptor in metataggenerates(g)
		registerdescriptor(r, descriptor, g)
	end
end

# Register a descriptor for a generator.
function registerdescriptor(r::DocStringMatchingRegistry, descriptor::AbstractString, g::Generator)
	gens = get!(r.descriptorstogenerators, descriptor, Generator[])
	push!(gens, g)
	gens
end

function generatorfor(description::AbstractString, r::DocStringMatchingRegistry = godelTestGeneratorRegistry)
	# Only use approximate matching if no exact matches found.
	generators = findmatchinggenerators(r, description)
	if length(generators) == 0
		generators = findapproximatelymatchinggenerators(r, description)
	end

	# Return an OrGenerator that generates from any of its sub generators.
	#OrGenerator(generators)
	# For now lets just return one randomly:
	if length(generators) > 0
		generators[rand(1:length(generators))]
	else
		error("No generator found")
	end
end

# A convenience version
gen(desc::AbstractString; state = nothing) = first(generate(generator_for(desc); state = state))

# Implements exact matching.
function findmatchinggenerators(r::GeneratorRegistry, description)
	for descriptor in keys(r.descriptorstogenerators)
		if descriptor == description
			return r.descriptorstogenerators[descriptor]
		end
	end
	[] # nothing found!
end

wordsofstring(s) = split(s, " ")

StopWords = ["a", "an", "of", "the"]

skipstopwords(words) = filter((w) -> !in(w, StopWords), words)

numcommonwords(ws1, ws2) = sum(map((w) -> in(w, ws2), ws1))

numcommonwords(s1::AbstractString, s2::AbstractString) = numcommonwords(skipstopwords(wordsofstring(s1)), 
	skipstopwords(wordsofstring(s2)))

# This needs to be a much smarter heuristic over time. For example 
# "a small float" would match "a small integer" which is not really what we want.
function findapproximatelymatchinggenerators(r::GeneratorRegistry, description)
	gens = []
	for descriptor in keys(r.descriptorstogenerators)
		if numcommonwords(descriptor, description) >= 1
			gens = cat(1, gens, r.descriptorstogenerators[descriptor])
		end
	end
	unique(gens)
end

