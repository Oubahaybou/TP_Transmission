function b = source(N, p1)
% Rend N bits aléatoires, avec P(1) = p1
    b = double(rand(N, 1) < p1);
end