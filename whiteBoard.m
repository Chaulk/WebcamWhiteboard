function whiteBoard( )
    a = imaqhwinfo;
    [camera_name, camera_id, format] = getCameraInfo(a);
    
    % Ask the user for the marker color..
    color = questdlg('What colour would you like to track?', ...
                     'Track Color', ...
                     'Red','Green','Blue',...
                     'Red');

    % ask the user for a frame grab interval rate...
    frames = inputdlg('Enter Frame Grab Interval ( 1 - 25)',...
                      'Choose Frame Grab Interval',1,{'5'});
                  
    % Get the video input...
    vid = videoinput(camera_name, camera_id, format);
    
    binThresh = 0.18;
    
    % set the index based on color
    switch (color)
        case 'Red'
            trackIndex = 1;
        case 'Green'
            trackIndex = 2;
            %Green requires more sensitive thresholding for the markers we
            %have..
            binThresh = 0.1;
        case 'Blue'
            trackIndex = 3;
        otherwise
            disp('Assumed red...');
            trackIndex = 1;
    end

    % Set the video object properties..
    set(vid, 'FramesPerTrigger', Inf);
    set(vid, 'ReturnedColorspace', 'rgb')
    vid.FrameGrabInterval = str2num(sprintf('%s',frames{:}));
    % set the key listener...
    set(gcf,'KeyPressFcn',@keyPressed);

    %get image size and hold it as a variable..
    %this is so we do not have to continuously do this calculation in the
    %loop...
    whiteBoard = getsnapshot(vid);
    dsize = size(whiteBoard);
    rows = dsize(1);
    cols = dsize(2);
    %create the whiteboard object
    whiteBoard = zeros(dsize);
    %begin the video object..
    start(vid)
    
    %draw the whiteboard
    imshow(whiteBoard);
    
    %p1 will hold the marker centroid. A value of [-1,-1] means a new first
    %point has to be found..
    p1 = [ -1, -1 ];
    running = true;
    try
        while running 

            % Get the snapshot of the current frame
            data = getsnapshot(vid);
            % flush the ram
            flushdata(vid);
            
            % subject the grayscaled image from the red channel of the
            % image.
            diff_im = imsubtract(data(:,:,trackIndex), rgb2gray(data));

            % Convert the image into a binary image...
            diff_im = im2bw(diff_im, binThresh);

            % Remove small objects with an area less than 1000px^2
            diff_im = bwareaopen(diff_im,500);

            % get calculate the centroid, Area, and eccetricity (invariant)
            % of every object in the image..
            stats = regionprops(diff_im, 'Centroid', 'Area', 'Eccentricity');

            % Display the whiteboard object
            imshow(whiteBoard);
            hold on

            %If there's an object found..
            if ~isempty(stats)
                object = -1;
                for object = 1:length(stats)
                    e = stats(object).Eccentricity;
                    %if the area isn't too big (trying to account for
                    %background objects, such as clothing)..
                    if (stats(object).Area < 10000 )
                        bc = stats(object).Centroid;
                        bc(1) = dsize(2) - bc(1);
                        p2 = bc;
                        dist = sqrt( ((p1(1)-p2(1))^2) + ((p1(2)-p2(2))^2) );
                        %if the displacement greater than a 5th of the
                        %image width, ignore it. This is, again, part of
                        %the effort to ignore artifacts in the image..
                        if dist > (cols/5)
                            continue
                        %If the eccentricity is acceptable (like a circular
                        %marker head) than assume this to be the marker..
                        elseif e < 0.55
                            break;
                        end;
                    end
                end

                if object ~= -1
                    bc = stats(object).Centroid;
                    bc(1) = dsize(2) - bc(1);
                    p2 = bc;
                    plot(bc(1), bc(2), '-m+', 'color', 'magenta');
                    if ( stats(object).Area > 2500 )
                        dist = sqrt( ((p1(1)-p2(1))^2) + ((p1(2)-p2(2))^2) );

                        if ( isequal(p1, [-1,-1]) )
                            %new starting point
                            p1 = p2;
                        elseif dist < (cols/5) %apply the same distance sensitivity
                            % Calculate the line of best fit..
                            inds = getLineIndeces(p1,p2);
                            % paint the whiteboard..
                            for i = 1 : size(inds,1)
                                point = inds(i,:);
                                r = ceil(point(1));
                                c = ceil(point(2));
                                whiteBoard(c,r,trackIndex) = 255;
                            end
                            p1 = p2;
                        else
                            %Flag for a new starting point..
                            p1 = [-1,-1];
                        end;
                    else
                        p1 = [-1,-1];
                    end
                else
                    %if no object is found.. then begin drawing anew..
                    p1 = [-1,-1];
                end;
            end;
            hold off
        end
    catch exception
        stop(vid);
        flushdata(vid);
        disp(exception.message);
    end

    % Video aquisition...
    stop(vid);

    % Flush the memory buffer...
    flushdata(vid);

    close(gcf);
    % Clear variables
    clear all

    function keyPressed( src, evnt )
        keyIn = get(gcf,'CurrentCharacter');
        if strcmpi(keyIn,char(27)) % Exit program..
            disp(sprintf('Exiting...'));
            running = false;
        elseif strcmpi(keyIn,'c') %Clear the whiteboard..
            whiteBoard = zeros(dsize);
        elseif strcmpi(keyIn,'r')
            p1 = [-1, -1];
            trackIndex = 1;
            binThresh = 0.18;
        elseif strcmpi(keyIn,'g')
            p1 = [-1, -1];
            trackIndex = 2;
            binThresh = 0.05;
        elseif strcmpi(keyIn,'b')
            p1 = [-1, -1];
            trackIndex = 3;
            binThresh = 0.18;
        end
    end
end