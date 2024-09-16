FROM elasticsearch:7.8.0

RUN bin/elasticsearch-plugin install analysis-icu && \
    bin/elasticsearch-plugin install analysis-phonetic

EXPOSE 9200 9300