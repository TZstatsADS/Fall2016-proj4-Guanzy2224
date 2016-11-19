# ADS-Project-4 Lyrics Recommender

## Project: Lyrics Recommender

## Project Description
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

In short:Given some music audio features of a song, this project generate a "machine" that provides lyrics recommendations.

Term: Fall 2016

+ Name: Guanzhong You
+ Uni : gy2224

## Project Idea

### 1.1 Process audio features
As could be easily read from the r code in this repo, this part I chooses several time sequence features and music patterns as features(X's). Each song has 156 dimensions of X's. They includes: pitchs, loudness, segment length, periodogram of pitchs, loudness, segment length, acf/pacf of pitchs, loudness, segment length, and so on.

I did this with hope that these features can capture the emotional style of this songs.

When cooperated with Adam Gaoo, we discovered that timbre feature can be very useful in distinguishing topics of each songs (the topic tags of each song is from LDA topic modelling model). So these features is also kept alghough we abandomed topicmodelling finally.
![image](https://raw.githubusercontent.com/Guanzy2224/ADS-Project-4/master/doc/MDS%20of%20timbre%20feature.png)

### 1.2 Process lyrics for training data
Apply pca to document to term matrix. Each pc stands for a "topic" somehow. I chose this in place of topic modeling because the latter perform poor in that too many topics contains only few songs. In addition, match music audio pattern with topics can not gaurantee the accuracy in the final word prediction or recommendation.



### 2. Train neural network
As simple as possible, I choose nnet package and set the hidden layer only a few nodes.
Here Y is scores from PCA of each songs ( choose first 50 scores, so Y is multi dimension (50));
X is music features (156 real number for each song)

### 3. Make recommendations for testing data
Use trained NNET to take in new X's and predict scores, then times scores with loadings and get the predicted word frequency matrix.

![image](https://raw.githubusercontent.com/Guanzy2224/ADS-Project-4/master/doc/%E5%B9%BB%E7%81%AF%E7%89%871.PNG)

### CoWorkers
Adam Gaoo
ChenCheng, Nicole, Jiang
Skanda, V
WenHang Bao
