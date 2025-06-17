clc; 
clear;
close all;

% -------------------------
% PARÁMETROS GEOMÉTRICOS
% -------------------------
L1 = 62; L2 = 45; L3 = 39;
L4 = 150; L5 = 140; L6 = 61;

% -------------------------
% CONFIGURACIÓN
% -------------------------
phi = 0.0;     % Orientación deseada del efector
CODO = -1;     % Configuración de codo
nSteps = 50;   % Pasos de interpolación

% -------------------------
% LÍMITES ANGULARES (grados)
% -------------------------
limites = [
    -180, 180;   % g1
    -35, 145;    % g2
    -35, 145;    % g3 (invertido)
    -90, 90      % g4
];

% -------------------------
% POSICIONES
% -------------------------
POS_INICIAL = [0 145 145 0];       % Posición inicial por defecto
POS_DESCANSO = [0 145 145 -90];    % Posición al salir

% -------------------------
% INICIO
% -------------------------
estado_actual = [0 0 0 0];
estado_actual = interpolar_y_dibujar(estado_actual, POS_INICIAL, nSteps, L1, L2, L3, L4, L5, L6, limites);

% -------------------------
% BUCLE PRINCIPAL
% -------------------------
ejecutando = true;

while ejecutando
    entrada = input('\nIngrese coordenadas [-Y X Z] o "salir": ', 's');

    if strcmpi(entrada, 'salir')
        disp('🔚 Moviendo a posición de descanso...');
        estado_actual = interpolar_y_dibujar(estado_actual, POS_DESCANSO, nSteps, L1, L2, L3, L4, L5, L6, limites);
        disp('✅ Finalizado correctamente.');
        ejecutando = false;  % Salir del bucle
        break;               % Finaliza la ejecución del bucle sin reinicio
    end

    coords = str2num(entrada); %#ok<ST2NM>
    if length(coords) ~= 3
        disp('❌ Entrada inválida. Use el formato: [-Y X Z]');
        continue;
    end

    % Cinemática inversa
    angulos = cinematica_inversa(coords, phi, CODO, L1, L2, L3, L4, L5, L6);
    if isempty(angulos)
        disp('❌ Posición no alcanzable.');
        continue;
    end

    % Movimiento interpolado
    estado_actual = interpolar_y_dibujar(estado_actual, angulos, nSteps, L1, L2, L3, L4, L5, L6, limites);
end
