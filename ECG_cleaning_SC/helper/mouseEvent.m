%jia added data_per_page
function mouseEvent (object, eventdata, startPlot, endPlot, data, slider_x,data_per_page)

C = get (gca, 'CurrentPoint');
Xpos=round(C(1,1)); Ypos=C(1,2);

which=get(gcf, 'Selectiontype');

% determine maximal height in the current display
limits=ylim;
max_display_height=limits(2);
lowerbound=limits(1);

%title(gca, ['CLICKED! (X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ') with ', which '  startPlot '  num2str(startPlot)]);

mark=0; signum=0; selectsquare=-999; selectBit = 0;
% when we are in the top of the display, when the mouse is clicked:
if C(1,2) > max_display_height-.3;
    
    title(gca, ['moving window frame']);
    
    switch which 
        case 'normal'    
            if Xpos>slider_x; startPlot=startPlot+data_per_page; endPlot=endPlot+data_per_page; end; 
            if Xpos<slider_x; startPlot=startPlot-data_per_page; endPlot=endPlot-data_per_page; end; 
        case 'alt'
            %startPlot=round(Xpos/10000)*length(data); endPlot=startPlot+10000;
    end
    
    % take care that the sliding frame never moves out of the data
    if startPlot < 1; startPlot=1; endPlot=data_per_page; end;
    if endPlot > length(data); endPlot=length(data); startPlot=length(data)-data_per_page; end;
    

else 
    % meaning we are somewhere else - in the graphical window -
    % then we want to mark / unmark 
    
    % these are the points within the our circle (to be used for vicinity
    % sum)
    vicLeft = Xpos+startPlot-25; if vicLeft<1; vicLeft=1; end; 
    vicRight = Xpos+startPlot+25; if vicRight>length(data); vicRight=length(data); end;
    
            
    if Ypos>0 % we are above the line
        if strcmp(which, 'normal') && Xpos > 1 && Xpos<data_per_page% left clicking sets a mark
            vicinity_sum=sum(data(vicLeft:vicRight, 5));
            % but only if the next marker has a sufficinet distance of at
            % least 25 samples
            if vicinity_sum==0; mark=Xpos+startPlot; signum=1; end;  
        end

        if strcmp(which, 'alt') % left clicking removes a marker...
            % ...in case we are on a marker
            vicinity_sum=sum(data(vicLeft:vicRight, 5));
            mpos=find( data(vicLeft:vicRight, 5)~=0)+Xpos-25+startPlot-1;
            if vicinity_sum>0;  mark=mpos; signum=-1; end;
        end
      
    end
    
    
    if Ypos<0 % we are below the line
        
     if Ypos < (lowerbound+.7) % we are on the lower bar --> we are doing selection/unselection of data
     
          if strcmp(which, 'normal');             selectsquare=Xpos; selectBit=1; end; % left mouse button always selects
          if strcmp(which, 'alt');                selectsquare=Xpos; selectBit=0; end;  % right mouse button always unselects (marked by negative signum)
          
          
     
     else
        
            if strcmp(which, 'normal') % left clicking rehabilitates a marker
                % ...in case we are on a deleted marker
                vicinity_sum=sum(data(vicLeft:vicRight, 4));
                mpos=find( data(vicLeft:vicRight, 4)<0)+Xpos-25+startPlot-1;
                if vicinity_sum<0; 
                    mark=mpos; signum=0;
                end;
            end

     end
    end
   
    
end

setappdata(0, 'startPlot', startPlot);
setappdata(0, 'endPlot', endPlot);
setappdata(0, 'mark', mark);
setappdata(0, 'signum', signum);
setappdata(0, 'selectsquare', selectsquare);
setappdata(0, 'selectBit', selectBit);

