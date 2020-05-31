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

% Last Modified by GUIDE v2.5 23-May-2020 20:46:25

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
handles.subplt = gobjects(1, 2);
handles.plt = gobjects(0);
handles.integrator = PendulumIntegrator();
handles.vis_opt = 'sim';
handles.method = 'runge_kutta';

set(handles.status, 'String', 'SIAP')
set(handles.analytic, 'Enable', 'off')
set(handles.show_analytic, 'Enable', 'off')

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
if strcmp(handles.vis_opt, 'time_graph')
    set(handles.show_data, 'Enable', 'off')
else
    set(handles.show_data, 'Enable', 'on')
end
guidata(hObject, handles);



% --- Executes when selected object is changed in method_opts.
function method_opts_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in method_opts 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.method = get(eventdata.NewValue,'Tag');
guidata(hObject, handles);


% --- Executes on button press in calculation.
function calculation_Callback(hObject, eventdata, handles)
% hObject    handle to calculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status, 'String', 'MOHON TUNGGU')
set(handles.calculation, 'Enable', 'off')
set(handles.visualization, 'Enable', 'off')
set(handles.stop_btn, 'Enable', 'off')
set(handles.reset, 'Enable', 'off')
set(handles.save, 'Enable', 'off')
set(handles.load, 'Enable', 'off')
set(handles.sim, 'Enable', 'off')
set(handles.gen_coord, 'Enable', 'off')
set(handles.time_graph, 'Enable', 'off')
set(handles.show_data, 'Enable', 'off')
set(handles.show_analytic, 'Enable', 'off')
set(handles.analytic, 'Enable', 'off')
set(handles.show_analytic, 'Value', 0)
pause(0.1)
handles.integrator.clear_properties()
L = [str2double(get(handles.L1, 'String')) str2double(get(handles.L2, 'String'))];
m = [str2double(get(handles.m1, 'String')) str2double(get(handles.m2, 'String'))];
th = [str2double(get(handles.th1, 'String')) str2double(get(handles.th2, 'String'))] * pi/180;
omg = [str2double(get(handles.omg1, 'String')) str2double(get(handles.omg2, 'String'))] * pi/180;
g = str2double(get(handles.grav, 'String'));
steps = str2double(get(handles.nstep, 'String'));
iter = str2double(get(handles.niter, 'String'));

handles.integrator.add_properties('GravAcc', g, 'Steps', steps, 'Iterations', iter, ...
    'Mass', m, 'Length', L, 'InitialTheta', th, 'InitialOmega', omg);

switch handles.method
case 'runge_kutta'
    handles.integrator.runge_kutta();
case 'euler'
    handles.integrator.euler();
case 'symplectic_euler'
    handles.integrator.symplectic_euler();
end

if all(abs(th*180/pi) <= 10) && abs(th(1)-th(2))*180/pi <= 10 && L(1) == L(2)
    set(handles.analytic, 'Enable', 'on')
end
set(handles.visualization, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
set(handles.calculation, 'Enable', 'on')
set(handles.load, 'Enable', 'on')
set(handles.stop_btn, 'Enable', 'on')
set(handles.reset, 'Enable', 'on')
set(handles.sim, 'Enable', 'on')
set(handles.gen_coord, 'Enable', 'on')
set(handles.time_graph, 'Enable', 'on')
set(handles.show_data, 'Enable', 'on')
set(handles.status, 'String', 'HITUNG DATA SELESAI')
guidata(hObject, handles);


% --- Executes on button press in visualization.
function visualization_Callback(hObject, eventdata, handles)
% hObject    handle to visualization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.plt)
delete(handles.subplt)
set(handles.stop_btn, 'UserData', 0)
set(handles.visualization, 'Enable', 'off')
set(handles.calculation, 'Enable', 'off')
set(handles.save, 'Enable', 'off')
set(handles.load, 'Enable', 'off')
set(handles.sim, 'Enable', 'off')
set(handles.time_graph, 'Enable', 'off')
set(handles.gen_coord, 'Enable', 'off')
set(handles.show_analytic, 'Enable', 'off')

set(handles.th1_str, 'String', 0)
set(handles.th2_str, 'String', 0)
set(handles.w1_str, 'String', 0)
set(handles.w2_str, 'String', 0)

