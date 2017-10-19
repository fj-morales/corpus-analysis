#Delete corpus information
DELETE FROM DOCUMENT;
DELETE FROM SENTENCE;
DELETE FROM ANNOTATION WHERE tool_id=2;
DELETE FROM SENTENCE_ANNOTATION;
COMMIT;

#Insert corpus information
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 1,'OASTM',0,'No license required');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES(2, 'PLOSOne',1,'Creative Commons Attribution license');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 3,'OTA',0,'No license required but some addtional texts requested require license');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 4,'PMC',1,'Creative Commons license');
COMMIT;

INSERT INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(1,'AntMover','Modified CARS model');
INSERT INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(2,'AWA','Modified from AZ for sentence level parsing');
COMMIT;

#AntMover Annotation Sheme
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('1_claiming_centrality',1);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('2_making_topic_generalizations',1);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('5_indicating_a_gap',1);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('9_announcing_present_research',1);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('10_announcing_principal_findings',1);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('11_evaluation_of_research',1);

#AWA Annotation Scheme
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('MainCategory',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Background',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Contrast',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Emphasis',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Novelty',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Position',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Question',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Surprise',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Trend',2);
COMMIT;


