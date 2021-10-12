function x = sortDirection(x)
    if x(end) < x(1)
       x = flip(x);
    end
end