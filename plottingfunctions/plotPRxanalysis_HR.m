% clear all
% close all
% clc

 if 1
    filename = '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/'
    savename = '9.26.2022_Patient.mat'
    addpath('~/Git/UniversalCode/')
else
    filename = '/Volumes/Briggs_2TB/Albers/PRxError/'
    savename='9.01.Patient.mat'
    addpath('~/Documents/GitHub/UniversalCode/')

end
load([filename savename])


%% 
for i = 1:length(out.filename)
    for q = 1:5
        [X,Y,Z] = surfnorm(out.quantiles(i).data(:,2:64,q));
        area_temp =  sqrt((X-mean2(X)).^2+(Y-mean2(Y)).^2+(Z-mean2(Z)).^2)./Z;
        area(i,q) = trapz(trapz(area_temp))
        ran(i,q) = max(max(out.quantiles(i).data(:,2:64,q))) - min(min(out.quantiles(i).data(:,2:64,q)));
        %ran_common(i,q) = range([out.quantiles(i).data(5,40,q), out.quantiles(i).data(15,30,q), out.quantiles(i).data(6,60,q), out.quantiles(i).data(10,30,q)])
        ran_common(i,q) = range([out.quantiles(i).data(15,4,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(4,40,q),...
            out.quantiles(i).data(6,40,q)'])
       ran_common_all(i,:,q) = ([out.quantiles(i).data(15,4,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(4,40,q),...
            out.quantiles(i).data(6,40,q)]')
    end
end

%% 
for i = 1:length(out.filename)
    q  = 3
        %interpolate over surface. 
        [xq, yq] = meshgrid([1:1:65],[1:1:30]);
        [vq] = griddata([1:65],[1:30],squeeze(out.quantiles(i).data(:,:,q)),xq, yq);
        
        %Approximate derivatives. We can do this because we interpolated.
        fx = diff(vq,1,1);
        fy = diff(vq,1,2);
        
        fxx = diff(fx, 1, 1);
        fyy = diff(fy, 1, 2);
        fxy = diff(fx, 1, 2);
        
        %approximate different sizes by dropping first and last values:
        fx = fx(1:end-1, 2:end-1);
        fy = fy(2:end-1, 1:end-1);
        fxx = fxx(:, 2:end-1);
        fyy = fyy(2:end-1, :);
        fxy = fxy(1:end-1, 1:end-1);
        
        %loop over every point in the grid:
        for k = 1:size(fxx,1)
            for j = 1:size(fxx,2)
                hess = [fxx(k,j), fxy(k,j); fxy(k,j), fyy(k,j)]; 
                dethess(k,j) = det(hess);
                normcurv(k,j) = (1+fx(k,j)^2+fy(k,j)^2);
                jac(k,j) = norm([fx(k,j), fy(k,j)]);
                perc_change(k,j) = norm([100*abs(vq(k+1,j)-vq(k,j))/2, 100*abs(vq(k,j+1)-vq(k,j))/2]);
            end
        end
        
        curv_first(i,q) = mean(mean(abs(jac),'omitnan'), 'omitnan');
        curvature(i,q) =  mean(mean(abs(dethess./normcurv),'omitnan'),'omitnan');
        perc_change_all(i,q) = mean(mean(perc_change, 'omitnan'), 'omitnan');
        common_method(i,q) = perc_change(10, 30);
        
    %calculate mean HR
    %data = load(['/data/brain/tmp_jenny/trackclean/withcbf/' out.filename(i).data]);
    %[~,HR(i), stdHR(i)] = findheartbeat(data.abp, data.icp, data.abpt);

end

%% 
for i = 1:length(out.filename)
stdprx(i) = std(out.PRx(i).data(10,30,:),'omitnan')
end

dev =  plottime(out);

%% 
HR = 60./HR;
figure, nexttile, plot(stdHR, curvature(:,3),'o'), title('Curvature STD')
nexttile, plot(HR, curvature(:,3),'o'),
title('Curvature mean'), 
nexttile, plot(stdHR, curv_first(:,3),'o'),  title('Curvature first STD')
nexttile, plot(HR, curv_first(:,3),'o'), 
title('Curve_first mean'), 
nexttile, plot(stdHR, perc_change_all(:,3),'o'), title('perc change STD')
nexttile, plot(HR, perc_change_all(:,3),'o'), title('perc change mean')

[ranked_curv, curvature_sort] = sort(curvature(:,3));
[ranked_curv_first, curv_sort_first] = sort(curv_first(:,3));
[ranked_perc, curv_sort_perc] = sort(perc_change_all(:,3));

%normalize curvature between -1:1:
curvature_norm = (curvature(:,3)-min(curvature(:,3)))/(range(curvature(:,3)))

close all