function varargout = testGUI(varargin)

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

    handles.output = hObject;
    guidata(hObject, handles);

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


function display_values(handles)

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

    
function new_champion(champ_name)
    
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

    varargout{1} = handles.output;


% --- Executes on selection change in champion_menu.
function champion_menu_Callback(hObject, eventdata, handles)
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
function levels_menu_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    set(hObject, 'String', {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18});

    
function add_item(button, slot)

    global version
    run_gui = itemsGUI;
    waitfor(run_gui);
    global item_slots
    item = getappdata(0,'item');
    if length(item) > 1
        set(button, 'CData', [])
        set(button, 'String', item)
    else
        set(button, 'CData', imresize(imread(['http://ddragon.leagueoflegends.com/cdn/' version '/img/item/' item.image.full]),1.3))
        set(button, 'String', '')
    end
    item_slots{slot} = item;
    add_stats(slot)
    
function add_stats(slot)
    
    global item_slots
    stats = item_slots{slot};
        
% --- Executes on button press in item1.
function item1_Callback(hObject, eventdata, handles) %#ok<*INUSL>
    
    add_item(handles.item1, 1)
    
% --- Executes on button press in item2.
function item2_Callback(hObject, eventdata, handles)

    add_item(handles.item2, 2)
    
% --- Executes on button press in item3.
function item3_Callback(hObject, eventdata, handles)

    add_item(handles.item3, 3)
    
% --- Executes on button press in item4.
function item4_Callback(hObject, eventdata, handles)

    add_item(handles.item4, 4)

% --- Executes on button press in item5.
function item5_Callback(hObject, eventdata, handles)

    add_item(handles.item5, 5)

% --- Executes on button press in item6.
function item6_Callback(hObject, eventdata, handles)

    add_item(handles.item6, 6)

% --- Executes on button press in item7.
function item7_Callback(hObject, eventdata, handles)

    add_item(handles.item7, 7)
