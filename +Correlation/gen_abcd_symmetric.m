function mat = gen_abcd_symmetric(C)
%     a = c;
    test_func = @(x) x >= 0 && x <= 1;
    b = rand;
    a = -1; c= -1; d = -1;
    cnt = 0;
    while ~ (test_func(a) && test_func(b) && test_func(d))
        b = rand;
        delta = (b*(1+C))^2 - 4* (1-C) * (1+b*(1+C)) * (b*(1-b)*(1+C));
        a1 = (-b*(1+C) + sqrt(delta)) / (2*(1-C) * (1+b*(1+C)));
        a2 = (-b*(1+C) - sqrt(delta)) / (2*(1-C) * (1+b*(1+C)));
        if test_func(a1)
            a = a1;
        end
        if test_func(a2)
            a = a2;
        end
        c = a;
        d = 1 - a - b - c;
        cnt = cnt + 1
    end
    mat = [b a; c d;];
end

