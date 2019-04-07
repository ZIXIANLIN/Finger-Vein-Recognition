function [H] = meanCurvature(S)
% [H] = CURVATURE(S) computes the mean curvatures of the 
%           surface S defined by S = f(x,y)
[fx,fy] = gradient(S);
[fxx,fxy] = gradient(fx);

[~,fyy] = gradient(fy);

H = (fxx.*fy.^2 - 2.*fxy.*fx.*fy + fyy.*fx.^2)./2.*(fx.^2 + fy.^2).^(3/2);