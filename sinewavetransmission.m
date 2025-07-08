% Generate the Sine Wave
fs = 5e6; % Baseband sample rate
f =100e3; % Sine wave frequency 100khz
samplesPerFrame=6000;
t = (0:samplesPerFrame-1)/fs; % Time vector
txWaveform = exp(1j*2*pi*f*t); % Complex sine wave
txWaveform = txWaveform.'; % Transpose to column vector 

% Configuring PlutoSDR for TX and RX

% Transmitter setup
tx = sdrtx('Pluto');
tx.RadioID = 'usb:0'; % Default USB ID for PlutoSDR
tx.CenterFrequency = 2.415e9; % Carrier frequency (2.415 GHz) 
tx.BasebandSampleRate = fs;
tx.Gain = -10; 

% Receiver setup
rx = sdrrx('Pluto');
rx.RadioID = 'usb:0'; % Same device
rx.CenterFrequency = 2.415e9; % Same carrier frequency for loopback % 2.415e9 (previously working)
rx.BasebandSampleRate = fs; % Match sample rate
rx.SamplesPerFrame = samplesPerFrame; % Match transmitter frame size
rx.GainSource = 'Manual'; % Manual gain control
rx.Gain = 0; % Initial RX gain 

% Simultaneous Transmit and Receive
runtime = tic; % TIME starts
i = -1;
while toc(runtime) < 10 % Run for 10 seconds and then stop
    i = i+1;
    % Transmit the sine wave continuously
 transmitRepeat(tx,txWaveform);

    % Receive the signal
    rxData = rx();

    % Real-time plotting of received signal
    figure(1);
    plot((t+i) * 1e3, real(rxData), 'k', 'DisplayName', 'Received Real Part');
    hold on;
    %plot((t+i) * 1e3, imag(rxData), 'r', 'DisplayName', 'Received Imaginary Part');
    hold off;
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title('Received Sine Wave - Time Domain (PlutoSDR)');
    legend;
    grid on;
    axis auto;
    axis tight;
    drawnow;
    pause(0.0001);% Update plot in real-time
end

% Stop and Release Resources
release(tx);
release(rx);

% Frequency domain(frequency plotting)
N = length(rxData);
f_axis = (-fs/2:fs/N:fs/2-fs/N)/1e3; % Frequency axis in kHz
spectrum = fftshift(fft(rxData)/N);
figure(2);
plot(f_axis, abs(spectrum), 'b');
xlabel('Frequency (kHz)');
ylabel('Magnitude');
title('Received Sine Wave - Frequency Domain');
grid on;
