FROM ros:melodic-ros-core

MAINTAINER Yosuke Matsusaka <yosuke.matsusaka@gmail.com>

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y curl supervisor && \
    apt-get clean

# OSRF distribution is better for gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN source /opt/ros/melodic/setup.bash && \
    mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/src && \
    catkin_init_workspace && \
    git clone --depth 1 https://github.com/ros-simulation/gazebo_ros_demos.git && \
    cd .. && \
    rosdep update && apt-get update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/ros/melodic install && \
    apt-get clean && rm -r ~/catkin_ws

ADD supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/opt/ros/melodic/share/rrbot_description", "/opt/ros/melodic/share/rrbot_control"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
