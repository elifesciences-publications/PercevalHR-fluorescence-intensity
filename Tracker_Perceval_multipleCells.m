function Tracker_Cedric
clc
close all
clear all

%%
MainFigure = figure('name','Main figure','numbertitle','on','Position',[100 100 250 250], 'tag', 'MainData');




Executeh  = uicontrol('Style', 'pushbutton','String','Get image',...
    'Position', [10 10 100 40], 'Callback',@get_image); %#ok<NASGU>
% 
Executeh  = uicontrol('Style', 'pushbutton','String','Get CANDLE Im',...
    'Position', [120 10 100 40], 'Callback',@get_image_CANDLE); %#ok<NASGU>

Executeh  = uicontrol('Style', 'pushbutton','String','Video Player',...
    'Position', [10 50 100 40], 'Callback',@MakeVideo); %#ok<NASGU>

Executeh  = uicontrol('Style', 'pushbutton','String','Segmentation',...
    'Position', [10 90 100 40], 'Callback',@I_segmentation); %#ok<NASGU>
% 
% Executeh  = uicontrol('Style', 'pushbutton','String','Analysis',...
%     'Position', [200 90 100 40], 'Callback',@Track_Selection2); %#ok<NASGU>
% 
Executeh  = uicontrol('Style', 'pushbutton','String','findcircles',...
    'Position', [120 130 100 40], 'Callback',@findcircles); %#ok<NASGU>

Executeh  = uicontrol('Style', 'pushbutton','String','Display Analysis',...
    'Position', [10 170 100 40], 'Callback',@Display_Analysis); %#ok<NASGU>

 
Executeh  = uicontrol('Style', 'pushbutton','String','Manual Tracking',...
    'Position', [10 130 100 40], 'Callback',@ManualTracking); %#ok<NASGU>

Executeh  = uicontrol('Style', 'pushbutton','String','Migratory Stage',...
    'Position', [10 210 100 40], 'Callback',@find_Migratory_Stage); %#ok<NASGU>



%%
    function get_image_CANDLE(MainFigure,eventdata)
        %% gET IMAGE
        MainData=guidata(MainFigure);
        % Selecte 1er-dernier timepoint et 2eme channel
        %input
        hey('fg')
        path = uigetdir()
        cd(path)
        if isempty(dir('*_Projection.tif'))==1
            [Projection,Projection2,Projection3, filename1,path1,filename2,filename3] = f_LoadImage_Perceval_CANDLE;
        else
            disp('hey')
            [filename1,path1] = uigetfile('*_Projection.tif','Open channel 1''s first image');
            cd(path1)
            [filename2,path2] = uigetfile('*_Projection.tif','Open channel 2''s first image');
            cd(path2)
            [filename3,path3] = uigetfile('*_Projection.tif','Open channel 3''s first image');
            cd(path3)
            [Projection] = f_openStack(fname1,path1);
            [Projection2] = f_openStack(fname2,path2);
            [Projection3] = f_openStack(fname3,path3);
        end
        % if previously computed.
        if exist('BW_Mask.tif.tif')
            Synapse_BW =tiffread('BW_Mask.tif');
            MainData.Synapse_BW = Synapse_BW;
        end
        if exist('Tracks_CellBody_Manual.txt')
            MainData.Tracks_CellBody_Manual =load('Tracks_CellBody_Manual.txt');
        end
%         if exist('Tracks.mat')
%             a =open('Tracks.mat');
%             MainData.Tracks = a.Tracks;
%         end         
        MainData.Channel1 = Projection;
        MainData.Synapse = Projection3;
        MainData.SEP = Projection2;
        guidata(MainFigure,MainData)
    end

    function get_image(MainFigure,eventdata)
        %% gET IMAGE
        MainData=guidata(MainFigure);
        % Selecte 1er-dernier timepoint et 2eme channel
        %input
%         path = uigetdir()
%         cd(path)
        if isempty(dir('*_Projection.tif'))==1
            [Projection,Projection2,Projection3, filename1,path1,filename2,filename3] = f_LoadImage_Perceval;
        else
            [filename1,path1] = uigetfile('*_Projection.tif','Open channel 1''s first image');
            cd(path1)
            [filename2,path2] = uigetfile('*_Projection.tif','Open channel 2''s first image');
            cd(path2)
            [filename3,path3] = uigetfile('*_Projection.tif','Open channel 3''s first image');
            cd(path3)
            [Projection] = f_openStack(filename1,path1);
            [Projection2] = f_openStack(filename2,path2);
            [Projection3] = f_openStack(filename3,path3);
        end
        % if previously computed.
        if exist('BW_Mask.tif') == 2
            Synapse_BW =tiffread('BW_Mask.tif');
            MainData.Synapse_BW = Synapse_BW;
        end
        if exist('Tracks_CellBody_Manual.txt') == 2
            MainData.Tracks_CellBody_Manual =load('Tracks_CellBody_Manual.txt');
        end
        if exist('Tracks_LeadingProcess_Manual.txt') == 2
            MainData.Tracks_LeadingProcess_Manual =load('Tracks_LeadingProcess_Manual.txt');
        end
        
