# SensorEnabledAthleticShoe

*** PROJECT SUMMARY ***

For this project, myself, two other Biomedical Engineering students, and two Computer Engineering students designed and prototyped a sensor-enabled athletic shoe and associated iOS app in order to process 9-axis IMU and enviromental sensor data into a managable lifestyle fitness score. The sensor was integrated into the sole of the shoe and transmitted data via blutooth to an iPhone on which calculations were made.

My responsibilities included:

Construction of 3 prototype versions
Developing the logic for gait breakdown and timestamping (Gait.m)
Scanning, meshing, and printing 3D sole models
Collecting data

*** GAIT.M SCRIPT ***

This is the MATLAB script processes accelerometer data from the shoe in order to break down stride motion and timestamp each point in the gait cyce (the gait cycle consists of two steps - one with each foot - and encompasses 8 points). 

In aligning timestamps with specific points in the stride, we were able to:

Pull data from other sensors such as the gyroscope to make inferences about gait health
Calculate duration ratios between feet and even different parts of the stride for a given foot

*** COMMENTS ***
Later in the project, I worked with another member of my group to translate this script into Swift in order to more efficiently run in the app.
