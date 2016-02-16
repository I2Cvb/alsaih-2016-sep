function [ Oimg,ma ] = flattening( Iimg )
%FLATTENING Summary of this function goes here
%   Detailed explanation goes here
    m=im2bw(Iimg,0.3);
    d= bwconvhull(m,'objects');
    B = medfilt2(d);
    for i = 1:512
    tt=find(B(:,i));
    if length(tt)==0
        data(i)=NaN
    else
    data(i)=tt(length(tt));
    end
    end
    data(find(isnan(data)))=nanmean(data);
    p = polyfit(1:512,mean(data)*ones(1,512),2);
    y2 = polyval(p,data);
    ap=data-y2;
    for i = 1:512
    if ap(i)>0
    dif=abs(floor(ap(i)));
    te=Iimg(:,i);
    te=te([ dif+1:end 1:dif ]);
    Iimg(:,i)=te;
    else
    dif=abs(floor(ap(i)));
    te=Iimg(:,i);
    te=te([ end-dif+1:end 1:end-dif ]);
    Iimg(:,i)=te;
    end
    end
    Oimg=Iimg;
    ma=mean(data);
end


