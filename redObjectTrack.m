function redObjectTrack()    
    a = imaqhwinfo;
    [camera_name, camera_id, format] = getCameraInfo(a);


    % Capture the video frames using the videoinput function
    % You have to replace the resolution & your installed adaptor name.
    vid = videoinput(camera_name, camera_id, format);

    % Set the properties of the video object
    set(vid, 'FramesPerTrigger', Inf);
    set(vid, 'ReturnedColorspace', 'rgb')
    vid.FrameGrabInterval = 5;
    set(gcf,'KeyPressFcn',@closeFigure);
    %start the video aquisition here
    start(vid)

    running = true;
    try
        while running 

            % Get the snapshot of the current frame
            data = getsnapshot(vid);
            
            % Now to track red objects in real time
            % we have to subtract the red component 
            % from the grayscale image to extract the red components in the image.
            diff_im = imsubtract(data(:,:,1), rgb2gray(data));
            diff_im = fliplr(diff_im);
            %Use a median filter to filter out noise
            diff_im = medfilt2(diff_im, [3 3]);
            % Convert the resulting grayscale image into a binary image.
            diff_im = im2bw(diff_im,0.18);
            
            % Remove all those pixels less than 300px
            diff_im = bwareaopen(diff_im,300);

            % Label all the connected components in the image.
            bw = bwlabel(diff_im, 8);

            % Here we do the image blob analysis.
            % We get a set of properties for each labeled region.
            stats = regionprops(bw, 'BoundingBox', 'Centroid');

            % Display the image
%             imshow(data)
            imshow(data);
            hold on

            %This is a loop to bound the red objects in a rectangular box.
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                bc = stats(object).Centroid;
                rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
                plot(bc(1),bc(2), '-m+')
                a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), '    Y: ', num2str(round(bc(2)))));
                set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'yellow');
            end

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