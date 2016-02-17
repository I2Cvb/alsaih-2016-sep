function [ Oimg,ma ] = flattening( Iimg )
    % Binarize the image to find the maximum
    m=im2bw(Iimg,0.3);
    % Compute the convex hull
    d= bwconvhull(m,'objects');
    %apply median filter
    B = medfilt2(d);
    %find lower bounday
    for i = 1:size(B,2)
        tt=find(B(:,i));
        if length(tt)==0
            data(i)=NaN;
        else
            data(i)=tt(length(tt));
        end
    end

    data(find(isnan(data)))=nanmean(data);
    %second order polynomail for the lower boundary
    p = polyfit(1:size(B,2),mean(data)*ones(1,size(B,2)),2);
    %fit data to the calculated polynomial
    y2 = polyval(p,data);
    ap=data-y2;
    %movecolumns up or down
    for i = 1:size(B,2)
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