clear;
% Add Utility Function to the MATLAB Path
utilpath = fullfile(matlabroot, 'toolbox', 'imaq', 'imaqdemos','html', 'KinectForWindows');
addpath(utilpath);
% separate VIDEOINPUT object needs to be created for each of the color and depth(IR) devices
% The Kinect for Windows Sensor shows up as two separate devices in IMAQHWINFO.
hwInfo = imaqhwinfo('kinect')
hwInfo.DeviceInfo(1)
hwInfo.DeviceInfo(2)
% Create the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1)
depthVid = videoinput('kinect',2)
preview(colorVid);
preview(depthVid);
