LIUM
====


A demo on LIUM ILP clustering

LIUM_SpkDiarization is a software dedicated to speaker diarization (ie speaker segmentation and clustering), developed by Laboratoire d'Informatique de l'Université du Maine (LIUM - EA 4023).


-------------------------------------------------------------------------
Homepage:
  http://www-lium.univ-lemans.fr/diarization/doku.php/welcome

Download
  http://www-lium.univ-lemans.fr/diarization/doku.php/download

Related project:
  https://github.com/bbcrd/diarize-jruby


Prerequisites:

  1)glpk for ILP clustering:
  
    sudo apt-get install glpk
    
    or
    
    sudo apt-get install glpk-utils
    
    http://www.gnu.org/software/glpk/
    

  2)UBM and models
    http://www-lium.univ-lemans.fr/diarization/lib/exe/fetch.php/data_ilp.tgz


After download LIUM, UBM and other models, put them in this folder, you should have following file structure, then just  $./go.sh, output segmetns will be in test_out folder 
```
./
|-- LIUM_SpkDiarization-8.4.1.jar
|-- go.sh
|-- ilp_diarization2.sh
|-- LICENSE
|-- README.md
|-- mat
|   |-- wld.efn.xml
|   |-- wld.mahanalobis.mat
|   `-- wld.tv.mat
|-- models
|   |-- gender.gmms
|   |-- s.gmms
|   |-- sms.gmms
|   `-- ubm.gmm
|-- test_out
|-- test_wav
|   `-- t001.wav
`-- ubm
    `-- wld.gmm
```

Details are in ilp_diarization2.sh


Known issues:

1) https://github.com/StevenLOL/LIUM/issues/1  LIUM works fine with JDK 1.7 but has some problem with JDK 1.8

Please check out [this project](https://github.com/ahmetaa/lium-diarization) ,it works with JDK1.8 .

## Update:

### LIUM=Laboratoire d'Informatique de l'Université du MaineLaboratoire d'Informatique de l'Université du Maine



http://www-lium.univ-lemans.fr/


### Speaker diarization
Speaker diarization is one research topic in audio/speech processing. It is refer to unsupervised cluster audio sequences into speaker groups.
