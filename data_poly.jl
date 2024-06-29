using LinearAlgebra
using Statistics

"""
    data_poly(x, degree=2; orthogonal=false)

Compute the (orthogonal) polynomial matrix of a vector `x` up to a given `degree`.

# Examples
```jldoctest
julia> data_poly([1, 2, 3])
3×2 Matrix{Int64}:
 1  1
 2  4
 3  9

julia> data_poly([1, 2, 3], orthogonal=true)
3×2 Matrix{Float64}:
 -0.707107  -0.707107
  0.0        0.0
  0.707107  -0.707107
```
"""
function data_poly(x, degree=2; orthogonal=false)
    if orthogonal
        z = x .- mean(x)  # Center the data by subtracting its mean
        X = hcat([z .^ deg for deg in 1:degree]...)  # Create the matrix of powers up to 'degree'
        QR = qr(X)  # Perform QR decomposition
        X = Matrix(QR.Q)  # Extract the orthogonal matrix Q
    else
        X = hcat([x .^ deg for deg in 1:degree]...)  # Create the matrix of powers up to 'degree'
    end
    return X
end



# Test against R =============================================

# using BenchmarkTools
# using RCall

# x = rand(10);
# poly = data_poly(x, 2)

# @rput x;
# R"poly(x, 2, raw=TRUE)"

# y = rand(10);
# @rput y;
# R"as.data.frame(model.matrix(lm(y ~ poly(x, 2, raw=TRUE), data=data.frame(x=x, y=y))))"


# R"""
# z <- x - mean(x)
# X <- sapply(1:2, function(deg) z^deg)
# qr(X)
# # QR <- qr.Q(qr(X))
# # QR
# """

# R"""
# data_poly <- function(x, degree=2) {
#   z <- x - mean(x)
#   X <- sapply(1:degree, function(deg) z^deg)
#   QR <- qr.Q(qr(X))
#   QR
# }
# """

