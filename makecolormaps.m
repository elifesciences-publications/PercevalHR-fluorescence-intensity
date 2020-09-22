%makecolormap : est une fonction autoscale qui creer une map commencant
%a l'intensite minimum de l'image jusqu'au maximum. On peut choisir la 
%couleur avec 'Green' ou 'Red' ou 'Trans' pour une image en lumiere transmise 
%en grayscale.
%S. Labrecque 2007-07-24.

function [map] = makecolormaps(I, mapcolor)
% mapGreen=[];
% mapTrans=[];
% mapRed=[];
% mapBlue=[];
% mapYellow=[];

if isequal(mapcolor,'Green') == 1 
%     exsitingmap = exist('mapGreen.mat');
%     if exsitingmap == 0
        mapGreen=[];
        maxImage=double(max(max(I)));        
        mapGreen=zeros(maxImage+1,3);
        mapGreen(:,2)=[0:(1/maxImage):1];
        map= mapGreen;
%         save mapGreen mapGreen
%     else 
%         load mapGreen
%     end
end

if isequal(mapcolor,'Trans') == 1 
%     exsitingmap = exist('mapGreen.mat');
%     if exsitingmap == 2
%         load mapGreen
%     end
%     exsitingmap = exist('mapTrans.mat');
%     if exsitingmap == 0
        mapTrans=[];
        maxImage=double(max(max(I)));        
        mapTrans=zeros(maxImage+1,3);
        mapTrans(:,1)=[0:(1/maxImage):1];
        mapTrans(:,2)=[0:(1/maxImage):1]; 
        mapTrans(:,3)=[0:(1/maxImage):1]; 
        map = mapTrans;
%         save mapTrans mapTrans
%     else 
%         load Maptrans
%     end
end

if isequal(mapcolor,'Red') == 1
%         exsitingmap = exist('mapGreen.mat');
%     if exsitingmap == 2
%         load mapGreen
%     end
%         exsitingmap = exist('mapTrans.mat');
%     if exsitingmap == 2
%         load mapTrans
%     end
    
%     exsitingmap = exist('mapRed.mat');
%     if exsitingmap == 0
        mapRed=[];
        maxImage=double(max(max(I)));        
        mapRed=zeros(maxImage+1,3);
        mapRed(:,1)=[0:(1/maxImage):1];
        map = mapRed;
%         save mapRed mapRed
%     else 
%         load mapRed
%     end
end    
    %%%%%%%%%%%%
if isequal(mapcolor,'Blue') == 1
%         exsitingmap = exist('mapGreen.mat');
%     if exsitingmap == 2
%         load mapGreen
%     end
%         exsitingmap = exist('mapTrans.mat');
%     if exsitingmap == 2
%         load mapTrans
%     end
%         exsitingmap = exist('mapRed.mat');
%     if exsitingmap == 2
%         load mapRed
%     end
%     
%     exsitingmap = exist('mapBlue.mat');
%     if exsitingmap == 0
        mapBlue=[];
        maxImage=double(max(max(I)));        
        mapBlue=zeros(maxImage+1,3);
        mapBlue(:,3)=[0:(1/maxImage):1]; 
        map = mapBlue;
%         save mapBlue mapBlue
%     else 
%         load mapBlue
%     end
end    
    %%%
if isequal(mapcolor,'Yellow') == 1
%         exsitingmap = exist('mapGreen.mat');
%     if exsitingmap == 2
%         load mapGreen
%     end
%         exsitingmap = exist('mapTrans.mat');
%     if exsitingmap == 2
%         load mapTrans
%     end
%     
%     exsitingmap = exist('mapRed.mat');
%     if exsitingmap == 2
%         load mapRed
%     end    
% 
%         exsitingmap = exist('mapBlue.mat');
%     if exsitingmap == 2
%         load mapBlue
%     end
%     
%     exsitingmap = exist('mapYellow.mat');
%     if exsitingmap == 0
        mapYellow=[];
        maxImage=double(max(max(I)));        
        mapYellow=zeros(maxImage+1,3);
        mapYellow(:,1)=[0:(1/maxImage):1]; 
        mapYellow(:,2)=[0:(1/maxImage):1];
        map =  mapYellow;
%         save mapYellow mapYellow
%     else 
%         load mapYellow
%     end
end
% mapcolor
% pause
end