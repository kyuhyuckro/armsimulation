import numpy as np
import pandas as pd
from keras.models import Sequential
from keras.models import load_model
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from keras import backend as K
from tensorflow.keras import layers
import scipy.io
import os

def trainFromCSV(csvName,outputFolder,layers_num):

    # Check for existance of output folder, if no folder, make it.
    isExist = os.path.exists(outputFolder)
    if not os.path.exists(outputFolder):
        os.makedirs(outputFolder)
        
    merged_data=pd.read_csv(csvName)
    X=merged_data.iloc[:,1:13]
    y=merged_data.iloc[:,13:]

    all_times = X.iloc[:,0]

    # This should probably be removed:==================
    # seed = 7
    # np.random.seed(seed)
    # ==================================================

    # Make layers:
    #layers_num = int(input("enter number of network layers: "))
    #folder_name = str(layers_num) + 'layers'
    model = Sequential()
    model.add(layers.Embedding(input_dim=12, output_dim=12))

    # The output of GRU will be a 3D tensor of shape (batch_size, timesteps, 256)
    model.add(layers.GRU(256, return_sequences=True))

    # The output of SimpleRNN will be a 2D tensor of shape (batch_size, 128)
    model.add(layers.SimpleRNN(128))
    model.add(layers.Dense(10))
    model.add(layers.Dense(5))

    model.compile(loss='mean_squared_error', optimizer='adam', metrics='accuracy')

    
    x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    model.fit(x_train, y_train, epochs=10)
    
    mean_squared_error, accuracy = model.evaluate(x_test, y_test)
    print('Accuracy: %.2f' % (accuracy*100) + "%...")
    print('MSE: %.20f' % (mean_squared_error) + "...")
    
    model.summary()
    num_layers = len(model.layers)
    num_neurons = 0
    for layer_index in range(num_layers):
        layer = model.layers[layer_index]
        for i in range(1, len(layer.output.shape)):
            num_neurons_in_layer = 1
            num_neurons_in_layer *= int(layer.output.shape[i])
            num_neurons += num_neurons_in_layer

    cond = 0
    C = np.empty((0,num_neurons), int)
    time = np.empty((0,1), int)
    #print(X.shape[0])
    print("Compiling results...")
    for i in range (0,X.shape[0]-1):

        x = X.iloc[i,:]
        x = np.array(x)
        x.shape = (1,X.shape[1])

        ctime = np.array(all_times[i])
        ctime.shape = (1,1)
        time = np.concatenate([time, ctime])

        b = np.array([])
        for j in range(len(model.layers)):
            get_layer_output_0 = K.function([model.layers[0].input], [model.layers[j].output])
            layer_output_0 = get_layer_output_0([x])[0]
            a = layer_output_0.flatten()
            b = np.concatenate([b, a])

        C = np.vstack((C, b))
        #print (C.shape)

        target1 = X.iloc[i,10:13]
        #print(X.iloc[i,10:12])
        target2 = X.iloc[i+1,10:13]
        if np.linalg.norm(target1 - target2) > 1e-6:
            #print (i)
            #print (target1)
            #print (target2)
            scipy.io.savemat(outputFolder + '/data1100' + str(cond) + '.mat', mdict={'C': C, 'time':time, 'target':target1, 'accuracy' : accuracy, "MSE": mean_squared_error})
            C = np.empty((0,num_neurons), int)
            time = np.empty((0,1), int)
            cond = cond + 1
            print("Compiled " + str(i) + " of " + str(X.shape[0]-1) + "...")
    print("Compiling done!")