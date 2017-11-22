#Insert corpus information
INSERT IGNORE INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 1,'OASTM',0,'No license required');
INSERT IGNORE INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES(2, 'PLOSOne',1,'Creative Commons Attribution license');
INSERT IGNORE INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 3,'BAWE',0,'No license required but some addtional texts requested require license');
INSERT IGNORE INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 4,'PMC',1,'Creative Commons license');
COMMIT;

INSERT IGNORE INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(1,'AntMover','Modified CARS model');
INSERT IGNORE INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(2,'AWA','Modified from AZ for sentence level parsing');
COMMIT;

#AntMover Annotation Sheme
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('1_claiming_centrality',1);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('2_making_topic_generalizations',1);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('5_indicating_a_gap',1);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('9_announcing_present_research',1);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('10_announcing_principal_findings',1);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('11_evaluation_of_research',1);

#AWA Annotation Scheme
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Important',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Summary',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Important&Summary',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Background',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Contrast',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Emphasis',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Novelty',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Position',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Question',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Surprise',2);
INSERT IGNORE INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Trend',2);
COMMIT;