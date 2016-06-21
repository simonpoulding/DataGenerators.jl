using DataGenerators

@generator EmailAddress begin
    generates: "an email address"
    start() = choose(ASCIIString, "([a-z0-9]+\\.)*[a-z0-9]+@([a-z0-9]+\\.){1,2}[a-z0-9]+")
end

addr = choose(EmailAddress())
