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
    n = length(x)

    if orthogonal
        # Step 1: Center the data by subtracting its mean
        z = x .- mean(x)

        # Step 2: Generate the raw polynomial design matrix up to 'degree'
        X_raw = hcat([z .^ d for d in 0:degree]...)

        # Step 3: QR decomposition
        QR = qr(X_raw)

        # Step 4: Extract the orthogonal matrix Q
        Z = Matrix(QR.Q[:, 2:end])  # Drop the first column corresponding to the constant term

        # Step 5: Scale columns to have norm 1 (to match R's behavior)
        norm2 = sum(Z .^ 2, dims=1)
        Z = Z ./ sqrt.(norm2)

        # Step 6: Ensure the signs are consistent
        for j in 1:size(Z, 2)
            if sum(Z[:, j]) < 0
                Z[:, j] = -Z[:, j]
            end
        end

        return Z
    else
        # Raw polynomial terms
        X = hcat([x .^ d for d in 1:degree]...)
        return X
    end
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

