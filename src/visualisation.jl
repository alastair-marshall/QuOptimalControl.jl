"""
Visualisation methods, Bloch sphere plotting + other things
"""

using LinearAlgebra
using Plots

theme(:juno)

"""
Visualise the expectation value of op under the evoltuion of the ctrl_arr, at the moment we will ask for both the problem and the solution. 
"""
function visualise_expt_val(H_drift, H_ctrl, ctrl_arr, duration, n_timeslices, X_init::T, op; label = "") where T
    # dealing with the evolution of the system is a bit of a problem 
    n_pulses = length(H_ctrl)
    timestep = duration / n_timeslices
    P_list = pw_evolve_save(H_drift, H_ctrl, ctrl_arr, n_pulses, timestep, n_timeslices)

    states = similar(P_list)
    states[1] = X_init
    for i = 2:n_timeslices
        states[i] = P_list[i - 1] * states[i - 1]
    end

    exp_op = [real(tr(op * i)) for i in states]
    time = 0:timestep:duration - timestep

    lab = label 

    plot(time, exp_op, label = lab, xlabel = "Time", ylabel = "Expt. value")
    
end

"""
Visualise the expectation value of an array of ops under the evoltuion of the ctrl_arr, at the moment we will ask for both the problem and the solution. 
"""
function visualise_expt_val(H_drift::K, H_ctrl, ctrl_arr, duration, n_timeslices, X_init::T, ops::Array{K,1}, labels) where {T,K}
    N = length(ops)
    p = []
    for i = 1:N
        append!(p, [visualise_pulse(H_drift, H_ctrl, ctrl_arr, duration, n_timeslices, X_init, ops[i], label = labels[i])])
    end

    if sqrt(N) - floor(sqrt(N)) == 0
        layout = (Int(sqrt(N)), Int(sqrt(N)))
    else
        layout = (N, 1)
    end

    plot(p..., layout = layout)
end
