#!/usr/bin/python

import numpy as np
import pandas
from nltk.corpus import stopwords
from sklearn.cluster import KMeans
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import PCA
import matplotlib.pyplot as pl
import time
import warnings
import csv
from sklearn.utils.extmath import randomized_svd
warnings.filterwarnings("ignore")


# performs Latent Semantic Analysis on tweets
def LSA(stopset, docs):
    # Vectorize the tweets with tf-idf weights where each row is a tweet and each column is a word
    vectorizer = TfidfVectorizer(stop_words=stopset, min_df=1, max_df=.7, use_idf=True, ngram_range=(1, 1))
    X = vectorizer.fit_transform(docs)
    terms = vectorizer.get_feature_names()
    #print terms
    U, Sigma, VT = randomized_svd(X, n_components=15,n_iter=5,random_state=1)
    return U, Sigma, VT, terms


# computes distance (1-cosine similarity) between documents
# input V matrix from LSA (rows = number of documents, columns = singular vectors)
def docDistance(D):
    sim_mat = np.zeros((D.shape[0], D.shape[0]))
    for i in range(D.shape[0]):
        for j in range(D.shape[0]):
            doc_sim = 1 - cosine_similarity(D[i], D[j])
            sim_mat[i][j] = doc_sim
            j = j + 1
        i = i + 1

    return (sim_mat)


def conceptTerms(terms, lsa):
    for i, comp in enumerate(lsa.components_):
        termsInComp = zip(terms, comp)
        sortedTerms = sorted(termsInComp, key=lambda x: x[1], reverse=True)[:5]
        print("Concept %d:" % i)
        for term in sortedTerms:
            print(term[0])
        print(" ")





def main(in_file, out_folder, save):
    # open input file with all tweets separated by a new_line

    text_file = open(in_file)

    # read all the tweets, eliminate numbers and white sapces and store them in a list where each element is a tweet
    docs = (text_file.read().strip()).translate(None, '1234567890').split('\n')

    # define a dictionary of stop words
    stopset = set(stopwords.words('english'))
    #freq_words = ["ellicott", "city", "ellicottcity", "md", "maryland", "in", "elliott", "#"]
    #stopset |= set(freq_words)

    # apply lsa to fit the vectorized tweet matrix (X), and save the result
    print("LSA:")

    start_time_lsa = time.time()
    #lsa, X_lsa = LSA(stopset, docs)
    U, Sigma, VT, terms = LSA(stopset, docs)
    print (type(terms))
    time_taken_lsa = time.time() - start_time_lsa

    print (U.shape, VT.transpose().shape)
    #print("LSA variance:" + str("%.2f" % (sum(lsa.explained_variance_) * 100)))
    print("Time: " + str("%.2f" % time_taken_lsa) + "sec")
    print("*****************************")
    print("\n")
    f = open('/Users/amritaanam/Documents/GIT_Repo/hackumbc17/out_matrices/terms.txt', 'w')
    for item in terms:
        f.write("%s\n" % item)

    if save == 1:
        np.savetxt(out_folder + "term_mat_U.csv",VT.transpose(), delimiter=",")
        np.savetxt(out_folder + "doc_mat_V.csv", U, delimiter=",")
        #np.savetxt(out_folder + "terms.csv", terms, delimiter=",")

    # compute tweet-tweet distance matrix
    #print("Tweet Distance:")

    #start_time_dis = time.time()
    #S = docDistance(X_lsa)
    #time_taken_dis = time.time() - start_time_dis

    #print("Time: " + str("%.2f" % time_taken_dis) + "sec")
    #print("*****************************")
    #print("\n")

    #if save == 1:
    #    np.savetxt(out_folder + "tweet_distance.csv", S, delimiter=",")

    # compute k-means clustering on tweet distance matrix
    # save the cluster indexes with the top 2 principal components and the cluster centroids
    #print("k-means:")

    #start_time_km = time.time()
    #K, C, P, P2D = KMeansClustering(S)
    #time_taken_km = time.time() - start_time_km

    #print("PCA variance:" + str("%.2f" % (sum(P.explained_variance_) * 100)))
    #print("Time: " + str("%.2f" % time_taken_km) + "sec")
    #print("*****************************")
    #print("\n")

    #if save == 1:
    #    np.savetxt(out_folder + "cluster_centroids.csv", K.cluster_centers_, delimiter=",")
    #    np.savetxt(out_folder + "tweet_clusters.csv", C, delimiter=",")

    # plot the clusters
    #print("Plot:")
    #plotCluster(K, P2D)

    # concept terms
    # terms = vectorizer.get_feature_names()
    # conceptTerms(terms, lsa)


in_file = "/Users/amritaanam/Documents/GIT_Repo/hackumbc17/projects.txt"
out_folder = "/Users/amritaanam/Documents/GIT_Repo/hackumbc17/out_matrices/projects/"
main(in_file, out_folder, 1)
