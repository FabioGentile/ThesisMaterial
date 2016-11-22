#!/usr/bin/env python3
import argparse
import pickle
import os.path
import coloredlogs
from utility import *

from uiddetail import get_uid_detail

iterations_list = []


class Entry:
    all_energy = 0
    app_energy = 0


def print_list(list_or_iterator):
    for i, e in enumerate(list_or_iterator):
        print(str(i) + " - " + str(e.all_energy) + " " + str(e.app_energy))


print("Read ALL file")
with open("out_all.csv", 'r') as f:
        for line in f:
            line = line.rstrip("\n")
            token = line.split(',')  # '+' is the separator used in power tutor

            if token[0].isdigit():
                iteration = int(token[0])

                entry = Entry()
                entry.all_energy = int(token[2])

                iterations_list.insert(iteration, entry)
                pass


print("Read APP file")
with open("out_app.csv", 'r') as f:
    for line in f:
        line = line.rstrip("\n")
        token = line.split(',')  # '+' is the separator used in power tutor

        if token[0].isdigit():
            iteration = int(token[0])

            entry = iterations_list[iteration]
            entry.app_energy = int(token[2])
            pass

with open("out.csv", 'w') as f:
    for i, e in enumerate(iterations_list):
        f.write(str(i) + "," + str(e.all_energy) + "," + str(e.app_energy) + "\n")
