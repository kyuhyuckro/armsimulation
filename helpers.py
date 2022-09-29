import opensim as osim
import numpy as np
import matplotlib.pyplot as plt

def getMuscleDrivenModel(model_filename):

    # Load the base model.
    model = osim.Model(model_filename)
    model.finalizeConnections()

    # Replace the muscles in the model with muscles from DeGroote, Fregly,
    # et al. 2016, "Evaluation of Direct Collocation Optimal Control Problem
    # Formulations for Solving the Muscle Redundancy Problem". These muscles
    # have the same properties as the original muscles but their characteristic
    # curves are optimized for direct collocation (i.e. no discontinuities,
    # twice differentiable, etc).
    osim.DeGrooteFregly2016Muscle().replaceMuscles(model)

    # Make problems easier to solve by strengthening the model and widening the
    # active force-length curve.
    for m in np.arange(model.getMuscles().getSize()):
        musc = model.updMuscles().get(int(m))
        musc.setMinControl(0.0)
        musc.set_ignore_activation_dynamics(False)
        musc.set_ignore_tendon_compliance(False)
        musc.set_max_isometric_force(musc.get_max_isometric_force())
        dgf = osim.DeGrooteFregly2016Muscle.safeDownCast(musc)
        dgf.set_active_force_width_scale(1.5)
        dgf.set_tendon_compliance_dynamics_mode('implicit')
        #if str(musc.getName()) == 'soleus_r':
            # Soleus has a very long tendon, so modeling its tendon as rigid
            # causes the fiber to be unrealistically long and generate
            # excessive passive fiber force.
        #    dgf.set_ignore_passive_fiber_force(True)

    return model


def addCoordinateActuator(model, coordName, optForce):
    coordSet = model.updCoordinateSet()
    actu = osim.CoordinateActuator()
    actu.setName('tau_' + coordName)
    actu.setCoordinate(coordSet.get(coordName))
    actu.setOptimalForce(optForce)
    actu.setMinControl(-1)
    actu.setMaxControl(1)
    model.addComponent(actu)

def getTorqueDrivenModel(model_filename):
    # Load the base model.
    model = osim.Model(model_filename)

    # Remove the muscles in the model.
    model.updForceSet().clearAndDestroy()
    model.initSystem()

    # Add CoordinateActuators to the model degrees-of-freedom.
    addCoordinateActuator(model, 'elv_angle', 200)
    addCoordinateActuator(model, 'shoulder_elv', 200)
    addCoordinateActuator(model, 'shoulder_rot', 200)
    addCoordinateActuator(model, 'elbow_flexion', 200)
    addCoordinateActuator(model, 'pro_sup', 100)
    addCoordinateActuator(model, 'deviation', 100)
    addCoordinateActuator(model, 'flexion', 100)
    
    return model


