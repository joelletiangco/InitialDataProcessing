% APRIL 15TH - update
    % updated graph labels from x, y, z to flex/ext, inv/evr, int/ext rot
%% april 18 update - charge var names +data lines and remove units line.
% Sep 16 update - able to add vars and have them autoplot, remember to add
% units to units as well. 
function data = parse_and_plot(files, optsForce, title, dir);
% function that parses force columns of interest and columns of interest
% from vicon model outputs into data_parsed
% also sets import options for the vicon data to update for each file to
% ensure variable names are up to date since column positioning is
% inconsistent between files
% then plots graphs of the data so quality can be checked
%% does not plot angular vel. and angular accel. of hip, knee and ankle rn, but could easily be added :)
%% Inputs
% files -> struct of files for a given condition (side steps(1x1 struct) or walking(10x1 struct)), subject
% (just one) and side (R or L), struct has sub topics .force and .vicon

% optsForce -> import options for force data, as declared in the main
% (Process_main_mar27)

% title -> title you want to use for the graphs, as declared in main

% dir -> subject directory, also includes condition (ex.
% ./Feb01A/ShoesExcel/), declared in main

%% outputs
% data -> struct that contains parsed and organized force + vicon model
% outputs data for a given subject, condition and side combination

%% FILTER CREATION - October 3rd, 2023
% force plate filter
% Wn depends on sampling frequency
% butter(order of filter, cutoff freq / (sampling freq/2))
[b_f, a_f] = butter(4, 20/(1000/2));

% kinematic data filter - for any vicon data
[b_v, a_v] = butter(4, 20/(200/2));

%% define variables of interest here.
%% FIXED FINDING WHERE THESE VARIABLES ARE
% vars2find = {'RPelvisAngles', 'LPelvisAngles', 'RKneeAngles', 'LKneeAngles', 'RAnkleAngles', 'LAnkleAngles'};
% vars2find = {'RAnkleAngles', 'LAnkleAngles', 'RKneeAngles', 'LKneeAngles', 'RHipAngles', 'LHipAngles', 'RHipForce', 'LHipForce', 'RHipPower', 'LHipPower', 'RKneeMoment', 'LKneeMoment'};
% units = {' (°)', ' (°)', ' (°)', ' (°)', ' (°)', ' (°)', ' (N/kg)', ' (N/kg)', ' (W/kg)', ' (W/kg)', ' (N*mm/kg)', ' (N*mm/kg)'};

% SEPT 18 CHANGES HERE
angleVars = {'RAnkleAngles', 'LAnkleAngles', 'RKneeAngles', 'LKneeAngles', 'RHipAngles', 'LHipAngles'};
angleUnits = {' (°)', ' (°)', ' (°)', ' (°)', ' (°)', ' (°)'};

footProgVars = {'RFootProgressAngles', 'LFootProgressAngles'};
footProgUnits = {' (°)', ' (°)'};

pelvisVars = {'RPelvisAngles', 'LPelvisAngles'};
pelvisUnits = {' (°)', ' (°)'};

forceVars = {'RAnkleForce', 'LAnkleForce', 'RKneeForce', 'LKneeForce', 'RHipForce', 'LHipForce'};
forceUnits = {' (N/kg)', ' (N/kg)', ' (N/kg)', ' (N/kg)', ' (N/kg)', ' (N/kg)'};

momentVars = {'RAnkleMoment', 'LAnkleMoment', 'RKneeMoment', 'LKneeMoment', 'RHipMoment', 'LHipMoment'};
momentUnits = {' (N*mm/kg)', ' (N*mm/kg)', ' (N*mm/kg)', ' (N*mm/kg)', ' (N*mm/kg)', ' (N*mm/kg)'};

powerVars = {'RAnklePower', 'LAnklePower', 'RKneePower', 'LKneePower', 'RHipPower', 'LHipPower'};
powerUnits = {' (W/kg)', ' (W/kg)', ' (W/kg)', ' (W/kg)', ' (W/kg)', ' (W/kg)'};

allTogether = [angleVars footProgVars pelvisVars forceVars momentVars powerVars];
unitsTogether = [angleUnits footProgUnits pelvisUnits forceUnits momentUnits powerUnits];
vars2find = allTogether;
units = unitsTogether;

%% create variable names to use later
j = 1;
for i = 1:3:3*length(vars2find)
    VarNames{i} = [vars2find{j} '_x'];
    VarNames{i+1} = [vars2find{j} '_y'];
    VarNames{i+2} = [vars2find{j} '_z'];
    j = j+1;
end

