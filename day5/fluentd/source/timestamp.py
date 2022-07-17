#!/usr/bin/env python
import sys
timestamp=1658041094
jump=600
for line in sys.stdin:
    timestamp+=jump
    print("%s\t%s" % (timestamp, line.strip()))
