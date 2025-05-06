#!/usr/bin/python
from scapy.all import *

import time, sys
pkts = rdpcap("D:\DTS\Code\pyDTS\pyDTS\ch10-replay\Analog Time Format 2 - DP20.pcapng")
clk = pkts[0].time
for p in pkts:
    time.sleep(int(p.time - clk))
    clk = p.time
    sendp(p, iface="DTS1")