%% load in the force data, and save it in the struct, only saving Forces, moments and COPs
for i = 1:1:length(files.force)
    clear temp
    temp = readtable([dir files.force(i).name], optsForce);
    temp = array2table(filtfilt(b_f, a_f, table2array(temp)), 'VariableNames', temp.Properties.VariableNames);
    

    % ADDING FILTERING - October 3, 2023
    % note: can't filter a table but you can filter a matrix --> filter
    % matrix first before putting it into a table
    data(i).Force = array2table([temp.Fx temp.Fy temp.Fz], 'VariableNames', {'Fx', 'Fy', 'Fz'});
    data(i).COP = array2table([temp.Fx temp.Fy temp.Fz], 'VariableNames', {'Cx', 'Cy', 'Cz'});
    data(i).M = array2table([temp.Fx temp.Fy temp.Fz], 'VariableNames', {'Mx', 'My', 'Mz'});
    %         dataraw(i).Vicon = readtable([dir files(i).name, optsMocap]);
    %       %% declare import options for vicon
    opts = detectImportOptions([dir files.vicon(i).name]);
    opts.DataLines = [2 Inf];
    
    opts.VariableNamesLine = 1;
    opts.ExtraColumnsRule = 'ignore';
    % make sure all vars are type double
    % ENSURING ITS ALL TYPE DOUBLE (SOMETIMES GETTING CHAR BC OF BLANKS W THE DIFF FORMULA FOR VELOCITY AND ANG ACCELERATION)
    for a = 1:1:length(opts.VariableNames)
        varTypes{a} = 'double';
    end
    opts.VariableTypes = varTypes;

    % load in data to temp table, clears every iter
    clear vicon_temp
    vicon_temp = readtable([dir files.vicon(i).name], opts);
    [dir files.vicon(i).name]
    % Oct 3rd, 2023 Adding Filter
%     vicon_temp = array2table(filtfilt(b_v, a_v, table2array(vicon_temp)), 'VariableNames', vicon_temp.Properties.VariableNames);

    % find columns of interest for a given index{i} (1) is °rees or
    % mm, (2) is °/s or mm/s, (3) is °/s^2 and mm/s^2
    %% FIRST IS °REES OR DISTANCE, SECOND IS THE DERIV VELOCITY (ANGULAR OR POSITIONAL), THIRD IS THE ACCELERATION (ANG OR POS)

    for k = 1:1:length(vars2find)
        index{k} = find(contains(opts.VariableNames, vars2find{k}));
        %% 
    end
    
    % split into indices for °rees, angular velocity and angular
    % acceleration
    for j = 1:1:length(index)
        clear ind_temp
        ind_temp = index{j};
        %% // CURRENTLY ANGLE BUT COULD BE POSITION BC RN ONLY LOOKING FOR ANGLES 
        index{j}
        index_ang(j) = ind_temp(1);
        index_vel(j) = ind_temp(2);
        index_acc(j) = ind_temp(3);
    end


    % convert vicon_temp to a table type for use below
    vicon_temp = table2array(vicon_temp);
    %% save data in angles part of struct
    %save in temp, concat through for loop
    temp_ang = [];
    temp_vel = [];
    temp_acc = [];
    % make matrices of angle, angular velocity and angular acceleration
    % data for each 'main' joint on each side
    for m = 1:1:length(index_ang)
        temp_ang = [temp_ang vicon_temp(:, index_ang(m)) vicon_temp(:, index_ang(m)+1) vicon_temp(:, index_ang(m)+2)];
        % 2 to end for angular velocity because 1st pt is NaN b/c of vicons
        % derivation method
        temp_vel = [temp_vel vicon_temp(:, index_vel(m)) vicon_temp(:, index_vel(m)+1) vicon_temp(:, index_vel(m)+2)];
        % 3 to end for angular acceleration because 1st two pts are NaN b/c of vicons
        % derivation method
        temp_acc = [temp_acc vicon_temp(:, index_acc(m)) vicon_temp(:, index_acc(m)+1) vicon_temp(:, index_acc(m)+2)];
    end

    %% save parsed data into the data struct that is output by the function
    data(i).orig = array2table(filtfilt(b_v, a_v, temp_ang), 'VariableNames', VarNames);
    data(i).deriv1 = array2table(filtfilt(b_v, a_v, temp_vel), 'VariableNames', VarNames);
    data(i).deriv2 = array2table(filtfilt(b_v, a_v, temp_acc), 'VariableNames', VarNames);
    % BREAKPOINT FOR DEBUGGING
    a=2;
end

figure()
for i = 1:1:length(files.force)
    % multiply force by -1 so I can plot GRF
    % it was action force and we want to plot ground reaction force to multiply by -ve 1
    subplot(3,1,1)
    plot(-1.*data(i).Force.Fx)
    hold on
    ylabel('GRF X (N)')
    xlabel('Frame')

    sgtitle([title 'GRF'])
    subplot(3,1,2)
    plot(-1.*data(i).Force.Fy)
    hold on
    xlabel('Frame')
    ylabel('GRF Y (N)')

    subplot(3,1,3)
    plot(-1.*data(i).Force.Fz)
    hold on
    xlabel('Frame')
    ylabel('GRF Z (N)')
end
legend('1', '2', '3', '4', '5', '6', '7', '8', '9', '10')
% fprintf(' trial 1 length: ')
% length(data(1).Force.Fz)
% fprintf(' trial 8 length: ')
% length(data(8).Force.Fz)
%% plot vicon data

