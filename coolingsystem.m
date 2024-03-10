clc
clear
close all

% used lecture 5
% Given parameters
T_c = 2878.64; % Chamber temperature (K)
cf = 0.05; % Friction coefficient
mdot_chan = 45; % Mass flow rate (kg/s)
rho_l = 1000; % Density of the liquid (kg/m^3)
d5 = 0.01; % Diameter of the channel (m)

% Material properties
k_ss = 16.3; % Thermal conductivity of stainless steel (W/(m*K))
Cp_ss = 500; % Specific heat capacity of stainless steel (J/(kg*K))
Cp_H2 = 14300; % Specific heat capacity of hydrogen (J/(kg*K))
Cp_O2 = 920; % Specific heat capacity of oxygen (J/(kg*K))

% Calculating heat transfer coefficients
h_ss = k_ss / d5; % Heat transfer coefficient for stainless steel (W/(m^2*K))
h_H2 = Cp_H2 * mdot_chan; % Heat transfer coefficient for hydrogen (W/(m^2*K))
h_O2 = Cp_O2 * mdot_chan; % Heat transfer coefficient for oxygen (W/(m^2*K))

% Regenerator temperature (K)
T_r = 3000; % Regenerator temperature (K)

% Liquid temperature (K)
T_l = 300; % Liquid temperature (K)

% Calculating pressure drop
delta_p = 32 * cf * (mdot_chan^2 / (rho_l * pi^2 * d5));
disp(['Pressure Drop: ' num2str(delta_p) ' Pa']);

% Calculating wall-gas interface temperature
T_wg_ss = (h_ss * T_r + h_ss * T_l) / (2 * h_ss); % Wall-gas interface temperature for stainless steel
T_wg_H2 = (h_H2 * T_r + h_ss * T_l) / (h_ss + h_H2); % Wall-gas interface temperature for hydrogen
T_wg_O2 = (h_O2 * T_r + h_ss * T_l) / (h_ss + h_O2); % Wall-gas interface temperature for oxygen
disp(['Wall-Gas Interface Temperature for Stainless Steel: ' num2str(T_wg_ss) ' K']);
disp(['Wall-Gas Interface Temperature for Hydrogen: ' num2str(T_wg_H2) ' K']);
disp(['Wall-Gas Interface Temperature for Oxygen: ' num2str(T_wg_O2) ' K']);

% Checking for switch from active to passive cooling
switch_to_passive = T_wg_ss > T_c || T_wg_H2 > T_c || T_wg_O2 > T_c;

if switch_to_passive
    disp('Switch to passive cooling');
else
    disp('Active cooling is sufficient');
end

disp(['Switching Cooling to passive at: ' num2str(switch_to_passive)]);
