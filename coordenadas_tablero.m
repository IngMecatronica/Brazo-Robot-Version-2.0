function coord = coordenadas_tablero(fila, columna)
% COORDENADAS_DAMAS - Almacena y devuelve las coordenadas de un tablero de damas 8x8
% Uso: coord = coordenadas_damas(fila, columna)
%   fila: número entre 1-8 (1=abajo, 8=arriba)
%   columna: letra A-H o número 1-8 (A/1=izquierda, H/8=derecha)
%   coord: vector [x,y,z] con las coordenadas de esa posición
%
% Para obtener todas las coordenadas: matriz = coordenadas_damas()
%
% Ejemplos:
% - Para obtener coordenadas de A1: coordenadas_damas(1, 1) o coordenadas_damas(1, 'A')
% - Para obtener coordenadas de H8: coordenadas_damas(8, 8) o coordenadas_damas(8, 'H')

% Matriz de coordenadas [x,y,z] para cada posición del tablero
% Formato: tablero(fila, columna, :) = [x, y, z];
    
tablero = zeros(8, 8, 3);

% ------ FILA 8 (arriba) ------
tablero(8, 1, :) = [-85, 365, 70];  % Posición A8
tablero(8, 2, :) = [-50, 365, 70];  % Posición B8
tablero(8, 3, :) = [-20, 360, 70];  % Posición C8
tablero(8, 4, :) = [16, 355, 60]; % Posición D8
tablero(8, 5, :) = [46, 350, 65]; % Posición E8
tablero(8, 6, :) = [75, 355, 65]; % Posición F8
tablero(8, 7, :) = [105, 355, 65]; % Posición G8
tablero(8, 8, :) = [130, 355, 65]; % Posición H8

% ------ FILA 7 ------
tablero(7, 1, :) = [-85, 330, 55];  % Posición A7
tablero(7, 2, :) = [-50, 325, 60];  % Posición B7
tablero(7, 3, :) = [-20, 320, 60];  % Posición C7
tablero(7, 4, :) = [10, 320, 60]; % Posición D7
tablero(7, 5, :) = [45, 315, 55]; % Posición E7
tablero(7, 6, :) = [75, 315, 55]; % Posición F7
tablero(7, 7, :) = [105, 315, 55]; % Posición G7
tablero(7, 8, :) = [135, 315, 55]; % Posición H7

% ------ FILA 6 ------
tablero(6, 1, :) = [-80, 290, 45];  % Posición A6
tablero(6, 2, :) = [-50, 290, 45];  % Posición B6
tablero(6, 3, :) = [-20, 285, 45];  % Posición C6
tablero(6, 4, :) = [10, 280, 45]; % Posición D6
tablero(6, 5, :) = [40, 280, 50]; % Posición E6
tablero(6, 6, :) = [70, 280, 50]; % Posición F6
tablero(6, 7, :) = [100, 280, 50]; % Posición G6
tablero(6, 8, :) = [140, 280, 50]; % Posición H6

% ------ FILA 5 ------
tablero(5, 1, :) = [-75, 260, 40];  % Posición A5
tablero(5, 2, :) = [-40, 250, 50];  % Posición B5
tablero(5, 3, :) = [-10, 250, 45];  % Posición C5
tablero(5, 4, :) = [20, 250, 45]; % Posición D5
tablero(5, 5, :) = [50, 240, 40]; % Posición E5
tablero(5, 6, :) = [80, 240, 45]; % Posición F5
tablero(5, 7, :) = [105, 195, 20]; % Posición G5
tablero(5, 8, :) = [145, 230, 40]; % Posición H5

% ------ FILA 4 ------
tablero(4, 1, :) = [-75, 230, 40];  % Posición A4
tablero(4, 2, :) = [-40, 220, 40];  % Posición B4
tablero(4, 3, :) = [-10, 215, 40];  % Posición C4
tablero(4, 4, :) = [20, 210, 40]; % Posición D4
tablero(4, 5, :) = [50, 210, 40]; % Posición E4
tablero(4, 6, :) = [80, 205, 40]; % Posición F4
tablero(4, 7, :) = [105, 195, 40]; % Posición G4
tablero(4, 8, :) = [135, 195, 40]; % Posición H4

% ------ FILA 3 ------
tablero(3, 1, :) = [-70, 190, 40];  % Posición A3
tablero(3, 2, :) = [-40, 190, 40];  % Posición B3
tablero(3, 3, :) = [-5, 185, 40];  % Posición C3
tablero(3, 4, :) = [25, 180, 40]; % Posición D3
tablero(3, 5, :) = [55, 170, 40]; % Posición E3
tablero(3, 6, :) = [75, 170, 40]; % Posición F3
tablero(3, 7, :) = [105, 160, 40]; % Posición G3
tablero(3, 8, :) = [135, 160, 40]; % Posición H3

% ------ FILA 2 ------
tablero(2, 1, :) = [-65, 165, 50];  % Posición A2
tablero(2, 2, :) = [-35, 160, 45];  % Posición B2
tablero(2, 3, :) = [-5, 160, 45];  % Posición C2
tablero(2, 4, :) = [20, 155, 45]; % Posición D2
tablero(2, 5, :) = [45, 155, 45]; % Posición E2
tablero(2, 6, :) = [75, 145, 45]; % Posición F2
tablero(2, 7, :) = [105, 135, 45]; % Posición G2
tablero(2, 8, :) = [120, 135, 45]; % Posición H2

% ------ FILA 1 (abajo) ------
tablero(1, 1, :) = [-65, 135, 55];  % Posición A1
tablero(1, 2, :) = [-35, 135, 60];  % Posición B1
tablero(1, 3, :) = [-10, 135, 65];  % Posición C1
tablero(1, 4, :) = [20, 139, 70]; % Posición D1
tablero(1, 5, :) = [45, 125, 65]; % Posición E1
tablero(1, 6, :) = [70, 120, 65]; % Posición F1
tablero(1, 7, :) = [90, 115, 60]; % Posición G1
tablero(1, 8, :) = [120, 110, 55]; % Posición H1

% Si se llama sin argumentos, devolver toda la matriz
if nargin == 0
    coord = tablero;
    return;
end

% Si columna es una letra (A-H), convertirla a número (1-8)
if ischar(columna) || isstring(columna)
    columna = upper(char(columna));
    if length(columna) ~= 1 || columna < 'A' || columna > 'H'
        error('La columna debe ser una letra entre A y H');
    end
    columna = columna - 'A' + 1;  % Convertir A=1, B=2, etc.
end

% Verificar índices
if fila < 1 || fila > 8 || columna < 1 || columna > 8
    error('Los índices deben estar entre 1-8 para filas y A-H o 1-8 para columnas');
end

% Devolver las coordenadas específicas
coord = squeeze(tablero(fila, columna, :));
end