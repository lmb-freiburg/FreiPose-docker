# Tutorial: Overview Pose Estimation

**Goal**: Give a coarse Overview over the FreiPose workflow and see how to estimate pose on a given set of videos. 

**Video**: https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/freipose_tutorial_pose_overview.mp4

After building the Docker image (see section Installation), you can start the container using

    bash docker-run.sh
    
This will start up a container that is separated from the host machine it was started on, which gives full control over
libraries and dependencies used. To transfer files between the host and the Docker container a specific folder is needed. 
Inside the container it is available under `/host/`, which is mapped to `FreiPose/data/` on the host machine. 

For the tutorial we provide a short sequence of an previously unseen animal, where occlusions are introduced by an 
object inside of the cage. To download the data inside the container call

    cd /host/ && wget --no-check-certificate https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/tutorial_data.zip && unzip tutorial_data.zip && rm tutorial_data.zip

which makes the data accessible on the host (under `FreiPose/data/`) and from inside the container (under `/host/`).
Inspecting any of the folders shows you that in the `tutorial_data` subfolder are 7 video files of cameras cam1 to cam7 
a folder called `train_set`, one called `eval_set` and a `M.json` file that contains the camera calibration.

Let `${TUT_PATH}` be the path to where the data is located inside the Docker container (i.e. `/host/tutorial_data`).
In order to make predictions on the videos use
    
    export TUT_PATH="/host/tutorial_data"
    cd ~/FreiPose/
    python predict_bb.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi
    python predict_pose.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi
    
Which creates the file `${TUT_PATH}/pred_run010__00.json` containing the prediction data. 
To visualize what this file contains you can call

    python show_pred.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi --draw_fid --save
    
It shows you the predictions made by the model overlayed on the images and saves it as a video file `${TUT_PATH}/vid_pred_run010__00.avi`.
The video shows that overall the predictions are fairly reasonable, but there are systematic errors from 275-300 
because of the unkown object occluding the animal. 

To evaluate how well the pose estimation is, we provide already provided a small set of evaluation frames we use for error calculation:

    python eval.py config/model_rat.cfg.json ${TUT_PATH}/pred_run010__00.json ${TUT_PATH}/eval_set/anno.json

The evaluation yields an error of 5.78 mm on average. To improve the systematic failure cases due to object occlusion we label some of the problematic frames.

Let's not spend much time on actually labeling the frames, but proceed with the labeled dataset that is provided with the data downloaded earlier
`${TUT_PATH}/train/`. To train the network on the newly labeled dataset we have to tell the framework about this chunk 
of frames. This is achieved by adding an entry to the respective configuration file: `config/data_rat.cfg.json`. 
By default the settings are already correctly made (lines 16-32).

Because the bounding box detections look good we skip training the bounding box network. Otherwise this could be started by calling `python train_bb.py config/model_rat.cfg.json`.
    
To be able to train the pose network on the frames we need to preprocess the images so network training 
can run much faster. Preprocessing includes cropping the images wrt a bounding box containing all the keypoints, 
which will be stored in a dedicated storage folder `${TUT_PATH}/processed_frames/`.

    python preproc_data.py config/model_rat.cfg.json
    
Afterwards we are ready to start the actual training of the network:
    
    python train_pose.py config/model_rat.cfg.json
    
which finishs in ~30min using an NVIDIA 1070TI. The model weights are stored in `${TUT_PATH}/trainings/`, which is shared with the host machine.
When the training process is done we can add the newly trained model to the framework by adding a new entry to the list 
of pose_networks (line 5):

    "pose_networks": [
    "weights/pose_base/ckpt/",
    "trainings/train_pose_run0/ckpt/"
    ],

To verify the improvement you can make new pose predictions with the improved model and then run evaluation on the new predictions.

    python predict_bb.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi
    python predict_pose.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi
    python eval.py config/model_rat.cfg.json ${TUT_PATH}/pred_run010__01.json ${TUT_PATH}/eval_set/anno.json
    
Which now returns a final error of 5.39 mm and also direct comparison of the predictions shows the improvement. 
Due to some randomness in the training process the exact final error is subject to some noise, so the number you are 
calculating will most probably differ from the reported one here.

To visualize the new predictions you can use 

    python show_pred.py config/model_rat.cfg.json ${TUT_PATH}/run010_cam1.avi --draw_fid --save
    
Comparing both videos shows that the labeled frames are correct now: f.e. 236, 278
And also neighboring (formally erronous ones) are also correct now: f.e. 278, 279



    
