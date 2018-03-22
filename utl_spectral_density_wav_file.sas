Compute the spectral density of a wav sound file

 Two Solutions
 =============

    1. Python to read wav file and R to produce spectra
    2. SAS proc spectra (uses R conversion of wave file to SAS dataset )

  proc spectra is not part of base WPS
  ERROR: Procedure SPECTRA not known


see
https://stackoverflow.com/questions/49411154/how-can-i-get-a-dataframe-of-frequency-and-time-from-a-wav-file-in-r

INPUT (any wav file)
=====================

  A 0.1 second 440 Hz musical note of A above middle C that
  serves as a general tuning standard for musical pitch.

  signal = np.sin(2 * np.pi * f * samples);

  d:/wav/utl_compute_the_spectral_desity_of_an_arbitray_wav_audio_file.wav


PROCESS (working code)
======================

 1. R to produce spectra (Python was used to create input wav file)

   sndObj = readWave("d:/wav/utl_spectral_density_wav_file.wav");
   s1 <- sndObj@left;
   s1 <- s1 / 2^(sndObj@bit -1);
   timeArray <- (0:(5292-1)) / sndObj@samp.rate;

   * signal, think ocilliscope;
   sinSig<-as.data.frame(cbind(timeArray,s1));

   * Fast fourier transporm;
   FT <- spec.fft(s1, timeArray);
   ftfx<-as.data.frame(cbind(abs(FT$fx),abs(FT$A)));

  * output signal and spectra;
  import r=sinSig data=wrk.utl_spectral_density_wav_sinsig;
  import r=ftfx data=wrk.utl_spectral_density_wav_spectra;

 2. SAS proc spectra (uses R conversion of wave file to SAS dataset

   options ls=255 ps=500;
   proc spectra data=sd1.utl_spectral_density_wav_sinsig(obs=2880) P S adjmean out=spectra coef ;
   Var s1 timearray;
   weight 1;
   run;quit;


OUTPUT
======

*                      ______
__      ___ __  ___   / /  _ \
\ \ /\ / / '_ \/ __| / /| |_) |
 \ V  V /| |_) \__ \/ / |  _ <
  \_/\_/ | .__/|___/_/  |_| \_\
         |_|
;


options ls=64 ps=32;
proc plot data=utl_spectral_density_wav_sinsig(obs=300);
plot s1*timearray='*'/ vref=0;
run;quit;

  Signal (S1)                                                   WORK.UTL_SPECTRAL_DENSITY_WAV_SINSIG obs=5,292

     |                                                             Obs    TIMEARRAY       S1
 1.0 +      ***                 ***                 ***
     |     ** **               ** **               ** **             1    .00000000    0.00000
     |     *   *               *   *               *   *             2    .00001890    0.05222
     |    **   **             **    *              *    *            3    .00003779    0.10428
     |    *     *             *     *             *     *            4    .00005669    0.15607
 0.5 +    *     **            *     **            *     **           5    .00007559    0.20743
     |   *       *           **      *           **      *           6    .00009448    0.25821
     |   *       *           *       *           *       *           7    .00011338    0.30832
     |   *       **          *       **          *       **         ....
     |  *         *         **        *         **        *
 0.0 +--*---------*---------*---------*---------*------------
     |            **        *         **        *
     |             *       **          *       **
     |             *       *           *       *
     |             **      *           **      *
-0.5 +              *     **            *     **
     |              *     *             *     *
     |              **    *             **    *
     |               *   *               *   *
     |               ** **               ** **
-1.0 +                ***                 ***
     ---+---------+---------+---------+---------+---------+--
     0.0000    0.0011    0.0023    0.0034    0.0045    0.0057

                         Time in Seconds


* use the excellent classic "graph" editor to enhace the proc plot;
* I chose not to use vref=440;
options ls=80 ps=32;
proc plot data=utl_spectral_density_wav_spectra(
rename=v2=aaaaaaaaaaaaaaaaaaaaaaaaaa where=(200<v1<800));
plot aaaaaaaaaaaaaaaaaaaaaaaaaa*v1='|';
run;quit;

                                                     WORK.UTL_SPECTRAL_DENSITY_WAV_SPECTRA obs=5,292
 Amplitude
     |                                                       Obs      V1     V2
 0.6 +
     |                                                         1    26460     0
     |                                                         2    26450     0
     |                 0.5 Single spike at 440                 3    26440     0
     |                  |  cycles per second                   4    26430     0
     |                  |                                   ....
     |                  |                                   2690      430      1.419912E-17
 0.4 +                  |                                   2691      440      0.499974915   SPIKE
     |                  |                                   2692      450      3.335793E-23
     |                  |                                   ....
     |                  |                                   5290    26430      6.473502E-23
     |                  |                                   5291    26440      1.4342133E-7
     |                  |                                   5292    26450      2.807506E-18
     |                  |
 0.2 +                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
 0.0 +  ................+......................
     |                 440
     ---+------------+--+---------+------------+--
       200          400          600          800

                  Cycles_per_second

