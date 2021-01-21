using LinearAlgebra
using StaticArrays
"""
Contains code to perform time evolution
"""

"""
Given a set of Hamiltonians (drift and control) compute the evolution
"""
function pw_evolve(H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64}, n_pulses, timestep, timeslices, U0::T)::T where T
    K = n_pulses
    U = U0
    for i = 1:timeslices
        # compute the propagator
        Htot = H₀
        for j = 1:K
            @views Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        @views U = exp(-1.0im * timestep * Htot) * U
    end
    U
end

"""
Given a set of Hamiltonians (drift and control) compute the evolution, Zygote compatible
lets dispatch to this properly sometime
"""
function pw_evolve_T(H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64}, n_pulses, timestep, timeslices, U0::T)::T where T
    x_arr = complex.(real.(x_arr)) # needed for Zygote to use complex numbers internally
    D = size(H₀)[1] # get dimension of the system
    K = n_pulses
    # U0 = T(I(D))
    for i = 1:timeslices
        # compute the propagator
        Htot = H₀
        for j = 1:k
            @views Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        U0 = exp(-1.0im * timestep * Htot) * U0
    end
    U0
end

"""
Given a set of Hamiltonians compute the piecewise evolution saving the propagator for each time slice
"""
function pw_evolve_save(H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64}, n_pulses, timestep, timeslices) where T
    D = size(H₀)[1] # get dimension of the system
    K = n_pulses
    out = T[]
    U0 = T(I(D))
    for i = 1:timeslices
    # compute the propagator
        Htot = H₀
        for j = 1:K
            @views Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        @views U0 = exp(-1.0im * timestep * Htot)# * U0
        append!(out, [U0])
    end
    out
end



"""
Function to compute the Hamiltonians for a piecewise constant control and save them. Low allocations when used with StaticArrays!
"""
function pw_ham_save(H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64}, n_pulses, timeslices) where T
    D = size(H₀)[1] # get dimension of the system
    out = Vector{T}(undef, timeslices)
    for i = 1:timeslices
        Htot = H₀
        for j = 1:n_pulses
            @views Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        out[i] = Htot
    end
    out
end

"""
An almost allocation free (1 alloc in my tests) version of the Hamiltonian saver, since the update is inplace we have to be careful with the definition of out!
"""
function pw_ham_save!(H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64,2}, n_pulses, timeslices, out) where T
    K = n_pulses
    Htot = similar(H₀)

    @views @inbounds for i = 1:timeslices
        @. Htot = 0.0 * Htot
        @inbounds for j = 1:K
            @. Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        @. out[i] = Htot + H₀
    end
end

"""
An almost allocation free (1 alloc in my tests) version of the Generator saving function, this saves the generators of propagators (implementation might differ for prob)
"""
function pw_gen_save!(prob::Union{StateTransferProblem,UnitaryProblem}, H₀::T, Hₓ_array::Array{T,1}, x_arr::Array{Float64,2}, n_pulses, timeslices, duration, out) where T
    K = n_pulses
    Htot = similar(H₀)
    dt = duration/timeslices

    @views @inbounds for i = 1:timeslices
        @. Htot = 0.0 * Htot
        @inbounds for j = 1:K
            @. Htot = Htot + Hₓ_array[j] * x_arr[j, i]
        end
        @. out[i] = (Htot + H₀) .* (-1.0im * dt)
    end
end



