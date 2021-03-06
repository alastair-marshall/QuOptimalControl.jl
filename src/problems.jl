abstract type Problem end
abstract type ClosedSystem <: Problem end
abstract type OpenSystem <: Problem end
abstract type Experiment <: Problem end

import Base.@kwdef # unsure about using this so much

"""
Description of the dynamics of a closed state transfer problem. This also applies method also applies to optimisation of Hermitian operators
"""
@kwdef struct StateTransferProblem{T} <: ClosedSystem
    B::Vector{T} # control terms
    A::T # drift terms
    X_init::T # initial state
    X_target::T # target operator or state
    duration::Float64 # duration of pulse
    n_timeslices::Int64 # slices
    n_controls::Int64 # number of pulses
    initial_guess::Matrix{Float64} # guess at controls
end

"""
Description of the dynamics of a unitary synthesis problem. Although this contains the same information as another closed state problem by defining it separately we can choose the evolution methods that make sense for the problem
"""
@kwdef struct UnitaryProblem <: ClosedSystem
    B # control terms
    A # drift terms
    X_init # initial state
    X_target # target operator or state
    duration # duration of pulse
    n_timeslices # slices
    n_controls # number of pulses
    initial_guess # guess at controls
end

"""
Define an ensemble of problems, can provide any method for computing the new drift or control Hamiltonians
"""
@kwdef struct ClosedEnsembleProblem{T}
    problem::T # for an ensemble of systems you'll provide one "template" problem
    n_ensemble::Int64 # we need to know the number of ensemble members
    A_generators # need to find a better name but these will give us some discretisation
    B_generators # similarly to above
    X_init_generators
    X_target_generators
    weights::Vector{Float64} # weights for calculating the figure of merit and gradient
end

"""
Working in Liouville space we can do an optimisation in the presence of relaxation, we can also reuse the gradient and goal functions from before. Assuming Hermitian operators on input, need to deal with non-Hermitian.

Following the Khaneja and Glaser paper provided we can use the same gradient and fom functions as in the relaxation free case but the evolution is now governed by the Liovuillian superoperator.
"""
@kwdef struct OpenSystemCoherenceTransfer <: OpenSystem
    B # control terms
    A # drift terms
    X_init # initial state
    X_target # target operator or state
    duration # duration of pulse
    n_timeslices # slices
    n_controls # number of pulses
    initial_guess # guess at controls
end

"""
Working with an experiment
"""
@kwdef struct ExperimentInterface <: Experiment
    duration
    timestep
    n_timeslices
    n_controls
    start_exp # function to start exp
    pulse_path
    infidelity_path
    timeout
end