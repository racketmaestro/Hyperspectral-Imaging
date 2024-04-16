function [preprocessedHSI, newWavelengths, testProc1, finalProc] = preprocessHSIData(hsiData, wavelengths)
    % Move hyperspectral data to GPU
    hsiData = gpuArray(hsiData);

    % Estimate and Filter Noise Using HySIME
    [rows, cols, bands] = size(hsiData);
    hsi2D = reshape(hsiData, rows*cols, bands)';  % Each column is a pixel
    [n, Rn] = est_noise(hsi2D);  % Use the GPU version of est_noise
    disp(size(n));
    disp(size(hsi2D));

    % Estimate the signal subspace dimension and corresponding eigenvectors
    [kf, Ek] = estimateAndFilterNoiseHySIME(hsi2D, n, Rn);  % Adjusted for GPU usage
    
    % Project the hyperspectral data onto the signal subspace to denoise
    denoisedHSI2D = Ek * (Ek' * hsi2D);
    
    % Reshape denoised HSI back to original cube dimensions
    preprocessedHSI = reshape(denoisedHSI2D', rows, cols, bands);
    preprocessedHSI = gather(preprocessedHSI);  % Convert back to CPU array for further processing
    testProc1 = preprocessedHSI(50,50,:);
    %preprocessedHSI = denoiseNGMeet(preprocessedHSI);
    %testProc2 = preprocessedHSI(50,50,:);
    % Remove Extreme Noise Bands

    filteredBandsData = preprocessedHSI(:, :, 51:750);
    newWavelengths = wavelengths(51:750);
    
    % Spectral Band Reduction through Averaging for Redundancy Reduction
    targetBands = 129;
    [preprocessedHSI, newWavelengths] = reduceBands(filteredBandsData, targetBands, newWavelengths);
    
    % Normalization of the HS Cube
    preprocessedHSI = normalizeHSI(preprocessedHSI);
    finalProc = preprocessedHSI(50,50,:);
end