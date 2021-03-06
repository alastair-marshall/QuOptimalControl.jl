
# tests for problems and ensemble problem types

@testset "StateTransfer in place w/ GRAPE" begin

prob = StateTransferProblem(
    B = [Sx, Sy],
    A = Sz,
    X_init = ρinit,
    X_target = ρfin,
    duration = 1.0,
    n_timeslices = 10,
    n_controls = 2,
    initial_guess = rand(2, 10)
)

sol = GRAPE(prob)
@test sol.result[1].minimum - C1(ρfin, ρfin) < tol

end


@testset "StateTransfer GRAPE" begin

prob = StateTransferProblem(
    B = [SSx, SSy],
    A = SSz,
    X_init = ρinitS,
    X_target = ρfinS,
    duration = 1.0,
    n_timeslices = 10,
    n_controls = 2,
    initial_guess = rand(2, 10)
)

sol = GRAPE(prob, inplace=false)
@test sol.result[1].minimum - C1(ρfin, ρfin) < tol

end



@testset "StateTransfer Ensemble inplace" begin

prob = StateTransferProblem(
    B = [Sx, Sy],
    A = Sz,
    X_init = ρinit,
    X_target = ρfin,
    duration = 5.0,
    n_timeslices = 25,
    n_controls = 2,
    initial_guess = rand(2, 25)
)


ens = ClosedEnsembleProblem(prob, 5, A_gens, B_gens, X_init_gens, X_target_gens, ones(5)/5)

sol = GRAPE(ens, inplace=true)
@test sol.result[1].minimum - C1(ρfin, ρfin) < tol * 10

end



@testset "StateTransfer Ensemble out of place" begin
    prob = StateTransferProblem(
        B = [SSx, SSy],
        A = SSz,
        X_init = ρinitS,
        X_target = ρfinS,
        duration = 5.0,
        n_timeslices = 25,
        n_controls = 2,
        initial_guess = rand(2, 25)
    )


    ens = ClosedEnsembleProblem(prob, 5, A_gens_static, B_gens_static, X_init_gens_static, X_target_gens_static, ones(5)/5)

    sol = GRAPE(ens, inplace=false)
    @test sol.result[1].minimum - C1(ρfin, ρfin) < tol * 10

end
