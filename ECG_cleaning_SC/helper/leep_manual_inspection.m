% use manual inspection to update the manual peaks and exclusions
% input smoothed data, peaks and markers

function [peaks_manual, exclusions] = leep_manual_inspection(subject_no,...
    data_smoothed, data_raw, srate, peaks_auto, minh, filename_markers,...
    filename_exclusions)
    
    n_dpt = length(data_raw);
    
    finished_marker_editing = 0;    
    seconds_per_page = 40;
    data_per_page = srate*seconds_per_page;
    highlight = 500; 
    signum = 0;
    
    % initiaze startPlot and endPlot
    startPlot = 1;
    endPlot = data_per_page;
    
    % initialzing some variables ???
    slider_x = (endPlot/n_dpt) * data_per_page;
    
    % get the previous marked peaks and exclusions
    % removed peak is marked -1, nopeak is marked 0    
    [peaks_manual, exclusions] = leep_get_marker_exclusion(filename_markers,...
    filename_exclusions, n_dpt, srate);

    disabled_line(1:seconds_per_page) = exclusions(round(startPlot/srate)+1:round(endPlot/srate));  

    % update the peaks
    peaks_combined = peaks_auto + peaks_manual;

    % Get rid of all the application data that might still be saved
    % somewhere:
    appdata = get(0,'ApplicationData');
    fns = fieldnames(appdata);
    for ii = 1:numel(fns)
        rmappdata(0,fns{ii});
    end
    
    % create the plotting window
    figure('units','normalized','outerposition',[0 0 1 1]);
    while ~finished_marker_editing % main loop

        %   refer to mouse operation functions
        set(gcf, 'Pointer', 'crosshair');
        set (gcf, 'WindowButtonDownFcn', {@mouseEvent, startPlot, endPlot, data_smoothed, slider_x,data_per_page});
        set (gcf, 'WindowButtonMotionFcn', {@mouseMoved, subject_no, startPlot, endPlot, data_smoothed, highlight, seconds_per_page, srate});
        highlight = getappdata(1, 'highlight');
        signum = getappdata(0, 'signum');
        mark = getappdata(0, 'mark');
        
        % adjust the manual insert to the highest local peak (-10 to +10
        % samples)

        if mark > 0 & signum == 1
            highestspot = data_raw(mark);
            divergence = 0;
            for j = -10:10
                if data_raw(mark+j) > highestspot
                    highestspot = data_raw(mark+j); divergence=j; 
                end
            end
            mark = mark + divergence;

        end

        if mark > 0
           peaks_manual(mark) = signum; 
           peaks_combined(mark) = peaks_auto(mark) + peaks_manual(mark); 
        end
        
        % update disabled_line for the current page
        % resolution of disabled_line is 1 second
        selectsquare = getappdata(0, 'selectsquare');
        selectBit = getappdata(0, 'selectBit');

        if selectsquare > 0 & selectsquare < data_per_page
            exclusions(round(startPlot/srate) + floor(selectsquare/srate)+1) = selectBit;
            disabled_line(1:seconds_per_page) = exclusions(round(startPlot/srate)+1:round(endPlot/srate));
        end

        % plot data
        plot(data_smoothed(startPlot:endPlot , 1)); 
        hold on;
        % plot a comined channel (manual marks + automated marks)

        plot(peaks_combined(startPlot:endPlot) * minh, 'k', 'LineWidth', 3);
        % plot manual marks % why not *minh?
        plot(peaks_manual(startPlot:endPlot), 'r', 'LineWidth', 3);

        % display a rectangle on top of display 
        % to show which point of the data we are at
        yl = ylim;
        lowerbound = yl(1);
        maxHeight = yl(2);
        slider_x = (endPlot/n_dpt) * data_per_page;
        fullslider = rectangle('Position',...
            [1, maxHeight-.3, data_per_page, .3],...
            'FaceColor',[.5 .5 .5]);
        r= rectangle('Position',...
            [slider_x, maxHeight-.3, 100, .3],...
            'FaceColor',[0 .5 .5], 'EdgeColor','b',...
            'LineWidth',3);

        % display a collection of seconds_per_page seconds at the bottom 
        % which show
        % whether a section is included (green) or excluded from data
        % analysis
        b = rectangle('Position',...
            [1,lowerbound+.3,data_per_page,.3],...
            'FaceColor',[0 .3 0]);
        for i = 1:seconds_per_page
            if disabled_line(i)==1
                small = rectangle('Position',...
                    [1 + (i-1)*srate,lowerbound+.3, srate,.3],...
                    'FaceColor',[1 0 0]);
            end
        end

        hold off;

        w=waitforbuttonpress;
        currkey=get(gcf,'CurrentKey');

        % if it is a keyboard press and "Return" is pressed
        if w == 1 && strcmp(currkey, 'return') 

            % if it is not the end of the file
            if endPlot < n_dpt
                answer = questdlg('You have not reached the end of the data yet.', ...
                    'Gate to IBI view', ...
                    'Proceed anyway','Resume marker editing', 'Resume marker editing');

                if strcmp(answer,'Proceed anyway')
                    finished_marker_editing = 1;
                    %disabled_line(1:seconds_per_page) = exclusions(round(startPlot/srate)+1:round(endPlot/srate));
                end
            % end of file
            else
                finished_marker_editing = 1;
                %disabled_line(1:seconds_per_page) = exclusions(round(startPlot/srate)+1:round(endPlot/srate));
            end

        elseif w == 0 % mousepress
            % update to the next page
            startPlot = getappdata(0, 'startPlot');
            endPlot = getappdata(0, 'endPlot');
            disabled_line(1:seconds_per_page) = exclusions(round(startPlot/srate)+1:round(endPlot/srate));  
            %  get the exclusions for the actual data
            %jia commented, not able to exclude the last bit of data in some cases
            %due to the usage of 'round'. however no useful data is intended
        end

    end % of marker editing loop loop
    hold off;
    close;

    % save markers to file
    save(filename_markers,'peaks_manual');

    % save exclusions to file
    save(filename_exclusions,'exclusions');

end