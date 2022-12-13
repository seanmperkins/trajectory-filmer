# Trajectory Filmer
<img align="right" src="demo_movie_for_readme.gif" alt="example_gif" width="40%"/>
<p>Trajectory Filmer is a data visualization tool for MATLAB that generates a movie file (.mp4) by setting up a virtual camera to pan, rotate, and zoom around 3D trajectory data. Despite being developed for neuroscientific applications, Trajectory Filmer is a general-purpose tool that can be used for any time series data that lends itself to plotting in trajectory format. Trajectory Filmer represents 3D time series data as trajectories through 3D space and instantaneous event data as spherical markers in 3D space. Unlike MATLAB's built-in camera tools, Trajectory Filmer correctly scales line widths and spherical markers to maintain realistic perspective.</p>

<p>The activity of a collection of neurons at a single moment in time can be summarized as a 'neural state' in a low-dimensional state space. As the activity of those neurons changes over time, the neural state moves through the state space carving out a 'neural trajectory'. It can be helpful to visualize neural trajectories from different perspectives in order to better understand their geometry, which can yield insight into the underlying computational principles driving the network of neurons. The movie embedded in this README shows two neural trajectories corresponding to patterns of neural activity in the motor cortex while a monkey moves a hand pedal cyclically forward (green trajectory) or backward (purple trajectory) [data from <a href="https://www.jneurosci.org/content/42/2/220.abstract">Schroeder et al. 2022</a>]. The black spheres indicate the moments, for each of the two movements, in which the monkey's hand began moving, and the orange spheres indicate the moments that the monkey's hand stopped moving. In both cases, there is a large translation in one neural dimension around movement onset that reverses at movement offset, suggesting the presence of a 'move' signal that doesn't care about pedaling direction. There appears to be large rotational activity in these neural dimensions when pedaling forward, but not when pedaling backward, suggesting that neural activity related to backward pedaling may largely occupy a different set of neural dimensions.</p>

<p>The user must provide a config file containing the data to plot. The config file will additionally specify how the data should appear, camera locations and settings, and other general attributes of the video. Trajectory Filmer then takes care of the low-level implementation details related to plotting the data, setting up the camera, smoothly interpolating between camera locations/settings, adjusting object sizes to maintain perspective, capturing frames, and exporting as a video file.</p>

# Syntax

To create a movie, call `film_trajectories(config_file, movie_name)` where:

`config_file`: Relative path to a config file specifying the data, camera movements, etc. User will need to create a custom config file.

`movie_name`: File name for the exported movie.

# Example

`film_trajectories('example_config', 'demo_movie')`

This syntax will re-create the movie embedded in this README. When creating a custom config file for your own data, you can use `example_config.m` as a template. It provides detailed comments explaining all of the available settings and will be a helpful aid in correctly formatting your own config file.

**Tip:** Generating a movie can be slow at high frame rates. If you plan on iteratively exporting several movies while you figure out your camera angles, etc. you can speed up the process considerably by dropping the frame rate (e.g., to 5 frames per second). You can set the frame rate by adjusting `Vid.fps` in the config file.

# Requirements

Code was written in MATLAB R2022a. It will likely work in similar versions, but this hasn't been tested.