%         if exist('Tracks.mat')
%             a =open('Tracks.mat');
%             MainData.Tracks = a.Tracks;
%         end         
        MainData.Channel1 = Projection;
        MainData.Synapse = Projection3;
        MainData.SEP = Projection2;
        guidata(MainFigure,MainData)
    end

    function I_segmentation2(MainFigure,eventdata)

        MainData=guidata (findobj('tag','MainData'));
        
        for i=1:numel(MainData.Synapse)
            I = MainData.Synapse(i).data;
            [MainData.Synapse_BW(i).data]= f_feature_extract(I,5,2);
        end
       %get positionlist
                % positionlist = [xcentroid ycentroid frame particule upleftx
                % uplefty x_width y_width Eccentricity MajorAxisLength MinorAxisLength]
                positionlist = [];
                for frame=1:numel(MainData.Synapse_BW)
                    %             BW = bwlabel(Synapse_BW(frame).data); %devrait enter bwlabael ds guidata
                    %             Synapse_BW(frame).data = BW;
                    BW = MainData.Synapse_BW(frame).data;
                    BW = bwlabel(BW);
                    STATS = regionprops(BW, 'Centroid');
                    plist=[];
                    for particule=1:numel(STATS)
                        plist(particule,:) = [STATS(particule).Centroid frame particule];
                    end
                    positionlist = [positionlist ; plist];
                end

                MainData.positionlist = positionlist;
                save positionlist positionlist
                guidata(findobj('tag','MainData'),MainData)
        
    end

    function I_segmentation(MainFigure,eventdata)
        %%
        MainData=guidata (findobj('tag','MainData'));

        f = figure('name','Segmentation','numbertitle','on','Position',[100 100 550 150],'tag', 'Segemntaion parameters');
        % Window W uicontrols
        Adaph   =uicontrol('Style', 'text', 'String', 'Adaptive threshold parameters',...
            'Position', [10 125 160 20], 'parent', f);
        slideW  =uicontrol('Style','slider','Position', [75,90,100,25],...
            'Value',25,'Min',1,'Max',60,'SliderStep',[0.05 0.5],...
            'Callback',@Segment_synapses , 'parent', f, 'BusyAction', 'cancel');
        Wtext   =uicontrol('Style', 'text', 'String', 'W',...
            'Position', [10 90 20 25], 'parent', f);
        Wh      =uicontrol('Style', 'text', 'String',...
            round(get(slideW,'Value')),'Position', [40 90 20 25], 'parent', f);
        % kSD uicontrols
        slidekSD =uicontrol('Style','slider','Position', [75,50,100,25],...
            'Value',2,'Min',0,'Max',20,'SliderStep',[0.01 0.25],...
            'Callback',@Segment_synapses, 'parent', f, 'BusyAction', 'cancel');
        kSDtext =uicontrol('Style', 'text', 'String', 'kSD',...
            'Position', [10 50 20 25], 'parent', f);
        kSDh    =uicontrol('Style', 'text', 'String', round(get(slidekSD,'Value')),...
            'Position', [40 50 25 25], 'parent', f);
        % time point uicontrols
        slidetime =uicontrol('Style','slider','Position', [75,10,100,25],...
            'Value',1,'Min',1,'Max',numel(MainData.SEP) ,'SliderStep',[1/numel(MainData.SEP) 3/numel(MainData.SEP)],...
            'Callback',@Segment_synapses, 'parent', f, 'BusyAction', 'cancel');
        timetext =uicontrol('Style', 'text', 'String', 'time',...
            'Position', [10 10 20 25], 'parent', f);
        timeh    =uicontrol('Style', 'text', 'String', round(get(slidetime,'Value')),...
            'Position', [40 10 25 25], 'parent', f);
        round(get(slidetime,'Value'))
        %clusters size uicontrols
        sizeh   =uicontrol('Style', 'text', 'String', 'Cluster properties parameters',...
            'Position', [200 125 160 20], 'parent', f);
        mintext   =uicontrol('Style', 'text', 'String', 'Min Cluster Size',...
            'Position', [200 95 85  20], 'parent', f);
        Minh      =uicontrol('Style', 'edit', 'String',...
            100,'Position', [290 95 30 20], 'parent', f);

        Maxtext   =uicontrol('Style', 'text', 'String', 'Max Cluster Size',...
            'Position', [200 65 85 20], 'parent', f);
        Maxh      =uicontrol('Style', 'edit', 'String',...
            5000,'Position', [290 65 30 20], 'parent', f);
        Ecctext   =uicontrol('Style', 'text', 'String', 'Eccentricity',...
            'Position', [200 35 85 20], 'parent', f);
        Ecch      =uicontrol('Style', 'edit', 'String',...
            0.97,'Position', [290 35 30 20], 'parent', f);
        %remove image overlay
        Removetxtim = uicontrol('Style', 'checkbox', 'String', 'remove Segmentation','Value',1,'Position', [350 10 130 25], 'parent', f,'Callback',@Segment_synapses);
        %Channel Selection
        ChangeChannel = uicontrol('Style', 'checkbox', 'String','Channel Synapse(on) vs SEP(off)','Value',1,'Position', [350 45 190 25], 'parent', f,'Tag','Changechannel');
        % Done button
        Runh = uicontrol('Style', 'pushbutton','String','Run',...
            'Position', [370 80 50 50], 'Callback',@Segment_synapses, 'parent', f);
        Doneh = uicontrol('Style', 'togglebutton','String','Done',...
            'Position', [425 80 50 50], 'Callback',@Segment_synapses, 'parent', f);

        %%

        %%
        function Segment_synapses(f,eventdata)

            W = round(get(slideW,'Value'));
            set( Wh, 'String',W)
            kSD = (get(slidekSD,'Value'));
            set( kSDh, 'String',kSD)
            time = round(get(slidetime,'Value'));
            set( timeh, 'String',time);
            if get(findobj('Tag','Changechannel'),'Value')==1
                I = MainData.Synapse(time).data;
            else
                I = MainData.SEP(time).data;
            end

            % convert to class double
            if strcmp(class(I),'double') == 0
                I2 = double(I)/double(max(max(I)));
            else
                I2 = I / max(max(I));
            end
            % define averaging window
%             Local_ROI = ones(W,W)/(W^2);
            Local_ROI = fspecial('disk',W);
            Local_Average = conv2(I2,Local_ROI,'same');
            %                 figure(9)
            %                 imshow(Local_Average,[])
            % calculate image with local average removed
            I_Offset = I2 - Local_Average;
            I_mean = mean2(I_Offset);
            I_SD = std2(I_Offset);
            It = I_Offset > I_mean+kSD*I_SD;

            figure(10)
            imshow(It,[])
            text(10,10,'Adaptive threshold It','color','w');

            %%% parameters
            minClustersize = str2num(get(Minh,'String'));
            maxClustersize = str2num(get(Maxh,'String'));
            maxEccentricity =str2num(get(Ecch,'String'));
            %%%%%%%%%%%%%%%%%%%%%%%

            BW1 = bwlabel(It);
            BW1  =  imclearborder(BW1);
            
            % figure, imshow(BW1, [0 0 0 ; jet(size(STATS,1))])
            STATS = regionprops(BW1, 'Area');
            allArea = [STATS.Area];
            idx = find(allArea <= maxClustersize ); %maxClustersize
            BW1 = ismember(BW1,idx);
            %                 figure(1); imshow(BW1,[])
            BW1 = bwlabel(BW1);
            STATS = regionprops(BW1, 'Area');
            allArea = [STATS.Area];
            idx = find(allArea >= minClustersize); %minClustersize
            BW1 = ismember(BW1,idx);
                   
            BW1 = imclose(BW1,strel('disk',10));
            %                 figure(4)
            cmap = makecolormaps(I, 'Trans');
            J = ind2rgb(I,cmap); BW1RGB = ind2rgb(BW1,[0 0 0 ; 1 0 0]);
            %                 imshow(BW1RGB+J)
            

            %remove image overlay
            if (get(Removetxtim,'Value') == get(Removetxtim,'Max'))
                figure(4)
                imshow(BW1RGB+J,'InitialMagnification',200)
            else
                % Checkbox is not checked-take approriate action
                figure(4)
                imshow(J,'InitialMagnification',200)
            end

            %Done button
            button_state = get(Doneh,'Value');
            if button_state == get(Doneh,'Max')
                h = waitbar(0,'Please wait Synapse BW(t)...');
                for frame=1:numel(MainData.Synapse)
                    W = round(get(slideW,'Value'));
                    kSD = (get(slidekSD,'Value'));
                    if get(findobj('Tag','Changechannel'),'Value')==1
                        I = MainData.Synapse(frame).data;
                    else
                        I = MainData.SEP(frame).data;
                    end
                    % convert to class double
                    if strcmp(class(I),'double') == 0
                        I2 = double(I)/double(max(max(I)));
                    else
                        I2 = I / max(max(I));
                    end

                    % define averaging window
%                     Local_ROI = ones(W,W)/(W^2);
                    Local_ROI = fspecial('disk',W);
                    Local_Average = conv2(I2,Local_ROI,'same');
                    % calculate image with local average removed
                    I_Offset = I2 - Local_Average;
                    I_mean = mean2(I_Offset);
                    I_SD = std2(I_Offset);
                    It = I_Offset > I_mean+kSD*I_SD;

                    %%% parameters
                    minClustersize = str2num(get(Minh,'String'));
                    maxClustersize = str2num(get(Maxh,'String'));
%                     maxEccentricity =str2num(get(Ecch,'String'));

                    BW1 = bwlabel(It);
                    BW1  =  imclearborder(BW1);
                    % figure, imshow(BW1, [0 0 0 ; jet(size(STATS,1))])
                    STATS = regionprops(BW1, 'Area');
                    allArea = [STATS.Area];
                    idx = find(allArea <= maxClustersize ); %maxClustersize
                    BW1 = ismember(BW1,idx);
                    %                 figure(1); imshow(BW1,[])
                    BW1 = bwlabel(BW1);
                    STATS = regionprops(BW1, 'Area');
                    allArea = [STATS.Area];
                    idx = find(allArea >= minClustersize); %minClustersize
                    BW1 = ismember(BW1,idx);
                    BW1 = imclose(BW1,strel('disk',10));
                    if frame == 1
                        imwrite(uint16(BW1),'BW_Mask.tif','tif','Compression','None')
                    else
                        imwrite(uint16(BW1),'BW_Mask.tif','tif','Compression','None','Writemode','append')
                    end
                 
                   figure(55);imshow(BW1,[])
                    %                                 pause
                    MainData.Synapse_BW(frame).data=BW1;
                    waitbar(frame/numel(MainData.Synapse))
                end
                close(h)

                %save BW with bwlabel.
                savename = 'Synapses_BW.tif';
                if exist(savename)
                    delete(savename)
                end

