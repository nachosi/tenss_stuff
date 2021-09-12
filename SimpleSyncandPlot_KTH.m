
% Hello Tenssies, This is a very tiny script for syncronizing Ephys and
% Tracking data and plotting the activity of a single neuron in relation to
% the position of the animal in space. 
%
%First of all, load the CleanNiceWorkspace

% Now let's see what we have here:

% SpikeTime (This is in milliseconds and corresponds to Ephys acquisition
% time)
%
% TimeMSFromStartTTLs (This is the time of the TTL in Ephys acquisition
% time)
%                      - These two things are syncronized by being recorded
%                      in the same equipment. The ephys system.
%
%
% FrameNumber  (This is Metadata from the camera, which tells us which is
% the number of frame taken by the camera)
%
% CameraTTLFrameNumber (This is preprocessed metadata of which Frames have
% the onset of the TTL)
%
% X (X position from tracking the head of the animal for each frame)
% Y (Y position)
% HeadDirection (HeadDirection of the animal, from tracking)
%
%
%                      - These data are syncronized to each other in that
%                      there is a frame 2 frame correspondence between
%                      them. 
%                      - However, they do need to be syncronized to the
%                      ephys data.

%% load data

load('c:\_Data\Code_and_data_analysis\Matlab\_addtoolboxes\spike_analysis\GridandHD\CleanNiceWorkspace.mat')

% CameraTTLFrameNumber			numbers    of camera frames that contained a TTL
% CameraFrameTimeinEphysTime	ephys time of camera frames that contained a TTL

% FrameNumber					all camera frames


% X, Y							position of animal

%% Lets start by looking at the TTL's and counting them
figure;
subplot(2,2,1)
plot(TimeMSFromStartTTLs, 'ok')

title( ['TTLs in ephys = ' num2str(numel(TimeMSFromStartTTLs))])
%% Lets look at the ones from the camera
subplot(2,2,2)
plot(CameraTTLFrameNumber,'or')
title( ['TTLs in Camera = ' num2str(numel(CameraTTLFrameNumber))])

%% Are they linearly related? 
subplot(2,2,3)
plot( CameraTTLFrameNumber, TimeMSFromStartTTLs ,'og')
hold on

%% To syncronize we will interpolate the rest of the Frames based on the frame number of the TTL, the frame number of each frame, and the 
% TTL time from the ephys, this will give us a FrameTime in Ephys time
CameraFrameTimeinEphysTime=interp1(CameraTTLFrameNumber, TimeMSFromStartTTLs, FrameNumber , 'linear', 'extrap' );
%									no of frame			 time of frame,        each frame

%% Lets plot all these camera frame times and see if the times are in the same range as the SPike times 

subplot(2,2,1)
hold on
plot(CameraFrameTimeinEphysTime, '.g')

subplot(2,2,4)

plot(CameraFrameTimeinEphysTime, '.g')
hold on
plot(SpikeTime, '.k')
%% Lets change the name of the frame times to make it easier, lets call it T 
T=CameraFrameTimeinEphysTime;
%% Now that the Frames are syncronized, lets look a bit at the behavioral variables , lets plot X and Y against time
figure;

subplot(2,2,1:2)
plot(T,X, '-m')
hold on
plot(T,Y, '-c')
ylabel('positon (cm)')
xlabel('Time (ms)')
%% Now , lets superimpose the Spike Times
plot(SpikeTime, 0, '+k') 
%% Nice! Ok we have the spiketimes, and the frame times, and the tracked  position for each frame. Lets figure out now
% at what position the animal was in, every time the neuron spiked. To do
% this we will interpolate linearly again. This time we use the
% correspondance between T and (X,Y) to figure out the SpikeX, and Spike Y
% according to the SpikeTime
SpikeX=interp1(T, X, SpikeTime, 'linear', 'extrap');
SpikeY=interp1(T, Y, SpikeTime, 'linear', 'extrap');

%% Easy, now we plot in the same space.
plot(SpikeTime,SpikeX, 'or')
plot(SpikeTime,SpikeY, 'ob')
%% Cool! looks interesting, it doesn't look very random , but from this plot its not evident that the cell Fires at specific X or Y values
% So, lets plot the trayectory of the animal and the spike positions in 2D space
subplot(2,2,3)

plot(X,Y, '-k')
axis square
hold on 
plot(SpikeX, SpikeY, '.r', 'MarkerSize',10)

%Surprise! Here I'am.  i'm the most beautiful cell in the brain. FIGHT ME!



%% Ok, it definitely looks like a grid cell, but It also could be that weirdly the animal spends most of his time in these very specific regions of space, 
% and that what we see is an artifact of a weird behavior and a constantly
% firing cell. 

% Soooo,  lets plot the Rate of the cell in space.
%
% To do this we need 2 histograms 1 ) of the amount of spikes in every bin
% in space
% 2) Of the amount of time spent by the animal in each bin of space

% spike count histogram
% &
% occupance histogram

% We define the bins
Xbins=-50:2.5:50;
Ybins=-50:2.5:50;

figure;
subplot(2,2,1);
SpikeCount=My2DHistogram(SpikeX, SpikeY, Xbins, Ybins, 0); % this function does a 2D histogram of the spikes for the bins defined
imagesc(flipud(SpikeCount')) ;%weird turning and plotting
axis square
title('SpikeCount');

%%  Now lets do a histogram of Coverage, how many frames was the rat in for in each bin.
subplot(2,2,2);
CoverageCount=My2DHistogram(X, Y, Xbins, Ybins,0);
imagesc(flipud(CoverageCount'));
axis square
title('CoverageCount')


%% Now lets calculate the Rate,    Rate = numberSpikes./TimeSpent  ,  The TimeSpent=CoverageCount x InterFrameInterval

Interval=(median(diff(T))/1000); %must be in seconds so that result of Rate is in Hz.
Rate=SpikeCount./(CoverageCount*Interval);

subplot(2,2,3)
imagesc(flipud(Rate'))
axis square
title('Rate (hz) ')
colorbar

% Nice that RateMap clearly show its a Grid cell!

%% However does it have the hexagonal grid shape Grid cells are famous for? For this we will do an autocorrelation 
% We will correlate the map to a shifted version of itself, if, the
% periodicity and hexagonality are there we should see a nice periodic
% hexagonal pattern
autocorrGrid=Cross_Correlation(Rate,Rate);

subplot(2,2,4)

imagesc(flipud(autocorrGrid'))
axis square
title('Autocorrelation ')
colorbar


%Thats it! Hope that was easy and will help you lot eventually syncronize
%and plot your own cells at the end of the school!

% Nacho (2019) - Berlin