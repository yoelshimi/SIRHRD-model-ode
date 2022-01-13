function [x,y,err] = make_error_plot(x_long, y_long, Nvals)
    [x_long,ord] = sort(x_long);
    x = linspace(x_long(1),x_long(end),Nvals);
    y = zeros(Nvals,1);
    err = zeros(2,Nvals);
    for iter = 1:Nvals
        strt = find(x_long>=x(iter),1,"first");
        stp = find(x_long<=x(min(iter+1,Nvals)),1,"last");
        try
            y_data = y_long(ord(strt:stp),:);
        catch
            y_data = y_long(:,ord(strt:stp));
        end
        y(iter) = mean(y_data(:));
        err(1,iter) = std(y_data(y_data>y(iter))); % pos std *2 
        err(2,iter) = std(y_data(y_data<y(iter))); % pos std *2
    end
end