%                
                positionlist = [];
                for frame=1:numel(MainData.Synapse_BW)
                    %             BW = bwlabel(Synapse_BW(frame).data); %devrait enter bwlabael ds guidata
                    %             Synapse_BW(frame).data = BW;
                    BW = MainData.Synapse_BW(frame).data;
                    BW = bwlabel(BW);
                    STATS = regionprops(BW, 'Centroid');
                    plist=[];
                    for particule=1:numel(STATS)
                        plist(particule,:) = [STATS(particule).Centroid frame particule];
                    end
                    positionlist = [positionlist ; plist];
                end

%                 MainData.Synapse_BW = Synapse_BW;
                MainData.positionlist = positionlist;
                save positionlist positionlist

                guidata(findobj('tag','MainData'),MainData)
                close(2)
                close(4)
                close(10)
                close(55)
            end
        end
        waitfor(f)
    end

    function TrackSynapse(MainFigure,eventdata)
        %%
        MainData = guidata(findobj('tag','MainData'));
        positionlist = MainData.positionlist;
        
        Trackparam = figure('name','Track Parameters','numbertitle','off','Position',[100 100 500 150], 'tag', 'trackParam');

        %uicontrols
        Maxdisptext     =uicontrol('Style', 'text', 'String', 'Maximum displacement',...
            'Position', [10 115 150 15]); %#ok<NASGU>
        Maxdisph        =uicontrol('Style', 'edit', 'String',5,...
            'Position', [170 115 25 15], 'tag', 'MaxDisph');

        memtext         =uicontrol('Style', 'text', 'String', 'Memory size',...
            'Position', [10 73 150 15]);  %#ok<NASGU>
        memh            =uicontrol('Style', 'edit', 'String',...
            5,'Position', [170 73 25 15], 'tag', 'memh');

        goodenoughtext   =uicontrol('Style', 'text', 'String', 'Good enough',...
            'Position', [10 30 150 15]);  %#ok<NASGU>
        goodenoughh      =uicontrol('Style', 'edit', 'String',...
            25,'Position', [170 30 25 15], 'tag', 'GoodEnough');

        %Callback buttons
        Executeh  = uicontrol('Style', 'pushbutton','String','Track',...
            'Position', [210 85 50 50], 'Callback',@f_Track); %#ok<NASGU>

        % ExecuteAll  = uicontrol('Style', 'pushbutton','String','Track All',...
        %     'Position', [500 30 50 40], 'Callback',@f_Track_All); %#ok<NASGU>

        Executeh2 = uicontrol('Style', 'togglebutton','String','Show Tracks',...
            'Position', [275 85 100 50], 'Callback',@ShowAllTrackmovie, 'Enable','on', 'tag','showAllTrack');

        Executeh3 = uicontrol('Style', 'pushbutton','String','Done',...
            'Position', [210 25 100 50], 'Callback',@CloseTrack, 'Enable','on', 'tag','DoneTrack');

        %         Executeh4 = uicontrol('Style', 'pushbutton','String','Connect Tracks',...
        %             'Position', [575 25 100 50], 'Callback',@Connect, 'Enable','on', 'tag','Tracks_Connector');


        %%
        function f_Track(Trackparam ,eventdata)  %#ok<INUSD>
            %%
            % Get Positionlist, Tracking Parameter
            % dim,quiet,maxdisplacement,memory,goodenough.
            positionlist_Track = positionlist(:,1:3);
            positionlist_Track = sortrows(positionlist_Track,3);
            maxdisp     =str2num(get(Maxdisph,'String'));
            param.mem   =str2num(get(memh,'String'));
            param.good  =str2num(get(goodenoughh,'String'));
            param.dim   = 2;
            param.quiet = 0;

            %Track function
            Tracks= [];
            Tracks = track(positionlist_Track,maxdisp,param);

        
            MainData.Tracks = Tracks;
            guidata(findobj('tag','MainData'),MainData);
            save Tracks Tracks

            ShowAllTrackmovie
        end

        function ShowAllTrackmovie(Trackparam,eventdata) %#ok<INUSD>

            MainData = guidata(findobj('tag','MainData'));
            Synapse = MainData.Synapse;
            Tracks  = MainData.Tracks;

            if get(findobj('tag','showAllTrack'),'value') == 0
                figure(5)
                imshow(Synapse(1).data,[])
                hold on
                for i=1:max(Tracks(:,4))
                    ided = Tracks(find(Tracks(:,4)==i),:);
                    for j = 1:size(ided,1)-1
                        if ided(j+1,3)- ided(j,3) == 1 %Pour frame qui manque
                            plot(ided(j:j+1,1),ided(j:j+1,2),'Color','r','LineWidth',3)
                        end
                    end
                end
            end
            
            while get(findobj('tag','showAllTrack'),'value')
              
                if size(findobj('tag', 'trackDisplay'),1)> 0
                    close(findobj('tag', 'trackDisplay'))
                end
                figure('Name','Show Tracked','tag', 'trackDisplay')
