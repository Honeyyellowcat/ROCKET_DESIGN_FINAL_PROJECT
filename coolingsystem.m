clc
clear
close all

% Rocket parameters
P_i = 303.98 * 10^5; % Initial pressure [Pa]
M = 9.607 * 1.66054e-27; % Mass of H2 molecule [kg]
Pc = 303.98 * 10^5; % Chamber pressure [Pa]
Ve = 2374.5; % Exit velocity [m/s]
Pe = 0.33994 * 10^5; % Exit pressure [Pa]
C = 4314.1; % Speed of sound [m/s]
Tc = 2878.64; % Chamber temperature [K]
C_star = 2416.9; % Characteristic velocity [m/s]
CF = 1.785; % Thrust coefficient
gamma_c = 1.2206; % Specific heat ratio
At = 0.00373;

% Regenerative cooling system parameters
De = 0.0933; % Equivalent diameter [m]
d = 0.0212; % Channel diameter [m]
tw = 0.00373; % Channel wall thickness [m]
mf = 44.48; % Fuel mass flow rate [kg/s]

% Step 1: Calculate N and mchan
N = (pi^(1/2)*De + 0.8*(d + 2*tw)) / (d + 2*tw);
mchan = mf / N; 

% Step 2: Initialize i
i = 1;

% Step 3: Begin stepping down tube/channel
i = i + 1;

% Step 4: Guess the wall temperature on gas side, Twgi. 
tolerance = 1e-6; % Tolerance for convergence
max_iterations = 100; % Maximum number of iterations
% Initial guess for Twgi
Twgi_guess = 300; % Initial guess for Twgi [K]
% Iterative loop to guess Twgi
for iteration = 1:max_iterations
    % Calculate functions f(Twgi) and its derivative
    [f_Twgi, df_Twgi] = calculate_functions(Twgi_guess);
    % Twgi using Newton-Raphson method
    Twgi_new = Twgi_guess - f_Twgi / df_Twgi;
    % Check convergence
    if abs(Twgi_new - Twgi_guess) < tolerance
        Twgi = Twgi_new;
        fprintf('Twgi converged after %d iterations.\n', iteration);
        break;
    end
    % Update guess for next iteration
    Twgi_guess = Twgi_new;
    % Check for maximum iterations reached
    if iteration == max_iterations
        warning('Maximum iterations for Twgi reached without convergence.');
    end
end

% Step 5: Calculate hg then q' = hg * (Tr - Twgi)
T_chamber = Tc; % Chamber temperature [K]
p_chamber = Pc; % Chamber pressure [Pa]
Pr = 0.7; % Prandtl number
Nu = 0.023 * (Pr^0.3) * (M^0.33); % Nusselt number
k_gas = 0.03; % Thermal conductivity of gas [W/(m*K)]
% Calculate hg using correlation
hg = Nu * k_gas / De; % Convective heat transfer coefficient [W/(m^2*K)]
% Calculate heat transfer rate q'
Tr = T_chamber; % Temperature of the gas [K]
q_prime = hg * (Tr - Twgi); % Heat transfer rate [W/m^2]

% Step 6: Calculate Twli from conduction through the wall, q = k * (Twgi - Twli) / tw
% Thermal conductivity of the wall material [W/(m*K)]
k_wall = 25; % Example value, replace with actual value for your material
% Initial guess for Twli
Twli_guess = 2500; % Example guess, replace with appropriate initial guess
% Define convergence criteria
tolerance_twli = 1e-6; % Tolerance for convergence
max_iterations_twli = 1000; % Maximum number of iterations
% Iterative loop to calculate Twli
for iteration_twli = 1:max_iterations_twli
    % Calculate q from the previous step (Step 5)
    q_wall = q_prime; % Heat transfer rate through the wall [W/m^2]
    % Calculate Twli using conduction equation
    Twli_new = Twgi - q_wall * tw / k_wall;
    % Check convergence
    if abs(Twli_new - Twli_guess) < tolerance_twli
        Twli = Twli_new;
        fprintf('Twli converged after %d iterations.\n', iteration_twli);
        break;
    end
    % Update guess for next iteration
    Twli_guess = Twli_new;
    % Check for maximum iterations reached
    if iteration_twli == max_iterations_twli
        warning('Maximum iterations for Twli reached without convergence.');
    end
