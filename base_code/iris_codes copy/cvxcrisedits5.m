% Baran-Wu Solution
function [G,error] = cvxcrisedits5 (G)

% clear;
% clc;
% G=case57;

% G = case56customv2;

%G.branch=mergelines(G.branch);
% G.branch=sortrows(G.branch,4);


% Ordepring the nodes
% N = size(G.branch)*[1;0];  % N is the number of the links. 
N = size(G.branch, 1);

%G.branch(:,9)=1;
% for i=1:N
%     if G.branch(i,1)>G.branch(i,2)
%         temp=G.branch(i,1);
%         G.branch(i,1)=G.branch(i,2);
%         G.branch(i,2)=temp;
%         if G.branch(i,9)>0
%             G.branch(i,9)=1/G.branch(i,9);
%             G.branch(i,[3 4 5])=G.branch(i,[3 4 5])*(G.branch(i,9)^2);
%         else
%             G.branch(i,9)=1;
%         end
%         %G.branch(i,10)=-G.branch(i,10);
%     end
% end

% n = size(G.bus)*[1;0];  % n is the number of the links.
n = size(G.bus, 1);

% preprocess for correcting the node numbers
% G.branch(:,[1 2])= ordering (G.branch(:, [1 2]), G.bus(:,1));
% G.gen(:,1)= ordering (G.gen(:, 1), G.bus(:,1));
% G.bus(:,1)= 1:n;

r = G.branch (:,3);
%r(r==0)=10^-5;
%r(r==0)=10^-6;
x = G.branch (:,4);
%x(x==0)=10^-6;
% b = G.branch (:,5);


% Simply fill the consumption values by iterating over buses.
% p_c = G.bus(:,3)/100;
% q_c = G.bus(:,4)/100;
p_c = G.bus(:,3);
q_c = G.bus(:,4);

% Create a vector for the shunt cap values
% shunt = G.bus(:,6)/100;
shunt = G.bus(:,6);

% Add the b values to the shunt cap values
%for i=1:N
%    s=find(G.bus(:,1)==G.branch(i,1));
%    t=find(G.bus(:,1)==G.branch(i,2));
%    b=G.branch(i,5);
%    shunt(s) = shunt (s) + b/2;
%    shunt(t) = shunt (t) + b/2;0
%end

% Create a vector for tap ratio
% Tap=G.branch(:,9);
% Tap(Tap==0)=1;

% Voltage limits
u_max = G.bus(:,12).^2;
u_min = G.bus(:,13).^2;
% Generation Limits
q_g_max=zeros(n,1);
q_g_min=zeros(n,1);
p_g_max=zeros(n,1);
p_g_min=zeros(n,1);
for i=1:size(G.gen,1)
%     s=find(G.bus(:,1)==G.gen(i,1));
%     q_g_max(s) = G.gen(i,4)/100;
%     q_g_min(s) = G.gen(i,5)/100;
%     p_g_max(s) = G.gen(i,9)/100;
%     p_g_min(s) = G.gen(i,10)/100;
    q_g_max(i) = G.bus(i,4);
    q_g_min(i) = G.gen(i,5);
    p_g_max(i) = G.gen(i,9);
    p_g_min(i) = G.gen(i,10);
end

% Add bounds to real and reactive power generation at PV buses 
for i=1:size(G.bus,1)
    if G.bus(i,3) < 0
%         p_g_min(i) = G.bus(i,3);
        q_g_max(i) = -1*G.bus(i,3);
        q_g_min(i) = G.bus(i,3);
    end
end


cvx_begin
%      cvx_precision best
%     cvx_solver sdpt3
    
    variables P(N) l(N) Q(N) p_g(n) q_g(n) u(n)

    % loss minimization
    for t = 1:N
        f(t) = r(t)*l(t) ;   
    end
   f=sum(f);
   
   minimize (f)
    subject to

   % Constraints on generation and voltage limits
    for i= 1:n
        u(i)<=u_max(i);
        u(i)>=u_min(i);
        q_g(i)<= q_g_max(i);
        q_g(i)>= q_g_min(i);
        p_g(i)<= p_g_max(i);
        p_g(i)>= p_g_min(i);
        G.bus(45,3)^2 >= p_g(45)^2 + q_g(45)^2;
        G.bus(45,3) >= sqrt((p_g(45))^2 + (q_g(45))^2);
        
%         q_g(45) == sqrt(G.bus(45,3)^2 - (G.bus(45,3)-p_g(45))^2)
    end
    % p_g and q_g relationship
    
% Line Constraints   - apparently non existance in IEEE benchmarks!

    for t=1:N
        i=find(G.bus(:,1)==G.branch(t,1));
        (quad_over_lin( P(t),  u(i) ) + quad_over_lin ( Q(t), u(i) ) )<=l(t);
    end

    
    % real and reactive power balance for each node
    for t=1:n % this is the index, not the node number
       j = G.bus(t,1); % this is the name (node number)
       
       i=find(G.branch(:,2)==j);  % these are the indices of the incoming lines
       k=find(G.branch(:,1)==j);  % these are the indices of the outgoing lines
       
       if sum(k) == 0
            
            sum(P(i)-r(i).*l(i)) == p_c(j) - p_g(j);
            sum(Q(i)-x(i).*l(i)) == q_c(j) - q_g(j) - shunt(j).* u(j);

        elseif sum(i)==0
            
            0 == sum(P(k)) + p_c(j) - p_g(j);
            0 == sum(Q(k)) + q_c(j) - q_g(j) - shunt(j).* u(j);

       else
           
            sum(P(i)-r(i).*l(i)) == sum(P(k)) + p_c(j) - p_g(j);
            sum(Q(i)-x(i).*l(i)) == sum(Q(k)) + q_c(j) - q_g(j) - shunt(j).* u(j);

        end      
       
    end
    
            
    for t=1:N
        i=find(G.bus(:,1)==G.branch(t,1));
        j=find(G.bus(:,1)==G.branch(t,2));
        u(j) == u(i)-2*(r(t)*P(t)+x(t)*Q(t))+(r(t)^2+x(t)^2)*l(t);
    end

