date_count = size(pp.px,1);


for i = 1:date_count
    na(i) = sum(isnan(pp.px(i,:)));
end
plot(na(1:100));
plot(na);