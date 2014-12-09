#!/usr/bin/python
from utils import *
import matplotlib.pyplot as plt

datapath = "./data/data%03d.hf5"

for block in range(10):
	if block == 9:
		clipnums = range(block*50+1, 487)
	else:
		clipnums = range(block*50+1, (block+1)*50+1)
	weighted_means = []
	means = []
	clips = []

	for clipnum in clipnums:
		data = load_table_file(datapath % clipnum)
		weighted_means.append(np.average(data["guesses"][:100], 0, rescale(data["llh"].squeeze()[:100][0]/data["llh"].squeeze()[:100])))
		means.append(data["guesses"][:100].mean(0))
		clips.append(data["clip"])
		del data

	save_table_file("./data/weighted_means%d.hf5" % block, {"clips": np.array(clips), "guess": np.array(means), "weighted_guess": np.array(weighted_means)})

