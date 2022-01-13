classdef BranchingProccessClass
   properties
      Value {mustBeNumeric}
      Pe_function 
      Pe_function_laplace
      Pib_function
      Pib_function_laplace
      Pl_function      
   end
   methods
      function r = roundOff(obj)
         r = round([obj.Value],2);
      end
      function r = multiplyBy(obj,n)
         r = [obj.Value] * n;
      end
   end
end