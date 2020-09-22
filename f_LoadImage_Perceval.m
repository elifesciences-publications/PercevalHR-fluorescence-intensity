function [Projection,Projection2,Projection3, filename1,path1,filename2,filename3] = f_LoadImage_Cedric
% clear all
%Open files
[filename1,path1] = uigetfile('*_t1.TIF','Open channel 1''s first image');
cd(path1)
[filename2,path2] = uigetfile('*_t1.TIF','Open channel 2''s first image');
cd(path2)
[filename3,path3] = uigetfile('*_t1.TIF','Open channel 3''s first image');
cd(path3)
% filename2 = '100915-Slice1-1-Baseline_w2Perceval-2_t1.TIF';
 % %
        if exist([filename1(1:end-4) '_Projection.tif'])==2
            delete([filename1(1:end-4) '_Projection.tif'])
        end
        if exist([filename2(1:end-4) '_Projection.tif'])==2
            delete([filename2(1:end-4) '_Projection.tif'])
        end
        if exist([filename3(1:end-4) '_Projection.tif'])==2
            delete([filename3(1:end-4) '_Projection.tif'])
        end
%%        
        % Load Images Canal 1
        Projection=[];
        % Extract all files names with '_t' pattern
        numMetamorph = strfind(filename1,'_t');
        files = filename1(1:numMetamorph);
        Inames1 = dir([path1 '\' files '*.tif']);
            % open with respect of writing dates
                dates =[];
                daten=[];
                for i=1:numel(Inames1)
                    daten=[daten ; Inames1(i).datenum ];
                end
                [sdates,Ix]= sort(daten);
                for i=1:numel(Inames1)
                    Inames(i).name =  Inames1(Ix(i)).name;
                end
        % Get Images
        h = waitbar(0,'Please wait loading images channel 1...');
        for k=1:numel(Inames)
            filename = Inames(k).name;
            info = imfinfo(filename);
            I=[];
            J=[];
            for i=1:numel(info)
                I(:,:,i)= imread(filename,i);
%                 level = graythresh(I(i).data);
%                 I(:,:,i)=I(:,:,i)-level;
            end
            Projection(k).data = uint16(max(I,[],3));
%             figure(1); imshow(Projection(k).data,[])
            waitbar(k/numel(Inames))
        end
        close(h)
%         % % Rescale
%         % find max/min
%         mins = [];
%         maxs = [];
%         for i=1:numel(Projection)
%             Projection(i).data = double(Projection(i).data);
%             mins = [mins min(Projection(i).data(:))];
%             maxs = [maxs max(Projection(i).data(:))];
%         end
%         MinProjection = min(mins);
%         MaxProjection = max(mins);
%         for i=1:numel(Projection)
%             Projection(i).data = double(Projection(i).data);
%             Projection(i).data = uint16(2^16*((Projection(i).data - MinProjection)./ MaxProjection));
%         end
 %% 
        % Load Images Canal 2
        Projection2=[];
        Projection2D=[];
        numMetamorph = strfind(filename2,'_t');
        files = filename2(1:numMetamorph);
        Inames2_2 = dir([path2 '\' files '*.tif']);
            % open with respect of writing dates
                dates =[];
                daten=[];
                for i=1:numel(Inames2_2)
                    daten=[daten ; Inames2_2(i).datenum ];
                end
                [sdates,Ix]= sort(daten);
                for i=1:numel(Inames2_2)
                    Inames2(i).name =  Inames2_2(Ix(i)).name;
                end
        % Get images
        h = waitbar(0,'Please wait loading images canal 2...');
        for k=1:numel(Inames2)
            filename = Inames2(k).name;
            info = imfinfo(filename);
            I=[];
            J=[];
            for i=1:numel(info)
                I(:,:,i)= imread(filename,i);
%                 level = graythresh(I(i).data);
%                 I(i).data  =I(i).data-level;
            end
            Projection2(k).data = uint16(max(I,[],3));
%             figure(1); imshow(Projection(k).data,[])
            waitbar(k/numel(Inames2))
        end
        close(h)
% % %         % % Rescale
% % % %         % find max/min
%         mins = [];
%         maxs = [];
%         for i=1:numel(Projection2)
%             Projection2(i).data = double(Projection2(i).data);
%             mins = [mins min(Projection2(i).data(:))];
%             maxs = [maxs max(Projection2(i).data(:))];
%         end
%         MinProjection2 = min(mins);
%         MaxProjection2 = max(mins);
%         for i=1:numel(Projection2)
%             Projection2(i).data = double(Projection2(i).data);
%             Projection2(i).data = uint16(2^16*((Projection2(i).data - MinProjection2)./ MaxProjection2));
%         end
%%%%%%%%%%%%%%%
%%
        % Load Images Canal 3
        Projection3=[];
        numMetamorph = strfind(filename3,'_t');
        files = filename3(1:numMetamorph);
        Inames3_3 = dir([path3 '\' files '*.tif']);
            % open with respect of writing dates
                dates =[];
                daten=[];
                for i=1:numel(Inames3_3)
                    daten=[daten ; Inames3_3(i).datenum ];
                end
                [sdates,Ix]= sort(daten);
                for i=1:numel(Inames3_3)
                    Inames3(i).name =  Inames3_3(Ix(i)).name;
                end    
        % Get images
        h = waitbar(0,'Please wait loading images canal 3...');
        for k=1:numel(Inames3)
            filename = Inames3(k).name;
            info = imfinfo(filename);
            I=[];
            J=[];
            for i=1:numel(info)
                I(:,:,i)= imread(filename,i);
%                 level = graythresh(I(i).data);
%                 I(i).data  =I(i).data-level;
            end
            Projection3(k).data = uint16(max(I,[],3));
%             figure(1); imshow(Projection(k).data,[])
            waitbar(k/numel(Inames2))
        end
        close(h)
%         % Rescale
%         % find max/min
%         mins = [];
%         maxs = [];
%         for i=1:numel(Projection3)
%             Projection3(i).data = double(Projection3(i).data);
%             mins = [mins min(Projection3(i).data(:))];
%             maxs = [maxs max(Projection3(i).data(:))];
%         end
%         MinProjection3 = min(mins);
%         MaxProjection3 = max(mins);
%         for i=1:numel(Projection3)
%             Projection3(i).data = double(Projection3(i).data);
%             Projection3(i).data = uint16(2^16*((Projection3(i).data - MinProjection2)./ MaxProjection2));
%         end

%%
        %Align Images
%         [ProjectionD,Projection2D] = f_Stack_Alignment_Subpixel_2Channels(ProjectionD,Projection2D,1);
%         [ProjectionD,Projection2D] = f_Stack_Alignment_Subpixel_2Channels(ProjectionD,Projection2D,5);
%         [ProjectionD,Projection2D] = f_Stack_Alignment_Subpixel_2Channels(ProjectionD,Projection2D,10);
%         [Projection] = f_Stack_Alignment_Subpixel(Projection,10);
        
%         [Projection2,Projection] = f_Stack_Alignment_Subpixel_2Channels(Projection2,Projection,10);
%         [ProjectionD,Projection2D] = f_Stack_Alignment_Subpixel_2Channels(ProjectionD,Projection2D,10);
% %        
        % Save Images
%         cd(path3)
        h = waitbar(0,'Writing Images...');
        for i=1:numel(Projection)
            if i==1
                imwrite(Projection(i).data,[Inames(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none')
                imwrite(Projection2(i).data,[Inames2(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none')
                imwrite(Projection3(i).data,[Inames3(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none')
            else
                imwrite(Projection(i).data,[Inames(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none','WriteMode','append')
                imwrite(Projection2(i).data,[Inames2(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none','WriteMode','append')
                imwrite(Projection3(i).data,[Inames3(1).name(1:end-4) '_Projection.tif'],'tif','Compression','none','WriteMode','append')
            end
        waitbar(i/numel(Projection))
        end
        close(h)
