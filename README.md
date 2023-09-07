# Welcome!
This repository stores all of the code used in Briggs et al., "Personalizing the Pressure Reactivity Index for Neurocritical Care Decision Support"

# Calculation Functions:
### PRxcalc.m
This is the main function used for calculating PRx over many hyperparameters.
### trackTBI_PRx.m
This is the function used for cleaning and then calculating PRx from patient data
### findheartbeat.m
This is the function to identify heartbeats.
### PRxcalc_byHR.m
Calculate PRx by heartbeat rater than seconds
### PRxcalc.m
Calculate PRx using seconds method.
### runSimulatedPRx.m
Code used to create and calculate PRx for simulated data.


# Upstream Run files
### runtrackTBI_PRx.m
This is the script for running and saving PRx for all patient files


# Plotting/Analysis Files (located under plottingfunctions/


### plottime.m
Script used for Figure 3a,b and Figure 5.

### plot2D.m
Script used for Fig 3c top pannel

### plotcontinuous.m
Script used for Fig 3c blottom left and right pannels.

### plotPRxanalysis.m
Scatter plot for figure 3c middle pannel

### syntheticanalysisHR.m
Script for comparing PRx from HR method and PRx from seconds method in synthetic data. Figure 4 and 6.


### HRvsSeconds.m
Plots Figure 6c.

### PlotPRxanalysis_HR.m
Script used for Figure 6d and e.

### ploticm.m
Plots for Supplementary figure 1.


