const util = require('util');
const exec = util.promisify(require('child_process').exec);

async function awsExec(cmd) {
  try {
      const { stdout, stderr } = await exec(cmd)
      if (stderr) throw new Error(stderr)
      return stdout
  } catch (err) {
    throw err
  }
}

async function awsExecJson(cmd) {
  return JSON.parse(await awsExec(cmd))
}

async function describeRegions() {
  return awsExecJson('aws ec2 describe-regions --region us-east-1')
}

async function listRegionNames() {
  const { Regions } = await describeRegions()
  return Regions.map(region => region.RegionName)
}

async function listInstanceNames(region, states = 'pending,running,stopped,stopping') {
  const cmd = `aws ec2 describe-instances --filters  "Name=instance-state-name,Values=${states}" --query "Reservations[].Instances[].[InstanceId]" --region ${region}`
  const json = await awsExecJson(cmd)
  return json.flat()
}

async function shutDownInstances(instances, region) {
  const ids = instances.join(' ')
  const cmd = `aws ec2 stop-instances --region ${region} --instance-ids ${ids}`
  return awsExecJson(cmd)
}

async function shutDownAllRunningInstances() {
  const regions = await listRegionNames()
  regions.forEach(async region => {
    console.log('Getting EC2 instances for ' + region)
    const instances = await listInstanceNames(region, 'running')
    if (instances.length) {
      console.log(`Shutting down ${instances.length} instances`)
      shutDownInstances(instances, region)
    }
  })
}

async function countAllInstances() {
  const regions = await listRegionNames()
  const instanceList = await Promise.all(regions.map(region => listInstanceNames(region)))
  const sum = instanceList.reduce((sum, list) => sum + list.length, 0)
  console.log('total instances', sum)
}

async function describeVpcsForRegion(region) {
  const cmd = `aws ec2 describe-vpcs --region ${region} --query "Vpcs[]"`
  return awsExecJson(cmd)
}

async function describeVpcsForRegions(regions) {
  const vpcList = await Promise.all(regions.map(async region => {
    const list = await describeVpcsForRegion(region)
    return list.map(vpc => ({ ...vpc, region }))
  }))
  return vpcList.flat()
}

async function disableVpcClassicLink(id, region) {
  const cmd = `aws ec2 disable-vpc-classic-link --vpc-id ${id} --region ${region}`
  return awsExecJson(cmd)
}

async function deleteVpc(id, region) {
  const cmd = `aws ec2 delete-vpc-endpoints --vpc-id ${id} --region ${region}`
  return awsExecJson(cmd)
}

async function deleteVpcAndDependencies(id, region) {
  const cmd = `sh ./delete_vpc/delete_vpc.sh ${region} ${id} --non-interactive`
  return awsExec(cmd)
}

module.exports = {
  awsExec,
  awsExecJson,
  describeRegions,
  listRegionNames,
  listInstanceNames,
  shutDownInstances,
  shutDownAllRunningInstances,
  countAllInstances,
  describeVpcsForRegion,
  describeVpcsForRegions,
  disableVpcClassicLink,
  deleteVpc,
  deleteVpcAndDependencies
}