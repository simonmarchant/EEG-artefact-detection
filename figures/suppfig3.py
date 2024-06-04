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
colour = sb.color_palette("Set2")[:2]
plt.rcParams['figure.figsize'] = [18/2.54, 12/2.54]
plt.rcParams.update({'font.size': 8, 
                     'svg.fonttype': 'none'}) #svg defaults to drawing fonts as paths unless you do this?!?!?!!
plt.rcParams['svg.fonttype'] = 'none'
folder = os.path.dirname(os.path.abspath(__file__))
linewidth = 1.2
predictornames = ['LogVariance', 'Skew', 'Kurtosis', 'DeltaV',
    'LogHalfHzPwr', 'Lambda', 'Fiterror', 'DeltaLambda', 'DeltaFiterror',
    'DeltaLogPower', 'ThetaLambda', 'ThetaFiterror', 'ThetaLogPower',
    'AlphaLambda', 'AlphaFiterror', 'AlphaLogPower', 'BetaLambda',
    'BetaFiterror', 'BetaLogPower', 'GammaLambda', 'GammaFiterror',
    'GammaLogPower', 'SumDv50', 'SumDv100', 'SumDv200', 'SumDv300',
'SumDv500', 'HiguchiFD', 'KatzFD', 'Wavelet1', 'Wavelet2', 'Wavelet6']

# Plot
isartefact = trainset[['A','B','C','D','E','F','G']]=="Artefact"
numratingartefact = (isartefact.sum(axis=1)).astype(int)
X = trainset[predictornames] # predictors
posteriors = md.cross_val_predict(opt.best_estimator_, X, np.ravel(trainset['GroupDecision'].to_numpy()), 
            cv=md.LeaveOneGroupOut(), groups=trainset['ID'].to_numpy(), 
            n_jobs=-1, method='predict_proba')[:,0]
posterior_means = np.zeros(8)
posterior_stds = np.zeros(8)
for n in range(8):
    posterior_means[n] = np.mean(posteriors[numratingartefact==n])
    posterior_stds[n] = np.std(posteriors[numratingartefact==n])
plt.scatter(numratingartefact, posteriors, label='Individual', color=colour[0])
plt.errorbar(range(8),posterior_means, yerr=posterior_stds, fmt='C1D', label='Group mean & 1SD', color=colour[1])
plt.ylabel('Posterior')
plt.xlabel('Number of raters rating artefact')
plt.tight_layout()
plt.savefig(folder+'/suppfig3.svg')