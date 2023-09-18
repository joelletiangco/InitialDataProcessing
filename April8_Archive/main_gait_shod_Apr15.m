%% new data processing main
% April 11th, 2023

% DESIRED UPDATE: looking at just gait data, also want to refactor?
% MAKE SURE U ADD BREAKPOINTS (search for 'st0p')

% Loads in vicon files and force plate files for subjects. 
% calls quality function which strips out columns of interest from the
% vicon files (right now this is just pelvis, knee and ankle angles in x, y, z) and
% then plots them. 

% opts is import options force the force data
% larger change since last code: import options for vicon data are no longer defined in 
% main, they are defined in the subfunction, to ensure variable names list stays up to date w each file, because column locations are not consistent

%% clear workspace 
clear all
close all 
clc

%% important vars
% description of acronyms used
% BF = BareFoot
% S = shod
% OR = Orthotics
% Walk = walking trials
% L = left
% R = Right
% SS = sidesteps

%% specify subject
dirInfo = dir();
%figure out which things in this folder are folders (aka subfolders)
subFoldersBin = [dirInfo.isdir];
%creat a variable to store folder names (which are gonna be subject IDs)
subFolders = dirInfo(subFoldersBin);
% get folder names (which are subject names)
% get rid of the first two folders that don't exist so start at the third folder
subject = {subFolders(3:end).name};

%% turn off readtable variable renaming warning
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

for i = 1:1:1
% for i = 1:1:length(subject)
    disp(['i = ', num2str(i)])
    fprintf(['SUBJECT: ' subject{i} '\n'])

    %% set up file lists for shod data -> could probably do this in a more efficient way...
    SubjectDir = ['./' subject{i} '/ShoesExcel/'];


    %% set up import options for all force data using a sample file
    sample_file.force = dir([SubjectDir '*WalkingLeft*_force.csv']);
    opts = detectImportOptions([SubjectDir sample_file.force(1).name]);
%     opts = detectImportOptions([SubjectDir S_walk_L_files.force(1).name]);
    %% data starts on line 6
    data_starts = 6;
    opts.DataLines = [data_starts Inf];
    %% defines where the variable names and the units are
    opts.VariableUnitsLine = 5;
    opts.VariableNamesLine = 4;
    opts.ExtraColumnsRule = 'ignore';

    % LEFT SIDE
    S_walk_L_files.force = dir([SubjectDir '*WalkingLeft*_force.csv']);
    S_walk_L_files.vicon = dir([SubjectDir '*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE
    S_walk_R_files.force = dir([SubjectDir '*WalkingRight*_force.csv']);
    S_walk_R_files.vicon = dir([SubjectDir '*WalkingRight*_vicon.csv']);


    %% parse and plot shod data
    R_walk_S = parse_and_plot(S_walk_R_files, opts, [subject{i} ' Shod Walk Right Side'], SubjectDir);
    L_walk_S = parse_and_plot(S_walk_L_files, opts, [subject{i} ' Shod Walk Left Side'], SubjectDir);

%% pause to look at shod data
fprintf([subject{i} ' Shod Data \n'])
stop = 'here';
% close all shod graphs
close all
   
%% stop = here lets you put a break point to pause between subjects
end
