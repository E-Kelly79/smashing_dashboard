module Builds
  DEPLOYMENT_CONFIG = JSON.parse(File.read('config/deployment.json'))
  DEPLOYMENT_LIST = DEPLOYMENT_CONFIG['integrations']
  RD_CONFIG = JSON.parse(File.read('config/rd.json'))
  RD_LIST = RD_CONFIG['integrations']
end