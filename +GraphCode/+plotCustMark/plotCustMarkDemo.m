
% Use hexagons as markers
vertHexX=[-sqrt(3)/2*rHex   0       +sqrt(3)/2*rHex +sqrt(3)/2*rHex     0       -sqrt(3)/2*rHex     -sqrt(3)/2*rHex ] ;
vertHexY=[-rHex/2           -rHex   -rHex/2         +rHex/2             +rHex   +rHex/2             -rHex/2         ] ;
% scale = 0.5
plotCustMark(sort(rand(20,1)*50),rand(20,1)*50,vertHexX,vertHexY,0.5)
axis equal
box on
grid on

% Use crosses as markers
vertHexX=[-0.5 +0.5 +0.5 +1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -1.5 -1.5 -0.5 -0.5] ;
vertHexY=[-3.5 -3.5 -0.5 -0.5 +0.5 +0.5	+1.5 +1.5 +0.5 +0.5 -0.5 -0.5 -3.5] ;
% scale = 0.2
plotCustMark(sort(rand(20,1)*50),rand(20,1)*50,vertHexX,vertHexY,0.2)
axis equal
box on
grid on