package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type VPCOutput struct {
	VPCIPv6AssociationID         string   `json:"vpc_ipv6_association_id"`
	VPCIPv6CIDRBlock             string   `json:"vpc_ipv6_cidr_block"`
	PrivateSubnetsIPv6CIDRBlocks []string `json:"private_subnets_ipv6_cidr_blocks"`
	PublicSubnetsIPv6CIDRBlocks  []string `json:"public_subnets_ipv6_cidr_blocks"`
}

func TestTerraform(t *testing.T) {
	tfOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./envs/_example/",
		TerraformBinary: "terragrunt",
	})

	terraform.Init(t, tfOpts)
	defer terraform.Destroy(t, tfOpts)

	terraform.Apply(t, tfOpts)

	gotVPCOutput := VPCOutput{}
	terraform.OutputStruct(t, tfOpts, "vpc", &gotVPCOutput)
	assert.NotEmpty(t, gotVPCOutput.VPCIPv6AssociationID)
	assert.NotEmpty(t, gotVPCOutput.VPCIPv6CIDRBlock)
	assert.NotEmpty(t, gotVPCOutput.PrivateSubnetsIPv6CIDRBlocks)
	assert.NotEmpty(t, gotVPCOutput.PublicSubnetsIPv6CIDRBlocks)

	terraform.OutputRequired(t, tfOpts, "zone")
}
