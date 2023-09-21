%% new data processing main
% Sept 18th, 2023

% MAKE SURE U ADD BREAKPOINTS (search for 'stop')
%% april 18 update - charge var names +data lines and remove units line.
% Loads in vicon files and force plate files for subjects. 
% calls quality function which strips out columns of interest from the
% vicon files (right now this is just pelvis, knee and ankle angles in x, y, z) and
% then plots them. 
% opts is import options force the force data
% larger change since last code: import options for vicon data are no longer defined in 
% main, they are defined in the subfunction, to ensure variable names list
% stays up to date w each file, because column locations are not consistent
% other changes include making sure that all variables are double type, as
% previously some were loading as char. 
%% clear workspace 
clear all
close all 
clc

%% important vars
% BF = BareFoot
% S = shod
% OR = Orthotics
% Walk = walking trials
% L = left
% R = Right
% SS = sidesteps

%% specify subject
dirInfo = dir();
%determine which things in this folder are subfolders 
subFoldersBin = [dirInfo.isdir];
%creat a variable to store folder names (which are gonna be subject IDs)
subFolders = dirInfo(subFoldersBin);
% get folder names (which are subject names)
% get rid of the first two folders that don't exist so start at the third folder
subject = {subFolders(3:end-1).name};

%% turn off readtable variable renaming warning
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')

for i = 1:1:length(subject)
    disp(['i = ', num2str(i)])
    fprintf(['SUBJECT: ' subject{i} '\n'])
    %% set up file lists for shod data -> could probably do this in a more efficient way...
    Sdir = ['./' subject{i} '/ShoesExcel/'];
    % LEFT SIDE
    S_walk_L_files.force = dir([Sdir '*WalkingLeft*_force.csv']);
    S_walk_L_files.vicon = dir([Sdir '*WalkingLeft*_vicon.csv']);


    % RIGHT SIDE
    S_walk_R_files.force = dir([Sdir '*WalkingRight*_force.csv']);
    S_walk_R_files.vicon = dir([Sdir '*WalkingRight*_vicon.csv']);

    
    %% set up import options for all force data using a sample file
    opts = detectImportOptions([Sdir S_walk_L_files.force(1).name]);
    %% data starts on line 6
    opts.DataLines = [2 Inf];
    %% defines where the variable names and the units are
    %opts.VariableUnitsLine = 5;
    opts.VariableNamesLine = 1;
    opts.ExtraColumnsRule = 'ignore';


    %% parse and plot shod data
    R_walk_S{i} = parse_and_plot(S_walk_R_files, opts, [subject{i} ' Shod walk Right Side'], Sdir);
    L_walk_S{i} = parse_and_plot(S_walk_L_files, opts, [subject{i} ' Shod walk Left Side'], Sdir);
    
%% pause to look at shod data
fprintf([subject{i} ' Shod Data \n'])
stop = 'here';
% close all shod graphs
close all

    %% create file lists of orthotics data
    ORdir = ['./' subject{i} '/OrthoticsExcel/'];
    % LEFT SIDE
    OR_walk_L_files.force = dir([ORdir '*WalkingLeft*_force.csv']);
    OR_walk_L_files.vicon = dir([ORdir '*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE
    OR_walk_R_files.force = dir([ORdir '*WalkingRight*_force.csv']);
    OR_walk_R_files.vicon = dir([ORdir '*WalkingRight*_vicon.csv']);


    %% parse and plot orthotics data
    R_walk_OR{i} = parse_and_plot(OR_walk_R_files, opts, [subject{i} ' Orthotics walk Right Side'], ORdir);
    L_walk_OR{i} = parse_and_plot(OR_walk_L_files, opts, [subject{i} ' Orthotics walk Left Side'], ORdir);
    

%% pause to look at orthotics data
fprintf([subject{i} ' Orthotics Data \n'])
stop = 'here';
%close orthotics graphs
close all

    %% create file lists of barefoot data
    BFdir = ['./' subject{i} '/BarefootExcel/'];
    % LEFT SIDE
    BF_walk_L_files.force = dir([BFdir '*WalkingLeft*_force.csv']);
    BF_walk_L_files.vicon = dir([BFdir '*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE 
    BF_walk_R_files.force = dir([BFdir '*WalkingRight*_force.csv']);
    BF_walk_R_files.vicon = dir([BFdir '*WalkingRight*_vicon.csv']);

    %% parse and plot barefoot data
    R_walk_BF{i} = parse_and_plot(BF_walk_R_files, opts, [subject{i} ' Barefoot walk Right Side'], BFdir);
    L_walk_BF{i} = parse_and_plot(BF_walk_L_files, opts, [subject{i} ' Barefoot walk Left Side'], BFdir);
    
% pause to look at barefoot data and between participants
fprintf([subject{i} ' Barefoot Data \n'])

stop = 'here';
close all
    
%% stop = here lets you put a break point to pause between subjects
end