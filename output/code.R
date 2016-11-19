
# source("https://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
# install.packages("topicmodels",dependencies = T)
# install.packages("slam")
library(rhdf5)
library(dplyr)
library(topicmodels)
library(e1071)
library(caret)
library(lda)
library(LDAvis)
library(neuralnet)
library(randomForest)
library(nnet)
#set working d to .Rdata
setwd("C:/Users/Administrator/Desktop/proj4/Project4_data")
load("lyr.RData")
#Set wd to training data
setwd("C:/Users/Administrator/Desktop/proj4/Project4_data/data")

FileList = list.files(recursive = T)
nSongs = length(FileList)
index=c(1:2000)
lyr_data= lyr[index,-1]
# lyr_words=as.matrix(lyr[,-1])
# m1=LDA(lyr_words,k=20)
# m1$Dim
# sm1=topics(m1,k=1)
# tm1=terms(m1,k=5000)
# NonEng=(sm1 %in% c(2,7,19,20))
# Pick out non english songs
NonEngInd=c(17,24,100,114,118,121,123,124,125,126,128,136,151,156,163,164,
         195,209,215,216,219,222,226,231,233,236,237,242,254,260,274,281,
         284,291,302,305,307,312,313,314,320,330,335,342,343,344,346,349,
         363,374,379,380,407,408,413,416,429,435,437,440,444,464,465,470,
         482,499,503,505,506,512,515,517,527,531,533,534,553,565,576,577,
         587,594,619,622,624,639,644,649,653,657,659,670,671,679,687,689,
         694,696,705,711,719,730,735,737,742,749,756,761,777,786,799,800,
         806,807,813,820,830,833,841,849,852,853,854,860,866,868,880,891,
         902,910,918,919,921,923,939,961,962,963,964,968,982,990,995,999,
         1013,1016,1024,1029,1035,1041,1049,1051,1053,1062,1066,1069,1086,
         1089,1103,1105,1114,1116,1122,1123,1125,1131,1145,1148,1161,1163,
         1179,1188,1189,1194,1198,1201,1219,1229,1236,1239,1253,1256,1272,
         1274,1275,1283,1285,1291,1295,1297,1298,1307,1321,1327,1329,1330,
         1331,1346,1347,1358,1390,1391,1393,1405,1407,1408,1412,1413,1416,
         1431,1451,1459,1466,1467,1473,1477,1479,1495,1502,1504,1506,1510,
         1522,1534,1535,1539,1541,1553,1554,1556,1557,1559,1576,1577,1580,
         1585,1596,1597,1602,1603,1609,1617,1649,1656,1661,1663,1678,1679,
         1689,1697,1700,1703,1705,1710,1711,1720,1725,1760,1773,1777,1782,
         1790,1793,1818,1830,1831,1842,1861,1867,1871,1877,1880,1881,1888,
         1894,1895,1901,1911,1922,1928,1944,1949,1951,1964,1974,1982,2001,
         2012,2019,2021,2022,2024,2026,2036,2068,2091,2092,2093,2095,2105,
         2111,2118,2128,2137,2138,2159,2168,2176,2177,2180,2193,2198,2200,
         2206,2207,2209,2212,2226,2227,2232,2233,2240,2248,2249,2251,2267,
         2270,2278,2287,2290,2291,2296,2302,2304,2307,2314,2319,2326,2334)
NonEng=rep(F,2350)
NonEng[NonEngInd]=T



MakePeriodogram=function(x){
  len=length(x)
  Span=round(len/10)
  temp=spec.pgram(x,spans=Span,plot=F)
  span2=floor(length(temp$freq)/10)
  ans=temp$freq[span2*(0:9)+round(span2/2)]
  return(ans)
}


MakeMatx=function(x,N_row){matrix(x,nrow=N_row,ncol=length(x),byrow = T)}

