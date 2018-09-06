### demo_code 
This folder contains a sample implementation of WADAC. We developed a shiny App to show the capabilities and functionality of WADAC.
The following steps were carried out to demonstrate WADAC: 
- We collected link-layer traffic from a D-Link camera using COTS radio in three different scenarios: 
  1. When the camera was performing normal functions
  2. While implementing tcp-flood attack on the D-Link camera 
  3. While implementing udp-flood attack on camera 
- The collected traffic was stored as pcap files in ./WADAC/demo
  - monitor_cam_dlinkcam62879313_mixed_packetgen_noraml_4.pcap contains udp-flood attack packets
  - monitor_cam_dlinkcam62879313_mixed_packetgen_noraml_4_old.pcap contains tcp-flood attack packets followed by normal packets
- Implemented WADAC to detect anomalies and classify wether the anomaly is tcp-flood or udp-flood attack

### Key files: 
- ./WADAC/live_capture_n_extract_features_anomaly_detect.py: This python file extracts link-layer features from pcap files found in ./WADAC/demo folder and stores it in ./WADAC/demo/live_db_sigs_bnl800_bks300.db database
- ./WADAC/demo/live_db_sigs_bnl800_bks300.db database: Contains features extracted from pcap files. This file is constantly polled by a R script to check for any updates
-  ./WADAC/server.R: 
  -This file contains the server implementation of the web App. The server polls the database after every second to check for updated features. 
  - The server applies autoencoder stored as ./WADAC/model_demo.hd5 to detect anomalies in collected traffic. This model was trained using demo_main.R script
  - The server plots a mse vs time plot to show the time when anomalies are detected
  - It also applies randomForest model stores as ./WADAC/supervised_model.RData to classify the anomaly detected into a known set of attacks. This randomForest model was trained using demo_supervised.R script
- ./WADAC/ui.R: This file contains the design of ui of the web App. 
  
### Steps to run: 
- Using RStudio: Open ./WADAC/server.R or ./WADAC/ui.R and click on RunApp
- Via R terminal: Run the following in a R terminal 

``runGitHub("scy-phy/wadac","<github_username>",subdir="demo_code/WADAC")``

### System Details
- OS: Ubuntu 17.10
- R version details: 
      platform       x86_64-pc-linux-gnu         
      arch           x86_64                      
      os             linux-gnu                   
      system         x86_64, linux-gnu           
      major          3                           
      minor          4.2                         
      language       R                           
      version.string R version 3.4.2 (2017-09-28)
      nickname       Short Summer
 - Required R packages: dplyr, RSQLite, keras, randomForest, ggplot2, future, caret, shiny, shinythemes
      
