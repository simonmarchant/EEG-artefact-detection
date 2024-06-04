import pickle
from matplotlib import pyplot as plt
from sklearn.metrics import confusion_matrix, balanced_accuracy_score
import sklearn.model_selection as md
import pandas as pd
import numpy as np
import seaborn as sb
import os

# Axis resizing helper function from https://stackoverflow.com/questions/44970010/axes-class-set-explicitly-size-width-height-of-axes-in-given-units
def set_axis_size(w,h, ax=None):
    """ w, h: width, height in cm """
    w = w/2.54
    h = h/2.54
    if not ax: ax=plt.gca()
    l = ax.figure.subplotpars.left
    r = ax.figure.subplotpars.right
    t = ax.figure.subplotpars.top
    b = ax.figure.subplotpars.bottom
    figw = float(w)/(r-l)
    figh = float(h)/(t-b)
    ax.figure.set_size_inches(figw, figh)

# Load and separate the dataset
with open('./model_optimisation/balanced_epochs.pickle', 'rb') as handle:
    balanced = pickle.load(handle)
trainset = balanced[balanced['Holdout']==0]
with open('./model_optimisation/gridoptresults_postbugfix.pickle', 'rb') as handle:
    opt = pickle.load(handle)

# Set variables
colour = sb.color_palette("Set2")[0]
plt.rcParams['figure.figsize'] = [5/2.54, 5/2.54]
plt.rcParams.update({'font.size': 8, 
                     'svg.fonttype': 'none'}) #svg defaults to drawing fonts as paths unless you do this?!?!?!!
plt.rcParams['svg.fonttype'] = 'none'
folder = os.path.dirname(os.path.abspath(__file__))
linewidth = 1.2
isartefact = trainset[['A','B','C','D','E','F','G']]=="Artefact"
trainset['Agreement'] = ((abs(isartefact.sum(axis=1)-3.5))+3.5).astype(int)
classnames = ['Artefact','Clean']
predictornames = ['LogVariance', 'Skew', 'Kurtosis', 'DeltaV',
       'LogHalfHzPwr', 'Lambda', 'Fiterror', 
       'DeltaLambda', 'DeltaFiterror', 'DeltaLogPower', 
       'ThetaLambda', 'ThetaFiterror', 'ThetaLogPower',
       'AlphaLambda', 'AlphaFiterror', 'AlphaLogPower', 
       'BetaLambda', 'BetaFiterror', 'BetaLogPower', 
       'GammaLambda', 'GammaFiterror', 'GammaLogPower', 
       'SumDv50', 'SumDv100', 'SumDv200', 'SumDv300', 'SumDv500']

# # Fig 1a
# cm = confusion_matrix(trainset.GroupDecision, opt.y_pred) #stackoverflow.com/questions/71574168
# plt.figure().set_figwidth(5/2.54)
# fig1a = sb.heatmap(cm, fmt='d', annot=True, square=True,
#             cmap='gray_r', vmin=0, vmax=0, cbar=False,
#             linewidths=0.5, linecolor='k', 
#             xticklabels=classnames, yticklabels=classnames)
# plt.xlabel('Predicted Class')
# plt.ylabel('True Class')
# plt.tight_layout() # prevents axis labels hanging off edge
# plt.show()

# fig = fig1a.get_figure()
# fig.savefig(folder+'/fig3a.svg')

# # Fig 3b
# colname = 'Type'
# types = np.unique(trainset[colname])
# scores = pd.DataFrame()
# scoresmn = np.zeros_like(types)
# scoressd = np.zeros_like(types)
# for n, type in enumerate(types):
#     subset = trainset.loc[trainset[colname]==type]
#     scores[type] = md.cross_val_score(opt.best_estimator_, subset[predictornames], subset.GroupDecision, scoring='balanced_accuracy',
#                             cv=md.StratifiedGroupKFold(n_splits=5, shuffle=True).split(subset, y=subset.AgeTypeGroup, groups=subset.ID))
# scores = pd.melt(scores, value_vars=types)
# fig3b = sb.pointplot(data=scores, x='variable', y='value', color=colour, capsize=0.1, linewidth=linewidth, errwidth=linewidth, scale=linewidth/3,
#              order=['Background','Auditory','Visual','Touch','Pinprick','ControlLance','Heellance'])
# plt.ylabel('Balanced Accuracy')
# plt.xticks(rotation=90)
# plt.xlabel('Stimulus Type')
# plt.ylim((0,1))
# plt.tight_layout()
# set_axis_size(10/2.54, 7/2.54, fig3b)
# plt.show()
# fig = fig3b.get_figure()
# fig.savefig(folder+'/fig3b.svg')

