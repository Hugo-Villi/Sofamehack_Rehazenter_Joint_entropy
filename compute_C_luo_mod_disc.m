function proba_r_s_global=compute_C_luo_mod_disc(n,displacement,discretization,length_subsequence)
matrix_r_s_global=zeros(n-1,n-1,size(displacement,1));   %declare the matrix
disc=discretize(displacement,discretization);   %discretize the all markers and frames, gives back the interval in which the displacement is in
for k=length_subsequence:(size(displacement,1)-length_subsequence)  %loop for going through the frames 
    for j=(k-length_subsequence+1):k    %loop for going through the subsequence
        for i=1:size(disc,2)    %for going through markers
            matrix_r_s_global(disc(j,i),disc(j+length_subsequence,i),k)=...
                matrix_r_s_global(disc(j,i),disc(j+length_subsequence,i),k)+1;  %add a 1 at the corresponding position 
        end
    end
end
proba_r_s_global=matrix_r_s_global/(size(displacement,2)*length_subsequence);   %compute the global proba by divinding the sum made in the loop by the number of markers*length of the subsequence
end