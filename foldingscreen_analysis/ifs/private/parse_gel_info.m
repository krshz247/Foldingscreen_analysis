function [parsed_data, warnings] = parse_gel_info(filepath, log_file)
% @ step1 via compute_profiles
% parse the gel_info.txt file

    %% read line by line
    warnings = false;
    disp(filepath)
    fileID = fopen(filepath);
    tmp = textscan(fileID,'%s','CommentStyle','#', 'Delimiter', '\n');
    fclose(fileID);
    lines = tmp{1};
    parsed_data.filepath = filepath;
    parsed_data.log_file = log_file;
    
    logfile_ID = fopen(log_file,'a');
    fprintf(logfile_ID,'%s\n', ['Parsing file: ' filepath]);
    disp(['Parsing file: ' filepath])
    
    
    info = ["user", "project", "design_name", "date", "scaffold_type", "lattice_type", "tem_verified" ,"comment", "scaffold_concentration", "staple_concentration","comment", "Lane_" "Gelsize", "Agarose_concentration","Staining", "Mg_concentration" ,"Voltage", "Running_time","Cooling"];
    for i=1:length(lines)
        if ~isempty(lines{i}) % if line containes text, e.i. is not empty
            seg = split(lines{i}, {'=', ':'}); % split at = or :
            if length(seg)==1 % there was no = or : in the line
                disp(['Warning. Random line detected. It will be ignored. Check gel_info. Line: ' lines{i}])
                fprintf(logfile_ID,'%s\n', ['Warning. Random line detected. It will be ignored. Check gel_info. Line: ' lines{i}]);

                warnings = true;
            else
                index_comment = strfind(seg{2}, '#');
                if ~isempty(index_comment)
                    seg{2} = seg{2}(1:index_comment(1)-1); % remove all characters afer comment 
                end
                seg{2} = strtrim(seg{2});
            end
            
            
            key = strrep(seg{1}, ' ', '');
            
            if contains(key, "Lane_")
                l = str2num(erase(key, "Lane_"));
                key = "Lane_";
            end
            if  any (strcmpi (info, key))
                if any (strcmpi(["scaffold_concentration", "staple_concentration"], key))
                    parsed_data.(lower(key)) = str2num(strtrim(seg{2}));
                elseif key == "Lane_"
                    parsed_data.lanes{l} = strtrim(seg{2});
                else
                    parsed_data.(lower(key)) = strtrim(seg{2});
                end
            end  
        end
    end
    %disp(['File ' filepath ' parsed.'])
    
    %% go through lanes
    
    advanced = false;
    for i=1:length(parsed_data.lanes)
            %disp(parsed_data.lanes{i})
            if strcmp(parsed_data.lanes{i}(1), '{')
                advanced = true;
            end
    end
    %{
        if key_str(i) == "1kb" || key_str(i) == "ladder"
            index_list[index] = []
            parse.lanes.ladder = {parsed_data.lanes{index}}
            
        elseif key_str(i) == "scaf"
            parse.lanes.scaffold = {parsed_data.lanes{index}}
            index_list[index] = []
        else
            parse.lanes.mono = {parsed_data.lanes{index_list}}
        end
    end
    %}
    
    
    %{
    lanes = parsed_data.lanes
    for i=1:length(lanes)
        if contains(parsed_data.lanes, "1kb",'IgnoreCase',true) || contains(parsed_data.lanes{1}, "ladder",'IgnoreCase',true)
            parsed_data.species.ladder = lanes(i)
        elseif contains(parsed_data.lanes{1}, "scaf",'IgnoreCase',true)
            parsed_data.species.scaffold = lanes(i)
        else
            parsed_data.species.scaffold = lanes(i)
        end
    end
    %}
    
    if advanced
        parsed_data.lanes_unparsed = parsed_data.lanes; % save un-parsed data
        for i=1:length(parsed_data.lanes)
            %disp(parsed_data.lanes{i})
            if strcmp(parsed_data.lanes{i}(1), '{')
                tmp = strsplit(parsed_data.lanes{i}(2:end-1), ',');
                parsed_data.lanes{i} = tmp{1};
            end
        end
    end
    
    %put each lane into its catagory: (ladder, scaffold, mono)
    
    index_list = 1:length(parsed_data.lanes);  
    ladder_index = find(contains(parsed_data.lanes, "ladder"));
    scaff_index = find(contains(parsed_data.lanes, "scaff"));
    
    if ladder_index
        parsed_data.species.ladder = {parsed_data.lanes{ladder_index}};
        %index_list(ladder_index) = []
    end 
    
    if scaff_index
        parsed_data.species.scaffold = {parsed_data.lanes{scaff_index}};
        %index_list(scaff_index) = []
    end
    
    index_list([ladder_index scaff_index]) = [];
    parsed_data.species.mono = {parsed_data.lanes{index_list}};
    
    
   fclose(logfile_ID);

end








