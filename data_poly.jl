using LinearAlgebra
using Statistics

"""
    data_poly(x, degree=2; orthogonal=false)

Compute the (orthogonal) polynomial matrix of a vector `x` up to a given `degree`.

# Examples
```jldoctest
julia> data_poly([1, 2, 3, 4])  # R: poly(c(1, 2, 3, 4), 2, raw=TRUE)
4×2 Matrix{Float64}:
 1.0   1.0
 2.0   4.0
 3.0   9.0
 4.0  16.0

julia> data_poly([1, 2, 3, 4], orthogonal=true)  # R: poly(c(1, 2, 3, 4), 2)
4×2 Matrix{Float64}:
 -0.67082    0.5
 -0.223607  -0.5
  0.223607  -0.5
  0.67082    0.5
```
"""
function data_poly(x::AbstractVector{<:Number}, degree::Int=2; orthogonal::Bool=false)
    n = length(x)
    T = promote_type(eltype(x), Float64)
    x_T = Array{T}(undef, n)
    @inbounds @simd for i in 1:n
        x_T[i] = x[i]
    end

    if !orthogonal
        # Raw polynomials
        X = Array{T}(undef, n, degree)
        @inbounds for d in 1:degree
            @simd for i in 1:n
                X[i, d] = x_T[i] ^ d
            end
        end
        return X
    else
        # Orthogonal polynomials
        # Step 1: Center the data without modifying the original x_T
        x_centered = Array{T}(undef, n)
        x_mean = mean(x_T)
        @inbounds @simd for i in 1:n
            x_centered[i] = x_T[i] - x_mean
        end

        # Step 2: Initialize variables
        degree_plus_one = degree + 1
        Z = Array{T}(undef, n, degree_plus_one)
        norm2 = Array{T}(undef, degree_plus_one)
        alpha = Array{T}(undef, degree)

        # Step 3: Modified Gram-Schmidt process
        # P0(x) = 1
        @inbounds @simd for i in 1:n
            Z[i, 1] = 1
        end
        norm2[1] = n  # Since Z[:, 1] is all ones

        for k in 1:degree
            Zk = @view Z[:, k + 1]
            Zprev = @view Z[:, k]

            # Pk(x) = x_centered .* Pk-1(x)
            @inbounds @simd for i in 1:n
                Zk[i] = x_centered[i] * Zprev[i]
            end

            # Orthogonalize against previous polynomials
            for j in 1:k
                Zj = @view Z[:, j]
                # Compute dot product Zj' * Zk
                dot = zero(T)
                @inbounds @simd for i in 1:n
                    dot += Zj[i] * Zk[i]
                end
                alpha_jk = dot / norm2[j]
                # Update Zk
                @inbounds @simd for i in 1:n
                    Zk[i] -= alpha_jk * Zj[i]
                end
                if j == k
                    alpha[k] = alpha_jk
                end
            end

            # Compute norm squared of the new polynomial
            norm2_k1 = zero(T)
            @inbounds @simd for i in 1:n
                norm2_k1 += Zk[i] * Zk[i]
            end
            norm2[k + 1] = norm2_k1
        end

        # Step 4: Normalize the polynomials
        for k in 2:degree_plus_one
            Zk = @view Z[:, k]
            inv_normk = inv(sqrt(norm2[k]))
            @inbounds @simd for i in 1:n
                Zk[i] *= inv_normk
            end
        end

        # Step 5: Adjust signs to match R's convention
        for k in 2:degree_plus_one
            Zk = @view Z[:, k]
            desired_sign = (-1)^(k + 1)
            if sign(Zk[1]) != desired_sign
                @inbounds @simd for i in 1:n
                    Zk[i] = -Zk[i]
                end
            end
        end

        # Step 6: Extract the polynomials (exclude the first column)
        Z_out = @view Z[:, 2:end]
        return Z_out
    end
end

