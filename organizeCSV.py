# organizeCSV.py
import os

tor_idx = [0, 12, 13, 15, 16, 17, 32, 33, 35, 36, 37]
tau_idx = [42, 43, 44, 45, 46];
k_ix = [8, 9]

def organize(torquePath, kinPath, csvName = "merged_data_.csv", type = 0):

    if type == 1:
        k_ix = [8, 10]
 
    # Get the list of all files and directories
    t_dir_list = os.listdir(torquePath)
    k_dir_list = os.listdir(kinPath)
    
    fOut = open(csvName, 'w')
    
    for i in range(len(t_dir_list)):
    
        t_file_in = open(torquePath + "/" + t_dir_list[i], 'r')
        k_file_in = open(kinPath + "/" + k_dir_list[i], 'r')
        
        t_next_line = t_file_in.readline()
        while not 'endheader' in t_next_line:
            t_next_line = t_file_in.readline()
        t_next_line = t_file_in.readline()
        
        t_labels = t_next_line.split()

        k_next_line = k_file_in.readline()
        k_labels = k_next_line.split(",")
        
        T = [t_labels[i] for i in tor_idx];
        T2 = [t_labels[i] for i in tau_idx];
        K = [k_labels[i] for i in k_ix];
        if i == 0:
            writeS = ",".join(str(s) for s in [T + K + T2])
            print(writeS)
            writeS.replace("\'", "")
            print(writeS)
            
            fOut.write(writeS[1:-1])
            #fOut.write(",".join(str([T + K + T2])))
            fOut.write("\n")
        
        t_next_line = t_file_in.readline()
        k_next_line = k_file_in.readline()
        while len(t_next_line):
            t_data = t_next_line.split()
            k_data = k_next_line.split(",")
            
            T = [t_data[i] for i in tor_idx];
            T2 = [t_data[i] for i in tau_idx];
            K = [k_data[i] for i in k_ix];
            
            writeS = ",".join(str(s) for s in [T + K + T2])
            writeS.replace("\'", "")
            fOut.write(writeS[1:-1])
            fOut.write("\n")
            
            t_next_line = t_file_in.readline()
            k_next_line = k_file_in.readline()
        
    fOut.close()