%% WORK IN PROGRESS MODIFY FOR HPS VEHICLE - CHRISTIAN
function Xdot = state_derivs(u,v,w,p,q,r,Fax,Fay,Faz,Agx,Agy,Agz,Mx,My,Mz,MASS,Ix,Iy,Iz,Ixz,Ixy,Iyz)
    % Rigid Body Equations of Motion, linear and angular accel only
    %
    % Units are flexible but must be consistent, i.e.:
    %      [ft/s, lbs, ft-lbs, slugs, slug-ft^2]   or   [m/s, N, N-m, kg, kg-m^2]
    %                        (angular velocity in rad/sec always)
    %
    %     Body axis coordinates:
    %         x: + forward
    %         y: + to the right
    %         z: + positive down
    %
    % Inputs:
    %    u,v,w: body axis velocity (x,y,z axes) in velocity units.
    %    p,q,r: body axis angular velocity (x,y,z axes) in rad/sec.
    %    Fax,Fay,Faz: applied forces in body axes (x,y,z axes) in force units (gravity not included).
    %    Agx,Agy,Agz: acceleration due to gravity in body axes in acceleration units.
    %    Mx,My,Mz: body axis moment (x,y,z axes) in moment units.
    %    MASS: mass of the vehicle in mass units
    %    Ix,Iy,Iz,Ixz,Ixy,Iyz: moments of inertia in inertia units 
    %         Products of Inertia sign convention
    %         The sign convention used follows Stevens book & Durham's book:
    %              Ib = [[ Ixx, -Ixy, -Ixz],
    %                    [-Ixy,  Iyy, -Iyz],
    %                    [-Ixz, -Iyz, -Izz]]
    %              The products are defined as:  Ixy = sum(dm*x*y)
    %
    % Outputs:
    %    Xdot = [6x1] body axis vector of [udot,vdot,wdot] linear velocity acceleration and [pdot,qdot,rdot] angular velocity acceleration
    %
    coder.inline('always');
   
    % acceleration of linear velocity
    u_dot = Agx + Fax/MASS - q*w + r*v;
    v_dot = Agy + Fay/MASS - r*u + p*w;
    w_dot = Agz + Faz/MASS - p*v + q*u;
    
    % TODO: handle angular momentum
    hx=0;
    hy=0;
    hz=0;

    % Angular Rate Derivatives
    % This is the expanded solution to w_dot_b = Ib^-1 * (Mb - OMGb*Ib*wb) for
    % the full inertia matrix
    %    Eq 2.8 Durham, Aircraft Control Allocation
    %    Eq 1.7-5 Stevens 2016, pg 37 - Note that Stevens inverse inertia matrix (1.7-6) is incorrect as of the 3rd edition
    Ixy = -Ixy; % follow negative convention
    Ixz = -Ixz; % follow negative convention
    Iyz = -Iyz; % follow negative convention
    idetI = 1.0/(Iy*(Ix*Iz-Ixz*Ixz) - Ix*Iyz*Iyz - Iz*Ixy*Ixy  + 2*Ixy*Ixz*Iyz); % reciprocal determinant of inertia matrix

    % intermediate results for  (Mb - OMGb*Ib*wb)
    t_Lres = Mx - q*( Iz*r+Iyz*q+Ixz*p + hz) + r*(Iyz*r+ Iy*q+Ixy*p + hy);
    t_Mres = My + p*( Iz*r+Iyz*q+Ixz*p + hz) - r*(Ixz*r+Ixy*q+ Ix*p + hx);
    t_Nres = Mz - p*(Iyz*r+ Iy*q+Ixy*p + hy) + q*(Ixz*r+Ixy*q+ Ix*p + hx);

    % acceleration of angular velocity
    p_dot = idetI * (  (Iy*Iz - Iyz*Iyz) * t_Lres ...
                     + (Ixz*Iyz-Ixy*Iz)  * t_Mres ...
                     + (Ixy*Iyz-Ixz*Iy)  * t_Nres );
                 
    q_dot = idetI * (  (Ixz*Iyz-Ixy*Iz)  * t_Lres ...
                     + (Ix*Iz - Ixz*Ixz) * t_Mres ...
                     + (Ixy*Ixz-Ix*Iyz)  * t_Nres );

    r_dot = idetI * (  (Ixy*Iyz-Ixz*Iy)  * t_Lres ...
                     + (Ixy*Ixz-Ix*Iyz)  * t_Mres ...
                     + (Ix*Iy - Ixy*Ixy) * t_Nres );
                 
    Xdot = [ u_dot;
             v_dot;
             w_dot;
             p_dot;
             q_dot;
             r_dot ];
end