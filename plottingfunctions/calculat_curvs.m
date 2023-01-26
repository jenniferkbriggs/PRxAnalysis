
function [curv_first, common_method, perc_change_all] = calculat_curvs(out)

for i = 1:length(out.quantiles)
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
        curv_first(i) = mean(mean(abs(jac),'omitnan'), 'omitnan');
        curvature(i) =  mean(mean(abs(dethess./normcurv),'omitnan'),'omitnan');
        perc_change_all(i) = mean(mean(perc_change, 'omitnan'), 'omitnan');
        common_method(i) = range([vq(5, 40), vq(10,30), vq(10,40),...
            vq(15,30), vq(6,40)]);
end
end
