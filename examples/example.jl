# # Simple QP Example


#Required packages
using LinearAlgebra, SparseArrays
using Clarabel

#-------------
#Problem data in sparse format
A = SparseMatrixCSC(I(3)*1.)
P = SparseMatrixCSC(I(3)*1.)
A = [A;-A]
c = [3.;-2.;1.]*10
b = ones(Float64,2*3);


# ----------------------------
# ### Solve in Clarabel native interface

cone_types = [Clarabel.NonnegativeConeT]
cone_dims  = [length(b)]

settings = Clarabel.Settings(
        max_iter=20,
        verbose=false,
        direct_kkt_solver=true,
        equilibrate_enable = true
)
solver = Clarabel.Solver()
Clarabel.setup!(solver,P,c,A,b,cone_types,cone_dims,settings)
Clarabel.solve!(solver)
x = solver.variables.x

# -------------
# ### Solve in JuMP

using JuMP
model = Model(Clarabel.Optimizer)
@variable(model, x[1:3])
@constraint(model, c1, A*x .<= b)
@objective(model, Min, sum(c.*x) + 1/2*x'*P*x)

#Run the opimization
optimize!(model)
x = JuMP.value.(x)
