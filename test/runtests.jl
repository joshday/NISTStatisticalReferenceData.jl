using NISTStatisticalReferenceData
using Test

@testset "NISTStatisticalReferenceData.jl" begin
    @testset "Load Every Dataset" begin
        dsets = NISTStatisticalReferenceData.datasets()
        for (k,v) in dsets
            for vi in v 
                println("Loading $vi...")
                NISTStatisticalReferenceData.TestCase(vi)
            end
        end
    end
end
