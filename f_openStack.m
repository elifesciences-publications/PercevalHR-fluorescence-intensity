
function [I,filename,PathName] = f_openStack(filename,PathName)

%     [filename,PathName] = uigetfile('*.tif','Select file');
    cd(PathName)
    hinfo = imfinfo(filename);
    size = numel(hinfo);
%     size = 50
    I=[];
    h = waitbar(0,'Please wait Definition images...');
    for i=1:size
        I(i).data = uint16(zeros(hinfo(1).Height,hinfo(1).Width));
        waitbar(i / size)
    end
    close(h)
    
    h = waitbar(0,'Please wait reading images...');
    for i=1:size
        I(i).data = imread(filename,i);
        waitbar(i / size)
    end
    close(h)