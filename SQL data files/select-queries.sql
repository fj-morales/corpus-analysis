SELECT COUNT(SENTENCE_ANNOTATION.annotation_id) AS 'annotation_id'
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id = SENTENCE_ANNOTATION.sentence_id
AND  SENTENCE_ANNOTATION.annotation_id=1
GROUP BY SENTENCE.document_id 
ORDER BY SENTENCE.document_id ASC;

SELECT COUNT(summaryTable.annotation_status) FROM
(
SELECT COUNT(SENTENCE_ANNOTATION.annotation_id) AS 'annotation_status'
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id = SENTENCE_ANNOTATION.sentence_id
AND  SENTENCE_ANNOTATION.annotation_id=6
GROUP BY SENTENCE.document_id
) summaryTable
WHERE summaryTable.annotation_status=0;

#number of lines in each document
SELECT COUNT(SENTENCE.sentence_id) FROM SENTENCE
GROUP BY SENTENCE.document_id
ORDER BY SENTENCE.document_id ASC;

#exact number of annotation_scheme with respective document id
select document.document_id,count(sentence_annotation.annotation_id) as 'annotation_id' from sentence_annotation,sentence,document where 
sentence_annotation.sentence_id = sentence.sentence_id
AND sentence.document_id = document.document_id
AND sentence_annotation.annotation_id =  1 GROUP BY document.document_id 
ORDER BY document.document_id ASC;

#To test that all sentences are process
SELECT COUNT(*) FROM SENTENCE WHERE sentence_id 
NOT IN(SELECT sentence_id FROM SENTENCE_ANNOTATION WHERE tool_id=1);

#display all the sentences with its annotations
#AntMover : tool_id=1
SELECT SENTENCE.sentence_id,SENTENCE_ANNOTATION.annotation_id
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id=SENTENCE_ANNOTATION.sentence_id
AND SENTENCE_ANNOTATION.tool_id=1
AND SENTENCE_DATE='2017-10-08';

#AWA : tool_id=2
SELECT SENTENCE.sentence_id,SENTENCE_ANNOTATION.annotation_id
FROM SENTENCE
LEFT JOIN SENTENCE_ANNOTATION ON SENTENCE.sentence_id=SENTENCE_ANNOTATION.sentence_id
AND SENTENCE_ANNOTATION.tool_id=2;

#select sentences with annotations for specific document category
SELECT SENTENCE_ANNOTATION.sentence_id,SENTENCE_ANNOTATION.annotation_id 
FROM SENTENCE_ANNOTATION,SENTENCE,DOCUMENT
WHERE SENTENCE_ANNOTATION.tool_id=1 
AND SENTENCE_ANNOTATION.sentence_date='2017-10-08'
AND SENTENCE_ANNOTATION.sentence_id = SENTENCE.sentence_id
AND SENTENCE.document_id = DOCUMENT.document_id
AND DOCUMENT.document_category like '% Agriculture %' 
ORDER BY sentence_id;

update document set document_category=trim(TRAILING '\n' FROM document_category);


#select number of sentences in a document category that annotated
SELECT DOCUMENT.document_category, COUNT(SENTENCE.sentence_id) 
FROM DOCUMENT, SENTENCE, SENTENCE_ANNOTATION
WHERE DOCUMENT.document_id = SENTENCE.document_id
AND SENTENCE.sentence_id = SENTENCE_ANNOTATION.sentence_id
AND SENTENCE_ANNOTATION.tool_id=2
GROUP BY DOCUMENT.document_category
ORDER BY DOCUMENT.document_category ASC;

#the number of lines in each category of documents
SELECT DOCUMENT.document_category, COUNT(SENTENCE.sentence_id)
FROM DOCUMENT, SENTENCE
WHERE DOCUMENT.document_id = SENTENCE.document_id
GROUP BY DOCUMENT.document_category
ORDER BY DOCUMENT.document_category ASC;

SELECT SENTENCE.sentence_id,SENTENCE.document_id,SENTENCE_ANNOTATION.annotation_id AS 'AntMover' 
FROM SENTENCE LEFT JOIN SENTENCE_ANNOTATION 
ON SENTENCE.sentence_id=SENTENCE_ANNOTATION.sentence_id 
AND SENTENCE_ANNOTATION.tool_id=1 
AND SENTENCE_ANNOTATION.sentence_date='2017-10-08' 
WHERE SENTENCE.document_id IN (SELECT DOCUMENT.document_id FROM DOCUMENT WHERE DOCUMENT.document_category='Material Science')
ORDER BY SENTENCE.sentence_id ASC;

#subset of ANTMOVER annotated sentences with AWA annotated sentences
SELECT ANTMOVERLABEL.annotation_label, AWALABEL.annotation_label FROM
SENTENCE_ANNOTATION ANTMOVER, SENTENCE_ANNOTATION AWA, ANNOTATION ANTMOVERLABEL, ANNOTATION AWALABEL
WHERE AWA.sentence_id = ANTMOVER.sentence_id
AND AWA.tool_id = 2 AND ANTMOVER.tool_id=1
AND ANTMOVER.sentence_date='2017-10-08'
AND AWA.annotation_id = AWALABEL.annotation_id
AND ANTMOVER.annotation_id = ANTMOVERLABEL.annotation_id
ORDER BY ANTMOVERLABEL.annotation_label,AWALABEL.annotation_label ASC;

#include not annotated sentences in AWA
SELECT ANTMOVER.annotation_id, AWA.annotation_id 
FROM SENTENCE_ANNOTATION ANTMOVER
LEFT JOIN SENTENCE_ANNOTATION AWA
ON ANTMOVER.sentence_id = AWA.sentence_id AND AWA.tool_id = 2
WHERE ANTMOVER.tool_id=1
AND ANTMOVER.sentence_date='2017-10-08';

