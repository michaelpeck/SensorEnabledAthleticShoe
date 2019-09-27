Importing sensor data
% Call accelerometer file
accelerometer = readtable('Walk3_accelerometer.csv')

% Create array of y-acceleration over time
YA = table2array(accelerometer(2:end,5));

% Create parallel time array
time = table2array(accelerometer(2:end,3));

Plotting values
% Acceleration in y vs time
%   Note: This is data from a session jogging at a relatively constant
%   speed around a block. Flat periods at the beginning and near the end
%   were spent standing.

plot(time,YA);
title('y-Acceleration vs time');
xlabel('Time(s)');
ylabel('y-Acceleration');

% Zoomed version (Method for easily shifting zoomed region

zoomYA = [];    % Establish empty array for zoom YA
zoomTime = [];  % Establish empty array for zoom t

for i = round(length(time)/2):round(length(time)/1.9)
    zoomYA = [zoomYA, YA(i)];
    zoomTime = [zoomTime, time(i)];
end

plot(zoomTime,zoomYA);
title('y-Acceleration vs time [zoomed]')
xlabel('Time(s)');
ylabel('y-Acceleration');
Finding Peaks and Valleys in y-Acceleration
% Loop through all y-acceleration data to find peaks and valleys
%   Note: I use this instead of findpeaks(data) in order to eliminate arbitrary
%   peaks. By adding the second line in each if statement (with the abs()
%   functions) we ensure that peaks that are miniscule in comparison with a
%   steps acceleration are filtered out.

YApeak=[]; % Empty array for peaks
YAval=[];  % Empty array for valleys

for i = 5:(length(YA)-100)
    if YA(i)>YA(i-1) && YA(i)>YA(i+1) && YA(i)>YA(i-2) && YA(i)>YA(i+2) && YA(i)>YA(i-3) && YA(i)>YA(i+3) ...
            && abs(YA(i)-YA(i-2))>0.02 && abs(YA(i)-YA(i+2))>0.02 && abs(YA(i)-YA(i-3))>0.05 && abs(YA(i)-YA(i+3))>0.05
        YApeak=[YApeak,i]; % Tack entry # of any qualifying peaks to the end of this array
    elseif  YA(i)<=YA(i-1) && YA(i)<YA(i+1) && YA(i)<=YA(i-2) && YA(i)<YA(i+2) && YA(i)<=YA(i-3) && YA(i)<YA(i+3)...
            && abs(YA(i)-YA(i-2))>0.02 && abs(YA(i)-YA(i-3))>0.03
        YAval=[YAval,i]; % Tack entry # of any qualifying valleys to the end of this array
    end
end

% Print for testing
YApeak = YApeak % Place in the y-acceleration array where a peak occurs
YAval = YAval   % Place in the y-acceleration array where a valley occurs

% Plot first 20 YA at peaks and valleys
for i = 1:20
    j=YApeak(i);
    q=dYAval(i);
    plot(time(j),YA(j),'ro')    % Peaks are red circles
    hold on
    plot(time(q),YA(q),'bx')    % Valleys are blue xs
    hold on
end
hold off

title('y-Acceleration Peaks and Valleys')
xlabel('Time(s)')
ylabel('Acceleration(m/s^2?)')


Trim Out Irrelevant Peaks and Valleys
% Make sure we start with a valley
%   Note: For the given sensor orientation, there is always a valley at the
%   beginning of every step. As a result, the first recorded step must
%   start with a valley.
while YAval(1)>YApeak(1)
    YApeak(1)=[];
end

% Delete values of consecutive peaks
%   Note: From any given peak, if the next extreme is another peak rather
%   than a valley, delete the smaller of the two peaks.

leq = min(length(YAval),length(YApeak)); %Limiting factor in following for loops [lesser extreme quantity]
for i=1:(leq-1)
    if abs(YApeak(i)-YApeak(i+1))<abs(YApeak(i)-YAval(i+1))
        if YApeak(i)>YApeak(i+1)
            YApeak(i+1)=[];
        else
            YApeak(i)=[];
        end
    end
end

% Delete values of consecutive valleys
%   Note: From any given valley, if the next extreme is another valley rather
%   than a peak, delete the smaller of the two valleys.

leq = min(length(YAval),length(YApeak)); %Re-establish limiting factor
for i=1:(leq-2)
    if abs(YAval(i)-YAval(i+1))<abs(YAval(i)-YApeak(i))
        if YAval(i)>YAval(i+1)
            YAval(i+1)=[];
        else
            YAval(i)=[];
        end
    end
end

leq = min(length(YAval),length(YApeak)); %Re-establish limiting factor

% Break up extremes into steps
%   Note: Here, a ?x5 matrix will be populated with the step count followed
%   by the timestamps from valley one(vo), peak one(po), valley two(vt), and
%   peak two(pt) of the foot from which this data was taken. Keep in mind
%   that the progression of each 'step' includes strides by both the right
%   and the left feet.

rCycle=zeros(1,5);   % Establishing right cycle matrix
rCycleCount=1;        % Start cycle count

for i=1:2:(leq-2) % Cycle through the data in twos to collect the pair of each in each cycle.
    vo=YAval(i);
    po=YApeak(i);
    vt=YAval(i+1);
    pt=YApeak(i+1);

    % rCycle array populated as a separate cycle for visualization
    rCycle(rCycleCount,1)=rCycleCount;
    rCycle(rCycleCount,2)=time(vo);
    rCycle(rCycleCount,3)=time(po);
    rCycle(rCycleCount,4)=time(vt);
    rCycle(rCycleCount,5)=time(pt);
    rCycleCount=rCycleCount+1;

end
%   Note: This loop ^ works because we already ensured that all extremes
%   are alternating and long gaps between extremes accounted for.


Combine Data from Both Feet
% Create theoretical left foot data
%   Note: Since the y-axis runs front to back on the shoe given our sensor
%   placement and the mirrored left foot orientation would result in a 180
%   degree flip in y-axis orientation. The same analysis could be completed
%   on both feet by simply multiplying ones values by -1. Since I do not
%   have left shoe data, I am faking by copying the right foot data and
%   stagering it.

lCycle=zeros(1,5);    % Establishing left cycle matrix
lCycleCount=1;        % Start cycle count
tVar = 0;             % Variable for determining average time of rCycle
for i = 1:length(rCycle)-1
    tVar = tVar + (rCycle(i+1,2)-rCycle(i,2));
end
tAvg = tVar/(length(rCycle)-1)          % Average time of a rCycle

for i = 1:length(rCycle(:,1))
    lCycle(lCycleCount,1)=lCycleCount;
    lCycle(lCycleCount,2)=rCycle(lCycleCount,2)+(tAvg/2);  % Stagger left cycle by 1/2 avg cycle time
    lCycle(lCycleCount,3)=rCycle(lCycleCount,3)+(tAvg/2);
    lCycle(lCycleCount,4)=rCycle(lCycleCount,4)+(tAvg/2);
    lCycle(lCycleCount,5)=rCycle(lCycleCount,5)+(tAvg/2);
    lCycleCount=lCycleCount+1;
end

%   Note: In order to understand how to group the two steps together, we
%   first must understand how the y-acceleration graph correlates to the
%   motion of the foot.

fig1 = imread('GaitCycle.png');
image(fig1);
axis image
title('Motion at Points in Gait Cycle');

fig2 = imread('yAccelerations.png');
image(fig2);
axis image
title('y-Acceleration of feet during pictured cycle (0 acc. lies near the middle of each curve)');


% Combining data from both feet
%   Note: This matrix is different than the cycle matricies as it counts
%   steps (2 steps per cycle, 1 with each foot) and holds 4 values per step
%   from a combination of both feet.
%   IMPORTANT: This system is not perfect yet and needs further refining
%   to accurately timestamp the eight distinct steps of the gait cycle. The extremes
%   collected in the previous 'cycle' arrays simply provide a grid of the
%   cycle from which we derive anchor points. It also may turn out that those 8 points
%   are unimportant for the data analyzed with this system, but assuming
%   that we would like the to stamp these 8 points, further data processing
%   would be necessary.

tStep=zeros(1,5);   % Establishing step array

%   Note: The tStep matrix acts as a general bracket for the steps of the
%   gait cycle. I think that the next step should be to consider points of
%   0 y-acceleration as from the looks of the graph some of those may be
%   better correlated to certain points in the cycle.

if lCycle(1,2) > rCycle(1,2)  % If user steps with the right foot first
    first = 'r';   % Used later for symmetry.
    for i = 1:2:((rCycleCount-1)*2)-1
        j = i + 1;
        k = (i+1)/2;
        q = k+1;
        tStep(i,1) = i;
        tStep(i,2) = lCycle(k,2);   % Each step contains 3 points from 1
        tStep(i,3) = lCycle(k,3);   % cycle and 1 point from its counterpart.
        tStep(i,4) = rCycle(k,5);   % This is because 3 extremes seeme to be
        tStep(i,5) = lCycle(k,4);   % grouped into < half of the cycle.
        if j < ((rCycleCount-1)*2)-1
            tStep(j,1) = j;
            tStep(j,2) = rCycle(q,2);
            tStep(j,3) = rCycle(q,3);
            tStep(j,4) = lCycle(k,5);
            tStep(j,5) = rCycle(q,4);
        end
    end
elseif lCycle(1,2) < rCycle(1,2)  % If user steps wih the left foot first
    for i = 1:2:((lCycleCount-1)*2)-1
        j = i + 1;
        q = k + 1;
        tStep(i,1) = i;
        tStep(i,2) = rCycle(k,2);
        tStep(i,3) = rCycle(k,3);
        tStep(i,4) = lCycle(k,5);
        tStep(i,5) = rCycle(k,4);
        if j < ((lCycleCount-1)*2)-1
            tStep(j,1) = j;
            tStep(j,2) = lCycle(q,2);
            tStep(j,3) = lCycle(q,3);
            tStep(j,4) = rCycle(k,5);
            tStep(j,5) = lCycle(q,4);
        end
    end
end

%   Note: Looking at tStep for this data you may notice that some steps
%   start before the previous one has ended or certain points occur after
%   the following. Working with additional extracted data, I think that
%   this general system could be honed to a science.


Symmetry
% The symmetry value shows discrepancy between time spent on each foot as a
% percentage of agerage time spent on a foot over the course of the
% session.

rTime = 0;      % Right foot time on ground during all combined steps
lTime = 0;      % Left foot time on ground during all combined steps
count = 0;      % Step count

for i = 1:2:length(tStep)   % Left and right steps alternate in tStep so I count in 2s and grab both at once.
    j = i + 1;
    if j < length(tStep) || (length(tStep)\2 == 0)    % Eliminates instances where length(tStep) is odd so j exceeds limit.
        if first == 'r'  % First step with right foot
            rTime = rTime + (tStep(i,5)-tStep(i,4));
            lTime = lTime + (tStep(j,5)-tStep(j,4));
            count = count + 1;
        else    % First step with left foot
            lTime = lTime + (tStep(i,5)-tStep(i,4));
            rTime = rTime + (tStep(j,5)-tStep(j,4));
            count = count + 1;
        end
    end
end

% Determine average time spent on each foot per step during entire session
rAvgTime = rTime/count
lAvgTime = lTime/count
AvgTime = (rAvgTime+lAvgTime)/2

% Generate a symmetry value based on the larger of the two times
symVal = (abs(rAvgTime-lAvgTime)/AvgTime)*100

% Determine which foot is favored
if rAvgTime > lAvgTime
    symSign = 'right'
else
    symSign = 'left'
end

% Present symmetry value
X = ['You favored your ', symSign, ' foot by ', num2str(symVal), '%.'];
disp(X);


Additional Calculations
% The calculations for standing time and and our derived fitness score are
% in the analysis script in the swift app.
