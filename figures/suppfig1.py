import numpy as np
import pickle
import pandas as pd
import sklearn.model_selection as md
import matplotlib.pyplot as plt
import os
import seaborn as sb

# Load and separate the dataset
with open('./model_optimisation/balanced_epochs.pickle', 'rb') as handle:
    balanced = pickle.load(handle)
trainset = balanced[balanced['Holdout']==0]
with open('./model_optimisation/gridoptresults_postbugfix.pickle', 'rb') as handle:
    opt = pickle.load(handle)

# Set vars
colour = sb.color_palette("Set2")[0]
plt.rcParams['figure.figsize'] = [8/2.54, 5/2.54]
plt.rcParams.update({'font.size': 8, 
                     'svg.fonttype': 'none'}) #svg defaults to drawing fonts as paths unless you do this?!?!?!!
plt.rcParams['svg.fonttype'] = 'none'
folder = os.path.dirname(os.path.abspath(__file__))
linewidth = 1.2

results = pd.DataFrame.from_dict(opt.cv_results_["params"])
results['score_mean'] = opt.cv_results_["mean_test_score"]
results['score_std'] = opt.cv_results_["std_test_score"]
for parameter in opt.best_params_.keys():
    paramvalues = opt.param_grid[parameter]
    x = range(len(paramvalues))
    y = np.zeros([len(paramvalues)])
    y_std = np.zeros([len(paramvalues)])
    for n, paramvalue in enumerate(paramvalues):
        subset = results[results[parameter]==paramvalue]
        optimal_paramset = subset.loc[subset['score_mean'].idxmax()]
        y[n] = optimal_paramset.score_mean
        y_std[n] = np.std(subset.score_mean)
    plt.figure()
    plt.errorbar(x, y, y_std, capsize=3, marker='o', markersize=5, color=colour)
    plt.ylabel('Mean f-statistic')
    plt.xlabel(parameter)
    plt.xticks(x,[str(p) for p in paramvalues])
    plt.title('Optimal score for different values of {}'.format(parameter))
    plt.tight_layout()
    plt.savefig(folder+'/suppfig1'+parameter+'.svg')
