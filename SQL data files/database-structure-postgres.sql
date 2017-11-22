#Drop tables
DROP TABLE IF EXISTS SENTENCE_ANNOTATION;
DROP TABLE IF EXISTS ANNOTATION;
DROP TABLE IF EXISTS TOOL;
DROP TABLE IF EXISTS SENTENCE;
DROP TABLE IF EXISTS DOCUMENT;
DROP TABLE IF EXISTS CORPUS;

#Create tables
CREATE TABLE IF NOT EXISTS CORPUS(
corpus_id				SERIAL,
corpus_label				VARCHAR(50),
corpus_license			BOOLEAN, #0-not exist, 1-exist
corpus_license_detail	VARCHAR(250),
PRIMARY KEY(corpus_id)
);

CREATE TABLE IF NOT EXISTS DOCUMENT(
document_label			VARCHAR(50),
document_category	VARCHAR(50) DEFAULT NULL,
corpus_id					INTEGER,
PRIMARY KEY(document_label,corpus_id),
FOREIGN KEY(corpus_id) REFERENCES CORPUS(corpus_id)
);

CREATE TABLE IF NOT EXISTS SENTENCE(
sentence_id					BIGSERIAL,
sentence_detail			VARCHAR(2500),
sentence_label			VARCHAR(350) DEFAULT NULL, #can be section name or number of line in the document
document_label			VARCHAR(50),
corpus_id					INTEGER,
PRIMARY KEY(sentence_id),
FOREIGN KEY(document_label,corpus_id) REFERENCES DOCUMENT(document_label,corpus_id)
);

CREATE TABLE IF NOT EXISTS TOOL(
tool_id						SERIAL,
tool_name					VARCHAR(50),
tool_annotation			VARCHAR(50),
PRIMARY KEY(tool_id)
);

CREATE TABLE IF NOT EXISTS ANNOTATION(
annotation_id		SERIAL,
annotation_label		VARCHAR(50),
tool_id						INTEGER,
PRIMARY KEY(annotation_id),
FOREIGN KEY(tool_id) REFERENCES TOOL(tool_id)
);

CREATE TABLE IF NOT EXISTS SENTENCE_ANNOTATION(
sentence_id				BIGINT,
tool_id						INTEGER,
sentence_date		DATE,
annotation_id			INTEGER,
PRIMARY KEY(sentence_id, tool_id,sentence_date,annotation_id),
FOREIGN KEY(sentence_id) REFERENCES SENTENCE(sentence_id),
FOREIGN KEY(tool_id) REFERENCES TOOL(tool_id),
FOREIGN KEY(annotation_id) REFERENCES ANNOTATION(annotation_id)
);

#Create index
CREATE INDEX index_sentence_detail ON SENTENCE(sentence_detail);
CREATE INDEX index_sentence_document_id ON SENTENCE(document_label,corpus_id);