function [index_best] = get_best_folding(profileData, gelInfo)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


figure(2)
    subplot(4, 1, 1)
    height_width = zeros(length(profileData.profiles),1);
    width = zeros(length(profileData.profiles),1);
    for i=1:length(profileData.profiles)
        height_width(i) = profileData.monomerFits{i}.a1/profileData.monomerFits{i}.c1;
        width(i) = profileData.monomerFits{i}.c1;
    end
    plot(height_width, '.-')
    xlabel('Lane')
    ylabel('Height/width')
    set(gca, 'XTick', [1:length(profileData.profiles) ] )

    %subplot(4,1,2)
    %plot(profileData.monomerTotal, '.-')
    %xlabel('Lane')
    %ylabel('monomer absolute')
    %set(gca, 'XTick', [1:length(profileData.profiles) ] )

    subplot(4,1,2)
    plot(width, '.-')
    xlabel('Lane')
    ylabel('Width')
    set(gca, 'XTick', [1:length(profileData.profiles) ], 'XTickLabels', gelInfo.lanes)

    subplot(4,1,3)
    plot(profileData.monomerTotal./(profileData.monomerTotal+profileData.pocketTotal+profileData.smearTotal), '.-')
    xlabel('Lane')
    ylabel('monomer/(monomer+pocket+smear)')
    set(gca, 'XTick', [1:length(profileData.profiles) ], 'XTickLabels', gelInfo.lanes)
    
    %subplot(4,1,4)
    %mig_distance = zeros(length(profileData.profiles),1);
    %for i=1:length(profileData.profiles)
    %    mig_distance(i) = profileData.monomerFits{i}.b1-profileData.aggregateFit.b1;
    %end
    %plot(mig_distance, '.-')
    %xlabel('Lane')
    %ylabel('Migration distance (pocket to monomer) [px]')
    %set(gca, 'XTick', [1:length(profileData.profiles) ] )
    
    subplot(4,1,4)
    plot(profileData.monomerTotal./(profileData.monomerTotal+profileData.pocketTotal+profileData.smearTotal)./width, '.-')
    xlabel('Lane')
    ylabel('monomer/(monomer+pocket+smear)/width')
    set(gca, 'XTick', [1:length(profileData.profiles) ], 'XTickLabels', gelInfo.lanes)
    
    
    
    height_width = zeros(length(profileData.profiles),1);
    for i=1:length(profileData.profiles)
        height_width(i) = profileData.monomerFits{i}.a1/profileData.monomerFits{i}.c1;
    end
    
    % T-screen indices
    for i=1:length(gelInfo.lanes)
        cur_name = strtrim(gelInfo.lanes{i});
        if strcmpi(cur_name(1), 'T')
            index_Tscrn(str2num(cur_name(2))) = i;
        end
    end
    % Mg-screen indices
    for i=1:length(gelInfo.lanes)
        cur_name = strtrim(gelInfo.lanes{i});
        if strcmpi(cur_name, 'M5')
            index_Mgscrn(1) = i;
        end
        if strcmpi(cur_name, 'M10')
            index_Mgscrn(2) = i;
        end
        if strcmpi(cur_name, 'M15')
            index_Mgscrn(3) = i;
        end
        if strcmpi(cur_name, 'M20')
            index_Mgscrn(4) = i;
        end
        if strcmpi(cur_name, 'M25')
            index_Mgscrn(5) = i;
        end
        if strcmpi(cur_name, 'M30')
            index_Mgscrn(6) = i;
        end
    end
            
    % RM indices
    for i=1:length(gelInfo.lanes)
        cur_name = strtrim(gelInfo.lanes{i});
        if strcmpi(cur_name, 'RM1')
            index_RM(1) = i;
        end
        if strcmpi(cur_name, 'RM1_diluted')
            index_RM(1) = i;
        end
        if strcmpi(cur_name, 'RM2')
            index_RM(2) = i;
        end
    end 
    % all indices except for scaffold and ladder
    index_foldings = [];
    for i=1:length(gelInfo.lanes)
        cur_name = strtrim(gelInfo.lanes{i});
        if strcmpi(cur_name, 'scaffold') || strcmpi(cur_name, '1kb_ladder') || contains(cur_name,'ladder','IgnoreCase',true)
            
        else
            index_foldings = [index_foldings, i];
        end
    end 
    
   % get_ranking(height_width(index_Tscrn))
   % get_ranking(height_width(index_Mgscrn))
   % get_ranking(height_width(index_RM))
   % get_ranking(height_width([index_Tscrn index_Mgscrn index_RM]))

   indicator = profileData.monomerTotal./(profileData.monomerTotal+profileData.pocketTotal+profileData.smearTotal)./width;
   [~, i_sort] = sort(indicator(index_foldings), 'descend');
   index_best = index_foldings(i_sort(1));
   disp(['Best folding ' gelInfo.lanes{index_best}])
    %get_ranking(height_width(index_foldings))
    
    
end

