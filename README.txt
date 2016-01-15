# DCDR_adv
Init DCDR evaluation project

plotDCsimulation.m -- plot avg of data center flexibility(KW) with voilation frequency

under Iris_Codes2PV
plotDCAllBuses.m --- plot fig 3d

RUNWithStorage.m --- plot non-violation fraction for each location of storage bus
nonvoilationfraction.m --- violationFraction = (out_bounds) / (tsteps*numBuses)

nvfcvx56.m --- case study 1; calculate power flow for t and fraction of t each bus spends out of tolerance.

for testnvfcase47_0812.m,testnvfcase47.m,testnvfcvx56.m
    they are similar, plot capacities vs. bus in bounds, vs. violation_log