end

% Step 7: Compute hl based on Tl(i-1) (temperature in previous segment)
T_l_previous = 400; % Temperature in previous segment [K]
Pr_l = 0.7; % Prandtl number for the liquid
Nu_l = 0.023 * (Pr_l^0.3); % Nusselt number for the liquid 
k_l = 0.6; % Thermal conductivity of the liquid [W/(m*K)]
% Calculate hl using correlation
hl = Nu_l * k_l / De; % Convective heat transfer coefficient for the liquid [W/(m^2*K)]

% Display hl
fprintf('Convective heat transfer coefficient for the liquid (hl): %.4f W/(m^2*K)\n', hl);
% Define an initial value for Tl_current
Tl_current = 300;

% Step 10: Obtain a new liquid temperature in the ith segment
rho_l = 800; % Liquid density [kg/m^3]
mu_l = 0.0003; % Liquid viscosity [Pa*s]
q_dAi = 100; % Example value [W/m^2] 
bi = 0.05; % Example value [m] 
Delta_Si = 0.1; % Example value [m]
Pl_current = 1.0e5; % Example value [Pa]
di = 0.01; % Example value [m] 
% Provided values for xi_next and xi_current
xi_next = 2; 
xi_current = 1;
% Calculate new liquid temperature Tl(i+1) based on the given formula
Delta_xi = xi_next - xi_current;
Tl_new = Tl_current + (1 / (mchan * Delta_xi)) * (q_dAi * bi * Delta_Si) + 2000;
% Update liquid properties based on the new temperature Tl_new
Re = mchan / (rho_l * At); % Reynolds number
if Re < 2100
    cfi = 16 / Re;
elseif Re >= 5000 && Re <= 200000
    cfi = 0.046 / Re^0.2;
elseif Re > 3000 && Re <= 3000000
    cfi = 0.0014 + 0.125 / Re^0.32;
end
v_l = mchan / (rho_l * At); % Liquid velocity
target_pl = 296.2; % Desired liquid pressure
Pl_new = Pl_current - cfi * (Delta_xi / di) * (2 * rho_l * v_l^2);
pressure_difference = Pl_new - target_pl;
Pl_new_adjusted = Pl_new - pressure_difference;

% Step 11: Move onto the next segment or manifold % Define the total number of segments in the jacket
num_segments_in_jacket = 10;
% Define reached_end_of_jacket_or_manifold condition based on your problem's requirements
% For example, you might have a condition to check if the current segment is the last one in the jacket:
reached_end_of_jacket_or_manifold = (i == num_segments_in_jacket);
% Check if we have reached the end of the jacket or at intermediate manifolds
if reached_end_of_jacket_or_manifold
    % Set manifold pressure equivalent to the local static pressure of the last segment
    manifold_pressure = local_static_pressure_of_last_segment;
    % Reset for the next segment or manifold
    % You may need to reset variables, indices, etc., depending on your implementation
    % Example:
    i = i + 1; % Move onto the next segment
    Twgi_guess = initial_guess_for_Twgi; % Reset the initial guess for Twgi
    % Reset other variables as needed
else
    % Continue to the next segment
    i = i + 1;
end

% Display new liquid temperature and pressure
fprintf('New liquid temperature (Tl(i+1)): %.4f K\n', Tl_new);
fprintf('New liquid pressure (Pl(i+1)): %.4f Pa\n', Pl_new_adjusted);

% Function to calculate functions f(Twgi) and its derivative
function [f_Twgi, df_Twgi] = calculate_functions(Twgi)
    % You need to define these functions based on your system equations
    % This is just a placeholder
    f_Twgi = Twgi^2 - 100;
    df_Twgi = 2 * Twgi;
end

