function [ind] = getLineIndeces(p1,p2)

    if isequal(p1,p2)
        ind(1, 1) = p1(1);
        ind(1, 2) = p1(2);
    else
        m = (p2(1)-p1(1))/(p2(2)-p1(2));
        b = p2(1) - ( m * p2(2) );

        count = 0;
        ind = [];
        minR = min(p1(1), p2(1));
        maxR = max(p1(1), p2(1));
        minC = min(p1(2), p2(2));
        maxC = max(p1(2), p2(2));
        for r=minR:maxR
            count = count + 1;
            ind(count, 1) = r;
            if isinf(m) || m == 0
                ind( count, 2) = p1(2);
            else
                ind( count, 2) = round( (r - b) / m);
            end
        end
        if ~isinf(m)
            for c=minC:maxC
                r = round((m*c) + b);
                tmp = true;
                for i=1:size(ind,1)
                    if isequal( [r,c], ind(i,:))
                        tmp = false;
                    end;
                end
                if tmp
                    count = count + 1;
                    ind(count, 1) = r;
                    ind( count, 2) = c;
                end;
            end
        end;
    end;
end