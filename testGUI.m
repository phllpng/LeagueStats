function varargout = testGUI(varargin)
% TESTGUI MATLAB code for testGUI.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI

% Last Modified by GUIDE v2.5 09-Jun-2015 22:34:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI_OutputFcn, ...
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

    
% --- Executes just before testGUI is made visible.
function testGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI (see VARARGIN)

% Choose default command line output for testGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global version
global static_texts

version_link = 'https://global.api.pvp.net/api/lol/static-data/na/v1.2/versions?api_key=f1153217-7b9e-4adc-9036-596a248cb50b';
version = parse_json(urlread(version_link));
version = version{1};

static_texts = [handles.hp handles.hpperlevel handles.mp handles.mpperlevel handles.armor handles.armorperlevel ...
                handles.spellblock handles.spellblockperlevel handles.hpregen handles.hpregenperlevel ...
                handles.mpregen handles.mpregenperlevel handles.crit handles.critperlevel handles.attackdamage ...
                handles.attackdamageperlevel handles.attackspeed handles.attackspeedperlevel handles.abilitypower ...
                handles.abilitypowerperlevel handles.cooldown handles.cooldownperlevel handles.attackrange ...
                handles.movespeed];

new_champion('Aatrox')
display_values(handles)


function [] = display_values(handles)

    global version
    global champion
    global static_texts
    
    imshow(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/champion/' champion.id '.png']));
    set(handles.name,'String',champion.id)
    set(handles.title,'String',champion.title)
    stats = struct2cell(champion.stats);
    for i = 1:length(static_texts)
        set(static_texts(i), 'String' , num2str(str2double(sprintf('%.3f',stats{i}))))
    end

function [] = new_champion(champ_name)
    
    global version
    global champion
    
    champion_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion/' champ_name '.json'];
    champion = parse_json(urlread(champion_link));
    champion = struct2cell(champion.data);
    champion = champion{1};
    champion.stats.attackspeedoffset = .625/(1+champion.stats.attackspeedoffset); % calculates base attack speed
    champion.stats.abilitypower = 0; % create ability power field
    champion.stats.abilitypowerperlevel = 0; % create ability power per level field
    champion.stats.cooldown = 0; % create cool down field
    champion.stats.cooldownperlevel = 0; % create cool down per level field
    
    attackrange = champion.stats.attackrange;
    movespeed = champion.stats.movespeed;
    champion.stats = rmfield(champion.stats, 'attackrange');
    champion.stats = rmfield(champion.stats, 'movespeed');
    champion.stats.attackrange = attackrange;
    champion.stats.movespeed = movespeed;
   
% --- Outputs from this function are returned to the command line.
function varargout = testGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in champion_menu.
function champion_menu_Callback(hObject, eventdata, handles)
% hObject    handle to champion_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns champion_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from champion_menu

champion_list = cellstr(get(hObject,'String'));
selected_champion = champion_list{get(hObject,'Value')};

new_champion(selected_champion)
display_values(handles)
set(handles.levels_menu, 'Value', 1)


% --- Executes during object creation, after setting all properties.
function champion_menu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global version

all_champions_link = ['http://ddragon.leagueoflegends.com/cdn/' version '/data/en_US/champion.json'];
champions = parse_json(urlread(all_champions_link));

set(hObject, 'String', fieldnames(champions.data));



% --- Executes on selection change in levels_menu.
function levels_menu_Callback(hObject, eventdata, handles)
% hObject    handle to levels_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns levels_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from levels_menu
global champion

level = get(hObject, 'Value');
fields = fieldnames(champion.stats);
new_champion(champion.id)

for i  = 1:2:numel(fields)-3
    if i == 17
        champion.stats.(fields{i}) = champion.stats.(fields{i})*((.01*(level-1)*champion.stats.(fields{i+1}))+1);
    else
        champion.stats.(fields{i}) = champion.stats.(fields{i}) + champion.stats.(fields{i+1})*(level-1);
    end
end


display_values(handles)
% --- Executes during object creation, after setting all properties.
function levels_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to levels_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18});

function [] = add_item(button)
global version
run_gui = itemsGUI;
waitfor(run_gui);
item = getappdata(0,'item');
if length(item) > 1
    set(button, 'CData', [])
    set(button, 'String', item)
else
    set(button, 'CData', imresize(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' item.image.full]),1.3))
end

% --- Executes on button press in item1.
function item1_Callback(hObject, eventdata, handles)
% hObject    handle to item1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item1)

% --- Executes on button press in item2.
function item2_Callback(hObject, eventdata, handles)
% hObject    handle to item2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item2)

% --- Executes on button press in item3.
function item3_Callback(hObject, eventdata, handles)
% hObject    handle to item3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item3)

% --- Executes on button press in item4.
function item4_Callback(hObject, eventdata, handles)
% hObject    handle to item4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item4)

% --- Executes on button press in item5.
function item5_Callback(hObject, eventdata, handles)
% hObject    handle to item5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item5)

% --- Executes on button press in item6.
function item6_Callback(hObject, eventdata, handles)
% hObject    handle to item6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item6)

% --- Executes on button press in item7.
function item7_Callback(hObject, eventdata, handles)
% hObject    handle to item7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_item(handles.item7)
