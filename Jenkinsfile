PROJECT = 'fuelsdk'

pipeline {
  agent any

  options {
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10')) // only keep artifacts of the last 10 builds
  }

  parameters {
    booleanParam(name: 'PRE_NOTIFY', defaultValue: true, description: 'Notify of start of build for master branch')
    booleanParam(name: 'CHECK_SEMAPHORE', defaultValue: true, description: 'Check current Semaphore tests status')
    booleanParam(name: 'BUILD_GEM', defaultValue: true, description: "Build and push ${PROJECT} gem to Gemstash")
    booleanParam(name: 'POST_NOTIFY', defaultValue: true, description: 'Notify of the result of the build for master branch')
  }

  environment {
    GEM_VERSION = sh(
      script: "_pipeline/utils/gem_version.sh ${PROJECT}.gemspec",
      returnStdout: true
    ).trim()
  }

  stages {
    stage('Pre Notify') {
      when {
        anyOf {
          branch 'master'
          expression { return params.PRE_NOTIFY }
        }
      }
      steps {
        sh "bnw_runner ./_pipeline/utils/slack_notification_on_master.sh ${PROJECT} ${currentBuild.currentResult} 'Starting build for ${PROJECT} v${GEM_VERSION}'"
      }
    }

    stage('Build Gem') {
      when {
        anyOf {
          branch 'master'
          expression { return params.BUILD_GEM }
        }
      }
      steps {
        sh "bnw_runner ./_pipeline/step_build_gem.sh"
      }
      post {
        failure {
          script {
            sh "bnw_runner ./_pipeline/utils/slack_notification_on_master.sh ${PROJECT} FAILURE '${PROJECT} BUILD step has failed'"
          }
        }
      }
    }

    stage('Post Notify') {
      when {
        anyOf {
          branch 'master'
          expression { return params.POST_NOTIFY }
        }
      }
      steps {
        sh "bnw_runner ./_pipeline/utils/slack_notification_on_master.sh ${PROJECT} ${currentBuild.currentResult} 'Completed build for ${PROJECT} v${GEM_VERSION}'"
      }
    }
  }
}