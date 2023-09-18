%% new data processing main
% Megan + Joelle
% April 11th, reediting this version

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
%figure out which things in this folder are folders (aka subfolders)
subFoldersBin = [dirInfo.isdir];
%creat a variable to store folder names (which are gonna be subject IDs)
subFolders = dirInfo(subFoldersBin);
% get folder names (which are subject names)
% get rid of the first two folders that don't exist so start at the third folder
subject = {subFolders(3:end).name};

%% turn off readtable variable renaming warning
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
%% CHANGED TO 2 TO DEBUG -> second set of files weren't working so you skipped it (typically 1:1:length)
for i = 1:1:length(subject)
    
    fprintf(['SUBJECT: ' subject{i} '\n'])
    %% set up file lists for shod data -> could probably do this in a more efficient way...
    Sdir = ['./' subject{i} '/ShoesExcel/'];
    % LEFT SIDE
    % force
    S_walk_L_files.force = dir([Sdir '*WalkingLeft*_force.csv']);
    % // change this side lunges to lunge*
    S_SS_L_files.force = dir([Sdir '*SideLunge*Left*_force.csv']);
    % vicon
    S_walk_L_files.vicon = dir([Sdir '*WalkingLeft*_vicon.csv']);
    S_SS_L_files.vicon = dir([Sdir '*SideLungesLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    S_walk_R_files.force = dir([Sdir '*WalkingRight*_force.csv']);
    S_SS_R_files.force = dir([Sdir '*SideLungesRight*_force.csv']);
    % vicon
    S_walk_R_files.vicon = dir([Sdir '*WalkingRight*_vicon.csv']);
    S_SS_R_files.vicon = dir([Sdir '*SideLungesRight*_vicon.csv']);
    
    %% set up import options for all force data using a sample file
    opts = detectImportOptions([Sdir S_walk_L_files.force(1).name]);
    %% data starts on line 6
    opts.DataLines = [6 Inf];
    %% defines where the variable names and the units are
    opts.VariableUnitsLine = 5;
    opts.VariableNamesLine = 4;
    opts.ExtraColumnsRule = 'ignore';


    %% parse and plot shod data
    R_walk_S = parse_and_plot(S_walk_R_files, opts, [subject{i} ' Shod walk Right Side'], Sdir);
    L_walk_S = parse_and_plot(S_walk_L_files, opts, [subject{i} ' Shod walk Left Side'], Sdir);
    R_SS_S = parse_and_plot(S_SS_R_files, opts, [subject{i} ' Shod Side Lunges Right Side'], Sdir);
    L_SS_S = parse_and_plot(S_SS_L_files, opts, [subject{i} ' Shod Side Lunges Left Side'], Sdir);
    
%% pause to look at shod data
fprintf([subject{i} ' Shod Data \n'])
stop = 'here';
% close all shod graphs
close all

    %% create file lists of orthotics data
    ORdir = ['./' subject{i} '/OrthoticsExcel/'];
    % LEFT SIDE
    % force
    OR_walk_L_files.force = dir([ORdir '*WalkingLeft*_force.csv']);
    OR_SS_L_files.force = dir([ORdir '*SideLungesLeft*_force.csv']);
    % vicon
    OR_walk_L_files.vicon = dir([ORdir '*WalkingLeft*_vicon.csv']);
    OR_SS_L_files.vicon = dir([ORdir '*SideLungesLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    OR_walk_R_files.force = dir([ORdir '*WalkingRight*_force.csv']);
    OR_SS_R_files.force = dir([ORdir '*SideLungesRight*_force.csv']);
    % vicon
    OR_walk_R_files.vicon = dir([ORdir '*WalkingRight*_vicon.csv']);
    OR_SS_R_files.vicon = dir([ORdir '*SideLungesRight*_vicon.csv']);

    %% parse and plot orthotics data
    R_walk_OR = parse_and_plot(OR_walk_R_files, opts, [subject{i} ' Orthotics walk Right Side'], ORdir);
    L_walk_OR = parse_and_plot(OR_walk_L_files, opts, [subject{i} ' Orthotics walk Left Side'], ORdir);
    R_SS_OR = parse_and_plot(OR_SS_R_files, opts, [subject{i} ' Orthotics Side Lunges Right Side'], ORdir);
    L_SS_OR = parse_and_plot(OR_SS_L_files, opts, [subject{i} ' Orthotics Side Lunges Left Side'], ORdir);
    

%% pause to look at orthotics data
fprintf([subject{i} ' Orthotics Data \n'])
stop = 'here';
%close ortho graphs
close all

    %% create file lists of barefoot data
    BFdir = ['./' subject{i} '/BarefootExcel/'];
    % LEFT SIDE
    % force
    BF_walk_L_files.force = dir([BFdir '*WalkingLeft*_force.csv']);
    BF_SS_L_files.force = dir([BFdir '*SideLungesLeft*_force.csv']);
    % vicon
    BF_walk_L_files.vicon = dir([BFdir '*WalkingLeft*_vicon.csv']);
    BF_SS_L_files.vicon = dir([BFdir '*SideLungesLeft*_vicon.csv']);

    % RIGHT SIDE
    %force
    BF_walk_R_files.force = dir([BFdir '*WalkingRight*_force.csv']);
    BF_SS_R_files.force = dir([BFdir '*SideLungesRight*_force.csv']);
    % vicon
    BF_walk_R_files.vicon = dir([BFdir '*WalkingRight*_vicon.csv']);
    BF_SS_R_files.vicon = dir([BFdir '*SideLungesRight*_vicon.csv']);

    %% parse and plot barefoot data
    R_walk_BF = parse_and_plot(BF_walk_R_files, opts, [subject{i} ' Barefoot walk Right Side'], BFdir);
    L_walk_BF = parse_and_plot(BF_walk_L_files, opts, [subject{i} ' Barefoot walk Left Side'], BFdir);
    R_SS_BF = parse_and_plot(BF_SS_R_files, opts, [subject{i} ' Barefoot Side Lunges Right Side'], BFdir);
    L_SS_BF = parse_and_plot(BF_SS_L_files, opts, [subject{i} ' Barefoot Side Lunges Left Side'], BFdir);
    
    % pause to look at barefoot data and between participants
    fprintf([subject{i} ' Barefoot Data \n'])
    stop = 'here';
    close all
    
%% stop = here lets you put a break point to pause between subjects
end
