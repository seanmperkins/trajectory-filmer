function film_trajectories(config_file,movie_name)
%FILM_TRAJECTORIES
%
%   Create and export movies panning and zooming around data with realistic
%   perspective that accurately scales line widths and point data as a
%   function of virtual camera movements.
%
%   FILM_TRAJECTORIES(CONFIG_FILE,MOVIE_NAME)
%
%   CONFIG_FILE (string): Relative path to a function that specifies
%   all details regarding the data to be plotted and how the plots should
%   be animated to generate a movie. The function should output four
%   structures as detailed below. The expected format for these structures
%   is laid out in greater detail in the accompanying example config file
%   'example_config.m'.
%
%       Time_Series: A structure array containing 3D time series data along
%                    with color and line width information. This structure
%                    array provides all the necessary information to plot
%                    trajectories.
%
%            Events: A structure array containing 3D point data along with
%                    color and size information. This structure array
%                    provides all the necessary information to plot 3D
%                    spheres marking events along (or off) the trajectories.
%
%       Camera_Data: A structure containing data on how the virtual camera
%                    should move around the data (and how the camera's
%                    settings should change) over the course of the movie.
%
%               Vid: A structure containing general attributes of the movie
%                    (e.g., length, frame rate, resolution, etc.)
%
%   MOVIE_NAME (string): File name for the .MP4 that will be generated and
%   saved in the current directory.
%
%   Example syntax: FILM_TRAJECTORIES('example_config','example_movie')
%
%   Sean Perkins - October 2022

% Load config file.
[Time_Series, Events, Camera_Data, Vid] = eval(config_file);

% Create a figure.
figure('Units','inches','Position',[0 0 Vid.fig_size]);
ax = axes;
axis('off')
ax.Projection = 'orthographic'; % orthographic gives accurate projections, perspective gives better sense of 3D shape
daspect([1 1 1])
axis vis3d
hold on

% Make sure axis limits are large enough to avoid cutting off any data.
all_data_points = [{Time_Series.data}, {Events.data}];
all_data_points = cat(2,all_data_points{:});
all_data_min = min(all_data_points,[],2);
all_data_max = max(all_data_points,[],2);
xlim([all_data_min(1) all_data_max(1)]*2)
ylim([all_data_min(2) all_data_max(2)]*2)
zlim([all_data_min(3) all_data_max(3)]*2)

% Plot time series data as lines.
for i = 1:length(Time_Series)
    plot3(Time_Series(i).data(1,:),Time_Series(i).data(2,:),Time_Series(i).data(3,:),...
        'Color',Time_Series(i).color,'LineWidth',Time_Series(i).line_width);
end

% Plot events as spheres.
[x,y,z] = sphere;
for i = 1:length(Events)
    r = Events(i).radius;
    surf(x*r+Events(i).data(1), y*r+Events(i).data(2), z*r+Events(i).data(3),...
        'FaceColor',Events(i).color,'EdgeColor',Events(i).color);
end

% Generate frames for each movie segment.
n_segments = size(Camera_Data.pos,2)-1;
F = cell(n_segments,1);
for n = 1:n_segments
    Begin = structfun(@(Data) Data(:,n),Camera_Data,'un',0);
    End = structfun(@(Data) Data(:,n+1),Camera_Data,'un',0);
    F{n} = generate_frames(ax, Begin, End, Vid, n);
end

% Create pauses before, between, or after segments.
F_pause = cell(length(Vid.pause),1);
for n = 1:length(F_pause)
    if n > 1
        F_pause{n} = repmat(F{n-1}(end),1,round(Vid.fps*Vid.pause(n)));
    else
        F_pause{n} = repmat(F{n}(1),1,round(Vid.fps*Vid.pause(n)));
    end
