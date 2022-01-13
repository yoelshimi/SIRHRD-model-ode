
function inds = getTimeInds(dateTime, otherDateTime)
%  function for getting indices where otherDate is within the range 
%  given by dateTime.
    if nargin == 1 
        otherDateTime = dateTime;
    end
    inds = find(otherDateTime >= dateTime(1) & ...
        otherDateTime <= dateTime(end));
end