%                 set(0,'CurrentFigure',findobj('tag', 'trackDisplay'))
                axesI = axes('parent', findobj('tag', 'trackDisplay'));
                image = imshow(Synapse(1).data, [], 'InitialMagnification', 'fit', 'parent', axesI);
                %time display
                timetext = text(2,size(Synapse(1).data,1)-12,'0','FontSize',12, 'color', 'w' , 'parent', axesI);
                for i=1:numel(Synapse)
                    set(image, 'CData', Synapse(i).data);
                    hold on
                    delete(findobj('tag','linetag'))
                    for j=1:max(Tracks(:,4))
                        ided = Tracks(Tracks(:,4)==j,:);
                        try
                        line(ided(1:find(ided(:,3)==i),1),ided(1:find(ided(:,3)==i),2),...
                            'Color','r','LineWidth',3,'tag','linetag','parent',axesI)
                        catch ME
                            dips('OUps')
                        end
                    end
                    time=strcat(num2str(i, '%05.2f'));
                    set(timetext,'String', time);
                    drawnow
                    pause(0.001)
                end
            end
            
        end

        function CloseTrack(Trackparam ,eventdata)
            close(findobj('tag', 'trackParam'))
            try
                t=get(5);
                close(5)
            catch ME;
            end
        end

    end

    function Track_Selection2(MainFigure,eventdata)

        QD=guidata (findobj('tag','MainData'));
        Tracks_Final = QD.Tracks;
        Tracks_Final = sortrows(Tracks_Final,[4 3]);
        %%
        scrsz = get(0,'ScreenSize');
        hfscrsz = 0.5*scrsz;
        %
        try
            t = get(findobj('tag', 'SingleParam'));
            close(findobj('tag', 'SingleParam'))
        catch ME
        end

        %Draw Mask
        figure(66)
        title('define Regions Of Interest')
        uicontrol('Style','ToggleButton','Position',[5 5 50 50],'String','Done','Value',0,'tag','DoneRegions')
        [Gmap] = makecolormaps(QD(1).Synapse(1).data, 'Trans');
        IRGB=ind2rgb(QD(1).Synapse(1).data, Gmap);
        BW_Bckg = zeros(size(IRGB,1),size(IRGB,2));

        while get(findobj('tag','DoneRegions'),'Value')== 0
            % Local Translocation
            imshow(IRGB);
            hold on
            for i=1:max(Tracks_Final(:,4))
                ided = Tracks_Final(find(Tracks_Final(:,4)==i),:);
                plot(ided(:,1),ided(:,2),'Color','r','LineWidth',3)
            end
            text(10,15,'Select ROIs','color', 'w')
            h = imfreehand(gca);
            api = iptgetapi(h);
            position= api.getPosition();
            BW = poly2mask(position(:,1), position(:,2), size(IRGB,1), size(IRGB,2));
            BW_Bckg = BW_Bckg + BW;
            BWRGB = ind2rgb(BW,[0 0 0 ; 0 1 1]);
            IRGB = BWRGB + IRGB;
        end
        %         imwrite(BW_Bckg,'GluA1SEP_BW_Bckg.tif','tif','Compression','none')
        close(66)
        %%

        % Keeps tracks under ROI
        [r,c]= find(BW_Bckg>0);
        xy = [c r];
        Tracks_round = round(Tracks_Final);
        [tf] = ismember(Tracks_round(:,1:2),xy,'rows');
        Tracks_Final= Tracks_Final(tf,:);
        kept = unique(Tracks_Final(:,4));

        Tracks_kept=[];
        for i=1:size(kept,1)
            Ided = Tracks_Final(Tracks_Final(:,4)==kept(i),:);
            Ided(:,4)=i;
            Tracks_kept=[Tracks_kept ; Ided];
        end
     
        Tracks_Final =Tracks_kept;


        %%
        SingleParam = figure('name','Single Track Selection & Verification','numbertitle','off','Position',[16 50 hfscrsz(3) hfscrsz(4)], 'tag', 'SingleParam');

        %Callback buttons
        Excuteh3 = uicontrol('Style', 'pushbutton','String','Play/rePlay',...
            'Position', [10 10 70 50], 'Value',0,'Callback',@Play_Stop);

        Executeh  = uicontrol('Style', 'togglebutton','String','Next',...
            'Position', [80 10 70 50],'tag', 'Nexttag');

        %         Executeh2 = uicontrol('Style', 'checkbox','String','Show Gaussian Fit',...
        %             'Position', [10 130 120 15], 'tag', 'ShowGaussian','enable','off'); %#ok<NASGU>

        ExecuteAll  = uicontrol('Style', 'togglebutton','String','Delete',...
            'Position', [150 10 70 50], 'tag', 'deletetag');

        uicontrol('Style','text','String','Track number 1',...
            'Position', [570 10 100 25], 'tag', 'tracknum');

        %             Blinkh  = uicontrol('Style', 'Checkbox','String','Blinking Detected',...
        %                 'Position', [10 150 120 15], 'tag', 'Blinkh');

        %             Excuteh3 = uicontrol('Style', 'pushbutton','String','Bored ?',...
        %                 'Position', [555 5 50 25], 'Value',0,'Callback','f_mtetris');
        %
        Excuteh3 = uicontrol('Style', 'togglebutton','String','Skip Selection',...
            'Position', [695 10 75 25],'tag','SkipSelectionh');

        %%
        handlePlaySpeed = uicontrol ('style', 'slide', 'position', [400 5 125 25], 'Min', 1, 'Max', 60, 'Sliderstep', [1/50 5/50], 'value', 60,'tag','slideFPS');
        handleTxtPlaySpeed = uicontrol ('style', 'text', 'position', [300 5 100 25], 'string', 'Frame Rate:');
        handleDspPlaySpeed = uicontrol ('style', 'text', 'position', [525 5 20 25], 'string', '60','tag', 'DspFPS');

      
        %%
        figure(5)
        imshow(QD.Synapse(1).data,[])
        hold on
        for i=1:max(Tracks_Final(:,4))
            ided = Tracks_Final(find(Tracks_Final(:,4)==i),:);
            for j = 1:size(ided,1)-1
                if ided(j+1,3)- ided(j,3) == 1 %Pour frame qui manque
                    plot(ided(j:j+1,1),ided(j:j+1,2),'Color','r','LineWidth',3)
                end
            end
            text(ided(1,1), ided(1,2), num2str(ided(1,4)),'color','y')
        end



        function Play_Stop(SingleParam,evendata)
            keeper= [];

            for which = 1:max(Tracks_Final(:,4))
                %                 which
                set(findobj('tag', 'tracknum'),'String',['Track number ' num2str(which)])

                IndicesInTracks_Final = find(Tracks_Final(:,4) == which);
                Track = Tracks_Final(IndicesInTracks_Final,:);
                % Image square cut for Trajectory
                maxx = round(max(Track(:,1))); maxy = round(max(Track(:,2)));
                minx = round(min(Track(:,1))); miny = round(min(Track(:,2)));
                offsetx = 5; offsety = 5;
                %effet de bord
                if miny-offsety <= 0;                   offsety=0; end
                if maxy+offsety > size(QD.Synapse(1).data,1);   offsety=size(QD.Synapse(1).data,1)-maxy; end
                if minx-offsetx <= 0;                   offsetx=0; end
                if maxx+offsetx > size(QD.Synapse(1).data,2);   offsetx=size(QD.Synapse(1).data,2)-maxx; end
                %%%
                offsetplotx = 50; offsetploty = 50;
                %effet de bord
                if miny-offsetploty <= 0;                   offsetploty=0; end
                if maxy+offsetploty > size(QD.Synapse(1).data,1);   offsetploty=size(QD.Synapse(1).data,1)-maxy; end
                if minx-offsetplotx <= 0;                   offsetplotx=0; end
                if maxx+offsetplotx > size(QD.Synapse(1).data,2);   offsetplotx=size(QD.Synapse(1).data,2)-maxx; end
                %%
                i = Track(1,3);
                I = QD.Synapse(i).data;
                axesIall = axes('parent', findobj('tag', 'SingleParam'),'position',[(260/hfscrsz(3)) 30/hfscrsz(4) 400/hfscrsz(3) 400/hfscrsz(4)]);
                image = imshow(I((miny-offsety:maxy+offsety),(minx-offsetx:maxx+offsetx)),[],'InitialMagnification', 'fit', 'parent', axesIall);
                timetext = text(2,2,'0','FontSize',10, 'color', 'w' , 'parent', axesIall);
                axesIfit = axes('parent', findobj('tag', 'SingleParam'), 'position',[(35/hfscrsz(3)) 80/hfscrsz(4) 200/hfscrsz(3) 200/hfscrsz(4)],...
                    'visible','off');

                while get(findobj('tag','Nexttag'),'value')==0
                    %                         while xor(get(findobj('tag','Nexttag'),'value')==0,get(findobj('tag','ExtraSynQD'),'value')==0)==0

                    if i >= max(Track(:,3));
                        i=Track(1,3);
                    end

                    if get(findobj('tag', 'deletetag'),'value')== 1
                        set(findobj('tag','deletetag'),'value',0)
                        break
                    end

                    I = QD.Synapse(i).data;
                    Isq = I((miny-offsety:maxy+offsety),(minx-offsetx:maxx+offsetx));
                    set(image, 'CData', Isq);
                    time=strcat(num2str(i));
                    set(timetext,'String', time);
                    delete(findobj('tag', 'LigneTracks'));
                    %doit faire jaune pour blink...
                    line(Track(find(Track(:,3) <= i),1)-minx+offsetx+1,Track(find(Track(:,3) <= i),2)-miny+offsety+1, 'Color', [1 0 0],'parent',...
                        axesIall, 'tag', 'LigneTracks') ;


                    FPS = round(get (findobj('tag','slideFPS'), 'value'));
                    set(findobj('tag', 'DspFPS'), 'string', int2str(FPS))
                    pauseTime = 1/FPS;
                    pause(pauseTime)
                    i=i+1;
                end

                if get(findobj('tag','Nexttag'),'value')==1
                    keeper = [keeper which];
                end

                set(findobj('tag','Nexttag'),'value',0)
                %                     set(findobj('tag','deletetag'),'value',0)
                set(timetext,'String', []);
                set(image, 'CData', []);

                if get(findobj('tag','SkipSelectionh'),'value')==1
                    tracknum = unique(Tracks_Final(:,4));
                    % doit choisir les points après les which
                    keeper = tracknum';
                    try t= get(5); close(5)
                    catch ME; end
                    break
                end
            end

            close(findobj('tag', 'SingleParam'))
            Tracks_Final = f_Keeptracks(Tracks_Final, keeper);
            Tracks_Final = Tracks_Final(:,1:4);
            %mesure distance
            Tracks_Final_distance = [];
            for k=1:size(unique(Tracks_Final(:,4)),1)
                Ided = Tracks_Final(Tracks_Final(:,4)==k,:);
                for l=1:size(Ided,1)-1
                    d = sqrt((Ided(l,1)-Ided(l+1,1))^2 + (Ided(l,2)-Ided(l+1,2))^2);
                    Ided(l+1,5)=d;
                end
                Tracks_Final_distance = [Tracks_Final_distance  ; Ided ];
            end

            save ('Tracks_Final.txt', 'Tracks_Final_distance','-double','-ascii')
            QD.Tracks_Final_distance = Tracks_Final_distance;
            %             QD.Tracks_unkept = Tracks_unkept;
            guidata (findobj('tag','MainData'),QD);
            pause(0.01)
        end

    end

    function Analysis_Montage(MainFigure,enventdata)
        
        QD=guidata (findobj('tag','MainData'));
        Tracks_Final = QD.Tracks;
        Tracks_Final = sortrows(Tracks_Final,[4 3]);
        scrsz = get(0,'ScreenSize');
        hfscrsz = 0.5*scrsz;
        %
        try
            t = get(findobj('tag', 'DoneRegions'));
            close(findobj('tag', 'DoneRegions'))
        catch ME
        end

        %Draw Mask
        figure(66)
        title('define Regions Of Interest')
        uicontrol('Style','ToggleButton','Position',[5 5 50 50],'String','Done','Value',0,'tag','DoneRegions')
        [Gmap] = makecolormaps(QD(1).Synapse(1).data, 'Trans');
        IRGB=ind2rgb(QD(1).Synapse(1).data, Gmap);
        BW_Bckg = zeros(size(IRGB,1),size(IRGB,2));

        while get(findobj('tag','DoneRegions'),'Value')== 0
            % Local Translocation
            imshow(IRGB);
            hold on
            for i=1:max(Tracks_Final(:,4))
                ided = Tracks_Final(find(Tracks_Final(:,4)==i),:);
                plot(ided(:,1),ided(:,2),'Color','r','LineWidth',3)
            end
            text(10,15,'Select ROIs','color', 'w')
            h = imfreehand(gca);
            api = iptgetapi(h);
            position= api.getPosition();
            BW = poly2mask(position(:,1), position(:,2), size(IRGB,1), size(IRGB,2));
            BW_Bckg = BW_Bckg + BW;
            BWRGB = ind2rgb(BW,[0 0 0 ; 0 1 1]);
            IRGB = BWRGB + IRGB;
        end
        %         imwrite(BW_Bckg,'GluA1SEP_BW_Bckg.tif','tif','Compression','none')
        close(66)
        %%
        % Keeps tracks under ROI
        [r,c]= find(BW_Bckg>0);
        xy = [c r];
        Tracks_round = round(Tracks_Final);
        [tf] = ismember(Tracks_round(:,1:2),xy,'rows');
        Tracks_Final= Tracks_Final(tf,:);
        kept = unique(Tracks_Final(:,4));

        Tracks_kept=[];
        for i=1:size(kept,1)
            Ided = Tracks_Final(Tracks_Final(:,4)==kept(i),:);
            Ided(:,4)=i;
            Tracks_kept=[Tracks_kept ; Ided];
        end
        Tracks_Final =Tracks_kept;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        I_Before = [];
        I_After = [];
        keeper = [];
        figure(2)
        set(2,'Position',[706 91 172 73])
        uicontrol('Style', 'togglebutton','String','Next','Position', [10 10 70 50],'tag', 'Nexttag2');
        uicontrol('Style', 'togglebutton','String','Delete','Position', [80 10 70 50], 'tag', 'deletetag2')
        for i=1:max(Tracks_Final(:,4))
            Ided = Tracks_Final(Tracks_Final(:,4)==i,1:4);
            if size(Ided,1) > 1
                Ided1 = Ided(1,:);
                [Roi1] = f_cut_square_on_Image(Ided1(1:2), QD.SEP(Ided1(1,3)).data, 2);

                Ided2 = Ided(2,:);
                [Roi2] = f_cut_square_on_Image(Ided2(1:2), QD.SEP(Ided2(1,3)).data, 2);

                Imean1 = double(mean(Roi1(:)));
                Imean2 = double(mean(Roi2(:)));

                figure(3)
