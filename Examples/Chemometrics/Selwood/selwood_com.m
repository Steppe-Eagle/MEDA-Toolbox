% EDA example with PLS using the EDA Toolbox. See README.txt for more
% details.
% 
%  Data set: 
% 
%    D.L. Selwood, D.J. Livingstone, J.C.W. Comley, A.B. ODowd, A.T. Hudson, 
%       P. Jackson, K.S. Jandu, V.S. Rose, J.N. Stables Structure-Activity 
%       Relationships of Antifiral Antimycin Analogues: A Multivariate 
%       Pattern Recognition Study, Journal of Medical Chemistry 33 (1990) 
%       136142.
%
%   Analysis:
%
%   J. Camacho. Exploratory Data Analysis using latent subspace models.
%       INTECH. ISBN 978-953-51-0438-4. Pages 63 - 90. 2012

% variables
%
% Indices Descriptors
% 1:10 	ATCH1 ATCH2 ATCH3 ATCH4 ATCH5 ATCH6 ATCH7 ATCH8 ATCH9 ATCH10
% 11:20 	DIPV_X DIPV_Y DIPV_Z DIPMOM ESDL1 ESDL2 ESDL3 ESDL4 ESDL5 ESDL6
% 21:30 	ESDL7 ESDL8 ESDL9 ESDL10 NSDL1 NSDL2 NSDL3 NSDL4 NSDL5 NSDL6
% 31:40 	NSDL7 NSDL8 NSDL9 NSDL10 VDWVOL SURF_A MOFI_X MOFI_Y MOFI_Z PEAX_X
% 41:50 	PEAX_Y PEAX_Z MOL_WT S8_1DX S8_1DY S8_1DZ S8_1CX S8_1CY S8_1CZ LOGP
% 51:53 	M_PNT SUM_F SUM_R

%
% codified by: Jos� Camacho P�ez.
% last modification: 02/Feb/15.

%% Inicialization, remember to set the path of the toolbox

load selwood

prep_x = 2; % auto-scale X
prep_y = 2; % auto-scale Y
max_LVs = 20; % maximum number of PCs to take into account

y = x(:,end);
xn = x(:,1:end-1);


%% Step 1: Selection of the LVs

var_pls(xn,y,max_LVs,prep_x,prep_y); % 3 or 6 LVs

cumpress=crossval_pls(xn,y,0:10); % LVs 2 and 3 are not predictive 


%% Step 2: observations distribution and relationships 
%   scores and residuals, outliers detection
%   5 LVs are used for visualization

T = scores_pls(xn,y,1:5,[],prep_x,prep_y,1,Obs); 
% four abnormal observations are found in LV1 (J1(5), J19(3), K18(6), K17(1)) 
% which should be studied with more detail. Also, N31(16) is an outlier in
% LV2 vs LV3, and M6(18) in LV4.

leverage_pls(xn,y,1:5,[],prep_x,prep_y,1); 
% M6(18) is the clearest outlier. 

sqresiduals_pls(xn,y,1:5,[],prep_x,prep_y,1); 
% No high residual are found. 

%% Step 3: investigate differences between observations
%   apply oMEDA to outliers found

dummy=-ones(31,1);
dummy([1,3,5,6])=1;
omeda_pls(xn,y,1,xn,dummy,prep_x,prep_y,3);
% the abnormal observations present a generalized higher magnitude value
% than common observations (in both positive and negative directions)

dummy=-ones(31,1);
dummy(16)=1;
omeda_pls(xn,y,2:3,xn,dummy,prep_x,prep_y,3);
% The deviation of N31(16) is mainly related to an anomalous low value of 
% ATCH8  

dummy=-ones(31,1);
dummy(18)=1;
omeda_pls(xn,y,4,xn,dummy,prep_x,prep_y,3);
% the anomalour residual in M6(18) is related to a generalized low value in
% most of NSDL variables


%% Step 4: variables distribution and relationships  
%   loadings, MEDA and residuals

P = loadings_pls(xn,y,1:5,prep_x,prep_y,1,Vars);
% a main limitation of loading plots is that only two variables are
% assessed at a time. Also, although some correlations are found (e.g ATCH9
% and ATCH10), it is hard to interpret

meda_res = meda_pls(xn,y,1:5,prep_x,prep_y,0.5,3);
% with MEDA, the contribution of the 3 or 6 LVs selected previously can be 
% observed at once. Also, the groups of variables are easily found. There
% are several groups of related variables, which cannot be observed in the
% loading plots, but it is not clear which are the most predictive. Here
% we can use a simple trick (Step 3b): join xn and y in a single block and
% perform PCA and MEDA. 

leverage_pls(xn,y,1:5,[],prep_x,prep_y,2); 
% nothing relevant

sqresiduals_pls(xn,y,1:5,[],prep_x,prep_y,2); 
% several high residuals are found, considering data are auto-scaled (SQ = 30 per 
%   variable)

%% Step 4b: variables distribution and relationships in PCA join xn and y

Vars2 = {Vars{:} '-LOGEC50'};
xaug = [xn y];

SVIplot(xaug,min(max_LVs,rank(xaug)),size(xaug,2),size(xaug,1),prep_x); 
% the SVI plot is useful to determine the number of PCs when a single
% variable is of interest. 2 PCs may be a good choice (low uncertainty of
% alpha parameters while Q2 remains high)

meda_res = meda_pca(xaug,1:2,prep_x,0.5,3);
% it may be useful to combine this plot with the one focused on the column 
% representing -LOGEC50 (variable 54)

[map,ord] = seriation(meda_res); 
plot_vec(map(:,find(ord==54)),num2str(ord')','-LOGEC50',[0.1, -0.1]'*ones(1,size(xaug,2)));
% the limits are chosen to highlight some variables. Combining the two
% plots, we can find groups of related variables in which none of them are
% related to -LOGEC50. These can be discarded afterwards (the reasoning is
% not explained here)




