"""
    data_rescale(x; old_range=[minimum(x), maximum(x)], new_range=[0, 1])

Rescale a variable to a new range.

"""
function data_rescale(x; old_range=[minimum(x), maximum(x)], new_range=[0, 1])
    return (x .- old_range[1]) ./ (old_range[2] - old_range[1]) .* (new_range[2] - new_range[1]) .+ new_range[1]
end
