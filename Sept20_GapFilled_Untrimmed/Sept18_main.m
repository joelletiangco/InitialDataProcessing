%% new data processing main
% Sept 18, 2023
%     Sept 18 changes: cleaned up code to only have gait data

% MAKE SURE U ADD BREAKPOINTS (search for 'stop')


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
%figure out which things in this folder are folders (aka subfolders)
subFoldersBin = [dirInfo.isdir];
%creat a variable to store folder names (which are gonna be subject IDs)
subFolders = dirInfo(subFoldersBin);
% get folder names (which are subject names)
% get rid of the first two folders that don't exist so start at the third folder
subject = {subFolders(3:end).name};

%% turn off readtable variable renaming warning
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
%% turn off directory already exists warning for running w the parse csv + plot code
warning('OFF', 'MATLAB:MKDIR:DirectoryExists')
%% ADDED LINE BELOW TO LOOK ONLY AT ONE SUBJECT
% subject = {'Jan22A'};
for i = 1:1:length(subject)-1
    disp(['i = ', num2str(i)])
    fprintf(['SUBJECT: ' subject{i} '\n'])
    %% set up file lists for shod data -> could probably do this in a more efficient way...
    Sdir = ['./' subject{i} '/ShoesExcel/'];
    % LEFT SIDE
    % force
    S_walk_L_files.force = dir([Sdir 'S*WalkingLeft*_force.csv']);
    % vicon
    S_walk_L_files.vicon = dir([Sdir 'S*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    S_walk_R_files.force = dir([Sdir 'S*WalkingRight*_force.csv']);
    % vicon
    S_walk_R_files.vicon = dir([Sdir 'S*WalkingRight*_vicon.csv']);
    
    %% set up import options for all force data using a sample file
    opts = detectImportOptions([Sdir S_walk_L_files.force(1).name]);
    %% data starts on line 6
    opts.DataLines = [6 Inf];
    %% defines where the variable names and the units are
    opts.VariableUnitsLine = 5;
    opts.VariableNamesLine = 4;
    opts.ExtraColumnsRule = 'ignore';


    %% parse and plot shod data
    R_walk_S = parse_csv_and_plot(S_walk_R_files, opts, [subject{i} ' Shod walk Right Side'], Sdir);
    L_walk_S = parse_csv_and_plot(S_walk_L_files, opts, [subject{i} ' Shod walk Left Side'], Sdir);

    
%% pause to look at shod data
fprintf([subject{i} ' Shod Data \n'])
stop = 'here';
% close all shod graphs
close all

    %% create file lists of orthotics data
    ORdir = ['./' subject{i} '/OrthoticsExcel/'];
    % LEFT SIDE
    % force
    OR_walk_L_files.force = dir([ORdir 'O*WalkingLeft*_force.csv']);
    % vicon
    OR_walk_L_files.vicon = dir([ORdir 'O*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    OR_walk_R_files.force = dir([ORdir 'O*WalkingRight*_force.csv']);
    % vicon
    OR_walk_R_files.vicon = dir([ORdir 'O*WalkingRight*_vicon.csv']);

    %% parse and plot orthotics data
    R_walk_OR = parse_csv_and_plot(OR_walk_R_files, opts, [subject{i} ' Orthotics walk Right Side'], ORdir);
    L_walk_OR = parse_csv_and_plot(OR_walk_L_files, opts, [subject{i} ' Orthotics walk Left Side'], ORdir);

%% pause to look at orthotics data
fprintf([subject{i} ' Orthotics Data \n'])
stop = 'here';
%close orthotics graphs
close all

    %% create file lists of barefoot data
    BFdir = ['./' subject{i} '/BarefootExcel/'];
    % LEFT SIDE
    % force
    % SEPT 16 DEBUG CHANGES HERE TO SKIP the files that start with "._" 
    BF_walk_L_files.force = dir([BFdir 'B*WalkingLeft*_force.csv']);
    % vicon
    BF_walk_L_files.vicon = dir([BFdir 'B*WalkingLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    BF_walk_R_files.force = dir([BFdir 'B*WalkingRight*_force.csv']);
    % vicon
    BF_walk_R_files.vicon = dir([BFdir 'B*WalkingRight*_vicon.csv']);
% a=2;
    %% parse and plot barefoot data
    R_walk_BF = parse_csv_and_plot(BF_walk_R_files, opts, [subject{i} ' Barefoot walk Right Side'], BFdir);
    L_walk_BF = parse_csv_and_plot(BF_walk_L_files, opts, [subject{i} ' Barefoot walk Left Side'], BFdir);
    
    % pause to look at barefoot data and between participants
    fprintf([subject{i} ' Barefoot Data \n'])
    stop = 'here';
    close all
    
%% stop = here lets you put a break point to pause between subjects
end