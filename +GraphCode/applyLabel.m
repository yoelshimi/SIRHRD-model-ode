function applyLabel(g)
    % utility function that displays displName for each object in figure.
    ch = g.Children;
    for iter = 1 : numel(ch)
        if ch(iter).Type == "axes"
            ch2 = ch(iter).Children;
            for iter2 = 1 : numel(ch2)
                if ch2(iter2).Type == "line"
                    ch3 = ch2(iter2);
                    text(ch3.XData(end)+0.01, ch3.YData(end), ch3.DisplayName);
                end
            end
        end
    end
    
            
    
end