import pickle
from matplotlib import pyplot as plt
from sklearn.metrics import confusion_matrix, balanced_accuracy_score, recall_score
import pandas as pd
import numpy as np
import seaborn as sb
import os

plt.rcParams['figure.figsize'] = [5/2.54, 5/2.54]
plt.rcParams.update({'font.size': 8, 
                     'svg.fonttype': 'none'}) #svg defaults to drawing fonts as paths unless you do this?!?!?!!
plt.rcParams['svg.fonttype'] = 'none'
folder = os.path.dirname(os.path.abspath(__file__))
classnames = ['Artefact','Clean']
predictornames = ['LogVariance', 'Skew', 'Kurtosis', 'DeltaV',
    'LogHalfHzPwr', 'Lambda', 'Fiterror', 'MaxSpecDev', 'DeltaLambda', 'DeltaFiterror',
    'DeltaLogPower', 'ThetaLambda', 'ThetaFiterror', 'ThetaLogPower',
    'AlphaLambda', 'AlphaFiterror', 'AlphaLogPower', 'BetaLambda',
    'BetaFiterror', 'BetaLogPower', 'GammaLambda', 'GammaFiterror',
    'GammaLogPower', 'SumDv50', 'SumDv100', 'SumDv200', 'SumDv300',
'SumDv500', 'HiguchiFD', 'KatzFD', 'Wavelet1', 'Wavelet2', 'Wavelet6']
with open('../RFclassifier.pickle', 'rb') as handle:
    clf = pickle.load(handle)

def plot_confusion_matrix(y, y_pred, filename, classnames):
    cm = confusion_matrix(y, y_pred) #stackoverflow.com/questions/71574168
    plt.figure().set_figwidth(5/2.54)
    fig1a = sb.heatmap(cm, fmt='d', annot=True, square=True,
                cmap='gray_r', vmin=0, vmax=0, cbar=False,
                linewidths=0.5, linecolor='k', 
                xticklabels=classnames, yticklabels=classnames)
    plt.xlabel('Predicted Class')
    plt.ylabel('True Class')
    plt.tight_layout() # prevents axis labels hanging off edge
    plt.show()
    fig = fig1a.get_figure()
    fig.savefig(folder+'/'+filename+'.svg')

## HELD-OUT SET
with open('../model_optimisation/balanced_epochs.pickle', 'rb') as handle:
    balanced = pickle.load(handle)
testset = balanced[balanced['Holdout']==1]
y_pred_test = clf.predict(testset[predictornames])
plot_confusion_matrix(testset['GroupDecision'], y_pred_test,'fig4a',classnames)

## PETAL
poppi = pd.read_csv('../poppi_test/petalresults.csv',index_col=False)

inf_rows = poppi.index[np.isinf(poppi[clf.predictornames]).any(1)]
poppi.loc[inf_rows,'LogHalfHzPwr']=100
poppi.loc[poppi['Include']=='y', 'Include'] = 'Clean'
poppi.loc[poppi['Include']=='n', 'Include'] = 'Artefact'

y = poppi['Include']
y_pred = poppi['Decision']
plot_confusion_matrix(y, y_pred,'fig4b',classnames)
print('Sensitivity: {}'.format(recall_score(y, y_pred, pos_label='Artefact')))
print('Specificity: {}'.format(recall_score(y, y_pred, pos_label='Clean')))
print('Balanced Accuracy: {}'.format(balanced_accuracy_score(y, y_pred)))