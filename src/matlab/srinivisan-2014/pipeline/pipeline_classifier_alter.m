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

train_label = []; 

for j = 1:32

	  temp=find(strncmp( cellstr(s), strtok(file(j).name,'.'), length(strtok(file(j).name,'.'))));

temp2=strcat('/data/retinopathy/OCT/SERI/feature_data/srinivasan_2014/',file(j).name);

load(temp2)

if length(find(j==index))==0

  %           if n(temp)==1

  %               test_set = [test_set; hog_feat]; 

%               label_tem = ones(128,1); 

%               test_label = [test_label; label_tem ];

%           else

	      %               test_set = [test_set; hog_feat]; 

%               label_tem = -1*ones(128,1); 

%               test_label = [test_label; label_tem ];

%           end

% 

%     else

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



    %%% Training the svm classifier using training set

	  SVMStruct = svmtrain(train_set,train_label);

    

%%% Test the svm classifier using the test set

for j = 1 : 2

	  test_set = [];

test_label = [];

temp=find(strncmp( cellstr(s), strtok(file(index(j)).name,'.'), length(strtok(file(index(j)).name,'.'))));

temp2=strcat('/data/retinopathy/OCT/SERI/feature_data/srinivasan_2014/',file(index(j)).name);

load(temp2)

if n(temp)==1

  test_set = [test_set; hog_feat]; 

label_tem = ones(128,1); 

test_label = [test_label; label_tem ];

 else

   test_set = [test_set; hog_feat]; 

label_tem = -1*ones(128,1); 

test_label = [test_label; label_tem ];

          end

	  Group = svmclassify(SVMStruct, test_set);

gpf=[gpf;mode(Group)];

ladf=[ladf;mode(test_label)];

    end

end



    

%%% Validate the results with test label

%%%% confmat 



    C = confusionmat(gpf,ladf)

      sensitivity = C(1,1)/C(1,1)+C(1,2)

      specificity = C(2,2)/C(2,1)+C(2,2)

      accuracy = C(1,1)+C(2,2)/C(1,1)+C(1,2)+C(2,1)+C(2,2)

