function [reducedHSI, newWavelengths] = reduceBands(hsiData, targetBands, oriWavelengths)
    [rows, cols, ~] = size(hsiData);
    bandIndices = round(linspace(1, size(hsiData, 3), targetBands + 1));
    reducedHSI = zeros(rows, cols, targetBands);
    newWavelengths = zeros(1, targetBands); % Preallocate array for new wavelengths
    
    for i = 1:targetBands
        bandStart = bandIndices(i);
        bandEnd = bandIndices(i + 1) - 1;
        reducedHSI(:, :, i) = mean(hsiData(:, :, bandStart:bandEnd), 3);
        % Calculate the mean of the original wavelengths for the current band
        newWavelengths(i) = mean(oriWavelengths(bandStart:bandEnd));
    end
end