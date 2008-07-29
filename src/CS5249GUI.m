function varargout = CS5249GUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CS5249GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CS5249GUI_OutputFcn, ...
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

% End initialization code - DO NOT EDIT


% --- Executes just before CS5249GUI is made visible.
function CS5249GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CS5249GUI (see VARARGIN)

global config;
config.pitchScale           = 1.3;
config.timeScale            = 0.7;
config.resamplingScale      = 1;
config.reconstruct          = 0;
config.cutOffFreq           = 900;
config.fileIn               = '..\waves\test.wav';
config.fileOut              = '..\waves\syn.wav';
config.fileLowpass              = '..\waves\lowpass.wav';

global data;
data.waveOut = [];
data.pitchMarks = [];
data.Candidates = [];
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CS5249GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CS5249GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function input_sound_wav_edit_Callback(hObject, eventdata, handles)
global config; 
config.fileIn = get(hObject,'String');


% --- Executes during object creation, after setting all properties.
function input_sound_wav_edit_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function output_sound_wav_edit_Callback(hObject, eventdata, handles)
global config;
config.fileOut = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function output_sound_wav_edit_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in play_input_wav_push_button.
function play_input_wav_push_button_Callback(hObject, eventdata, handles)
global config; 
[WaveIn, fs] = wavread(config.fileIn);
axes(handles.axes1);
plot(WaveIn);
wavplay(WaveIn, fs, 'async');
title('Input waveform')


% --- Executes on button press in play_output_wav_push_button.
function play_output_wav_push_button_Callback(hObject, eventdata, handles)
global config;
[WaveOut, fsOut] = wavread(config.fileOut);
wavplay(WaveOut, fsOut);

function pitchScaleValTxb_Callback(hObject, eventdata, handles)
global config;
config.pitchScale =  str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function pitchScaleValTxb_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeScaleValTxb_Callback(hObject, eventdata, handles)
global config;
config.timeScale =  str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function timeScaleValTxb_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- Executes on button press in run_program_button.
function run_program_button_Callback(hObject, eventdata, handles)
global data;
global config;

[data.WaveIn, fs] = wavread(config.fileIn);
% WaveIn = WaveIn + 0.1*rand(size(WaveIn)); %add white noise
data.WaveIn = data.WaveIn - mean(data.WaveIn); %normalize input wave

[LowPass, lag] = LowPassFilter(data.WaveIn, fs, config.cutOffFreq); % low-pass filter for pre-processing
wavwrite(LowPass, fs, config.fileLowpass);
data.PitchContour = PitchEstimation(LowPass, fs);
data.PitchContour = data.PitchContour(lag + 1 : length(data.PitchContour)); %shift lag samples because of low-pass filter
PitchMarking(data.WaveIn, data.PitchContour, fs);

wavwrite(data.waveOut, fs, config.fileOut);
wavplay(data.waveOut, fs, 'async');

axes(handles.axes1);
plot(data.WaveIn);
title('Input waveform')
axes(handles.axes2);
plot(data.waveOut);
title('Output waveform')

%%
function edit6_Callback(hObject, eventdata, handles)
global config;
config.resamplingScale      = str2double(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spectrumReconstruct_ckb.
function spectrumReconstruct_ckb_Callback(hObject, eventdata, handles)
global config;
config.reconstruct = get(hObject,'Value');


% --- Executes on button press in browse_input_wav_push.
function browse_input_wav_push_Callback(hObject, eventdata, handles)
global config;
% prompt a dialog to load a wave file
[filename, pathname] = uigetfile('*.wav','select a wave file to load');
% check file is selected
if pathname == 0
    disp('ERROR! No file selected!');     
    return;
end   
pathStr = [pathname filename] ;
set(handles.input_sound_wav_edit,'string',pathStr);
config.fileIn = pathStr;
guidata(hObject,handles);


% --- Executes on button press in browse_output_wav_push.
function browse_output_wav_push_Callback(hObject, eventdata, handles)

global config;
% prompt a dialog to load a wave file
[filename, pathname] = uigetfile('*.wav','select a wave file to load');
% check file is selected
if pathname == 0
    disp('ERROR! No file selected!');     
    return;
end   
pathStr = [pathname filename] ;
set(handles.output_sound_wav_edit,'string',pathStr);    
config.fileOut = pathStr;
guidata(hObject,handles);


% --- Executes on button press in displayPitchMarksBtn.
function displayPitchMarksBtn_Callback(hObject, eventdata, handles)
global data;
axes(handles.axes2);
PlotPitchMarks(data.WaveIn, data.candidates, data.pitchMarks, data.PitchContour); %show the pitch marks


% --- Executes on button press in playOutputBtn.
function playOutputBtn_Callback(hObject, eventdata, handles)
global config;
[WaveOut, fsOut] = wavread(config.fileOut);
axes(handles.axes2);
plot(WaveOut);
wavplay(WaveOut, fsOut, 'async');
title('Output waveform')


% --- Executes on button press in open_volumn_control.
function open_volumn_control_Callback(hObject, eventdata, handles)
opensoundcontrol


