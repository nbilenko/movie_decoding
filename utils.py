import tables
import numpy as np

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

def rescale(im, new_min = 0., new_max = 1.):
    return (im-im.min())*(new_max-new_min)/(im.max() - im.min()) + new_min