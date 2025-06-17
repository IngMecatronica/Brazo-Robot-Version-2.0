function mover_pieza_damas(origen, destino, interfaz_obj)
% MOVER_PIEZA_DAMAS - Mueve una pieza de un lugar a otro en un tablero de damas
%
% Uso: mover_pieza_damas('A4', 'B5')
% O para usar tu sistema de control: mover_pieza_damas('A4', 'B5', true)
%
%   origen - Posición inicial (ej: 'A4')
%   destino - Posición final (ej: 'B5')
%   interfaz_obj - (Opcional) true para usar hardware real, falso o vacío para simulación
%
% Si se pasa "true" como tercer parámetro, usa las funciones de hardware

    % Verificar si interfaz_obj fue proporcionado, si no, asignar un valor vacío
    if nargin < 3
        interfaz_obj = [];
        modo_hardware = false;
    else
        modo_hardware = true;
    end

    % Parámetros de movimiento
    altura_segura = 40;      % Altura adicional para evitar colisiones (mm)
    pausa_movimiento = 1.0;  % Pausa entre movimientos (segundos)
    
    % Posición de reposo del robot - ajustar según tu configuración
    pos_reposo = [90, 180, 145, 35]; % [g1, g2, g3, g4]
    
    % Verificar formato de las entradas
    if ~ischar(origen) && ~isstring(origen) || length(char(origen)) ~= 2
        error('El origen debe tener formato de letra y número (Ej: A4)');
    end
    if ~ischar(destino) && ~isstring(destino) || length(char(destino)) ~= 2
        error('El destino debe tener formato de letra y número (Ej: B5)');
    end
    
    % Convertir a caracteres si son strings
    origen = char(origen);
    destino = char(destino);
    
    % Extraer fila y columna
    columna_origen = origen(1);
    fila_origen = str2double(origen(2));
    columna_destino = destino(1);
    fila_destino = str2double(destino(2));
    
    % Verificar si los valores son válidos
    if isnan(fila_origen) || isnan(fila_destino)
        error('Los números de fila deben ser dígitos del 1 al 8');
    end
    
    % Obtener coordenadas usando la función coordenadas_tablero
    try
        coord_origen = coordenadas_tablero(fila_origen, columna_origen);
        coord_destino = coordenadas_tablero(fila_destino, columna_destino);
    catch e
        error('Error al obtener coordenadas: %s', e.message);
    end
    
    % Mostrar información del movimiento
    fprintf('\n--- MOVIMIENTO DE PIEZA ---\n');
    fprintf('Origen: %s (%d,%s) -> X=%.1f, Y=%.1f, Z=%.1f\n', ...
        origen, fila_origen, columna_origen, coord_origen(1), coord_origen(2), coord_origen(3));
    fprintf('Destino: %s (%d,%s) -> X=%.1f, Y=%.1f, Z=%.1f\n', ...
        destino, fila_destino, columna_destino, coord_destino(1), coord_destino(2), coord_destino(3));
    
    % Indicar modo de ejecución
    if modo_hardware
        fprintf('Modo: HARDWARE FÍSICO\n');
    else
        fprintf('Modo: SIMULACIÓN (no mueve el brazo físico)\n');
    end
    
    % Crear puntos de aproximación elevados para evitar colisiones
    coord_origen_alto = coord_origen;
    coord_origen_alto(3) = coord_origen(3) + altura_segura;
    
    coord_destino_alto = coord_destino;
    coord_destino_alto(3) = coord_destino(3) + altura_segura;
    
    % Secuencia de movimiento
    % 1. Mover a posición por encima del origen
    fprintf('\nPaso 1: Moviendo a posición por encima del origen...\n');
    mover_a_coordenada(coord_origen_alto, modo_hardware);
    pause(pausa_movimiento);
    
    % 2. Bajar a la posición origen
    fprintf('Paso 2: Bajando a posición de origen...\n');
    mover_a_coordenada(coord_origen, modo_hardware);
    pause(pausa_movimiento);
    
    % 3. Activar electroimán
    fprintf('Paso 3: Activando electroimán...\n');
    controlar_electroiman(true, modo_hardware);
    pause(pausa_movimiento);
    
    % 4. Levantar a posición segura
    fprintf('Paso 4: Elevando pieza...\n');
    mover_a_coordenada(coord_origen_alto, modo_hardware);
    pause(pausa_movimiento);
    
    % 5. Mover a posición por encima del destino
    fprintf('Paso 5: Moviendo a posición por encima del destino...\n');
    mover_a_coordenada(coord_destino_alto, modo_hardware);
    pause(pausa_movimiento);
    
    % 6. Bajar a la posición destino
    fprintf('Paso 6: Bajando a posición de destino...\n');
    mover_a_coordenada(coord_destino, modo_hardware);
    pause(pausa_movimiento);
    
    % 7. Desactivar electroimán
    fprintf('Paso 7: Desactivando electroimán...\n');
    controlar_electroiman(false, modo_hardware);
    pause(pausa_movimiento);
    
    % 8. Levantar a posición segura
    fprintf('Paso 8: Elevando brazo...\n');
    mover_a_coordenada(coord_destino_alto, modo_hardware);
    pause(pausa_movimiento);
    
    % 9. Volver a posición de reposo
    fprintf('Paso 9: Volviendo a posición de reposo...\n');
    mover_a_posicion_reposo(modo_hardware);
    
    fprintf('\n¡Movimiento completado con éxito!\n');
