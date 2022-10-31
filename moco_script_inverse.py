import opensim as osim
import sys
import os
import numpy as np
import helpers

for target in range(8):
    model_filename = "MOBL_ARMS.osim"
    dirName = 'SimResults/'
    filename = dirName + 'torque_solutions/solution' + str(target) + '.sto'
    tableProcessor = osim.TableProcessor(filename)
    inverse = osim.MocoInverse()

    modelProcessor = osim.ModelProcessor(model_filename)
    modelProcessor.append(osim.ModOpIgnoreTendonCompliance())
    modelProcessor.append(osim.ModOpReplaceMusclesWithDeGrooteFregly2016())
    modelProcessor.append(osim.ModOpIgnorePassiveFiberForcesDGF())

    modelProcessor.append(osim.ModOpAddReserves(1.0))
    inverse.setModel(modelProcessor)

    inverse.setKinematics(tableProcessor)

    inverse.set_initial_time(0)
    inverse.set_final_time(0.05)
    inverse.set_mesh_interval(0.001)

    inverse.set_kinematics_allow_extra_columns(True)
    inverse.set_minimize_sum_squared_activations(True)

    inverseSolution = inverse.solve()
    solution = inverseSolution.getMocoSolution()
    inverseSolutionUnsealed = solution.unseal()
    inverse_filename = dirName + 'muscle_solutions/inverseSolution_' + str(target) + '.sto'
    inverseSolutionUnsealed.write(inverse_filename)

    inverseOutputs = inverseSolution.getOutputs()
    sto = osim.STOFileAdapter()
    sto.write(inverseOutputs, dirName + 'muscleOutputs' + str(target) + '.sto')
