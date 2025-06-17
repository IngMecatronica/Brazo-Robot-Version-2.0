function angulos_deg = cinematica_inversa(coords, phi, CODO, L1, L2, L3, L4, L5, L6)
    Px = coords(1);
    Py = coords(2);
    Pz = coords(3);

    q1 = atan2(-Px, Py);
    x4 = [-cos(phi)*sin(q1);
           cos(phi)*cos(q1);
           sin(phi)];
    P4 = [Px; Py; Pz];
    Pm = P4 - L6 * x4;

    r = sqrt(Pm(1)^2 + Pm(2)^2) - L3;
    z = Pm(3) - (L1 + L2);
    J = sqrt(r^2 + z^2);

    %cos_q3 = (J^2 - L4^2 - L5^2) / (2 * L4 * L5);
    %if abs(cos_q3) > 1
    %    angulos_deg = [];
    %    return;
    %end

    %sin_q3 = CODO * sqrt(1 - cos_q3^2);
    %q3 = atan2( CODO * sqrt(1 - ((J^2 - L4^2 - L5^2) / (2 * L4 * L5))^2) , (J^2 - L4^2 - L5^2) / (2 * L4 * L5) );
    
    cos_q3 = (J^2 - L4^2 - L5^2) / (2 * L4 * L5);
    if abs(cos_q3) > 1
        angulos_deg = [];
        return;
    end

    sin_q3 = CODO * sqrt(1 - cos_q3^2);
    q3 = atan2(sin_q3, cos_q3);

    alpha = atan2(z, r);
    beta = atan2(L5 * sin_q3, L4 + L5 * cos_q3);
    q2 = alpha - beta;

    q4 = phi - q2 - q3;
    %q4 = - (q2 - q3)+35;
    %q4 = -(q2 - q3);
    %q4 = phi - q2 - q3-35;

    angulos_rad = [q1 q2 q3 q4];
    angulos_deg = rad2deg(angulos_rad);
    angulos_deg(3) = -angulos_deg(3);  % invertir g3

    %alpha = atan2((Pm(3) - (L1 + L2)), ((sqrt(Pm(1)^2 + Pm(2)^2))-L3));
    %beta = atan2((L5 * sin(q3)) , (L4 + L5 * cos(q3)));

    %q2 = alpha + beta;

    %q4 = phi - q2;

    %angulos_rad = [q1 q2 q3 q4];
    %angulos_deg = rad2deg(angulos_rad);
    %angulos_deg(3) = -angulos_deg(3);  % invertir g3
end
