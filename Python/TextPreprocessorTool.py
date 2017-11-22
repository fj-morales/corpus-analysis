import os
import time
import json
from DatabaseConnection import DatabaseConnection as dbConnection
from TextPreprocessorCorpus import TextPreprocessorCorpus as tpCorpus

class TextPreprocessorTool:
    
    def __init__(self):
        #tool id (predefined value in database)
        self.AntMover = '1'
        self.AWA = '2'
    
    def textProcess_newVersion_AntMover(self,folderPath):
        dbObject = dbConnection()
        db = dbObject.connectToDb()
        dbCursor = db.cursor()
        process_date = time.strftime('%Y-%m-%d %H:%M:%S')
        
        sentenceAnnotation_query = ("INSERT IGNORE INTO SENTENCE_ANNOTATION(sentence_id,tool_id,sentence_date,annotation_id) VALUES(%s,%s,%s,%s)")
        query = ("SELECT annotation_id,annotation_label FROM ANNOTATION WHERE tool_id=" + self.AntMover)
        sentenceId_query = ("SELECT sentence_id FROM SENTENCE WHERE sentence_detail=%s")
        
        dbCursor.execute(query)
        dict_AnnotationScheme = {}
        for (annotation_id,annotation_label) in dbCursor:
            dict_AnnotationScheme.update({annotation_label:annotation_id})
        
        for fileName in os.listdir(folderPath):
            if(fileName.find(".txt")!=-1):
                sentence_annotation_id = dict_AnnotationScheme.get(fileName.replace(".txt",""))
                filePointer = open(folderPath + "/" + fileName)
                for sentence in filePointer.readlines():
                    try:
                        sentenceId_data = (sentence.strip(),)
                        dbCursor.execute(sentenceId_query,sentenceId_data)
                        listSentenceId = []
                        for (sentence_id) in dbCursor:
                            listSentenceId.append(sentence_id[0])
                        
                        for sentenceId in listSentenceId:
                            sentenceAnnotation_data = (sentenceId,self.AntMover,process_date,sentence_annotation_id)
                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                    except:
                        print(fileName + ": " + sentence)
            
            db.commit()
            print(fileName)
        
        dbCursor.close()
        dbObject.closeDb(db)
            
    def textProcess_AntMover(self,folderPath):
        #get all the annotation scheme defined for AntMover in database and put in python dictionary
        #AntMover tool_id = 1 (predefined in database)
        dbObject = dbConnection()
        db = dbObject.connectToDb()
        dbCursor = db.cursor()
        
        query = ("SELECT annotation_id,annotation_label FROM ANNOTATION WHERE tool_id=" + self.AntMover)
        dbCursor.execute(query)
        dict_AnnotationScheme = {}
        for (annotation_id,annotation_label) in dbCursor:
            dict_AnnotationScheme.update({annotation_label:annotation_id})
        
        sentenceAnnotation_query = ("INSERT INTO SENTENCE_ANNOTATION(sentence_id,tool_id,sentence_date,annotation_id) VALUES(%s,%s,%s,%s)")
        
        str_sentenceId = ''
        str_annotationId = ''
        str_document_id = ''
        db_document_id = ''
        process_date = time.strftime('%Y-%m-%d %H:%M:%S')
        list_allSentence = [] #contain detail in format [sentence_detail,sentence_id]
        writeFile = open(folderPath+'/'+'error.txt','w')
        processedFile = open(folderPath+'/'+'fileNames.txt','w')
        set_addedSentenceId = set()
        
        for folderName in os.listdir(folderPath):
            str_annotationId = dict_AnnotationScheme.get(folderName)
            if(folderName.find('.')==-1): #to make sure the folderName is a folder
                pathName = folderPath + '/' + folderName
            else:
                continue
            
            for fileName in os.listdir(pathName):
                if(fileName.find('.txt')==-1):
                    continue
                #basic read file data
                openFile = open(pathName+'/'+fileName,'r')
                contentFile = openFile.readline().lstrip().rstrip()
                openFile.close()
                
                if(str_document_id==fileName.split('_')[0]):
                    #can directly query from list_allSentence and insert into sentence_annotation table
                    if(contentFile not in list_allSentence):
                        writeFile.write(folderName + ' ' + fileName + ': ' +db_document_id +'\n')
                        continue
                    
                    
                    indexSentence = list_allSentence.index(contentFile)
                    str_sentenceId = list_allSentence[indexSentence+1]
                    while(str_sentenceId in set_addedSentenceId):
                        del list_allSentence[indexSentence]
                        del list_allSentence[indexSentence]
                        indexSentence = list_allSentence.index(contentFile)
                        str_sentenceId = list_allSentence[indexSentence+1]
                    
                    
                    del list_allSentence[indexSentence]
                    del list_allSentence[indexSentence]
                    sentenceAnnotation_data = (str_sentenceId,self.AntMover,process_date,str_annotationId)
                    dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                    set_addedSentenceId.add(str_sentenceId)
                else:
                    db_document_id = ''
                    str_document_id = fileName.split('_')[0]
                    sentence_query = ("SELECT sentence_id,document_id FROM SENTENCE WHERE sentence_detail='" + contentFile +"'")
                    dbCursor.execute(sentence_query)
                    counter = 0
                    for (sentence_id,document_id) in dbCursor:
                        db_document_id = str(document_id)
                        counter=+1
                    
                    if(counter>1 or db_document_id==''):
                        writeFile.write(folderName + ' ' + fileName + '\n')
                        str_document_id = ''
                        continue
                    
                    #since document id is confirmed, populate all the sentences from the document id into 
                    list_allSentence = []
                    allSentence = ("SELECT sentence_id,sentence_detail FROM SENTENCE WHERE document_id=" + db_document_id)
                    dbCursor.execute(allSentence)
                    for(sentence_id,sentence_detail) in dbCursor:
                        list_allSentence.append(sentence_detail)
                        list_allSentence.append(str(sentence_id))
                
                    #can directly query from list_allSentence and insert into sentence_annotation table
                    if(contentFile not in list_allSentence):
                        writeFile.write(folderName + ' ' + fileName + ': ' +db_document_id +'\n')
                        continue
                    
                    indexSentence = list_allSentence.index(contentFile)
                    str_sentenceId = list_allSentence[indexSentence+1]
                    while(str_sentenceId in set_addedSentenceId):
                        del list_allSentence[indexSentence]
                        del list_allSentence[indexSentence]
                        indexSentence = list_allSentence.index(contentFile)
                        str_sentenceId = list_allSentence[indexSentence+1]
                        
                    del list_allSentence[indexSentence]
                    del list_allSentence[indexSentence]
                    
                    sentenceAnnotation_data = (str_sentenceId,self.AntMover,process_date,str_annotationId)
                    dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                    set_addedSentenceId.add(str_sentenceId)
                
                db.commit()
                processedFile.write(fileName + ': ' +db_document_id + '\n')
            
            print('Completed: ' + folderName)
        dbCursor.close()
        dbObject.closeDb(db)
        writeFile.close()
        processedFile.close()
    
    def textProcess_AWA(self,folderPath,logFolderPath,corpusId):
        dbObject = dbConnection()
        conn = dbObject.connectToDb()
        dbCursor = conn.cursor()
        
        dicAnnotation = {}
        dbCursor.execute("SELECT annotation_label,annotation_id FROM ANNOTATION WHERE tool_id=2")
        for (annotation_label,annotation_id) in dbCursor:
            dicAnnotation.update({annotation_label:annotation_id})
        
        
        process_date = time.strftime('%Y-%m-%d %H:%M:%S')
        sentenceAnnotation_query = ("INSERT IGNORE INTO SENTENCE_ANNOTATION(sentence_id,tool_id,sentence_date,annotation_id) VALUES(%s,%s,%s,%s)")
        getSentenceId_query = ("SELECT sentence_id FROM SENTENCE WHERE document_label=%s AND corpus_id=%s AND sentence_detail=%s")
        
        processedFile = open(logFolderPath+'/fileNames.txt','w')
        errorFile = open(logFolderPath+'/error.txt','w')
        countError = 0
        countFile = 0
        tpCorpusObject = tpCorpus()  
        
        allFiles = tpCorpusObject.getTotalTextFiles(folderPath, ".txt")
        
        for fileName in allFiles:
            listFileName = fileName.split('-')
            dbFileName = listFileName[-1]
            
            #check for document id associate with that file name
            getDocumentId_query = ("SELECT document_label FROM DOCUMENT WHERE document_label=%s and corpus_id=%s")
            getDocumentId_data = (dbFileName,corpusId)
            dbCursor.execute(getDocumentId_query,getDocumentId_data)
            listDocumentId=[]
            for (document_label) in dbCursor:
                listDocumentId.append(document_label[0])

            for document_id in listDocumentId:
                #read the content of the file
                rawFileData = open(fileName,'r')
                jsonRawData = ''
                flagToWrite = False
                for sentence in rawFileData.readlines():
                    if(flagToWrite):
                        jsonRawData = jsonRawData + sentence
                        
                    if(sentence.lstrip().rstrip()=='====Analytic Raw Output===='):
                        flagToWrite = True

                jsonRawData = jsonRawData.lstrip().rstrip()
                jsonData = json.loads(jsonRawData)
                
                for dicObject in jsonData:
                    if(dicObject.has_key('IMPSENT')):
                        #the sentence is annotated with 'important' category
                        #get the sentence id
                        getSentenceId_data = (document_id,corpusId,dicObject['IMPSENT'][0])
                        dbCursor.execute(getSentenceId_query,getSentenceId_data)
                        listSentenceId = []
                        for sentence_id in dbCursor:
                            listSentenceId.append(sentence_id[0])
                        
                        #write to error file if cannot find the sentence id
                        if(len(listSentenceId)==0):
                            errorFile.write(str(document_id) + ': ' + '-'.join(dicObject['IMPSENT_F'][0]))
                            errorFile.write(str(document_id) + ': ' + dicObject['IMPSENT'][0].encode("utf-8") + '\n')
                            countError = countError + 1
                        
                        for sentence_id in listSentenceId:
                            sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Important'])
                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                            listSubcategory = dicObject['IMPSENT_F'][0]
                            
                            for subCategory in listSubcategory:
                                if(subCategory=='CONTRAST'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Contrast'])
                                elif(subCategory=='EMPH'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Emphasis'])
                                elif(subCategory=='ATTITUDE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Position'])
                                elif(subCategory=='NOVSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Novelty'])
                                elif(subCategory=='NOSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Question'])
                                elif(subCategory=='GROW'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Trend'])
                                elif(subCategory=='OLD'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Background'])
                                elif(subCategory=='SURPRISE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Surprise'])
                                else:
                                    continue
                            
                                dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                
                    elif(dicObject.has_key('SUMMARY')):
                        #the sentence is annotated with 'summary' category
                        getSentenceId_data = (document_id,corpusId,dicObject['SUMMARY'][0])
                        dbCursor.execute(getSentenceId_query,getSentenceId_data)
                        listSentenceId = []
                        for sentence_id in dbCursor:
                            listSentenceId.append(sentence_id[0])
                            
                        for sentence_id in listSentenceId:
                            sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Summary'])
                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                            listSubcategory = dicObject['SUMMARY_F'][0]
                            
                            for subCategory in listSubcategory:
                                if(subCategory=='CONTRAST'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Contrast'])
                                elif(subCategory=='EMPH'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Emphasis'])
                                elif(subCategory=='ATTITUDE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Position'])
                                elif(subCategory=='NOVSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Novelty'])
                                elif(subCategory=='NOSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Question'])
                                elif(subCategory=='GROW'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Trend'])
                                elif(subCategory=='OLD'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Background'])
                                elif(subCategory=='SURPRISE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Surprise'])
                                else:
                                    continue
                            
                                dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                        
                    elif(dicObject.has_key('IMPSUMMARY')):
                        #the sentence is annotated with 'important&summary' category
                        getSentenceId_data = (document_id,corpusId,dicObject['IMPSUMMARY'][0])
                        dbCursor.execute(getSentenceId_query,getSentenceId_data)
                        listSentenceId = []
                        for sentence_id in dbCursor:
                            listSentenceId.append(sentence_id[0])
                
                        for sentence_id in listSentenceId:
                            sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Important&Summary'])
                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                            listSubcategory = dicObject['IMPSUMMARY_F'][0]
                            
                            for subCategory in listSubcategory:
                                if(subCategory=='CONTRAST'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Contrast'])
                                elif(subCategory=='EMPH'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Emphasis'])
                                elif(subCategory=='ATTITUDE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Position'])
                                elif(subCategory=='NOVSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Novelty'])
                                elif(subCategory=='NOSTAT'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Question'])
                                elif(subCategory=='GROW'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Trend'])
                                elif(subCategory=='OLD'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Background'])
                                elif(subCategory=='SURPRISE'):
                                    sentenceAnnotation_data = (sentence_id,2,process_date,dicAnnotation['Surprise'])
                                else:
                                    continue
                            
                                dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
        
            conn.commit()
            processedFile.write(fileName + '\n')
            countFile = countFile + 1
        
        processedFile.write('Complete ' + str(countFile))
        print('Complete')
        dbCursor.close()
        dbObject.closeDb(conn)
        processedFile.close()
        errorFile.write("Total errors : " + str(countError))
        errorFile.close()