import os
import DatabaseConnection as dbConnection
import re
from bs4 import BeautifulSoup
import time

#corpus id (predefined value in database)
OASTMCorpusID = 1

#tool id (predefined value in database)
AntMover = '1'
AWA = '2'

list_sectionLabel = ['introduction','abstract','background','technique','techniques','method','methods','conclusion','content']

def textProcess_OASTM(folderPath,outputPath):
    #load category file into a dictionary
    categoryFile = open('/Users/yoongkuan/Desktop/DIC-Corpus/OASTM-corpus/fileCategories.txt','r')
    dc_categoryFile = {}
    for sentence in categoryFile.readlines():
        tokenizeSentence = sentence.split('\t');
        dc_categoryFile.update({tokenizeSentence[0]:tokenizeSentence[1].lstrip().rstrip()})
    
    categoryFile.close()
    #get dbconnection
    db = dbConnection.connectToDb();
    dbCursor = db.cursor();
    
    #queries for database
    document_query = ("INSERT INTO DOCUMENT(document_label,document_category,corpus_id) VALUES(%s,%s,%s)")
    sentence_query = ("INSERT INTO SENTENCE(sentence_detail,sentence_label,document_id) VALUES(%s,%s,%s)")
    
    for fileName in os.listdir(folderPath):
        document_data = (fileName,dc_categoryFile.get(fileName.split('_')[0]),OASTMCorpusID)
        dbCursor.execute(document_query,document_data)
        
        #retrieve the document id
        documentId = ''
        select_query = ("SELECT document_id,document_label FROM DOCUMENT WHERE document_label='" + fileName + "'")
        dbCursor.execute(select_query)
        for (document_id,document_label) in dbCursor:
            documentId = document_id
        
        #create new preprocess text file
        newFile = open(outputPath + '/dic-'+fileName.split('_')[0]+'.txt','w')
        
        #open the file document
        sentenceLabel = 'abstract';
        documentFile = open(folderPath + '/' + fileName,'r')
        for sentence in documentFile.readlines():            
            if(sentence[0]!='<'):
                sentenceLabelText = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', sentence).strip().lower();
                sentenceLabel = re.sub( '\s+', ' ', sentenceLabelText)
                ''' #to filter the label name to more general name
                if(re.sub('[^A-Za-z0-9\.]+', ' ', sentence).strip().lower() in list_sectionLabel):
                    sentenceLabel = sentence
                else:
                    sentenceLabel = 'content'
                continue
                '''
            elif(sentence[0:2]=='<s'):
                processSentence = BeautifulSoup(sentence,'html.parser')
                text = re.sub('[^A-Za-z0-9\(\)\[\]\, ]+', '', processSentence.get_text()).lstrip().rstrip()
                convertedSentence = re.sub( '\s+', ' ', text)
                convertedSentence = convertedSentence + ' [SE].'
                #convertedSentence = re.sub('\s[A-Za-z0-9][.]',' AB.',convertedSentenceText) # to avoid the sentence ending [A-Za-z0-9][.] as AntMover would not differentiate it as sentence ending
                sentence_data = (convertedSentence,sentenceLabel,documentId)
                dbCursor.execute(sentence_query,sentence_data)
                newFile.write(convertedSentence + '\n')
                
        db.commit()
        newFile.close()
        
    print('Completed')
    dbCursor.close()
    dbConnection.closeDb(db)

def textProcess_AntMover(folderPath,corpusId):
    
    #get all the annotation scheme defined for AntMover in database and put in python dictionary
    #AntMover tool_id = 1 (predefined in database)
    db = dbConnection.connectToDb()
    dbCursor = db.cursor()
    
    query = ("SELECT annotation_id,annotation_label FROM ANNOTATION WHERE tool_id=" + AntMover)
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
                sentenceAnnotation_data = (str_sentenceId,AntMover,process_date,str_annotationId)
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
                
                sentenceAnnotation_data = (str_sentenceId,AntMover,process_date,str_annotationId)
                dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                set_addedSentenceId.add(str_sentenceId)
            
            db.commit()
            processedFile.write(fileName + ': ' +db_document_id + '\n')
        
        print('Completed: ' + folderName)
    dbCursor.close()
    dbConnection.closeDb(db)
    writeFile.close()
    processedFile.close()


