#to feature extractor code "extract_features.py"
#python 2.7.0 would be better as it has compatible Scapy version with it which is used in this code
#steps to run the code
1. use ubuntu 16.04 to avoid compatibility issue
2. open a terminal 
3. go to 'feature_extraction' folder
4. $python extract_features.py
-- default setting is 'extract features for normal activities in nestcam camera'
-- wifi traffic for nestcam camera (in non-anomaly settings) are in "trace_nestcam_normal" folder
-- feature description can be found in 'feature_description.txt' in 'feature_extraction' folder

-- to extract features from anomaly traffic samples 
--   -- in function "if __name__ == '__main__':", make the following changes only
	
	dir_name = './ids_disclosure_wisec_trace/trace_nestcam_ddos/'
    	#dir_name = './ids_disclosure_wisec_trace/trace_nestcam_normal/'
     -- change the name of db in 'get_db_file_name()', the line should look like following
	db_name = './WADAC_Database/nestcam/db_nestcam_normal_ddos_sigs_bnl'+str(bin_length) +'_bks'+str(block_size)+'.db'
	
5. $python extract_features.py

-- note please follow the naming convention for the files as stated in the code as the files names are parsed to label the traffic samples
-- also note that only a small subset of traffic samples are presented here to have an understanind of the features we extract and the technique we use in the paper in WiSec 2018

###############################################

###Get database files 
* To test the codes, extract database folders from WADAC_Database.zip before running the codes in Anomaly_Detector. 
