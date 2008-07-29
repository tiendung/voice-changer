function [u, v] = UVSplit(p)

max = length(p);
last = 1;
count = 1;
first = find(p(last + 1 : max), 1, 'first') + last;

while (length(first) ~= 0)
    u(count, 1) = last;
    u(count, 2) = first - 1;
    
    last = find(p(first : max) == 0, 1, 'first') + first - 1;
    v(count, 1) = first;
    v(count, 2) = last - 1;

    first = find(p(last + 1 : max), 1, 'first') + last;
    count = count + 1;
end

u(count, 1) = v(count - 1, 2) + 1;
u(count, 2) = max;

%     disp(sprintf('first=%d last=%d',first,last));
