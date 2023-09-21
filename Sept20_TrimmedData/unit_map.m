disp('Hello World!')

% vars2find = {'RAnkleAngles', 'LAnkleAngles', 'RKneeAngles', 'LKneeAngles', 'RHipAngles', 'LHipAngles', 'RHipForce', 'LHipForce', 'RHipPower', 'LHipPower', 'RKneeMoment', 'LKneeMoment'};
% units = {' (°)', ' (°)', ' (°)', ' (°)', ' (°)', ' (°)', ' (N/kg)', ' (N/kg)', ' (W/kg)', ' (W/kg)', ' (N*mm/kg)', ' (N*mm/kg)'};

% CHANGES HERE
% vars2find = {'RAnkleMoment', 'LAnkleMoment', 'RAnklePower', 'LAnklePower'}
% units = {' (N*mm/kg)', ' (N*mm/kg)', ' (W/kg)', ' (W/kg)'}

% Create a structure array
units.LAnkleAngles = '°';
units.LAnkleForce = 'N/kg';
units.LAnkleMoment = 'Nmm/kg';
units.LAnklePower = 'W/kg';
units.LFootProgressAngles = '°';
units.LHipAngles = '°';
units.LHipForce = 'N/kg';
units.LHipMoment = 'Nmm/kg';
units.LHipPower = 'W/kg';
units.LKneeAngles = '°';
units.LKneeForce = 'N/kg';
units.LKneeMoment = 'Nmm/kg';
units.LKneePower = 'W/kg';
units.LPelvisAngles = '°';

units.RAnkleAngles = '°';
units.RAnkleForce = 'N/kg';
units.RAnkleMoment = 'Nmm/kg';
units.RAnklePower = 'W/kg';
units.RFootProgressAngles = '°';
units.RHipAngles = '°';
units.RHipForce = 'N/kg';
units.RHipMoment = 'Nmm/kg';
units.RHipPower = 'W/kg';
units.RKneeAngles = '°';
units.RKneeForce = 'N/kg';
units.RKneeMoment = 'Nmm/kg';
units.RKneePower = 'W/kg';
units.RPelvisAngles = '°';


string = ['X (' units.LAnkleForce ')'];
disp(string)
disp(units.LAnkleForce)
