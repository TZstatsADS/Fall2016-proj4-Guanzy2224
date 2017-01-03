# ADS-Project-4 Lyrics Recommender

## Description
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

In short:Given some music audio features of a song, this project generate a "machine" that provides lyrics recommendations.

Term: Fall 2016

+ Name: Guanzhong You
+ Uni : gy2224

## Idea

### 1.1 Process audio features
As could be easily read from the r code in this repo, I chose several time sequence statistics and music pattern statistics as features(X's). Each song has 156 dimensions of X's. They include: pitchs, loudness, segment length, periodogram of pitchs, loudness, segment length, acf/pacf of pitchs, loudness, segment length, and so on.

I did this with hope that these features can capture the emotional style pattern of songs, whereby we can further infer the possible lyrics.

Now let's see how these features work:

#### 1. Timbre 

When I cooperated with Adam Gaoo, we discovered that timbre feature can be very useful in distinguishing topics of each songs (the topic tags of each song is from LDA topic modelling). These features are also kept alghough we abandoned topicmodelling.

![image](https://raw.githubusercontent.com/Guanzy2224/ADS-Project-4/master/doc/MDS%20of%20timbre%20feature.png)

#### 2. Time series

For time series related features, it is hard to compare the time series directly without any feature extraction since the lenth of each song is different and the meaning of each time point in each song is not identical and hardly compariable. Therefore I came up with the idea to compare the pattern of each time series. To measure the pattern, I chose ACF, PACF and Periodogram. First let's see the raw data of time series (take loudness as example):

![image](https://raw.githubusercontent.com/TZstatsADS/Fall2016-proj4-Guanzy2224/master/doc/Loudness%20Time%20Series.png)
**Loudness_Max of 9 Songs**

From the comparison of the 9 songs' loudness series, it is appearantly that there are many different patterns. Some song has a jump, some songs varies in a small range, some songs have some seasonal-like pattern. So this indicates the feasibility of using time series tools. Let's see them:

![image](https://raw.githubusercontent.com/TZstatsADS/Fall2016-proj4-Guanzy2224/master/doc/ACF.png)

**ACF of loudness**

![image](https://raw.githubusercontent.com/TZstatsADS/Fall2016-proj4-Guanzy2224/master/doc/PACF.png)

**PACF of loudness**

![image](https://raw.githubusercontent.com/TZstatsADS/Fall2016-proj4-Guanzy2224/master/doc/Periodagram.png)

**Periodogram of loudness**

Comparing the same 9 songs, I found that those patterns differ a lot among songs. This difference, I think, results from the eifferent music style pattern, which could be meaningful in lyrics selection. So I chose them to build connection between lyrics (with Neural Network as to be mentioned below). For ACF and PACF, I chose 15 lags. For periodogram, I chose 10 samples from 0.05 to 0.5.

Except loudness, I also included the ACF, PACF, Periodogram of **pitchs** and **length of segment**. For pitches, I preprocessed it as follow: for each segment, find the largest pitch echo within the 12 numbers, then put the sequence number (an integer from 1 to 12) as the pitch of this segment. [(Why do that?)](https://en.wikipedia.org/wiki/Chroma_feature). For segment length, I think those statistics is enough to capture the pattern in rythm.

#### 3. Others

For each song, I also include some other features like average **beats per bar**, **average time lenth per segment**, and so on.

### 1.2 Process lyrics for training data
Apply PCA to Document To Term matrix. Each PC stands for some "topic" to some degree. (Similar to applying PCA in stock price data, each PC stands for a specific segment somehow.) I chose this in place of topic modeling because the latter performs poor in that too many topics contains only few songs. In addition, matching a music audio pattern of a song to a topic can not gaurantee the accuracy in the final word recommendation or prediction.

To justify the usage of PCA, let's see how the words are correlated. First we define the distance of word pairs as: logorithm of reciprocal of cosine distance. I tried several times and found under this measure of distance, the word can be best saperated into clusters. With MDS we can inspect the word distance:

![image](https://raw.githubusercontent.com/TZstatsADS/Fall2016-proj4-Guanzy2224/master/doc/Word%20Distance%20(2).png)

From the picture it is easy to see four clusters of words and not surprising that they correspond to English, Spanish, German and French. In addition, I found that in the cloud of English words, it is approximately alingned in a line, which is a very meaningful and useful fact. This fact indicates that there is a "chain relation" between words: a is frequently used with b, c with b, d with c, and so forth. Therefore, every word can be approximately projected to an R1 space(number axis) and thus words are "continuous"! Every song corresponds to an interval of this number axis, or more precisely, a distribution on this number axis. Inspired by this, it is easy to think of PCA, which does the projection job.

In addition, using PCA has many benefits:

a. reduce dimension: from 5000 to 50

b. avoid correlation: each column in the dtm matrix is correlated (some words tends to show up together and not show up together), and predicting multi dimension Y with its correlation well modeled is a hard work. PCA make each Y orthogonal so that we can either predict Y independently or together.

c. transform the data from a few integers to real number: directly using DTM matrix as Y will result in many problems. One of them is that the poisson-like data has only few levels (1,2,3,...) and the matrix is sparse(too many 0's). PCA "spreads" the DTM to different real numbers and thus better for fitting the model.

### 2. Train neural network
To make life easier, I chose nnet package and set the hidden layer to be containing only a few nodes(20 or so).
Here Y is scores from PCA of each songs ( choose first 50 scores, so Y is multi dimension (50), this data can be handled well by nnet);
X is music features (156 real number for each song)

### 3. Make recommendations for testing data
Use the trained NNET model and take in new X's to predict scores, then time scores with loadings and get the predicted word frequency matrix.

![image](https://raw.githubusercontent.com/Guanzy2224/ADS-Project-4/master/doc/%E5%B9%BB%E7%81%AF%E7%89%871.PNG)

### Result
Average rank is about 450~550 for English songs. (2000 training, 350 testing)

### CoWorkers
Yinxiang Gao; ChenCheng Jiang; Skanda Vishwanath; Wenhang Bao
