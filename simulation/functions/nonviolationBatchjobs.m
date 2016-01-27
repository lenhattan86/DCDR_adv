function [violationFreq] = nonviolationBatchjobs(pwr_case, pv_cap, irrad_time,...
    pct_load, dc_power, dc_ratio, dc_cap, bjDelay , A_SE, BS, b_flat,  interactive , options, dcBus, numBuses, pvBus, verbose)
    % Todo: Given the ending time for batch jobs
    

    p = 0.5; % need to decide by the ratio of batch job power/total DC power.
    
    tsteps  = length(irrad_time);
    dc_rate = mean(irrad_time/1000*pv_cap)*dc_ratio/mean(dc_power);
    dc_pwr  = dc_power*dc_rate;
    a = interactive*dc_rate;
    bs = BS*dc_rate;
    
    BN = size(BS,1); % total number of batch jobs.
    
    %% Step 1: Get the matrix of violation frequency weights W
    
    % Prepare the matrix of possible loads
    % Select n evenly distributed loads between the bounds of DC
            % Bounds of DC
                
    numLoads = floor(dc_cap/mean(bs));    
    L = numLoads+1;
    
    upperBound = mean(bs)*numLoads;
    lowerBound = 0;
    
    loadIntervals = 0:1:numLoads;
    selectedLoadsForDC = ((upperBound - lowerBound)/numLoads).*loadIntervals + lowerBound;
    
    % prepare for step 2
    Aeq_2 = ones(1,(L)*tsteps); % selected loads list
    A_bj = ones(1,(L)*tsteps); % selected loads list
    for i = 1:tsteps
        Aeq_2((i-1)*(L)+1: (i)*(L)) = selectedLoadsForDC;    
%         A_bj((i-1)*(L)+1: (i)*(L))  = selectedLoadsForDC-a(i);
        A_bj((i-1)*(L)+1: (i)*(L))  = selectedLoadsForDC;
    end
    
    W = zeros(numLoads, tsteps);
    for i = 1:tsteps
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);

        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap; 

        % Set up PV and DC bus loads
        temp_case.bus(pvBus,3) = temp_case.bus(pvBus,3) - pv_pwr;

        maxVoltage = temp_case.bus(1,12);
        minVoltage = temp_case.bus(1,13);

        [results, success] = runpf(temp_case, options);
        if success == 0
            fprintf('Initial onvergence failure: PV_capacity = %d, time = %d\n',...
                pv_cap, i);
            error('Power consumption is too high?');
            break;
        end

        if verbose
            disp('------------------------------------------------------')
            fprintf('Initial From Bus: \n')
            disp(results.branch(:,14))
            fprintf('Initial To Bus: \n')
            disp(results.branch(:,16))
            fprintf('Initial Voltages: \n')
            disp(results.bus(:,8))
            fprintf('Initial Demand: \n')
            disp(results.bus(:,3))
        end        

        violations = zeros(1,length(selectedLoadsForDC));
        previousLoad = 0;
        for idx = 1:length(selectedLoadsForDC)
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) - previousLoad;
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) + selectedLoadsForDC(idx);

            [newResults, success] = runpf(temp_case, options);runopf
            if success == 0
                fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                    pv_cap, i);
                % Set a place holder. This can never be the number of
                % violations, so it is ignored.
                violations(idx) = numBuses + 1;
                previousLoad = selectedLoadsForDC(idx);
                continue;
            end

            if verbose
                disp('------------------------------------------------------')
                fprintf('From Bus: \n')
                disp(newResults.branch(:,14))
                fprintf('To Bus: \n')
                disp(newResults.branch(:,16))
                fprintf('Voltages: \n')
                disp(newResults.bus(:,8))
                fprintf('Demand: \n')
                disp(newResults.bus(:,3))
            end

            violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
            W(idx, i) = length(violatedBuses);
            previousLoad = selectedLoadsForDC(idx);            
        end
    end
    
    %% Step 2: Optimzie the violation frequency    
    
%     W = randn((L), tsteps);
    
    % objective function
    f = reshape(W,(L)*tsteps,1);
    intcon = 1:(L)*tsteps;    
    
    % equality constraints
    load_ones = ones(1,(L));
    Aeq_1 = zeros(tsteps,(L)*tsteps); % select 1 load level each time slot   
    for i=1:tsteps
        Aeq_1(i,(i-1)*(L)+1: (i)*(L)) = load_ones;
    end    
    beq_1 = ones(tsteps,1); 
    
    A_SE_dup = zeros(BN,L*tsteps);
    for l = 1:L
        A_SE_dup(:,l:L:L*tsteps) = A_SE;
    end
    A_bj_dup = zeros(BN,L*tsteps);
    for n=1:BN
        A_bj_dup(n,:) = A_bj;
    end
    Aeq_3 = A_SE_dup.*A_bj_dup;  beq_3 = bs; % maintain the total batch job power
    
    Aeq = vertcat(Aeq_1, Aeq_3);
    beq = vertcat(beq_1, beq_3);
%     Aeq = Aeq_1;
%     beq = beq_1;
    
    % inequality constraints.
    beq_2 = sum(dc_pwr); % maintain the total power.
%     A = Aeq_2;
%     b = beq_2;
    A = [];
    b = [];
    
    lb = zeros((L)*tsteps,1);
    ub = ones((L)*tsteps,1);
    options = optimoptions('intlinprog','Display','final');   
    
    [x,fval,exitflag,output] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,options);    
    %% step 3: return results
    violationFreq = fval/(tsteps*numBuses);
end