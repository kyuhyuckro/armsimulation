import numpy as np
import pandas as pd
from keras.models import Sequential
from keras.models import load_model
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
from sklearn.model_selection import train_test_split
#from sklearn.model_selection import cross_val_score
#from sklearn import cross_validation
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
#from shuffle import shuffle_in_unison
from keras import backend as K
import scipy.io

#code used for looking at building and comparing different layers of neural network 
merged_data=pd.read_csv('merged_data.csv')
X=merged_data.iloc[:,1:13]
y=merged_data.iloc[:,13:]

all_times = X.iloc[:,0]

#X0 = X.iloc[:,11:12] # 11, 12, positions
#X = X.iloc[:,1:13]

#X = np.concatenate((X,X0), axis=1)
seed = 7
np.random.seed(seed)

model = Sequential()
model.add(Dense(256, input_dim=12, kernel_initializer='normal', activation='relu'))
model.add(Dense(128, kernel_initializer='normal', activation='relu'))
model.add(Dense(10, kernel_initializer='normal', activation='relu'))
model.add(Dense(5, kernel_initializer='normal'))
model.compile(loss='mean_squared_error', optimizer='adam')

x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
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
print(X.shape[0])
for i in range (0,X.shape[0]-1):

    x = X.iloc[i,:]
    x = np.array(x)
    x.shape = (1,12)

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
    print (C.shape)

    target1 = X.iloc[i,10:12]
    print(X.iloc[i,10:12])
    target2 = X.iloc[i+1,10:12]
    if np.linalg.norm(target1 - target2) > 1e-6:
        print (i)
        print (target1)
        print (target2)
        scipy.io.savemat('data1100' + str(cond) + '.mat', mdict={'C': C, 'time':time, 'target':target1})
        C = np.empty((0,num_neurons), int)
        time = np.empty((0,1), int)
        cond = cond + 1

# cosine tuning , jpca, extending model to muscles