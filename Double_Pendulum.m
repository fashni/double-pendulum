function varargout = Double_Pendulum(varargin)
% DOUBLE_PENDULUM MATLAB code for Double_Pendulum.fig
%      DOUBLE_PENDULUM, by itself, creates a new DOUBLE_PENDULUM or raises the existing
%      singleton*.
%
%      H = DOUBLE_PENDULUM returns the handle to a new DOUBLE_PENDULUM or the handle to
%      the existing singleton*.
%
%      DOUBLE_PENDULUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOUBLE_PENDULUM.M with the given input arguments.
%
%      DOUBLE_PENDULUM('Property','Value',...) creates a new DOUBLE_PENDULUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Double_Pendulum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Double_Pendulum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Double_Pendulum

% Last Modified by GUIDE v2.5 20-May-2020 09:03:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Double_Pendulum_OpeningFcn, ...
                   'gui_OutputFcn',  @Double_Pendulum_OutputFcn, ...
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


% --- Executes just before Double_Pendulum is made visible.
function Double_Pendulum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Double_Pendulum (see VARARGIN)

% Choose default command line output for Double_Pendulum
handles.output = hObject;

% Set handles state
set(handles.save, 'Enable', 'off')
set(handles.visualization, 'Enable', 'off')
set(handles.nstep, 'String', 0.005);
set(handles.niter, 'String', 2000);

% Initialize variables
handles.subplt = gobjects(1, 4);
handles.plt = gobjects(0);
handles.integrator = PendulumIntegrator();
handles.vis_opt = 'sim';

set(handles.status, 'String', 'SIAP')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Double_Pendulum wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Double_Pendulum_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in vis_opts.
function vis_opts_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in vis_opts 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.vis_opt = get(eventdata.NewValue,'Tag');
guidata(hObject, handles);


% --- Executes on button press in calculation.
function calculation_Callback(hObject, eventdata, handles)
% hObject    handle to calculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status, 'String', 'MOHON TUNGGU')
L = [str2double(get(handles.L1, 'String')) str2double(get(handles.L2, 'String'))];
m = [str2double(get(handles.m1, 'String')) str2double(get(handles.m2, 'String'))];
th = [str2double(get(handles.th1, 'String')) str2double(get(handles.th2, 'String'))] * pi/180;
omg = [str2double(get(handles.omg1, 'String')) str2double(get(handles.omg2, 'String'))] * pi/180;
g = str2double(get(handles.grav, 'String'));
steps = str2double(get(handles.nstep, 'String'));
iter = str2double(get(handles.niter, 'String'));

handles.integrator.add_properties('GravAcc', g, 'Steps', steps, 'Iterations', iter, ...
    'Mass', m, 'Length', L, 'InitialTheta', th, 'InitialOmega', omg);

handles.integrator.runge_kutta();

set(handles.visualization, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
set(handles.status, 'String', 'HITUNG DATA SELESAI')
guidata(hObject, handles);


% --- Executes on button press in visualization.
function visualization_Callback(hObject, eventdata, handles)
% hObject    handle to visualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.plt)
delete(handles.subplt)
set(handles.visualization, 'Enable', 'off')
set(handles.calculation, 'Enable', 'off')
set(handles.save, 'Enable', 'off')
set(handles.load, 'Enable', 'off')
if strcmp(handles.vis_opt, 'time_graph')
    t = 0:handles.integrator.steps:handles.integrator.steps*(handles.integrator.iterations-1);

    handles.subplt(1) = subplot('Position', [0.03 0.5 0.45 0.45], 'Parent', handles.vis_panel);
    plot(t, handles.integrator.th_data(1, :))
    title('\theta_{1}')
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    handles.subplt(2) = subplot('Position', [0.53 0.5 0.45 0.45], 'Parent', handles.vis_panel);
    plot(t, handles.integrator.th_data(2, :))
    title('\theta_{2}')
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    handles.subplt(3) = subplot('Position', [0.03 0 0.45 0.45], 'Parent', handles.vis_panel);
    plot(t, handles.integrator.w_data(1, :))
    title('\omega_{1}')
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
    handles.subplt(4) = subplot( 'Position', [0.53 0 0.45 0.45], 'Parent', handles.vis_panel);
    plot(t, handles.integrator.w_data(2, :))
    title('\omega_{2}')
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    
elseif strcmp(handles.vis_opt, 'gen_coord')
    handles.plt = subplot('Position', [0 0 1 1], 'Parent', handles.vis_panel);
    set(gca, 'XLim', [-3.3 3.3], 'YLim', [-3.3 3.3]);
    xlabel('\theta_{1}')
    ylabel('\theta_{2}')
    grid on
    handles.plt.XAxisLocation = 'origin';
    handles.plt.YAxisLocation = 'origin';
    hold on
    plot(handles.integrator.th_data(1, :), handles.integrator.th_data(2, :))
    scatter(handles.integrator.th_data(1, :), handles.integrator.th_data(2, :), 10, 'filled')
    hold off

