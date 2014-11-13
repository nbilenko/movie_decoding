#!/usr/bin/python
import numpy as np
from utils import *

datapath = "../data/data%03d.hf5"
clipnums = range(1, 11)


def find_best_path(datapath, metric, clipnums):
	data = load_table_file(datapath % clipnums[0])
	old_clip = data["clip"]
	old_guesses = data["guesses"]
	path = [old_guesses[0]]

	for guessnum, clipnum in enumerate(clipnums[1:]):
		guessnum += 1
		data = load_table_file(datapath % clipnum)
		clip = data["clip"]
		guesses = data["guesses"]
		target_metric = compute_metric(old_clip, clip, metric)
		guess_metrics = []
		for guess in guesses:
			guess_metrics.append(compute_metric(path[guessnum-1], guess, metric))

		scores = match_metrics(guess_metrics, target_metric)
		path.append(guesses[np.argmax(scores)])
	return np.array(path)

def compute_metric(clip0, clip1, metric = "sift"):
	if metric == "sift":
		# compute sift match between clip0 and clip1
		match = np.zeros(clip0.shape)
	return match

def match_metrics(choices, target):
	# Compute how well each choice matches the target
	scores = np.zeros((len(choices),))
	return scores