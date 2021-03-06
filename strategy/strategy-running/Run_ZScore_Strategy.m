%clear;clc;
load('spreads_6575_7306.mat');
load('spx_6575_7306.mat');

addpath('../../helpers/');
addpath('../../coint/deepsearch');
addpath('../../coint/impl');
addpath('..');
load ../../data/spx.mat;
format longg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% LOAD A SPREAD MODULE %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initial_bet  = 10000;
spread_count = length(spreads);
mat 		 = zeros(spread_count , 5 );
%zscore_conf  = struct('sell_open', 2, 'sell_close', 0.75, 'buy_open', -2, 'buy_close', -0.5);
zscore_conf  = struct('sell_open', 1, 'sell_close', -1, 'buy_open', -1, 'buy_close', 1);

%train
for i = 1:spread_count
    fprintf('i = %d\n', i);
	Spread 		= spreads(i);
    T           = ceil((1/3)* length(Spread.px));
	[pl, cum_pro, trds]= SimpleTradingStrategyZScore( pp, Spread, 1, T, zscore_conf, 0, 1, @Strategy_Simulator, initial_bet );
	vol 		= std(pl);
	real_sharpe = (mean(pl)/std(pl))*sqrt(252);
	trades 		= sum(pl ~= 0);

	mat(i,1) 	= cum_pro(end);
	mat(i,2) 	= vol;
	mat(i,3) 	= real_sharpe;
	mat(i,4) 	= trds;
    mat(i,5)    = i;
end

sorted_mat       = Rank_Results( mat, 3, 50);
spreads_ids      = sorted_mat(end-19:end,5)';

mat_t 		 = zeros(length(spreads_ids) , 5 );
fprintf('testing\n');
c = 1;
portfolio_cumsum = zeros(1);
for i = spreads_ids
    fprintf('i = %d\n', i);
	Spread 		= spreads(i);
    T           = ceil((1/3)* length(Spread.px));
	[pl, cum_pro, trds]= SimpleTradingStrategyZScore( pp, Spread, T, length(Spread.px), zscore_conf, 0, 1, @Strategy_Simulator, initial_bet );
	vol 		= std(pl);
	real_sharpe = (mean(pl)/std(pl))*sqrt(252);

	mat_t(c,1) 	= cum_pro(end);
	mat_t(c,2) 	= vol;
	mat_t(c,3) 	= real_sharpe;
	mat_t(c,4) 	= trds;
    mat_t(c,5)  = i;
    mat_t(c,6)  = maxdrawdown(cum_pro);
    portfolio_cumsum = portfolio_cumsum + cum_pro;
    c = c + 1;
end
portfolio_cumsum = portfolio_cumsum / length(spreads_ids);
PerformanceAssessment(portfolio_cumsum, spx, initial_bet);

portfolio_cumsum_z = portfolio_cumsum;

DISP_Selected_Triples( pp, spreads, spreads_ids, mat, mat_t );