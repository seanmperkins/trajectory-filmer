 function [Time_Series, Events, Camera_Data, Vid] = example_config()

% Load some example data to film. This can include time series data that
% you wish to plot as 3D trajectories or event data that you wish to plot
% as spheres at particular locations in the 3D space.
load('example_data','time_series','events')

% Specify time series details. This should be a 1 x J structure array where
% J is the number of time series you wish to plot. You must specify at
% least one time series. Each time series will render as a trajectory 
% traversing 3D space. Each element of the structure array should contain
% three fields:
%
%   data: A 3 x T matrix where T is the number of time samples and each row
%         contains x, y, and z data, respectively.
%
%   color: A 1 x 3 array of RGB values on a 0 to 1 scale indicating the
%          color the trajectory should be plotted as.
%
%   line_width: A scalar indicating the line width for the trajectory
%               when it gets plotted in the first frame.
%
Time_Series = struct('data',{},'color',[],'line_width',[]);

Time_Series(1).data = time_series{1};
Time_Series(1).color = [27 158 119]/255; 
Time_Series(1).line_width = 1.5;

Time_Series(2).data = time_series{2}; 
Time_Series(2).color = [117 112 179]/255;
Time_Series(2).line_width = 1.5;

% Specify event details. This should be a 1 x K structure array where
% K is the number of events you wish to plot. You do not have to specify
% any events if you prefer just to visualize trajectories. Each event will
% render as a sphere at a particular location in 3D space. Each element of
% the structure array should contain three fields:
%
%   data: A 3 x 1 array where containing the x-, y-, and z-coordinates at
%         which to plot the sphere.
%
%   color: A 1 x 3 array of RGB values on a 0 to 1 scale indicating the
%          color the sphere should be plotted as.
%
%   radius: A scalar indicating the radius the sphere should be plotted with.
%
Events = struct('data',{},'color',[],'radius',[]); % leave this uncommented even if you don't specify any events

Events(1).data = events{1};
Events(1).color = [0 0 0];
Events(1).radius = .02;

Events(2).data = events{2};
Events(2).color = [0 0 0];
Events(2).radius = .02;

Events(3).data = events{3};
Events(3).color = [217 95 2]/255;
Events(3).radius = .02;

Events(4).data = events{4};
Events(4).color = [217 95 2]/255;
Events(4).radius = .02;

% Define the movements of the virtual camera. When a 3D plot is generated
% in MATLAB, the perspective with which you view the plot is determined by
% a virtual camera viewing the scene. By moving this camera (as you do when
% panning, zoom, etc. with MATLAB's built-in tools) you can change this
% perspective. The setting defined below is a 3 x N matrix where each of
% the N columns determines a key camera location in 3D coordinates. When
% the movie is generated, the camera will smoothly move from the 1st
% location to 2nd, then the 2nd to the 3rd, etc. Thus, it effectively 
% defines N-1 movie segments that can then be stitched together into a
% single movie. The values here determine the 'CameraPosition' property of
% the axis object.
Camera_Data.pos = [       ...
    16.7  5.6  -7.1  26.9;...
    -1.1  -26  11.7   .4 ;...
    -21   -4   22.7   0   ...
    ];

% In addition to the camera's location, we need to specify the location
% that the camera is pointing at. The values here determine the
% 'CameraTarget' property of the axis object.
Camera_Data.targ = [...
    0  0 -.75  0;   ...
    0  0 -.53 .4;   ...
    0  0 -.44  0    ...
    ];

% We also need to specify the orientation of the camera (i.e., which
% direction is up for the camera). This is specified as a 3D vector, but
% it's the projection onto the 2D plane of the camera that matters (the 
% plane orthogonal to the line segment connecting the camera to the
% target). The values here determine the 'CameraUpVector' property of the
% axis object.
Camera_Data.up_vector = [...
    0  .06  .17 0;   ...
    0 -.14  .90 0;   ...
    1  .99 -.41 1    ...
    ];

% Finally, we need to specify the camera view angle, which determines the
% field of view of the camera. This setting effectively determines the zoom
% level of the camera. Larger angles correspond to being more zoomed out
% and smaller angles correspond to being more zoomed in. The values here
% determine the 'CameraViewAngle' property of the axis object. Note that
% linearly interpolating from one view angle to another does not give the
% appearance of a smooth zoom. However, the 'film_trajectories' function
% takes care of this internally and smoothly varies from one view angle to
% the next in a manner that yields a perceptually smooth and consistent
% zoom rate.
Camera_Data.view_angle = [6 6 2 5];

% Now that we've defined N camera key points and therefore N-1 video
% segments as the camera moves from one location to the next, we need to
% define how long each segment will be in the final video (in seconds).
Vid.segment_length = [4 4 4];

% We can also add N+1 pauses in the movie before, between, or after these segments.
Vid.pause = [.5 1 1 .5]; % duration (in seconds)

% Set some remaining video attributes.
Vid.fps = 30;           % frame rate for movies (frames per second)
Vid.fig_size = [6 6];   % figure size in inches [width height]
Vid.resolution = 150;   % pixels per inch
Vid.crop_X = [0 0];     % proportion of width to crop on left and right sides
Vid.crop_Y = [0 0];     % proportion of height to crop on top and bottom sides
Vid.boomerang = true;   % determines whether to play the frames through a second time in reverse, doubling the movie length