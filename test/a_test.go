package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraform(t *testing.T) {
	tfOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./envs/_example/",
	})

	terraform.Init(t, tfOpts)
	defer terraform.Destroy(t, tfOpts)

	terraform.Apply(t, tfOpts)

	tfOutVPC := terraform.OutputRequired(t, tfOpts, "vpc")
	t.Logf("=====%#v\n", tfOutVPC)

	//tfOutZone := terraform.OutputRequired(t, tfOpts, "zone")
	//t.Logf("=====%#v\n", tfOutZone)
}
