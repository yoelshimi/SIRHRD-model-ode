function [pop, sick, hosp, dead, infectors] = read_sb_output(f)
    fid = fopen(f);
    t = textscan(fid,"%s");
    t = t{1};
    t = t(end-54:end); % our part of the run
    pop.snb = str2double(t{9});
    pop.sb = str2double(t{11});
    pop.nsnb = str2double(t{13});
    pop.nsb = str2double(t{15}(1:end-1));
    sick.snb = str2double(t{19});
    sick.sb = str2double(t{21});
    sick.nsnb = str2double(t{23});
    sick.nsb = str2double(t{25});
    hosp.snb = str2double(t{29});
    hosp.sb = str2double(t{31});
    hosp.nsnb = str2double(t{33});
    hosp.nsb = str2double(t{35});
    dead.snb = str2double(t{39});
    dead.sb = str2double(t{41});
    dead.nsnb = str2double(t{43});
    dead.nsb = str2double(t{45});
    infectors.snb = str2double(t{49});
    infectors.sb = str2double(t{51});
    infectors.nsnb = str2double(t{53});
    infectors.nsb = str2double(t{55}(1:end-1));
    fclose(fid);
end
