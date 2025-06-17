clc; clear; close all;
  
%% Parámetros del robot
L4 = 50;   % Base a articulación 2
L5 = 125;  % Longitud eslabón 1
L6 = 125;  % Longitud eslabón 2
L7 = 120;  % Longitud muñeca (efector final)

% Límites de cada articulación
g1_lim = [-180, 180];
g2_lim = [-35, 145];
g3_lim = [-35, 145]; % Recuerda que g3 está invertido
g4_lim = [-90, 90];  % No se usa aquí

% Rango de puntos a probar
[x_vals, y_vals, z_vals] = meshgrid(-250:25:250, -250:25:250, 0:25:400);

% Almacenar puntos alcanzables y no alcanzables
alcanzables = [];
no_alcanzables = [];

%% Revisión punto por punto
for i = 1:numel(x_vals)
    x = x_vals(i); y = y_vals(i); z = z_vals(i);

    % Cinemática inversa (simplificada, usando tu función)
    % Calcular θ1
    teta1 = atan2(y, x);
    
    % Coordenadas en plano r-z
    r = sqrt(x^2 + y^2);
    z_ = z - L4;
    R = sqrt(r^2 + z_^2);

    % Verificar si está dentro del alcance físico
    if R > (L5 + L6 + L7)
        no_alcanzables(end+1, :) = [x, y, z];
        continue
    end

    % Ley del coseno para teta3
    cos_t3 = (R^2 - L5^2 - (L6+L7)^2) / (2 * L5 * (L6+L7));
    if abs(cos_t3) > 1
        no_alcanzables(end+1, :) = [x, y, z];
        continue
    end
    teta3 = -acos(cos_t3);  % Negativo por inversión

    % Calcular teta2
    alpha = atan2(z_, r);
    beta = atan2((L6+L7)*sin(-teta3), L5 + (L6+L7)*cos(-teta3));
    teta2 = alpha - beta;

    % Convertir a grados
    g1 = rad2deg(teta1);
    g2 = rad2deg(teta2);
    g3 = -rad2deg(teta3); % Invertimos el signo

    % Verificar si está dentro de límites
    if g1 >= g1_lim(1) && g1 <= g1_lim(2) && ...
       g2 >= g2_lim(1) && g2 <= g2_lim(2) && ...
       g3 >= g3_lim(1) && g3 <= g3_lim(2)
        alcanzables(end+1, :) = [x, y, z];
    else
        no_alcanzables(end+1, :) = [x, y, z];
    end
end

%% Visualización
figure;
if ~isempty(alcanzables)
    scatter3(alcanzables(:,1), alcanzables(:,2), alcanzables(:,3), 20, 'g', 'filled');
    hold on;
end
if ~isempty(no_alcanzables)
    scatter3(no_alcanzables(:,1), no_alcanzables(:,2), no_alcanzables(:,3), 20, 'r', 'filled');
end
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
title('Zona de trabajo del robot');
legend('Alcanzable', 'No alcanzable');
axis equal; grid on;
