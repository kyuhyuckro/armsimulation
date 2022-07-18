import numpy as np
import pandas as pd
from keras.models import Sequential
from keras.models import load_model
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasRegressor
#from sklearn.model_selection import cross_val_score
#from sklearn import cross_validation
from sklearn.model_selection import KFold
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
#from shuffle import shuffle_in_unison
from keras import backend as K
import scipy.io

merged_data=pd.read_csv('merged_data.csv')
X=merged_data.iloc[:,1:13]
y=merged_data.iloc[:,13:]

all_times = X[:,108]

X0 = X[:,109:]
X = X[:,0:14]

X = np.concatenate((X,X0), axis=1)

seed = 7
np.random.seed(seed)


model = load_model('ffnn.ipynb')

num_layers = len(model.layers)
num_neurons = 0
for layer_index in range(num_layers):
	layer = model.layers[layer_index]
	for i in range(1, len(layer.output.shape)):
		num_neurons_in_layer = 1
		num_neurons_in_layer *= int(layer.output.shape[i])
		num_neurons += num_neurons_in_layer

cond = 0

for i in range (0,X.shape[0]-1):

	x = X[i,:]
	x.shape = (1,17)

	ctime = np.array(all_times[i])
	ctime.shape = (1,1)
	time = np.concatenate([time, ctime])

	get_layer_output_0 = K.function([model.layers[0].input], [model.layers[0].output])
	layer_output_0 = get_layer_output_0([x])[0]

	get_layer_output_1 = K.function([model.layers[0].input], [model.layers[1].output])
	layer_output_1 = get_layer_output_1([x])[0]

	a0 = layer_output_0.flatten()
	a1 = layer_output_1.flatten()
	b = np.concatenate([a0, a1])

	print (b.shape)
	print (C.shape)

	C = np.vstack((C, b))
	print (C.shape)
     
	target1 = X[i,14:18]
	target2 = X[i+1,14:18]
	if np.linalg.norm(target1 - target2) > 1e-3:
		print (i)
		print (target1)
		print (target2)
		scipy.io.savemat('nn_47_data/data1100' + str(cond) + '.mat', mdict={'C': C, 'time':time, 'target':target1})
		C = np.empty((0,num_neurons), int)
		time = np.empty((0,1), int)
		cond = cond + 1

