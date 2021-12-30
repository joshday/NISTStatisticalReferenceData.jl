using NISTStatisticalReferenceData
using Test

@testset "NISTStatisticalReferenceData.jl" begin
    @testset "Load Every Dataset" begin
        dsets = NISTStatisticalReferenceData.datasets()
        for (k,v) in dsets
            for vi in v 
                println("Loading $vi...")
                t = NISTStatisticalReferenceData.TestCase(vi)
                @test !isempty(t.certified_values)
            end
        end
    end
end
