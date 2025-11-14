$tfPlanPath = "tfplan.json"

if (Test-Path $tfPlanPath) { 
    Write-Output "`u{2705} Checking if terrafom plan exists - OK. "
} else { 
    throw "`u{1F635} Unable to find terraform plan file. Please make sure that you saved terraform execution plan to the file and try again. "
}

$plan = (Get-Content -Path $tfPlanPath | ConvertFrom-Json) 

$ami = $plan.configuration.root_module.resources | Where-Object {$_.type -eq "aws_ami"} | Where-Object {$_.mode -eq "data" }
if ($ami -and ($ami.Count -eq 1 )) {
    Write-Output "`u{2705} Checking if AMI data source is present - OK. "
} else { 
    throw "`u{1F635} Unable to find AMI data source. Please make sure that you uncommended the aws_ami data source and try again. "
}

$keyPair = $plan.configuration.root_module.resources | Where-Object {$_.type -eq "aws_key_pair"} 
if ($keyPair  -and ($keyPair.Count -eq 1 )) {
    Write-Output "`u{2705} Checking if key pair resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find ssh key pair resource. Please make sure that you added the 'aws_key_pair' resource to the configuratoin and try again. "
}

$instance = $plan.resource_changes | Where-Object {$_.type -eq "aws_instance"} 
if ($instance  -and ($instance.Count -eq 1 )) {
    Write-Output "`u{2705} Checking EC2 instance resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find EC2 instance resource. Please make sure that you added the 'aws_instance' resource to the configuratoin and try again. "
}
if ($instance.change.after.instance_type -eq "t3.micro") { 
    Write-Output "`u{2705} Checking instance type - OK. "
} else { 
    throw "`u{1F635} Unable to validate instance type. Please make sure that you used t3.micro instance type and try again. "
}
if ($instance.change.after.associate_public_ip_address -eq $true) { 
    Write-Output "`u{2705} Checking instance public IP assignment - OK. "
} else { 
    throw "`u{1F635} Unable to validate instance public IP assignment. Please make sure that you used parameter 'associate_public_ip_address' to enable auto-assignment of instance public IP and try again. "
}
if ($instance.change.after.subnet_id) { 
    Write-Output "`u{2705} Checking if the subnet is set for the instance - OK. "
} else { 
    throw "`u{1F635} Unable to validate subnet settings for the instance. Please make sure that you used parameter 'subnet_id' to set the subnet id for the instance and try again. "
}
if ($instance.change.after.vpc_security_group_ids) { 
    Write-Output "`u{2705} Checking if the security group is set for the instance - OK. "
} else { 
    throw "`u{1F635} Unable to validate security group settings for the instance. Please make sure that you used parameter 'vpc_security_group_ids' to set the security group id for the instance and try again. "
}
if ($instance.change.after.tags.Name -eq "mate-aws-grafana-lab") { 
    Write-Output "`u{2705} Checking if instance has a name - OK. "
} else { 
    throw "`u{1F635} Unable to validate instance name tag. Please make sure that you added a 'Name' tag with value 'mate-aws-grafana-lab' for the ec2 instance and try again. "
}
if ($instance.change.after.user_data) { 
    Write-Output "`u{2705} Checking if user data is set on the instance - OK. "
} else { 
    throw "`u{1F635} Unable to validate instance user data. Please make sure that you used parameter 'user_data' to pass the Grafana installation script to instance and try again. "
}
if ($instance.change.after.iam_instance_profile) { 
    Write-Output "`u{2705} Checking if instance profile is set for the instance - OK. "
} else { 
    throw "`u{1F635} Unable to validate instance profile is beeing set on the instance. Please make sure that you used parameter 'iam_instance_profile' to set instance profile and try again. "
}

$policy = $plan.resource_changes | Where-Object {$_.type -eq "aws_iam_policy"} 
if ($policy  -and ($policy.Count -eq 1 )) {
    Write-Output "`u{2705} Checking that policy resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find policy resource. Please make sure that you added the 'aws_iam_policy' resource to the configuratoin and try again. "
}

$role = $plan.resource_changes | Where-Object {$_.type -eq "aws_iam_role"} 
if ($role  -and ($role.Count -eq 1 )) {
    Write-Output "`u{2705} Checking that role resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find role resource. Please make sure that you added the 'aws_iam_role' resource to the configuratoin and try again. "
}

$policyAttachment = $plan.resource_changes | Where-Object {$_.type -eq "aws_iam_role_policy_attachment"} 
if ($policyAttachment  -and ($policyAttachment.Count -eq 1 )) {
    Write-Output "`u{2705} Checking that policy to role attachment resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find policy to role attachment resource. Please make sure that you added the 'aws_iam_role_policy_attachment' resource to the configuratoin and try again. "
}

$instanceProfile = $plan.resource_changes | Where-Object {$_.type -eq "aws_iam_instance_profile"} 
if ($instanceProfile  -and ($instanceProfile.Count -eq 1 )) {
    Write-Output "`u{2705} Checking that instance profile resource is present - OK. "
} else { 
    throw "`u{1F635} Unable to find instance profile resource. Please make sure that you added the 'aws_iam_instance_profile' resource to the configuratoin and try again. "
}

Write-Output ""
Write-Output "`u{1F973} Congratulations! All tests passed!"
