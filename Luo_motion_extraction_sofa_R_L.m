%%acquisition of the needed data from the motion capture.
function [Reve,Leve]...
    = Luo_motion_extraction_sofa_R_L(acq,set,side_choice,disc,sweep,...
    PeakHeight,PeakDistance,PeakProeminence,strike_off_choice)
Reve=[];    %declare empty event to avoid error if nothing is detected
Leve=[];
all_labels = fieldnames(btkGetMarkers(acq));    %get the labels of the markers(1)
all_markers_values = btkGetMarkersValues(acq);  %give an array filled with the coordinates of the marker (x,y,z of first marker, x,y,z of second, and so on)

X_RTOE=all_markers_values(:,(find(all_labels=="RTOE")-1)*3+1);  %Get the X coordinates of the toe marker, that will be used to assign the ...
X_LTOE=all_markers_values(:,(find(all_labels=="LTOE")-1)*3+1);  %detected event to the right or left foot
if X_RTOE(end)-X_RTOE(1)<0  %The assignement of event is based on the assumption that the patient evolves towards positive X
    X_RTOE=-X_RTOE; %if not the X coordinates are reversed
    X_LTOE=-X_LTOE;
end

if side_choice==1   %the following part execute if both side are used to compute the joint entropy
    
    [markers_values,labels]=marker_set(set,all_labels,all_markers_values,1); %gives back the coordinates values of the selected markers
    
    %the following loop compute the displacments for every markers in every
    %direction
    for i=1:(size(markers_values,1)-1)                                  %-1 otherwise it will crash trying to reach the last frame + 1
        displacement(i,:)=markers_values(i+1,:)-markers_values(i,:);    %simple soustraction between frame+1-frame
    end
    %give only displacements for x, y and z, to ease the next steps (max/min
    %detection and discretization)
    for i=3:3:size(markers_values,2)
        displacement_x(:,i/3)=displacement(:,i-2);
        %{
        displacement_y(:,i/3)=displacement(:,i-1);
        displacement_z(:,i/3)=displacement(:,i);
        %}
    end
    
    %histograms will be created, the max an min of the displacement are
    %used to define the boundaries
    %{
    maximum=max(displacement,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum=min(displacement,[],'all');     %same for min
    %}
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x = max(displacement_x,[],'all');
    min_x = min(displacement_x,[],'all');
    %{
    max_y = max(displacement_y,[],'all');
    min_y = min(displacement_y,[],'all');
    
    max_z = max(displacement_z,[],'all');
    min_z = min(displacement_z,[],'all');
    %}
    
    %creating the histograms
    n = disc ;                                %number of discretizations levels, this setting may have importance on the results
    discretization_x=linspace(min_x,max_x,n);   %the function linspace creates a vector of values envenly distributed along a range
    %{
    discretization_y=linspace(min_y,max_y,n);
    discretization_z=linspace(min_z,max_z,n);
    discretization_global=linspace(minimum,maximum,n);
    %}
    
    Cx_luo=compute_C_luo_mod_disc(n,displacement_x,discretization_x,sweep);  %returns the joint probability matrix for the X components
    %only the X is used because it was observed that it gave the best
    %results
    %{
    Cy_luo=compute_C_luo_mod_disc(n,displacement_y,discretization_y,sweep);
    Cz_luo=compute_C_luo_mod_disc(n,displacement_z,discretization_z,sweep);
    C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,sweep);
    %}
    
    %compute the joint entropy for each dimension
    Ix_luo_mod=mutual_info_luo(size(displacement,1),Cx_luo);
    %{
    Iy_luo_mod=mutual_info_luo(size(displacement,1),Cy_luo);
    Iz_luo_mod=mutual_info_luo(size(displacement,1),Cz_luo);
    I_luo_mod=Ix_luo_mod+Iy_luo_mod+Iz_luo_mod;
    I_max_min_luo_mod=mutual_info_luo(size(displacement,1),C_max_min_luo);
    %}
    %the get_event function gives back the error for the strike and off
    %events, for each dimension. get_error3_with_plot returns the plot for
    %each file
    [Reve,Leve] = get_event(Ix_luo_mod,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
else    %this part execute the code for the rigth and left side separately
    [markers_values_r,labels_r]=marker_set(set,all_labels,all_markers_values,2); %gives back the coordinates values of the selected markers
    [markers_values_l,labels_l]=marker_set(set,all_labels,all_markers_values,3); %gives back the coordinates values of the selected markers
    
    %%calculation of the displacement vector
    displacement_r=zeros(size(markers_values_r,1)-1,size(markers_values_r,2));%preallocation
    displacement_l=zeros(size(markers_values_l,1)-1,size(markers_values_l,2));
    for i=1:(size(markers_values_r,1)-1)                                  %-1 otherwise it will crash trying to reach the last frame + 1
        displacement_r(i,:)=markers_values_r(i+1,:)-markers_values_r(i,:);    %simple soustraction between frame+1-frame
        displacement_l(i,:)=markers_values_l(i+1,:)-markers_values_l(i,:);
    end
    %give only displacements for x, y and z, to ease the next steps (max/min
    %detection and discretization)
    for i=3:3:size(markers_values_r,2)
        displacement_x_r(:,i/3)=displacement_r(:,i-2);
        %{
        displacement_y_r(:,i/3)=displacement_r(:,i-1);
        displacement_z_r(:,i/3)=displacement_r(:,i);
        %}
    end
    for i=3:3:size(markers_values_l,2)
        displacement_x_l(:,i/3)=displacement_l(:,i-2);
        %{
        displacement_y_l(:,i/3)=displacement_l(:,i-1);
        displacement_z_l(:,i/3)=displacement_l(:,i);
        %}
    end
    %%displacement histogram
    %{
    maximum_r=max(displacement_r,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum_r=min(displacement_r,[],'all');     %same for min
    maximum_l=max(displacement_l,[],'all');     %gives the max values for all the column hence for all the x,y,z coordinates respectively
    minimum_l=min(displacement_l,[],'all');     %same for min
    %}
    
    %the following part get the maximum and minimums of x,y and z displacement
    %to set the range of the histograms
    max_x_r = max(displacement_x_r,[],'all');
    min_x_r = min(displacement_x_r,[],'all');
    %{
    max_y_r= max(displacement_y_r,[],'all');
    min_y_r = min(displacement_y_r,[],'all');
    
    max_z_r = max(displacement_z_r,[],'all');
    min_z_r = min(displacement_z_r,[],'all');
    %}
    max_x_l = max(displacement_x_l,[],'all');
    min_x_l = min(displacement_x_l,[],'all');
    %{
    max_y_l= max(displacement_y_l,[],'all');
    min_y_l = min(displacement_y_l,[],'all');
    
    max_z_l = max(displacement_z_l,[],'all');
    min_z_l = min(displacement_z_l,[],'all');
    %}
    
    %creating the histograms
    n = disc ;                                %number of discretizations levels, this setting may have importance on the results
    discretization_x_r=linspace(min_x_r,max_x_r,n);   %the function linspace creates a vector of values envenly distributed along a range
    %{
    discretization_y_r=linspace(min_y_r,max_y_r,n);
    discretization_z_r=linspace(min_z_r,max_z_r,n);
    %}
    
    discretization_x_l=linspace(min_x_l,max_x_l,n);   %the function linspace creates a vector of values envenly distributed along a range
    %{
    discretization_y_l=linspace(min_y_l,max_y_l,n);
    discretization_z_l=linspace(min_z_l,max_z_l,n);
    
    discretization_global_r=linspace(minimum_r,maximum_r,n);
    discretization_global_l=linspace(minimum_l,maximum_l,n);
    %}
    
    Cx_luo_r=compute_C_luo_mod_disc(n,displacement_x_r,discretization_x_r,sweep);  %returns the C matrix
    %{
    Cy_luo_r=compute_C_luo_mod_disc(n,displacement_y_r,discretization_y_r,sweep);
    Cz_luo_r=compute_C_luo_mod_disc(n,displacement_z_r,discretization_z_r,sweep);
    C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,sweep);
    %}
    
    Cx_luo_l=compute_C_luo_mod_disc(n,displacement_x_l,discretization_x_l,sweep);  %returns the C matrix
    %{
    Cy_luo_l=compute_C_luo_mod_disc(n,displacement_y_l,discretization_y_l,sweep);
    Cz_luo_l=compute_C_luo_mod_disc(n,displacement_z_l,discretization_z_l,sweep);
    C_max_min_luo=compute_C_luo_mod_disc(n,displacement,discretization_global,,sweep);
    %}
    
    %compute the joint entropy for each dimension
    Ix_luo_mod_r=mutual_info_luo(size(displacement_r,1),Cx_luo_r);
    %{
    Iy_luo_mod_r=mutual_info_luo(size(displacement_r,1),Cy_luo_r);
    Iz_luo_mod_r=mutual_info_luo(size(displacement_r,1),Cz_luo_r);
    I_luo_mod_r=Ix_luo_mod_r+Iy_luo_mod_r+Iz_luo_mod_r;
    %}
    Ix_luo_mod_l=mutual_info_luo(size(displacement_l,1),Cx_luo_l);
    %{
    Iy_luo_mod_l=mutual_info_luo(size(displacement_l,1),Cy_luo_l);
    Iz_luo_mod_l=mutual_info_luo(size(displacement_l,1),Cz_luo_l);
    I_luo_mod_l=Ix_luo_mod_l+Iy_luo_mod_l+Iz_luo_mod_l;
    I_max_min_luo_mod=mutual_info_luo(size(displacement,1),C_max_min_luo);
    %}
    
    %the get_error function gives back the error for the strike and off
    %events, for each dimension. get_error3_with_plot returns the plot for
    %each file
    [Reve,Leve_r] = get_event(Ix_luo_mod_r,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
    [Reve_l,Leve] = get_event(Ix_luo_mod_l,sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE);
end
end