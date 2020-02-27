# Tutorial: Selection and Labeling

**Goal**: Learn how to select and label frames from video sequences using Selection and Annotation Tool.  

**Video**: https://lmb.informatik.uni-freiburg.de/data/RatTrack/data/freipose_tutorial_selection_labeling.mp4

It is assumed that the data of the [Overview Pose Estimation](https://github.com/lmb-freiburg/FreiPose-docker/blob/master/Tutorial_OverviewPose.md) tutorial is available. 

For selection of frames call

    python select.py config/model_rat.cfg.json /host/tutorial_data/pred_run010__00.json
    
To label the selected frames use

    python label.py config/model_rat.cfg.json /host/tutorial_data/labeled_set0/
    
    
For more information on the tools also see:

[Selection Tool](https://github.com/lmb-freiburg/FreiPose/blob/master/Readme_Select.md)

[Labeling Tool](https://github.com/lmb-freiburg/FreiPose/blob/master/Readme_Label.md)  
