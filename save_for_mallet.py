'''
This example processes the term counts for each page of a volume, outputting each
page as a document for Mallet import.

The process results in two files: train-mallet.txt and infer-mallet.txt.

train-mallet.txt can be used to train a unigram LDA model on that volume's pages.
infer-mallet.txt combines pages into a sliding frame (e.g. pg 1-3, 2-4, 3-5, etc.).
     Since page breaks are often independent of the content of the book,
     this will hopefully allow us to smooth over the individual quirks of any
     particular page and get more of a sense of topics as they move through the
     book.

TODO:

'''

from __future__ import unicode_literals
import glob
from htrc_features import FeatureReader
import bz2
from six import iteritems
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input',
                       help='Path to document to parse')
    parser.add_argument('-f', '--frame-size', default=10, type=int,
                       help='Number of pages to use in sliding frame')
    args = parser.parse_args()

    append = False 
    frame = []

    # Get a list of json.bz2 files to read
    freader = FeatureReader(args.input)
    vol = freader.next()

    # Remove special characters from title. This will allow us to name a file after it
    clean_id = ''.join([char for char in vol.title if char.isalnum()])
    
    # Open files for training (Doc=1 page) and inference (Doc=sliding set of pages)
    tfile = open('train-{}.txt'.format(clean_id), 'w+')
    inferfile = open('infer-{}.txt'.format(clean_id), 'w+' if not append else 'a')

    for page in vol.pages():
        all_terms = explode_terms(page)
        
        # Data cleaning
        all_terms = [clean(term) for term in all_terms]
        all_terms = [term for term in all_terms if term]

        # Make into string
        pagetxt = " ".join(all_terms)
        frame += [pagetxt]
        while len(frame) > args.frame_size:
            frame = frame[1:]
        tfile.write('page{0} page{0} {1}\n'.format(page.seq, pagetxt))
        inferfile.write('pages{0}to{1} pages{0}to{1} {2}\n'.format(page.seq+1-len(frame), 
                                                   page.seq, 
                                                   " ".join(frame)))
    tfile.close()
    inferfile.close()

def clean(s):
    # Strip special chars
    s = ''.join([char for char in s if char.isalnum()])
    # Remvoe short words
    if len(s) <= 2:
        return False
    return s

def explode_terms(page):
    # Access case-insensitive counts for non-POS-tagged terms
    counts_dict = page.body.tokenlist.token_counts(case=False, pos=False)
    # Explode {'word': count} to large list
    counts_list = []
    for term, count in iteritems(counts_dict):
        counts_list += [term] * count
    return counts_list

def old():
    # Get a list of json.bz2 files to read
    paths = glob.glob('data/*.json.bz2')
    paths = paths[0:4] # Truncate list for example

    # Open file for writing results
    f = bz2.BZ2File('term_volume_counts.bz2', "w")

    # Start a feature reader with the paths and pass the mapping function
    feature_reader = FeatureReader(paths)
    results = feature_reader.multiprocessing(get_term_volume_counts)

    # Save the results
    for vol, result in results:
        for t,c in result.iteritems(): # result.items() in python3
            s = "{0}\t{1}\t{2}\t{3}\n".format(vol[0], vol[1],t,c)
            f.write(s.encode('UTF-8')) # For python3, use str(s)

    f.close()


if __name__ == '__main__':
    main()