*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

data spectraFix;
  retain cycles_per_sec;
  label s_01=;
  set spectra;
  cycles_per_sec = 52920/period;
run;quit;

options ls=80 ps=32;
proc plot data=utl_spectral_density_wav_spectra(
rename=v2=aaaaaaaaaaaaaaaaaaaaaaaaaa where=(200<v1<800));
plot aaaaaaaaaaaaaaaaaaaaaaaaaa*v1='|';
run;quit;

 Area under spectra is the variance(engineers call it power),
 almost all the variance is at 440 cycles per second

 SAS Spectra
                    440
  150 +              |
      |              |
      |              |
      |              |
      |              |
  100 +              |
      |              |
  AAA |              |
      |              |
      |              |
   50 +              |
      |              |
      |              |
      |              |
      |              |
    0 +  ............+...................
      ---+----+----+----+----+----+----+--
        200  300  400  500  600  700  800

                 CYCLES_PER_SEC




Up to 40 obs from spectraFix total obs=1,441

         CYCLES_
 Obs     PER_SEC       S_01      P_01      COS_01      SIN_01

   1         .        0.000      0.00      0.00000     0.00000
   2       18.38      0.000      0.00      0.00089    -0.00019
   3       36.75      0.000      0.00      0.00089    -0.00038

  23      404.25      0.082      1.03      0.00505    -0.02627
  24      422.63      0.362      4.55      0.01006    -0.05530

  25      441.00    113.706   1428.87     -0.16899     0.98169  ** SPIKE note amplitude of sine **

  26      459.38      0.314      3.95     -0.00843     0.05170
  27      477.75      0.086      1.08     -0.00418     0.02704
  28      496.13      0.040      0.50     -0.00272     0.01852
...

1438    26404.88      0.000     0.00012     0.00000       0.00
1439    26423.25      0.000     0.00012     0.00000       0.00
1440    26441.63      0.000     0.00012     0.00000       0.00
1441    26460.00      0.000     0.00012     0.00000       0.00

*                _                                 __ _ _
 _ __ ___   __ _| | _____  __      ____ ___   __  / _(_) | ___
| '_ ` _ \ / _` | |/ / _ \ \ \ /\ / / _` \ \ / / | |_| | |/ _ \
| | | | | | (_| |   <  __/  \ V  V / (_| |\ V /  |  _| | |  __/
|_| |_| |_|\__,_|_|\_\___|   \_/\_/ \__,_| \_/   |_| |_|_|\___|

;
* create a wav file with a 0.1 second 440Hz signal;
%utl_submit_wps64('
options set=PYTHONHOME "C:\Program Files\Python 3.5\";
options set=PYTHONPATH "C:\Program Files\Python 3.5\lib\";
proc python;
submit;
import numpy as np;
from scipy.io import wavfile;
fs = 52920;
f = 440;
t = .1;
samples = np.linspace(0, t, fs*t, endpoint=False);
signal = np.sin(2 * np.pi * f * samples);
signal *= 32767;
signal = np.int16(signal);
wavfile.write("d:/wav/utl_spectral_density_wav_file.wav", fs, signal);
endsubmit;
run;quit;
');

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;
*____
|  _ \
| |_) |
|  _ <
|_| \_\

;
Proc datasets lib=work kill;
run;quit;