freq = str2double(get(handles.freq, 'String'));
t = 0:handles.integrator.steps:handles.integrator.steps*(handles.integrator.iterations-1);
th1 = handles.integrator.th_data(1, :) * 180/pi;
th2 = handles.integrator.th_data(2, :) * 180/pi;
w1 = handles.integrator.w_data(1, :) * 180/pi;
w2 = handles.integrator.w_data(2, :) * 180/pi;
th_analytic = handles.integrator.th_analytic * 180/pi;

switch handles.vis_opt
case 'time_graph'
    handles.subplt(1) = subplot('Position', [0.07 0.5 0.93 0.45], 'Parent', handles.vis_panel);
    plot(t, th1, t, th2, 'LineWidth', 1.5)
    title('\theta')
    legend('\theta_{1}', '\theta_{2}')
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';

    handles.subplt(2) = subplot('Position', [0.07 0 0.93 0.45], 'Parent', handles.vis_panel);
    if get(handles.show_analytic, 'Value')
        plot(t, th_analytic(1, :), t, th_analytic(2, :), 'LineWidth', 1.5)
        title('\theta Analitik')
        legend('\theta_{1}', '\theta_{2}')
    else
        plot(t, w1, t, w2, 'LineWidth', 1.5)
        title('\omega')
        legend('\omega_{1}', '\omega_{2}')
    end
    grid on
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';

case 'gen_coord'
    handles.plt = subplot('Position', [0 0 1 1], 'Parent', handles.vis_panel);
    set(gca, 'XLim', [min(th1) max(th1)], 'YLim', [min(th2) max(th2)]);
    daspect([1 1 1]);
    xlabel('\theta_{1}')
    ylabel('\theta_{2}')
    grid on
    handles.plt.XAxisLocation = 'origin';
    handles.plt.YAxisLocation = 'origin';
    hab = animatedline('LineWidth', 1.5, 'Color', 'b');
    hold on
    for k = 1:freq:handles.integrator.iterations
        head = scatter(th1(k), th2(k), 20, 'filled', 'MarkerFaceColor', 'k');
        addpoints(hab, th1(k), th2(k));
        drawnow();
        set(handles.time_str, 'String', num2str((k-1)*handles.integrator.steps, '%.4f'))
        if get(handles.show_data, 'Value')
            set(handles.th1_str, 'String', num2str(th1(k), '%.4f'))
            set(handles.th2_str, 'String', num2str(th2(k), '%.4f'))
            set(handles.w1_str, 'String', num2str(w1(k), '%.4f'))
            set(handles.w2_str, 'String', num2str(w2(k), '%.4f'))
        end
        if get(handles.stop_btn, 'UserData')
            break
        end
        if k+freq <= handles.integrator.iterations
            delete(head);
        end
    end
    hold off
    
