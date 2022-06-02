classdef CSimInput
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % ------ GLOBAL params ----%
        
        pH (1,2) double
        pD (1,2) double
        p_susc (1,1) double
        p_cautious (1,1) double
        R (1,1) double = 3
        gamma (1,1) double = 1/10
        gammaH (1,1) double = 1/20
        beta (1,1) double %  = R * gamma
        alpha = 0
        betaList (1,3) double = [0.05 0.15 1]
        corr (1,1) double {mustBeGreaterThanOrEqual(corr,0),...
            mustBeLessThanOrEqual(corr,1)}
        % those initially infected
        pinit (1,1) double {mustBeGreaterThanOrEqual(pinit,0),...
            mustBeLessThanOrEqual(pinit,1)} = 0.01
        
        % ------ ODE params ------- %

        N0 (1,1) double
        tspan (1,2) double = [0 365]
        
        % ----- Simulation Parameters ----- %
        run_file (1,1) string = "basic_run.py"
        sim_duration (1,1) double = 60
        code_path (1,1) string = ...
            "..\python_31_5_21"
        output_filename (1,1) string = "test"
        freq (1,1) double = 24
        nIter (1,1) double = 60
        RGmode (1,1) string = "sb"  
        Fam2Ppl = 3.3
    end
    
    methods
        function [tspan, param, xinit] = getODEParams(obj)
            %function for getting parameters for simulation
            %   returns all the values we define
            tspan = obj.tspan;
            param = [obj.betaList.*obj.beta./obj.N0 ...
                obj.gamma obj.gammaH obj.pH obj.pD];
            mat = Correlation.nonSymCorr(obj.p_susc,...
                obj.p_cautious, obj.corr); 
            x0 = mat([3 1 2 4])*obj.N0;
            xinit = [x0 x0*obj.pinit zeros(1,12)];
        end
        
        function [command, paramStruct] = getAGENTParams(obj)
            %returns parameters of agent-based python simulation.
            %   returns 1. command for cmd, 2. struct with all the fields
            %   nescessary.
            mat = nonSymCorr(obj.p_susc, obj.p_cautious, obj.corr);
            
            f = {"python", filesep(),"n","p","o","b","a","g","f","n_i","b_l","g_h","p_h_l",...
                "p_d_l","sbc_l","rng","s"};
            vals = {obj.code_path, obj.run_file, obj.N0/obj.Fam2Ppl,false,obj.output_filename,...
                obj.beta,obj.alpha,obj.gamma,obj.freq,obj.nIter,obj.betaList,obj.gammaH,...
                obj.pH,mat,obj.RGmode,"True"};
            % builds command in loop
            cmd = "";
            for iter = 1 : length(f)
                cmd = cmd + f{iter}+space+stringify(vals{iter})+space;
            end
            
            if nargout == 2
                % builds struct in loop.
                for iter = 1 : length(f)
                    paramStruct.(f{iter}) = vals{iter};
                end
                paramStruct = cell2struct(f,vals,1);
            end
            
            command = "python" + space+obj.code_path+filesep()+obj.run_file+space+...
                " -n "+obj.N0/3.3+" -p "+false+" -o "+obj.output_filename+" -b "+obj.beta+" -a "+...
                obj.alpha +" -g "+obj.gamma+" -f "+obj.freq+" -n_i "+obj.nIter+...
                " -b_l "+obj.betaList(1)+" "+obj.betaList(2)+" "+obj.betaList(3)+...
                " -g_h "+obj.gammaH + " -p_h_l "+obj.pH(1)+" "+obj.pH(2)+...
                " -p_d_l "+obj.pD(1)+" "+obj.pD(2)+...
                " -sbc_l "+mat(1,1)+space+mat(1,2)+space+mat(2,1)+space + mat(2,2)+...
                " -rng "+obj.RGmode+" -s "+"True"; 
        end

        function obj = CSimInput(varargin)
%             p = inputParser;
%             
%             % ------ GLOBAL params ----%
%             % 1. Required parameters:
%             addRequired(p,'N0',@isnumeric)
%             addRequired(p,'pH',@isnumeric)
%             addRequired(p,'pD',@isnumeric)
%             addRequired(p,'p_susc',@isnumeric)
%             addRequired(p,'p_cautious',@isnumeric)
%             
%             % 2. Optional parameters:
%             addOptional(p,'R',3,@isnumeric)
%             addOptional(p,'gamma',1/10,@isnumeric)
%             addOptional(p,'gammaH',1/20,@isnumeric)
%             addOptional(p,'beta',obj.R * obj.gamma,@isnumeric)
%             addOptional(p,'alpha',0,@isnumeric)
%             addOptional(p,'betaList',[0.05 0.15 1],@isnumeric)
%             addOptional(p,'corr',0.5,@isnumeric)
% 
%             % ------ ODE params ------- %
%             addOptional(p,'tspan', [0 365],@isnumeric)
%         
%             % ----- Simulation Parameters ----- %
%             addOptional(p,'run_file',"")
%             addOptional(p,'sim_duration', 60,@isnumeric)
%             addOptional(p,'code_path',"..\python_31_5_21" ,@isstring)
%             addOptional(p,'output_filename',...
%                 "test",@isstring)
%             addOptional(p,'freq', 24,@isnumeric)
%             addOptional(p,'nIter', 60,@isnumeric)
%             addOptional(p,'RGmode', "sb",@isstring)
%             
%             % --- options and parsing ---%
%             p.KeepUnmatched = false;
%             p.CaseSensitive = true;
            isFieldName = cellfun(...
                @(x) isstring(x) | ischar(x), varargin);
            isFieldName(2:2:end) = 0;
            inputStruct = cell2struct(varargin(~isFieldName)',...
                string(varargin(isFieldName))');
%             p.parse(varargin{:})
%             r = p.Results;
            f = fields(inputStruct);
            r = properties(obj);
            f2obj = cellfun(@(x) find(strcmpi(r, x)), f...
                , 'UniformOutput', false);
            for iter = 1 : length(f)
                thisField = f{iter};
                fieldNameObj = f2obj{iter};
                if isempty(fieldNameObj) == false
                    obj.(r{fieldNameObj}) = inputStruct.(thisField);
                end
            end
            
        end
    end
end

function s = stringify(x)
% aux fun that flattens data.
    if ismatrix(x)
        s = "";
        arrayfun(@(t) s+space+t,x);
    else
        s = x;
    end
        
end

