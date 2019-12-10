FROM emeraldsquad/sonar-scanner:1.0.2

COPY start-sonar-scanner.sh /start-sonar-scanner.sh
RUN apk -U --no-cache add git && \
    apk -U --no-cache add jq && \
    chmod +x /start-sonar-scanner.sh

CMD ["/start-sonar-scanner.sh"]