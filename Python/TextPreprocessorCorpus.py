import os
from DatabaseConnection import DatabaseConnection as dbConnection
import re
from bs4 import BeautifulSoup
from SentenceTokenizer import SentenceTokenizer as st
import csv

class TextPreprocessorCorpus:
    
    def __init__(self):
        self.OASTMCorpusID = 1
        self.PMCCorpusId = 4
        self.BAWECorpusId = 3 
        #sections of papers
        self.list_sectionLabel = ['abstract','introduction','background','literature review','technique','techniques','method','methods','discussion','discussions','result','results','conclusion']
        self.list_decodeLabel = {'abstract' : 'abstract','introduction':'introduction','background':'background','method':'method','discussion':'discussion','conclusion':'conclusion','discussion1':'conclusion','introduction1':'background'}
    
    def extractSentenceBasedDocId(self,folderPath):
        dbObject = dbConnection()
        conn = dbObject.connectToDb()
        dbCursor = conn.cursor()
        
        documentId_query = ("SELECT document_id,document_category FROM DOCUMENT ORDER BY document_id ASC")
        dbCursor.execute(documentId_query)
        
        listDocumentId={}
        
        for (document_id,document_category) in dbCursor:
            listDocumentId.update({document_id:document_category})
            
        for idKey in listDocumentId.keys():
            writeFile = open(folderPath + "/" + listDocumentId.get(idKey) + "-" + str(idKey) + '.txt','w')
            
            sentence_query = ("SELECT sentence_detail,sentence_label FROM SENTENCE WHERE document_id=" + str(idKey) + " ORDER BY sentence_id ASC")
            dbCursor.execute(sentence_query)
            titleLabel = ""
            for (sentence_detail,sentence_label) in dbCursor:
                if(sentence_label!=titleLabel and sentence_label.lstrip().rstrip()!=""):
                    writeFile.write("########## " + sentence_label.encode("utf-8") +" ##########\n")
                    titleLabel=sentence_label
                
                writeFile.write(sentence_detail + "\n")
                
            writeFile.close()
            
        dbCursor.close()
        dbObject.closeDb(conn)
    
    def determineSentenceLabel(self,title):
        tempTitle = title.lower()
        if(tempTitle.find('abstract')!=-1 or tempTitle.find('abstracts')!=-1):
            return 'abstract'
        elif(tempTitle.find('introduction')!=-1 or tempTitle.find('introductions')!=-1):
            return 'introduction'
        elif(tempTitle.find('background')!=-1 or tempTitle.find('backgrounds')!=-1 or tempTitle.find('literature review')!=-1 or tempTitle.find('review')!=-1 or tempTitle.find('reviews')!=-1):
            return 'background'
        elif(tempTitle.find('technique')!=-1 or tempTitle.find('techniques')!=-1 or tempTitle.find('method')!=-1 or tempTitle.find('methods')!=-1 or tempTitle.find('methodology')!=-1 or tempTitle.find('methodologies')!=-1):
            return 'method'
        elif(tempTitle.find('discussion')!=-1 or tempTitle.find('discussions')!=-1 or tempTitle.find('result')!=-1 or tempTitle.find('results')!=-1):
            return 'discussion'
        elif(tempTitle.find('conclusion')!=-1 or tempTitle.find('conclusions')!=-1):
            return 'conclusion'
        else:
            return ''  
    
    def textProcess_OASTM(self,folderPath,outputPath,categoryPath):
        #load category file into a dictionary
        categoryFile = open(categoryPath,'r')
        dc_categoryFile = {}
        for sentence in categoryFile.readlines():
            tokenizeSentence = sentence.split('\t');
            dc_categoryFile.update({tokenizeSentence[0]:tokenizeSentence[1].lstrip().rstrip()})
        
        categoryFile.close()

        for fileName in os.listdir(folderPath):
            
            #create new preprocess text file
            prefixFileName = fileName.split('_')[0]
            abstract = open(outputPath + '/abstract/' + 'abstract-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID) +'-'+fileName.replace('.xml','')+'.txt','w')
            introduction = open(outputPath + '/introduction/' + 'introduction-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID)+'-'+fileName.replace('.xml','')+'.txt','w')
            background = open(outputPath + '/background/' + 'background-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID)+'-'+fileName.replace('.xml','')+'.txt','w')
            method = open(outputPath + '/method/' + 'method-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID)+'-'+fileName.replace('.xml','')+'.txt','w')
            discussion = open(outputPath + '/discussion/' + 'discussion-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID)+'-'+fileName.replace('.xml','')+'.txt','w')
            conclusion = open(outputPath + '/conclusion/' + 'conclusion-' +dc_categoryFile.get(prefixFileName)+'-'+ str(self.OASTMCorpusID)+'-'+fileName.replace('.xml','')+'.txt','w')
            
            #open the file document
            sentenceLabel = '';
            abstract_counter = 0;
            documentFile = open(folderPath + '/' + fileName,'r')
            for sentence in documentFile.readlines():        
                if(sentence[0]!='<'):
                    try:
                        sentenceLabelText = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', sentence.encode("utf-8") )
                        sentenceLabel = re.sub( '\s+', ' ', sentenceLabelText).strip()
                    except:
                        print(sentence)
                        continue
                    
                    if((self.determineSentenceLabel(sentenceLabel)=='' and abstract_counter==0) or self.determineSentenceLabel(sentenceLabel)=='abstract'):
                        sentenceLabel = 'abstract'
                        abstract_counter = abstract_counter + 1
                    else:
                        sentenceLabel = self.determineSentenceLabel(sentenceLabel)
    
                elif(sentence[0:2]=='<s'):
                    processSentence = BeautifulSoup(sentence,'html.parser')
                    sentence = re.sub("[\(\[].*?[\)\]]", "", processSentence.get_text().encode("utf-8") ) 
                    text = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', sentence)
                    convertedSentence = re.sub( '\s+', ' ', text).strip()
                    
                    if(convertedSentence=='' or len(convertedSentence)<10 or len(convertedSentence.split(' '))<5):
                        continue
                    
                    convertedSentence = convertedSentence + ' [SE].\n'
                    if(sentenceLabel=='abstract'):
                        abstract.write(convertedSentence)
                    elif(sentenceLabel=='introduction'):
                        introduction.write(convertedSentence)
                    elif(sentenceLabel=='background'):
                        background.write(convertedSentence)
                    elif(sentenceLabel=='method'):
                        method.write(convertedSentence)
                    elif(sentenceLabel=='discussion'):
                        discussion.write(convertedSentence)
                    elif(sentenceLabel=='conclusion'):
                        conclusion.write(convertedSentence)
                    else:
                        method.write(convertedSentence)
            
            documentFile.close()
            abstract.close()
            introduction.close()
            background.close()
            method.close()
            discussion.close()
            conclusion.close()
            print(fileName)
            
        print('textProcess_OASTM completed')
    
    def textProcess_PMC(self,folderPath,outputPath):
        stObject = st()
        tokenizer = stObject.trainSentenceTokenizer()
        allFiles = self.getTotalTextFiles(folderPath,".nxml")
        print(len(allFiles))
                
        for filePath in allFiles:
            fileNameDetail = filePath.split('/')
            fileName = fileNameDetail[-1]
            categoryName = fileNameDetail[-2]
            rawText = open(filePath)
            soupParser = BeautifulSoup(rawText,'html.parser')
            
            #open file to save the processes file
            abstract = open(outputPath + '/abstract/' + 'abstract-' +categoryName+'-'+ str(self.PMCCorpusId) +'-'+fileName.replace('.nxml','')+'.txt','w')
            introduction = open(outputPath + '/introduction/' + 'introduction-' +categoryName+'-'+ str(self.PMCCorpusId)+'-'+fileName.replace('.nxml','')+'.txt','w')
            background = open(outputPath + '/background/' + 'background-' +categoryName+'-'+ str(self.PMCCorpusId)+'-'+fileName.replace('.nxml','')+'.txt','w')
            method = open(outputPath + '/method/' + 'method-' +categoryName+'-'+ str(self.PMCCorpusId)+'-'+fileName.replace('.nxml','')+'.txt','w')
            discussion = open(outputPath + '/discussion/' + 'discussion-' +categoryName+'-'+ str(self.PMCCorpusId)+'-'+fileName.replace('.nxml','')+'.txt','w')
            conclusion = open(outputPath + '/conclusion/' + 'conclusion-' +categoryName+'-'+ str(self.PMCCorpusId)+'-'+fileName.replace('.nxml','')+'.txt','w')
            
            abstract_counter = 0
            title=''
            for sectionDetail in soupParser.find_all('sec'):
                temptitle = sectionDetail.find('title')
                if(temptitle is not None):
                    title = temptitle.get_text()
                    
                title = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', title)
                title = re.sub( '\s+', ' ', title).strip().encode("utf-8")
                
                if((self.determineSentenceLabel(title)=='' and abstract_counter==0) or self.determineSentenceLabel(title)=='abstract'):
                    title = 'abstract'
                    abstract_counter = abstract_counter + 1
                else:
                    title = self.determineSentenceLabel(title)
                
                for paragraphDetail in sectionDetail.find_all('p'):  
                    paragraphText = re.sub('\(.*?\)','',paragraphDetail.get_text())
                    listSentence = tokenizer.tokenize(paragraphText)
                    for sentence in listSentence:
                        #insert into sentence table
                        try:
                            sentence = re.sub("[\(\[].*?[\)\]]", "", sentence.encode("utf-8"))                      
                            text = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', sentence)
                            convertedSentence = re.sub( '\s+', ' ', text)
                            convertedSentence = convertedSentence.strip()
                            if(convertedSentence=='' or len(convertedSentence)<10 or len(convertedSentence.split(' '))<5):
                                continue
                        except:
                            print(sentence)
                            continue
                        
                        convertedSentence = convertedSentence + ' [SE].\n'

                        if(title=='abstract'):
                            abstract.write(convertedSentence)
                        elif(title=='introduction'):
                            introduction.write(convertedSentence)
                        elif(title=='background'):
                            background.write(convertedSentence)
                        elif(title=='method'):
                            method.write(convertedSentence)
                        elif(title=='discussion'):
                            discussion.write(convertedSentence)
                        elif(title=='conclusion'):
                            conclusion.write(convertedSentence)
                        else:
                            method.write(convertedSentence)
            
            abstract.close()
            introduction.close()
            background.close()
            method.close()
            discussion.close()
            conclusion.close()
            rawText.close()
            
        print('textProcess_PMC completed')
    
    def textProcess_BAWE(self,folderPath,outputPath):
        
        allFiles = self.getTotalTextFiles(folderPath,".xml")
        print(len(allFiles))
        for filePath in allFiles:
            fileNameDetail = filePath.split('/')
            fileName = fileNameDetail[-1]
            categoryName = fileNameDetail[-2]
            
            rawText = open(filePath)
            soupParser = BeautifulSoup(rawText,'html.parser')
            
            #open file to save the processes file
            introduction = open(outputPath + '/introduction/' + 'introduction-' +categoryName+'-'+ str(self.BAWECorpusId)+'-'+fileName.replace('.xml','')+'.txt','w')
            discussion = open(outputPath + '/discussion/' + 'discussion-' +categoryName+'-'+ str(self.BAWECorpusId)+'-'+fileName.replace('.xml','')+'.txt','w')
            conclusion = open(outputPath + '/conclusion/' + 'conclusion-' +categoryName+'-'+ str(self.BAWECorpusId)+'-'+fileName.replace('.xml','')+'.txt','w')
            title = '';
            
            
            bodyContent = soupParser.find('body')

#           totalParagraph = 0
#           for i in bodyContent.find_all('p'):
#               totalParagraph = totalParagraph + 1
            
            totalParagraph = len(bodyContent.find_all('p'))
            
            indexSection = 0
            for sectionDetail in bodyContent.find_all('p'):
                indexSection = indexSection + 1
                
                if(indexSection==1):
                    title = 'introduction'
                elif(indexSection==totalParagraph):
                    title = 'conclusion'
                else:
                    title = 'discussion'
                
                for sentence in sectionDetail.find_all('s'):  
                    #insert into sentence table
                    sentence = sentence.get_text().encode("utf-8")    
                    sentence = re.sub("[\(\[].*?[\)\]]", "", sentence)        
                    text = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', sentence)
                    convertedSentence = re.sub( '\s+', ' ', text)
                    convertedSentence = convertedSentence.strip()
                    if(convertedSentence=='' or len(convertedSentence)<10 or len(convertedSentence.split(' '))<5):
                        continue
                    
                    convertedSentence = convertedSentence + ' [SE].\n'

                    if(title=='introduction'):
                        introduction.write(convertedSentence)
                    elif(title=='discussion'):
                        discussion.write(convertedSentence)
                    elif(title=='conclusion'):
                        conclusion.write(convertedSentence)
            

            introduction.close()
            discussion.close()
            conclusion.close()
            rawText.close()
        
        print('textProcess_BAWE completed')
    
    def getTotalTextFiles(self,folderPath,extensionFile):
        files = []
        for objectName in os.listdir(folderPath):
            if(objectName.find(extensionFile)!=-1):
                files.append(folderPath + '/' + objectName)
            elif(objectName.find(".")==-1):
                files.extend(self.getTotalTextFiles(folderPath + '/' + objectName,extensionFile))
                
        return files
    
    def genericDataProcessing(self,folderPath):
        
        #open db connection
        dbObject = dbConnection()
        db = dbObject.connectToDb()
        dbCursor = db.cursor()
        
        document_query = ("INSERT IGNORE INTO document(document_label,document_category,corpus_id) VALUES(%s,%s,%s)")
        sentence_query = ("INSERT INTO sentence(sentence_detail,sentence_label,document_label,corpus_id) VALUES(%s,%s,%s,%s)")
        
        files = self.getTotalTextFiles(folderPath,".txt")
        print("Total files: ", len(files))
        for eachFile in files:
            
            #get the file detail
            fileNameDetail = eachFile.split('-')
            sentenceLabel = self.list_decodeLabel.get(fileNameDetail[0].split('/')[-1])
            documentCategory = fileNameDetail[1]
            corpusId = fileNameDetail[2]
            fileName = fileNameDetail[3]
            
            #save the document file into document table
            document_data = (fileName,documentCategory,corpusId)
            dbCursor.execute(document_query,document_data)
            
            fileContent = open(eachFile)
            for sentence in fileContent.readlines():
                sentence = sentence.strip()
                if(sentence!=''):
                    try:
                        sentence_data = (sentence,sentenceLabel,fileName,corpusId)
                        dbCursor.execute(sentence_query,sentence_data)
                    except:
                        print(sentence)
                        continue
            fileContent.close()
            
        db.commit()
        dbCursor.close
        dbObject.closeDb(db)
        print("genericDataProcessing completed")
    
    def getDataIntoCSV(self):
        dbObject = dbConnection()
        db = dbObject.connectToDb()
        dbCursor = db.cursor()
        sentences_query = ("SELECT sentence_id,sentence_detail FROM sentence WHERE corpus_id="+str(self.OASTMCorpusID))
        dbCursor.execute(sentences_query)
        dicSentence = {}
        for (sentence_id,sentence_detail) in dbCursor:
            dicSentence.update({sentence_id:sentence_detail})
            
        annotation_query = ("SELECT annotation_id, annotation_label FROM annotation")
        dbCursor.execute(annotation_query)
        dicAnnotation = {}
        for (annotation_id, annotation_label) in dbCursor:
            dicAnnotation.update({annotation_id:annotation_label})
                
        csvFile = open("ElsevierSentences_AWA3_AWA_ANTMOVER.csv",'w')
        filewriter = csv.writer(csvFile, delimiter=',', quoting=csv.QUOTE_ALL)
        listAWA = ["Important","Summary","Important&Summary","Background","Contrast","Emphasis","Novelty","Position","Question","Surprise","Trend"]
        listAWA3 = ["AWA3_Important","AWA3_Summary","AWA3_Important&Summary","AWA3_Background","AWA3_Contrast","AWA3_Emphasis","AWA3_Novelty","AWA3_Position","AWA3_Question","AWA3_Surprise","AWA3_Trend"]
        listAntMover = ["1_claiming_centrality","2_making_topic_generalizations","5_indicating_a_gap","9_announcing_present_research","10_announcing_principal_findings","11_evaluation_of_research"]
        headerList = ["Id","Text"]
        headerList.extend(listAWA3)
        headerList.extend(listAWA)
        headerList.extend(listAntMover)
        listAllAnnotations = listAWA3 + listAWA + listAntMover
        print(headerList)
        print(listAllAnnotations)
        filewriter.writerow(headerList)
        
        for sentence_id in dicSentence.keys():
            sentence_annotation_query = ("SELECT annotation_id FROM sentence_annotation WHERE sentence_id="+str(sentence_id))
            dbCursor.execute(sentence_annotation_query)
            listSentenceAnnotation = []
            for (annotation_id) in dbCursor:
                listSentenceAnnotation.append(dicAnnotation.get(annotation_id[0]))
            
            #prepare list to write to file
            csvRow = [sentence_id, dicSentence.get(sentence_id)]
            for annotation_label in listAllAnnotations:
                if(annotation_label in listSentenceAnnotation):
                    csvRow.append("True")
                else:
                    csvRow.append("False")
            
            filewriter.writerow(csvRow)
        
        csvFile.close()
        dbCursor.close()
        dbObject.closeDb(db)
        print("getDataIntoCSV completed")
            