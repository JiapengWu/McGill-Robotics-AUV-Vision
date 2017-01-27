
%% Read in the image
srcFiles = dir('C:\Users\Administrator\Desktop\MATLAB workstation\image1\*.jpg');  % the folder in which ur images exists
for i = 1 : length(srcFiles)
    filename = strcat('\path\to\your\image\folder',srcFiles(i).name);
    Rec=0;Theta=500;
    RGB = imread(filename);
    figure;imshow(RGB);
%% Determine the gradient
%dx=[1,-1];
%dy=[1,-1];
%Ix=conv(I,dx,'same');
%Iy=conv(I,dy,'same');
%Im = sqrt(Ix.*Ix + Iy.*Iy);
%% Convert to edge image
level=0.90;

bw=im2bw(RGB,level);

bwfilt=medfilt2(bw,[5 5]);

[BW,thresh]=edge(bwfilt,'canny');

%figure;imshow(BW);

%% Hough transfermation
[H,T,R] = hough(BW);
%figure;imshow(H,[],'XData', T, 'YData', R, 'InitialMagnification','fit');
xlabel('\theta'),ylabel('\rho');
axis on, axis normal, hold on;
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2));
y = R(P(:,2));
plot(x,y,'s','color','white');

%Find lines and plot them
lines = houghlines(BW,T,R,P,'FillGap',100,'MinLength',40);
%disp('point1:');lines.point1
%disp('point2:');lines.point2
%disp('theta');lines.theta
%disp('rho');lines.rho
if isfield(lines,'point1')==0
    Rec=0;Theta=500;
else
figure, imshow(im2bw(RGB,0),'InitialMagnification',50), hold on;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
    %plot beginnings and ends of lines
    plot(xy(1,1),xy(1,2),'LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'LineWidth',2,'Color','red');    
end

%% classify in terms of the difference of rho and theta
clearvars s;
s(1).n(1)=lines(1);
for k=2:length(lines) 
    len1=length(lines);
    len=norm(lines(k).point1-lines(k).point2);
    %check each line
	for i=1:length(s) %for every catagory of lines
        len2=length(s);
        disp('k=');disp(k);
        disp('i=');disp(i);
        %disp('lines(k).rho');disp(lines(k).rho);
        %disp('s(i).n(1).rho');disp(s(i).n(1).rho);
        disp('rho');disp(abs(lines(k).rho-s(i).n(1).rho));
        %disp('lines(k).theta');disp(lines(k).theta);
        %disp('s(i).n(1).theta');disp(s(i).n(1).theta);
        disp('theta');disp(abs(lines(k).theta-s(i).n(1).theta));
        disp(' ');
        %if the difference between the kth line's rho and theta with respect
        %to the s(i).n(1) is within the range, append it to the end of
        %s(i).n(length+1)
        if (abs(lines(k).rho-s(i).n(1).rho)<10 && abs(lines(k).theta-s(i).n(1).theta)<5)
            lensi=length(s(i));
            s(i).n(lensi+1)=lines(k);
            i=-1;
            break;
        end  %end of if
    end  %end of for(i)
    
        %if the kth line does not match with any cluster in s, creat
        %s(length+1) to hold this line.
        lens=length(s);
        if i==lens
            lens=lens+1;
            s(lens).n(1)=lines(k);
        end
    %s(count).n.point2=lines(k).point2;
    %s(count).n.rho=lines(k).rho;
    %s(count).n.theta=lines(k).theta;
end  %end of for(k)

%% show the picture
figure, imshow(im2bw(RGB,0),'InitialMagnification',50), hold on;
max_len = 0;

%get the max and show the lines
for k = 1:length(s)
     max1=0;
     max2=0;
     lenMax=0;
     for j=1:length(s(k).n)
         len2=norm(s(k).n(j).point1-s(k).n(j).point2);
         if lenMax<len2
            max1=s(k).n(j).point1;
            max2=s(k).n(j).point2;
            lenMax=norm(max2-max1);
         end
     end
        xy = [max1; max2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
        %plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'LineWidth',2,'Color','red');    
end

%% debugging(showing images in s(1) to s(n))
%figure, imshow(im2bw(RGB,0),'InitialMagnification',50), hold on;
%for k = 1:length(s)
 %   for j=1:length(s(k).n)
 %      disp('length(s(k))=');disp(length(s(k)));
 %       xy = [s(k).n(j).point1; s(k).n(j).point2];
 %       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
 %   
 %       %plot beginnings and ends of lines
 %       plot(xy(1,1),xy(1,2),'LineWidth',2,'Color','yellow');
 %       plot(xy(2,1),xy(2,2),'LineWidth',2,'Color','red');    
 %   end
%end

%% judge if there exists parallel pairs of lines(with some distance)

for i=1:length(s)-1
	for j=i+1:length(s)
		if abs(s(i).n(1).theta-s(j).n(1).theta)<3;
			Rec=1;
			Theta=s(i).n(1).theta;
                 max1=0;
                 max2=0;
     lenMax=0;
     for k=1:length(s(i).n)
         len2=norm(s(i).n(k).point1-s(i).n(k).point2);
         if lenMax<len2
            max1=s(i).n(k).point1;
            max2=s(i).n(k).point2;
            lenMax=norm(max2-max1);
         end
     end
        xy = [max1; max2];
   
		
     max1=0;
     max2=0;
     lenMax=0;
     for k=1:length(s(j).n)
         len2=norm(s(j).n(k).point1-s(j).n(k).point2);
         if lenMax<len2
            max1=s(j).n(k).point1;
            max2=s(j).n(k).point2;
            lenMax=norm(max2-max1);
         end
     end
        xy1 = [max1; max2];
        
        
        figure, imshow(RGB,'InitialMagnification',50), hold on;
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
    
        %plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'LineWidth',2,'Color','red'); 
        
        plot(xy1(:,1),xy1(:,2),'LineWidth',2,'Color','red');
    
        %plot beginnings and ends of lines
        plot(xy1(1,1),xy1(1,2),'LineWidth',2,'Color','yellow');
        plot(xy1(2,1),xy1(2,2),'LineWidth',2,'Color','red');    
	end
end
clearvars s;
end
disp(Rec);
disp(Theta);
end
end