# # Fig 3c
# colname = 'AgeGroup'
# types = np.unique(trainset[colname])
# scores = pd.DataFrame()
# scoresmn = np.zeros_like(types)
# scoressd = np.zeros_like(types)
# for n, type in enumerate(types):
#     subset = trainset.loc[trainset[colname]==type]
#     scores[type] = md.cross_val_score(opt.best_estimator_, subset[predictornames], subset.GroupDecision, scoring='balanced_accuracy',
#                             cv=md.StratifiedGroupKFold(n_splits=5, shuffle=True).split(subset, y=subset.AgeTypeGroup, groups=subset.ID))
# scores = pd.melt(scores, value_vars=types)
# fig3c = sb.pointplot(data=scores, x='variable', y='value', color=colour, capsize=0.1, linewidth=linewidth, errwidth=linewidth, scale=linewidth/3)
# plt.ylabel('Balanced Accuracy')
# plt.xticks(rotation=90)
# plt.xlabel('Age Group')
# plt.ylim((0,1))
# plt.tight_layout()
# set_axis_size(10/2.54, 7/2.54, fig3c)
# plt.show()
# fig = fig3c.get_figure()
# fig.savefig(folder+'/fig3c.svg')

# # Fig 3d
# colname = 'Agreement'
# types = np.unique(trainset[colname])
# scores = pd.DataFrame()
# scoresmn = np.zeros_like(types)
# scoressd = np.zeros_like(types)
# for n, type in enumerate(types):
#     subset = trainset.loc[trainset[colname]==type]
#     scores[type] = md.cross_val_score(opt.best_estimator_, subset[predictornames], subset.GroupDecision, scoring='balanced_accuracy',
#                             cv=md.StratifiedGroupKFold(n_splits=5, shuffle=True).split(subset, y=subset.AgeTypeGroup, groups=subset.ID))
# scores = pd.melt(scores, value_vars=types)
# fig3d = sb.pointplot(data=scores, x='variable', y='value', color=colour, capsize=0.1, linewidth=linewidth, errwidth=linewidth, scale=linewidth/3)
# plt.ylabel('Balanced Accuracy')
# plt.xticks(rotation=90)
# plt.xlabel('Rater Agreement')
# plt.ylim((0,1))
# plt.tight_layout()
# set_axis_size(10/2.54, 7/2.54, fig3d)
# plt.show()
# fig = fig3d.get_figure()
# fig.savefig(folder+'/fig3d.svg')

#Fig 3e
def LOObalacc(resultstable, LOO_col):
    LOO_table = resultstable.drop(columns=[LOO_col])
    y_true = LOO_table.mode(1)
    y_pred = resultstable[LOO_col]
    return balanced_accuracy_score(y_true=='Artefact', y_pred=='Artefact')

raterdecisions = trainset[['A','B','C','D','E','F','G']]
raterdecisions['Classifier'] = opt.y_pred
balaccs = np.zeros(8)
for n, rater in enumerate(['A','B','C','D','E','F','G','Classifier']):
    balaccs[n] = LOObalacc(raterdecisions, rater)

bars = plt.bar(raterdecisions.columns, balaccs, color=colour)
plt.ylabel('Balanced accuracy')
plt.ylim([0.5,1])
plt.xlabel('Rater')
for rect in bars:
    height = rect.get_height()
    plt.text(rect.get_x() + rect.get_width() / 2.0, height, f'{height:.2f}', ha='center', va='bottom')
plt.tight_layout()
set_axis_size(15/2.54, 7/2.54)
plt.savefig(folder+'/fig3e.svg',format='svg')
plt.show()
