function makeZCorrection(ax)
    % removes colormap anomaly in uppermost row.
    z = ax.Children(end).ZData;
    z(1,:) = z(2, :);
    ax.Children(end).ZData = z;
end