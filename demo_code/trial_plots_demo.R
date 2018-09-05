source("desc_normalize.R")
###DATA ANALYSIS
apply(all_data,2,range)
apply(all_data,2,unique)


#See density plots for each var with all data
all_data %>%
  gather(variable, value,-Timestamp, -t_label) %>%
  ggplot(aes(y = as.factor(variable), 
             fill = as.factor(t_label), 
             x = percent_rank(value))) +
  geom_density_ridges()


normal_data %>%
  gather(variable, value,-Timestamp) %>%
  ggplot(aes(y = as.factor(variable), 
             
             x = percent_rank(value))) +
  geom_density_ridges()


attack_data %>%
  gather(variable, value,-Timestamp, -t_label) %>%
  ggplot(aes(y = as.factor(variable), 
             fill = as.factor(t_label), 
             x = percent_rank(value))) +
  geom_density_ridges()
