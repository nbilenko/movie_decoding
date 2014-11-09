import numpy as np
import tables

def load_table_file(filename):
	'''Loads in the filedict from an hdf5 table file.
	'''
	tabledict = dict()
	with tables.open_file(filename, mode="r") as hf:
		nodelist = hf.root._f_list_nodes()
		for node in nodelist:
			key = node._v_name
			value = node.read()
			tabledict[key] = value
	return tabledict

def save_table_file(filename, filedict):
	"""Saves the variables in [filedict] in a hdf5 table file at [filename].
	"""
	with tables.open_file(filename, mode="w", title="save_file") as hf:
		for vname, var in filedict.items():
			hf.create_array("/", vname, var)


fname = "../matlabdata/movie_lcode037_cut05_100_128_%03d.mat"
numframes = 487

for i in range(116, numframes):
	f = load_table_file(fname % i)
	frame_data = np.transpose(f["s"], [0, 1, 4, 3, 2])
	save_table_file("../data/data%03d.hf5" % i, {"clip": frame_data[0], "guesses": frame_data[1:], "llh": f["llh"]})