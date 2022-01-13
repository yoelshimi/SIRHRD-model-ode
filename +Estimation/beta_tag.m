function beta_t = beta_tag(beta, c, s, beta_l)
    % function for calculating updated beta due to S/B correlations.
    % beta_l = [bb bnb nbnb]
    Pb = -c * s + c / 2 + 0.5;
    Pnb = 1-Pb;
    Pb2 = Pb.^2;
    Pnb2 = Pnb.^2;
    bnb_vec = [Pb2; 1-Pb2-Pnb2; Pnb2;];
    
    beta_t = beta * (fliplr(beta_l) * bnb_vec);
end