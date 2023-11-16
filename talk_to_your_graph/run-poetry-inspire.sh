#!/bin/sh

# Authentication token to access the plugin, replace with actual value
export BEARER_TOKEN="<your-bearer-token>"

# Your OpenAI API KEY, replace with actual value
export OPENAI_API_KEY="<your-openai-api-key>"

# Vector database to use, in our case Weaviate
export DATASTORE=weaviate
# Weaviate's URL
export WEAVIATE_URL=http://localhost:8080
# Weaviate's schema name
export WEAVIATE_CLASS=INSPIRE_KG

# Text chunk size for indexing
export CHUNK_SIZE=400

poetry run start
