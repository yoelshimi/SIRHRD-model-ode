function str = buildUpDirs(n)
    % function that returns n many up dirs.
    str = strjoin(repmat("..", n, 1), filesep());
end