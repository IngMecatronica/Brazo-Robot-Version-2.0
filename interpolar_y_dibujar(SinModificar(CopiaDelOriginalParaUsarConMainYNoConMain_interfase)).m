function nuevo_estado = interpolar_y_dibujar(desde, hasta, pasos, L1, L2, L3, L4, L5, L6, limites)
    for i = 1:pasos
        paso = desde + (hasta - desde) * i / pasos;

        % Verificación de límites
        fuera = ...
            paso(1) < limites(1,1) || paso(1) > limites(1,2) || ...
            paso(2) < limites(2,1) || paso(2) > limites(2,2) || ...
            paso(3) < limites(3,1) || paso(3) > limites(3,2) || ...
            paso(4) < limites(4,1) || paso(4) > limites(4,2);

        paso(3) = -paso(3);  % invertir g3

        % Convertir a radianes
        g1 = deg2rad(paso(1));
        g2 = deg2rad(paso(2));
        g3 = deg2rad(paso(3));
        g4 = deg2rad(paso(4));

        % Cinemática directa
        P0 = [0; 0; 0];
        P1 = P0 + [0; 0; L1];
        P2 = P1 + [0; 0; L2];
        P3 = P2 + [L3*cos(g1); L3*sin(g1); 0];
        P4 = P3 + [L4*cos(g1)*cos(g2); L4*sin(g1)*cos(g2); L4*sin(g2)];
        P5 = P4 + [L5*cos(g1)*cos(g2+g3); L5*sin(g1)*cos(g2+g3); L5*sin(g2+g3)];
        P6 = P5 + [L6*cos(g1)*cos(g2+g3+g4); L6*sin(g1)*cos(g2+g3+g4); L6*sin(g2+g3+g4)];

        % Dibujar
        figure(1); clf;   <<<------------------Para cuando no hay interface
        %axes(app.UIAxes); cla(app.UIAxes); % <<<<<<<-----para cunado hay interface
        plot3([P0(1) P1(1)], [P0(2) P1(2)], [P0(3) P1(3)], 'k', 'LineWidth', 3); hold on;
        plot3([P1(1) P2(1)], [P1(2) P2(2)], [P1(3) P2(3)], 'k', 'LineWidth', 3);
        plot3([P2(1) P3(1)], [P2(2) P3(2)], [P2(3) P3(3)], 'b', 'LineWidth', 3);
        plot3([P3(1) P4(1)], [P3(2) P4(2)], [P3(3) P4(3)], 'r', 'LineWidth', 3);
        plot3([P4(1) P5(1)], [P4(2) P5(2)], [P4(3) P5(3)], 'g', 'LineWidth', 3);
        plot3([P5(1) P6(1)], [P5(2) P6(2)], [P5(3) P6(3)], 'm', 'LineWidth', 3);
        plot3(P6(1), P6(2), P6(3), 'o', 'MarkerSize', 8, ...
              'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k');

        xlabel('X'); ylabel('Y'); zlabel('Z');
        title('Simulación brazo robótico 3D');
        grid on; box on; axis equal;
        view(45, 30);
        xlim([-50 500]); ylim([-200 300]); zlim([-50 500]);

        if fuera
            text(0, 0, 450, '⚠️ ¡Ángulo fuera de límites!', ...
                'Color', 'r', 'FontSize', 14, 'FontWeight', 'bold');
        end

        pause(0.02);
    end

    nuevo_estado = hasta;
end