%                 hold on
                plot([1 2],[Imean1 Imean2],'x-k')

                I_Before = [I_Before Imean1];
                I_After = [I_After Imean2];

                %%%%%%%%%%
                Montage = f_MakeMontage(Ided, QD.SEP,20);
                Montage = imresize(Montage,2);
                figure(10)
                imshow(Montage,[],'initialMagnification',200)

                Montage2 = f_MakeMontage(Ided, QD.Synapse,20);
                Montage2 = imresize(Montage2,2);
                figure(11)
                imshow(Montage2,[],'initialMagnification',200)
                %%
                while get(findobj('tag','Nexttag2'),'value')==0

                    if get(findobj('tag', 'deletetag2'),'value')== 1
                        set(findobj('tag','deletetag2'),'value',0)
                        break
                    end

                    pause(0.001)
                end

                if get(findobj('tag','Nexttag2'),'value')==1
                    k=   [i Imean1 Imean2];
                    keeper = [keeper ; k];
                    imwrite(uint16((Montage*65335)/max(Montage(:))),['Montage ' num2str(i) '.tif'],'Compression','none')
                end
                set(findobj('tag','Nexttag2'),'value',0)
            end
            %
        end
        
Ratio = mean(keeper(:,3)) / mean(keeper(:,2))
save keeper keeper
save Ratio Ratio

    end

    function MakeVideo(MainFigure,eventdata)

        MainData=guidata(findobj( 'tag', 'MainData'));
        %     keeper = MainData.keeper;
        %     Tracks = MainData.Tracks;
        %         SEP = MainData.SEP;
        Synapse = MainData.Synapse;
        try
            Tracks = MainData.Tracks_Final_distance;
        catch ME
        end
        out9 =figure(9);
        set(9,'name','Video Player','Position',[500 200 600 500])
        %%
        %Channel Selection
        %         uicontrol('Style','listbox','Position', [5 120  100 30],'String','Synapse','tag','ChannelTag','Value',1)%,'Callback',@loopplay);
        %         stringFile{1}='Synapse';
        %         stringFile{2}='SEP';
        %         set(findobj('tag','ChannelTag'),'String',stringFile);

        %Frame buttons
        uicontrol('Style','slider','Position', [120 5  75 15],'Value',1,'Min',1,'Max',numel(Synapse),'SliderStep',[1/numel(Synapse) 2/numel(Synapse)],'tag','FrameSlider','Callback',@showsynapse);
        ph = uicontrol('Style', 'text', 'String', ['Frame ' num2str(round(get(findobj('tag','FrameSlider'),'Value')))] ,'Position', [5 5 100 15],'tag','Frameslidertext');

        %Colormap Buttons
        uicontrol('Style','slider','Position', [120 25  75 15],'Value',0.9,'Min',0.5,'Max',2,'SliderStep',[0.01 0.05],'tag','MinmapSlider','Callback',@showsynapse);
        ph = uicontrol('Style', 'text', 'String', ['Min ' num2str((get(findobj('tag','MinmapSlider'),'Value')))] ,'Position', [5 25 100 15],'tag','Colormapslidertext');
        uicontrol('Style','slider','Position', [120 45  75 15],'Value',1.5,'Min',0,'Max',4,'SliderStep',[0.01 0.05],'tag','MaxmapSlider','Callback',@showsynapse);
        ph = uicontrol('Style', 'text', 'String', ['Max ' num2str((get(findobj('tag','MaxmapSlider'),'Value')))] ,'Position', [5 45 100 15],'tag','Colormapslidertext');

        %PLay buttons
        uicontrol('Style','Togglebutton','Position', [5 70  60 50],'String','Play','Value',0,'tag','TogglePlay','Callback',@loopplay);
        %         uicontrol('Style','edit','Position', [60 50  50 20],'String',['1:' num2str(numel(Synapse))],'Value',0,'tag','EditPlay');
        %         uicontrol('Style','text','Position', [60 75  55 20],'String','loop frame','Value',0,'tag','texttPlay');

        %RectangleonROISynapse Checkbox
        uicontrol('Style','text','Position', [200 25  90 15],'String','Show Tracks','tag','Rectangletext')%
        uicontrol('Style','text','Position', [200 5  50 15],'String','Selected')%
        uicontrol('Style','checkbox','Position', [255 5  15 15],'Value',0,'tag','RectangleCheckboxSEP','Callback',@RectangleonROISEP);
        uicontrol('Style','text','Position', [280 5  40 15],'String','All')%
        uicontrol('Style','checkbox','Position', [325 5  15 15],'Value',0,'tag','RectangleCheckbox','Callback',@RectangleonROISynapse);

        %select local translocation regions
        %         uicontrol('Style','Pushbutton','Position', [5 155 100 25],'String','Translo Select','Value',0,'Callback',@SelectTransloRegions);

        %Make AVI
        uicontrol('Style','Togglebutton','Position', [5 120  60 50],'String','Make avi','Value',0,'tag','avih','Callback',@makeavi);

        %%

        function showsynapse(out9,eventdata)
            time = round(get(findobj('tag','FrameSlider'),'Value'));
            set(findobj('tag','Frameslidertext'), 'String', ['Frame ' num2str(round(get(findobj('tag','FrameSlider'),'Value')))])
            if time == numel(Synapse)
                set(findobj('tag','Frameslidertext'), 'String','Frame 1')
                set(findobj('tag','FrameSlider'),'Value',1)
            end
            svalue = stretchlim(Synapse(time).data);
            deltamin = get(findobj('tag','MinmapSlider'),'Value');
            deltamax = get(findobj('tag','MaxmapSlider'),'Value');
            J = imadjust(Synapse(time).data,[deltamin*svalue(1); deltamax*svalue(2)]);
            imshow(J)
            if get(findobj('tag','RectangleCheckboxSEP'), 'Value')==1
                RectangleonROISEP
            end
        end

        function loopplay(out9,eventdata)
            %             time = round(get(findobj('tag','FrameSlider'),'Value'));

            time=0;
            while get(findobj('tag','TogglePlay'),'Value') == 1
                time=time+1;
                if time > numel(Synapse)
                    time=1;
                end
                set(findobj('tag','Frameslidertext'), 'String', ['Frame ' num2str(round(time))])
                %                 time = times(i);
                %                 set(findobj('tag','Colormapslidertext'), 'String', ['Colormap ' num2str(round(get(findobj('tag','ColormapSlider'),'Value')))])
                set(findobj('tag','FrameSlider'),'Value',time)
                set(findobj('tag','FrameSlidertext'),'String',['Frame ' num2str(time)])
