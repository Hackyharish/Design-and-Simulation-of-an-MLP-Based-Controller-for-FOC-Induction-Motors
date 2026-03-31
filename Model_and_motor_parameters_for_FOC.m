%% Induction machine parameters

%   Copyright 2023 The MathWorks, Inc.
Pn  = 164e3;     % W, nominal power
Vn  = 550;       % V,  rms phase-to-phase, rated voltage
fn  = 50;        % Hz, rated frequency

Rs  = 0.0139;   % pu, stator resistance
Lls = 0.0672;   % pu, stator leakage inductance
Rr  = 0.0112;   % pu, rotor resistance, referred to the stator side
Llr = 0.0672;   % pu, rotor leakage inductance, referred to the stator side
Lm  = 2.717;    % pu, magnetizing inductance
Lr = Llr+Lm;    % pu, rotor inductance
Ls = Lls+Lm;    % pu, stator inductance

H = 0.2734;  % s, moment of inertia
F = 0.0106;  % pu,friction coefficient
p = 2;       % pole pairs

Vbase = Vn/sqrt(3)*sqrt(2);  % V, base voltage, peak, line-to-neutral
Ibase = Pn/(1.5*Vbase);  % A, base current, peak
Zbase = Vbase/Ibase;     % ohm, base resistance
wbase = 2*pi*fn;         % rad/s, base elec. radial frequency
Tbase = Pn/(wbase/p);    % N*m, base torque

Rss = Rs*Zbase;  % ohm, stator resistance
Xls = Lls*Zbase; % ohm, stator leakage reactance
Rrr = Rr*Zbase;  % ohm, rotor resistance, referred to the stator side
Xlr = Llr*Zbase; % ohm, rotor leakage reactance, referred to the stator side
Xm = Lm*Zbase;   % ohm, magnetizing reactance

%% Transformer parameters
Pt   = 200e3;  % VA,   nominal power
ft   = 60;     % Hz,   nominal frequency
V1   = 460;    % V,    rms line-to-line, primary rated voltage
V2   = 400;    % V,    rms line-to-line, secondary rated voltage
R1pu = 0.01;   % p.u., primary resistance
L1pu = 0.05;   % p.u., primary leakage inductance
R2pu = 0.01;   % p.u., secondary resistance
L2pu = 0.05;   % p.u., secondary leakage inductance
N    = V2/V1;  % turns ratio

wtbase = 2*pi*ft;              % rad/s, base elec. radial frequency
Vt1base = V1/sqrt(3)*sqrt(2);  % primary base voltage
Vt2base = V2/sqrt(3)*sqrt(2);  % secondary base voltage
It1base = Pt/(1.5*Vt1base);    % primary base current
It2base = Pt/(1.5*Vt2base);    % secondary base current
Zt1base = Vt1base / It1base;   % primary base impedance
Zt2base = Vt2base / It2base;   % secondary base impedance

R1 = R1pu * Zt1base;           % ohm, primary resistance
R2 = R2pu * Zt2base;           % ohm, secondary resistance
L1 = L1pu * Zt1base/wtbase;    % H,   primary leakage inductance
L2 = L2pu * Zt2base/wtbase;    % H,   secondary leakage inductance

Req = (R1 + R2*(V1/V2)^2)/Zt1base;  % p.u., equivalent resistance
Leq = (L1 + L2*(V1/V2)^2)/(Zt1base/wtbase);  % p.u., equivalent leakage inductance

%% Control parameters
Ts = 5e-6;        % s, fundamental sample time
fsw = 2e3;        % Hz, switching frequency 
Tsc = 1/(fsw*10); % s, control sample time

% Grid-side PI parameters
Kp_iq = 0.99;
Ki_iq = 20.81;
Kp_id = 0.84;
Ki_id = 17.64;
Kp_vdc = 3.54;
Ki_vdc = 681.12;

% Machine-side PI parameters
Kp_ids = 1.08;
Ki_ids = 207.58;
Kp_imr = 52.22;
Ki_imr = 2790.51;
Kp_iqs = 1.08;
Ki_iqs = 210.02;
Kp_wr = 65.47;
Ki_wr = 3134.24;