end
F = [F_pause(1); reshape([F F_pause(2:end)]',[],1)]; % alternate pauses and segments

% Stitch together frames across all segments.
F = cat(2,F{:});

% If desired, add a second copy of the frames playing in reverse to make a
% boomerang version of the video.
if Vid.boomerang
    F = [F fliplr(F)];
end

% Export as an MP4.
v = VideoWriter(movie_name,'MPEG-4');
v.FrameRate = Vid.fps;
open(v);
for n = 1:length(F)
    writeVideo(v,F(n));
end
close(v);

end

%--------------------------------------------------------------------

function F = generate_frames(ax, Begin, End, Vid, n)
% Move the virtual camera in discrete steps from one location in 3D space
% (as specified in the 'Begin' structure) to another location (as specified
% in the 'End' structure). Generate frames that can be used to play back
% the motion as a video.

% Frame count.
n_frames = round(Vid.fps*Vid.segment_length(n));

% Preallocate frame structure.
F(n_frames) = struct('cdata',[],'colormap',[]);

% Rendering definition.
res = ['-r',num2str(Vid.resolution)];

% Compute beginning and ending camera distances.
begin_dist = sqrt(sum((Begin.pos-Begin.targ).^2));
end_dist = sqrt(sum((Begin.pos-Begin.targ).^2));

% Compute total relative zoom over the course of these frames.
rel_zoom = Begin.view_angle/End.view_angle;

% Compute beginning and ending line widths.
line_objects = findobj(ax.Children,'Type','line');
begin_width = [line_objects.LineWidth];
end_width = begin_width .* rel_zoom;

% Generate each frame.
for j = 1:n_frames

    % Smoothly interpolate between beginning and ending values.
    cam_dist = begin_dist + (end_dist-begin_dist)*(j-1)/(n_frames-1);
    ax.CameraTarget = Begin.targ + (End.targ-Begin.targ)*(j-1)/(n_frames-1);
    ax.CameraPosition = Begin.pos + (End.pos-Begin.pos)*(j-1)/(n_frames-1);
    zf = 1 + (rel_zoom-1)*(j-1)/(n_frames-1);
    ax.CameraViewAngle = Begin.view_angle;
    camzoom(ax,zf)
    ax.CameraUpVector = Begin.up_vector + (End.up_vector-Begin.up_vector)*(j-1)/(n_frames-1);

    % Adjust camera position to ensure correct distance to target.
    v = ax.CameraPosition - ax.CameraTarget;
    v = v/sqrt(sum(v.^2))*cam_dist;
    ax.CameraPosition = ax.CameraTarget + v;

    % Adjust line widths.
    for i = 1:length(line_objects)
        line_objects(i).LineWidth = begin_width(i) + (end_width(i)-begin_width(i))*(j-1)/(n_frames-1);
    end

    % Draw and capture frame for plot.
    axes(ax) %#ok
    drawnow
    cdata = print('-RGBImage',res,'-vector');
    F(j) = crop_frame(im2frame(cdata),Vid);

end

end

%--------------------------------------------------------------------

function F = crop_frame(F, Vid)
% Crop frame to remove a portion of the pixels on left and right sides
% (as determined by Vid.crop_X) or from the top and bottom (as determined
% by Vid.crop_Y).

% Get original size of the figure in pixels.
[x_size,y_size,~] = size(F.cdata);

% Compute number of pixels to crop on each side.
x_pixels_to_crop = Vid.crop_X*x_size;
y_pixels_to_crop = Vid.crop_Y*y_size;

% Create index to sample frame with.
x_idx = x_pixels_to_crop+1:x_size-x_pixels_to_crop;
y_idx = y_pixels_to_crop+1:y_size-y_pixels_to_crop;

% Ensure frame has an even number of pixels for the purposes of
% compression.
if mod(length(x_idx),2) == 1
    x_idx = x_idx(1:end-1);
end
if mod(length(y_idx),2) == 1
    y_idx = y_idx(1:end-1);
end

% Crop frame.
F.cdata = F.cdata(y_idx,x_idx,:);

end