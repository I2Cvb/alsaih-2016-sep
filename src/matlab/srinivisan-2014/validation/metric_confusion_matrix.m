function [ sens, spec, prec, npv, acc, f1s, mcc, gmean, cm ] = metric_confusion_matrix( pred_label, true_label )

    % Compute the confusion matrix
    cm = confusionmat( true_label, pred_label, 'order', [-1 1]);

    % Compute the sensitivity and specificity
    sens = cm(2, 2) / ( cm(2, 2) + cm(2, 1) );
    spec = cm(1, 1) / ( cm(1, 1) + cm(1, 2) );

    % Compute the precision and negative predictive value
    prec = cm(2, 2) / ( cm(2, 2) + cm(1, 2) );
    npv  = cm(1, 1) / ( cm(1, 1) + cm(2, 1) );

    % Compute accuracy
    acc = ( cm(1, 1) + cm(2, 2) ) / sum( cm(:) );

    % Compute the F1 score
    f1s = ( 2 * cm(2, 2) ) / ( 2 * cm(2, 2) + cm(1, 2) + cm(2, 1) );

    % Compute the Matthew correlation coefficient
    mcc = ( cm(1, 1) * cm(2, 2) - cm(1, 2) * cm(2, 1) ) / ( sqrt( ...
        ( cm(2, 2) + cm(1, 2) ) * ...
        ( cm(2, 2) + cm(2, 1) ) * ...
        ( cm(1, 1) + cm(1, 2) ) * ...
        ( cm(1, 1) + cm(2, 1) ) ) );

    % Compute the geometric mean
    gmean = sqrt( sens * spec );

end
