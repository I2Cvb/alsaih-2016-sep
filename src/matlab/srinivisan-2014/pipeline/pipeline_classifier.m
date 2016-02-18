clc
clear all

file = dir('/data/retinopathy/OCT/SERI/feature_data/srinivasan_2014/*.mat');
[n,s,c]=xlsread('data.csv');
s=char(s{2:size(s,1),1});
train_set = []; 
test_set = []; 
train_label = []; 
test_label = [];
%%% Loading the test set 
for i = 1 : 2
    temp=find(strncmp( cellstr(s), strtok(file(i).name,'.'), length(strtok(file(i).name,'.'))));
    load file(i).name
          if n(temp)==1
              test_set = [test_set; hog_feat]; 
              label_tem = ones(128,1); 
              test_label = [train_label; label_tem ]
          else
              test_set = [test_set; hog_feat]; 
              label_tem = -1*ones(128,1); 
              test_label = [test_label; label_tem ]
          end
end

%%% loading the train set 
for i = 3 : size(file,1)
    temp=find(strncmp( cellstr(s), strtok(file(i).name,'.'), length(strtok(file(i).name,'.'))));
    load file(i).name
          if n(temp)==1
              train_set = [train_set; hog_feat]; 
              label_tem = ones(128,1); 
              train_label = [train_label; label_tem ]
          else
              train_set = [train_set; hog_feat]; 
              label_tem = -1*ones(128,1); 
              train_label = [train_label; label_tem ]
          end
end

%%% Training the svm classifier using training set
    SVMStruct = svmtrain(train_set,train_label);
    
%%% Test the svm classifier using the test set 
    Group = svmclassify(SVMStruct, test_set);
    
%%% Validate the results with test label
%%%% confmat 

C = confusionmat(Group,test_label)