else
    set(handles.status, 'String', 'SIMULASI SEDANG BERJALAN')
    cartesian = handles.integrator.get_cartesian();
    x1 = cartesian(1, :);
    y1 = cartesian(2, :);
    x2 = cartesian(3, :);
    y2 = cartesian(4, :);

    handles.plt = subplot('Position', [0 0 1 1], 'Parent', handles.vis_panel);
    set(gca, 'XLim', [-sum(handles.integrator.length)-0.5 sum(handles.integrator.length)+0.5], ... 
             'YLim', [-sum(handles.integrator.length)-0.5 sum(handles.integrator.length)+0.5]);
             tic
    hold on
    for k=1:15:handles.integrator.iterations
        string1 = line([0 x1(k)], [0 y1(k)]);
        string2 = line([x1(k) x2(k)], [y1(k) y2(k)]);
        head1 = scatter(x1(k), y1(k), 50, 'filled', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');
        head2 = scatter(x2(k), y2(k), 50, 'filled', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
        drawnow();
        % pause(0.001)
        if k+15<=handles.integrator.iterations
            delete(string1);
            delete(string2);
            delete(head1);
            delete(head2);
        end
    end
    hold off
    toc
    set(handles.status, 'String', 'SIMULASI SELESAI')
end
set(handles.visualization, 'Enable', 'on')
set(handles.calculation, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
set(handles.load, 'Enable', 'on')
guidata(hObject, handles);


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.integrator.clear_properties();
handles.vis_opt = 'sim';
set(handles.vis_opts, 'selectedobject', handles.sim);
set(handles.L1, 'String', 1);
set(handles.L2, 'String', 1);
set(handles.m1, 'String', 1);
set(handles.m2, 'String', 1);
set(handles.th1, 'String', 0);
set(handles.th2, 'String', 0);
set(handles.omg1, 'String', 0);
set(handles.omg2, 'String', 0);
set(handles.grav, 'String', 9.8);
set(handles.nstep, 'String', 0.005);
set(handles.niter, 'String', 2000);
delete(handles.subplt)
delete(handles.plt)

set(handles.visualization, 'Enable', 'off')
set(handles.save, 'Enable', 'off')
guidata(hObject, handles);


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
    % hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile('saved\*.mat', 'Save as...');
if pathname==0
    return
end
pendulum = handles.integrator;
try
    save([pathname filename], 'pendulum')
    set(handles.status, 'String', 'DATA BERHASIL DISIMPAN')
catch
    set(handles.status, 'String', 'DATA GAGAL DISIMPAN')
end


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('saved\*.mat', 'Select a file');
if pathname==0
    return
end
load([pathname filename], 'pendulum')
handles.integrator = pendulum;
set(handles.L1, 'String', num2str(pendulum.length(1)));
set(handles.L2, 'String', num2str(pendulum.length(2)));
set(handles.m1, 'String', num2str(pendulum.mass(1)));
set(handles.m2, 'String', num2str(pendulum.mass(2)));
set(handles.th1, 'String', num2str(pendulum.th_data(1, 1) * 180/pi));
set(handles.th2, 'String', num2str(pendulum.th_data(2, 1) * 180/pi));
set(handles.omg1, 'String', num2str(pendulum.w_data(1, 1) * 180/pi));
set(handles.omg2, 'String', num2str(pendulum.w_data(2, 1) * 180/pi));
set(handles.grav, 'String', num2str(pendulum.grav));
set(handles.nstep, 'String', num2str(pendulum.steps));
set(handles.niter, 'String', num2str(pendulum.iterations));

set(handles.status, 'String', 'DATA BERHASIL DIMUAT')
set(handles.visualization, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
guidata(hObject, handles);


% --- Executes on button press in show_data.
function show_data_Callback(hObject, eventdata, handles)
% hObject    handle to show_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_data


% --- Executes on button press in sim.
function sim_Callback(hObject, eventdata, handles)
% hObject    handle to sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sim


% --- Executes on button press in gen_coord.
function gen_coord_Callback(hObject, eventdata, handles)
% hObject    handle to gen_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gen_coord


% --- Executes on button press in time_graph.
function time_graph_Callback(hObject, eventdata, handles)
% hObject    handle to time_graph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of time_graph



function grav_Callback(hObject, eventdata, handles)
% hObject    handle to grav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of grav as text
%        str2double(get(hObject,'String')) returns contents of grav as a double


% --- Executes during object creation, after setting all properties.
function grav_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nstep_Callback(hObject, eventdata, handles)
% hObject    handle to nstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nstep as text
%        str2double(get(hObject,'String')) returns contents of nstep as a double


% --- Executes during object creation, after setting all properties.
function nstep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function niter_Callback(hObject, eventdata, handles)
% hObject    handle to niter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of niter as text
%        str2double(get(hObject,'String')) returns contents of niter as a double


% --- Executes during object creation, after setting all properties.
function niter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to niter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function th1_Callback(hObject, eventdata, handles)
% hObject    handle to th1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of th1 as text
%        str2double(get(hObject,'String')) returns contents of th1 as a double


% --- Executes during object creation, after setting all properties.
function th1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to th1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function th2_Callback(hObject, eventdata, handles)
% hObject    handle to th2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of th2 as text
%        str2double(get(hObject,'String')) returns contents of th2 as a double


% --- Executes during object creation, after setting all properties.
function th2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to th2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function omg1_Callback(hObject, eventdata, handles)
% hObject    handle to omg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of omg1 as text
%        str2double(get(hObject,'String')) returns contents of omg1 as a double


% --- Executes during object creation, after setting all properties.
function omg1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to omg1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function omg2_Callback(hObject, eventdata, handles)
% hObject    handle to omg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of omg2 as text
%        str2double(get(hObject,'String')) returns contents of omg2 as a double


% --- Executes during object creation, after setting all properties.
function omg2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to omg2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L1_Callback(hObject, eventdata, handles)
% hObject    handle to L1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L1 as text
%        str2double(get(hObject,'String')) returns contents of L1 as a double


% --- Executes during object creation, after setting all properties.
function L1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function L2_Callback(hObject, eventdata, handles)
% hObject    handle to L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of L2 as text
%        str2double(get(hObject,'String')) returns contents of L2 as a double


% --- Executes during object creation, after setting all properties.
function L2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to L2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function m1_Callback(hObject, eventdata, handles)
% hObject    handle to m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m1 as text
%        str2double(get(hObject,'String')) returns contents of m1 as a double


% --- Executes during object creation, after setting all properties.
function m1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function m2_Callback(hObject, eventdata, handles)
% hObject    handle to m2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of m2 as text
%        str2double(get(hObject,'String')) returns contents of m2 as a double


% --- Executes during object creation, after setting all properties.
function m2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to m2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
