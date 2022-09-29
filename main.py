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

outPath = "SimResults/" 

locStr = 'merged_data.csv'

#sim.simulateMotion(type = 1, nbr_targets = 8, outPath = outPath)

OC.organize(outPath + "torque_solutions",outPath + "path_solutions", csvName= outPath + locStr)

for i in range(3,101,1):
    numLayers = i
    outStr = outPath + str(numLayers) + 'layerOutput' 
    makeCSV.trainFromCSV(locStr,outStr,numLayers)