function [DR_profit, a_power, b_power, idle_power] ...
        = respond_DR_by_batchjobs(P_target, t_dr_events, durationsOfDR, dr_rates, T_schedule, ...
                dc_power,dc_cap, a, BS, A_bj, IDLE_POWER, ON_OFF, IP, PP)
T = T_schedule;
total_BN = size(BS,1); % total number of batch jobs.
peak_power_rate = PP/(PP-IP);

DR_profit = 0;
numberOfDREvents = sum(t_dr_events);
for event = 1:numberOfDREvents
    %% Optimzie the violation frequency            
    cvx_begin 
        variable b(total_BN,T);
        variable P_dc(T);
        variable P_dr(T); 
        maximize(sum(dr_rates'.*P_dr));
        subject to
        b >= 0;
        sum(b,2) == BS;
        sum(A_bj.*b,2) == BS;

        if ON_OFF
            P_dc' == (sum(A_bj.*b, 1) + a')*peak_power_rate;
        else    
            P_dc' == sum(A_bj.*b, 1) + a' + IDLE_POWER;
        end
        P_dc >= 0;
        P_dc <= dc_cap;

        if(P_target>0)
            P_dr == P_dc-dc_power;
            P_dc(durationsOfDR==1)-dc_power(durationsOfDR==1) >= P_target; 
        elseif(P_target<0)
            P_dr == -(P_dc-dc_power);
            P_dc(durationsOfDR==1)-dc_power(durationsOfDR==1) <= P_target; 
        end
    cvx_end   

    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    
    if ON_OFF
        idle_power = (sum(A_bj.*b, 1) + a')*IP/PP;
    else    
        idle_power = IDLE_POWER;
    end
    DR_profit = DR_profit + cvx_solution;
end

%% return results
a_power = a;
b_power = sum(A_bj.*b, 1);
