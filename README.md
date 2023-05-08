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
### syntheticanalysisHR.m
Script for comparing PRx from HR method and PRx from seconds method in synthetic data

### HRvsSeconds.m
Plots Figure 6c.

