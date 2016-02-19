
clc
clear all

file = dir('/data/retinopathy/OCT/SERI/feature_data/srinivasan_2014/*.mat');
[n,s,c]=xlsread('../../../../data/data.csv');
s=char(s{2:size(s,1),1});
index=[0 16];
gpf=[];
ladf=[];
%%% Loading the test set 
for i = 1 : 16
        index = index + 1;
        train_set = [];
        test_set = [];
        train_label = [];
        test_label = [];
    for j = 1:32
    temp=find(strncmp( cellstr(s), strtok(file(j).name,'.'), length(strtok(file(j).name,'.'))));
    temp2=strcat('/data/retinopathy/OCT/SERI/feature_data/srinivasan_2014/',file(j).name);
    %to check the loop is going well becuase the mistake before
    % i used i in the file names while it should be in j
    %file(i).name
    %n(temp)
    load(temp2)
    if length(find(j==index))>0
          if n(temp)==1
              test_set = [test_set; hog_feat]; 
              label_tem = ones(128,1); 
              test_label = [test_label; label_tem ];
          else
              test_set = [test_set; hog_feat]; 
              label_tem = -1*ones(128,1); 
              test_label = [test_label; label_tem ];
          end

    else
          if n(temp)==1
              train_set = [train_set; hog_feat]; 
              label_tem = ones(128,1); 
              train_label = [train_label; label_tem ];
          else
              train_set = [train_set; hog_feat]; 
              label_tem = -1*ones(128,1); 
              train_label = [train_label; label_tem ];
          end
    end   
    end
    %checker for the size of the label after each iteration   
    size(test_label)
    % size(test_set)
    %%% Training the svm classifier using training set
    SVMStruct = svmtrain(train_set,train_label);
    
%%% Test the svm classifier using the test set 
    Group = svmclassify(SVMStruct, test_set);
    gpf=[gpf;Group];
    ladf=[ladf;test_label];
end

    
%%% Validate the results with test label
%%%% confmat 

C = confusionmat(gpf,ladf);
