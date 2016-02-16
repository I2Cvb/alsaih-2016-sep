clc
clear all
close all

%read all file names in db folder
file = dir('/data/retinopathy/OCT/SERI/original_data/*.img');
p = 1;
q = 1;
%read the label file
[n,s,c]=xlsread('../../../data/data.csv');
s=char(s{2:size(s,1),1});
for i = 1 : size(file,1)
    % read a volume
    [vol] = read_oct_volume(strcat('/data/retinopathy/OCT/SERI/original_data/',file(i).name),512,128,1024);
    % find its label
    temp=find(strncmp( cellstr(s), strtok(file(i).name,'.'), length(strtok(file(i).name,'.'))));
    % process all images in the volume one by one
    disp('Processing volume')
    disp(file(i).name)
    for j = 1 : 128
        a = vol(:,:,j);
        %denoise image
	    sigma=190;
        a = denoising(a, sigma);
        %flatten the image
        [a,ma] = flattening(a);
        %crop the image
        a = crop(a,ma);
        %extract feature
        feature = Featurevectorextraction(a);
        % store the features in a matrix
          if n(temp)==1
              dfeature(p,:) = [feature n(temp)];
              p = p + 1;
          else
              nfeature(q,:) = [feature n(temp)];
              q = q + 1;
          end
    end
end

ncorrect  = 0;
dcorrect = 0;
for i = 1 : 128 :size(nfeature,1)
    ddfeature = dfeature;
    nnfeature = nfeature;
    ddfeature(i:i+127,:) = [];
    nnfeature(i:i+127,:) = [];
    trset = [ddfeature(1:size(ddfeature,1)-1,:);nnfeature(1:size(nnfeature,1)-1,:)];
    tset = [ddfeature(:,size(ddfeature,2));nnfeature(:,size(nnfeature,2))];
    SVMStruct = svmtrain(trset,tset);
    Group = svmclassify(SVMStruct,dfeature(i:i+127,:));
    if mode(Group) == -1
        dcorrect = dcorrect +1;
    end
    Group = svmclassify(SVMStruct,nfeature(i:i+127,:));
    if mode(Group) == 1
        ncorrect = ncorrect +1;
    end
end
disp('Correctly classified normal images')
ncorrect
disp('Correctly classified diseased images')
dcorrect
