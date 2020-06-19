%%%Underwater Color Image Quality Metric%%%%%%%
function Qualty_Val=UCIQE(I,Coe_Metric)

%%% Trained coefficients are c1=0.4680, c2=0.2745, c3=0.2576.
%% UCIQE=c1*Var_Chr+c2*Con_lum+c3*Aver_Sat
%%%%%%%   Var_chr   is ¦Òc : the standard deviation of chroma
%%%%%%%   Con_lum is conl: the contrast of luminance
%%%%%%%   Aver_Sat  is ¦Ìs : the average of saturation
%%%%%%%   Coe_Metric=[c1, c2, c3]are weighted coefficients.
if nargin==1
    %% According to training result mentioned in the paper:
    %% Obtained coefficients are c1=0.4680, c2=0.2745, c3=0.2576.
    Coe_Metric=[0.4680    0.2745    0.2576];
end
%%%Transform to Lab color space
cform = makecform('srgb2lab');
Img_lab = applycform(I, cform);

Img_lum=double(Img_lab(:,:,1));
Img_lum=Img_lum./255+ eps;

Img_a=double(Img_lab(:,:,2))./255;
Img_b=double(Img_lab(:,:,3))./255;
%%%% Chroma
Img_Chr=sqrt(Img_a(:).^2+Img_b(:).^2);
%%%% Saturation
Img_Sat=Img_Chr./sqrt(Img_Chr.^2+Img_lum(:).^2);

%% Average of saturation
Aver_Sat=mean(Img_Sat);
%% Average of Chroma
Aver_Chr=mean(Img_Chr);
%%% Variance of Chroma
Var_Chr =sqrt(mean((abs(1-(Aver_Chr./Img_Chr).^2))));
%%% Contrast of luminance
Tol=stretchlim(Img_lum);
Con_lum=Tol(2)-Tol(1);
%%% get final quality value
Qualty_Val=Coe_Metric(1)*Var_Chr+Coe_Metric(2)*Con_lum+Coe_Metric(3)*Aver_Sat;