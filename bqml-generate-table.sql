CREATE OR REPLACE EXTERNAL TABLE
 bqml_tutorial.image_dataset
WITH CONNECTION DEFAULT 
OPTIONS(object_metadata="DIRECTORY",
   uris=["gs://bq-generate-table-demo/images/*"])

CREATE OR REPLACE MODEL
 bqml_tutorial.gemini25flash
REMOTE WITH CONNECTION DEFAULT 
OPTIONS (endpoint = "gemini-2.5-flash-preview-05-20")


# Query for generating a table with additional prompts for data in google cloud sql
SELECT
  city_name,
  state,
  brief_history,
  attractions,
  uri
FROM
  AI.GENERATE_TABLE( MODEL bqml_tutorial.gemini25flash,
    (
    SELECT
      ("Recognize the city from the picture and output its name, belonging state, brief history, and tourist attractions. Please output nothing if the image is not a city.",
        ref) AS prompt,
      uri
    FROM
      bqml_tutorial.image_dataset),
    STRUCT( "city_name STRING, state STRING, brief_history STRING, attractions ARRAY<STRING>" AS output_schema,
      8192 AS max_output_tokens))