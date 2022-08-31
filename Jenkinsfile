def DockerApp
def DockerAppDB
def DockerDB
def DockerDyalog
def Testfile = "/tmp/dcms-CI.log"
def Branch = env.BRANCH_NAME.toLowerCase()

node ('Docker') {
	stage ('Checkout') {
		checkout scm
	}
	stage ('Update Dyalog') {
		withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
			DockerDyalog=docker.image('dyalog/dyalog:odbc')
			DockerDyalog.pull()
		}
	}
	stage ('Update MariaDB') {
			withDockerRegistry(credentialsId: '0435817a-5f0f-47e1-9dcc-800d85e5c335') {
			DockerDB=docker.image('mariadb')
			DockerDB.pull()
		}
	}
	stage ('Test service') {
		DockerAppDB = DockerDB.run ("-e MYSQL_RANDOM_ROOT_PASSWORD=true -e MYSQL_DATABASE=dyalog_cms -e MYSQL_USER=dcms -e MYSQL_PASSWORD=apl --name dcmsdb")
		
		def DBIP = sh (
			script: "docker inspect ${DockerAppDB.id} | jq .[0].NetworkSettings.IPAddress | sed 's/\"//g'",
			returnStdout: true
		).trim()
		
		sh "echo ${DBIP}"
		sleep 10
		
		withCredentials([file(credentialsId: '205bc57d-1fae-4c67-9aeb-44c1144f071c', variable: 'DCMS_SECRETS')]) {
			DockerApp = DockerDyalog.run ("-t -u 6203 -v $DCMS_SECRETS:$DCMS_SECRETS -e CONFIGFILE=/app/run.dcfg -e SECRETS=$DCMS_SECRETS -e SQL_SERVER=${DBIP} -e SQL_DATABASE=dyalog_cms -e SQL_USER=dcms -e SQL_PASSWORD=apl -e SQL_PORT=3306 -v $WORKSPACE:/app")
			println(DockerApp.id)
			
			def DOCKER_IP = sh (
				script: "docker inspect ${DockerApp.id} | jq .[0].NetworkSettings.IPAddress | sed 's/\"//g'",
				returnStdout: true
			).trim()
			
			try {
				sh "sleep 1 && rm -f ${Testfile} && touch ${Testfile} && ${WORKSPACE}/CI/runtests.sh ${Testfile} ${DOCKER_IP}"
			}
			catch (e) {
				DockerAppDB.stop()
				println 'Failed to start DCMS service correctly - cleaning up.'
				sh ("docker logs ${DockerApp.id}")
				sh ('git rev-parse --short HEAD > .git/commit-id')
				withCredentials([string(credentialsId: '250bdc45-ee69-451a-8783-30701df16935', variable: 'GHTOKEN')]) {
					commit_id = readFile('.git/commit-id')
					sh "${WORKSPACE}/CI/githubComment.sh ${DockerApp.id} ${commit_id}"
				}
				DockerApp.stop()
				echo "Throwing Exception..."
				echo "Exception is: ${e}"
				throw new Exception("${e}");
			}
		}
		DockerApp.stop()
		DockerAppDB.stop()
	}

	stage ('Publish Try APL') {
		withCredentials([file(credentialsId: '205bc57d-1fae-4c67-9aeb-44c1144f071c', variable: 'DCMS_SECRETS')]) {
		sh 'mkdir -p ${WORKSPACE}/secrets && cat $DCMS_SECRETS >> ${WORKSPACE}/secrets/secrets.json5'
        if (Branch == 'master') {
            ftpPublisher alwaysPublishFromMaster: false, continueOnError: false, failOnError: false, publishers: [[
                configName: 'DCMSWeb',
                transfers: [[
                    asciiMode: false,
                    cleanRemote: false,
                    excludes: '',
                    flatten: false,
                    makeEmptyDirs: false,
                    noDefaultExcludes: false,
                    patternSeparator: '[, ]+',
                    remoteDirectory: "/${Branch}/",
                    remoteDirectorySDF: false,
                    removePrefix: '',
                    sourceFiles: '**/*'
                ]],
                usePromotionTimestamp: false,
                useWorkspaceInPromotion: false,
                verbose: true
            ]]
        } else {
            sh ("mkdir -p /DockerVolumes/ftp/dcmsweb/${Branch}/")
            sh ("cp -R * /DockerVolumes/ftp/dcmsweb/${Branch}/")
        }
		}
    }
	stage ('Create ENV file') {
		// This will come from Jenkins data after testing
		sh '''
		  echo SQL_SERVER=db > ${WORKSPACE}/env
		  echo SQL_DATABASE=dyalog_cms >> ${WORKSPACE}/env
		  echo SQL_USER=dcms >> ${WORKSPACE}/env
		  echo SQL_PASSWORD=apl >> ${WORKSPACE}/env
		  echo SQL_PORT=3306 >> ${WORKSPACE}/env
		  echo SECRETS=/app/secrets/secrets.json5 >> ${WORKSPACE}/env
		  echo RIDE_INIT=http:*:4502 >> ${WORKSPACE}/env
		  echo MYSQL_DATABASE=dyalog_cms >> ${WORKSPACE}/env
		  echo MYSQL_USER=dcms >> ${WORKSPACE}/env
		  echo MYSQL_PASSWORD=apl >> ${WORKSPACE}/env
		  echo MYSQL_PORT=3306 >> ${WORKSPACE}/env
		  echo CONFIGFILE=/app/run.dcfg >> ${WORKSPACE}/env

		  echo MYSQL_RANDOM_ROOT_PASSWORD=1 >> ${WORKSPACE}/env
		'''
	}
	stage('Deploying with Rancher') {
        withCredentials([
                usernamePassword(credentialsId: '02543ae7-7ed9-4448-ba20-6b367d302ecc', passwordVariable: 'SECRETKEY', usernameVariable: 'ACCESSKEY')]) {
            if (env.BRANCH_NAME.contains('master')) {
                sh ("sed -i 's%\${PWD}%/DockerVolumes/ftp/dcmsweb/${Branch}/%g' ./docker-compose.yml")
                sh '/usr/local/bin/rancher-compose -f ./docker-compose.yml --access-key $ACCESSKEY --secret-key $SECRETKEY --url http://rancher.dyalog.com:8080/v2-beta/projects/1a5/stacks/1st60 -p DCMS up --force-upgrade --confirm-upgrade --pull -d'
            }
        }
    }
}