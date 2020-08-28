#!/usr/bin/python
import os
import sys
f = open(sys.argv[1], 'r')
buf = f.read()
old = buf
torep = sys.argv[2]
repwith = sys.argv[3]
from random import randint
while torep in buf:
    buf = buf.replace(torep, repwith.replace("RANDOM", str(randint(0, 100000000))), 1)
if old != buf:
    f = open(sys.argv[1], 'w')
    f.write(buf)
    f.close()