end

% Función para mover a una coordenada específica
function mover_a_coordenada(coordenada, modo_hardware)
    % Ajustar coordenadas según convención del robot
    x = coordenada(1);
    y = coordenada(2);
    z = coordenada(3);
    
    % Mostrar coordenada objetivo
    fprintf('  → Moviendo a: X=%.1f, Y=%.1f, Z=%.1f\n', x, y, z);
    
    % Calcular ángulos usando cinemática inversa
    try
        % Ajustar el orden de coordenadas según tu sistema
        xyz = [-y, x, z]; % IMPORTANTE: Ajusta según la convención que uses en tu robot
        phi = 0.0;  % Ángulo de la herramienta
        
        % Parámetros de DH (ajusta según tu sistema)
        L1 = 62; L2 = 45; L3 = 39; L4 = 150; L5 = 140; L6 = 61;
        
        % Utiliza la cinemática inversa para obtener ángulos
        angulos = cinematica_inversa(xyz, phi, -1, L1, L2, L3, L4, L5, L6);
        
        if isempty(angulos)
            fprintf('  ⚠ ¡Advertencia! Posición fuera de alcance: [%.1f, %.1f, %.1f]\n', x, y, z);
            return;
        end
        
        fprintf('  → Ángulos calculados: g1=%.1f°, g2=%.1f°, g3=%.1f°, g4=%.1f°\n', ...
                angulos(1), angulos(2), angulos(3), angulos(4));
        
        % Si estamos en modo hardware, mover el brazo físico
        if modo_hardware
            % IMPORTANTE: AQUÍ DEBES USAR TUS PROPIAS FUNCIONES PARA MOVER EL BRAZO
            % Este es un ejemplo genérico, que deberías reemplazar con tu implementación real
            
            % Reemplaza estas líneas con llamadas a tus propias funciones de control
            % Por ejemplo:
            mover_articulacion(1, angulos(1));  % Articulación 1
            mover_articulacion(2, angulos(2));  % Articulación 2
            mover_articulacion(3, angulos(3));  % Articulación 3
            mover_articulacion(4, angulos(4));  % Articulación 4
        else
            fprintf('  → Modo simulación: No se mueve el brazo físico\n');
        end
        
    catch e
        fprintf('  ⚠ Error en cinemática inversa: %s\n', e.message);
    end
end

% Función para controlar el electroimán
function controlar_electroiman(activar, modo_hardware)
    if activar
        estado = 'ACTIVADO';
    else
        estado = 'DESACTIVADO';
    end
    
    fprintf('  → Electroimán %s\n', estado);
    
    % Si estamos en modo hardware, controlar el electroimán físico
    if modo_hardware
        % IMPORTANTE: AQUÍ DEBES USAR TU PROPIA FUNCIÓN PARA CONTROLAR EL ELECTROIMÁN
        % Este es un ejemplo genérico, que deberías reemplazar con tu implementación real
        
        % Reemplaza esta línea con la llamada a tu función de control del electroimán
        % Por ejemplo:
        controlar_salida_electroiman(activar);  % Tu función para controlar el electroimán
    else
        fprintf('  → Modo simulación: No se controla el electroimán físico\n');
    end
end

% Función para volver a posición de reposo
function mover_a_posicion_reposo(modo_hardware)
    fprintf('  → Moviendo a posición de reposo\n');
    
    % Si estamos en modo hardware, mover el brazo a posición de reposo
    if modo_hardware
        % IMPORTANTE: AQUÍ DEBES USAR TU PROPIA FUNCIÓN PARA MOVER A POSICIÓN DE REPOSO
        % Este es un ejemplo genérico, que deberías reemplazar con tu implementación real
        
        % Reemplaza estas líneas con llamadas a tus propias funciones
        % Por ejemplo:
        mover_articulacion(1, 90);  % Articulación 1
        mover_articulacion(2, 180); % Articulación 2
        mover_articulacion(3, 145); % Articulación 3
        mover_articulacion(4, 35);  % Articulación 4
    else
        fprintf('  → Modo simulación: No se mueve el brazo físico a posición de reposo\n');
    end
end