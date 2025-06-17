function main_interface()
    % ------------------------- PARÁMETROS INICIALES -------------------------
    L1 = 62; L2 = 45; L3 = 39;
    L4 = 150; L5 = 140; L6 = 61;
    phi_default = 0.0;
    POS_INICIAL = [90 180 145 35];
    POS_FINAL = [0 180 145 0];
    limites = [0 180; -45 180; 0 180; -35 180];

    estado_actual = POS_INICIAL;
    pasos_interp = 30;
    ejecutando = false;
    detenido = false;

    % ------------------------- ARDUINO Y ELECTROIMÁN -------------------------
    electroiman_estado = 0;
    arduinoActivo = false;
    pausaComunicacion = false;
    puertoSerial = [];

    % ------------------------- VENTANA PRINCIPAL -------------------------
    fig = uifigure('Name', 'Interfaz Brazo Robótico', 'Position', [100 100 1000 600]);

    ax = uiaxes(fig, 'Position', [350 130 620 420]);
    title(ax, 'Vista 3D del Robot');
    xlabel(ax, 'X'); ylabel(ax, 'Y'); zlabel(ax, 'Z');
    view(ax, 45, 30);

    % ------------------------- SECCIÓN: Coordenadas Efector Final -------------------------
    uilabel(fig, 'Text', 'X Final', 'Position', [400 80 60 22]);
    xEfField = uieditfield(fig, 'numeric', 'Position', [460 80 80 22], 'Editable', 'off');
    uilabel(fig, 'Text', 'Y Final', 'Position', [560 80 60 22]);
    yEfField = uieditfield(fig, 'numeric', 'Position', [620 80 80 22], 'Editable', 'off');
    uilabel(fig, 'Text', 'Z Final', 'Position', [720 80 60 22]);
    zEfField = uieditfield(fig, 'numeric', 'Position', [780 80 80 22], 'Editable', 'off');

    % ------------------------- MENSAJES DE COMANDO -------------------------
    commandBox = uitextarea(fig, 'Position', [30 500 320 40], 'Editable', 'off');
    function mostrar_comando(msg)
        commandBox.Value = [commandBox.Value; msg];
    end

    % ------------------------- DIBUJAR ESTADO INICIAL -------------------------
    dibujar_estado(POS_INICIAL);

    function dibujar_estado(ang)
        [estado_actual, efector_pos] = interpolar_y_dibujar(estado_actual, ang, pasos_interp, ...
            L1, L2, L3, L4, L5, L6, limites, ax);
        xEfField.Value = efector_pos(1);
        yEfField.Value = efector_pos(2);
        zEfField.Value = efector_pos(3);
    end

    % ------------------------- SLIDERS Y CAMPOS NUMÉRICOS -------------------------
    labels = {'g1', 'g2', 'g3', 'g4'};
    sliders = gobjects(1,4);
    edits = gobjects(1,4);

    for i = 1:4
        y_base = 480 - 70 * i;
        uilabel(fig, 'Text', labels{i}, 'Position', [30 y_base 30 22]);

        slider_limites = limites(i,:);
        sliders(i) = uislider(fig, 'Position', [80 y_base+10 150 3], ...
            'Limits', slider_limites, 'Value', POS_INICIAL(i), 'Enable', 'off');

        edits(i) = uieditfield(fig, 'numeric', 'Position', [240 y_base 60 22], ...
            'Limits', slider_limites, 'Value', POS_INICIAL(i), 'Enable', 'off');

        sliders(i).ValueChangedFcn = @(s, ~) sync_slider_edit(i, s.Value);
        edits(i).ValueChangedFcn = @(e, ~) sync_edit_slider(i, e.Value);
    end

    function sync_slider_edit(idx, val)
        edits(idx).Value = val;
        actualizar_robot();
    end

    function sync_edit_slider(idx, val)
        sliders(idx).Value = val;
        actualizar_robot();
    end

    % ------------------------- CAMPOS DE COORDENADAS Y PHI -------------------------
    uilabel(fig, 'Text', 'X', 'Position', [30 120 20 22]);
    xField = uieditfield(fig, 'numeric', 'Position', [50 120 60 22]);
    uilabel(fig, 'Text', 'Y', 'Position', [120 120 20 22]);
    yField = uieditfield(fig, 'numeric', 'Position', [140 120 60 22]);
    uilabel(fig, 'Text', 'Z', 'Position', [210 120 20 22]);
    zField = uieditfield(fig, 'numeric', 'Position', [230 120 60 22]);
    uilabel(fig, 'Text', 'Phi', 'Position', [30 85 30 22]);
    phiField = uieditfield(fig, 'numeric', 'Position', [70 85 60 22], 'Value', phi_default);

    invBtn = uibutton(fig, 'Text', 'Aplicar cinemática inversa', ...
        'Position', [140 85 160 22], 'ButtonPushedFcn', @(~,~) resolverInversa());

    function resolverInversa()
        if ~(ejecutando && ~detenido)
            uialert(fig, 'Debe presionar START para habilitar la ejecución.', 'Advertencia');
            return;
        end

        xyz = [-yField.Value, xField.Value, zField.Value];
        phi = phiField.Value;

        angs = cinematica_inversa(xyz, phi, -1, L1, L2, L3, L4, L5, L6);

        if isempty(angs)
            uialert(fig, 'Posición no alcanzable.', 'Error');
            return;
        end

        % Mostrar advertencia pero no detener (NO usar uialert)
        for i = 1:4
            if angs(i) < limites(i,1) || angs(i) > limites(i,2)
                mostrar_comando(sprintf('Advertencia: Ángulo g%d fuera de límites (%.1f°)', i, angs(i)));
            end
        end

        % Saturar y asignar ángulos a sliders y edits
        for i = 1:4
            slider_limites = sliders(i).Limits;
            val_saturado = max(slider_limites(1), min(slider_limites(2), angs(i)));
            sliders(i).Value = val_saturado;
            edits(i).Value = val_saturado;
        end
        actualizar_robot();
    end

    % ------------------------- BOTONES PRINCIPALES -------------------------
    startBtn = uibutton(fig, 'Text', 'Start', 'Position', [30 30 60 30], 'ButtonPushedFcn', @(~,~) onStart());
    stopBtn = uibutton(fig, 'Text', 'Stop', 'Position', [100 30 60 30], 'ButtonPushedFcn', @(~,~) onStop());
    resetBtn = uibutton(fig, 'Text', 'Reset', 'Position', [170 30 60 30], 'ButtonPushedFcn', @(~,~) onReset());
    salirBtn = uibutton(fig, 'Text', 'Salir', 'Position', [240 30 60 30], 'ButtonPushedFcn', @(~,~) onSalir());

    function onStart()
        ejecutando = true;
        detenido = false;
        for i = 1:4
            sliders(i).Enable = 'on';
            edits(i).Enable = 'on';
        end
    end

    function onStop()
        detenido = ~detenido;
        estado = 'off';
        if ~detenido, estado = 'on'; end
        for i = 1:4
            sliders(i).Enable = estado;
            edits(i).Enable = estado;
        end
    end

    function onReset()
        for i = 1:4
            sliders(i).Value = POS_INICIAL(i);
            edits(i).Value = POS_INICIAL(i);
        end
        actualizar_robot();
    end

    function onSalir()
        if ~isempty(puertoSerial) && isvalid(puertoSerial)
            delete(puertoSerial);
            mostrar_comando("Arduino desconectado al cerrar la interfaz.");
        end
        ejecutando = true;
        detenido = false;
        dibujar_estado(POS_FINAL);
        pause(0.5);
        close(fig);
    end

    % ------------------------- COMUNICACIÓN ARDUINO Y ELECTROIMÁN -------------------------
    uilabel(fig, 'Text', 'Comunicación Arduino', 'FontWeight','bold', 'Position', [30 580 200 22]);
    onBtn = uibutton(fig, 'Text', 'ON', 'Position', [30 550 50 25], 'ButtonPushedFcn', @(btn,~) toggleCom(btn, true));
    offBtn = uibutton(fig, 'Text', 'OFF', 'Position', [90 550 50 25], 'ButtonPushedFcn', @(btn,~) toggleCom(btn, false));
    stopComBtn = uibutton(fig, 'Text', 'STOP', 'Position', [150 550 50 25], 'ButtonPushedFcn', @(~,~) pausarArduino());
    imanBtn = uibutton(fig, 'Text', 'EIman', 'Position', [290 550 60 25], 'BackgroundColor', [1 0 0], 'ButtonPushedFcn', @(btn,~) toggleIman(btn));

    function toggleIman(btn)
        electroiman_estado = ~electroiman_estado;
        if electroiman_estado
            btn.BackgroundColor = [0 1 0];
        else
            btn.BackgroundColor = [1 0 0];
        end
        mostrar_comando("Electroimán: " + string(electroiman_estado));
        actualizar_robot();
    end

    function toggleCom(btn, activar)
        if activar
            conectarArduino();
            btn.BackgroundColor = [0 1 0];
            offBtn.BackgroundColor = [1 0 0];
        else
            desconectarArduino();
            btn.BackgroundColor = [1 0 0];
            onBtn.BackgroundColor = [0 1 0];
        end
    end

    function conectarArduino()
        try
            puertoSerial = serialport("COM4", 115200); % Cambia el puerto si es necesario
            pause(2);
            arduinoActivo = true;
            pausaComunicacion = false;
            mostrar_comando("Arduino conectado.");
        catch
            uialert(fig, 'No se pudo conectar con Arduino.', 'Error');
        end
    end

    function desconectarArduino()
        if ~isempty(puertoSerial) && isvalid(puertoSerial)
            delete(puertoSerial);
            puertoSerial = [];
            arduinoActivo = false;
            pausaComunicacion = false;
            mostrar_comando("Arduino desconectado.");
        end
    end

    function pausarArduino()
        pausaComunicacion = ~pausaComunicacion;
        estado = "pausada";
        if ~pausaComunicacion
            estado = "activa";
        end
        mostrar_comando("Comunicación con Arduino " + estado);
    end

    % ------------------------- ACTUALIZAR ROBOT (Y ENVIAR A ARDUINO) -------------------------
    function actualizar_robot()
        if ejecutando && ~detenido
            valores = [sliders(1).Value, sliders(2).Value, sliders(3).Value, sliders(4).Value];
    
            % Aplica offset para simulación (si es necesario)
            valores_con_offset = valores;
            valores_con_offset(2) = valores(2) + 45;  % Offset de g2 para simulación
            valores_con_offset(4) = valores(4) + 35;  % Offset de g4 para simulación
    
            dibujar_estado(valores_con_offset);  % Enviar valores con offset a la simulación

            % Enviar a Arduino (sin offset extra)
            if arduinoActivo && ~pausaComunicacion && isvalid(puertoSerial)
                try
                    valores_envio = valores; % aquí puedes ajustar offsets físicos si tu hardware lo requiere
                    valores_envio(3) = -valores_envio(3); % invertir g3 si lo requiere tu hardware
                    comando = sprintf('A%d,%d,%d,%d,%d', round(valores_envio), electroiman_estado);
                    writeline(puertoSerial, comando);
                    mostrar_comando(comando);
                catch
                    mostrar_comando("Error al enviar datos a Arduino.");
                end
            end
        end
    end
end