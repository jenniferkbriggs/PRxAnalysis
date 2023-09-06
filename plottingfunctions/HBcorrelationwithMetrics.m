% Find HB and SD HB for all patients: 

% Requires you preload the PRx 'out' .mat file: 


for i = 1:10
    try %sometimes the data file overrides the 'out' .mat file
        i_hold = i;
        load(strcat('/data/brain/tmp_jenny/trackclean/PRx_alternativedataset/', out.filename(i).data))
        i = i_hold;
    catch
        i_hold = i;
        load('/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/9.26.2022_Patient.mat')
        load(strcat('/data/brain/tmp_jenny/trackclean/withcbf/', out.filename(i).data))
        i = i_hold;
    end

     if length(icp)~= length(abp)
            ll = length(icpt) - length(abpt);
            if ll > 0
                st = find(icpt == abpt(1));
                if st == 1
                    st = find(icpt == abpt(end));
                    icpt(st+1:end) = [];
                    icpt(st+1:end) = [];
                else
                    icpt(1:st) = [];
                    icp(1:st) = [];
                end
            else
                st = find(abpt == icpt(1));
                if st == 1
                    st = find(abpt == icpt(end));
                    abpt(st+1:end) = [];
                    abp(st+1:end) = [];
                else
                    abpt(1:st) = [];
                    abp(1:st) = [];
                end
            end
        end

    [u, indx] = unique(abpt);
    if length(abp) ~= length(icp)
        abp = interp1(abpt(indx), abp(indx), icpt);
        abpt = icpt;
    end

    if size(icp, 1) > size(icp, 2)
        icp = icp';
    end
    if size(abp, 1)>size(abp, 2)
        abp = abp';
    end

    CPP = abp- icp;

    range(abpt./60)
    tic
    [~, medianHR_all(i), stdHR_all(i)] = ...
        findheartbeat(abp, icp, CPP, abpt);
    toc
end