Resolve=function(FileName){
  a=h5read(FileName,"analysis")
  Seg_n=length(a$segments_start)
  if ((Seg_n)<40) ans=rep(NA,156) else{
    Seg_Duration=diff(a$segments_start)
    Seg_pitch=apply(a$segments_pitches,2,which.max)
    SPEED=mean(Seg_Duration)
    RYTHM=sd(Seg_Duration)
    TEMPO=length(a$beats_start)/length(a$bars_start)
    MEAN_timbre=apply(a$segments_timbre,1,mean)
    MEAN_Duration=mean(Seg_Duration)
    MEAN_pitch=mean(Seg_pitch)
    MEAN_loud=mean(a$segments_loudness_max)
    SD_timbre=apply(a$segments_timbre,1,sd)
    SD_Duration=sd(Seg_Duration)
    SD_pitch=sd(Seg_pitch)
    SD_loud=sd(a$segments_loudness_max)
    ACF_pitch=acf(Seg_pitch,lag.max = 15,plot=F)$acf 
    ACF_loud=acf(a$segments_loudness_max,lag.max=15,plot=F)$acf 
    ACF_len=acf(Seg_Duration,lag.max=15,plot=F)$acf
    PACF_pitch=pacf(Seg_pitch,lag.max = 15,plot=F)$acf
    PACF_loud=pacf(a$segments_loudness_max,lag.max=15,plot=F)$acf 
    PACF_len=pacf(Seg_Duration,lag.max=15,plot=F)$acf
    PDGM_pitch=MakePeriodogram(Seg_pitch)
    PDGM_loud=MakePeriodogram(a$segments_loudness_max)
    PDGM_len=MakePeriodogram(Seg_Duration)
    ans=c(SPEED,RYTHM,TEMPO,
          MEAN_Duration,MEAN_pitch,MEAN_loud,
          SD_Duration,  SD_loud,   SD_pitch,
          ACF_len,      ACF_loud,  ACF_pitch,
          PACF_len,     PACF_loud, PACF_pitch,
          PDGM_len,     PDGM_loud, PDGM_pitch,
          MEAN_timbre, SD_timbre)
  }
  return(ans)
}


#------read and resolve training data------
x=matrix(0,nrow=2000,ncol=156)
for (i in 1:2000){
  x[i,]=Resolve(FileList[i])
}
indX=(!is.na(x[,1]))&(!NonEng[1:2000])
x0=x[indX,]
x0[x0==Inf]=99
x0[is.na(x0)]=0.1


#------apply pca to response------
pca=prcomp(sqrt(lyr_data[1:2000,]))
y51=(pca$x[indX,1:50])
loading=pca$rotation

#------train neural network------
m4=nnet(x=x0,y=y51,size=20,MaxNWts = 100000,decay=0.1,maxit=50)

#------read  and resolve test data------
setwd("C:/Users/Administrator/Desktop/proj4/TestSongFile100/TestSongFile100")

TestFileList=list.files(recursive = F)
xx=matrix(0,nrow=100,ncol=156)
for (i in 1:100){
  xx[i,]=Resolve(TestFileList[i])
}

# NAXX=is.na(rowMeans(xx))
# xx[NAXX,]=xx[1,] 
#This is for NA data, if there exists no na data, no need to do that

#-------predict pca scores for each testing songs------
y.hat4=predict(m4,xx)


#-------transform back to word freq and generate ranks------
WordProb=y.hat4%*%t(loading[,1:50])
pca_mean=pca$center
Centered=t(t(WordProb)+pca_mean)
WordRank=WordProb
for (i in 1:100){
  WordRank[i,]=rank(-Centered[i,])
}

#-------generate csv output------
#--------------------------------
#         !!!!ATTENTION!!!
# the title of each word (column names) does not align with each column
# This problem exists in the sample submission too
#--------------------------------
colnames(WordRank)=as.character(c(1:5000))
dat2=data.frame(TestFileList,WordRank)
names(dat2)=names(lyr)
write.csv(dat2,file = "outputfinal.csv")