%                 svalue = stretchlim(Synapse(time).data);
%                 deltamin = get(findobj('tag','MinmapSlider'),'Value');
%                 deltamax = get(findobj('tag','MaxmapSlider'),'Value');
%                 J = imadjust(Synapse(time).data,[deltamin*svalue(1); deltamax*svalue(2)]);
%                 imshow(J)
                imshow(Synapse(time).data,[])



                if get(findobj('tag','RectangleCheckbox'), 'Value')==1
                    RectangleonROISynapse
                end
                if get(findobj('tag','RectangleCheckboxSEP'), 'Value')==1
                    RectangleonROISEP
                end

                pause(0.00001)
            end

        end

        %%% Rectangle on ROI
        function RectangleonROISynapse(out9,eventdata)
            MainData=guidata(findobj( 'tag', 'MainData'));
            %             Tracks = MainData.Tracks_Final_distance;
            Tracks = MainData.Tracks;
            delete (findobj('tag','linetagsunkept'));
            time = round(get(findobj('tag','FrameSlider'),'Value'));
            hold on
            for i=1:max(Tracks(:,4))
                ided = Tracks(find(Tracks(:,4)==i),:);
                if time <= max(ided(:,3))
                    line(ided(ided(:,3)<= time,1),ided(ided(:,3)<= time,2),'color','y','tag','linetagsunkept')
                end
            end
            hold off
        end

        function RectangleonROISEP(out9,eventdata)
            MainData=guidata(findobj( 'tag', 'MainData'));
            Tracks = MainData.Tracks_Final_distance;
            delete (findobj('tag','linetags'));
            time = round(get(findobj('tag','FrameSlider'),'Value'));
            hold on
            for i=1:max(Tracks(:,4))
                ided = Tracks(find(Tracks(:,4)==i),:);
                if time <= max(ided(:,3))
                    line(ided(ided(:,3)<= time,1),ided(ided(:,3)<= time,2),'color','r','tag','linetags')
                end
            end
            hold off
        end


        function makeavi(out9,eventdata)
            MainData=guidata(findobj( 'tag', 'MainData'));

            if get(findobj('tag','TogglePlay'),'Value') == 1
                set(findobj('tag','TogglePlay'),'Value',0)
            end
            figure(666)


            %             scrsz = get(0,'ScreenSize');
            mov2 = avifile('Tracker.avi','compression','Cinepak','quality',100,'fps',20);
            %             figure(2)
            %             set(666,'Position',0.7*scrsz)
            %             axes('Position',[0 0 1 1])


            for time=1:numel(MainData.Synapse)
                set(findobj('tag','FrameSlider'),'Value',time)

                %                 set(findobj('tag','Frameslidertext'), 'String', ['Frame ' num2str(round(time))])
                %                 %                 time = times(i);
                %                 %                 set(findobj('tag','Colormapslidertext'), 'String', ['Colormap ' num2str(round(get(findobj('tag','ColormapSlider'),'Value')))])
                %                 set(findobj('tag','FrameSlider'),'Value',time)
                %                 set(findobj('tag','FrameSlidertext'),'String',['Frame ' num2str(time)])
                svalue = stretchlim(Synapse(time).data);
%                 deltamin = get(findobj('tag','MinmapSlider'),'Value');
%                 deltamax = get(findobj('tag','MaxmapSlider'),'Value');
%                 J = imadjust(Synapse(time).data,[deltamin*svalue(1); deltamax*svalue(2)]);
%                 imshow(J)
                imshow(Synapse(time).data,[])
                text(10,10,['Frame = ' num2str(time)],'color','w')
                if get(findobj('tag','RectangleCheckbox'), 'Value')==1
                    RectangleonROISynapse
                end
                if get(findobj('tag','RectangleCheckboxSEP'), 'Value')==1
                    RectangleonROISEP
                end

                pause(0.00001)
                A=getframe(gca);
                if time==1
                    width = size(A.cdata,1); height = size(A.cdata,2);
                end
                A.cdata = A.cdata(2:width-2,2:height-2,:);
                mov2=addframe(mov2,A);
            end
            mov2=close(mov2);
            close(666)
        end



    end


    function findcircles(MainFigure, eventdata)
       MainData=guidata (findobj('tag','MainData')); 
       I = MainData.Synapse; 

%        figure(13)
        MainData=guidata (findobj('tag','MainData'));
        f = figure('name','Find Circles','numbertitle','on','Position',[100 100 550 150],'tag', 'Segemntaion parameters');
        % Window W uicontrols
        uicontrol('Style', 'text', 'String', 'Define Radius',...
            'Position', [10 125 160 20], 'parent', f);
        uicontrol('Style', 'text', 'String', 'Min',...
            'Position', [10 90 25 25], 'parent', f);  
        uicontrol('Style', 'edit', 'String',...
            '15','Position', [40 90 25 25], 'parent', f,'tag', 'MinRadiusTag');
        uicontrol('Style', 'edit', 'String',...
            '50','Position', [70 90 25 25], 'parent', f,'tag', 'MaxRadiusTag');
        uicontrol('Style', 'text', 'String', 'Max',...
            'Position', [100 90 25 25], 'parent', f);
        uicontrol('Style', 'text', 'String', 'S',...
            'Position', [130 90 25 25], 'parent', f);
        uicontrol('Style', 'edit', 'String',...
            '0.9','Position', [160 90 25 25], 'parent', f,'tag', 'SensitivityTag');
        

        Runh = uicontrol('Style', 'pushbutton','String','Run',...
            'Position', [370 80 50 50], 'Callback',@findcircles2, 'parent', f);
        Doneh = uicontrol('Style', 'togglebutton','String','Done',...
            'Position', [425 80 50 50], 'Callback',@findcircles2, 'parent', f);
