function res = mean2(mat)

res = sum(sum(mat)) / (size(mat, 1) * size(mat, 2));

end