%20201102, added time display in seconds
%20180604, Jia Wu changed line 28 to say 'right' instead of 'left' for
%removing existing marker
%20180809, jia added data_per_page

function mouseMoved (object, eventdata, subject_no,...
    startPlot, endPlot, data, highlight, seconds_per_page,...
    srate)

data_per_page = srate * seconds_per_page;

C = get (gca, 'CurrentPoint');
Xpos=round(C(1,1)); Ypos=C(1,2);

which=get(gcf, 'Selectiontype');
limits=ylim;
max_display_height=limits(2);
lowerbound=limits(1);



if C(1,2) > max_display_height-.3 % if we are in the slider bar zone
    title(gca, {['working on subject ' subject_no ' -- samples ' num2str(startPlot) ' to ' num2str(endPlot)],...
        [' -- seconds ' num2str(startPlot*1000/srate) ' to ' num2str(endPlot*1000/srate)];
        ['window length' seconds_per_page],...
        ['click to move to different data segment' ]});
    set(gcf,'Pointer','hand');
else

if Xpos>1 && Xpos<data_per_page % if we are in the range of the data
    
     % get a sum of the marker channel around the mousepoint
     vicLeft = Xpos+startPlot-25; 
     if vicLeft<1 
         vicLeft=1; 
     end 
     vicRight = Xpos+startPlot+25; 
     if vicRight>length(data) 
         vicRight=length(data); 
     end
     
     
     if Ypos>0 % if we are above the line
        vicinity_sum=sum(data(vicLeft:vicRight, 5)); % get vicinity sum from the combined channel (automated + manual markers)
        title(gca, {['working on subject ' subject_no ' -- samples ' num2str(startPlot) ' to ' num2str(endPlot)],...
            ['left mouse button: set a new marker -- right mouse button: remove existing marker' ]} );
     end
     
      if Ypos<0 % if we are below the line
        vicinity_sum=sum(data(vicLeft:vicRight, 4)); % get vicinity sum only from the manual channel
        title(gca, {['working on subject ' subject_no ' -- samples ' num2str(startPlot) ' to ' num2str(endPlot)],...
            ['left mouse button: recover the old marker when over it']} );
      end
      
   
      
      
     if ~vicinity_sum==0
        highlight=1;
        set(gcf,'Pointer','circle'); % turn mouse into circle to signal that we are on a pointer
    
     else
         
         set(gcf, 'Pointer', 'crosshair');
         highlight=0;
      
         
     end;
     
     if Ypos < (lowerbound+.7)
        set(gcf,'Pointer','arrow')
         title(gca, {['working on subject ' subject_no ' -- samples ' num2str(startPlot) ' to ' num2str(endPlot)],...
             ['left mouse button: exclude this second (will turn red); right mouse button: include this second (will turn green)']} );
     end
     
end;
end;


setappdata(1, 'highlight', highlight);
