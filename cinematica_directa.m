function [pos, R] = cinematica_directa(angulos, L1, L2, L3, L4, L5, L6)
    % Convertir ángulos a radianes
    theta1 = deg2rad(angulos(1) + 90);  % θ1 + 90°
    theta2 = deg2rad(angulos(2));
    theta3 = deg2rad(angulos(3));
    theta4 = deg2rad(angulos(4));

    % DH: [theta, d, a, alpha]
    T1 = dh_transform(theta1, L1 + L2, L3, pi/2);
    T2 = dh_transform(theta2, 0, L4, 0);
    T3 = dh_transform(theta3, 0, L5, 0);
    T4 = dh_transform(theta4, 0, L6, 0);

    % Matriz de transformación total
    T = T1 * T2 * T3 * T4;

    % Posición y rotación final
    pos = T(1:3, 4);
    R = T(1:3, 1:3);
end

% -------------------------------
% Función auxiliar DH estándar
function T = dh_transform(theta, d, a, alpha)
    T = [cos(theta), -sin(theta)*cos(alpha),  sin(theta)*sin(alpha), a*cos(theta);
         sin(theta),  cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
                  0,             sin(alpha),             cos(alpha),           d;
                  0,                      0,                      0,           1];
end
