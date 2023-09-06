c = [173, 29, 28;
     41, 77, 70;
     160, 82, 108;
     79, 4, 39;
     0, 123, 32]./255;
figure, ct = 1
for i = [10,10, 5, 15, 6; 40, 30, 40, 30, 40]
    PRx= squeeze(PRx_sam(i(1),i(2),:));
    PRx = atanh(PRx);
    CPPbinned = round(squeeze(CPP_final(i(1),i(2), :))./5).*5;
    cppunique = unique(CPPbinned);
    cppunique(isnan(cppunique))=[];
    cppunique = nonzeros(cppunique);
    for jk = 1:length(cppunique)
          PRxplaceholder = (PRx(find(CPPbinned == cppunique(jk))));
          PRxbinned(jk,1:length(PRxplaceholder)) = PRxplaceholder;
    end
    err = std(PRxbinned');
    plot(cppunique, mean(PRxbinned'),'o')
    hold on,% errorbar(cppunique', mean(PRxbinned'), err, 'vertical', 'color',c(ct,:), 'linewidth',3)
    ct = ct+1
    clear PRxbinned
end