def textProcess_AWA(folderPath,corpusId):
    
    db = dbConnection.connectToDb()
    dbCursor = db.cursor()
    process_date = time.strftime('%Y-%m-%d %H:%M:%S')
    sentenceAnnotation_query = ("INSERT INTO SENTENCE_ANNOTATION(sentence_id,tool_id,sentence_date,annotation_id) VALUES(%s,%s,%s,%s)")
    writeFile = open(folderPath+'/files/'+'error.txt','w')
    processedFile = open(folderPath+'/files/'+'fileNames.txt','w')
    noRedundantSentence = 0
    #get all the annotation scheme of AWA except the main category annotation
    dicAnnotation = {}
    dbCursor.execute("SELECT annotation_label,annotation_id FROM ANNOTATION WHERE tool_id=2")
    for (annotation_label,annotation_id) in dbCursor:
        dicAnnotation.update({annotation_label:annotation_id})
    
    for fileName in os.listdir(folderPath):
        if(fileName.find('.txt')==-1):
            continue
        else:
            contentFile = open(folderPath + '/' +fileName)
            for sentenceFile in contentFile.readlines():
                sentenceWithoutTrailingSpace = sentenceFile.rstrip()
                if(sentenceWithoutTrailingSpace!=''):
                    #check the sentence in the database
                    dbCursor.execute("SELECT COUNT(sentence_id) AS countno FROM SENTENCE WHERE sentence_detail='" + sentenceWithoutTrailingSpace +"'")
                    for countno in dbCursor:
                        noRedundantSentence = countno[0]
                    
                    if(noRedundantSentence==0):
                        #tokenize and get the sub category annotation scheme
                        listTokenizeSentence = sentenceWithoutTrailingSpace.split(' ')
                        intTokenCount = 1
                        tempStoreAnnotation = set()
                        for tokenWord in listTokenizeSentence:
                            if(dicAnnotation.has_key(tokenWord)):
                                tempStoreAnnotation.add(tokenWord) # store the sub category annotations for the sentence
                                tempSentence = ' '.join(listTokenizeSentence[intTokenCount:])
                                intTokenCount+=1
                                dbCursor.execute("SELECT COUNT(sentence_id) AS countno FROM SENTENCE WHERE sentence_detail='" + tempSentence +"'")
                                for countno in dbCursor:
                                    noRedundantSentence = countno[0]
                                    
                                if(noRedundantSentence==0):
                                    continue #means the sentence has more than one annotation
                                elif(noRedundantSentence==1):
                                    #insert into SENTENCE_ANNOTATION table with all the tempStoreAnnotation
                                    dbCursor.execute("SELECT sentence_id FROM SENTENCE WHERE sentence_detail='" + tempSentence +"'")
                                    for (sentence_id) in dbCursor:
                                        for subAnnotation in tempStoreAnnotation:
                                            sentenceAnnotation_data = (sentence_id[0],AWA,process_date,dicAnnotation.get(subAnnotation))
                                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                                    break
                                else:
                                    #insert into error file with sentence:fileName
                                    writeFile.write(fileName + ' ' + tempSentence + '\n')
                                    break
                                
                            else:
                                #insert into error file with sentence:fileName  
                                writeFile.write(fileName + ' ' + sentenceFile + '\n')  
                                break    
                                
                    elif(noRedundantSentence==1):
                        #insert into SENTENCE_ANNOTATION table
                        dbCursor.execute("SELECT sentence_id FROM SENTENCE WHERE sentence_detail='" + sentenceFile +"'")
                        for (sentence_id) in dbCursor:
                            sentenceAnnotation_data = (sentence_id[0],AWA,process_date,dicAnnotation.get('MainCategory'))
                            dbCursor.execute(sentenceAnnotation_query,sentenceAnnotation_data)
                    else:
                        #insert into error file with sentence:fileName
                        writeFile.write(fileName + ' ' + sentenceFile + '\n')
                        
        db.commit()
        processedFile.write(fileName + '\n')
        print(fileName)
    
    print('Completed')
    writeFile.close()
    processedFile.close()
    dbCursor.close()
    dbConnection.closeDb(db)
                
                