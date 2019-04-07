function [K,H] = curvature(S)
% [K,H] = CURVATURE(S) computes the gaussian and mean curvatures of the 
%           surface S defined by S = f(x,y), where (x,y) is the
%           rectangular grid on which f is defined.
%
% 
%Example: Define gaussians on a rectangular grid, and find its
%    curvatures:
%
%    f = @(mu1,mu2,s1,s2,x,y) exp(-(x-mu1).^2/(s1.^2)-(y-mu2).^2/(s2.^2));
%    [X,Y] = meshgrid(linspace(-5,5,200));
%    S = f(-2,0,2,2,X,Y) - f(2,0,2,2,X,Y)
%    figure; mesh(S);
%    [K,H] = curvature(S);   
%    figure;mesh(K); title('Gaussian Curvature','FontSize',20);
%    figure;mesh(H); title('Mean Curvature','FontSize',20);
%
%
% =========================================================================
% Copyright (c) 2015, Thomas Atta-Fosu 
% email: txa128@case.edu (Department of Math, Appl. Math & Statistics,
% CWRU)
% All Rights Reserved
% =========================================================================
[fx,fy] = gradient(S);
[fxx,fxy] = gradient(fx);

[~,fyy] = gradient(fy);

K = (fxx.*fyy - fxy.^2)./((1 + fx.^2 + fy.^2).^2);
H = ((1+fx.^2).*fyy + (1+fy.^2).*fxx - 2.*fx.*fy.*fxy)./...
    ((1 + fx.^2 + fy.^2).^(3/2));