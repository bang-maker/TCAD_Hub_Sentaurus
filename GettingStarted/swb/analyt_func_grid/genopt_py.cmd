# Define optimization parameters. Names must be Sentaurus Workbench parameters.
x = TOptParam('x', 0, -4, 4)
y = TOptParam('y', 0, -4, 4)
params = [x, y]

optimizer.set_from_swb(params)

# Define optimization targets
t1 = OptTarget("error", value=0, scale=1)
targets = [t1]

# Define constraints (x-y<0)
c1 = OptConstraint("constr", lt=0)
constraints = [c1]

# Parameter search - Grid
opt_params = optimizer.search(params, targets + constraints,
	method="grid", options={"Ns": 5}
)

# Local minimization
optimizer.backend.set_method("minimize")
optimizer.backend.set_optimization_parameters(jacobian_options={"eps": 1e-3},
                                              method="SLSQP",
                                              options={"maxiter": 10})
opt_params = optimizer.optimize(params, targets + constraints)
