"""
This is the pipeline for producing torque data and analyzing it.

The basic pipeline proceeds as follows:
    1. Data is generated by moco_script_torque_endpoint.py
        This returns two folders with several torques and paths.
    2. Data is passed into and organized by organizeCSV.py
        This returns a csv with merged torque and kinematic data.
    3. The csv is passed into makeDataFromCSV.py   
        This returns the activity of the neural network.
    4. Take this end result over to MATLAB.
"""

import moco_script_torque_endpoint as sim
import organizeCSV as OC
import makeDataFromCSV as makeCSV
from string import ascii_lowercase


outPath = 'SimResultsOct5_2/' 
metaDataStr = 'meta_data.json'
locStr = 'merged_data.csv'
type = 0
simSteps = 250

sim.simulateMotion(type = type, nbr_targets = 8, nbr_trials = 5, outPath = outPath, simSteps = simSteps, metaPath = outPath + metaDataStr)

OC.organize(outPath + "torque_solutions",outPath + "path_solutions", csvName= outPath + locStr, type = type)

trials = 10
nlayers = 56
stepsz = 10
for i in range(5,nlayers,stepsz):
    print("starting layer " + str(i+1) + " of " + str(nlayers) + "...")    
    for j in range(trials):
        print("--> starting trial " + str(j+1) + " of " + str(trials)+ "...")     
        numLayers = i
        outStr = outPath + str(numLayers) + 'layerOutput' + ascii_lowercase[j]
        makeCSV.trainFromCSV(outPath+locStr,outStr,numLayers)

