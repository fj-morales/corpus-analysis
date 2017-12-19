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
#tpCorpusObject.textProcess_OASTM('/Users/yoongkuan/Desktop/DIC-Corpus/AllData/OASTM-Corpus/OriginalFiles','/Users/yoongkuan/Desktop/Elsevier','/Users/yoongkuan/Desktop/DIC-Corpus/AllData/OASTM-Corpus/fileCategories.txt')

#text process PMC corpus
#tpCorpusObject.textProcess_PMC('/Users/yoongkuan/Desktop/corpus', '/Users/yoongkuan/Desktop/PMC')

#text process BAWE corpus
#tpCorpusObject.textProcess_BAWE('/Users/yoongkuan/Desktop/DIC-Corpus/AllData/BAWE-Corpus/CORPUS_ByDiscipline', '/Users/yoongkuan/Desktop/BAWE')

#save all preprocess files into database
#tpCorpusObject.genericDataProcessing("/Users/yoongkuan/Desktop/PMC")

#preprocess AntMover
#tpToolObject.textProcess_newVersion_AntMover('/Users/yoongkuan/Desktop/PMC_AntMover/method')

#preprocess AWA
#tpToolObject.textProcess_AWA('/Users/yoongkuan/Desktop/PMC_AWA/method','/Users/yoongkuan/Desktop/PMC_AWA/Log',PMCCorpusId)

#preprocess AWA3
#tpToolObject.textProcess_AWA3()

#text extracts sentences from database based on ID
#tpCorpusObject.extractSentenceBasedDocId('/Users/yoongkuan/Desktop/DIC-Corpus/corpus')

#extract db sentences into CSV file
tpCorpusObject.getDataIntoCSV()