from sklearn.model_selection import GridSearchCV, StratifiedGroupKFold, LeaveOneGroupOut, cross_val_predict
from sklearn.ensemble import AdaBoostClassifier
from sklearn.preprocessing import StandardScaler
from email.message import EmailMessage
import smtplib, ssl
import numpy as np
import datetime
import pickle

# This script is supposed to be run remotely, as it can take a long time. 
# Try `screen -d -m python hyperparamopt.py -s 'longrun'`

def hyperparamopt_svm():
    # Set parameters of the search
    svm = AdaBoostClassifier()
    this_is_a_test = True
    use_leaveoneout = True
    p_grid = {"n_estimators": [1,10,100,1e3,1e4,1e5,1e6], "learning_rate": [1e-3,1e-2,0.1,1,10,100,1e3]}
    predictornames = ['LogVariance', 'Skew', 'Kurtosis', 'DeltaV',
        'LogHalfHzPwr', 'Lambda', 'Fiterror', 'DeltaLambda', 'DeltaFiterror',
        'DeltaLogPower', 'ThetaLambda', 'ThetaFiterror', 'ThetaLogPower',
        'AlphaLambda', 'AlphaFiterror', 'AlphaLogPower', 'BetaLambda',
        'BetaFiterror', 'BetaLogPower', 'GammaLambda', 'GammaFiterror',
        'GammaLogPower', 'SumDv50', 'SumDv100', 'SumDv200', 'SumDv300',
	'SumDv500', 'HiguchiFD', 'KatzFD', 'Wavelet1', 'Wavelet2', 'Wavelet6']
    responsenames = ['GroupDecision']
    if this_is_a_test:
        p_grid = {"n_estimators": [1,10]}
    starttime = datetime.datetime.now()

    # Load and separate the dataset
    with open('balanced_epochs.pickle', 'rb') as handle:
        balanced = pickle.load(handle)
    trainset = balanced[balanced['Holdout']==0]
    isartefact = trainset[['A','B','C','D','E','F','G']]=="Artefact"
    weights = abs((isartefact.sum(axis=1)-3.5)/3.5) # observation weights
    X = trainset[predictornames].to_numpy() # predictors
    y = np.ravel(trainset[responsenames].to_numpy()) # response
    groups = trainset['ID'].to_numpy() # grouping variables for splits
    scaler = StandardScaler()
    scaler.fit(X)
    X = scaler.transform(X)

    # Set splits
    if use_leaveoneout:
        outer_cv = LeaveOneGroupOut()
    else:
        outer_cv = StratifiedGroupKFold(n_splits=5, shuffle=True).split(X, y=trainset.AgeTypeGroup, groups=groups)

    # Non-nested CV
    # note fit-params due to unfixed sklearn bug: https://github.com/scikit-learn/scikit-learn/issues/7646
    clf = GridSearchCV(estimator=svm, param_grid=p_grid, cv=outer_cv, scoring="f1_weighted", n_jobs=-1)
    clf.fit(X, y, groups=groups, sample_weight=weights)
    
    # Separately 5-fold cross-validate balanced accuracy
    fivefold = [[train, test] for train, test in StratifiedGroupKFold(n_splits=5, shuffle=True, random_state=1).split(X, y=trainset.AgeTypeGroup, groups=groups)]
    crossval = cross_val_predict(clf.best_estimator_, X, y, cv=outer_cv, groups=groups, n_jobs=-1, method='predict_proba')[:,0]
    crossvalpredictions = np.array(['Clean']*len(crossval))
    crossvalpredictions[crossval >= 0.5] = 'Artefact'
    setattr(clf, 'y_pred', crossvalpredictions)
    setattr(clf, 'y_pred_posteriors', crossval)
    setattr(clf, 'y_pred_splits', outer_cv)

    if not this_is_a_test:
        with open('gridoptresults.pickle', 'wb') as handle:
            pickle.dump(clf, handle, protocol=pickle.HIGHEST_PROTOCOL)

    # Send an email notification when done
    msg = EmailMessage()
    msg.set_content("The function {}, which started at {}, has completed. Runtime {}.".format(__name__, starttime, str(datetime.datetime.now()-starttime)))
    msg["Subject"] = "Optimisation complete"
    msg["From"] = "EMAIL1_GOES_HERE"
    msg["To"] = "EMAIL2_GOES_HERE"

    context=ssl.create_default_context()
    with smtplib.SMTP("smtp.outlook.com", port=587) as smtp:
        smtp.starttls(context=context)
        smtp.login(msg["From"], "PASSWORD_GOES_HERE")
        smtp.send_message(msg)

if __name__=="__main__":
    hyperparamopt_svm()
