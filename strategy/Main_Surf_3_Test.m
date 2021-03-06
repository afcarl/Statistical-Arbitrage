clear; clc;
addpath('../filters/');
addpath('../helpers/');
addpath('../pmcmc/');
addpath('../models/');
addpath('../likelihoods/');
addpath('./surf/');
addpath('../coint/deepsearch/');
load('../data/spx.mat');

pp = TruncateData(pp, 5000, 7000);
load('spreads.mat');
nstd_range = 0.2:0.1:3.0;
wsize_range = 5:2:160;
wts = 0;

step = 0;
Z_cumsum = zeros(length(wsize_range),length(nstd_range)); %same range
for i = 1:20:length(spreads)
    Spread = spreads(i);
    [ profits, vols, sharpes, I ] = CrossValidationParallel( pp, Spread, @SimpleTradingStrategy, nstd_range, wts, wsize_range );
    I(:,4)          = sharpes;
    I(:,5)          = profits;
    I(:,6)          = vols;

    I(isnan(I)) = 0;
    A = [I(:,3) I(:,1) I(:,4)];
    W = sortrows(A, 3);

    wsize           = W(end,1);
    nstd            = W(end,2);
    [~, balance_cum]= SimpleTradingStrategy( pp, Spread, 1, length(Spread.px), struct('wsize', wsize, 'wts', wts, 'nstd', nstd), 0 );

    close all;
    figure;
    [X,Y,Z] = Draw_Surf(I, nstd_range, wsize_range);
    drawnow;
    fprintf('id = %i, balance = %f, sharpe = %f, wsize = %f, nstd = %f ', i, balance_cum(end), W(end,3), wsize, nstd);
    SpreadProcessor(Spread);
    Z_cumsum = Z_cumsum + Z;
    step = step+1;
    
    figure;
    surf(X,Y,Z_cumsum/step);
    %Plot_Draw_Surf(X,Y,Z_cumsum/step);
    drawnow;
    
    if(step == 20 || step == 50 || step == 100 || step == 200)
       a = 2; 
    end
end

%id = 1, balance = 18971.869859, sharpe = 1.476030, wsize = 71.000000, nstd = 1.500000 mean = -5.900054, std = 2.572778, rev = 11.058333, mse = 41.425024
ZZ = Plot_Draw_Surf(X,Y,Z);
[px,py] = gradient(ZZ);
figure; quiver(px,py);
quiver(px,py);
set(gca,'XTick', 1:2:length(nstd_range));
set(gca,'XTickLabel', nstd_range(1:2:length(nstd_range)));

set(gca,'YTick', 1:9:length(wsize_range));
set(gca,'YTickLabel', wsize_range(1:9:length(wsize_range)));

