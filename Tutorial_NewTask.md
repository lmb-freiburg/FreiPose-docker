# Tutorial: Adapting FreiPose to a new Task

**Goal**: Learn about the necessary steps to adapt FreiPose to a completely new task (new object with different keypoints and camera configuration).

**Video**: https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/tutorial_freipose_new_task.mp4

First, start the docker environment and then download the dataset for this experiment:

    cd /host/ && wget --no-check-certificate https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/tutorial_new_task.zip && unzip tutorial_new_task.zip && rm tutorial_new_task.zip


Second, define the keypoints of the new object. For this purpose we create new configuration files

    mkdir /host/config/
    cp config/model_rat.cfg.json /host/config/model_gp.cfg.json
    cp config/skel_rat.cfg.json /host/config/skel_gp.cfg.json
    cp config/data_rat.cfg.json /host/config/data_gp.cfg.json
    
Edit the configuration files accordingly (see video for more details):

    - Change paths in model_gp.cfg.json
    - Adapt keypoint definition in skel_gp.cfg.json
    
Then create two sets of data. One for training and one for evaluation. For this purpose we use the selection tool.

    cd ~/FreiPose/
    python select.py /host/config/model_gp.cfg.json /host/tutorial_new_task/run003_cam0.avi
    
Because initially we don't have any predictions for the object in question, we can't provide `select.py` with any predictions to show. 
Therefore we pass a video file to `select.py` instead of a prediction file (`*.json`), which will tell the script that we don't have predictions yet.
In `select.py` we write two different sets of selected frames to disk to become our training and evaluation split. 
We recommend to use 5 uniformly chose samples for training and two other frames for evaluation (f.e. frame 9 and 15).  

Label the data

    python label.py /host/config/model_gp.cfg.json /host/tutorial_new_task/labeled_set0/
    python label.py /host/config/model_gp.json /host/tutorial_new_task/labeled_set1/

   
Edit `data_gp.cfg.json` accordingly (see video for more details):

    - Change storage directory
    - Enter the datasets in the 'dataset' field
    
Preprocess the data for network training

    python preproc_data.py /host/config/model_gp.cfg.json
    
You can visualize the labels using

    python show_labels.py  /hkatost/config/model_gp.cfg.json  --set_name train --wait
    python show_labels.py  /host/config/model_gp.cfg.json  --set_name eval --wait

The task of this tutorial is fairly easy to learn for the algortihm so to save some time its recommended to shorten the number of training iterations.
But the chosen default values would also work well.

    - Set bb_train_steps to 5000 in `config/bb_network.cfg.json`    
    - Set pose_train_steps to 5000 in `config/pose_network.cfg.json`
    
Start training of the bounding box network

    python train_bb.py /host/config/model_gp.cfg.json
    
which runs approximately for 20 min on our development machine (Nvidia GeForce 1070TI).

Train the pose estimation network
    
    python train_pose.py /host/config/model_gp.cfg.json
    
which runs approximately for 40 min on our development machine.

Add the newly trained networks to `data_gp.cfg.json`:

    "bb_networks": [
        "trainings/train_bb_run0_graph/frozen_inference_graph.pb"
    ],
    "pose_networks": [
        "trainings/train_pose_run0_laser1/ckpt/"
    ],
    
Make predictions using these networks
    
    python predict_bb.py /host/config/model_gp.cfg.json /host/tutorial_new_task/run003_cam0.avi
    python predict_pose.py /host/config/model_gp.cfg.json /host/tutorial_new_task/run003_cam0.avi
    python eval.py /host/config/model_gp.cfg.json /host/tutorial_new_task/pred_run003__00.json /host/tutorial_new_task/labeled_set1/anno.json