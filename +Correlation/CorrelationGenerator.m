function mat = CorrelationGenerator(C, is_symmetric)
    if nargin < 2
        is_symmetric = 1;
    end
    
    test_func = @(x) x >= 0 && x <= 1;
    
    if ~ (test_func(C) || test_func(-C))
        disp("invalid correlation C");
        mat = zeros(2);
        return;
    end
%     a = sb, b = snb, c = nsnb, d = nsb
%     eqn 1: a+b+c+d = 1, 2: ac-bd / ab+bd = C 3: a=c, b=d
    if is_symmetric
        b = -1;
        while ~ test_func(b)
            delta =  -1;
            while delta < 0
                a = rand;
                fake_b = (2 * a - 1 - C * (1 - 2 * a));
                delta = fake_b ^ 2 - 4 * (1-C) * (a^2 * (1 + C));
            end
            b1 = (- fake_b + 2 * sqrt(delta) ) / (1 - C);
            b2 = (- fake_b - 2 * sqrt(delta) ) / (1 - C);
            if test_func(b1)
                b = b1;
            end
            if test_func(b2)
                b = b2;
            end
        end
        mat = [b a; a b;] % d = b, a = c
        return
    else  % non symmetric case
        c = -1; d = -1;
        while ~ (test_func(c) && test_func(d))
            a = rand; b = rand;
            c = (1 - a - b)*(1 + C) / (a * (1-C) + b * (1 + C));
            d = 1 - a - b - c;
        end 
        mat = [b a; c d;];
        return;
    end
end

