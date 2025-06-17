function [nuevo_estado, efector_pos] = interpolar_y_dibujar(desde, hasta, pasos, L1, L2, L3, L4, L5, L6, limites, ax)
    % Offsets según tu configuración
    offset_g2 = -45;
    offset_g4 = -70;
    
    for i = 1:pasos
        paso = desde + (hasta - desde) * i / pasos;

        fuera = ...
            paso(1) < limites(1,1) || paso(1) > limites(1,2) || ...
            paso(2) < limites(2,1) || paso(2) > limites(2,2) || ...
            paso(3) < limites(3,1) || paso(3) > limites(3,2) || ...
            paso(4) < limites(4,1) || paso(4) > limites(4,2);

        % -------------------------
        % Aplicar offsets (igual que en GraficaBrazo)
        % -------------------------
        g1 = deg2rad(paso(1));                    % g1 sin offset
        g2 = deg2rad(paso(2) + offset_g2);       % g2 con offset -45°
        g3 = -deg2rad(paso(3));                  % g3 invertido
        g4 = deg2rad(paso(4) + offset_g4);       % g4 con offset -35°

        % -------------------------
        % Cálculo de posiciones (igual que en GraficaBrazo)
        % -------------------------
        P0 = [0; 0; 0];
        P1 = P0 + [0; 0; L1];
        P2 = P1 + [0; 0; L2];
        P3 = P2 + L3 * [cos(g1); sin(g1); 0];
        
        % Dirección del eslabón rojo
        dir3 = [cos(g1)*cos(g2); sin(g1)*cos(g2); sin(g2)];
        P4 = P3 + L4 * dir3;
        
        % Dirección del eslabón verde (con g3 invertido)
        dir4 = [cos(g1)*cos(g2 + g3); sin(g1)*cos(g2 + g3); sin(g2 + g3)];
        P5 = P4 + L5 * dir4;
        
        % Dirección del eslabón fucsia (con offset -35°)
        dir5 = [cos(g1)*cos(g2 + g3 + g4); sin(g1)*cos(g2 + g3 + g4); sin(g2 + g3 + g4)];
        P6 = P5 + L6 * dir5;

        % -------------------------
        % Dibujo
        % -------------------------
        cla(ax);
        hold(ax, 'on');
        plot3(ax, [P0(1) P1(1)], [P0(2) P1(2)], [P0(3) P1(3)], 'k', 'LineWidth', 3); % L1
        plot3(ax, [P1(1) P2(1)], [P1(2) P2(2)], [P1(3) P2(3)], 'b', 'LineWidth', 3); % L2
        plot3(ax, [P2(1) P3(1)], [P2(2) P3(2)], [P2(3) P3(3)], 'c', 'LineWidth', 3); % L3
        plot3(ax, [P3(1) P4(1)], [P3(2) P4(2)], [P3(3) P4(3)], 'r', 'LineWidth', 3); % rojo
        plot3(ax, [P4(1) P5(1)], [P4(2) P5(2)], [P4(3) P5(3)], 'g', 'LineWidth', 3); % verde
        plot3(ax, [P5(1) P6(1)], [P5(2) P6(2)], [P5(3) P6(3)], 'm', 'LineWidth', 3); % fucsia
        plot3(ax, P6(1), P6(2), P6(3), 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

        title(ax, 'Simulación brazo robótico 3D');
        xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
        view(ax, 45, 30);
        grid(ax, 'on'); axis(ax, 'equal');
        xlim(ax, [-200 300]); ylim(ax, [-300 300]); zlim(ax, [-100 400]);

        if fuera
            text(ax, 0, 0, 350, '⚠️ ¡Ángulo fuera de límites!', ...
                'Color', 'r', 'FontSize', 14, 'FontWeight', 'bold');
        end

        pause(0.02);
    end

    nuevo_estado = hasta;
    efector_pos = P6;  % Coordenadas finales del efector (x, y, z)
end