clear all; close all; clc;
cvx_solver Gurobi;

L = 3;
T = 3;
W = [0 0 1; 0 2 3; 1 3 4]
lambda = [2 4 1];
loadLevels = [0 0 0; 2 2 2; 4 4 4];

cvx_begin
    variable X(L,T) binary;
    variable b(3);
    minimize( sum(sum(W.*X)) );
    subject to
        sum(X)==ones(1,T);
        X >= 0;
        X <= 1;        
        b == 0.5;
        sum(loadLevels.*X) == lambda;
cvx_end