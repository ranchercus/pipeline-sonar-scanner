#!/bin/sh

cat << EOF > /usr/lib/sonar-scanner-4.0.0.1744/conf/sonar-scanner.properties
sonar.host.url=${SONAR_HOST_URL}
sonar.login=${SONAR_LOGIN}
sonar.sourceEncoding=${SONAR_SOURCE_ENCODING}
EOF

echo -e "${SONAR_PROJECT_PROPERTIES}" > ./sonar-project.properties

sonar-scanner

function s_echo(){
        echo "=================================================================="
        echo "--------------------Sonar Scan results----------------------------"
        echo -e "The sonar result is: ${result}"
        echo -e "PDF Report URL:"
        echo -e "${SONAR_HOST_URL}/api/pdfreport/get?componentKey=${SONAR_PROJECT_KEY}"
        echo "================================================================="
}

function f_echo(){
        echo "=================================================================="
        echo "--------------------Sonar Scan results----------------------------"
        echo -e "The sonar result is: ${result}"
        echo -e "The ${critical_violations}: ${critical_value}"
        echo -e "The ${major_violations}: ${major_value}"
        echo -e "The ${blocker_violations}: ${blocker_value}"
        echo ""
        echo -e "Sonar scan Unqualified !\n"
        echo -e "Please Modify the code to Meet the sonar rules !\n"
        echo "================================================================="
        exit 99;
}

sonar_qc () {
    componentKey="jenkins:${JOB_NAME}"
    wget -q -t 3 -O .sonarqcfile "${SONAR_HOST_URL}/api/measures/component?componentKey=${SONAR_PROJECT_KEY}&metricKeys=major_violations,blocker_violations,critical_violations" || exit 1
    # 获取质量阈值
    critical_violations=$(cat .sonarqcfile | jq -r .component.measures[0].metric)
    major_violations=$(cat .sonarqcfile | jq -r .component.measures[1].metric)
    blocker_violations=$(cat .sonarqcfile | jq -r .component.measures[2].metric)
    critical_value=$(cat .sonarqcfile | jq -r .component.measures[0].value)
    major_value=$(cat .sonarqcfile | jq -r .component.measures[1].value)
    blocker_value=$(cat .sonarqcfile | jq -r .component.measures[2].value)

    if [[ ${critical_value} -gt 0 ]] || [[ ${major_value} -gt 0 ]] || [[ ${blocker_value} -gt 0 ]]; then
        result=Failed
        f_echo;
    else
        result=Successed
        s_echo;
    fi
}

sonar_qc;