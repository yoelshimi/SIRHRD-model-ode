randRes         = cell(N_susc,1);
structRes       = randRes;
randInfMat      = zeros(N_cautious, N_susc, Niter1, Niter2,4);
structInfMat    = randInfMat;
randSickMat     = zeros(N_cautious, N_susc, Niter1, Niter2);
structSickMat   =  randSickMat;
RStructMatrix   = zeros(N_cautious,N_susc,3,Niter1,Niter2);
structPopMatrix = zeros(N_cautious,N_susc,Niter1,Niter2,4);
randPopMatrix   = structPopMatrix;
RRandMatrix     = RStructMatrix;

popTypes = ["snb","sb","nsnb","nsb"];

for iter2 = 1:N_cautious
    for iter = 1:N_susc
        %--------notice! iter for susc shoud be iter, not iter2!!---2.7.21-%
        matFile = load("C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\test"+filesep()+...
            "rand res for B "+cautions(iter2)+" S "+suscs(iter)+" susc.mat");
        randRes{iter} = matFile.res;
        randInfMat(iter2, iter,:,:,1) = reshape([matFile.res.inf.sb],Niter1,Niter2);
        randInfMat(iter2, iter,:,:,2) = reshape([matFile.res.inf.snb],Niter1,Niter2);
        randInfMat(iter2, iter,:,:,3) = reshape([matFile.res.inf.nsnb],Niter1,Niter2);
        randInfMat(iter2, iter,:,:,4) = reshape([matFile.res.inf.nsb],Niter1,Niter2);
        randSickMat(iter2, iter,:,:) = reshape(sum(cell2mat(cellfun(@(x)...
            [matFile.res.sick.(x)], fields(matFile.res.sick), 'UniformOutput', false)),1),Niter1,Niter2);
        RRandMatrix(iter2,iter,:,:,:) = cell2mat( struct2cell(matFile.res.R0));
        
        for  ind = 1:4
            structPopMatrix(iter2,iter,:,:,ind) = matFile.res.pop.(popTypes(ind));
        end
        
        matFile = load("C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\test"+filesep()+...
            "agent res for B "+cautions(iter2)+" S "+suscs(iter2)+" susc.mat");
        structRes{iter} = matFile.res;
        structInfMat(iter2, iter,:,:,1) = reshape([matFile.res.inf.sb],Niter1,Niter2);
        structInfMat(iter2, iter,:,:,2) = reshape([matFile.res.inf.snb],Niter1,Niter2);
        structInfMat(iter2, iter,:,:,3) = reshape([matFile.res.inf.nsnb],Niter1,Niter2);
        structInfMat(iter2, iter,:,:,4) = reshape([matFile.res.inf.nsb],Niter1,Niter2);
        structSickMat(iter2, iter,:,:) = reshape(sum(cell2mat(cellfun(@(x)...
            [matFile.res.sick.(x)], fields(matFile.res.sick), 'UniformOutput', false)),1),Niter1,Niter2);
        RStructMatrix(iter2,iter,:,:,:) = cell2mat( struct2cell(matFile.res.R0));;
        
        for  ind = 1:4
            randPopMatrix(iter2,iter,:,:,ind) = matFile.res.pop.(popTypes(ind));
        end
           
    end
end
