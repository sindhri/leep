% Lossless event-related ECG pipleline (LEEP)
% A cleaned-up version of the heart rate inspection scripts originally
% developed by Dr. Boris Bornemann (Max Planck Insitute for Human Cognitive and
% Brain Sciences) 
% Modified and cleaned up by Jia Wu and Michael Crowley Yale Child Study Center

function leep(srate, subject_no, task, has_event, to_plot_ECG, to_plot_IBI)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. specify different input options
if nargin == 0
    srate = 250; %default to 250Hz
end

% manually select a ECG text file to process
if nargin<=1 
    [filename_data, pathname_data] = uigetfile('*.txt','select HR text file','txt');
    fprintf('processing %s\n',filename_data);
    all_fileseps = find(pathname_data == filesep);
    pathname_project = pathname_data(1:all_fileseps(length(all_fileseps)-1));
    pathname_help = [pathname_data(1:all_fileseps(length(all_fileseps)-2)) 'helper' filesep];
    first_underscore = find(filename_data == '_',1);
    subject_no = filename_data(first_underscore+1:first_underscore+4);
    task = filename_data(1:first_underscore-1);    
end

if nargin<6
   if exist([pathname_project 'events' filesep],'dir') ==7
        has_event = 1;
    else
        has_event = 0;
   end
    to_plot_ECG = 1; % default to plot ECG
    to_plot_IBI = 1; % default to plot IBI
end

% use the path of 'leep.m' to locate the project path and data path
if nargin>=3
    pathname_current = [fileparts(which('leep.m')) filesep];
    pathname_help = [pathname_current 'helper' filesep];
    pathname_project = [pathname_current task filesep];
    pathname_data = [pathname_project 'data' filesep];
    filename_data = [task '_' subject_no '.txt'];
end
% add path to the helper files
addpath(pathname_help);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Set up output folders
folder_group = {'IBIs',...
        'IBIs_with_latencies',...
        'manualMarks',...
        'plot_markers'};
% for event related, export IBI and dp around the events
if has_event == 1
    folder_group{5} = 'results_IBI';
    folder_group{6} = 'results_dp';
end
% for gofigure, export anticipation
if strcmp(task, 'gofigure')
    folder_group{7} = 'results_IBI_include_anticipation';
    folder_group{8} = 'results_dp_include_anticipation';
end
% for cyberball, split the IBI from fairplay in 2
if strcmp(task, 'cyberball')
    folder_group{7} = 'IBIs_split';
end
% make the output folders
folder_group_names = cell(1);
for i = 1:length(folder_group)
    folder_group_names{i} = [pathname_project 'processed' filesep folder_group{i} filesep];
    if exist(folder_group_names{i},'dir') ~=7
       mkdir(folder_group_names{i});
    end
end

% Set up some parameters for event related
if has_event == 1
    preevent_seconds = 2; % default to look 2 seconds before the event
    postevent_seconds = 4; % default to look at 4 seconds after the event
    preevent_dp = srate * preevent_seconds;
    postevent_dp = srate * postevent_seconds;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. import the data of given subject, calculate the peaks
data_raw = dlmread([pathname_data, filename_data]); %n x 1 dimension

% smooth the data and caulate peaks_auto based on smoothed data but
% adjusted by raw data
[data_smoothed, peaks_auto, minh]=leep_find_peaks(data_raw, srate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Get manually marked channels and exclusions
% load previously makred channels and exclusions if they exist
% option of plotting ECG and do further adjustment
filename_markers = [folder_group_names{3} 'marks_' task '_' subject_no '.mat'];
filename_exclusions = [folder_group_names{3} 'exclusions_' task '_' subject_no '.mat'];

if to_plot_ECG ==1    
    [peaks_manual, exclusions] = leep_manual_inspection(subject_no, ...
        data_smoothed, data_raw, srate, peaks_auto, minh,...
        filename_markers, filename_exclusions);
else
    [peaks_manual, exclusions] = leep_get_marker_exclusion(filename_markers,...
        filename_exclusions, size(data,1), srate);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%5. Update exclusion and peaks based on peaks_manual and exclusions
% calculate IBIs and write to output files
exclusion_vector = leep_get_exclusion_vector(exclusions, srate, size(data,1));
peaks_clean = leep_get_peaks_clean(exclusion_vector,...
    peaks_auto, peaks_manual);

% calculate IBIs and write to IBI files
filename_IBIs = [folder_group_names{1} 'IBIs_' subject_no '_' task '.txt'];
filename_IBIs_with_latency = [folder_group_names{2} 'IBIs_latency' subject_no '_' task '.txt'];

[IBIs_with_latency, IBI_vector_clean] = leep_get_IBIs(data_smoothed, peaks_clean, ...
    exclusion_vector, filename_IBIs, filename_IBIs_with_latency);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Event related
% read the event file, 
% events: first column offset, second column coulbourn marker
if has_event == 1
    event_file = [pathname_events task '_' subject_no '_event.txt'];
    events = dlmread(event_file);

    leep_output_results_dp(IBI_vector_clean, ...
        events, preevent_dp, postevent_dp, folder_group_names{6});
end

% Some special event related cases
% export results_dp for gofigure anticipation
if strcmp(task, 'gofigure')
    filename_anticipation = [folder_group_names{8} 'results2_' subject_no '_' task '.txt'];

    anticipation_preevent_dp = srate*5; %5s baseline before stim onset
    leep_output_results_dp(IBI_vector_clean, ...
        events, anticipation_preevent_dp, postevent_dp,...
        filename_anticipation);
        
    filename_anticipation = [folder_group_names{7} 'results_' subject_no '_' task '.txt'];

    anticipation_preevent_IBI = 6; %5s baseline before stim onset
        
    leep_output_results_IBI(events, subject_id,...
       anticipation_preevent_IBI, postevent_IBI, IBI_vector, exclusion_vector,...
       filename_anticipation);
end

if strcmp(task, 'cyberball')==1
    pathname_IBIs_split = folder_group_names{7};
    event_process_cyberball(events, IBIs_with_latency,...
        pathname_IBIs_split);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%7. plot IBI if needed
if to_plot_IBI == 1
    filename_plot_markers = [folder_group_names{4} 'plot_markers_' task '_' subject_no '.png'];
    
    leep_plot_IBIs(IBI_vector, IBI_vector_clean, has_event,...
        exclusion_vector,filename_plot_markers)
end

end