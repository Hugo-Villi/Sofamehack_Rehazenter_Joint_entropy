function [Reve,Leve] = get_event(I,size_sweep,PeakHeight,PeakDistance,PeakProeminence,strike_off_choice,X_RTOE,X_LTOE)
Reve=[];
Leve=[];
locs=[];
I_to_plot=I(1+size_sweep:size(I,2)-size_sweep); %the subsequences reduce the size of the curve
temp_I_max=max(I_to_plot);  %get the maximum value
temp_I_min=min(I_to_plot);  %get the minimum value
peak_proeminence=abs((temp_I_max-temp_I_min)/(mean(I_to_plot)*PeakProeminence));    %compute the value of the minimal proeminence of the peak
[~,locs]=findpeaks(I,'MinPeakHeight',mean(I_to_plot)*PeakHeight,...
    'MinPeakDistance',PeakDistance,'MinPeakProminence',peak_proeminence);   %only get the index of the peaks, i.e. the frame of the peak
j=1;
k=1;
if isempty(locs)~=1 %does not enter the loop unless peaks had been identified
    if strike_off_choice==1 %this settings is used to choose between the identification of strike or off events
        for i=1:size(locs,2)   %loop for the number of peak
            if X_RTOE(locs(i))>X_LTOE(locs(i))  %if the right toes are in front of the left toes, the peak is identified as a right foot strike
                Reve(j)=locs(i);
                j=j+1;
            else
                Leve(k)=locs(i);    %same for the left foot
                k=k+1;
            end
        end
    else
        for i=1:size(locs,2)
            if X_RTOE(locs(i))<X_LTOE(locs(i))
                Reve(j)=locs(i);    %the opposite is made for toe off: if the right toes are behind the left toes, the peak is identifed as a right foot off
                j=j+1;
            else
                Leve(k)=locs(i);
                k=k+1;
            end
        end
    end
end
if isempty(Leve)==1 %gave back a false event in case nothing is detected to avoid crashes
    Leve=round(size(I,2)/2);
end
if isempty(Reve)==1
    Reve=round(size(I,2)/2);
end 
end