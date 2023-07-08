% NPP Compensation Resistor Determination
% Version 2.1
% Release Notes:
%
% V1.0
% - Basic funtionality to determine compensation resistance.
% - Bridge input voltage is hard-coded in script
%
% V2.0
% - Modified so resistor values are read in from a TAB delimited file, more
% suitable for large batches of gauges.
%
% V2.1
% Compensation branch included in output
%
% V2.2
% Improved funcitionality with varying length input files. Fixed errors.
%% Preamble

clc;
clear all;
close all;

%% Load Assets

load('resval.mat');
Rdata = load('resistor_data.txt');
Vin = 5;

%% Ininitalize output array
RcompVal = zeros(length(Rdata(:,1)),2);

%% Determine Current Bridge Values

[nrows, ~] = size(RcompVal);
for j = 1:nrows
    rp8_2 = Rdata(j,1);
    rp8_6 = Rdata(j,2);
    rp2_4 = Rdata(j,3);
    rp6_5 = Rdata(j,4);

    % Calculate output voltages for a range of compensation resistor values
    for i = 1:length(resval)
        Vb_824(i) = Vin * ((rp2_4 + resval(i)) /(rp8_2 + (rp2_4 + resval(i)))- rp6_5 /(rp8_6 + rp6_5));
        Vb_865(i) = Vin * ((rp6_5 + resval(i)) /(rp8_6 + (rp6_5 + resval(i)))- rp2_4 /(rp8_2 + rp2_4));
    end

    % Find value and index of minimum bridge voltage
    Vb_824_min(j) = min(abs(Vb_824));
    idx1 = find(abs(Vb_824) == Vb_824_min(j));
    Vb_865_min(j) = min(abs(Vb_865));
    idx2 = find(abs(Vb_865) == Vb_865_min(j));
    
    if Vb_824_min(j) < Vb_865_min(j)
        Leg = 824;
        RcompVal(j,1) = resval(idx1);
        idx = idx1;
        Vb_min = Vb_824_min(j);
    else
        Leg = 865;
        RcompVal(j,2) = resval(idx2);
        idx = idx2;
        Vb_min = Vb_865_min(j);
    end

% Present output to user
disp('------')
disp('OUTPUT')
disp('------')
disp(['Input Voltage: ', num2str(Vin), 'V'])
disp(['Suggested Compensation Resistance: ', num2str(resval(idx)), ' Ohms'])
disp(['Compensation on Leg: ', num2str(Leg)])
disp(['Vb: ', num2str(Vb_min*1e3), ' mV'])


% figure()
% plot(resval, Vb2)
% hold on
% plot(resval(idx), Vb2(idx), 'Or')
% xlabel('Compenation Resistance, Ohms')
% ylabel('Bridge voltage, Volts')
    
end