cvx_end

G.bus(:,8) = u(:).^(1/2);

error=0;
for t=1:N
    i=find(G.bus(:,1)==G.branch(t,1));
    error = error+ r(t)*((P(t)^2+Q(t)^2)/u(i)-l(t));
    %[r(t)*(P(t)^2+Q(t)^2)/u(i) r(t)*l(t)]
end
error;

% 
% GG=sparse([G.branch(:,1); G.branch(:,2)], [G.branch(:,2); G.branch(:,1)] , [G.branch(:,4); G.branch(:,4)], n, n);
% [ST,pred] = graphminspantree(GG, 'Method', 'Kruskal');
% ST=full(ST);
% ST=(ST+ST')/2;
% 
% % GG2=sparse([G.branch(:,1); G.branch(:,2)], [G.branch(:,2); G.branch(:,1)] , [G.branch(:,4)./G.branch(:,4); G.branch(:,4)./G.branch(:,4)], n, n);
% % [ST2,pred2] = graphminspantree(GG2, 'Method', 'Kruskal');
% % ST2=full(ST2);
% % ST2=(ST2+ST2');
% 
% %ST2 = ST;
% ST (ST~=0) =1;
% 
% costs = graphallshortestpaths(sparse(ST));
% 
% Teta = zeros (N,1);  % Actual angle differences
% 
% A=zeros(n,n); % Incidence Matrix 
% 
% sp = zeros(N,1); % indicates spanning tree links
% 
% counter = 0;
% 
% for t = 1:N
%     i=find(G.bus(:,1)==G.branch(t,1));
%     j=find(G.bus(:,1)==G.branch(t,2));
%     A(t,i)=+1;
%     A(t,j)=-1;
%     if ST(i,j)==0
%         sp(t)=0;
%     else
%         counter=counter+1;
%         sp(t)=1;
%     end
%     Teta(t)= atan( (r(t)*Q(t) - x(t)*P(t)) / (u(i)/(Tap(t)^2)- r(t)*P(t)-x(t)*Q(t)) )  * (180/pi);
% end
% 
% 
% for t1=1:N-1
%     for t2=t1+1:N
%         if (G.branch(t1,1)==G.branch(t2,1)) && (G.branch(t1,2)==G.branch(t2,2) && (sp(t2)==1))
%             sp(t2)=0;
%         end
%     end
% end
% 
% 
% A_reduced= A(sp==1,:);
% temp=zeros(1,n);
% temp(1,1)=1;
% A_reduced=[temp;A_reduced];
% 
% Teta_reduced = Teta(sp==1, :);
% 
% Teta_reduced=[0;Teta_reduced];
% 
% Angles = A_reduced\Teta_reduced;
% 
% %A_aux = B_TP * () ;
% %b_aux = ;
% %phi_aux = ;
% 
% 
% % Recovering the Phase shifter angeles
% 
% Phi = zeros(N,1);
% Phi2 = zeros(N,1);
% 
% for t=1:N
%     i=find(G.bus(:,1)==G.branch(t,1));
%     j=find(G.bus(:,1)==G.branch(t,2));
%     if ST(i,j)==1
%         Phi(t)=0;
%         Phi2(t) = 0;
%     else
%         Phi(t)= Teta(t)-(Angles(i)-Angles(j));     
%         Phi2(t)= (Teta(t)-(Angles(i)-Angles(j)))/(costs(i,j)+1);    
%     end
%     
% end
%    
% PST=[Phi, Phi2, r, x];
% 
% sortrows(PST,1);
% 
% PSTs = sum(abs(Phi)>0.1);
% Phi_min  = min(Phi)
% Phi_max = max(Phi)
% Phi_min2 = min(Phi2);
% Phi_max2 = max(Phi2);
% 
% loss = cvx_optval * 10^4;% / sum(G.bus(:,3)) ;
% 
% 
% display('-----------------------------------------------------');
% 
% % for i=1:N
% %     temp=sp(i);
% %     sp(i)=0;
% %     blah = A(sp'==1,:);
% %     if rank(blah)== n-1
% %         continue;
% %     else
% %         sp(i)=temp;
% %     end
% % end
%     
% % A_reduced= A(sp==1,:);
% %     
% % [B_T,index] = licols(A_reduced');
% % temp=ones(1,n);
% % temp(index)=0;
% % missing = sum(temp.* [1:n]);
% % temp2=find(sp>0);
% % missing2=temp2(missing);
% % sp(missing2)=0;
% 
% % 
% % sp=zeros(1,N);
% % sp(index) = 1;
% 
% A(:,1) = [];
% B_T = A(sp'==1,:);
% B_TP = A(sp'==0,:);
% beta_T = Teta(sp==1);
% beta_TP = Teta(sp==0);
% 
% A_aux = B_TP*inv(B_T);
% b_aux = beta_TP - B_TP * inv (B_T) * beta_T;
% 
% phi_aux = inv(A_aux'*A_aux + eye (size(A_aux'*A_aux))) * A_aux' * b_aux;
% 
% min(phi_aux)
% 
% max(phi_aux)