%%       
       
        function findcircles2(FindCircleparam ,eventdata)  
            figure(55555)
            hold on
            CirclePositionList = [];
            for i=1:numel(I)
            imshow(I(i).data,[])
            minRadius = str2double(get(findobj('tag', 'MinRadiusTag'),'String'));
            maxRadius = str2double(get(findobj('tag', 'MaxRadiusTag'),'String'));
            Sens = str2double(get(findobj('tag', 'SensitivityTag'),'String'));
                [centers, radii, metric] = imfindcircles(I(i).data,[minRadius maxRadius],'Sensitivity',Sens);
                try
                    CirclePositionList = [CirclePositionList ; centers radii i]; %ishhh selction ceneter 1, pas top
                catch ME
                    disp(num2str(i))
                end
                % Draw the five strongest circle perimeters.
                viscircles(centers, radii,'EdgeColor','b');
                %             viscircles(centers2, radii2,'EdgeColor','r');
                pause(0.001)
            end
            close(findobj('name','Find Circles'))
            %%
            
            %creates an interpolated posilist
            Tracks_inter = zeros(numel(I),4);
            Tracks_inter(:,4) =(1:numel(I))';
            for i=1:numel(I)
                try
                    Tracks_inter(i,:) = CirclePositionList(find(CirclePositionList(:,4)==i),:);
                catch ME
                end
            end
            for i=2:numel(I)-1
                if sum(Tracks_inter(i,1:3)) == 0
                    Tracks_inter(i,1:3) = (Tracks_inter(i-1,1:3) + Tracks_inter(i+1,1:3))/2;
                end
            end
            CirclePositionList =Tracks_inter;
            maxdisp     =20;
            param.mem   =2;
            param.good  =50;
            param.dim   = 2;
            param.quiet = 0;
            CirclePositionList = track(CirclePositionList,maxdisp,param);
            
            save('CirclePositionList.txt','CirclePositionList','-ascii')
            
            MainData.CirclePositionList = CirclePositionList;
            guidata(findobj('tag','MainData'),MainData)
            
            
            
        end
    
    end

    function ManualTracking(MainFigure, eventdata)
        %%
        MainData=guidata (findobj('tag','MainData'));
        I = MainData.Synapse;
        
        prompt = {'How many cells do you want to track:'};
        dlg_title = 'Input';
        num_lines = 1;
        defaultans = {'1'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        numcells =str2double(cell2mat(answer));
        Tracks_CellBody_Manual = [];
        Tracks_LeadingProcess_Manual = [];
        for j=1:numcells
            xy = [];
            for i=1:numel(I)
                figure(1000)
                imshow(I(i).data, [])
                text(10, 10, ['Click on Cell body #' num2str(i) ' Frame= ' num2str(i) '/' num2str(numel(I))],'color','w');
                [x,y] = ginput(1);
                xy = [xy; x y i];
            end
            close(1000)
            Tracks_CellBody_Manual = [Tracks_CellBody_Manual ; xy j.*ones(size(xy,1),1)];
            
            choice = questdlg('Would you like Track leading process?', ...
            '','Yes','No thank you','Yes');
            if strcmp(choice,'Yes')
                xy = [];
                for i=1:numel(I)
                    figure(1000)
                    imshow(I(i).data, [])
                    text(10, 10, ['Click on Leading Process #' num2str(i) ' Frame= ' num2str(i) '/' num2str(numel(I))],'color','w');
                    [x,y] = ginput(1);
                    xy = [xy; x y i];
                end
                close(1000)
                Tracks_LeadingProcess_Manual = [Tracks_LeadingProcess_Manual ; xy j.*ones(size(xy,1),1)];
            end
            if j < numcells
                h = warndlg(['Next Track cell #' num2str(j+1)]);
                waitfor(h)
            end
        end
        save ('Tracks_CellBody_Manual.txt', 'Tracks_CellBody_Manual','-double','-ascii')
        save ('Tracks_LeadingProcess_Manual.txt', 'Tracks_LeadingProcess_Manual','-double','-ascii')
        MainData.Tracks_CellBody_Manual = Tracks_CellBody_Manual;
        MainData.Tracks_LeadingProcess_Manual = Tracks_LeadingProcess_Manual;
        guidata(findobj('tag','MainData'),MainData)
    end

    function Display_Analysis(MainFigure, eventdata)
%%        
       MainData=guidata (findobj('tag','MainData'));
%        CirclePositionList =  MainData.CirclePositionList;
        I =  MainData.Channel1;
        I2 =  MainData.SEP;
        I3 = MainData.Synapse;
        I3_BW = MainData.Synapse_BW; 
        Tracks_inter = MainData.Tracks_CellBody_Manual;
        Tracks_LP = MainData.Tracks_LeadingProcess_Manual;

% %      Display All Cells analysis     
        A= [];
        figure(1001)
        for i=1:numel(I3)-1
            cmap = makecolormaps(I3(i).data,'Trans');
            I3s_RGB = ind2rgb(I3(i).data,cmap());
            BWperim = bwperim(I3_BW(i).data);
            BWmask_RGB = ind2rgb(BWperim,[0 0 0 ; 0 1 0]);
            I3s_RGB = I3s_RGB+ BWmask_RGB;
            imshow(I3s_RGB,[])
            hold on
            for j=1:max(Tracks_inter(:,4))
                % Cell Body
                ided = Tracks_inter(Tracks_inter(:,4)==j,:);
                plot(ided(1:i,1),ided(1:i,2),'r','tag','cellbody')
                plot(ided(i,1),ided(i,2),'or','markersize',5,'tag','cellbody2')
                % leading Process
                ided_LP = Tracks_LP(Tracks_LP(:,4)==j,:);
                plot(ided_LP(1:i,1),ided_LP(1:i,2),'c','tag','LP')
                plot(ided_LP(i,1),ided_LP(i,2),'oc','markersize',5,'tag','LP2')

            end
            text(10,10, ['Time = ' num2str(0.5*i,'%0.1f') '(min)'],'color','w','tag','texttag')
            A(i).cdata = getframe(gca);
            pause(0.001)
            delete(findobj('tag','cellbody'))
            delete(findobj('tag','cellbody2'))  
            delete(findobj('tag','LP'))
            delete(findobj('tag','LP2'))
            delete(findobj('tag','texttag'))
        end
        imwrite((A(i).cdata.cdata),'Final.tif','tif','Compression','None')
        for i=2:numel(I3)-1
            imwrite((A(i).cdata.cdata),'Final.tif','tif','Compression','None','Writemode','append')
        end      

%%
%         % Show all Cells and BW roi
        for frame=1%:numel(I)
             BW_Label = bwlabel(I3_BW(frame).data);
             stats = regionprops(BW_Label,'PixelList');
             startpixel=[];
             for i=1:max(Tracks_inter(:,4))
                 ind = find(Tracks_inter(:,4)==i);
                 startpixel(i,:) = Tracks_inter(ind(frame),1:2);
             end
             
             % Show all pts
             figure(66666)
             imshow(BW_Label,[])
             hold on
             for i=1:max(Tracks_inter(:,4))
                 plot(startpixel(i,1),startpixel(i,2),'xc')
             end
             pause(0.01)
        end
%         
%%      % Get single cells
        cell=[];
        for cellid=1:max(Tracks_inter(:,4))
            ind = find(Tracks_inter(:,4)==cellid);
            for frame=1:numel(I3_BW)
                BW_Label = bwlabel(I3_BW(frame).data);
                startpixel = Tracks_inter(ind(frame),1:2);
                cell(cellid).BW(frame).data = bwselect(BW_Label,startpixel(1,1),startpixel(1,2),4);
                figure(222)
                imshow(cell(cellid).BW(frame).data)
                hold on
                plot(startpixel(1,1),startpixel(1,2),'xc')
                pause(0.01)
            end
        end
        
        
        %% Display single cells Analysis
        for cellid = 1:max(Tracks_inter(:,4))
            
            % Must redefine tracks and BW...
            I3_BW = cell(cellid).BW;
            
            A= [];
            figure(1001)
            for i=1:numel(I3)-1
               
                cmap = makecolormaps(I3(i).data,'Trans');
                I3s_RGB = ind2rgb(I3(i).data,cmap());
                BWperim = bwperim(I3_BW(i).data);
                BWmask_RGB = ind2rgb(BWperim,[0 0 0 ; 0 1 0]);
                I3s_RGB = I3s_RGB+ BWmask_RGB;

                imshow(I3s_RGB,[])
                hold on
                % Cell Body
                ided = Tracks_inter(Tracks_inter(:,4)==cellid,:);
                plot(ided(1:i,1),ided(1:i,2),'r','tag','cellbody')
                plot(ided(i,1),ided(i,2),'or','markersize',5,'tag','cellbody2')
                % Leading Process
                ided2 = Tracks_LP(Tracks_LP(:,4)==cellid,:);
                plot(ided2(1:i,1),ided2(1:i,2),'C','tag','cellbody')
                plot(ided2(i,1),ided2(i,2),'oC','markersize',5,'tag','cellbody2')
                text(10,10, ['Time = ' num2str(0.5*i,'%0.1f') '(min)'],'color','w','tag','texttag')
                A(i).cdata = getframe(gca);
                pause(0.001)
                delete(findobj('tag','cellbody'))
                delete(findobj('tag','cellbody2'))
                delete(findobj('tag','texttag'))
            end
            % %
            imwrite((A(i).cdata.cdata),['Final_Cell_' num2str(cellid) '.tif'],'tif','Compression','None')
            for i=2:numel(I3)-1
                imwrite((A(i).cdata.cdata),['Final_Cell_' num2str(cellid) '.tif'],'tif','Compression','None','Writemode','append')
            end
            
             % %
            mcell1 =[];
            mcell2 =[];
            for i=1:numel(I)
                cell1 = double(I3_BW(i).data) .* double(I(i).data);
                mcell1 = [mcell1  mean(cell1(cell1>0))];
                cell2 = double(I3_BW(i).data) .* double(I2(i).data);
                mcell2 =[mcell2 mean(cell2(cell2>0))];
                
                
                figure(1)
                imshow(cell1,[]);
                figure(2)
                imshow(cell2,[]);
                
                pause(0.0001)
            end
            ratio = mcell2./mcell1;
            save (['Ratio_' num2str(cellid) '.txt'], 'ratio','-double','-ascii')
            
            % %
            figure(3)
            hold on
            plot((1:size(mcell1,2))*0.5,mcell1,'k')
            legend()
            plot((1:size(mcell2,2))*0.5,mcell2,'b')
            legend({'Perceval 1' 'Perceval 2'})
            xlabel('time (min)')
            ylabel('Persevals')
            saveas(3, ['Perceval 1 & 2_Cell_' num2str(cellid) '.pdf'],'pdf')
            close(3)
           figure(4)
            plot(ratio,'r')
            legend({'Ratio Perceval 2 / Perceval 1'})
            xlabel('Frame')
            ylabel('Perseval Ratio')
            saveas(4,['ratio 2on1_Cell_' num2str(cellid) '.pdf'],'pdf')
            close(4)
            %%
            % Calulate speed
            d = [];
            Ided = Tracks_inter(Tracks_inter(:,4)==cellid,:);
            for i=1:numel(I)-1
                ided = Ided(Ided(:,3)==i,:);
                ided2 = Ided(Ided(:,3)==i+1,:);
                dx = (ided2(1)-ided(1))^2;
                dy = (ided2(2)-ided(2))^2;
                di= dx+dy;
                d = [d sqrt(di)];
            end
            
            d= (d .* (6.45/60))./ (0.5/60);
            save (['Speed_CellBody_' num2str(cellid) '.txt'], 'd','-double','-ascii')
                        % %
            figure(5)
            hold on
            plotyy((1:size(ratio,2))*0.5,ratio,(1:size(d,2))*0.5,d)
            legend({'Ratio' 'Speed'})
            xlabel('Time (min)')
            ylabel('Perseval Ratio 2/1')
            saveas(5,['CellBody Speed&Ratio_mig Cell' num2str(cellid) '.pdf'],'pdf')
            close(5)
            
            % Calulate speed Leading Process
            d_LP = [];
            Ided = Tracks_LP(Tracks_LP(:,4)==cellid,:);
            for i=1:numel(I)-1
                ided = Ided(Ided(:,3)==i,:);
                ided2 = Ided(Ided(:,3)==i+1,:);
                dx = (ided2(1)-ided(1))^2;
                dy = (ided2(2)-ided(2))^2;
                di= dx+dy;
                d_LP = [d_LP sqrt(di)];
            end
            
            d_LP= (d_LP .* (6.45/60))./ (0.5/60);
            save (['Speed _LP_' num2str(cellid) '.txt'], 'd_LP','-double','-ascii')
            figure(6)
            hold on
            plotyy((1:size(ratio,2))*0.5,ratio,(1:size(d_LP,2))*0.5,d_LP)
            legend({'Ratio' 'Speed'})
            xlabel('Time (min)')
            ylabel('Perseval Ratio 2/1')
            saveas(6,['LeadingProcess Speed&Ratio_mig Cell' num2str(cellid) '.pdf'],'pdf')
            close(6)
            

            % hold on
            
        end
        
        
    end

    function Display_Leading_Process(MainFigure, eventdata)
%%        
        MainData=guidata (findobj('tag','MainData'));
        I =  MainData.Channel1;
        I2 =  MainData.SEP;
        I3 = MainData.Synapse;
        I3_BW = MainData.Synapse_BW;
        Ided = MainData.Tracks_CellBody_Manual;  
        Ided_LP = MainData.Tracks_LeadingProcess_Manual;
        
        
%%        
    end    
        
    function find_Migratory_Stage(MainFigure, eventdata)
%%
    MainData=guidata (findobj('tag','MainData'));        
    Tracks =  MainData.Tracks_CellBody_Manual;
    Tracks(:,4) = ones(size(Tracks,1),1);
    %
    figure(100)
    plot(Tracks(:,2),Tracks(:,1))
    
    %Distance
    d = [];
    for i=1:size(Tracks,1)-1
        ided = Tracks(Tracks(:,3)==i,:);
        ided2 = Tracks(Tracks(:,3)==i+1,:);
        dx = (ided2(1)-ided(1))^2;
        dy = (ided2(2)-ided(2))^2;
        di= dx+dy;
        d = [d sqrt(di)];
    end
    figure(101)
    plot(d)
    % % Moving Avg
    w=10;
    k = ones(1, w) / w;
    davg = conv(d, k, 'same');
    figure(102)
    plot(davg)
    
    % Dinst
    xyres=1;
    tres=1;
    Dmin=0.00000000001;
    Dt = f_Dinst(Tracks,w,xyres,tres,Dmin);
% %    
    figure
    plot(Dt(:,1))
    hold on
        for i=1:size(Dt,1)
            if   Dt(i,2) == 1
                plot(i,Dt(i,1),'or')
            else
                plot(i,Dt(i,1),'ok')
            end
        end
    end
end



















