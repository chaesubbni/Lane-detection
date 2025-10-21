clear all; clc;
filename = 'solidYellowLeft.mp4';
VideoSource = vision.VideoFileReader(filename, 'VideoOutputDataType', 'double');
VideoOut = vision.VideoPlayer('Name', 'Output');
filtersz = 7; 
sigma = 7;
th_h = 0.26;
th_l = 0.05;
ang_l = 75 ; % lane line angle for Lane selection
while ~isDone(VideoSource)
    img = step(VideoSource);
    img_ori = imresize(img, 0.5);
    col = length(img_ori(:,1));
    row = length(img_ori(1,:));
    img_output = imcrop(img_ori,[1 col*3/5 row col]);
    img_gray = rgb2gray(img_output); % 1채널 unit8
    img_gray = double(img_gray); 
    %% canny edge detection
    image_canny=Canny_acl(img_gray, filtersz, sigma, th_h, th_l);
    %% Hough line transform
    [H,T,R] = hough(image_canny);
    P = houghpeaks(H, 25,'threshold',ceil(0.3*max(H(:))));
    [lines] = houghlines(image_canny,T,R,P,'FillGap',10,'MinLength', 8);
    %% Lane selection
    c1 = []; c2 = []; l = [];
    for k = 1:length(lines)
        if(lines(k).theta < 75  && lines(k).theta > -75 )
            c1 = [c1; [lines(k).point1 2]];
            c2 = [c2; [lines(k).point2 2]];
            l = [l;lines(k).point1 lines(k).point2];
        end
    end
    img_line = insertShape(img_output, 'Line', l,'Color','green','LineWidth',3);
    img_line = insertShape(img_line, 'Circle', c1);
    img_line = insertShape(img_line, 'Circle', c2);
    step(VideoOut, img_line);
end
release(VideoOut);
release(VideoSource);

function output_img = Canny_acl(src_img ,filtersz, sigma, th_h, th_l)
%% gaussian filter
%Smoothing the input image by an Gaussian filter
g1=fspecial('gaussian', [filtersz,filtersz],sigma);
img1=filter2(g1,src_img); %2D convolution
%% Calculating gradient with sobel mask
sobelMaskX=[-1,0,1;-2,0,2;-1,0,1];
sobelMaskY=[1,2,1;0,0,0;-1,-2,-1];
%Convolution by image by horizontal and vertical filter
G_X=conv2(img1,sobelMaskX,'same'); 
G_Y=conv2(img1,sobelMaskY,'same'); 
%Calcultae magnitude of edge
magnitude=sqrt((G_X.^2)+(G_Y.^2)); %에지의 세기
%Calculate directions/orientations
theta=atan2(G_Y,G_X);
theta=theta*(180/pi);

%Adjustment for negative directions, making all directions positive
col=length(src_img(:,1));
row=length(src_img(1,:));
for i=1:col
    for j=1:row
        if (theta(i,j)<0)
            theta(i,j)= 360 + theta(i,j);
            % 0 <= theta <= 360
        end
    end
end

%% quantization theta
qtheta=zeros(col,row);
%Adjusting directions to nearest 0, 45, 90, or 135 degree
for i=1:col
    for j=1:row
        if ((theta(i,j)>=0) && (theta(i,j)<22.5)|| (theta(i,j)>=157.5)&&(theta(i,j)<202.5)||...
            (theta(i,j)>=337.5)&&(theta(i,j)<=360))
            qtheta(i,j)=0; %degree group 0
        elseif((theta(i,j)>=22.5)&&(theta(i,j)<67.5)||(theta(i,j)>=202.5)&&(theta(i,j)<247.5))
            qtheta(i,j)=1; %degree group 1
        elseif((theta(i,j)>=67.5 && theta(i,j)<112.5)||(theta(i,j)>=247.5 && theta(i,j)<292.5))
            qtheta(i,j)=2; %degree group 2
        elseif((theta(i,j)>=112.5 && theta(i,j)<157.5)||(theta(i,j)>=292.5 && theta(i,j)<337.5))
            qtheta(i,j)=3; %degree group 3
        end
    end
end

%% Non-Maximum Supression
BW=zeros(col,row);
for i=2:col-1
    for j=2:row-1
        if(qtheta(i,j)==0)
            BW(i,j)=(magnitude(i,j)==max([magnitude(i,j),magnitude(i,j+1),magnitude(i,j-1)]));
        elseif (qtheta(i,j)==1)
            BW(i,j)=(magnitude(i,j)==max([magnitude(i,j),magnitude(i+1,j-1),magnitude(i-1,j+1)]));
        elseif (qtheta(i,j)==2)
            BW(i,j)=(magnitude(i,j)==max([magnitude(i,j),magnitude(i+1,j),magnitude(i-1,j)]));
        elseif (qtheta(i,j)==3)
            BW(i,j)=(magnitude(i,j)==max([magnitude(i,j),magnitude(i+1,j+1),magnitude(i-1,j-1)]));
        end
    end
end
BW=BW.*magnitude;

%% Hysteresis Thresholding
T_max=th_h; T_min=th_l;
T_min=T_min * max(max(BW));
T_max=T_max * max(max(BW)); %전체 픽셀값의 최대
edge_final = zeros(col, row);
for i=1:col
    for j=1:row
        if (BW(i,j)<T_min)
            edge_final(i,j)=0;
        elseif(BW(i,j)>T_max)
            edge_final(i,j)=1; 
        elseif( BW(i+1,j)>T_max || BW(i-1,j)>T_max ...
        || BW(i,j+1)>T_max || BW(i,j-1)>T_max || BW(i-1,j-1)>T_max ...
        || BW(i-1,j+1)>T_max || BW(i+1,j+1)>T_max || BW(i+1,j-1)>T_max) ...
        edge_final(i,j)=1;
        end
    end
end
output_img=uint8(edge_final.*255);
end
