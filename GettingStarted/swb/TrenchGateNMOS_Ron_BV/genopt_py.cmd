# Define optimization parameters. Names must be Sentaurus Workbench parameters.
a = TOptParam('nepi1D', 1.0e16, 1.0e15, 2.0e16, Log10)
b = TOptParam('pwellD', 1.0e13, 1.0e12, 1.0e14, Log10)
params = [a, b]
optimizer.set_from_swb(params)


# Define optimization targets
t1 = OptTarget("Ron")
targets = [t1]

# Define optimization constraints
c1 = OptConstraint("BV", gt=80.0)
constraints = [c1]

## Parameter Search
opt_params = optimizer.search(params, targets + constraints,
	method="sobol",
    options={ "Ns": 20 }
)

## Local minimization
optimizer.backend.set_method("minimize")
optimizer.backend.set_optimization_parameters(
	jacobian_options={"eps": 1.e-2},
    method="SLSQP",
    options={"ftol": 1e-4, "maxiter": 10}
)

opt_params = optimizer.optimize(params, targets + constraints)
