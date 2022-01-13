
num_sims = 150;
num_extra_iter = 1;
rs = zeros(num_sims,num_extra_iter);
rs_actual = zeros(num_sims,num_extra_iter);
tic
new_graph_flag = 1;
for this_sim = 1:num_sims
    for  extra_iter = 1:num_extra_iter
        d = this_sim
        mySEIRonGraph;
        rs(this_sim,extra_iter) = R;
        rs_actual(this_sim,extra_iter) = R_actual;
        new_graph_flag = 0;
        toc;
    end
    new_graph_flag = 1;
end