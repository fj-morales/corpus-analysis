from TextPreprocessorCorpus import TextPreprocessorCorpus as tpCorpus
from TextPreprocessorTool import TextPreprocessorTool as tpTool

#create instance of classes
tpCorpusObject = tpCorpus()
tpToolObject = tpTool()
#corpus Id in database
OASTMCorpusID = 1
PMCCorpusId = 4
BAWECorpusId = 3 


#test OASTM data
#tpCorpusObject.textProcess_OASTM('/Users/yoongkuan/Desktop/Elsevier-corpus/files','/Users/yoongkuan/Desktop/Elsevier-corpus/output')

#text process PMC corpus
#tpCorpusObject.textProcess_PMC('/Users/yoongkuan/Desktop/PMC-corpus/files', '/Users/yoongkuan/Desktop/PMC-corpus/output', 'Sociology')

#text process BAWE corpus
#tpCorpusObject.textProcess_BAWE('/Users/yoongkuan/Desktop/DIC-Corpus/AllData/BAWE-Corpus/CORPUS_ByDiscipline', '/Users/yoongkuan/Desktop/BAWE')

#save all preprocess files into database
#tpCorpusObject.genericDataProcessing("/Users/yoongkuan/Desktop/CIC corpora/BAWE/original")

#preprocess AntMover
tpToolObject.textProcess_newVersion_AntMover('/Users/yoongkuan/Desktop/CIC Corpora/BAWE/AntMover/processFolder')

#preprocess AWA
#tpToolObject.textProcess_AWA('/Users/yoongkuan/Desktop/CIC Corpora/BAWE/AWA','/Users/yoongkuan/Desktop/CIC Corpora/BAWE/Log',BAWECorpusId)

#text extracts sentences from database based on ID
#tpCorpusObject.extractSentenceBasedDocId('/Users/yoongkuan/Desktop/DIC-Corpus/corpus')