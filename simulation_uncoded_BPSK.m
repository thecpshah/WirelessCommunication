
clear all
clc
close all

EbNo = 0:1:10;                          % Range of SNR in dB (SNR = EbNo)

EbNo_lin = 10.^(EbNo/10);               % SNR in linear scale

M = 2;                                  % Modulation scheme (M = 2 means BPSK)

m = log2(M);                            % Number of bits per symbol

Es = 1;                                 % Symbol energy (it is always 1 for any type of PSK scheme)

sigma = sqrt(Es ./ (2*m*EbNo_lin));     % Noise standard deviation (To scale the noise accordingly)

Nbits = 1000;                           % Number of information bits

mcErrors = 50;                          % Number of maximum errors

frames = 0;                             % Frame count

randomMessage = 1;

bitError = zeros(size(EbNo));           % Empty vector for Bit error

totalErrors = zeros(size(EbNo));        % Empty vector for Total Error

convergence = false;                    % Flag to stop the simulation

while(~convergence)
    
    frames = frames + 1;                        % Increment frame count
    
    for kk = 1:length(EbNo)                     % Loop through all SNR values
        
        if (randomMessage)
            infoBits = randi([0, 1], 1, Nbits);                 % Random message sequence
        else
            load('infoMessage.mat')                             % Hey there!, would you like to go out for a drink?
        end
        
        infoSymbols = 2 * infoBits - 1;                         % BPSK symbols
        
        noise = randn(size(infoSymbols));                       % AWGN Noise
        
        receivedSymbols = infoSymbols + sigma(kk) * noise;      % Received signal
        
        finalBits = sign(receivedSymbols)/2 + 0.5;              % Final estimated bits
        
        bitError(kk) = length(find(infoBits ~= finalBits));     % Bit error for a given SNR
    end
    
    totalErrors = totalErrors + bitError;                       % Total bit error for all the frame
    
    BER = totalErrors / (length(infoBits) * frames);            % Bit error rate (BER)
    
    if (min(totalErrors) > mcErrors)                            % Stopping criteria
        convergence = true;
        sprintf('Simulation completed. The BER for each SNR is:')
        sprintf('%f\n', BER)
    end
end

theoretical_BER = qfunc(sqrt(2*EbNo_lin));                      % Theoretical BER using Q function

figure
semilogy(EbNo, BER, '*-', 'LineWidth', 2)
hold on
semilogy(EbNo, theoretical_BER, 'o-')
grid
h = legend('Simulation', 'Theoretical', 1);
title('Simulation for uncoded BPSK')
xlabel('Eb/No')
ylabel('BER')