%% plot right ankle angles
for j= 1:3:length(VarNames)
    figure()
    for i = 1:1:length(files.force)
%         disp('TESTING THIS OUT:')
%         disp(VarNames{j})
%         disp('DONE PRINTING')
        subplot(3,1,1)
        plot(data(i).orig.(char(VarNames{j})))
        hold on
        ylabel(['X' units{(j+2)/3}])
        xlabel('Frame')
        plot_label = strsplit(VarNames{j}, '_');
        sgtitle([title ' ' plot_label{1}])
        subplot(3,1,2)
        plot(data(i).orig.(char(VarNames{j+1})))
        hold on
        xlabel('Frame')
        ylabel(['Y' units{(j+2)/3}])

        subplot(3,1,3)
        plot(data(i).orig.(char(VarNames{j+2})))
        hold on
        xlabel('Frame')
        ylabel(['Z' units{(j+2)/3}])
    end
end
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     %var names is statically typed at the top (manually)
%     %sketchy if it was not manually detected bc it would be "double" dynamically naming/pulling variables
%     plot(data(i).orig.(char(VarNames{1})))
%     hold on
%     ylabel('Ankle Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Right Ankle Angles'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{2})))
%     hold on
%     xlabel('Frame')
%     ylabel('Ankle Inv/Evr (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{3})))
%     hold on
%     xlabel('Frame')
%     ylabel('Ankle Int/Ext Rot (°)')
% end
% 
% %% plot left ankle angles
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{4})))
%     hold on
%     ylabel('Ankle Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Left Ankle Angles'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{5})))
%     hold on
%     xlabel('Frame')
%     ylabel('Ankle Inv/Evr (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{6})))
%     hold on
%     xlabel('Frame')
%     ylabel('Ankle Int/Ext Rot (°)')
% end
% 
% 
% 
% %% plot right knee angles
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{7})))
%     hold on
%     ylabel('Knee Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Right Knee Angles'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{8})))
%     hold on
%     xlabel('Frame')
%     ylabel('Knee Inv/Evr (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{9})))
%     hold on
%     xlabel('Frame')
%     ylabel('Knee Int/Ext Rot (°)')
% end
% 
% %% plot left knee angles
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{10})))
%     hold on
%     ylabel('Knee Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Left Knee Angles'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{11})))
%     hold on
%     xlabel('Frame')
%     ylabel('Knee Inv/Evr (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{12})))
%     hold on
%     xlabel('Frame')
%     ylabel('Knee Int/Ext Rot (°)')
% end
% 
% %% plot right hip angles
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{13})))
%     hold on
%     ylabel('Hip Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Right Hip Angle'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{14})))
%     hold on
%     xlabel('Frame')
%     ylabel('Hip Inv/Evr (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{15})))
%     hold on
%     xlabel('Frame')
%     ylabel('Hip Int/Ext Rot (°)')
% end
% 
% %% plot right hip angles
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{16})))
%     hold on
%     ylabel('Hip Flex/Ext (°)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Left Hip Angle'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{17})))
%     hold on
%     xlabel('Frame')
%     ylabel('Hip Abd/Add (°)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{18})))
%     hold on
%     xlabel('Frame')
%     ylabel('Hip Int/Ext Rot (°)')
% end
% 
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{19})))
%     hold on
%     ylabel('RHipForce (N/kg)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Right Hip Force'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{20})))
%     hold on
%     xlabel('Frame')
%     ylabel('RHipForce (N/kg)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{21})))
%     hold on
%     xlabel('Frame')
%     ylabel('RHipForce (N/kg)')
% end
% 
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{22})))
%     hold on
%     ylabel('LHipForce (N/kg)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Left Hip Force'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{23})))
%     hold on
%     xlabel('Frame')
%     ylabel('LHipForce (N/kg)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{24})))
%     hold on
%     xlabel('Frame')
%     ylabel('LHipForce (N/kg)')
% end
% 
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{25})))
%     hold on
%     ylabel('RHipPower (W/kg)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Right Hip Power'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{26})))
%     hold on
%     xlabel('Frame')
%     ylabel('RHipPower (W/kg)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{27})))
%     hold on
%     xlabel('Frame')
%     ylabel('RHipPower (W/kg)')
% end
% 
% figure()
% for i = 1:1:length(files.vicon)
% 
%     subplot(3,1,1)
%     plot(data(i).orig.(char(VarNames{28})))
%     hold on
%     ylabel('LHipPower (W/kg)')
%     xlabel('Frame')
% 
%     sgtitle([title ' Left Hip Power'])
%     subplot(3,1,2)
%     plot(data(i).orig.(char(VarNames{29})))
%     hold on
%     xlabel('Frame')
%     ylabel('LHipPower (W/kg)')
% 
%     subplot(3,1,3)
%     plot(data(i).orig.(char(VarNames{30})))
%     hold on
%     xlabel('Frame')
%     ylabel('LHipPower (W/kg)')
% end
end
