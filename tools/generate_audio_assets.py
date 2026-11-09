import os
import math
import wave
import struct

def synthesize_wav(filename, duration, sample_rate, wave_func):
    num_samples = int(duration * sample_rate)
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)  # Mono
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = float(i) / sample_rate
            sample = wave_func(t, duration)
            # Clamp between -1.0 and 1.0
            sample = max(-1.0, min(1.0, sample))
            int_val = int(sample * 32767.0)
            wav.writeframesraw(struct.pack('<h', int_val))

def gen_all():
    os.makedirs('assets/audio', exist_ok=True)
    sr = 44100

    # 1. Correct Answer: Dual bell chime (E5 -> A5 harmonized)
    def correct_wave(t, dur):
        # Two ascending harmonic tones: first at t=0, second at t=0.1
        val = 0.0
        # Tone 1: E5 (659.25 Hz)
        if t >= 0:
            env1 = math.exp(-6.0 * t)
            val += 0.5 * math.sin(2 * math.pi * 659.25 * t) * env1
            val += 0.2 * math.sin(2 * math.pi * 1318.5 * t) * env1
        # Tone 2: A5 (880.0 Hz) - major bright chime
        if t >= 0.09:
            dt = t - 0.09
            env2 = math.exp(-4.5 * dt)
            val += 0.6 * math.sin(2 * math.pi * 880.0 * dt) * env2
            val += 0.25 * math.sin(2 * math.pi * 1760.0 * dt) * env2
            val += 0.1 * math.sin(2 * math.pi * 2640.0 * dt) * env2
        return val * 0.9

    synthesize_wav('assets/audio/correct.wav', 0.65, sr, correct_wave)
    print('Generated assets/audio/correct.wav')

    # 2. Incorrect Answer: Soft low double-tone (warm, not harsh or jarring)
    def incorrect_wave(t, dur):
        val = 0.0
        # Tone 1: 310 Hz
        if t < 0.14:
            env1 = math.exp(-5.0 * t)
            val += 0.45 * math.sin(2 * math.pi * 310.0 * t) * env1
        # Tone 2: 240 Hz
        elif t >= 0.14:
            dt = t - 0.14
            env2 = math.exp(-6.0 * dt)
            val += 0.45 * math.sin(2 * math.pi * 240.0 * dt) * env2
        return val * 0.85

    synthesize_wav('assets/audio/incorrect.wav', 0.45, sr, incorrect_wave)
    print('Generated assets/audio/incorrect.wav')

    # 3. Quiz Complete: Triumphant uplifting harmonic chord
    def complete_wave(t, dur):
        val = 0.0
        notes = [(0.0, 523.25), (0.12, 659.25), (0.24, 783.99), (0.36, 1046.50)]
        for start_t, freq in notes:
            if t >= start_t:
                dt = t - start_t
                env = math.exp(-3.5 * dt)
                val += 0.35 * math.sin(2 * math.pi * freq * dt) * env
                val += 0.15 * math.sin(2 * math.pi * freq * 2 * dt) * env
        return val * 0.9

    synthesize_wav('assets/audio/complete.wav', 1.2, sr, complete_wave)
    print('Generated assets/audio/complete.wav')

    # 4. Achievement: Sparkling celebratory harmonic shimmer
    def achievement_wave(t, dur):
        val = 0.0
        notes = [(0.0, 587.33), (0.1, 739.99), (0.2, 880.0), (0.32, 1174.66)]
        for start_t, freq in notes:
            if t >= start_t:
                dt = t - start_t
                env = math.exp(-4.0 * dt)
                shimmer = 1.0 + 0.1 * math.sin(2 * math.pi * 12.0 * dt)
                val += 0.3 * math.sin(2 * math.pi * freq * dt) * env * shimmer
                val += 0.15 * math.sin(2 * math.pi * freq * 2 * dt) * env
        return val * 0.85

    synthesize_wav('assets/audio/achievement.wav', 1.1, sr, achievement_wave)
    print('Generated assets/audio/achievement.wav')

    # 5. Tactile Click: Subtle clean wooden pop
    def click_wave(t, dur):
        env = math.exp(-60.0 * t)
        freq = 1200.0 * (1.0 - t * 8.0)
        return 0.4 * math.sin(2 * math.pi * max(200.0, freq) * t) * env

    synthesize_wav('assets/audio/click.wav', 0.06, sr, click_wave)
    print('Generated assets/audio/click.wav')

    # 6. Countdown tick
    def tick_wave(t, dur):
        env = math.exp(-45.0 * t)
        return 0.35 * math.sin(2 * math.pi * 850.0 * t) * env

    synthesize_wav('assets/audio/countdown.wav', 0.08, sr, tick_wave)
    print('Generated assets/audio/countdown.wav')

if __name__ == '__main__':
    gen_all()
