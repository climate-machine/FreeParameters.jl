"""
    update_free_parameters!(fp, val)

Update free parameters vector `fp` with value `val`
"""
function update_free_parameters!(fp, val)
  for i in eachindex(fp)
    fp[i].val = typeof(fp[i].val)(val)
  end
  return nothing
end

@testset "Update free parameters in Params" begin
  # Define parametric model
  pmodel = Model.m

  # Define a generic model in Params and get an instance
  gmodel = generic_type(Params, pmodel)

  # Test the generic model matches the parametric model
  @test gmodel.x   ≈  pmodel.x
  @test gmodel.a.x ≈  pmodel.a.x
  @test gmodel.a.i == pmodel.a.i

  # Annotate which parameters are `FreeParameter`'s
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  # Extract pointers to `FreeParameter`'s
  fp = extract_free_parameters(gmodel)

  # Test free parameters match their annotated values
  @test fp[1].prior == Distributions.Normal
  @test fp[1].val ≈ 3.0
  @test fp[2].val ≈ 1.0
  @test fp[3].val == 2

  # Update free parameters (in UQ)
  new_params_val = 10.0
  update_free_parameters!(fp, new_params_val)

  # Get parametric version of updated generic model
  pmodel_new = parametric_type(Model, pmodel, gmodel)

  # Test model is updated
  @test pmodel_new.x   ≈  new_params_val
  @test pmodel_new.a.x ≈  new_params_val
  @test pmodel_new.a.i == new_params_val
end

@testset "Update free parameters in Main" begin
  # Define parametric model
  pmodel = Model.m

  # Define a generic model in Main and get an instance
  gmodel = generic_type(Main, pmodel)

  # Test the generic model matches the parametric model
  @test gmodel.x   ≈  pmodel.x
  @test gmodel.a.x ≈  pmodel.a.x
  @test gmodel.a.i == pmodel.a.i

  # Annotate which parameters are `FreeParameter`'s
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  # Extract pointers to `FreeParameter`'s
  fp = extract_free_parameters(gmodel)

  # Test free parameters match their annotated values
  @test fp[1].prior == Distributions.Normal
  @test fp[1].val ≈ 3.0
  @test fp[2].val ≈ 1.0
  @test fp[3].val == 2

  # Update free parameters (in UQ)
  new_params_val = 10.0
  update_free_parameters!(fp, new_params_val)

  # Get parametric version of updated generic model
  pmodel_new = parametric_type(Model, pmodel, gmodel)

  # Test model is updated
  @test pmodel_new.x   ≈  new_params_val
  @test pmodel_new.a.x ≈  new_params_val
  @test pmodel_new.a.i == new_params_val
end