case 'sim'
    set(handles.status, 'String', 'SIMULASI SEDANG BERJALAN')
    cartesian = handles.integrator.get_cartesian();
    x1 = cartesian(1, :);
    y1 = cartesian(2, :);
    x2 = cartesian(3, :);
    y2 = cartesian(4, :);
    if get(handles.show_analytic, 'Value')
        x1_a = cartesian(5, :);
        y1_a = cartesian(6, :);
        x2_a = cartesian(7, :);
        y2_a = cartesian(8, :);
    end

    handles.plt = subplot('Position', [0.055 0.055 0.945 0.945], 'Parent', handles.vis_panel);
    set(gca, 'XLim', [-sum(handles.integrator.length)*1.2 sum(handles.integrator.length)*1.2], ... 
            'YLim', [-sum(handles.integrator.length)*1.2 sum(handles.integrator.length)*1.2]);
    tic
    hold on
    for k=1:freq:handles.integrator.iterations
        string1 = line([0 x1(k)], [0 y1(k)], 'LineWidth', 1.5, 'Color', '#A2142F');
        string2 = line([x1(k) x2(k)], [y1(k) y2(k)], 'LineWidth', 1.5, 'Color', '#A2142F');
        head1 = scatter(x1(k), y1(k), 70, 'filled', 'MarkerFaceColor', 	'#77AC30', 'MarkerEdgeColor', 'k');
        head2 = scatter(x2(k), y2(k), 70, 'filled', 'MarkerFaceColor', '#7E2F8E', 'MarkerEdgeColor', 'k');
        if get(handles.show_analytic, 'Value')
            string1_a = line([0 x1_a(k)], [0 y1_a(k)], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'k');
            string2_a = line([x1_a(k) x2_a(k)], [y1_a(k) y2_a(k)], 'LineStyle', '--', 'LineWidth', 1.5, 'Color', 'k');
            head1_a = scatter(x1_a(k), y1_a(k), 50, 'filled', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');
            head2_a = scatter(x2_a(k), y2_a(k), 50, 'filled', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k');
        end

        drawnow();
        set(handles.time_str, 'String', num2str((k-1)*handles.integrator.steps, '%.4f'))
        if get(handles.show_data, 'Value')
            set(handles.th1_str, 'String', num2str(th1(k), '%.4f'))
            set(handles.th2_str, 'String', num2str(th2(k), '%.4f'))
            set(handles.w1_str, 'String', num2str(w1(k), '%.4f'))
            set(handles.w2_str, 'String', num2str(w2(k), '%.4f'))
        end
        if get(handles.stop_btn, 'UserData')
            break
        end
        if k+freq <= handles.integrator.iterations
            delete(head1);
            delete(head2);
            delete(string1);
            delete(string2);
            if get(handles.show_analytic, 'Value')
                delete(head1_a);
                delete(head2_a);
                delete(string1_a);
                delete(string2_a);
            end
        end
    end
    hold off
    toc
end

set(handles.status, 'String', 'VISUALISASI SELESAI')
set(handles.visualization, 'Enable', 'on')
set(handles.calculation, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
set(handles.load, 'Enable', 'on')
set(handles.sim, 'Enable', 'on')
set(handles.time_graph, 'Enable', 'on')
set(handles.gen_coord, 'Enable', 'on')
if ~isempty(th_analytic)
    set(handles.show_analytic, 'Enable', 'on')
end
guidata(hObject, handles);


% --- Executes on button press in stop_btn.
function stop_btn_Callback(hObject, eventdata, handles)
% hObject    handle to stop_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.stop_btn, 'UserData', 1)
guidata(hObject, handles);


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.integrator.clear_properties();
handles.vis_opt = 'sim';
handles.method = 'runge_kutta';
set(handles.vis_opts, 'selectedobject', handles.sim);
set(handles.method_opts, 'selectedobject', handles.runge_kutta);
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
set(handles.time_str, 'String', 0)
set(handles.th1_str, 'String', 0)
set(handles.th2_str, 'String', 0)
set(handles.w1_str, 'String', 0)
set(handles.w2_str, 'String', 0)
delete(handles.subplt)
delete(handles.plt)

set(handles.visualization, 'Enable', 'off')
set(handles.save, 'Enable', 'off')
set(handles.calculation, 'Enable', 'on')
set(handles.load, 'Enable', 'on')
set(handles.sim, 'Enable', 'on')
set(handles.time_graph, 'Enable', 'on')
set(handles.gen_coord, 'Enable', 'on')
set(handles.show_analytic, 'Enable', 'off')
set(handles.show_analytic, 'Value', 0)
set(handles.analytic, 'Enable', 'off')
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
method = handles.method;
try
    save([pathname filename], 'pendulum', 'method')
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
load([pathname filename], 'pendulum', 'method')
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
if all(abs(pendulum.th_data(:, 1)*180/pi) <= 10) && ... 
   abs(pendulum.th_data(1, 1)-pendulum.th_data(1, 2))*180/pi <= 10 && ...
   pendulum.length(1) == pendulum.length(2)
    set(handles.analytic, 'Enable', 'on')
else
    set(handles.analytic, 'Enable', 'off')
end
if ~isempty(pendulum.th_analytic)
    set(handles.show_analytic, 'Enable', 'on')
else
    set(handles.show_analytic, 'Enable', 'off')
end
handles.method = method;
switch handles.method
case 'runge_kutta'
    set(handles.method_opts, 'selectedobject', handles.runge_kutta);
case 'euler'
    set(handles.method_opts, 'selectedobject', handles.euler);
case 'symplectic_euler'
    set(handles.method_opts, 'selectedobject', handles.symplectic_euler);
end

set(handles.status, 'String', 'DATA BERHASIL DIMUAT')
set(handles.visualization, 'Enable', 'on')
set(handles.save, 'Enable', 'on')
guidata(hObject, handles);


% --- Executes on button press in analytic.
function analytic_Callback(hObject, eventdata, handles)
% hObject    handle to analytic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.integrator.analytic()
set(handles.show_analytic, 'Enable', 'on')


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



function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq as text
%        str2double(get(hObject,'String')) returns contents of freq as a double


% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_analytic.
function show_analytic_Callback(hObject, eventdata, handles)
% hObject    handle to show_analytic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_analytic
