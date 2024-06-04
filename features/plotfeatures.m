function plotfeatures(featurestable, pred1, pred2, response)
    figure; hold on
    tab = featurestable;
    scatter(tab.(pred1)(tab.(response)==1), tab.(pred2)(tab.(response)==1))
    scatter(tab.(pred1)(tab.(response)==0), tab.(pred2)(tab.(response)==0),'x')
    legend({'Response=True','Response=False'})
    xlabel(pred1)
    ylabel(pred2)
    title('Feature comparison')
end