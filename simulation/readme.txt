I. How to obtain the figure 3 in "Oppotuities and Challenges for Data Center Demand Response"
- setting:
	+ 47 buses
	+ voltage constraint: 3%
	+ Data center: 15MW, 20% flexibility
	+ 
- RUNWithDC.m to simulate and obtain the results like Figure 3 (a)->(c)	

- Use function plotDCsimulation.m to plot each figure 3 (a)->(c)
	+ fracInBounds: Violation Frequency
	+ flexValues: 
	+ 
	
- RUNWithStorage.m to simulate and obtain the results for storages like Figure 3 (a)->(c)
- Use plotDCAllBuses.m to plot the figure 3 (d) with inputs
	+ dcFrac: Data center fraction (violation frequency)
	+ storageFrac: Storage Fraction (violation frequency)
	+ optimalStorageFrace: fraction of optimal location
	
II. How to obtain the figure 4 in "Oppotuities and Challenges for Data Center Demand Response"

- 