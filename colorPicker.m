function varargout = colorPicker(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @colorPicker_OpeningFcn, ...
        'gui_OutputFcn',  @colorPicker_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end


function colorPicker_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    
    handles.previewIm = zeros(500,500,3);
    
    imshow(handles.previewIm);

    guidata(hObject, handles);
end

function varargout = colorPicker_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
end

function pushbutton1_Callback(hObject, eventdata, handles)
    close;
end



% --- Executes on button press in redButton.
function redButton_Callback(hObject, eventdata, handles)
    handles.previewIm(:,:,:) = 0;
    handles.previewIm(:,:,1) = 1;
    imshow(handles.previewIm);
    handles.trackColor = 'red';
    guidata(hObject, handles);
end


% --- Executes on button press in greenButton.
function greenButton_Callback(hObject, eventdata, handles)
    handles.previewIm(:,:,:) = 0;
    handles.previewIm(:,:,2) = 1;
    imshow(handles.previewIm);
    handles.trackColor = 'green';
    guidata(hObject, handles);
end


% --- Executes on button press in blueButton.
function blueButton_Callback(hObject, eventdata, handles)
    handles.previewIm(:,:,:) = 0;
    handles.previewIm(:,:,3) = 1;
    imshow(handles.previewIm);
    handles.trackColor = 'blue';
    guidata(hObject, handles);
end
