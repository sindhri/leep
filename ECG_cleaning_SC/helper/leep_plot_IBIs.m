function leep_plot_IBIs(IBI_vector, IBI_vector_clean, ...
    has_event, exclusion_vector, filename_plot_IBIs)

% display IBIs (so user can check whether there are any outliers

figure('units','normalized','outerposition',[0 0 1 1])    
title('displaying IBIS'); 
plot(IBI_vector,'*');
pause;
plot(IBI_vector_clean,'b*');
hold on;

% overlay events if the task is event related
if has_event == 1
    event_vector = zeros(length(IBI_vector),1);
   for i = 1:length(events)
       event_vector(events(i,1)) = events(i, 2);
   end

   plot(event_vector, '-k');
end

%plot exclusions
plot(exclusion_vector*25, 'r');


%plot mean and std lines
mIBI = mean(IBI_vector_clean);
stdIBI = std(IBI_vector_clean);
line([0,size(data,1)],[mIBI,mIBI],'Color','g');
line([0,size(data,1)],[mIBI-stdIBI*2,mIBI-stdIBI*2],'Color','g');
line([0,size(data,1)],[mIBI+stdIBI*2,mIBI+stdIBI*2],'Color','g');

saveas(gcf, filename_plot_IBIs);
close;

end