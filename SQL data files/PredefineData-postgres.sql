--Insert corpus information
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 1,'OASTM',0,'No license required');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES(2, 'PLOSOne',1,'Creative Commons Attribution license');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 3,'BAWE',0,'No license required but some addtional texts requested require license');
INSERT INTO CORPUS(corpus_id,corpus_label,corpus_license,corpus_license_detail) 
VALUES( 4,'PMC',1,'Creative Commons license');
COMMIT;

INSERT INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(1,'AntMover','Modified CARS model');
INSERT INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(2,'AWA','Modified from AZ for sentence level parsing');
INSERT INTO TOOL(tool_id,tool_name, tool_annotation) 
VALUES(3,'AWA3','Modified from AZ for sentence level parsing');
COMMIT;

--AntMover Annotation Sheme
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

--AWA Annotation Scheme
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Important',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Summary',2);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('Important&Summary',2);
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

--AWA3 Annotation Scheme
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Important',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Summary',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Important&Summary',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Background',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Contrast',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Emphasis',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Novelty',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Position',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Question',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Surprise',3);
INSERT INTO ANNOTATION(annotation_label,tool_id) 
VALUES('AWA3_Trend',3);
COMMIT;