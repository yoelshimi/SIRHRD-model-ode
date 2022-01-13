classdef BranchClass
    %Class to encapsulate distribution for Branching process functions.
    %   Detailed explanation goes here
    properties
        type {mustBeMember(type,['','Uniform','Exponential', 'MixedExponential', 'ShiftedExponential']) }
        params
        
        pdf
        cdf
        laplace_pdf
        random
    end
    
    methods
        function obj = BranchClass(type,params)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.type = type;
            if isempty(params)
                obj.type = 'empty';
                return
            end
            switch type
                case 'Uniform'
                    obj.params = params;
                    dist = makedist('Uniform','lower', params.a,'upper',params.b);
                    obj.pdf = @(n) dist.pdf(n,1);
                    obj.random = @(n) dist.random(n,1);
                    obj.laplace_pdf = @(s) (exp(-s*params.a) - exp(-s*params.b))/(s*(params.b - params.a));
                case 'Exponential'
                    obj.params = params;
                    dist = makedist('Exponential','mu',params.lambda);
                    obj.random = @(n) dist.random(n,1);
                    obj.laplace_pdf = @(s) 1/(1 + s/params.lambda);
                case 'ShiftedExponential'
                    % not complete! the PDF and CDF aren't updated.
                    obj.params = params;
                    dist = makedist('Exponential','mu',params.lambda);
                    obj.random = @(n) params.shift + dist.random(n,1);
                    obj.laplace_pdf = @(s) params.shift + 1/(1 + s/params.lambda);
                    
                case 'MixedExponential'
                    %  params is a array of structs each with fields:
                    %  lambda, p.
                    obj.params = params;
                    for iter = 1:length(fields(params))
%                         dist(iter) = makedist('exponential','mu', params(iter).lambda);
                    end

%                     obj.dist.pdf = @(x) dot(arrayfun(@(t) pdf(t,x),dist), [params.p]);
%                     obj.dist.cdf = @(x) dot(arrayfun(@(t) cdf(t,x),dist), [params.p]);
                    obj.random = @(n) randmixexp(params(1).p,params(1).lambda,params(2).lambda,n);
                    %  to_dist(dist,params.lambda,x);
                    obj.laplace_pdf = @(s) sum(arrayfun(@(param) param.p*1/(1+s/param.lambda), params));
            end
        end
        
        function new_obj = copy(obj)
            %copy method
            %   creates new object identical to self and returns it.
            new_obj = BranchClass(obj.type,obj.params);
        end
    end
end

function v= to_dist(d,w,x)
    for j=1:size(d)
        v = v + d(j).pdf(x) * w(j);
    end
end
