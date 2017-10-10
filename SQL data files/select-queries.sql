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

SELECT DISTINCT(sentence_date) FROM SENTENCE_ANNOTATION;
SELECT COUNT(*) FROM SENTENCE_ANNOTATION WHERE sentence_date='2017-10-10';
SELECT COUNT(*) FROM SENTENCE_ANNOTATION WHERE sentence_date='2017-10-08';

SELECT COUNT(*) FROM SENTENCE_ANNOTATION sa1, SENTENCE_ANNOTATION sa2
WHERE sa1.sentence_id=sa2.sentence_id
AND sa1.annotation_id != sa2.annotation_id
AND sa1.tool_id = 1 AND sa2.tool_id=1
AND sa1.sentence_date='2017-10-08'
AND sa2.sentence_date='2017-10-10';
