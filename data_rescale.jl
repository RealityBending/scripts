"""
    data_rescale(x; old_range=[minimum(x), maximum(x)], new_range=[0, 1])

Rescale a variable to a new range.

# Examples
```jldoctest
julia> data_rescale([1, 2, 3])
3-element Vector{Float64}:
 0.0
 0.5
 1.0

julia> data_rescale([1, 2, 3]; old_range=[1, 6], new_range=[1, 0])
3-element Vector{Float64}:
 1.0
 0.8
 0.6
```
"""
function data_rescale(x; old_range=[minimum(x), maximum(x)], new_range=[0, 1])
    return (x .- old_range[1]) ./ (old_range[2] - old_range[1]) .* (new_range[2] - new_range[1]) .+ new_range[1]
end