options ls=171 ps=500;
%utl_submit_wps64('
libname sd1 sas7bdat "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(tuneR);
library(spectral);
sndObj = readWave("d:/wav/utl_spectral_density_wav_file.wav");
s1 <- sndObj@left;
s1 <- s1 / 2^(sndObj@bit -1);
timeArray <- (0:(5292-1)) / sndObj@samp.rate;
sinSig<-as.data.frame(cbind(timeArray,s1));
FT <- spec.fft(s1, timeArray);
ftfx<-as.data.frame(cbind(abs(FT$fx),abs(FT$A)));
endsubmit;
import r=sinSig data=wrk.utl_spectral_density_wav_sinsig;
import r=ftfx data=wrk.utl_spectral_density_wav_spectra;
run;quit;
');

options ls=64 ps=32;
proc plot data=utl_spectral_density_wav_sinsig(obs=300);
plot s1*timearray='*'/ vref=0;
run;quit;

  Signal

     |
 1.0 +      ***                 ***                 ***
     |     ** **               ** **               ** **
     |     *   *               *   *               *   *
     |    **   **             **    *              *    *
     |    *     *             *     *             *     *
 0.5 +    *     **            *     **            *     **
     |   *       *           **      *           **      *
     |   *       *           *       *           *       *
     |   *       **          *       **          *       **
     |  *         *         **        *         **        *
 0.0 +--*---------*---------*---------*---------*------------
     |            **        *         **        *
     |             *       **          *       **
     |             *       *           *       *
     |             **      *           **      *
-0.5 +              *     **            *     **
     |              *     *             *     *
     |              **    *             **    *
     |               *   *               *   *
     |               ** **               ** **
-1.0 +                ***                 ***
     ---+---------+---------+---------+---------+---------+--
     0.0000    0.0011    0.0023    0.0034    0.0045    0.0057

                         Time in Seconds


* use the ckassic editor to create output below;
options ls=80 ps=32;
proc plot data=utl_spectral_density_wav_spectra(
rename=v2=aaaaaaaaaaaaaaaaaaaaaaaaaa where=(200<v1<800));
plot aaaaaaaaaaaaaaaaaaaaaaaaaa*v1='|';
run;quit;


 Amplitude
     |
 0.6 +
     |
     |
     |                 0.5 Single spike at 440
     |                  |  cycles per second
     |                  |
     |                  |
 0.4 +                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
 0.2 +                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
     |                  |
 0.0 +  ................+......................
     |                 440
     ---+------------+--+---------+------------+--
       200          400          600          800

                  Cycles_per_second
*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

options ls=255 ps=500;
proc spectra data=sd1.utl_spectral_density_wav_sinsig(obs=2880) P S adjmean out=spectra coef ;
Var s1 timearray;
weight 1;
run;quit;

data spectraFix;
  retain cycles_per_sec;
  label s_01=;
  set spectra;
  cycles_per_sec = 52920/period;
run;quit;

proc print uniform data=spectraFix(keep=cycles_per_sec COS_01 SIN_01 P_01 S_01);
run;quit;

options ls=64 ps=24;
proc plot data=spectraFix(where=(200<cycles_per_sec<800) rename=s_01=aaaaaaaaaaaaaaaaaaaaaaaaaa);
plot aaaaaaaaaaaaaaaaaaaaaaaaaa*cycles_per_sec='|'/haxis=200 to 800 by 100 href=440;
run;quit;

 SAS Spectra

  150 +              |
      |              |
      |              |
      |              |
      |              |
  100 +              |
      |              |
  AAA |              |
      |              |
      |              |
   50 +              |
      |              |
      |              |
      |              |
      |              |
    0 +  |||||||||||||||||||||||||||||||
      ---+----+----+----+----+----+----+--
        200  300  400  500  600  700  800

                 CYCLES_PER_SEC




Up to 40 obs from spectraFix total obs=1,441

         CYCLES_
 Obs     PER_SEC       S_01      P_01      COS_01      SIN_01

   1         .        0.000      0.00      0.00000     0.00000
   2       18.38      0.000      0.00      0.00089    -0.00019
   3       36.75      0.000      0.00      0.00089    -0.00038

  23      404.25      0.082      1.03      0.00505    -0.02627
  24      422.63      0.362      4.55      0.01006    -0.05530

                    Variance                           Sine coef
                    ========                           =========
  25      441.00    113.706   1428.87     -0.16899     0.98169  ** SPIKE NOTE the SIN amplitude **

  26      459.38      0.314      3.95     -0.00843     0.05170
  27      477.75      0.086      1.08     -0.00418     0.02704
  28      496.13      0.040      0.50     -0.00272     0.01852
...

1438    26404.88      0.000     0.00012     0.00000       0.00
1439    26423.25      0.000     0.00012     0.00000       0.00
1440    26441.63      0.000     0.00012     0.00000       0.00
1441    26460.00      0.000     0.00012     0.00000       0.00


