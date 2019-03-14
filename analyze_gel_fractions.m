function profileData = analyze_gel_fractions(profileData,gelData)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    sigma_integrate = 2;
    peaks_ok='No';
    while strcmp(peaks_ok,'No')
        % select are for pockets
        plot_image_ui(gelData.images{1});
        title('Select the pockets')

        h = imrect;
        wait(h);
        selectedPocketArea = int32(getPosition(h));
        close all
        %sum 

        %% compute sum profiles and fit it with gaussian
        %close all
        %cf = figure();
        fits = cell(length(profileData.profiles),1);
        profile_sum = zeros(selectedPocketArea(4)+1,1);

        for i=1:length(profileData.profiles)
            profile_sum = profile_sum + profileData.fullProfiles{i}(selectedPocketArea(2):selectedPocketArea(2)+selectedPocketArea(4));
        end

        x = double(selectedPocketArea(2):selectedPocketArea(2)+selectedPocketArea(4));
        pocket_fit = fit(x', profile_sum, 'gauss1');
       
        %clf
        %plot(x, profile_sum), hold on
        %plot(x, pocket_fit(x))
        % integrate pockets

        %% select area for monomer band
        plot_image_ui(gelData.images{1});
        title('Select monomer bands')
        h = imrect;
        wait(h);
        selectedArea = int32(getPosition(h));
        close all

        %%
        %cf = figure();
        fits = cell(length(profileData.profiles),1);
        tmp = zeros(2, length(profileData.profiles));
        for i=1:length(profileData.profiles)
            %figure

            tmp(i,:) = max(profileData.fullProfiles{i}(selectedArea(2):selectedArea(2)+selectedArea(4)));

            y = profileData.fullProfiles{i}(selectedArea(2):selectedArea(2)+selectedArea(4));
            x = double(selectedArea(2):selectedArea(2)+selectedArea(4));

            fits{i} = fit(x', y, 'gauss1', 'Lower', [0 selectedArea(2) 0], 'Upper', [Inf selectedArea(2)+selectedArea(4) +selectedArea(4)]);
            %clf
            %plot(x, y), hold on
            %plot(x, fits{i}(x))

        end  

        
        
        %% Display results and aks if ok
        close all
        figure(1)
        imagesc(gelData.images{1}, [0 3.*std(gelData.images{1}(:))]), axis image, colormap gray, hold on
        % plot pocket fits
        for i=1:length(profileData.profiles)
            plot(mean(profileData.lanePositions(i,1:2)), pocket_fit.b1, 'r.')
            plot(mean(profileData.lanePositions(i,1:2))*[1 1], [pocket_fit.b1-sigma_integrate*pocket_fit.c1 pocket_fit.b1+sigma_integrate*pocket_fit.c1], 'r')
        end

        % plot leading band fits
        for i=1:length(profileData.profiles)
            plot(mean(profileData.lanePositions(i,1:2)), fits{i}.b1, 'r.')
            plot(mean(profileData.lanePositions(i,1:2))*[1 1], [fits{i}.b1-sigma_integrate*fits{i}.c1 fits{i}.b1+sigma_integrate*fits{i}.c1], 'r')
        end
    
        peaks_ok = questdlg('Are the found peaks ok?','Peaks found?' ,'No','Yes', 'Yes');
        
        
        
        %keyboard
        %%
        profileData.aggregateFit = pocket_fit;
        profileData.aggregateSelectedArea = selectedPocketArea;
        profileData.monomerFits = fits;
        profileData.monomerSelectedArea = selectedArea;
        
        

        %close all
    end

end

