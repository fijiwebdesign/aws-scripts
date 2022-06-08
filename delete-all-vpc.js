const { deleteVpcAndDependencies, describeVpcsForRegions, listRegionNames } = require("./aws")

async function delete_all_vpcs() {
  const regions = await listRegionNames()
  const vpcList = await describeVpcsForRegions(regions)
  console.log(`Found ${vpcList.length} vpcs`)

  vpcList.forEach(async vpc => {
    console.log(`deleting vpc ${vpc.VpcId} at region ${vpc.region}`)
    const resp = await deleteVpcAndDependencies(vpc.VpcId, vpc.region)
    console.log('resp', resp)
  })
}

// @note: this is dangerous. !!!!!
// it will delete every vpc and dependencies
//delete_all_vpcs()