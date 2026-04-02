%% collect_foc_robust_v4.m
% Captures Ramps, Deceleration (1000->200), and prints live signal data.

modelName = 'Foc_control_of_induction_motor_v1'; 
refSpdPath = [modelName, '/Reference Speed'];
loadTorquePath = [modelName, '/Load Torque/Constant'];
Tsc_val = evalin('base', 'Tsc');

% --- Operating Points for a Robust Model ---
% We include the 1000 -> 200 RPM jump to capture deceleration dynamics.
opPoints = {
    500,  0.0, 3.5;   500,  0.8, 3.5;  % Low speed steady
    1000, 0.2, 4.0;   1000, 1.0, 4.0;  % Mid speed steady
    1500, 0.5, 5.0;   1500, 1.0, 5.0;  % Rated speed
    200,  0.5, 4.0;                    % Low speed recovery
    1000, 0.5, 3.0;                    % Prep for decel
    200,  0.8, 4.5;        
};

X_all = []; Y_all = [];
fprintf('\n%-5s | %-8s | %-8s | %-8s | %-8s | %-8s\n', 'OP', 'RefSpd', 'Avg wr', 'Avg imr', 'Avg Vds', 'Avg Vqs');
fprintf('----------------------------------------------------------------------\n');

for op = 1:size(opPoints,1)
    spd = opPoints{op,1}; trq = opPoints{op,2}; dur = opPoints{op,3};
    
    set_param(refSpdPath, 'Value', num2str(spd));
    set_param(loadTorquePath, 'Value', num2str(trq));
    
    simOut = sim(modelName, 'StopTime', num2str(dur));
    t_u = (0:Tsc_val:dur)';
    
    try
        % Smart extraction
        S_ref = smartGet(simOut, 'Spd_ref');
        I_ref = smartGet(simOut, 'Imag_ref');
        wr    = smartGet(simOut, 'wr');
        imr   = smartGet(simOut, 'imr');
        idseF = smartGet(simOut, 'idseF');
        iqseF = smartGet(simOut, 'iqseF');
        Vds   = smartGet(simOut, 'Vds'); 
        Vqs   = smartGet(simOut, 'Vqs'); 
        
        % Filter out the "Dip" (Skip the first 0.01s of every simulation)
        % We only want the AI to learn the stable part or the smooth ramp.
        valid = (t_u >= 0.01); 
        
        X_op = [resamp(S_ref, t_u), resamp(I_ref, t_u), resamp(wr, t_u), ...
                resamp(imr, t_u), resamp(idseF, t_u), resamp(iqseF, t_u)];
        Y_op = [resamp(Vds, t_u), resamp(Vqs, t_u)];
        
        X_all = [X_all; X_op(valid,:)];
        Y_all = [Y_all; Y_op(valid,:)];
        
        % --- LIVE VALUE PRINTOUT ---
        fprintf('%-5d | %-8.0f | %-8.1f | %-8.2f | %-8.2f | %-8.2f\n', ...
            op, spd, mean(X_op(valid,3)), mean(X_op(valid,4)), mean(Y_op(valid,1)), mean(Y_op(valid,2)));
            
    catch e
        fprintf('Op %d FAILED: %s\n', op, e.message);
    end
end

if ~isempty(X_all)
    X = X_all; Y = Y_all;
    save('foc_dataset_robust.mat','X','Y','Tsc_val', '-v7');
    fprintf('\n[SUCCESS] %d samples saved. Ready for Python.\n', size(X,1));
end

%% --- Support Functions ---
function val = smartGet(simOut, target)
    lo = simOut.logsout; names = lo.getElementNames();
    idx = find(contains(names, target, 'IgnoreCase', true), 1);
    if ~isempty(idx)
        elem = lo.getElement(names{idx});
        while isa(elem, 'Simulink.SimulationData.Dataset'); elem = elem.getElement(1); end
        val = elem.Values; return;
    end
    if strcmpi(target, 'wr') % Check simlog if missing in Simulink
        ts = simOut.simlog_IMDriveSensor.ASM.w.series;
        val = timeseries(ts.values, ts.time); return;
    end
    error('Missing: %s', target);
end

function d = resamp(ts, t_target)
    [ut, ia] = unique(ts.Time, 'stable');
    ud = ts.Data(ia, :);
    if numel(ut) < 2
        d = repmat(double(ud(1,1)), size(t_target));
    else
        d = interp1(double(ut), double(ud(:,1)), t_target, 'linear', 'extrap');
    end
end