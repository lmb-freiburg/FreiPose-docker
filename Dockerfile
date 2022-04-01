FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Disable interaction with tzinf, which asks for your geographic region
ENV DEBIAN_FRONTEND=noninteractive

# update repos and get packages
RUN apt-get update &&                          \
    apt-get install -y \
        sudo git ssh wget cmake python3-pip cmake libgoogle-glog-dev libatlas-base-dev libopencv-dev \
        libboost-all-dev libeigen3-dev libsuitesparse-dev libgtk2.0-dev libsm6 libxext6 wget unzip python3-pyqt5 kate geeqie firefox python3-tk
RUN pip3 install --upgrade pip
RUN pip3 install Pillow==6.0.0 scipy==1.2.1 opencv-python==4.1.2.30 matplotlib==3.0.3 Cython pyx commentjson tqdm pandas numpy==1.16.4 tensorflow-gpu==1.13.1 joblib colored tensorpack==0.9.4

## Container's mount point for the host's input/output folder
VOLUME "/host"

## Enable X in the container
ARG DISPLAY
ENV XAUTHORITY $XAUTHORITY

## Setup "machine id" used by DBus for proper (complaint-free) X usage
ARG machine_id
ENV machine_id=${machine_id}
RUN sudo chmod o+w /etc/machine-id &&       \
    echo ${machine_id} > /etc/machine-id && \
sudo chmod o-w /etc/machine-id

## Switch to non-root user
ARG uid
ARG gid
ARG username
ENV uid=${uid}
ENV gid=${gid}
ENV USER=${username}
RUN groupadd -g $gid $USER &&                                         \
    mkdir -p /home/$USER &&                                           \
    echo "${USER}:x:${uid}:${gid}:${USER},,,:/home/${USER}:/bin/bash" \
         >> /etc/passwd &&                                            \
    echo "${USER}:x:${uid}:"                                          \
         >> /etc/group &&                                             \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL"                            \
         > /etc/sudoers.d/${USER} &&                                  \
    chmod 0440 /etc/sudoers.d/${USER} &&                              \
    chown ${uid}:${gid} -R /home/${USER}

USER ${USER}
ENV HOME=/home/${USER}

WORKDIR ${HOME}

## make python3 default
RUN sudo rm -f /usr/bin/python && sudo ln -s /usr/bin/python3 /usr/bin/python

## install cocotools
RUN cd ~ && git clone https://github.com/cocodataset/cocoapi && cd cocoapi/PythonAPI/ && sudo make install

# install FreiPose
RUN cd ~ && git clone https://github.com/lmb-freiburg/FreiPose.git && cd FreiPose && ln -s /host/ ./data && \
    ln -s /host/trainings ./trainings && \
    cd utils/triangulate/ && python setup.py build_ext --inplace

## Download network weights
RUN cd ~/FreiPose/ && wget --no-check-certificate https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/weights.zip && unzip weights.zip && rm weights.zip

# hack needed to make computer with more than one GPU work if the first one is not cuda compatible
ENV CUDA_VISIBLE_DEVICES="0" 
