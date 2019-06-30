tic
addpath(genpath('.\btk'))

folder  = {'.\CP',...
    '.\FD',...
    '.\ITW'};
group = {'CP','FD','ITW'};
diff_global_FO = struct();
diff_global_FS = struct();

%algorithm's settings, for foot contact
set_str=7; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet, 7=foot and ankle
side_str=1; %Side choice: 1 or nothing=both, 2=right and left side separately
disc_str=266;   %number of levels of discretization
sweep_str=15;   %size of the subsequences
PeakHeight_str=1;   %minimal height of the peak
PeakDistance_str=25;    %minimal distance between peaks
PeakProminence_str=14.82; %minimal peak prominence
%algorithm's settings, for foot off
set_off=6; %Set choice: 1=all marker, 2=minimal, 3=lower body, 4=legs, 5=shanks, 6=feet, 7=foot and ankle
side_off=2; %Side choice: 1 or nothing=both, 2=right and left side separately
disc_off=123;   %number of levels of discretization
sweep_off=18;   %size of the subsequences
PeakHeight_off=1;   %minimal height of the peak
PeakDistance_off=32;    %minimal distance between peaks
PeakProminence_off=34.77;   %minimal peak prominence


for ind_folder = 1:size(folder,2)
    name_files = dir(folder{ind_folder});
    
    diff_global_FO_temp = [];
    diff_global_FS_temp = [];
    for ind_name = 3:size(name_files)
        c3d_filename = name_files(ind_name).name
        c3d_filename = strcat(folder{ind_folder},'\',c3d_filename)
        acq = btkReadAcquisition(c3d_filename);
        % Event detection function
        [RFS,LFS]= Luo_motion_extraction_sofa_R_L(acq,set_str,side_str,disc_str,sweep_str,...
            PeakHeight_str,PeakDistance_str,PeakProminence_str,1);
        [RFO,LFO]= Luo_motion_extraction_sofa_R_L(acq,set_off,side_off,disc_off,sweep_off,...
            PeakHeight_off,PeakDistance_off,PeakProminence_off,2);
        
        % Frame difference calculation from the reference
        refevents = btkGetEvents(acq);
        name_events = fieldnames(refevents);
        
        if isfield(refevents,'Right_Foot_Strike_GS')
            ref_RFS = refevents.Right_Foot_Strike_GS()*btkGetPointFrequency(acq);
            diff_global_FS_temp = [diff_global_FS_temp,calcul_penalty(RFS,ref_RFS)];
        end
        
        if isfield(refevents,'Right_Foot_Off_GS')
            ref_RFO = refevents.Right_Foot_Off_GS()*btkGetPointFrequency(acq);
            diff_global_FO_temp = [diff_global_FO_temp,calcul_penalty(RFO,ref_RFO)];
        end
        
        if isfield(refevents,'Left_Foot_Strike_GS')
            ref_LFS = refevents.Left_Foot_Strike_GS()*btkGetPointFrequency(acq);
            diff_global_FS_temp = [diff_global_FS_temp,calcul_penalty(LFS,ref_LFS)];
        end
        
        if isfield(refevents,'Left_Foot_Off_GS')
            ref_LFO = refevents.Left_Foot_Off_GS()*btkGetPointFrequency(acq);
            diff_global_FO_temp = [diff_global_FO_temp,calcul_penalty(LFO,ref_LFO)];
        end
    end
    diff_global_FO.(group{ind_folder}) = diff_global_FO_temp;
    diff_global_FS.(group{ind_folder}) = diff_global_FS_temp;
end

% Score by pathology
score_final_FO_CP = sum(exp(diff_global_FO.CP))/size(diff_global_FO.CP,2);
score_final_FS_CP = sum(exp(diff_global_FS.CP))/size(diff_global_FS.CP,2);

score_final_FO_FD = sum(exp(diff_global_FO.FD))/size(diff_global_FO.FD,2);
score_final_FS_FD = sum(exp(diff_global_FS.FD))/size(diff_global_FS.FD,2);

score_final_FO_ITW = sum(exp(diff_global_FO.ITW))/size(diff_global_FO.ITW,2);
score_final_FS_ITW = sum(exp(diff_global_FS.ITW))/size(diff_global_FS.ITW,2);

% Total score
diff_FO_total = [];
diff_FS_total = [];
for ind_folder = 1:size(folder,2)
    diff_FO_total = [diff_FO_total,diff_global_FO.(group{ind_folder})];
    diff_FS_total = [diff_FS_total,diff_global_FS.(group{ind_folder})];
end
score_final_FO_total = sum(exp(diff_FO_total))/size(diff_FO_total,2);
score_final_FS_total = sum(exp(diff_FS_total))/size(diff_FS_total,2);
disp(strcat('The final score for Foot off is :',num2str(score_final_FO_total)))

disp(strcat('The final score for Foot strike is :',num2str(score_final_FS_total)))
elapsed_time=toc;
disp(strcat('Elapsed time :',string(elapsed_time)))