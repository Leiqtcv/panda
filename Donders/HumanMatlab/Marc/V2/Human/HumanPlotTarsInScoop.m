HA_xy	= findobj('Tag','XYAxes');
if ~isempty(HA_xy)
    HCurTar = plot(0,0,'xg','markersize',10,'linewidth',2,'linestyle','none','parent',HA_xy);
    Htar	= plot(0,0,...
        'marker','o',...
        'markeredgecolor','g',...
        'markerfacecolor','g',...
        'markersize',15,...
        'linewidth',2,...
        'linestyle','none',...
        'parent',HA_xy);
    [X,Y] = rect2patch([0 0],[10 10]);
    Hwnd1	= patch(X,Y,'y');
    set(Hwnd1,'edgecolor','y','facecolor','none','linewidth',1)
    [X,Y] = rect2patch([0 0],[10 10]-2);
    Hwnd2	= patch(X,Y,'y');
    set(Hwnd2,'edgecolor','y','facecolor','none','linewidth',2)
end