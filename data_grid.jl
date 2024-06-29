# datagrid ================================================================================
import DataFrames
# import CategoricalArrays


# datagrid: Vectors ------------------------------------------------------------------------
# https://github.com/neuropsychology/Psycho.jl/blob/master/src/modelling/datagrid.jl

function data_grid(X::AbstractVector{<:Union{Real,Missing}}; n::Int=10)
    X = skipmissing(X)
    X = collect(range(minimum(X), stop=maximum(X), length=n))
end

# function data_grid(X::DataFrames.CategoricalVector ; n=nothing)
#     X = levels(X)
# end


function data_grid(X::AbstractVector{<:Union{String,Missing}}; n=nothing)
    X = unique(skipmissing(X))
end


