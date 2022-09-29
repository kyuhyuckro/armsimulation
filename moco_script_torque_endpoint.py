import opensim as osim
import sys
import os
import numpy as np
import helpers
import math
import random

def simulateMotion(type = 0, nbr_targets = 8, outPath = "SimResults/"):

    start_x =  0.29707
    start_y = -0.217857
    start_z = 0.272545
    points = 5
    tscalar = 60/points

    fileLoc = ""
    filename = outPath + "torque_solutions"+fileLoc
    isExist = os.path.exists(filename)
    if not isExist:
        os.makedirs(filename)

    filename = outPath + "path_solutions"+fileLoc
    isExist = os.path.exists(filename)
    if not isExist:
        os.makedirs(filename)

    for i in range(nbr_targets):
        model_filename = "MOBL_ARMS.osim"
        # model = helpers.getMuscleDrivenModel(model_filename)
        model = helpers.getTorqueDrivenModel(model_filename)
        hand_body = model.getBodySet().get("hand")
        marker = osim.Marker('marker', hand_body, osim.Vec3(0,0,0.0))
        model.addMarker(marker)

        study = osim.MocoStudy()
        problem = study.updProblem()
        problem.setModel(model)

        problem.setTimeBounds(0, tscalar * points/100) 

        problem.setStateInfo('/jointset/shoulder0/elv_angle/value', [-1.5, 2.0],.349066)
        problem.setStateInfo('/jointset/shoulder1/shoulder_elv/value', [0, 2.5],.436332)
        problem.setStateInfo('/jointset/shoulder2/shoulder_rot/value', [0, 0.5],.0)
        problem.setStateInfo('/jointset/elbow/elbow_flexion/value', [0., 3.1459],1.5708)
        problem.setStateInfo('/jointset/radioulnar/pro_sup/value', [-3.14159/2., 3.14159/2.], 1.57, 1.57)
        problem.setStateInfo('/jointset/radiocarpal/deviation/value', [-0.17453293, 0.43633231], 0, 0)
        problem.setStateInfo('/jointset/radiocarpal/flexion/value', [-1.2, 1.2], 0, 0)
        problem.setStateInfoPattern('/jointset/.*/speed', [-2, 2], 0, 0)

        endpointCost = osim.MocoMarkerFinalGoal("target", 20)  
        endpointCost.setPointName('/markerset/marker')

        r = 0.15;
        
        target = i;  
        theta = (target/nbr_targets) * 2 * math.pi;
        if type == 0:
            X = start_x + r * math.sin(theta)
            Y = start_y 
            Z = start_z +  r * math.cos(theta)
        if type == 1:
            X = start_x + r * math.sin(theta)
            Y = start_y + r * math.cos(theta)
            Z = start_z 

        # endpointCost.setReferenceLocation(osim.Vec3(0.304432 + r * math.sin(theta), -0.186052,0.207766 +  r * math.cos(theta)))
        endpointCost.setReferenceLocation(osim.Vec3(X, Y, Z))
        problem.addGoal(endpointCost)
        
        markerTrajectories = osim.TimeSeriesTableVec3()
        markerTrajectories.setColumnLabels(["/markerset/marker"])
        mya = 0
        for ix in range(points+1):
            if type == 0:
                X2 = start_x + mya * math.sin(theta)
                Y2 = start_y 
                Z2 = start_z + mya * math.cos(theta)
            if type == 1:
                X2 = start_x + mya * math.sin(theta)
                Y2 = start_y + mya * math.cos(theta)
                Z2 = start_z 
            
            m0 = osim.Vec3(X2,Y2,Z2)
            markerTrajectories.appendRow(tscalar * ix/100,
            osim.RowVectorVec3([m0]))
            num = random.uniform(-.01, .01)
            mya = mya + r/points + num
            print(mya)
            
        print(markerTrajectories)    
        # Assign a weight to each marker.
        markerWeights = osim.SetMarkerWeights()
        markerWeights.cloneAndAppend(osim.MarkerWeight("/markerset/marker", 20))
         
        ref = osim.MarkersReference(markerTrajectories, markerWeights)
        markerTracking = osim.MocoMarkerTrackingGoal()
        markerTracking.setMarkersReference(ref)
        problem.addGoal(markerTracking)           
        

        problem.addGoal(osim.MocoControlGoal('myeffort',2)) 

        solver = study.initCasADiSolver()
        solver.set_num_mesh_intervals(60)
        solver.set_optim_convergence_tolerance(1e-2)
        solver.set_optim_constraint_tolerance(1e-2)
        solver.set_optim_max_iterations(250)

        predictSolution = study.solve()
        solutionUnsealed = predictSolution.unseal()
        filename = outPath + "torque_solutions" + fileLoc + "/solution" + str(target) + '.sto'
        solutionUnsealed.write(filename)

        model.initSystem()
        states = predictSolution.exportToStatesTable()

        statesTraj = osim.StatesTrajectory.createFromStatesTable(model, states)

        filename = outPath + "path_solutions" + fileLoc + "/traj" + str(target) + '.sto'
        f = open(filename, "a")
        f.truncate(0)
        f.write("time, marker_x, marker_y, marker_z, handle_x, handle_y, handle_z, target_x, target_y, target_z, points\n")
            
        for state in statesTraj:
            model.realizePosition(state)
            m0 = model.getComponent('/markerset/marker')
            m1 = model.getComponent("markerset/Handle")
            f.write(str(state.getTime()))
            f.write(", ")
            s = str(m0.getLocationInGround(state))
            f.write(s[2:-1])
            f.write(", ")
            s = str(m1.getLocationInGround(state))
            f.write(s[2:-1])
            f.write(", ")
            s = str([X, Y, Z])
            f.write(s[1:-1])
            f.write(", ")
            f.write(str(points))
            f.write(",\n")

        f.close()
