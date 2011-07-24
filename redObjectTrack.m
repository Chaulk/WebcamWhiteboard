function redObjectTrack( )
    a = imaqhwinfo;
    [camera_name, camera_id, format] = getCameraInfo(a);
    
    
    color = questdlg('What colour would you like to track?', ...
                     'Track Color', ...
                     'Red','Green','Blue',...
                     'Red');

    
    frames = inputdlg('Enter Frame Grab Interval ( 1 - 25)',...
                      'Choose Frame Grab Interval',1,{'5'});
                  
    % Capture the video frames using the videoinput function
    % You have to replace the resolution & your installed adaptor name.
    vid = videoinput(camera_name, camera_id, format);
    
    switch (color)
        case 'Red'
            color = 'red';
            trackIndex = 1;
        case 'Green'
            color = 'green';
            trackIndex = 2;
        case 'Blue'
            color = 'blue';
            trackIndex = 3;
    end

    % Set the properties of the video object
    set(vid, 'FramesPerTrigger', Inf);
    set(vid, 'ReturnedColorspace', 'rgb')
    vid.FrameGrabInterval = str2num(sprintf('%s',frames{:}));
    set(gcf,'KeyPressFcn',@closeFigure);
    %start the video aquisition here
    %get image size
    whiteBoard = getsnapshot(vid);
    dsize = size(whiteBoard);
    rows = dsize(1);
    cols = dsize(2);
    whiteBoard = zeros(dsize);
    start(vid)
    
    imshow(whiteBoard);
    
    p1 = [ -1, -1 ];
    running = true;
    try
        while running 

            % Get the snapshot of the current frame
            data = getsnapshot(vid);
            flushdata(vid);
            
            % Now to track color objects in real time
            % we have to subtract the color component 
            % from the grayscale image to extract the color components in the image.
            diff_im = imsubtract(data(:,:,trackIndex), rgb2gray(data));

            %Use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3 3]);
            % Convert the resulting grayscale image into a binary image.
            diff_im = im2bw(diff_im,0.18);

            % Remove all those pixels less than 500px
            diff_im = bwareaopen(diff_im,500);
%             imshow(diff_im);
            % Here we do the image blob analysis.
            % We get a set of properties for each labeled region.
            stats = regionprops(diff_im, 'Centroid', 'Area');

            % Display the image
            imshow(whiteBoard);
            hold on

            %This is a loop to bound the red objects in a rectangular box.
            for object = 1:length(stats)
                if (stats(object).Area < 20000 )
%                     bb = stats(object).BoundingBox;
                    bc = stats(object).Centroid;
    %                 a=text(bc(1)+15,bc(2), strcat('Area: ', num2str(round(stats(object).Area))));
                    bc(1) = dsize(2) - bc(1);
                    p2 = bc;% [ bc(2), bc(1) ];
                    
                    dist = sqrt( ((p1(1)-p2(1))^2) + ((p1(2)-p2(2))^2) );
                    
                    if ( isequal(p1, [-1,-1]) )
                        p1 = p2;
                    elseif dist < 1000
                        inds = getLineIndeces(p1,p2);
                        for i=1:length(inds)
                            point = inds(i,:);
                            r = ceil(point(1));
                            c = ceil(point(2));
                            whiteBoard(c,r,trackIndex) = 255;
%                             plot(r,c, '-m+', 'color', color);
                        end
%                         N = min( abs(p1(1)-bc(2)), abs(p1(2)-bc(1)));
%                         N = max(1, N);
%                         rpts = linspace(p1(1), bc(2), N);
%                         cpts = linspace(p1(2), bc(1), N);
%                         index = sub2ind([rows, cols], round(rpts), round(cpts));
%                         whiteBoard(index) = 255;
                        p1 = p2;
                    end;

                end;
            end
%             imshow(whiteBoard);
            hold off
        end
    catch exception
        stop(vid);
        flushdata(vid);
        disp(exception.message);
    end

    % Stop the video aquisition.
    stop(vid);

    % Flush all the image data stored in the memory buffer.
    flushdata(vid);

    close(gcf);
    % Clear all variables
    clear all

    function closeFigure( src, evnt )
        keyIn = get(gcf,'CurrentCharacter');
        if strcmpi(keyIn,char(27))
            disp(sprintf('Exiting...'));
            running = false;
        end
    end
end