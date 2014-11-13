#!/usr/bin/python
from utils import *
import matplotlib.pyplot as plt

datapath = "../data/data%03d.hf5"
clipnums = range(1, 487)
weighted_means = []
clips = []

for clipnum in clipnums:
	data = load_table_file(datapath % clipnum)
	llh = data["llh"].squeeze()[:100]; clip = data["clip"]; guesses = data["guesses"]
	weights = rescale(llh[0]/llh)
	weighted_means.append(np.average(guesses, 0, weights))
	clips.append(clip)

save_table_file("../data/weighted_means.hf5", {"clips": np.array(clips), "guesses": np.array(weighted_means)})

