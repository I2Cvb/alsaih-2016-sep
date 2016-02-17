clear all
clc
tic

[a] = read_oct_volume('PCS57635OS.img',512,128,1024);

a=uint8(a(:,:,1));
imshow(a)
sigma = 190;[t,a] = BM3D(1, a,sigma);
pp=a;
m=im2bw(a,0.3);
d= bwconvhull(m,'objects');
B = medfilt2(d);
for i = 1:512
tt=find(B(:,i));
data(i)=tt(length(tt));
end
p = polyfit(1:512,mean(data)*ones(1,512),2);
y2 = polyval(p,data);
ap=data-y2;
%a=pp;
for i = 1:512
if ap(i)>0
dif=abs(floor(ap(i)));
te=a(:,i);
te=te([ dif+1:end 1:dif ]);
a(:,i)=te;
else
dif=abs(floor(ap(i)));
te=a(:,i);
te=te([ end-dif+1:end 1:end-dif ]);
a(:,i)=te;
end
end
figure
imshow(a)
f=a(floor(mean(data))-89:floor(mean(data))+30,size(a,2)/2-169:size(a,2)/2+170);
figure
imshow(f)
I0 = f;
I1 = impyramid(I0, 'reduce');
I2 = impyramid(I1, 'reduce');
I3 = impyramid(I2, 'reduce');
[feature,hg] = extractHOGFeatures(I0,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1]);
feature = [feature extractHOGFeatures(I1,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];
feature = [feature extractHOGFeatures(I2,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];
feature = [feature extractHOGFeatures(I3,'CellSize',[4 4],'BlockSize',[2 2] ,'BlockOverlap',[1 1])];
hold on
plot(hg,'Color','red')
toc
