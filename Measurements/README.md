# ThesisMeasurements

This repo contains all the measurement and analysis collected with PowerTutor and LabVIEW. The data are organized as follows:

    ALGORITHM_SIZE-REP_CORE-FREQ

Where

*   `ALGORITHM`: the sorting algorithm used.
*   `SIZE`: the size of the array to be sorted.
*   `REP`: the number of times the array must be sorted
*   `CORE`: the number of active cores on the CPU
*   `FREQ`: operating frequency for the cores. `AUTO` means that the governor used is `ondemand`, so the frequency is automatically scaled.

## Script_daq.R
An R script used to analyze the power trace obtained from LabVIEW. Usage:

    ./script_daq.R FOLDER_NAME
Where `FOLDER_NAME` is the location where are stored the data.

## Script_pt.R
An R script used to analyze the power trace obtained from PowerTutor. Usage:

    ./script_pt.R FOLDER_NAME
Where `FOLDER_NAME` is the location where are stored the data.

## Gen_pdf.sh
A shell script that launch the R script on all the folder if no parameters are specified. Otherwise launch the scripts only on the specified folder. Usage:

    ./gen_pdf.sh [FOLDER_NAME]
