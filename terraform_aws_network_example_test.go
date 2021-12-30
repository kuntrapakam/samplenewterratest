package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTerraformAwsNetworkExample(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1"

	vpcCidr := "10.10.0.0/16"
	privateSubnetCidr := "10.10.1.0/24"
	publicSubnetCidr := "10.10.2.0/24"
	networkAclIdd := ""

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",

		Vars: map[string]interface{}{
			"main_vpc_cidr":       vpcCidr,
			"private_subnet_cidr": privateSubnetCidr,
			"public_subnet_cidr":  publicSubnetCidr,
			"aws_region":          awsRegion,
			"network_acl_id":      networkAclIdd,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	publicSubnetId := terraform.Output(t, terraformOptions, "public_subnet_id")
	privateSubnetId := terraform.Output(t, terraformOptions, "private_subnet_id")
	vpcId := terraform.Output(t, terraformOptions, "terratest_vpc_id")
	networkAclId := terraform.Output(t, terraformOptions, "network_acl_id")
	network_acl_id := networkAclId

	subnets := aws.GetSubnetsForVpc(t, vpcId, awsRegion)

	require.Equal(t, 2, len(subnets))

	assert.True(t, aws.IsPublicSubnet(t, publicSubnetId, awsRegion))

	assert.False(t, aws.IsPublicSubnet(t, privateSubnetId, awsRegion))
	assert.Equal(t, network_acl_id, networkAclId)
}
